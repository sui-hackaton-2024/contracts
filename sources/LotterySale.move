// next try a USDC version

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
    // const EUnauthorizedWithdrawal: u64 = 4;
    const EInvalidNBWinners: u64 = 5;

    // --- structs

    // manages ownership rights for a Sale
    public struct SaleCap has key, store  {
        id: UID, // Unique identifier for the SaleCap
        owner: address,  // Address of the owner of this SaleCap
    }
    
    // Struct representing a Sale
    public struct Sale has key, store {
        id: UID, // Unique sale identifier (based on object UID)
        owner: address,
        cap: SaleCap, // Reference to the SaleCap
        deposit_price: u64,  // beware the unit is in Mist not SUI
        participants: vector<address>,
        nb_winners: u64, // Number of possible winners
        is_active: bool,
        total_collected: u64, // Track total amount collected from participants
    }

    public fun create_sale_cap(
        ctx: &mut TxContext,
    ){
        // we create a SaleCap struct to handle the right to call restricted fonctions
        // pass the salecap id to the create_sale() function to inject it into the Sale itself
        // + verifier le owner du cap dans les fonctions à restreindre

        let sale_cap = SaleCap {
            id: sui::object::new(ctx),  // Create a new SaleCap object
            owner: tx_context::sender(ctx),  // Set the owner of the SaleCap to the caller
        };
        // private send
        transfer::transfer(sale_cap, tx_context::sender(ctx));
    }
    
    // Function to create a sale
    public fun create_sale(
        sale_cap: SaleCap,  // Mutable reference to the SaleCap object
        deposit_price: u64,
        nb_winners: u64,  // Number of winners for the sale
        ctx: &mut TxContext,
    ) {
        // ensure deposit price > 0
        assert!(deposit_price > 0, EInvalidDepositPrice);
        // Ensure there is at least one winner
        assert!(nb_winners > 0, EInvalidNBWinners);

        // Create a new SaleCap instance

        let sale = Sale {
            id: sui::object::new(ctx),
            owner: tx_context::sender(ctx),
            cap: sale_cap, // TODO inject the salecap
            deposit_price, 
            participants: vector::empty(),
            nb_winners,
            is_active: true,
            total_collected: 0,
        };

        // Share the object to make it accessible to everyone
        transfer::public_share_object(sale)
    }

    // Function to participate in a sale
    public fun participate(
        sale: &mut Sale,                // Mutable reference to the sale object
        inputCoins: &mut Coin<SUI>,     // Mutable reference to the payment coin
        ctx: &mut TxContext,            // Transaction context
    ) {

        // Check if the sale is active
        assert!(sale.is_active, EInactiveSale);

        // Split the inputCoins to create a new coin for the payment
        let payment_coin = sui::coin::split(inputCoins, sale.deposit_price, ctx); 

        // Get the payment amount from the newly created coin
        let payment_amount = sui::coin::value(&payment_coin); // Get the value of the payment coin (in mist, not SUI)

        // Check if the payment is sufficient
        assert!(payment_amount >= sale.deposit_price, EInvalidPayment); // Ensure payment is sufficient

        let caller = tx_context::sender(ctx); // Get the caller's address

        // Calculate the change
        let change_amount = payment_amount - sale.deposit_price;

        let mut mut_payment_coin = payment_coin; // Make payment_coin mutable again

        // Add the caller to the participants list
        vector::push_back(&mut sale.participants, caller);

        // Update the total collected amount
        sale.total_collected = sale.total_collected + sale.deposit_price;

        // NOTE explore the possibility of leavin the funds in the contract for longer & withdraw later
        // but at least the current way is safe

        // If there's change, return it to the sender
        if (change_amount > 0) {
            // Create a new coin for the change
            // (note we cannot mint native SUI, mint is only for tokens)
            let change_coin = sui::coin::split(&mut mut_payment_coin, change_amount, ctx);
            // Transfer both coins in the same context
            transfer::public_transfer(change_coin, caller);           // Transfer the change to the caller
            transfer::public_transfer(mut_payment_coin, sale.owner);      // Transfer the payment to the sale owner
        } else {
            // If there's no change, just transfer the full payment to the sale owner
            // beware putting this line outside of the else block breaks the function
            transfer::public_transfer(mut_payment_coin, sale.owner);
        }
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
}