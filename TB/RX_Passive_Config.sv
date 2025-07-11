class RX_Passive_Config extends uvm_object;



`uvm_object_utils(RX_Passive_Config)



virtual LPIF_if LPIF_vif_h;


uvm_active_passive_enum active = UVM_PASSIVE;


bit Has_Coverage_Collector = 1;



function new (string name = "RX_Passive_Config");
  
   super.new(name);
  
endfunction



endclass