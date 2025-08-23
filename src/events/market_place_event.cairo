use starknet::ContractAddress;

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorApplicationSubmitted {
    #[key]
    pub applicant: ContractAddress,
    pub description: felt252,
    pub experience: felt252,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorApproved {
    #[key]
    pub validator: ContractAddress,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorRejected {
    #[key]
    pub applicant: ContractAddress,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct CarListed {
    #[key]
    pub token_id: u256,
    #[key]
    pub seller: ContractAddress,
    pub price_strk: u256,
    pub price_usdc: u256,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct CarDelisted {
    #[key]
    pub token_id: u256,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct EscrowCreated {
    #[key]
    pub escrow_id: u256,
    #[key]
    pub buyer: ContractAddress,
    #[key]
    pub seller: ContractAddress,
    pub validator: ContractAddress,
    pub token_id: u256,
    pub amount: u256,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorDecision {
    #[key]
    pub escrow_id: u256,
    #[key]
    pub validator: ContractAddress,
    pub proceed: bool,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct PurchaseCompleted {
    #[key]
    pub escrow_id: u256,
    #[key]
    pub buyer: ContractAddress,
    #[key]
    pub seller: ContractAddress,
    pub token_id: u256,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct EscrowRefunded {
    #[key]
    pub escrow_id: u256,
    #[key]
    pub buyer: ContractAddress,
    pub amount: u256,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorRated {
    #[key]
    pub validator: ContractAddress,
    #[key]
    pub buyer: ContractAddress,
    pub rating: u8,
    pub new_average: u256,
}

// Enhanced validator system events
#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct EnhancedValidatorApplicationSubmitted {
    #[key]
    pub applicant: ContractAddress,
    pub specialization: felt252,
    pub stake_amount: u256,
    pub documents_hash: felt252,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorKYCCompleted {
    #[key]
    pub validator: ContractAddress,
    pub kyc_provider: ContractAddress,
    pub status: bool,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorStakeSlashed {
    #[key]
    pub validator: ContractAddress,
    pub slash_amount: u256,
    pub remaining_stake: u256,
    pub reason: felt252,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorSpecializationVerified {
    #[key]
    pub validator: ContractAddress,
    pub specialization: felt252,
    pub verifier: ContractAddress,
}

#[derive(Clone, Drop, Debug, starknet::Event)]
pub struct ValidatorStakeWithdrawn {
    #[key]
    pub validator: ContractAddress,
    pub amount: u256,
    pub withdrawal_date: u64,
}

