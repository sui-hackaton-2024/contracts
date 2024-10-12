
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

    // --- structs
    
    // Struct representing a Sale
    public struct Sale has key {
        id: UID, // Unique sale identifier (based on object UID)
        owner: address,
        deposit_price: u64,  // TODO allow for floating numbers
        participants: vector<address>,
        is_active: bool,
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
        };
        transfer::transfer(sale, tx_context::sender(ctx));
    }


    // Function to participate in a sale
    public fun participate(
        sale_id: UID,
        amount: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Retrieve the sale object mutably
        let sale = get_mut<Sale>(sale_id); // Get a mutable reference to the Sale object

        // Check if the sale is active
        assert!(sale.is_active, EInactiveSale);

        // Get the payment amount from the coin
        let payment_amount = sui::coin::value(&amount); // Get the value of the payment coin

        // Check if the payment is sufficient
        assert!(payment_amount >= sale.deposit_price, EInvalidPayment);

        // Add the caller to the participants list
        let caller = tx_context::sender(ctx);
        vector::push_back(&mut sale.participants, caller);

        // Transfer the payment to the sale owner
        sui::coin::transfer(amount, sale.owner, ctx); // Transfer the actual coin object
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

}