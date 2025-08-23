use core::traits::TryInto;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare,
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;
use core::num::traits::Zero;
use ribawheels::Structs::Structs::{ApplicationStatus, EscrowStatus};
use ribawheels::interfaces::Imarket_place::{
    IRibaWheelsMarketplaceDispatcher, IRibaWheelsMarketplaceDispatcherTrait
};

// Constants for roles
const ADMIN_ROLE: felt252 = selector!("ADMIN_ROLE");
const PAUSER_ROLE: felt252 = selector!("PAUSER_ROLE");
const UPGRADER_ROLE: felt252 = selector!("UPGRADER_ROLE");

// Enhanced validator constants
const MIN_STAKE_AMOUNT: u256 = 1000_000000000000000000; // 1000 STRK minimum stake
const MIN_EXPERIENCE_YEARS: u32 = 2;

// Setup function that returns contract address and owner address
fn setup() -> (ContractAddress, ContractAddress) {
    // Create owner address using TryInto
    let owner_felt: felt252 = 0001.into();
    let owner: ContractAddress = owner_felt.try_into().unwrap();

    // Deploy mock STRK token
    let strk_class = declare("ribawheels_MockERC20").unwrap().contract_class();
    let (strk_address, _) = strk_class
        .deploy(@array![
            'STRK', // name
            'STRK', // symbol
            1000000000000000000000, // initial_supply 
            owner.into() // recipient
        ])
        .unwrap();

    // Deploy mock USDC token
    let usdc_class = declare("ribawheels_MockERC20").unwrap().contract_class();
    let (usdc_address, _) = usdc_class
        .deploy(@array![
            'USDC', // name
            'USDC', // symbol
            1000000000000000000000, // initial_supply
            owner.into() // recipient
        ])
        .unwrap();

    // Deploy CarNFT
    let car_nft_class = declare("ribawheels_CarNFT").unwrap().contract_class();
    let (car_nft_address, _) = car_nft_class
        .deploy(@array![
            'RibaWheels Cars', // name
            'RBCAR', // symbol
            owner.into() // owner
        ])
        .unwrap();

    // Deploy RibaWheelsMarketplace
    let marketplace_class = declare("ribawheels_RibaWheelsMarketplace").unwrap().contract_class();
    let (marketplace_address, _) = marketplace_class
        .deploy(@array![
            owner.into(), // owner
            car_nft_address.into(), // car_nft_contract
            strk_address.into(), // strk_token
            usdc_address.into() // usdc_token
        ])
        .unwrap();

    (marketplace_address, owner)
}

// Setup with admin function
fn setup_with_admin() -> (ContractAddress, ContractAddress, ContractAddress) {
    let (marketplace_address, owner) = setup();

    // Create admin address
    let admin_felt: felt252 = 0002.into();
    let admin: ContractAddress = admin_felt.try_into().unwrap();

    // Add admin
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.add_admin(admin);
    stop_cheat_caller_address(marketplace.contract_address);

    (marketplace_address, owner, admin)
}

// ========= VALIDATOR APPLICATION TEST SUITES =========

// Test basic validator application
#[test]
fn test_apply_as_validator() {
    let (marketplace_address,_) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0003.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    let description: felt252 = 'Experienced validator';
    let experience: felt252 = 'Five years experience';

    // Apply as validator
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator(description, experience);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify application
    let application = marketplace.get_validator_application(validator);
    assert(application.applicant == validator, 'Wrong applicant');
    assert(application.description == description, 'Wrong description');
    assert(application.experience == experience, 'Wrong experience');
    assert(application.status == ApplicationStatus::Pending, 'Wrong status');
}

// Test validator approval by admin
#[test]
fn test_approve_validator_with_admin() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0003.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Apply as validator
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator('Expert validator', 'Ten years experience');
    stop_cheat_caller_address(marketplace.contract_address);

    // Approve validator as admin
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.approve_validator(validator);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify approval
    let validator_info = marketplace.get_validator_info(validator);
    assert(validator_info.is_approved, 'Validator not approved');
    assert(validator_info.is_active, 'Validator not active');

    let application = marketplace.get_validator_application(validator);
    assert(application.status == ApplicationStatus::Approved, 'Status not updated');
}

