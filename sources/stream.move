module my_addr::Fluxtream{
    use aptos_framework::event;
    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::signer::address_of;
    use std::vector;
    use std::timestamp;
    use std::simple_map::{SimpleMap,Self};
    use aptos_framework::account;

    use aptos_framework::coin;
    use aptos_framework::coin::balance;

    struct FlowInfo has key {
        sender: address,
        receiver: address,
        flow_rate: u64,
        start_time: u64,
        end_time: u64, // added a field to store the end time of the stream
        total_amount: u64, // added a field to store the total amount of the stream
    }

    struct FlowSignerCap has store {
        resource_account_address: address,
        resource_account_signer_cap: account::SignerCapability
    }
    struct Sender has key {
        balance: u64,
        // Map receiver address to flow resource account address
        resource_account_map: SimpleMap<address, FlowSignerCap>,
    }
    public fun calculate_amount(flow_rate: u64, elapsed_time: u64): u64 {
        flow_rate * elapsed_time
    }
    public fun calculate_elapsed_time(start_time: u64, end_time: u64): u64 {
        end_time - start_time
    }
    public fun is_stream_completed(stream: &FlowInfo): bool {
        let current_time = timestamp::now_seconds();
        let elapsed_time = calculate_elapsed_time(stream.start_time, current_time);
        let amount = calculate_amount(stream.flow_rate, elapsed_time);
        amount >= stream.total_amount
    }
    public fun transfer_tokens(account: &signer, receiver: address, amount: u64) {
        // Token::transfer_from(account, receiver, amount);
    }
    public fun emit_stream_created_event(stream: &FlowInfo) {
        event::emit(stream);
    }
    public fun emit_stream_stopped_event(stream: &FlowInfo) {
        event::emit(stream);
    }
    public fun emit_stream_withdrawn_event(stream: &FlowInfo, fraction: u8) {
        event::emit(stream);
    }
    public fun emit_stream_completed_event(stream: &FlowInfo) {
        event::emit(stream);
    }
    const APP_SIGNER_CAPABILITY_SEED: vector<u8> = b"super_flow_sender_resource_account";
    public entry fun create_stream<CoinType>(sender: &signer, receiver: address, flow_rate: u64, total_amount: u64) acquires Sender {
        let sender_address = signer::address_of(sender);
        let (resource_account, resource_signer_cap) = account::create_resource_account(
            sender,
            APP_SIGNER_CAPABILITY_SEED,
        );
        let resource_signer = account::create_signer_with_capability(&resource_signer_cap);

        if (!exists<Sender>(sender_address)) {
            move_to(sender, Sender {
                balance: 0,
                //TODO: Sender.balance
                resource_account_map: SimpleMap<address, FlowSignerCap>,
            });
        };
        let sender_resource = borrow_global_mut<Sender>(sender_address);
        assert!(sender_resource.balance >= total_amount, 2);

        // TODO: Check that a flow for the same receiver isn't already created before->Completed
        if (simple_map::contains_key(&sender_resource.resource_account_map, &receiver)) {
            abort 100; // or any other error code
        };

        simple_map::insert(&mut sender_resource.resource_account_map, receiver, FlowSignerCap {
            resource_account_address: signer::address_of(&resource_account),
            resource_account_signer_cap: resource_signer_cap,
        });

        let stream = FlowInfo {
            sender: sender_address,
            receiver,
            flow_rate,
            start_time: timestamp::now_seconds(),
            end_time: 0,
            total_amount,
        };
        move_to<FlowInfo>(&resource_signer, stream);
            // TODO: Send `amount` APT to the resource account
            coin::transfer<CoinType>(sender, resource_account, total_amount);
            // TODO: subtract `total_amount` from sender's balance

    }

    // public fun stop_stream(account: &signer) acquires FlowInfo, Sender {

    public fun withdraw_stream(receiver_signer: &signer, sender: address, fraction: u8) acquires FlowInfo, Sender {
        let receiver = signer::address_of(receiver_signer);
        let sender_resource = borrow_global<Sender>(sender);
        let resource_account_signer_info = simple_map::get(&sender_resource.resource_account_map, receiver);
        let resource_account_signer = account::create_signer_with_capability(&resource_account_signer_info.resource_account_signer_cap);
        // TODO: Calculate the balance to be transfer to the receiver
        coin::transfer<CoinType>(&resource_account_signer, receiver, amount);
    }

    // A function to check if the stream is completed or not

}