class LTSSM2_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(LTSSM2_seq_item) 


bit lpreset; 
bit[3:0] lp_state_req;
bit[3:0] pl_state_sts;
bit[2:0] pl_speedmode;
bit lp_force_detect;
bit pl_linkUp;

bit[1:0] operation;

static bit set_reset ;

function new(string name = "LTSSM2_seq_item");
    super.new(name);
endfunction

endclass