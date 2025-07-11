class DLLP_Seq_TX_MASTER_U extends uvm_sequence #(LPIF_seq_item);
`uvm_object_utils(DLLP_Seq_TX_MASTER_U)

LPIF_seq_item seq_item;

function new (string name = "DLLP_Seq_TX_MASTER_U");

    super.new(name);

endfunction

    task body ();
        int seed=1;
        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        seq_item.DLLP_const.constraint_mode(1);

       //send different DLLP transfers
        `uvm_info(get_type_name() ," drive Different DLLP sequence in TX Master U ",UVM_LOW)
        repeat(500)begin
            start_item(seq_item);
               assert(seq_item.randomize());
            finish_item(seq_item); 
        end
        // send DLLP sequence in same transfer
        `uvm_info(get_type_name() ," drive Different DLLP in same transfer sequence in TX Master U ",UVM_LOW)

        seq_item.constraint_mode(0);

         /*   start_item(seq_item);
                assert(seq_item.randomize() with {
                    payload.size==1;
                                    
                    lp_dlpstart==64'h4010008004000000;
                    lp_dlpend  ==64'h0080200100080000;
                    lp_tlpstart==64'h0000000000000000;
                    lp_tlpend  ==64'h0000000000000000;
                });
            finish_item(seq_item);*/
    endtask

endclass