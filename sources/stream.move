module self::test13{
    use std::signer;
    use std::debug::print;
    use std::timestamp; 
    use std::vector;
    use aptos_std::table::{Self, Table};
   struct FluXtream_transaction has key,drop,store {
     sender: address,
        receiver: address,
        flow_rate: u128,
        start_time: u64,
        end_time: u64, // added a field to store the end time of the stream
   }
   
   struct Sender_streams has key,store{
       transactions: Table<address, vector<FluXtream_transaction>>
   }
   struct Reciever_streams has key,store {
       transactions: Table<address, FluXtream_transaction>
   }
   fun init_module(account :&signer){
         let sender_streams = Sender_streams{
              transactions: table::new<address,vector<FluXtream_transaction>>(),
         };
         move_to( account,sender_streams);
         let reciever_streams = Reciever_streams{
              transactions: table::new<address,FluXtream_transaction>(),
         };
         move_to( account,reciever_streams);
    } 
    public entry fun CreateStream(user:&signer,receiver:address,flow_rate:u128,duration:u64) acquires Sender_streams{
        let transaction1= FluXtream_transaction{
            sender: signer::address_of(user),
            receiver: receiver,
            flow_rate: flow_rate,//flowrate per second
            start_time:timestamp::now_seconds(),
            end_time:timestamp::now_seconds()+ duration,
        };
        let sender_streams_map=borrow_global_mut<Sender_streams>(@self);
        if (!table::contains<address,vector<FluXtream_transaction>>(&sender_streams_map.transactions,signer::address_of(user))){
            table::add(&mut sender_streams_map.transactions,signer::address_of(user),vector::empty<FluXtream_transaction>());
        };
        let sender_transactions=table::borrow_mut(&mut sender_streams_map.transactions,signer::address_of(user));
        vector::push_back<FluXtream_transaction>( sender_transactions,transaction1);
    }
    #[view]
    public fun IsSendStreamsPresent(user: address): bool acquires Sender_streams{
        let entire_stream=borrow_global<Sender_streams>(@self);
        table::contains<address,vector<FluXtream_transaction>>(&entire_stream.transactions,user)
    }
    #[view]
    public fun getListOfStreams(user: address): vector<FluXtream_transaction> acquires Sender_streams{
        let entire_stream=borrow_global<Sender_streams>(@self);
        let a=table::borrow_global<vector<FluXtream_transaction>>(entire_stream.transactions,user);
        a
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
