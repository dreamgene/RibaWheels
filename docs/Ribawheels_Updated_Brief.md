# Ribawheels - Updated Hackathon Project Brief

## 1. Project Overview

Ribawheels is a decentralized marketplace for car sales on Starknet. The platform ensures secure transactions through validator-based verification, escrow in STRK and USDC, and NFT-based car ownership certificates.

## 2. Key Features

### Car Listings
Sellers can list cars with detailed descriptions including:
- Make and model
- Year and mileage
- VIN (Vehicle Identification Number)
- Chassis number
- Other unique identifiers
- Pricing in both STRK and USDC

### Validator System
- Validators must apply and undergo vetting by the admin
- Applications are approved or rejected before validators become active
- Only approved validators can participate in transactions

### Validator Rating System
- Buyers can rate validators after transactions (1–5 stars)
- Ratings are stored on-chain and averaged
- Historical rating data is maintained for transparency

### Buyer Choice of Validator
- Buyers can select from approved validators
- Validator profiles show ratings and fees
- Transparent validator selection process

### Dynamic Validator Fees
Validator fees are based on their rating tier:
- **Rating ≥ 4.5** → 3% fee
- **Rating ≥ 3.0 and < 4.5** → 2% fee  
- **Rating < 3.0** → 1% fee

### Escrow System
- Supports both STRK and USDC for secure payments
- Funds held in smart contract until transaction completion
- Automatic fee distribution upon completion

### Car Ownership NFT
- Each listed car automatically mints an ERC-721 NFT
- NFT represents ownership certificate
- Transfers to buyer after successful purchase
- Immutable record of ownership history

### Admin Role
- Admin (contract owner) can approve/reject validators
- Remove fraudulent car listings
- Transfer admin rights to new address
- Platform governance and maintenance

### Wallet Swap Integration (Future Feature)
- Users can swap STRK ↔ USDC within the marketplace wallet
- Planned for post-hackathon implementation
- Will integrate with DEX protocols on Starknet

## 3. Transaction Flow

### Step-by-Step Process

1. **Car Listing**
   - Seller provides car details and pricing
   - Car NFT is automatically minted to seller's address
   - Listing becomes active on the marketplace

2. **Validator Selection**
   - Buyer browses available validators
   - Reviews validator ratings and fees
   - Selects preferred validator and payment token (STRK or USDC)

3. **Escrow Creation**
   - Buyer pays car price + validator fee into escrow contract
   - Funds are locked until transaction completion
   - Escrow record created with all transaction details

4. **Vehicle Inspection**
   - Validator inspects the physical vehicle
   - Verifies car details against listing
   - Submits decision (proceed/reject) to smart contract

5. **Purchase Finalization**
   - **If proceed = true:**
     - Seller receives car price
     - Validator receives their fee
     - Car NFT transfers to buyer
     - Listing becomes inactive
   - **If proceed = false:**
     - Buyer receives refund minus small validator dispute fee
     - Validator receives dispute fee for their time
     - Car remains listed for sale

6. **Validator Rating**
   - Buyer rates validator performance (1–5 stars)
   - Rating recorded on-chain
   - Validator's average rating updated

## 4. Roles and Responsibilities

### Admin/Owner
- **Validator Management**: Approve or reject validator applications
- **Content Moderation**: Remove fraudulent or inappropriate car listings
- **System Parameters**: Manage platform settings and fee structures
- **Ownership Transfer**: Can transfer admin rights to new address

### Seller
- **Car Listing**: Create detailed car listings with accurate information
- **Price Setting**: Set prices in both STRK and USDC
- **Payment Receipt**: Receive payments after successful transactions
- **Listing Management**: Can delist cars if needed

### Buyer
- **Validator Selection**: Choose from approved validators based on ratings/fees
- **Payment**: Pay via STRK or USDC through escrow system
- **Purchase Decision**: Final say on whether to complete purchase
- **Rating**: Rate validator performance after transactions

### Validator
- **Vehicle Inspection**: Physically inspect cars and verify details
- **Decision Making**: Provide honest assessment of vehicle condition
- **Fee Earning**: Receive fees based on rating tier
- **Reputation Building**: Build rating through quality service

## 5. Technical Implementation

### Smart Contracts Architecture

#### Built in Cairo 1.x for Starknet
- Modern Cairo syntax and features
- Optimized for Starknet's proving system
- Gas-efficient implementation

#### Marketplace Contract (`src/marketplace.cairo`)
Core contract handling:
- Car listing management
- Escrow operations
- Validator system
- Rating mechanism
- Admin functions
- Settlement logic

