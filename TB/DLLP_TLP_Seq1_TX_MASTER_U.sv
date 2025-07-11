class DLLP_TLP_Seq1_TX_MASTER_U extends uvm_sequence #(LPIF_seq_item);
`uvm_object_utils(DLLP_TLP_Seq1_TX_MASTER_U)

LPIF_seq_item seq_item;
static bit SEND_TLP,SEND_DLLP;
static bit [63:0] DLLP_START,DLLP_END,TLP_END;
function new (string name = "DLLP_TLP_Seq1_TX_MASTER_U");

    super.new(name);

endfunction

    task body ();

        seq_item = LPIF_seq_item::type_id::create("seq_item");
         seq_item.constraint_mode(0);
        seq_item.DLLP_TLP_const.constraint_mode(1);
        
         repeat(1500) begin
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
            finish_item(seq_item);
            
          end


        /*`uvm_info(get_type_name() ,"  different TLP DLLP sequence U",UVM_LOW)
        repeat(5)begin
                    
                assert(seq_item.randomize());
                        
                if(seq_item.lp_tlpstart>seq_item.lp_dlpstart)SEND_TLP=1;
                else if(seq_item.lp_tlpstart<seq_item.lp_dlpstart)SEND_DLLP=1;
                TLP_END=seq_item.lp_tlpend;
                DLLP_START=seq_item.lp_dlpstart;
                DLLP_END=seq_item.lp_dlpend;
                        if(seq_item.payload.size()==1)begin
                            start_item(seq_item);
                            finish_item(seq_item);
                        end
                        else if(SEND_TLP)begin
                            for (int i=0;i<$size(seq_item.payload);i++)begin
                                start_item(seq_item);
                                seq_item.lp_data=seq_item.payload[i];
                                if(i==0)begin
                                    seq_item.lp_dlpend=0;
                                    seq_item.lp_dlpstart=0;
                                    seq_item.lp_tlpend=0;
                                end
                                else if(i == $size(seq_item.payload)-1)begin
                                    seq_item.lp_tlpend  =TLP_END;
                                    seq_item.lp_dlpstart=DLLP_START;
                                    seq_item.lp_dlpend  =DLLP_END;
                                end
                                else begin
                                    seq_item.lp_tlpstart=0;

                                end
                                finish_item(seq_item);
                            end
                        end
                        else if(SEND_DLLP)begin
                            for (int i=0;i<$size(seq_item.payload);i++)begin
                                start_item(seq_item);
                                seq_item.lp_data=seq_item.payload[i];
                                if(i==0)begin
                                    seq_item.lp_tlpend=0;
                                end
                                else if(i == $size(seq_item.payload)-1)begin
                                    seq_item.lp_tlpend  =TLP_END;;
                                end
                                else begin
                                    seq_item.lp_tlpstart=0;
                                    seq_item.lp_dlpend=0;
                                    seq_item.lp_dlpstart=0;
                                end
                                finish_item(seq_item);
                            end
                        end
            DLLP_START=0;
            DLLP_END=0;
            TLP_END=0;
            SEND_DLLP=0;
            SEND_TLP=0;
        end


        // DLLP TLP in_same transfer sequence
         `uvm_info(get_type_name() ,"  DLLP TLP in_same transfer sequence U",UVM_LOW)
        seq_item.constraint_mode(0);
            start_item(seq_item);
                assert(seq_item.randomize() with { payload.size()==1 ;});
                seq_item.lp_dlpstart=64'h8000000000000080;
                seq_item.lp_dlpend  =64'h0100000000000001;
                seq_item.lp_tlpstart=64'h0080000400000000;
                seq_item.lp_tlpend  =64'h0000001000002000;
            finish_item(seq_item);

        // send DLLP_TLP_MAX sequence 
        `uvm_info(get_type_name() ,"  DLLP_TLP_MAX sequence U",UVM_LOW)

         assert(seq_item.randomize() with { payload.size()==65 ;});
                seq_item.lp_tlpstart=0;
                seq_item.lp_tlpend  =0;
                seq_item.lp_dlpstart=0;
                seq_item.lp_dlpend  =0;
                for (int i=0;i<$size(seq_item.payload);i++)begin
                    start_item(seq_item);
                    seq_item.lp_data=seq_item.payload[i];
                    if(i==0)begin
                        seq_item.lp_tlpstart=64'h8000000000000000;
                    end
                    else if(i == $size(seq_item.payload)-1)begin
                        seq_item.lp_tlpend  =64'h0001000000000000;
                        seq_item.lp_dlpstart=64'h0000800000000000;
                        seq_item.lp_dlpend  =64'h0000010000000000;
                    end
                    else begin
                        seq_item.lp_tlpstart=0;

                    end
                    finish_item(seq_item);
            end


            // send DLLP_TLP_MIN sequence 
            `uvm_info(get_type_name() ,"  DLLP_TLP_MIN sequence ",UVM_LOW)

                assert(seq_item.randomize() with { payload.size()==1 ;});
                start_item(seq_item);
                    seq_item.lp_tlpstart=64'h8000000000000000;
                    seq_item.lp_tlpend  =64'h0010000000000000;
                    seq_item.lp_dlpstart=64'h0008000000000000;
                    seq_item.lp_dlpend  =64'h0000100000000000;
                finish_item(seq_item); 

            // send Different_size_DLLP_TLP sequence 
            `uvm_info(get_type_name() ,"  Different_size_DLLP_TLP sequence U",UVM_LOW) 

            assert(seq_item.randomize() with { payload.size()==10 ;});
                seq_item.lp_tlpstart=0;
                seq_item.lp_tlpend  =0;
                seq_item.lp_dlpstart=0;
                seq_item.lp_dlpend  =0;
                for (int i=0;i<$size(seq_item.payload);i++)begin
                    start_item(seq_item);
                    seq_item.lp_data=seq_item.payload[i];
                    if(i==0)begin
                        seq_item.lp_tlpstart=64'h8000000000000000;
                        seq_item.lp_tlpend  =64'h0000000000000002;
                        seq_item.lp_dlpstart=64'h0000000000000001;
                    end
                    else if(i == 1)begin
                        seq_item.lp_tlpend  =0;
                        seq_item.lp_dlpstart=0;
                        seq_item.lp_dlpend  =64'h0200000000000000;
                        seq_item.lp_tlpstart=64'h0000000800000000;
                    end
                    else if(i == 5) begin
                        seq_item.lp_tlpstart=0;
                        seq_item.lp_tlpend  =64'h0010000000000000;
                        seq_item.lp_dlpstart=64'h0000800080040000;
                        seq_item.lp_dlpend  =64'h0000010001000800;
                    end
                    else if(i == 6) begin
                        seq_item.lp_tlpstart=64'h0080000000000000;
                        seq_item.lp_tlpend  =0;
                        seq_item.lp_dlpstart=0;
                        seq_item.lp_dlpend  =0;
                    end
                    else if(i == 9) begin
                        seq_item.lp_tlpstart=0;
                        seq_item.lp_tlpend  =64'h0080000000000040;;

                    end
                    else begin
                        seq_item.lp_tlpstart=0;
                        seq_item.lp_tlpend  =0;
                        seq_item.lp_dlpstart=0;
                        seq_item.lp_dlpend  =0;

                    end
                    finish_item(seq_item);
            end*/


    endtask
endclass