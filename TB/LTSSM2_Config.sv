
class LTSSM2_Config extends uvm_object;

`uvm_object_utils(LTSSM2_Config)


virtual LPIF_if LPIF_vif_h;
event force_detect_trigger;
uvm_active_passive_enum active = UVM_ACTIVE;

bit Has_Coverage_Collector = 1;



function new (string name = "LTSSM2_Config");
  
   super.new(name);
  
endfunction



endclass