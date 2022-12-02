#[test_only]
module overmind_interview::GameTest {
    // use std::debug;
    use std::vector;
    use std::unit_test;
    use std::signer;

    use overmind_interview::Game;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun trivial_test_runs() {
        assert!(true, 0)
    }

    #[test]
    public entry fun sample_withdrawal_vec() {
        let test_vector = Game::create_basic_withdrawal_vector();
        assert!(
            vector::is_empty(&test_vector) == false,
            0
        );
    }

    #[test]
    public entry fun depositor_can_deposit_amount() {
        // Setup
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);

        // Action
        Game::deposit_amount(&account, 10);

        // Test
        assert!(
            Game::get_depositor_amount(addr) == 10, 
            0
        );
    }

    #[test]
    public entry fun depositor_can_withdraw_amount() {
        // Setup
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        Game::deposit_amount(&account, 10);

        // Action
        let prize = Game::withdraw_amount(&account);

        // Test
        assert!(
            prize == 5, 
            0
        );

    }

    #[test]
    public entry fun depositor_amount_updates_after_withdraw() {
        // Setup
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        Game::deposit_amount(&account, 10);

        // Action
        let _prize = Game::withdraw_amount(&account);

        // Test - with static withdrawal fraction (.5)
        assert!(
            Game::get_depositor_amount(addr) == 5, 
            0
        );
    }

}