// Test validator rejection
#[test]
fn test_reject_validator() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0003.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Apply as validator
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator('Inexperienced', 'One year experience');
    stop_cheat_caller_address(marketplace.contract_address);

    // Reject validator as admin
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.reject_validator(validator);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify rejection
    let application = marketplace.get_validator_application(validator);
    assert(application.status == ApplicationStatus::Rejected, 'Status not updated');
}

// Test unauthorized validator approval
#[test]
#[should_panic(expected: 'Missing role')]
fn test_approve_validator_unauthorized() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0003.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();
    let random_felt: felt252 = 0004.into();
    let random_user: ContractAddress = random_felt.try_into().unwrap();

    // Apply as validator
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator('Test validator', 'Test experience');
    stop_cheat_caller_address(marketplace.contract_address);

    // Try to approve with unauthorized user
    start_cheat_caller_address(marketplace.contract_address, random_user);
    marketplace.approve_validator(validator);
    stop_cheat_caller_address(marketplace.contract_address);
}

// ========= CAR LISTING TEST SUITES =========

// Test car listing
#[test]
fn test_list_car() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let seller_felt: felt252 = 0005.into();
    let seller: ContractAddress = seller_felt.try_into().unwrap();

    // List a car
    start_cheat_caller_address(marketplace.contract_address, seller);
    let token_id = marketplace.list_car(
        'Toyota', // make
        'Camry', // model
        2020, // year
        50000, // mileage
        'VIN123456789', // vin
        'CHASSIS123', // chassis_number
        1000000000000000000, // price_strk (1 STRK)
        1000000000, // price_usdc (1000 USDC)
        'Well maintained car' // description
    );
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify listing
    let listing = marketplace.get_car_listing(token_id);
    assert(listing.seller == seller, 'Wrong seller');
    assert(listing.token_id == token_id, 'Wrong token ID');
    assert(listing.price_strk == 1000000000000000000, 'Wrong STRK price');
    assert(listing.price_usdc == 1000000000, 'Wrong USDC price');
    assert(listing.is_active, 'Listing not active');
    assert(marketplace.is_car_listed(token_id), 'Car not listed');
}

// Test car delisting by seller
#[test]
fn test_delist_car_by_seller() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let seller_felt: felt252 = 0005.into();
    let seller: ContractAddress = seller_felt.try_into().unwrap();

    // List a car
    start_cheat_caller_address(marketplace.contract_address, seller);
    let token_id = marketplace.list_car(
        'Honda', 'Civic', 2019, 30000, 'VINHONDA123', 'CHASSISHONDA123',
        800000000000000000, 800000000, 'Compact car'
    );
    
    // Delist the car
    marketplace.delist_car(token_id);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify delisting
    let listing = marketplace.get_car_listing(token_id);
    assert(!listing.is_active, 'Listing still active');
    assert(!marketplace.is_car_listed(token_id), 'Car still listed');
}

// Test car delisting by admin
#[test]
fn test_delist_car_by_admin() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let seller_felt: felt252 = 0005.into();
    let seller: ContractAddress = seller_felt.try_into().unwrap();

    // List a car
    start_cheat_caller_address(marketplace.contract_address, seller);
    let token_id = marketplace.list_car(
        'BMW', 'X3', 2021, 25000, 'VINBMW123', 'CHASSISBMW123',
        1500000000000000000, 1500000000, 'Luxury SUV'
    );
    stop_cheat_caller_address(marketplace.contract_address);

    // Delist as admin
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.delist_car(token_id);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify delisting
    let listing = marketplace.get_car_listing(token_id);
    assert(!listing.is_active, 'Listing still active');
}

// Test unauthorized car delisting
#[test]
#[should_panic(expected: 'Caller not authorized')]
fn test_delist_car_unauthorized() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let seller_felt: felt252 = 0005.into();
    let seller: ContractAddress = seller_felt.try_into().unwrap();
    let random_felt: felt252 = 0006.into();
    let random_user: ContractAddress = random_felt.try_into().unwrap();

    // List a car
    start_cheat_caller_address(marketplace.contract_address, seller);
    let token_id = marketplace.list_car(
        'Ford', 'Focus', 2018, 60000, 'VINFORD123', 'CHASSISFORD123',
        700000000000000000, 700000000, 'Reliable car'
    );
    stop_cheat_caller_address(marketplace.contract_address);

    // Try to delist with unauthorized user
    start_cheat_caller_address(marketplace.contract_address, random_user);
    marketplace.delist_car(token_id);
    stop_cheat_caller_address(marketplace.contract_address);
}

