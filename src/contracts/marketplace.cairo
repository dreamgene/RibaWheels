// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^1.0.0

const PAUSER_ROLE: felt252 = selector!("PAUSER_ROLE");
const UPGRADER_ROLE: felt252 = selector!("UPGRADER_ROLE");
const ADMIN_ROLE: felt252 = selector!("ADMIN_ROLE");

// Fee scaling factor for validator fees
// 100 means fees are stored with 2 decimal places (e.g., 250 = 2.50%)
const FEE_SCALING_FACTOR: u32 = 100;

// Enhanced Validator Registration System Constants
const MIN_STAKE_AMOUNT: u256 = 1000_000000000000000000; // 1000 STRK minimum stake
const MIN_EXPERIENCE_YEARS: u32 = 2;
const VALIDATOR_BOND_PERCENTAGE: u32 = 10; // 10% of transaction value as bond
const MAX_VALIDATORS_PER_SPECIALIZATION: u32 = 50; // Limit validators per category
const STAKE_LOCK_PERIOD: u64 = 2592000; // 30 days in seconds

#[starknet::contract]
mod RibaWheelsMarketplace {
    // Import conversion traits
    use core::traits::Into;
    use core::num::traits::Zero;
    use openzeppelin::access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::security::pausable::PausableComponent;
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use starknet::event::EventEmitter;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{
        ClassHash, ContractAddress, get_block_timestamp, get_caller_address, get_contract_address,
    };
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::interfaces::Icar_nft::{ICarNFTDispatcher, ICarNFTDispatcherTrait};
    use crate::interfaces::Imarket_place::IRibaWheelsMarketplace;
    use crate::Structs::Structs::{ValidatorApplication, ApplicationStatus, ValidatorInfo, ValidatorRating, Escrow, EscrowStatus, CarListing, EnhancedValidatorApplication, ValidatorSpecialization, ValidatorPerformanceMetrics};
    // Import events
    use crate::events::market_place_event::{
        ValidatorApplicationSubmitted, ValidatorApproved, ValidatorRejected, CarListed, CarDelisted,
        EscrowCreated, ValidatorDecision, PurchaseCompleted, EscrowRefunded, ValidatorRated,
        EnhancedValidatorApplicationSubmitted, ValidatorKYCCompleted, ValidatorStakeSlashed,
        ValidatorSpecializationVerified, ValidatorStakeWithdrawn,
    };
    use super::{*, ADMIN_ROLE, PAUSER_ROLE, UPGRADER_ROLE};

    component!(path: PausableComponent, storage: pausable, event: PausableEvent);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    // External
    #[abi(embed_v0)]
    impl PausableImpl = PausableComponent::PausableImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlMixinImpl = AccessControlComponent::AccessControlMixinImpl<ContractState>;

