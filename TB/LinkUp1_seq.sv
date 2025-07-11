class linkup_seq1 extends uvm_sequence #(PIPE_seq_item);
`uvm_object_utils(linkup_seq1)

PIPE_seq_item seq_item;

function new (string name = "linkup_seq1");

    super.new(name);

endfunction

task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);

        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = 100;
        seq_item.substate_error_in_Up = 100;
        
    finish_item(seq_item);

endtask

endclass

