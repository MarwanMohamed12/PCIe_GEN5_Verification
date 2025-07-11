class DLLP_TLP_Seq2_TX_MASTER_U extends uvm_sequence #(LPIF_seq_item);
`uvm_object_utils(DLLP_TLP_Seq2_TX_MASTER_U)

LPIF_seq_item seq_item;
static bit SEND_TLP,SEND_DLLP;
static bit [63:0] DLLP_START,DLLP_END,TLP_END;
function new (string name = "DLLP_TLP_Seq2_TX_MASTER_U");

    super.new(name);

endfunction

    task body ();

     repeat(150) begin

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.DLLP_const.constraint_mode(1);


        
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
            
            

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.TLP_const.constraint_mode(1);


        
            start_item(seq_item);
                  assert(seq_item.randomize() with { payload.size()==1 ; no_of_tlp ==1 ; tlp_size[0]==64;});
            finish_item(seq_item);
            
    end      
    
    
    
    
    
    repeat(150) begin
  

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.TLP_const.constraint_mode(1);


        
            start_item(seq_item);
               assert(seq_item.randomize() with { payload.size()==1 ; no_of_tlp ==1 ; tlp_size[0]==64;});
            finish_item(seq_item);
            
            
        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.DLLP_const.constraint_mode(1);


        
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
            
          
            
    end      








    repeat(150) begin

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.DLLP_const.constraint_mode(1);


        
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
            
            

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.TLP_const.constraint_mode(1);


        
            start_item(seq_item);
                  assert(seq_item.randomize() with { payload.size()==1 ; });
            finish_item(seq_item);
            
    end      
    
    
    
    
    
    repeat(150) begin
  

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.TLP_const.constraint_mode(1);


        
            start_item(seq_item);
               assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
            
        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.DLLP_const.constraint_mode(1);


        
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
            
          
            
    end      



    


    endtask
endclass