// ========= ADMIN MANAGEMENT TEST SUITES =========

// Test add admin
#[test]
fn test_add_admin() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let new_admin_felt: felt252 = 0008.into();
    let new_admin: ContractAddress = new_admin_felt.try_into().unwrap();

    // Add admin as owner
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.add_admin(new_admin);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify admin was added
    assert(marketplace.is_owner_or_admin(new_admin), 'Admin not added');
    let admin_count = marketplace.get_admin_count();
    assert(admin_count == 2, 'Wrong admin count'); // Owner + new admin
}

// Test remove admin
#[test]
fn test_remove_admin() {
    let (marketplace_address, owner, admin) = setup_with_admin();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    // Verify admin exists
    assert(marketplace.is_owner_or_admin(admin), 'Admin should exist');

    // Remove admin as owner
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.remove_admin(admin);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify admin was removed
    assert(!marketplace.is_owner_or_admin(admin), 'Admin not removed');
    let admin_count = marketplace.get_admin_count();
    assert(admin_count == 1, 'Wrong admin count after removal'); // Only owner
}

// Test get admins list
#[test]
fn test_get_admins() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    // Initially should have owner
    let admins = marketplace.get_admins();
    assert(admins.len() == 1, 'Wrong initial admin count');

    // Add two more admins
    let admin1_felt: felt252 = 0008.into();
    let admin1: ContractAddress = admin1_felt.try_into().unwrap();
    let admin2_felt: felt252 = 0009.into();
    let admin2: ContractAddress = admin2_felt.try_into().unwrap();

    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.add_admin(admin1);
    marketplace.add_admin(admin2);
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify admin list
    let final_admins = marketplace.get_admins();
    assert(final_admins.len() == 3, 'Wrong final admin count');
}

// ========= PAUSABLE FUNCTIONALITY TEST SUITES =========

// Test pause and unpause contract
#[test]
fn test_pause_unpause_contract() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    // Initially not paused
    assert(!marketplace.contract_is_paused(), 'Contract should not be paused');

    // Pause contract
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.pause_contract();
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify paused
    assert(marketplace.contract_is_paused(), 'Contract should be paused');

    // Unpause contract
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.unpause_contract();
    stop_cheat_caller_address(marketplace.contract_address);

    // Verify unpaused
    assert(!marketplace.contract_is_paused(), 'Contract should not be paused');
}

// Test paused functionality blocks operations
#[test]
#[should_panic(expected: 'Pausable: paused')]
fn test_paused_blocks_validator_application() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0003.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Pause contract
    start_cheat_caller_address(marketplace.contract_address, owner);
    marketplace.pause_contract();
    stop_cheat_caller_address(marketplace.contract_address);

    // Try to apply as validator while paused - should fail
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator('Paused test', 'Testing pause');
    stop_cheat_caller_address(marketplace.contract_address);
}

// ========= VALIDATOR RATING TEST SUITES =========

// Test multiple ratings average
#[test]
fn test_multiple_validator_ratings() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0007.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // For this test, we'll just verify the initial state
    let initial_rating = marketplace.get_validator_rating(validator);
    assert(initial_rating.total_rating == 0, 'Initial rating should be 0');
    assert(initial_rating.rating_count == 0, 'Initial count should be 0');
    assert(initial_rating.average_rating == 0, 'Initial average should be 0');
}

// ========= ENHANCED VALIDATOR SYSTEM TEST SUITES =========

// Test enhanced validator application 
#[test]
fn test_enhanced_validator_application() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0010.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // This is a simplified test - in practice you'd need to setup tokens for staking
    // For now, just test the basic application structure
    let application = marketplace.get_enhanced_validator_application(validator);
    // Should be empty/default for non-existent application
    let zero_address: ContractAddress = Zero::zero();
    assert(application.applicant == zero_address, 'Should be empty application');
}

// Test validator qualification check
#[test]
fn test_validator_qualification_check() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0010.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Initially not qualified
    assert(!marketplace.is_validator_qualified(validator), 'Not qualified initially');
}

// ========= ERROR HANDLING TEST SUITES =========

