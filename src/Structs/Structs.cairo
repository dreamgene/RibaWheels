use starknet::ContractAddress;

// Enhanced validator application structure
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct EnhancedValidatorApplication {
    pub applicant: ContractAddress,
    pub description: felt252,
    pub experience_years: u32,
    pub specialization: felt252, // e.g., "luxury_cars", "vintage", "commercial", "electric"
    pub certifications: felt252, // IPFS hash of certifications
    pub documents_hash: felt252, // IPFS hash of ID, certificates, references
    pub stake_amount: u256,
    pub application_date: u64,
    pub status: ApplicationStatus,
    pub kyc_completed: bool,
    pub background_check_passed: bool,
    pub specialization_verified: bool,
}

// Original validator application (kept for backward compatibility)
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct ValidatorApplication {
    pub applicant: ContractAddress,
    pub description: felt252,
    pub experience: felt252,
    pub application_date: u64,
    pub status: ApplicationStatus,
}

#[derive(Copy, Drop, Serde, starknet::Store, PartialEq)]
pub enum ApplicationStatus {
    #[default]
    Pending,
    Approved,
    Rejected,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Validator {
    pub validator_address: ContractAddress,
    pub is_active: bool,
    pub joined_at: u64,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct ValidatorInfo {
    pub is_approved: bool,
    pub is_active: bool,
    pub application_date: u64,
    pub approval_date: u64,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct ValidatorRating {
    pub total_rating: u256,
    pub rating_count: u256,
    pub average_rating: u256, // Stored as rating * 100 (e.g., 450 = 4.5 stars)
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Escrow {
    pub buyer: ContractAddress,
    pub seller: ContractAddress,
    pub validator: ContractAddress,
    pub token_id: u256,
    pub amount: u256,
    pub validator_fee: u256,
    pub token_address: ContractAddress, // STRK or USDC
    pub status: EscrowStatus,
    pub creation_date: u64,
}

#[derive(Copy, Drop, Serde, starknet::Store, PartialEq)]
pub enum EscrowStatus {
    #[default]
    Active,
    ValidatorDecisionPending,
    Completed,
    Refunded,
    Disputed,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct CarDetails {
    pub vin: felt252,
    pub chassis_number: felt252,
    pub make: felt252,
    pub model: felt252,
    pub year: u32,
    pub mileage: u64,
    pub description: felt252,
    pub seller: ContractAddress,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct CarListing {
    pub seller: ContractAddress,
    pub token_id: u256,
    pub price_strk: u256,
    pub price_usdc: u256,
    pub description: felt252,
    pub is_active: bool,
    pub listing_date: u64,
}

// Validator specialization tracking
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct ValidatorSpecialization {
    pub specialization_type: felt252,
    pub validator_count: u32,
    pub is_active: bool,
}

// Validator performance metrics
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct ValidatorPerformanceMetrics {
    pub total_transactions: u32,
    pub successful_transactions: u32,
    pub disputed_transactions: u32,
    pub average_response_time: u64, // in seconds
    pub last_activity: u64,
    pub reliability_score: u32, // out of 1000 (100.0%)
}
