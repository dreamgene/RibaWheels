use starknet::ContractAddress;
use crate::Structs::Structs::{ValidatorInfo, ValidatorApplication, CarListing, Escrow, ValidatorRating, EnhancedValidatorApplication, ValidatorSpecialization, ValidatorPerformanceMetrics};

#[starknet::interface]
pub trait IRibaWheelsMarketplace<TContractState> {
    // Validator Management
    fn apply_as_validator(ref self: TContractState, description: felt252, experience: felt252);
    fn approve_validator(ref self: TContractState, validator: ContractAddress);
    fn reject_validator(ref self: TContractState, applicant: ContractAddress);
    
    // Car Listing Management
    fn list_car(
        ref self: TContractState,
        make: felt252,
        model: felt252,
        year: u32,
        mileage: u64,
        vin: felt252,
        chassis_number: felt252,
        price_strk: u256,
        price_usdc: u256,
        description: felt252,
    ) -> u256;
    fn delist_car(ref self: TContractState, token_id: u256);
    
    // Purchase Flow
    fn create_purchase_escrow(
        ref self: TContractState,
        token_id: u256,
        validator: ContractAddress,
        use_strk: bool,
    ) -> u256;
    fn validator_decision(ref self: TContractState, escrow_id: u256, proceed: bool);
    fn finalize_purchase(ref self: TContractState, escrow_id: u256, proceed: bool);
    
    // Rating System
    fn rate_validator(ref self: TContractState, escrow_id: u256, rating: u8);
    
    // Getters
    fn get_validator_info(self: @TContractState, validator: ContractAddress) -> ValidatorInfo;
    fn get_validator_application(self: @TContractState, applicant: ContractAddress) -> ValidatorApplication;
    fn get_car_listing(self: @TContractState, token_id: u256) -> CarListing;
    fn get_escrow_data(self: @TContractState, escrow_id: u256) -> Escrow;
    fn get_validator_rating(self: @TContractState, validator: ContractAddress) -> ValidatorRating;
    fn is_car_listed(self: @TContractState, token_id: u256) -> bool;
    
    // Pausable functions
    fn pause_contract(ref self: TContractState);
    fn unpause_contract(ref self: TContractState);
    fn contract_is_paused(self: @TContractState) -> bool;
    
    // Admin management functions
    fn add_admin(ref self: TContractState, admin: ContractAddress);
    fn remove_admin(ref self: TContractState, admin: ContractAddress);
    fn is_owner_or_admin(self: @TContractState, address: ContractAddress) -> bool;
    fn get_admins(self: @TContractState) -> Array<ContractAddress>;
    fn get_admin_count(self: @TContractState) -> u32;
    
    // Enhanced Validator System Functions
    fn apply_as_validator_enhanced(
        ref self: TContractState,
        description: felt252,
        experience_years: u32,
        specialization: felt252,
        certifications_hash: felt252,
        documents_hash: felt252,
        stake_amount: u256,
    );
    fn verify_validator_kyc(ref self: TContractState, validator: ContractAddress, approved: bool);
    fn verify_background_check(ref self: TContractState, validator: ContractAddress, approved: bool);
    fn verify_specialization(ref self: TContractState, validator: ContractAddress, approved: bool);
    fn approve_validator_enhanced(ref self: TContractState, validator: ContractAddress);
    fn get_enhanced_validator_application(self: @TContractState, applicant: ContractAddress) -> EnhancedValidatorApplication;
    fn get_validator_performance(self: @TContractState, validator: ContractAddress) -> ValidatorPerformanceMetrics;
    fn get_validator_stake(self: @TContractState, validator: ContractAddress) -> u256;
    fn get_specialization_info(self: @TContractState, specialization: felt252) -> ValidatorSpecialization;
    fn is_validator_qualified(self: @TContractState, validator: ContractAddress) -> bool;
}
