class Reset_LTSSM1_seq extends uvm_sequence #(PIPE_seq_item);
  
`uvm_object_utils(Reset_LTSSM1_seq)

PIPE_seq_item seq_item;

function new (string name = "Reset_LTSSM1_seq");

super.new(name);

endfunction

task body ();

seq_item = PIPE_seq_item::type_id::create("seq_item");

start_item(seq_item);
seq_item.operation = 2'b00;
finish_item(seq_item);

endtask

endclass