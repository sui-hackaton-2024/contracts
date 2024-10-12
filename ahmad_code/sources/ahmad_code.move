
module LotterySale::LotterySale {    
    use sui::coin::Coin; // For handling SUI coin operations
    use sui::random::Random; // For randomness
    use std::string::String;
    use sui::object::UID;
    use sui::transfer;
    use sui::tx_context::TxContext;

    // error codes
    const EInvalidDepositPrice: u64 = 1;
    // const EInactiveSale: u64 = 2;
    // const EInvalidPayment: u64 = 3;

    // --- structs
    
    // Struct representing a Sale
    public struct Sale has key {
        id: UID, // Unique sale identifier (based on object UID)
        owner: address,
        deposit_price: u64,  // TODO allow for floating numbers
        participants: vector<address>,
        is_active: bool,
        total_collected: u64,
        deposits: vector<u64>,
    }

    
    // Function to create a sale
    public fun create_sale(
        deposit_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(deposit_price > 0, EInvalidDepositPrice);
        let sale = Sale {
            id: sui::object::new(ctx),
            owner: tx_context::sender(ctx),
            deposit_price,
            participants: vector::empty(),
            is_active: true,
            total_collected: 0,
            deposits: vector::empty(),
        };
        transfer::transfer(sale, tx_context::sender(ctx));
    }

/*
    // struct representing a participation in the sale
    public struct Participation has key, store {
        id: UID,
        sale_id: ID,
        participant: address,
    }
*/
    // --- functions

/*
    // Function to create a sale
    public fun create_sale(
        deposit_price: u64,
        ctx: &mut TxContext,
    ): object::ID {
        assert!(deposit_price > 0, EInvalidDepositPrice);
        let sale_id = object::new(ctx);
        let sale = Sale {
            id: sale_id,
            owner: tx_context::sender(ctx),
            deposit_price,
            participants: vector::empty(),
            is_active: true,
            total_collected: 0,
            deposits: vector::empty(),
        };
        let sale_id_copy = *object::uid_as_inner(&sale.id); // Extract the ID before transferring
        sui::transfer::transfer(sale, tx_context::sender(ctx));
        sale_id_copy // Return the extracted ID
    }
    */


/*
    // Function to participate in a sale
    public fun participate(
        sale: &mut Sale,
        payment: Coin<sui::SUI>,
        ctx: &mut TxContext
    ) {
        assert!(Coin::value(&payment) == sale.deposit_price, EInvalidPayment);
        transfer::transfer(payment, tx_context::sender(ctx));
    }

    // Function for buyers to participate in the lottery by depositing SUI
    public fun participate(
        sale_id: object::ID,
        payment: sui::coin::Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Fetch the sale object using the sale_id
        let sale = borrow_global_mut<Sale>(sale_id);
        
        // Ensure the sale is active
        assert!(sale.is_active, EInactiveSale);
        
        // Ensure the payment is equal to the deposit price
        assert!(sui::coin::value(&payment) == sale.deposit_price, EInvalidPayment);
        
        // Add participant to the sale
        vector::push_back(&mut sale.participants, tx_context::sender(ctx));
        
        // Update total collected
        sale.total_collected = sale.total_collected + sale.deposit_price;
        
        // Transfer the payment to the sale owner
        sui::transfer::transfer(payment, sale.owner);
    }
    */
    fun draw_winner(
    participants: &vector<address>, // List of participants
    ctx: &mut TxContext // Transaction context used for randomness generation
    ): address {
    let total_participants = vector::length(participants);
    assert!(total_participants > 0, 5, "No participants to draw from");

    // Create a new RandomGenerator
    let mut generator = random::new_generator(&Random, ctx);

    // Generate a random index in the range [0, total_participants)
    let winner_index = random::generate_u64_in_range(&mut generator, 0, total_participants);

    // Get the winner's address
    *vector::borrow(participants, winner_index)
}

    //trigger lottery
    public fun trigger_lottery(
    sale: &mut Sale,
    owner: &signer,
    treasury_cap: &mut TreasuryCap<YourCoinType>, // Add TreasuryCap for minting
    ctx: &mut TxContext // Pass the TxContext for randomness
    ) {
    assert!(sale.is_active, 3, "Sale is not active");
    assert!(sale.owner == signer::address_of(owner), 4, "Only owner can trigger the lottery");

    let participants = &sale.participants;
    let total_participants = vector::length(participants);
    assert!(total_participants > 0, 5, "No participants to draw from");
    
    // Call the draw_winner function using the native randomness
    let winner = draw_winner(participants, ctx);

    // Mint NFT ticket for the winner
    let nft = NFT::mint(winner, "Winning Ticket", "You have won the lottery!");

    // Emit lottery triggered event
    Event::emit(LotteryTriggered {
        sale_id: signer::address_of(&sale.owner), // Use the sale owner's address as a unique ID
        winner,
    });

    // Refund other participants
    for i in 0..total_participants {
        let participant = vector::borrow(participants, i);
        if *participant != winner {
            // Get the corresponding deposit amount
            let deposit = vector::borrow(&sale.deposits, i);
            // Create a new Coin to refund using TreasuryCap
            let refund_coin = coin::mint(treasury_cap, *deposit, ctx);
            transfer::public_transfer(refund_coin, *participant);
        }
    }

    sale.is_active = false;
    }
    //leftover funds
    public fun claim_leftover_funds(
    sale: &mut Sale,
    owner: &signer,
    treasury_cap: &mut TreasuryCap<YourCoinType>,
    ctx: &mut TxContext
    ) {
    assert!(sale.owner == signer::address_of(owner), 1, "Only the sale owner can claim funds");
    assert!(!sale.is_active, 2, "Sale must be inactive to claim funds");

    // Calculate the leftover funds
    let leftover_funds = sale.total_collected;
    sale.total_collected = 0; // Reset total collected

    // Mint a new Coin to transfer to the owner
    let funds_coin = coin::mint(treasury_cap, leftover_funds, ctx);
    transfer::public_transfer(funds_coin, signer::address_of(owner));
    }
}