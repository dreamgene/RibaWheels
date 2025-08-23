<<<<<<< HEAD
# RibaWheels - Decentralized Car Marketplace

RibaWheels is a decentralized marketplace for car sales built on Starknet. The platform ensures secure transactions through validator-based verification, escrow in STRK and USDC, and NFT-based car ownership certificates.

## 🚗 Features

### Core Functionality
- **Car Listings**: Sellers can list cars with detailed descriptions including make, model, year, mileage, VIN, chassis number, and other unique identifiers
- **Validator System**: Validators must apply and undergo vetting by the admin before becoming active
- **Validator Rating**: Buyers can rate validators after transactions (1–5 stars) with ratings stored on-chain
- **Dynamic Validator Fees**: Fees depend on validator rating tiers:
  - Rating ≥ 4.5 → 3%
  - Rating ≥ 3.0 and < 4.5 → 2%
  - Rating < 3.0 → 1%
- **Dual-Token Escrow**: Supports both STRK and USDC for secure payments
- **Car Ownership NFTs**: Each listed car automatically mints an ERC-721 NFT representing ownership
- **Admin Controls**: Admin can approve/reject validators and remove fraudulent listings

## 🏗️ Architecture

### Smart Contracts

#### CarNFT Contract (`src/car_nft.cairo`)
- ERC-721 compliant NFT contract for car ownership certificates
- Stores car metadata (make, model, year, mileage, VIN, chassis number)
- Handles minting and ownership transfers
- Only marketplace contract can mint and transfer tokens

#### Marketplace Contract (`src/marketplace.cairo`)
- Core marketplace logic for car listings and transactions
- Validator application and approval system
- Escrow management for secure payments
- Rating system for validators
- Admin controls for platform management

### Key Data Structures

```cairo
struct CarData {
    make: felt252,
    model: felt252,
    year: u32,
    mileage: u64,
    vin: felt252,
    chassis_number: felt252,
    seller: ContractAddress,
    is_listed: bool,
}

struct CarListing {
    seller: ContractAddress,
    token_id: u256,
    price_strk: u256,
    price_usdc: u256,
    description: felt252,
    is_active: bool,
    listing_date: u64,
}

struct EscrowData {
    buyer: ContractAddress,
    seller: ContractAddress,
    validator: ContractAddress,
    token_id: u256,
    amount: u256,
    validator_fee: u256,
    token_address: ContractAddress,
    status: EscrowStatus,
    creation_date: u64,
}
```

## 🔄 Transaction Flow

1. **Car Listing**: Seller lists a car → Car NFT is minted to seller's address
2. **Validator Selection**: Buyer selects a validator and chooses payment token (STRK or USDC)
3. **Escrow Creation**: Buyer pays price + validator fee into escrow
4. **Validation**: Validator inspects the car and submits a decision
5. **Purchase Finalization**:
   - If proceed = true: Seller gets price, validator gets fee, NFT transfers to buyer
   - If proceed = false: Buyer gets refunded minus small validator fee, validator gets dispute fee
6. **Rating**: Buyer rates validator (1–5 stars)

## 👥 Roles

- **Admin/Owner**: Approves validators, removes fraudulent cars, manages system parameters
- **Seller**: Lists cars and receives payments
- **Buyer**: Selects validators, pays via STRK/USDC, finalizes purchases
- **Validator**: Inspects cars, validates transactions, earns fees based on rating

## 🚀 Getting Started

### Prerequisites
- [Scarb](https://docs.swmansion.com/scarb/) (Cairo package manager)
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/) (for testing)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd ribawheels

# Build the project
scarb build

# Run tests
scarb test
```

### Deployment

1. Deploy the CarNFT contract first
2. Deploy mock STRK and USDC tokens (or use mainnet addresses)
3. Deploy the Marketplace contract with:
   - Admin address
   - CarNFT contract address
   - STRK token address
   - USDC token address

## 🧪 Testing

The project includes comprehensive tests covering:

- Validator application and approval flow
- Car listing and delisting
- Complete purchase transactions
- Validator rating system
- Refund mechanisms
- Error cases and edge conditions

Run tests with:
```bash
scarb test
```

## 📋 Contract Interfaces

### Marketplace Interface

```cairo
trait IRibaWheelsMarketplace<TContractState> {
    // Validator Management
    fn apply_as_validator(ref self: TContractState, description: felt252, experience: felt252);
    fn approve_validator(ref self: TContractState, validator: ContractAddress);
    fn reject_validator(ref self: TContractState, applicant: ContractAddress);
    
    // Car Listing Management
    fn list_car(ref self: TContractState, /* car details */) -> u256;
    fn delist_car(ref self: TContractState, token_id: u256);
    
    // Purchase Flow
    fn create_purchase_escrow(ref self: TContractState, token_id: u256, validator: ContractAddress, use_strk: bool) -> u256;
    fn validator_decision(ref self: TContractState, escrow_id: u256, proceed: bool);
    fn finalize_purchase(ref self: TContractState, escrow_id: u256, proceed: bool);
    
    // Rating System
    fn rate_validator(ref self: TContractState, escrow_id: u256, rating: u8);
    
    // Getters
    fn get_validator_info(self: @TContractState, validator: ContractAddress) -> ValidatorInfo;
    fn get_car_listing(self: @TContractState, token_id: u256) -> CarListing;
    fn get_escrow_data(self: @TContractState, escrow_id: u256) -> EscrowData;
    // ... other getters
}
```

### CarNFT Interface

```cairo
trait ICarNFT<TContractState> {
    fn mint_car(ref self: TContractState, to: ContractAddress, /* car details */) -> u256;
    fn get_car_data(self: @TContractState, token_id: u256) -> CarData;
    fn update_listing_status(ref self: TContractState, token_id: u256, is_listed: bool);
    fn transfer_car(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
}
```

## 🛡️ Security Features

- **Escrow Protection**: Funds are held in contract until transaction completion
- **Validator Verification**: Multi-step approval process for validators
- **Admin Controls**: Platform owner can remove malicious content
- **Rating System**: Incentivizes honest validator behavior
- **Dual-Token Support**: Flexibility in payment methods

## 🔮 Future Enhancements

- Wallet swap integration (STRK ↔ USDC)
- Advanced search and filtering
- Dispute resolution mechanism
- Integration with external car verification APIs
- Mobile app interface
- Governance token for platform decisions

## 📄 License

This project is part of a hackathon submission and is provided as-is for educational and demonstration purposes.

## 🤝 Contributing

This is a hackathon project. For issues or suggestions, please open an issue in the repository.

---

**Built with ❤️ on Starknet**







=======
# Ribawheels

## Overview
This is a hackathon project for building a peer-to-peer marketplace on Starknet with:
- Validator vetting
- Buyer choice of validator
- Dynamic validator fees based on rating
- STARK-only escrow

## Structure
- `contracts/` - Cairo smart contracts
- `frontend/` - Web frontend (React/Next.js)
- `docs/` - Documentation

## Setup
1. Install Scarb & Cairo
2. Clone repo: `git clone <repo_url>`
3. Navigate to `contracts/` and build: `scarb build`
4. Test contracts: `scarb test`

## Team Workflow
- Create a branch for your feature
- Commit changes
- Push and open a Pull Request

## License
MIT
>>>>>>> origin/main
