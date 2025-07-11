class LTSSM1_Config extends uvm_object;

`uvm_object_utils(LTSSM1_Config)


virtual PIPE_if PIPE_vif_h;

uvm_active_passive_enum active = UVM_ACTIVE;

bit Has_Coverage_Collector = 1;



event Receiver_Detected;


function new (string name = "LTSSM1_Config");
  
   super.new(name);
  
endfunction



endclass