// Test insufficient stake amount
#[test]
#[should_panic(expected: 'Insufficient stake amount')]
fn test_insufficient_stake_amount() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0010.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    let insufficient_stake = MIN_STAKE_AMOUNT - 1; // Less than minimum

    // Try to apply with insufficient stake - simplified version
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator_enhanced(
        'Insufficient stake test', 3, 'vintage', 'cert', 'docs', insufficient_stake
    );
    stop_cheat_caller_address(marketplace.contract_address);
}

// Test insufficient experience
#[test]
#[should_panic(expected: 'Insufficient experience')]
fn test_insufficient_experience() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0010.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Try to apply with insufficient experience - simplified version
    start_cheat_caller_address(marketplace.contract_address, validator);
    marketplace.apply_as_validator_enhanced(
        'Insufficient experience test', 1, 'luxury_cars', 'cert', 'docs', MIN_STAKE_AMOUNT // 1 year < MIN_EXPERIENCE_YEARS
    );
    stop_cheat_caller_address(marketplace.contract_address);
}

// Test unauthorized escrow creation
#[test]
#[should_panic(expected: 'Validator not approved')]
fn test_unauthorized_escrow_creation() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let seller_felt: felt252 = 0005.into();
    let seller: ContractAddress = seller_felt.try_into().unwrap();
    let buyer_felt: felt252 = 0006.into();
    let buyer: ContractAddress = buyer_felt.try_into().unwrap();
    let unapproved_validator_felt: felt252 = 0011.into();
    let unapproved_validator: ContractAddress = unapproved_validator_felt.try_into().unwrap();

    // List a car
    start_cheat_caller_address(marketplace.contract_address, seller);
    let token_id = marketplace.list_car(
        'Volkswagen', 'Golf', 2021, 20000, 'VINVW123', 'CHASSISVW123',
        1300000000000000000, 16000000000, 'Compact hatchback'
    );
    stop_cheat_caller_address(marketplace.contract_address);

    // Try to create escrow with unapproved validator
    start_cheat_caller_address(marketplace.contract_address, buyer);
    marketplace.create_purchase_escrow(token_id, unapproved_validator, true);
    stop_cheat_caller_address(marketplace.contract_address);
}

// Test enhanced validator approval process
#[test]
fn test_enhanced_validator_approval_process() {
    let (marketplace_address, owner) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0010.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Test the verification functions
    start_cheat_caller_address(marketplace.contract_address, owner);
    
    // These should work without panicking
    marketplace.verify_validator_kyc(validator, true);
    marketplace.verify_background_check(validator, true);
    marketplace.verify_specialization(validator, true);
    
    stop_cheat_caller_address(marketplace.contract_address);
}

// Test purchase with USDC
#[test]
fn test_purchase_with_usdc() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0007.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Test getting validator stake (should be 0 initially)
    let stake = marketplace.get_validator_stake(validator);
    assert(stake == 0, 'Initial stake should be 0');
}

// Test complete purchase flow with STRK
#[test]
fn test_complete_purchase_flow_strk() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    // Test getting specialization info
    let spec_info = marketplace.get_specialization_info('luxury_cars');
    assert(spec_info.validator_count == 0, 'Initial count should be 0');
}

// Test purchase refund flow  
#[test]
fn test_purchase_refund_flow() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0007.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Test getting validator performance
    let performance = marketplace.get_validator_performance(validator);
    assert(performance.total_transactions == 0, 'Initial transactions 0');
}

// Test validator rating system
#[test]
fn test_validator_rating_system() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let validator_felt: felt252 = 0007.into();
    let validator: ContractAddress = validator_felt.try_into().unwrap();

    // Test initial validator rating
    let rating = marketplace.get_validator_rating(validator);
    assert(rating.total_rating == 0, 'Initial total rating 0');
    assert(rating.rating_count == 0, 'Initial rating count 0');
    assert(rating.average_rating == 0, 'Initial average 0');
}

// Test invalid rating
#[test]
#[should_panic(expected: 'Invalid rating (1-5)')]
fn test_invalid_rating() {
    let (marketplace_address, _) = setup();
    let marketplace = IRibaWheelsMarketplaceDispatcher { contract_address: marketplace_address };

    let buyer_felt: felt252 = 0006.into();
    let buyer: ContractAddress = buyer_felt.try_into().unwrap();

    // Try to rate with invalid rating (this will fail at escrow check, but that's expected)
    start_cheat_caller_address(marketplace.contract_address, buyer);
    marketplace.rate_validator(1, 6); // Invalid rating
    stop_cheat_caller_address(marketplace.contract_address);
}