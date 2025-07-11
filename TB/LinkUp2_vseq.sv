
class LinkUp2_vseq extends uvm_sequence #(LPIF_seq_item);

        `uvm_object_utils(LinkUp2_vseq)

        LTSSM2_D_Sequencer sqr_u1;
        LTSSM2_U_Sequencer sqr_u2;

        Reset_LTSSM2_seq         rst_n_U,rst_n_D;
        Force_detect_LTSSM2_seq  force_detect_u,force_detect_d ;

        LinkUp2_seq              LinkUp_U,LinkUp_D;
        LPIF_seq_item            LPIF_seq_item_h;

        int number_of_reset   ;
        function new(string name ="LinkUp2_vseq");
            super.new(name);
        endfunction

        task body();


            LPIF_seq_item_h=LPIF_seq_item::type_id::create("item");

            rst_n_U=Reset_LTSSM2_seq::type_id::create("rst_n_U");
            rst_n_D=Reset_LTSSM2_seq::type_id::create("rst_n_D");

            force_detect_u=Force_detect_LTSSM2_seq::type_id::create("force_detect_u");
            force_detect_d=Force_detect_LTSSM2_seq::type_id::create("force_detect_d");

            LinkUp_U=LinkUp2_seq::type_id::create("LinkUp_U");
            LinkUp_D=LinkUp2_seq::type_id::create("LinkUp_D");
            
          
            rst_n_D.start(sqr_u1);
            rst_n_U.start(sqr_u2);
           
          
            #50;
            
            fork

              LinkUp_D.start(sqr_u1);

              LinkUp_U.start(sqr_u2);

            join

            
        endtask
endclass



