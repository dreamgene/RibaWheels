use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct CarData {
    pub make: felt252,
    pub model: felt252,
    pub year: u32,
    pub mileage: u64,
    pub vin: felt252,
    pub chassis_number: felt252,
    pub seller: ContractAddress,
    pub is_listed: bool,
}

#[starknet::interface]
pub trait ICarNFT<TContractState> {
    fn mint_car(
        ref self: TContractState,
        to: ContractAddress,
        make: felt252,
        model: felt252,
        year: u32,
        mileage: u64,
        vin: felt252,
        chassis_number: felt252,
    ) -> u256;
    fn get_car_data(self: @TContractState, token_id: u256) -> CarData;
    fn update_listing_status(ref self: TContractState, token_id: u256, is_listed: bool);
    fn transfer_car(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn get_next_token_id(self: @TContractState) -> u256;
    fn approve_minter(ref self: TContractState, minter: ContractAddress);
    fn revoke_minter(ref self: TContractState, minter: ContractAddress);
    fn is_approved_minter(self: @TContractState, minter: ContractAddress) -> bool;
}
