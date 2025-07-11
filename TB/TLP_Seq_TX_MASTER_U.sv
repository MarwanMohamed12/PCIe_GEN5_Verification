class TLP_Seq_TX_MASTER_U extends uvm_sequence #(LPIF_seq_item);
`uvm_object_utils(TLP_Seq_TX_MASTER_U)

LPIF_seq_item seq_item;

static bit [63:0] ending;
function new (string name = "TLP_Seq_TX_MASTER_U");
    super.new(name);
endfunction

    task body ();

        seq_item = LPIF_seq_item::type_id::create("seq_item");
        seq_item.constraint_mode(0);
        // for max size 

        /*`uvm_info(get_type_name() ," drive MAX size TLP sequence in TX Master U ",UVM_LOW)
        // Set the seed for randomization
        // Set the seed manually
 
       

        // Apply constraints and randomize
        assert(seq_item.randomize() with {
            payload.size==65;
            lp_tlpstart==64'h8000000000000000;
            lp_tlpend  ==64'h0001000000000000;
            lp_dlpstart==0;
            lp_dlpend  ==0;
        });


        ending=seq_item.lp_tlpend; //take the place for end byte
        
        if($size(seq_item.payload)==1)begin
            start_item(seq_item);
            finish_item(seq_item);
        end
        else begin
            for (int i=0;i<$size(seq_item.payload);i++)begin
                start_item(seq_item);
                seq_item.lp_data=seq_item.payload[i];
                if(i==0)begin
                    
                    seq_item.lp_tlpend=0;
                end
                else if(i == $size(seq_item.payload)-1)begin
                    seq_item.lp_tlpend=ending;
                    seq_item.lp_tlpstart=0;
                    seq_item.lp_valid='b1;
                end
                else begin
                seq_item.lp_tlpstart=0;
                seq_item.lp_tlpend=0;
                end

                finish_item(seq_item);
            end
        end
        // for min size 3dw
        `uvm_info(get_type_name() ," drive MIN size TLP sequence in TX Master U ",UVM_LOW)
        start_item(seq_item);
            assert(seq_item.randomize() with {
                payload.size==1;
                lp_tlpstart==64'h8000000000000000;
                lp_tlpend  ==64'h0010000000000000;
                lp_dlpstart==0;
                lp_dlpend  ==0;
            });
        finish_item(seq_item);

        seq_item.TLP_const.constraint_mode(1);
        //send different TLP_Size
        `uvm_info(get_type_name() ," drive Different size TLP sequence in TX Master U ",UVM_LOW)
         repeat (5)begin

            assert(seq_item.randomize() with{ payload.size > 1 ;} );
            ending=seq_item.lp_tlpend; //take the place for end byte
            
            if($size(seq_item.payload)==1)begin
                start_item(seq_item);
                finish_item(seq_item);
            end
            else begin
                for (int i=0;i<$size(seq_item.payload);i++)begin
                    start_item(seq_item);
                    seq_item.lp_data=seq_item.payload[i];
                    if(i==0)begin
                        seq_item.lp_tlpend=0;
                    end
                    else if(i == $size(seq_item.payload)-1)begin
                        seq_item.lp_tlpend=ending;
                        seq_item.lp_tlpstart=0;
                        seq_item.lp_valid='b1;
                    end
                    else begin
                    seq_item.lp_tlpstart=0;
                    seq_item.lp_tlpend=0;
                    end
                    finish_item(seq_item);
                end
            end
        end   */   
        
        //send Different_TLP_In_one_transfer
        seq_item.TLP_const.constraint_mode(1);
        
        `uvm_info(get_type_name() ," drive Different size TLP  in one transfer sequence in TX Master U ",UVM_LOW)

//random size
            repeat (900)begin
                start_item(seq_item);
                    assert(seq_item.randomize() with {
                        payload.size==1;});
                finish_item(seq_item);
            end
            
            
//max size            
            repeat (100)begin
                start_item(seq_item);
                    assert(seq_item.randomize() with { payload.size()==1 ; no_of_tlp ==1 ; tlp_size[0]==64;});
                finish_item(seq_item);
            end
            
            
    endtask

endclass

