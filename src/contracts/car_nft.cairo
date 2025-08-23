#[starknet::contract]
pub mod CarNFT {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use crate::interfaces::Icar_nft::{ICarNFT, CarData};
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::access::ownable::OwnableComponent;
    use core::num::traits::Zero;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // Ownable
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        // Car-specific data
        car_data: Map<u256, CarData>,
        next_token_id: u256,
        // Approved minters (like marketplace contract)
        approved_minters: Map<ContractAddress, bool>,
    }



    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        CarMinted: CarMinted,
        CarDataUpdated: CarDataUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct CarMinted {
        #[key]
        token_id: u256,
        #[key]
        seller: ContractAddress,
        car_data: CarData,
    }

    #[derive(Drop, starknet::Event)]
    struct CarDataUpdated {
        #[key]
        token_id: u256,
        car_data: CarData,
    }

    mod Errors {
        const UNAUTHORIZED: felt252 = 'Caller not authorized';
        const CAR_NOT_EXISTS: felt252 = 'Car does not exist';
        const ALREADY_LISTED: felt252 = 'Car already listed';
        const NOT_LISTED: felt252 = 'Car not listed';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        owner: ContractAddress,
    ) {
        self.erc721.initializer(name, symbol, "");
        self.ownable.initializer(owner);
        self.next_token_id.write(1);
    }

    #[abi(embed_v0)]
    impl CarNFTImpl of ICarNFT<ContractState> {
        fn mint_car(
            ref self: ContractState,
            to: ContractAddress,
            make: felt252,
            model: felt252,
            year: u32,
            mileage: u64,
            vin: felt252,
            chassis_number: felt252,
        ) -> u256 {
            let caller = get_caller_address();
            assert(
                self.ownable.owner() == caller || self.approved_minters.read(caller),
                'Caller not authorized to mint'
            );
            
            let token_id = self.next_token_id.read();
            self.next_token_id.write(token_id + 1);

            let car_data = CarData {
                make,
                model,
                year,
                mileage,
                vin,
                chassis_number,
                seller: to,
                is_listed: true,
            };

            self.car_data.write(token_id, car_data);
            self.erc721.mint(to, token_id);

            self.emit(CarMinted { token_id, seller: to, car_data });
            token_id
        }

        fn get_car_data(self: @ContractState, token_id: u256) -> CarData {
            assert(!self.erc721.owner_of(token_id).is_zero(), 'Car does not exist');
            self.car_data.read(token_id)
        }

        fn update_listing_status(ref self: ContractState, token_id: u256, is_listed: bool) {
            self.ownable.assert_only_owner();
            assert(!self.erc721.owner_of(token_id).is_zero(), 'Car does not exist');
            
            let mut car_data = self.car_data.read(token_id);
            car_data.is_listed = is_listed;
            self.car_data.write(token_id, car_data);

            self.emit(CarDataUpdated { token_id, car_data });
        }

        fn transfer_car(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            self.ownable.assert_only_owner();
            self.erc721.transfer_from(from, to, token_id);
        }

        fn get_next_token_id(self: @ContractState) -> u256 {
            self.next_token_id.read()
        }

        fn approve_minter(ref self: ContractState, minter: ContractAddress) {
            self.ownable.assert_only_owner();
            self.approved_minters.write(minter, true);
        }

        fn revoke_minter(ref self: ContractState, minter: ContractAddress) {
            self.ownable.assert_only_owner();
            self.approved_minters.write(minter, false);
        }

        fn is_approved_minter(self: @ContractState, minter: ContractAddress) -> bool {
            self.approved_minters.read(minter)
        }
    }
}