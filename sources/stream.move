module self::test19{
    use std::signer;
    use std::debug::print;
    use std::timestamp; 
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_std::table::{Self, Table};
    const UNIT_PRICE: u64 = 100000;//least is 1oooth of a coin
    const PLATFORM_FEE:u64 =1000000;
   struct FluXtream_transaction has key,copy,drop,store {
     sender: address,
        receiver: address,
        flow_rate: u64,
        start_time: u64,
        end_time: u64, // added a field to store the end time of the stream
        completed: bool,
   }
   struct DifferenceAmount has key ,store{
    isPositive: bool,
    amount: u64,
   }
   struct UserBalances has key , store{
        Users: Table<address, DifferenceAmount>
   }
   struct Sender_streams has key,store{
       transactions: Table<address, vector<FluXtream_transaction>>
   }
   struct Reciever_streams has key,store{
       transactions: Table<address, vector<FluXtream_transaction>>
   }
   fun init_module(account :&signer){
         let sender_streams = Sender_streams{
              transactions: table::new<address,vector<FluXtream_transaction>>(),
         };
         move_to( account,sender_streams);
         let reciever_streams = Reciever_streams{
              transactions: table::new<address,vector<FluXtream_transaction>>(),
         };
         move_to( account,reciever_streams);
         let user_balances = UserBalances{
              Users: table::new<address,DifferenceAmount>(),
         };
         move_to( account,user_balances);
    } 
    // this function creates a stream and stores ni both senders and recievers table
    public entry fun CreateStream(user:&signer,receiver:address,flow_rate:u64,duration:u64) acquires Reciever_streams , Sender_streams{
        //transfering the amount to the contract
        coin::transfer<AptosCoin>(user, @self, UNIT_PRICE*(flow_rate*duration)+PLATFORM_FEE);
        //create a transaction
        let transaction1= FluXtream_transaction{
            sender: signer::address_of(user),
            receiver: receiver,
            flow_rate: flow_rate,//flowrate per second
            start_time:timestamp::now_seconds(),
            end_time:timestamp::now_seconds()+ duration,
            completed:false,
        };
        let transaction2= FluXtream_transaction{
            sender: signer::address_of(user),
            receiver: receiver,
            flow_rate: flow_rate,//flowrate per second
            start_time:timestamp::now_seconds(),
            end_time:timestamp::now_seconds()+ duration,
            completed:false,
        };
        //update sender_streams
        let sender_streams_map=borrow_global_mut<Sender_streams>(@self);
        if (!table::contains<address,vector<FluXtream_transaction>>(&sender_streams_map.transactions,signer::address_of(user))){
            table::add(&mut sender_streams_map.transactions,signer::address_of(user),vector::empty<FluXtream_transaction>());
        };
        let sender_transactions=table::borrow_mut(&mut sender_streams_map.transactions,signer::address_of(user));
        vector::push_back<FluXtream_transaction>( sender_transactions,transaction1);
        //update reciever_streams
        let reciever_streams_map=borrow_global_mut<Reciever_streams>(@self);
        if (!table::contains<address,vector<FluXtream_transaction>>(&reciever_streams_map.transactions,receiver)){
            table::add(&mut reciever_streams_map.transactions,receiver,vector::empty<FluXtream_transaction>());
        };
        let reciever_transactions=table::borrow_mut(&mut reciever_streams_map.transactions,receiver);
        vector::push_back<FluXtream_transaction>( reciever_transactions,transaction2);
    }
   
    #[view]
    public fun IsSendStreamsPresent(user: address): bool acquires Sender_streams{
        let entire_stream=borrow_global<Sender_streams>(@self);
        table::contains<address,vector<FluXtream_transaction>>(&entire_stream.transactions,user)
    }
    #[view]
    public fun IsRecieveStreamPresent(user: address): bool acquires Reciever_streams{
        let entire_stream=borrow_global<Reciever_streams>(@self);
        table::contains<address,vector<FluXtream_transaction>>(&entire_stream.transactions,user)
    }
    #[view]
    public fun getListOfStreams(user: address): vector<FluXtream_transaction> acquires Sender_streams {
        let entire_stream=borrow_global<Sender_streams>(@self);
        let b=vector::empty<FluXtream_transaction>();
        if(table::contains<address,vector<FluXtream_transaction>>(&entire_stream.transactions,user)){
            let k=table::borrow<address, vector<FluXtream_transaction>>(&entire_stream.transactions,user);
            b=*k;
        };
        b
    }
    struct FlowingBalance has key,store{
        isPositive:bool,
        isPositive_flowrate:bool,
        balance: u64,
        flow_rate: u64,
    }
    #[view]
    public fun current_balance(user:address):FlowingBalance acquires Sender_streams , Reciever_streams{
        //TODO : current balance of user is the sum of all the streams that are active + his existing balance
         
        //adding all the negative streams
        let sender_streams_map=borrow_global<Sender_streams>(@self);
        let negative_streams:u64=0;
        let negative_flowrate:u64=0;
        // only if the sender address is present in senderstreams , run the logic
        if (!table::contains<address,vector<FluXtream_transaction>>(&sender_streams_map.transactions,user)){
            
            let sender_transactions=table::borrow(&sender_streams_map.transactions,user);
            let len1:u64 = vector::length(sender_transactions);
            
            let i = 0;
            while (i < len1) {
                let element = vector::borrow(sender_transactions, i);
                // when the stream is active
                if (element.end_time>timestamp::now_seconds()) {
                    let difference_time = timestamp::now_seconds() - element.start_time;
                    let difference_amount = difference_time * element.flow_rate;
                    negative_streams=negative_streams+difference_amount;
                    negative_flowrate=negative_flowrate+element.flow_rate;

                };
                if(element.end_time<timestamp::now_seconds()){
                    let difference_time = element.end_time - element.start_time;
                    let difference_amount = difference_time * element.flow_rate;
                    negative_streams=negative_streams+difference_amount;

                };
                i = i + 1;
            };

        };
        
        // adding all the positive streams
        let reciever_streams_map=borrow_global<Reciever_streams>(@self);
        let positive_streams:u64=0;
        let positive_flowrate:u64=0;
        if (!table::contains<address,vector<FluXtream_transaction>>(&reciever_streams_map.transactions,user)){
            let reciever_transactions=table::borrow(&reciever_streams_map.transactions,user);
            let len1:u64 = vector::length(reciever_transactions);
            let i = 0;
            while (i < len1) {
                let element = vector::borrow(reciever_transactions, i);
                // when the stream is active
                if (element.end_time > timestamp::now_seconds()) {
                    let difference_time = timestamp::now_seconds() - element.start_time;
                    let difference_amount = difference_time * element.flow_rate;
                    positive_streams=positive_streams+difference_amount;
                    positive_flowrate=positive_flowrate+element.flow_rate;
                };
                if(element.end_time < timestamp::now_seconds()){
                    let difference_time = element.end_time - element.start_time;
                    let difference_amount = difference_time * element.flow_rate;
                    positive_streams=positive_streams+difference_amount;

                };
                i = i + 1;
            };
        };

        let a:bool=true;
        let b:u64=0;
        let c:u64=0;
        let d:bool=true;
        if(negative_flowrate > positive_flowrate){
            d=false;
            c=negative_flowrate-positive_flowrate;
        };
        if(negative_flowrate < positive_flowrate){
            d=true;
            c=positive_flowrate-negative_flowrate;
        };
        if(negative_streams > positive_streams){
            a=false;
            b=negative_streams-positive_streams;
        };
        if(negative_streams < positive_streams){
            a=true;
            b=positive_streams-negative_streams;
        };
        let flowing_balance:FlowingBalance = FlowingBalance{
            isPositive:a,
            balance:b,
            flow_rate:c,
            isPositive_flowrate:d,
        };
        flowing_balance
    }
//    #[test(user = @0x1)]
// 	fun test_create_friend(user:signer) {
//         timestamp::set_time_has_started_for_testing(&user);
//         let _transaction1= FluXtream_transaction{
//             sender: @0x0,
//             receiver: @0x1,
//             flow_rate: 100,
//             start_time:timestamp::now_seconds(),
//             end_time: timestamp::now_seconds()+100,
//         };
//         let transactions=table::new<address,FluXtream_transaction>;
//         table::add(transactions,user,_transaction1);
//         let _sender_streams = Sender_streams{
//             transactions: transactions
//         };
//         print(&_sender_streams)
        
// 	}
}
