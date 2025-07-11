class Reset_vseq  extends uvm_sequence #(PIPE_seq_item) ;
        `uvm_object_utils(Reset_vseq)

        LTSSM2_D_Sequencer sqr_u1;
        LTSSM2_U_Sequencer sqr_u2;

        PIPE_seq_item PIPE_Item_h;

        Reset_LTSSM2_seq reset_seq_D,reset_seq_U;
        Force_detect_LTSSM2_seq  force_detect_u,force_detect_d ;

        LPIF_seq_item            LPIF_seq_item_h;

        int number_of_reset   ;

        function new(string name ="Reset_vseq");
            super.new(name);
        endfunction

        task body();

            PIPE_Item_h = PIPE_seq_item::type_id::create("seq_item");

            reset_seq_D = Reset_LTSSM2_seq::type_id::create("reset_seq_D");
            reset_seq_U = Reset_LTSSM2_seq::type_id::create("reset_seq_U");
            
            force_detect_u=Force_detect_LTSSM2_seq::type_id::create("force_detect_u");
            force_detect_d=Force_detect_LTSSM2_seq::type_id::create("force_detect_d");
            
                fork

                force_detect_d.start(sqr_u1);
                
                force_detect_u.start(sqr_u2);

                join
                
            repeat(4)begin

                wait(LPIF_seq_item_h.set_reset);
                LPIF_seq_item_h.set_reset =0;
                number_of_reset++;
                #1000000;

                    fork

                    reset_seq_D.start(sqr_u1);
                    
                    reset_seq_U.start(sqr_u2);

                    join
         
            end

            
        endtask 
endclass