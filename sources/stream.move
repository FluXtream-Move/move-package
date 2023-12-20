module self::Fluxtream{
    use std::debug::print;
    use std::timestamp; 
    use aptos_std::table::{Self, Table};

   struct FluXtream_transaction has key,drop,store{
     sender: address,
        receiver: address,
        flow_rate: u128,
        start_time: u64,
        end_time: u64, // added a field to store the end time of the stream
   }
   struct Sender_streams has key,store{
       transactions: Table<address, FluXtream_transaction>
   }
   fun init_module(account :&signer){
         let sender_streams = Sender_streams{
              transactions: table::new(),
         };
         move_to( account,sender_streams);
    } 

   #[test(framework = @0x1)]
	fun test_create_friend(framework:signer){
        timestamp::set_time_has_started_for_testing(&framework);
        let _transaction1= FluXtream_transaction{
            sender: @0x0,
            receiver: @0x1,
            flow_rate: 100,
            start_time:timestamp::now_seconds(),
            end_time: timestamp::now_seconds()+100,
        };
        let transactions = table::new();
        transactions.add(framework,_transaction1);
        let _sender_streams = Sender_streams{
            transactions: transactions
        };
        print(&_sender_streams)
        
	}
}
