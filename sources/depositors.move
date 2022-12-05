module overmind_interview::Game {
    use std::signer;
    use std::fixed_point32::{Self, FixedPoint32};
    use std::vector;

    struct DepositBank has key {
        amount: u64,
    }

    struct GameSession has key {
        order: vector<FixedPoint32>,
        limit: u8
    }

    public fun init_game(owner: &signer) {
        let game = GameSession {
            order: create_basic_withdrawal_vector(),
            limit: 3,
        };

        move_to(owner, game);

    }

    public entry fun create_basic_withdrawal_vector(): vector<FixedPoint32> {
        let ret: vector<FixedPoint32> = vector[];
        let one = fixed_point32::create_from_rational(1, 2);
        let two = fixed_point32::create_from_rational(1, 3);
        let three = fixed_point32::create_from_rational(1, 5);

        vector::push_back(&mut ret,three);
        vector::push_back(&mut ret,two);
        vector::push_back(&mut ret,one);

        ret

    }

    public entry fun deposit_amount(account: &signer, amount: u64)
    acquires DepositBank {
        // Check if number of depositors have been met

        let account_addr = signer::address_of(account);
        if (!exists<DepositBank>(account_addr)) {
            move_to(account, DepositBank {
                amount
            })
        } else {
            let depositor = borrow_global_mut<DepositBank>(account_addr);
            depositor.amount = depositor.amount + amount;
        }
    }

    public entry fun get_depositor_amount(addr: address): u64 
    acquires DepositBank {
        *&borrow_global<DepositBank>(addr).amount
    }

    public entry fun withdraw_amount(account: &signer): u64
    acquires DepositBank {
        let account_addr = signer::address_of(account);
        let depositor = borrow_global_mut<DepositBank>(account_addr);
        let current_amt = depositor.amount;

        let withdraw_amt = calculate_withdraw_amount(current_amt);
        depositor.amount = current_amt - withdraw_amt;

        withdraw_amt

    }

    public fun calculate_withdraw_amount(avail_amt: u64): u64
    {
        if (avail_amt <= 1) {
            return 0
        };
        
        // todo: use the next fraction from global storage
        // todo: this funtion would use the annotation 'acquires GameSession'

        // let order = &mut borrow_global_mut<GameSession>(account_addr).order;
        // let next_fraction = vector::pop_back(order);

        // static withdraw fraction
        let static_fraction = fixed_point32::create_from_rational(1, 2);

        // Multiply will truncate any fractional part of the value
        fixed_point32::multiply_u64(avail_amt, static_fraction)
    }

}
