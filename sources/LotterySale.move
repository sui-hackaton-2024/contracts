
module LotterySale::LotterySale {    
    use sui::coin::Coin; // For handling SUI coin operations
    use sui::random::Random; // For randomness
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // Struct representing a Sale, refactored to store UID for object-based management
    public struct Sale has key, store  { // 'key' allows this struct to be stored on-chain
        id: UID, // Unique identifier for the Sale
        owner: address,
        deposit_price: u64, // in SUI cents
        participants: vector<address>,
        is_active: bool,
        total_collected: u64,
        deposits: vector<u64>, // Store deposits of each participant
        // nft_ticket: Option<NFT>, // Placeholder for future NFT integration
    }

    // Event emitted when a sale is created
    public struct SaleCreated has copy, drop, store {
        sale_id: u64,
        owner: address,
        deposit_price: u64,
    }

    // Event emitted when a user participates
    public struct Participation has copy, drop, store {
        sale_id: u64,
        participant: address,
    }

    // Event emitted when the lottery is triggered
    public struct LotteryTriggered has copy, drop, store {
        sale_id: u64,
        winner: address,
    }

    // Sale counter to generate unique sale IDs
    public struct SaleCounter has store {
        count: u64,
    }

    // ------------------------



}