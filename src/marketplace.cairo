use starknet::ContractAddress;
use starknet::get_caller_address;

// Data structures
#[derive(Copy, Drop, Serde)]
struct Product {
    id: u128,
    name: felt252,
    description: felt252,
    price: u128,
    location: felt252,
    seller: ContractAddress,
    status: u8 // 0 = Listed, 1 = Sold
}

#[derive(Copy, Drop, Serde)]
struct Validator {
    id: u128,
    addr: ContractAddress,
    name: felt252,
    location: felt252,
    is_active: bool,
    status: u8, // 0 = Pending, 1 = Approved, 2 = Rejected
    rating: u128, // Stored as avg * 100
    total_ratings: u128
}

#[derive(Copy, Drop, Serde)]
struct Order {
    id: u128,
    product_id: u128,
    buyer: ContractAddress,
    validator_id: u128,
    status: u8, // 0 = Pending, 1 = Approved, 2 = Cancelled
    escrow_amount: u128
}

#[starknet::contract]
mod Marketplace {
    use super::*;

    #[storage]
    struct Storage {
        product_count: u128,
        validator_count: u128,
        order_count: u128,
        products: LegacyMap<u128, Product>,
        validators: LegacyMap<u128, Validator>,
        orders: LegacyMap<u128, Order>,
        escrow_balances: LegacyMap<ContractAddress, u128>
    }

    // ----------------------
    // Constructor
    // ----------------------
    #[constructor]
    fn constructor(ref self: ContractState) {
        self.product_count.write(0);
        self.validator_count.write(0);
        self.order_count.write(0);
    }

    // ----------------------
    // Admin functions
    // ----------------------
    #[external]
    fn approve_validator(ref self: ContractState, validator_id: u128) {
        let mut val = self.validators.read(validator_id).unwrap();
        val.status = 1;
        val.is_active = true;
        self.validators.write(validator_id, val);
    }

    #[external]
    fn reject_validator(ref self: ContractState, validator_id: u128) {
        let mut val = self.validators.read(validator_id).unwrap();
        val.status = 2;
        val.is_active = false;
        self.validators.write(validator_id, val);
    }

    // ----------------------
    // User registration
    // ----------------------
    #[external]
    fn register_validator(ref self: ContractState, name: felt252, location: felt252) {
        let count = self.validator_count.read();
        let id = count + 1;
        let caller = get_caller_address();

        let val = Validator {
            id,
            addr: caller,
            name,
            location,
            is_active: false,
            status: 0,
            rating: 0,
            total_ratings: 0
        };

        self.validators.write(id, val);
        self.validator_count.write(id);
    }

    // ----------------------
    // Product functions
    // ----------------------
    #[external]
    fn list_product(
        ref self: ContractState,
        name: felt252,
        description: felt252,
        price: u128,
        location: felt252
    ) {
        let count = self.product_count.read();
        let id = count + 1;
        let caller = get_caller_address();

        let prod = Product {
            id,
            name,
            description,
            price,
            location,
            seller: caller,
            status: 0
        };

        self.products.write(id, prod);
        self.product_count.write(id);
    }

    // ----------------------
    // Buy product (Buyer chooses validator)
    // ----------------------
    #[external]
    fn buy_product(ref self: ContractState, product_id: u128, validator_id: u128) {
        let caller = get_caller_address();
        let mut prod = self.products.read(product_id).unwrap();
        assert(prod.status == 0, "Product not available");

        let val = self.validators.read(validator_id).unwrap();
        assert(val.status == 1, "Validator not approved");
        assert(val.is_active, "Validator not active");

        let fee_percent = get_fee_percent(val.rating);
        let fee_amount = prod.price * fee_percent / 100;
        let total_amount = prod.price + fee_amount;

        let buyer_balance = self.escrow_balances.read(caller).unwrap_or(0);
        self.escrow_balances.write(caller, buyer_balance - total_amount);

        let order_num = self.order_count.read();
        let new_order_id = order_num + 1;
        let ord = Order {
            id: new_order_id,
            product_id,
            buyer: caller,
            validator_id,
            status: 0,
            escrow_amount: total_amount
        };

        self.orders.write(new_order_id, ord);
        self.order_count.write(new_order_id);

        prod.status = 1;
        self.products.write(product_id, prod);
    }

    // ----------------------
    // Validator decision
    // ----------------------
    #[external]
    fn submit_validation(ref self: ContractState, order_id: u128, decision: u8) {
        let mut ord = self.orders.read(order_id).unwrap();
        let val = self.validators.read(ord.validator_id).unwrap();
        assert(get_caller_address() == val.addr, "Only assigned validator");

        ord.status = decision;
        self.orders.write(order_id, ord);
    }

    // ----------------------
    // Buyer final decision
    // ----------------------
    #[external]
    fn finalize_purchase(ref self: ContractState, order_id: u128, proceed: bool) {
        let ord = self.orders.read(order_id).unwrap();
        let prod = self.products.read(ord.product_id).unwrap();
        let val = self.validators.read(ord.validator_id).unwrap();

        if proceed {
            let validator_fee = prod.price * get_fee_percent(val.rating) / 100;
            self.escrow_balances.write(prod.seller, prod.price);
            self.escrow_balances.write(val.addr, validator_fee);
        } else {
            self.escrow_balances.write(ord.buyer, ord.escrow_amount - 3);
            self.escrow_balances.write(val.addr, 3);
        }
    }

    // ----------------------
    // Rating function
    // ----------------------
    #[external]
    fn rate_validator(ref self: ContractState, order_id: u128, stars: u128) {
        let mut val = self.validators.read(self.orders.read(order_id).unwrap().validator_id).unwrap();
        let new_total_ratings = val.total_ratings + 1;
        let new_avg = ((val.rating * val.total_ratings) + (stars * 100)) / new_total_ratings;

        val.rating = new_avg;
        val.total_ratings = new_total_ratings;
        self.validators.write(val.id, val);
    }
}

// ----------------------
// Helper functions
// ----------------------
fn get_fee_percent(rating: u128) -> u128 {
    if rating >= 450 {
        return 3;
    }
    if rating >= 300 {
        return 2;
    }
    1
}


