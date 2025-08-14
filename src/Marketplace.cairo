%lang starknet

// ----------------------
// STRUCTS & ENUMS
// ----------------------
@storage_var
func product_count() -> (count: felt) {}

@storage_var
func validator_count() -> (count: felt) {}

@storage_var
func order_count() -> (count: felt) {}

struct Product {
    id: felt,
    name: felt,
    description: felt,
    price: felt,
    location: felt,
    seller: felt,
    status: felt
}

struct Validator {
    id: felt,
    addr: felt,
    name: felt,
    location: felt,
    is_active: felt,
    status: felt,
    rating: felt,
    total_ratings: felt
}

struct Order {
    id: felt,
    product_id: felt,
    buyer: felt,
    validator_id: felt,
    status: felt,
    escrow_amount: felt
}

// ----------------------
// STORAGE MAPPINGS
// ----------------------
@storage_var
func products(product_id: felt) -> (product: Product) {}

@storage_var
func validators(validator_id: felt) -> (validator: Validator) {}

@storage_var
func orders(order_id: felt) -> (order: Order) {}

@storage_var
func escrow_balances(user: felt) -> (amount: felt) {}

// ----------------------
// ADMIN FUNCTIONS
// ----------------------
@external
func approve_validator{syscall_ptr: felt*, storage_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    validator_id: felt
) {
    alloc_locals;
    let (mut val) = validators(validator_id);
    val.status = 1;
    val.is_active = 1;
    validators.write(validator_id, val);
    return ();
}

@external
func reject_validator{syscall_ptr: felt*, storage_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    validator_id: felt
) {
    alloc_locals;
    let (mut val) = validators(validator_id);
    val.status = 2;
    val.is_active = 0;
    validators.write(validator_id, val);
    return ();
}

// ----------------------
// USER REGISTRATION
// ----------------------
@external
func register_validator(
    name: felt, location: felt
) {
    alloc_locals;
    let (count) = validator_count.read();
    let id = count + 1;
    let caller = get_caller_address();

    let val: Validator = Validator(id, caller, name, location, 0, 0, 0, 0);
    validators.write(id, val);
    validator_count.write(id);
    return ();
}

// ----------------------
// PRODUCT FUNCTIONS
// ----------------------
@external
func list_product(
    name: felt, description: felt, price: felt, location: felt
) {
    alloc_locals;
    let (count) = product_count.read();
    let id = count + 1;
    let caller = get_caller_address();

    let prod: Product = Product(id, name, description, price, location, caller, 0);
    products.write(id, prod);
    product_count.write(id);
    return ();
}

// ----------------------
// BUY PRODUCT (Buyer chooses validator)
// ----------------------
@external
func buy_product(
    product_id: felt, validator_id: felt
) {
    alloc_locals;

    let caller = get_caller_address();
    let (mut prod) = products(product_id);
    assert prod.status = 0;

    let (val) = validators(validator_id);
    assert val.status = 1;
    assert val.is_active = 1;

    let fee_percent = get_fee_percent(val.rating);
    let fee_amount = prod.price * fee_percent / 100;
    let total_amount = prod.price + fee_amount;

    let (buyer_balance) = escrow_balances(caller);
    escrow_balances.write(caller, buyer_balance - total_amount);

    let (order_num) = order_count.read();
    let new_order_id = order_num + 1;
    let ord: Order = Order(new_order_id, product_id, caller, validator_id, 0, total_amount);
    orders.write(new_order_id, ord);
    order_count.write(new_order_id);

    prod.status = 1;
    products.write(product_id, prod);
    return ();
}

// ----------------------
// VALIDATOR DECISION
// ----------------------
@external
func submit_validation(order_id: felt, decision: felt) {
    alloc_locals;
    let (mut ord) = orders(order_id);
    assert get_caller_address() = validators(ord.validator_id).addr;
    ord.status = decision;
    orders.write(order_id, ord);
    return ();
}

// ----------------------
// BUYER FINAL DECISION
// ----------------------
@external
func finalize_purchase(order_id: felt, proceed: felt) {
    alloc_locals;
    let (mut ord) = orders(order_id);
    let (prod) = products(ord.product_id);
    let (val) = validators(ord.validator_id);

    if proceed == 1 {
        let validator_fee = prod.price * get_fee_percent(val.rating) / 100;
        escrow_balances.write(prod.seller, prod.price);
        escrow_balances.write(val.addr, validator_fee);
    } else {
        escrow_balances.write(ord.buyer, ord.escrow_amount - 3);
        escrow_balances.write(val.addr, 3);
    }

    return ();
}

// ----------------------
// RATING FUNCTION
// ----------------------
@external
func rate_validator(order_id: felt, stars: felt) {
    alloc_locals;
    let (mut val) = validators(orders(order_id).validator_id);
    let new_total_ratings = val.total_ratings + 1;
    let new_avg = ((val.rating * val.total_ratings) + (stars * 100)) / new_total_ratings;

    val.rating = new_avg;
    val.total_ratings = new_total_ratings;
    validators.write(val.id, val);
    return ();
}

// ----------------------
// HELPER FUNCTIONS
// ----------------------
func get_fee_percent(rating: felt) -> (fee: felt) {
    if rating >= 450 {
        return (3,);
    }
    if rating >= 300 {
        return (2,);
    }
    return (1,);
}