    // Internal
    impl PausableInternalImpl = PausableComponent::InternalImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        pausable: PausableComponent::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        // Core contracts
        car_nft_contract: ContractAddress,
        strk_token: ContractAddress,
        usdc_token: ContractAddress,
        // Validators
        validators: Map<ContractAddress, ValidatorInfo>,
        validator_applications: Map<ContractAddress, ValidatorApplication>,
        validator_count: u32,
        // Car listings
        car_listings: Map<u256, CarListing>,
        active_listings: Map<u256, bool>,
        // Escrow
        escrows: Map<u256, Escrow>,
        escrow_counter: u256,
        // Ratings
        validator_ratings: Map<ContractAddress, ValidatorRating>,
        transaction_ratings: Map<u256, bool>, // escrow_id -> rated
        // Admin management
        admins: Map<ContractAddress, bool>, // Store admin addresses
        admin_addresses: Map<u32, ContractAddress>, // Store admin addresses by index
        admin_count: u32, // Keep track of total admins
        // Enhanced validator data
        enhanced_validator_applications: Map<ContractAddress, EnhancedValidatorApplication>,
        validator_stakes: Map<ContractAddress, u256>,
        validator_bonds: Map<(ContractAddress, u256), u256>, // (validator, escrow_id) -> bond_amount
        validator_documents: Map<ContractAddress, felt252>, // IPFS hash of documents
        validator_kyc_status: Map<ContractAddress, bool>,
        validator_performance: Map<ContractAddress, ValidatorPerformanceMetrics>,
        // Specialization tracking
        specializations: Map<felt252, ValidatorSpecialization>,
        validator_specialization_mapping: Map<ContractAddress, felt252>,
        // Stake management
        minimum_stake_required: u256,
        stake_unlock_time: Map<ContractAddress, u64>, // When validator can withdraw stake
        pending_stake_withdrawals: Map<ContractAddress, u256>,
        // KYC and verification
        kyc_verifier: ContractAddress, // Third-party KYC service
        background_check_provider: ContractAddress,
        document_verification_service: ContractAddress,
        // Admin settings
        registration_fee: u256, // Fee to apply as validator
        max_validators_global: u32,
        current_validator_count: u32,
    }



    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        PausableEvent: PausableComponent::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        ValidatorApplicationSubmitted: ValidatorApplicationSubmitted,
        ValidatorApproved: ValidatorApproved,
        ValidatorRejected: ValidatorRejected,
        CarListed: CarListed,
        CarDelisted: CarDelisted,
        EscrowCreated: EscrowCreated,
        ValidatorDecision: ValidatorDecision,
        PurchaseCompleted: PurchaseCompleted,
        EscrowRefunded: EscrowRefunded,
        ValidatorRated: ValidatorRated,
        EnhancedValidatorApplicationSubmitted: EnhancedValidatorApplicationSubmitted,
        ValidatorKYCCompleted: ValidatorKYCCompleted,
        ValidatorStakeSlashed: ValidatorStakeSlashed,
        ValidatorSpecializationVerified: ValidatorSpecializationVerified,
        ValidatorStakeWithdrawn: ValidatorStakeWithdrawn,
    }



    mod Errors {
        const UNAUTHORIZED: felt252 = 'Caller not authorized';
        const VALIDATOR_NOT_APPROVED: felt252 = 'Validator not approved';
        const VALIDATOR_ALREADY_APPROVED: felt252 = 'Validator already approved';
        const APPLICATION_NOT_FOUND: felt252 = 'Application not found';
        const CAR_NOT_LISTED: felt252 = 'Car not listed';
        const CAR_ALREADY_LISTED: felt252 = 'Car already listed';
        const INSUFFICIENT_PAYMENT: felt252 = 'Insufficient payment';
        const ESCROW_NOT_FOUND: felt252 = 'Escrow not found';
        const ESCROW_NOT_ACTIVE: felt252 = 'Escrow not active';
        const INVALID_RATING: felt252 = 'Invalid rating (1-5)';
        const ALREADY_RATED: felt252 = 'Already rated';
        const NOT_BUYER: felt252 = 'Not the buyer';
        const NOT_VALIDATOR: felt252 = 'Not the validator';
        const INVALID_TOKEN: felt252 = 'Invalid token';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        car_nft_contract: ContractAddress,
        strk_token: ContractAddress,
        usdc_token: ContractAddress,
    ) {
        // Initialize OpenZeppelin components
        self.accesscontrol.initializer();
        
        // Grant roles to owner
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, owner);
        self.accesscontrol._grant_role(ADMIN_ROLE, owner);
        self.accesscontrol._grant_role(PAUSER_ROLE, owner);
        self.accesscontrol._grant_role(UPGRADER_ROLE, owner);
        
        // Set up admin tracking
        self.admins.write(owner, true);
        self.admin_addresses.write(0, owner);
        self.admin_count.write(1);
        
        // Initialize contract state
        self.car_nft_contract.write(car_nft_contract);
        self.strk_token.write(strk_token);
        self.usdc_token.write(usdc_token);
        self.escrow_counter.write(1);
        
        // Initialize enhanced validator settings
        self.minimum_stake_required.write(MIN_STAKE_AMOUNT);
        self.registration_fee.write(0); // No registration fee initially
        self.max_validators_global.write(1000); // Max 1000 validators
        self.current_validator_count.write(0);
    }

    #[abi(embed_v0)]
    impl RibaWheelsMarketplaceImpl of IRibaWheelsMarketplace<ContractState> {
        // Validator Management
        fn apply_as_validator(ref self: ContractState, description: felt252, experience: felt252) {
            self.pausable.assert_not_paused();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();
            
            let application = ValidatorApplication {
                applicant: caller,
                description,
                experience,
                application_date: current_time,
                status: ApplicationStatus::Pending,
            };
            
            self.validator_applications.write(caller, application);
            self.emit(ValidatorApplicationSubmitted { applicant: caller, description, experience });
        }

        fn approve_validator(ref self: ContractState, validator: ContractAddress) {
            self.accesscontrol.assert_only_role(ADMIN_ROLE);
            self.pausable.assert_not_paused();
            
            let application = self.validator_applications.read(validator);
            assert(application.status == ApplicationStatus::Pending, 'Application not pending');
            
            let updated_application = ValidatorApplication {
                status: ApplicationStatus::Approved,
                ..application
            };
            self.validator_applications.write(validator, updated_application);
            
            let validator_info = ValidatorInfo {
                is_approved: true,
                is_active: true,
                application_date: application.application_date,
                approval_date: get_block_timestamp(),
            };
            self.validators.write(validator, validator_info);
            
            let count = self.validator_count.read();
            self.validator_count.write(count + 1);
            
            self.emit(ValidatorApproved { validator });
        }

        fn reject_validator(ref self: ContractState, applicant: ContractAddress) {
            self.accesscontrol.assert_only_role(ADMIN_ROLE);
            self.pausable.assert_not_paused();
            
            let application = self.validator_applications.read(applicant);
            assert(application.status == ApplicationStatus::Pending, 'Application not pending');
            
            let updated_application = ValidatorApplication {
                status: ApplicationStatus::Rejected,
                ..application
            };
            self.validator_applications.write(applicant, updated_application);
            
            self.emit(ValidatorRejected { applicant });
        }
        // Car Listing Management
        fn list_car(
            ref self: ContractState,
            make: felt252,
            model: felt252,
            year: u32,
            mileage: u64,
            vin: felt252,
            chassis_number: felt252,
            price_strk: u256,
            price_usdc: u256,
            description: felt252,
        ) -> u256 {
            self.pausable.assert_not_paused();
            let caller = get_caller_address();
            let car_nft = ICarNFTDispatcher { contract_address: self.car_nft_contract.read() };
            
            // Mint the car NFT
            let token_id = car_nft.mint_car(caller, make, model, year, mileage, vin, chassis_number);
            
            let current_time = get_block_timestamp();
            let listing = CarListing {
                seller: caller,
                token_id,
                price_strk,
                price_usdc,
                description,
                is_active: true,
                listing_date: current_time,
            };
            
            self.car_listings.write(token_id, listing);
            self.active_listings.write(token_id, true);
            
            self.emit(CarListed { token_id, seller: caller, price_strk, price_usdc });
            token_id
        }

        fn delist_car(ref self: ContractState, token_id: u256) {
            self.pausable.assert_not_paused();
            let caller = get_caller_address();
            let mut listing = self.car_listings.read(token_id);
            
            // Only seller or admin can delist
            assert(
                listing.seller == caller || self.accesscontrol.has_role(ADMIN_ROLE, caller),
'Caller not authorized'
            );
            assert(listing.is_active, 'Car not listed');
            
            listing.is_active = false;
            self.car_listings.write(token_id, listing);
            self.active_listings.write(token_id, false);
            
            let car_nft = ICarNFTDispatcher { contract_address: self.car_nft_contract.read() };
            car_nft.update_listing_status(token_id, false);
            
            self.emit(CarDelisted { token_id });
        }

        // Purchase Flow
        fn create_purchase_escrow(
            ref self: ContractState,
            token_id: u256,
            validator: ContractAddress,
            use_strk: bool,
        ) -> u256 {
            self.pausable.assert_not_paused();
            let buyer = get_caller_address();
            let listing = self.car_listings.read(token_id);
            
            assert(listing.is_active, 'Car not listed');
            assert(self.validators.read(validator).is_approved, 'Validator not approved');
            
            let price = if use_strk { listing.price_strk } else { listing.price_usdc };
            let token_address = if use_strk { self.strk_token.read() } else { self.usdc_token.read() };
            
            // Calculate validator fee based on rating
            let validator_fee = self._calculate_validator_fee(validator, price);
            let total_amount = price + validator_fee;
            
            // Transfer tokens to escrow
            let token = IERC20Dispatcher { contract_address: token_address };
            token.transfer_from(buyer, get_contract_address(), total_amount);
            
            let escrow_id = self.escrow_counter.read();
            self.escrow_counter.write(escrow_id + 1);
            
            let escrow = Escrow {
                buyer,
                seller: listing.seller,
                validator,
                token_id,
                amount: price,
                validator_fee,
                token_address,
                status: EscrowStatus::Active,
                creation_date: get_block_timestamp(),
            };
            
            self.escrows.write(escrow_id, escrow);
            
            self.emit(EscrowCreated {
                escrow_id,
                buyer,
                seller: listing.seller,
                validator,
                token_id,
                amount: total_amount,
            });
            
            escrow_id
        }

        fn validator_decision(ref self: ContractState, escrow_id: u256, proceed: bool) {
            let caller = get_caller_address();
            let escrow = self.escrows.read(escrow_id);
            
            assert(escrow.validator == caller, 'Not the validator');
            assert(escrow.status == EscrowStatus::Active, 'Escrow not active');
            
            let updated_escrow = Escrow {
                status: EscrowStatus::ValidatorDecisionPending,
                ..escrow
            };
            self.escrows.write(escrow_id, updated_escrow);
            
            self.emit(ValidatorDecision {
                escrow_id,
                validator: caller,
                proceed,
            });
        }

        fn finalize_purchase(ref self: ContractState, escrow_id: u256, proceed: bool) {
            let caller = get_caller_address();
            let escrow = self.escrows.read(escrow_id);
            
            assert(escrow.buyer == caller, 'Not the buyer');
            assert(escrow.status == EscrowStatus::ValidatorDecisionPending, 'Escrow not pending');
            
            let token = IERC20Dispatcher { contract_address: escrow.token_address };
            
            if proceed {
                // Transfer payment to seller
                token.transfer(escrow.seller, escrow.amount);
                // Transfer validator fee
                token.transfer(escrow.validator, escrow.validator_fee);
                
                // Transfer NFT to buyer
                let car_nft = ICarNFTDispatcher { contract_address: self.car_nft_contract.read() };
                car_nft.transfer_car(escrow.seller, escrow.buyer, escrow.token_id);
                
                // Update listing status
                let listing = self.car_listings.read(escrow.token_id);
                let updated_listing = CarListing {
                    is_active: false,
                    ..listing
                };
                self.car_listings.write(escrow.token_id, updated_listing);
                
                let final_escrow = Escrow {
                    status: EscrowStatus::Completed,
                    ..escrow
                };
            self.escrows.write(escrow_id, final_escrow);
                
                self.emit(PurchaseCompleted {
                    escrow_id,
                    buyer: escrow.buyer,
                    seller: escrow.seller,
                    token_id: escrow.token_id,
                });
            } else {
                // Refund buyer (minus small validator dispute fee)
                let dispute_fee = escrow.validator_fee / 2; // 50% of validator fee as dispute fee
                let refund_amount = escrow.amount + escrow.validator_fee - dispute_fee;
                
                token.transfer(escrow.buyer, refund_amount);
                token.transfer(escrow.validator, dispute_fee);
                
                let mut updated_escrow = escrow;
                let refunded_escrow = Escrow {
                    status: EscrowStatus::Refunded,
                    ..updated_escrow
                };
                self.escrows.write(escrow_id, refunded_escrow);
                
                
                self.emit(EscrowRefunded {
                    escrow_id,
                    buyer: escrow.buyer,
                    amount: refund_amount,
                });
            }
        }

        // Rating System
        fn rate_validator(ref self: ContractState, escrow_id: u256, rating: u8) {
            let caller = get_caller_address();
            let escrow = self.escrows.read(escrow_id);
            
            assert(escrow.buyer == caller, 'Not the buyer');
            assert(rating >= 1 && rating <= 5, 'Invalid rating (1-5)');
            assert(!self.transaction_ratings.read(escrow_id), 'Already rated');
            
            // Mark as rated
            self.transaction_ratings.write(escrow_id, true);
            
            // Update validator rating
            let validator_rating = self.validator_ratings.read(escrow.validator);
            let new_total_rating = validator_rating.total_rating + rating.into();
            let new_rating_count = validator_rating.rating_count + 1;
            
            let updated_rating = ValidatorRating {
                total_rating: new_total_rating,
                rating_count: new_rating_count,
                average_rating: (new_total_rating * 100) / new_rating_count,
            };
            self.validator_ratings.write(escrow.validator, updated_rating);
            
            self.emit(ValidatorRated {
                validator: escrow.validator,
                buyer: caller,
                rating,
                new_average: updated_rating.average_rating,
            });
        }

        // Getters
        fn get_validator_info(self: @ContractState, validator: ContractAddress) -> ValidatorInfo {
            let validator_info: ValidatorInfo = self.validators.read(validator);
            validator_info
        }

        fn get_validator_application(self: @ContractState, applicant: ContractAddress) -> ValidatorApplication {
            let application: ValidatorApplication = self.validator_applications.read(applicant);
            application
        }

        fn get_car_listing(self: @ContractState, token_id: u256) -> CarListing {
            let listing: CarListing = self.car_listings.read(token_id);
            listing
        }

        fn get_escrow_data(self: @ContractState, escrow_id: u256) -> Escrow {
            let escrow: Escrow = self.escrows.read(escrow_id);
            escrow
        }

        fn get_validator_rating(self: @ContractState, validator: ContractAddress) -> ValidatorRating {
            let rating: ValidatorRating = self.validator_ratings.read(validator);
            rating
        }

        fn is_car_listed(self: @ContractState, token_id: u256) -> bool {
            self.active_listings.read(token_id)
        }

        // Pausable functions
        fn pause_contract(ref self: ContractState) {
            // Only users with PAUSER_ROLE can pause the contract
            let caller = get_caller_address();
            let has_pauser_role = self.accesscontrol.has_role(PAUSER_ROLE, caller);
            assert(has_pauser_role, 'Caller is not a pauser');
            self.pausable.pause();
        }

        fn unpause_contract(ref self: ContractState) {
            // Only users with PAUSER_ROLE can unpause the contract
            let caller = get_caller_address();
            let has_pauser_role = self.accesscontrol.has_role(PAUSER_ROLE, caller);
            assert(has_pauser_role, 'Caller is not a pauser');
            self.pausable.unpause();
        }
        

        fn contract_is_paused(self: @ContractState) -> bool {
            self.pausable.is_paused()
        }

        // Admin management functions
        fn add_admin(ref self: ContractState, admin: ContractAddress) {
            // Check if contract is paused
            self.pausable.assert_not_paused();

            // Use OpenZeppelin's has_role instead of custom modifier
            let caller = get_caller_address();
            let has_default_admin_role = self.accesscontrol.has_role(DEFAULT_ADMIN_ROLE, caller);
            assert(has_default_admin_role, 'Caller is not the admin');

            // Check if already an admin
            let is_already_admin = self.admins.read(admin);
            if !is_already_admin {
                // Add to admins mapping
                self.admins.write(admin, true);

                // Add to admin addresses list
                let current_count = self.admin_count.read();
                self.admin_addresses.write(current_count, admin);
                self.admin_count.write(current_count + 1);

                // Grant ADMIN_ROLE to the new admin
                self.accesscontrol._grant_role(ADMIN_ROLE, admin);
            }
        }

        fn remove_admin(ref self: ContractState, admin: ContractAddress) {
            // Check if contract is paused
            self.pausable.assert_not_paused();

            // Use OpenZeppelin's has_role instead of custom modifier
            let caller = get_caller_address();
            let has_default_admin_role = self.accesscontrol.has_role(DEFAULT_ADMIN_ROLE, caller);
            assert(has_default_admin_role, 'Caller is not the admin');

            let is_admin = self.admins.read(admin);

            if is_admin {
                // Remove from admins mapping
                self.admins.write(admin, false);

                // Find and remove from admin addresses list
                let count = self.admin_count.read();
                let mut found_index: u32 = 0;
                let mut found = false;

                // Find the index of the admin to remove
                let mut i: u32 = 0;
                while i != count {
                    let current_admin = self.admin_addresses.read(i);
                    if current_admin == admin {
                        found = true;
                        found_index = i;
                        break;
                    }
                    i = i + 1_u32;
                }

                // If found, replace with the last admin and decrease count
                if found {
                    let last_index = count - 1;
                    if found_index < last_index {
                        let last_admin = self.admin_addresses.read(last_index);
                        self.admin_addresses.write(found_index, last_admin);
                    }
                    self.admin_count.write(last_index);
                }

                // Revoke ADMIN_ROLE from the admin
                self.accesscontrol._revoke_role(ADMIN_ROLE, admin);
            }
        }

        // Function to check if an address has admin privileges
        fn is_owner_or_admin(self: @ContractState, address: ContractAddress) -> bool {
            // Check if address is the owner (has DEFAULT_ADMIN_ROLE)
            let is_owner = self.accesscontrol.has_role(DEFAULT_ADMIN_ROLE, address);
            // Check if address has ADMIN_ROLE
            let is_admin = self.accesscontrol.has_role(ADMIN_ROLE, address);
            // Return true if either condition is met
            is_owner || is_admin
        }

        fn get_admins(self: @ContractState) -> Array<ContractAddress> {
            let count = self.admin_count.read();
            let mut admins = ArrayTrait::new();

            let mut i: u32 = 0;
            while i != count {
                let admin = self.admin_addresses.read(i);
                admins.append(admin);
                i = i + 1_u32;
            }

            admins
        }

        fn get_admin_count(self: @ContractState) -> u32 {
            self.admin_count.read()
        }

        // Enhanced Validator System Functions
        fn apply_as_validator_enhanced(
            ref self: ContractState,
            description: felt252,
            experience_years: u32,
            specialization: felt252,
            certifications_hash: felt252,
            documents_hash: felt252,
            stake_amount: u256,
        ) {
            self.pausable.assert_not_paused();
            let caller = get_caller_address();
            let current_time = get_block_timestamp();
            
            // Check if already applied
            let existing_app = self.enhanced_validator_applications.read(caller);
            assert(existing_app.applicant.is_zero(), 'Already applied');
            
            // Validate requirements
            assert(experience_years >= MIN_EXPERIENCE_YEARS, 'Insufficient experience');
            assert(stake_amount >= self.minimum_stake_required.read(), 'Insufficient stake amount');
            
            // Check registration fee
            let registration_fee = self.registration_fee.read();
            if registration_fee > 0 {
                let strk_token = IERC20Dispatcher { contract_address: self.strk_token.read() };
                strk_token.transfer_from(caller, get_contract_address(), registration_fee);
            }
            
            // Check global validator limit
            let current_count = self.current_validator_count.read();
            let max_global = self.max_validators_global.read();
            assert(current_count < max_global, 'Validator limit reached');
            
            // Check specialization limit
            let specialization_info = self.specializations.read(specialization);
            assert(specialization_info.validator_count < MAX_VALIDATORS_PER_SPECIALIZATION, 'Specialization limit reached');
            
            // Transfer stake to contract
            let strk_token = IERC20Dispatcher { contract_address: self.strk_token.read() };
            strk_token.transfer_from(caller, get_contract_address(), stake_amount);
            
            // Store stake and set lock period
            self.validator_stakes.write(caller, stake_amount);
            self.stake_unlock_time.write(caller, current_time + STAKE_LOCK_PERIOD);
            self.validator_documents.write(caller, documents_hash);
            self.validator_specialization_mapping.write(caller, specialization);
            
            // Create enhanced application
            let application = EnhancedValidatorApplication {
                applicant: caller,
                description,
                experience_years,
                specialization,
                certifications: certifications_hash,
                documents_hash,
                stake_amount,
                application_date: current_time,
                status: ApplicationStatus::Pending,
                kyc_completed: false,
                background_check_passed: false,
                specialization_verified: false,
            };
            
            self.enhanced_validator_applications.write(caller, application);
            
            // Initialize performance metrics
            let performance = ValidatorPerformanceMetrics {
                total_transactions: 0,
                successful_transactions: 0,
                disputed_transactions: 0,
                average_response_time: 0,
                last_activity: current_time,
                reliability_score: 1000, // Start with perfect score
            };
            self.validator_performance.write(caller, performance);
            
            self.emit(EnhancedValidatorApplicationSubmitted {
                applicant: caller,
                specialization,
                stake_amount,
                documents_hash,
            });
        }

        fn verify_validator_kyc(ref self: ContractState, validator: ContractAddress, approved: bool) {
            let caller = get_caller_address();
            let has_admin_role = self.accesscontrol.has_role(ADMIN_ROLE, caller);
            assert(has_admin_role, 'Caller is not an admin');
            
            let mut application = self.enhanced_validator_applications.read(validator);
            assert(!application.applicant.is_zero(), 'Application not found');
            
            application.kyc_completed = approved;
            self.enhanced_validator_applications.write(validator, application);
            self.validator_kyc_status.write(validator, approved);
            
            self.emit(ValidatorKYCCompleted {
                validator,
                kyc_provider: self.kyc_verifier.read(),
                status: approved,
            });
        }

        fn verify_background_check(ref self: ContractState, validator: ContractAddress, approved: bool) {
            let caller = get_caller_address();
            let has_admin_role = self.accesscontrol.has_role(ADMIN_ROLE, caller);
            assert(has_admin_role, 'Caller is not an admin');
            
            let mut application = self.enhanced_validator_applications.read(validator);
            assert(!application.applicant.is_zero(), 'Application not found');
            
            application.background_check_passed = approved;
            self.enhanced_validator_applications.write(validator, application);
        }

        fn verify_specialization(ref self: ContractState, validator: ContractAddress, approved: bool) {
            let caller = get_caller_address();
            let has_admin_role = self.accesscontrol.has_role(ADMIN_ROLE, caller);
            assert(has_admin_role, 'Caller is not an admin');
            
            let mut application = self.enhanced_validator_applications.read(validator);
            assert(!application.applicant.is_zero(), 'Application not found');
            
            application.specialization_verified = approved;
            self.enhanced_validator_applications.write(validator, application);
            
            if approved {
                self.emit(ValidatorSpecializationVerified {
                    validator,
                    specialization: application.specialization,
                    verifier: get_caller_address(),
                });
            }
        }

        fn approve_validator_enhanced(ref self: ContractState, validator: ContractAddress) {
            let caller = get_caller_address();
            let has_admin_role = self.accesscontrol.has_role(ADMIN_ROLE, caller);
            assert(has_admin_role, 'Caller is not an admin');
            self.pausable.assert_not_paused();
            
            let application = self.enhanced_validator_applications.read(validator);
            assert(application.status == ApplicationStatus::Pending, 'Application not pending');
            assert(application.kyc_completed, 'KYC not completed');
            assert(application.background_check_passed, 'Background check failed');
            assert(application.specialization_verified, 'Specialization not verified');
            
            // Final stake verification
            let current_stake = self.validator_stakes.read(validator);
            assert(current_stake >= self.minimum_stake_required.read(), 'Insufficient stake');
            
            // Update application status
            let updated_application = EnhancedValidatorApplication {
                status: ApplicationStatus::Approved,
                ..application
            };
            self.enhanced_validator_applications.write(validator, updated_application);
            
            // Update validator info
            let validator_info = ValidatorInfo {
                is_approved: true,
                is_active: true,
                application_date: application.application_date,
                approval_date: get_block_timestamp(),
            };
            self.validators.write(validator, validator_info);
            
            // Update specialization count
            let mut specialization_info = self.specializations.read(application.specialization);
            specialization_info.validator_count += 1;
            self.specializations.write(application.specialization, specialization_info);
            
            // Update global count
            let count = self.validator_count.read();
            self.validator_count.write(count + 1);
            self.current_validator_count.write(self.current_validator_count.read() + 1);
            
            self.emit(ValidatorApproved { validator });
        }

        fn get_enhanced_validator_application(self: @ContractState, applicant: ContractAddress) -> EnhancedValidatorApplication {
            let application: EnhancedValidatorApplication = self.enhanced_validator_applications.read(applicant);
            application
        }

        fn get_validator_performance(self: @ContractState, validator: ContractAddress) -> ValidatorPerformanceMetrics {
            let performance: ValidatorPerformanceMetrics = self.validator_performance.read(validator);
            performance
        }

        fn get_validator_stake(self: @ContractState, validator: ContractAddress) -> u256 {
            self.validator_stakes.read(validator)
        }

        fn get_specialization_info(self: @ContractState, specialization: felt252) -> ValidatorSpecialization {
            let spec_info: ValidatorSpecialization = self.specializations.read(specialization);
            spec_info
        }

        fn is_validator_qualified(self: @ContractState, validator: ContractAddress) -> bool {
            let validator_info = self.validators.read(validator);
            let stake = self.validator_stakes.read(validator);
            let performance = self.validator_performance.read(validator);
            
            validator_info.is_approved && 
            validator_info.is_active && 
            stake >= self.minimum_stake_required.read() &&
            performance.reliability_score >= 700 // Minimum 70% reliability
        }
    }

    // Upgradeable implementation
    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            // Use has_role instead of assert_only_role
            let caller = get_caller_address();
            let has_upgrader_role = self.accesscontrol.has_role(UPGRADER_ROLE, caller);
            assert(has_upgrader_role, 'Caller is not an upgrader');
            self.upgradeable.upgrade(new_class_hash);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _calculate_validator_fee(self: @ContractState, validator: ContractAddress, price: u256) -> u256 {
            let rating = self.validator_ratings.read(validator);
            let average_rating = rating.average_rating; // Rating * 100
            
            let fee_percentage = if average_rating >= 450 { // 4.5 stars
                3
            } else if average_rating >= 300 { // 3.0 stars
                2
            } else {
                1
            };
            
            (price * fee_percentage) / 100
        }
    }
}