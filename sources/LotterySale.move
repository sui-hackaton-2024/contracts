
module LotterySale::LotterySale {    
    use sui::coin::Coin; // For handling SUI coin operations
    use sui::random::Random; // For randomness
    use std::string::String;
    use sui::object::UID;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::sui::SUI;

    // error codes
    const EInvalidDepositPrice: u64 = 1;
    const EInactiveSale: u64 = 2;
    const EInvalidPayment: u64 = 3;
    const EUnauthorizedWithdrawal: u64 = 4;

    // --- structs
    
    // Struct representing a Sale
    public struct Sale has key {
        id: UID, // Unique sale identifier (based on object UID)
        owner: address,
        deposit_price: u64,  // TODO allow for floating numbers
        participants: vector<address>,
        is_active: bool,
        total_collected: u64, // Track total amount collected from participants
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
        };
        transfer::transfer(sale, tx_context::sender(ctx));
    }

/*
    // Function to participate in a sale
    public fun participate(
        sale_id: UID,
        amount: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Retrieve the sale object mutably
        let sale_ref = sui::object::borrow_mut<Sale>(sale_id, ctx);
        // let sale = borrow_global_mut<Sale>(sale_id); // Get a mutable reference to the Sale object

        // Check if the sale is active
        assert!(sale.is_active, EInactiveSale);

        // Get the payment amount from the coin
        let payment_amount = sui::coin::value(&amount); // Get the value of the payment coin

        // Check if the payment is sufficient
        assert!(payment_amount >= sale.deposit_price, EInvalidPayment);

        // Add the caller to the participants list
        let caller = tx_context::sender(ctx);
        vector::push_back(&mut sale.participants, caller);

        // commenting to leave the funds into the contract ?
        // Transfer the payment to the sale owner
        // sui::coin::transfer(amount, sale.owner, ctx); // Transfer the actual coin object
        // Instead of transferring, update total collected        
        let sale = borrow_global_mut<Sale>(sale_id);
        let new_total = sale.total_collected + payment_amount;
        *sale = Sale {
            total_collected: new_total,
        };

    }
    */

    // Function to participate in a sale
    public fun participate(
        sale: &mut Sale,
        amount: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Check if the sale is active
        assert!(sale.is_active, EInactiveSale);

        // Get the payment amount from the coin
        let payment_amount = sui::coin::value(&amount); // Get the value of the payment coin

        // Check if the payment is sufficient
        assert!(payment_amount != sale.deposit_price, EInvalidPayment);

        // Add the caller to the participants list
        let caller = tx_context::sender(ctx);
        vector::push_back(&mut sale.participants, caller);

        sale.total_collected = sale.total_collected + payment_amount;

        // Transfer the payment to the sale owner
        // sui::coin::transfer(amount, sale.owner, ctx); 
        sui::transfer::public_transfer(amount, sale.owner)
    }

/* // useless ?
    // Function for the sale owner to withdraw collected funds
    public fun withdraw_funds(
        sale: &mut Sale,
        ctx: &mut TxContext,
    ) {        
        // Ensure that the caller is the sale owner
        assert!(tx_context::sender(ctx) == sale.owner, EUnauthorizedWithdrawal);

        // Transfer the collected funds to the owner
        let amount_to_transfer = sale.total_collected;

        // Create a new Coin<SUI> from the collected amount, assuming you have a way to do this
        let collected_coin = sui::coin::create(amount_to_transfer); // This will depend on your SUI implementation

        // Transfer the coin to the owner
        sui::coin::transfer(collected_coin, sale.owner, ctx);

        // Reset total collected to zero after withdrawal
        sale.total_collected = 0;
    }
    */

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

}