
class Reset_LTSSM2_seq extends uvm_sequence #(LPIF_seq_item) ;
        `uvm_object_utils(Reset_LTSSM2_seq)

        LPIF_seq_item LPIF_seq_item_h;
        function new(string name ="Reset_LTSSM2_seq");
            super.new(name);
        endfunction

        task body();
            LPIF_seq_item_h=LPIF_seq_item::type_id::create("item");
            start_item(LPIF_seq_item_h);
                LPIF_seq_item_h.operation = 2'b00;
            finish_item(LPIF_seq_item_h);

            
            
        endtask 
endclass



class Force_detect_LTSSM2_seq extends uvm_sequence #(LPIF_seq_item) ;
        `uvm_object_utils(Force_detect_LTSSM2_seq)

        LPIF_seq_item LPIF_seq_item_h;
        function new(string name ="Force_detect_LTSSM2_seq");
            super.new(name);
        endfunction

        task body();
            LPIF_seq_item_h=LPIF_seq_item::type_id::create("item2");
            start_item(LPIF_seq_item_h);
                LPIF_seq_item_h.operation = 2'b10;
            finish_item(LPIF_seq_item_h);

            
            
        endtask 
endclass