#### CarNFT Contract (`src/car_nft.cairo`)
ERC-721 compliant contract for:
- Car ownership certificates
- Metadata storage
- Transfer mechanisms
- Listing status tracking

#### Payment Token Support
- **STRK**: Native Starknet token
- **USDC**: Stable coin for price stability
- ERC-20 interface compatibility

### File Structure
```
ribawheels/
├── Scarb.toml                     # Project configuration
├── src/
│   ├── lib.cairo                  # Library entry point
│   ├── marketplace.cairo          # Main marketplace contract
│   └── car_nft.cairo             # NFT contract for car ownership
├── tests/
│   ├── lib.cairo                  # Test module entry
│   ├── test_marketplace.cairo     # Comprehensive test suite
│   └── mocks/
│       └── mock_erc20.cairo       # Mock tokens for testing
├── docs/
│   └── Ribawheels_Updated_Brief.md # This document
└── README.md                      # Project documentation
```

### Key Technical Features

#### Validator Rating Algorithm
```cairo
fn _calculate_validator_fee(validator: ContractAddress, price: u256) -> u256 {
    let rating = get_validator_rating(validator);
    let fee_percentage = if rating >= 450 { // 4.5 stars * 100
        3
    } else if rating >= 300 { // 3.0 stars * 100
        2
    } else {
        1
    };
    (price * fee_percentage) / 100
}
```

#### Escrow State Management
- `Active`: Funds deposited, awaiting validator decision
- `ValidatorDecisionPending`: Validator has decided, awaiting buyer
- `Completed`: Transaction successful, funds distributed
- `Refunded`: Transaction cancelled, funds returned
- `Disputed`: Special case for dispute resolution

#### Gas Optimization
- Efficient storage patterns
- Minimal on-chain computation
- Batch operations where possible

## 6. Hackathon Scope

### Core Implementation Focus

#### ✅ Implemented Features
- **Marketplace Logic**: Complete car listing and purchasing system
- **Validator System**: Application, approval, and rating mechanisms
- **Admin Controls**: Validator management and platform oversight
- **Dual-Token Escrow**: Support for both STRK and USDC
- **NFT Integration**: Car ownership certificates with metadata
- **Comprehensive Testing**: Full test coverage for main user flows

#### 🎯 Hackathon Deliverables
1. **Smart Contracts**: Production-ready Cairo contracts
2. **Test Suite**: Comprehensive testing framework
3. **Documentation**: Complete technical and user documentation
4. **Deployment Scripts**: Ready for testnet/mainnet deployment

#### 🔮 Post-Hackathon Roadmap
- **Frontend Interface**: Web application for user interaction
- **Mobile App**: iOS/Android applications
- **DEX Integration**: Built-in token swapping functionality
- **Advanced Analytics**: Market insights and statistics
- **Governance System**: Community-driven platform decisions

### Testing Coverage

#### Core Flow Tests
- Validator application and approval process
- Complete purchase transactions
- Refund mechanisms
- Rating system functionality

#### Edge Case Tests
- Unauthorized access attempts
- Invalid parameter handling
- State transition validation
- Error condition management

#### Integration Tests
- Multi-contract interaction
- Token transfer operations
- NFT minting and transfers
- Event emission verification

## 7. Security Considerations

### Smart Contract Security
- **Access Controls**: Role-based permissions throughout
- **Input Validation**: Comprehensive parameter checking
- **State Management**: Careful state transition handling
- **Reentrancy Protection**: Secure external call patterns

### Economic Security
- **Escrow Protection**: Funds locked until completion
- **Validator Incentives**: Rating-based fee structure
- **Dispute Resolution**: Fair handling of transaction disputes

### Platform Security
- **Admin Controls**: Emergency functions for platform safety
- **Content Moderation**: Removal of fraudulent listings
- **Validator Vetting**: Careful approval process

## 8. Innovation Highlights

### Unique Features
- **Dynamic Fee Structure**: First marketplace with rating-based validator fees
- **Dual-Token Escrow**: Flexible payment options for users
- **On-Chain Reputation**: Transparent validator rating system
- **Car NFT Certificates**: Immutable ownership records

### Technical Innovation
- **Cairo 1.x Implementation**: Modern Starknet development
- **Gas Optimization**: Efficient storage and computation patterns
- **Modular Architecture**: Upgradeable and maintainable design

### User Experience
- **Transparent Process**: All actions visible on-chain
- **Flexible Payments**: STRK or USDC options
- **Quality Assurance**: Validator system ensures transaction safety
- **Fair Pricing**: Market-driven validator fees

---

*This brief represents the complete implementation scope for the Ribawheels hackathon project, demonstrating a production-ready decentralized car marketplace on Starknet.*







