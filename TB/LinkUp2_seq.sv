
class LinkUp2_seq extends uvm_sequence #(LPIF_seq_item) ;
        `uvm_object_utils(LinkUp2_seq)

        LPIF_seq_item LPIF_seq_item_h;
        function new(string name ="LinkUp2_seq");
            super.new(name);
        endfunction

        task body();
            LPIF_seq_item_h=LPIF_seq_item::type_id::create("item");
            start_item(LPIF_seq_item_h);
            LPIF_seq_item_h.operation=2'b01;
            finish_item(LPIF_seq_item_h);
        endtask
endclass


