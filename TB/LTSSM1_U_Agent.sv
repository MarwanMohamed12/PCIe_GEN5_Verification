class LTSSM1_U_Agent  extends uvm_agent;
  
  
`uvm_component_utils(LTSSM1_U_Agent)

uvm_analysis_port #(PIPE_seq_item) send_ap;



LTSSM1_U_Driver          LTSSM1_U_Driver_h;
LTSSM1_U_Sequencer       LTSSM1_U_Sequencer_h; 
//LTSSM1_U_Monitor         LTSSM1_U_Monitor_h;
LTSSM1_Config            LTSSM1_Config_h;





extern function new(string name="LTSSM1_U_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);






endclass








function LTSSM1_U_Agent::new(string name="LTSSM1_U_Agent",uvm_component parent);
  
super.new(name,parent);

endfunction




function void LTSSM1_U_Agent::build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    LTSSM1_U_Driver_h = LTSSM1_U_Driver::type_id::create("LTSSM1_U_Driver_h",this);
    LTSSM1_U_Sequencer_h = LTSSM1_U_Sequencer::type_id::create("LTSSM1_U_Sequencer_h",this);
    //LTSSM1_U_Monitor_h = LTSSM1_U_Monitor::type_id::create("LTSSM1_U_Monitor_h",this);
    send_ap = new("send_ap",this);

    if(!uvm_config_db #(LTSSM1_Config)::get(this,"","LTSSM1_U_Config_h",LTSSM1_Config_h)) begin
        `uvm_fatal(get_type_name(),"failed to get the Config_Obj_LTSSM1!")
    end
    
endfunction





function void LTSSM1_U_Agent::connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    LTSSM1_U_Driver_h.seq_item_port.connect(LTSSM1_U_Sequencer_h.seq_item_export);
    LTSSM1_U_Driver_h.PIPE_vif_h = LTSSM1_Config_h.PIPE_vif_h;
    LTSSM1_U_Driver_h.Receiver_Detected = LTSSM1_Config_h.Receiver_Detected;    
    //LTSSM1_U_Monitor_h.PIPE_vif_h = LTSSM1_Config_h.PIPE_vif_h;
    //LTSSM1_U_Monitor_h.send_ap.connect(send_ap);

endfunction




task LTSSM1_U_Agent::run_phase(uvm_phase phase);
  
    super.run_phase(phase);

endtask
