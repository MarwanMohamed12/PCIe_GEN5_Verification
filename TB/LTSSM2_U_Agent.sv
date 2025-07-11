class LTSSM2_U_Agent extends uvm_agent;
  
`uvm_component_utils(LTSSM2_U_Agent)

LTSSM2_Config          LTSSM2_Config_h;
LTSSM2_U_Monitor       LTSSM2_U_Monitor_h;
LTSSM2_U_Driver        LTSSM2_U_Driver_h;
LTSSM2_U_Sequencer     LTSSM2_U_Sequencer_h;

uvm_analysis_port #(LTSSM2_seq_item) send_ap;



extern function new(string name="LTSSM2_U_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);




endclass





function LTSSM2_U_Agent::new(string name="LTSSM2_U_Agent",uvm_component parent);
            super.new(name,parent);
endfunction




function void LTSSM2_U_Agent::build_phase(uvm_phase phase);
  
            super.build_phase(phase);
            LTSSM2_U_Monitor_h   = LTSSM2_U_Monitor::type_id::create("LTSSM2_U_Monitor_h",this);
            LTSSM2_U_Driver_h    = LTSSM2_U_Driver::type_id::create("LTSSM2_U_Driver_h",this);
            LTSSM2_U_Sequencer_h = LTSSM2_U_Sequencer::type_id::create("LTSSM2_U_Sequencer_h",this);
            send_ap              = new("send_ap",this);

            if(! uvm_config_db #(LTSSM2_Config)::get(this,"*","LTSSM2_U_Config_h",LTSSM2_Config_h))
                `uvm_fatal("build_phase","Can't get LTSSM2_U configuration object");

endfunction





function void LTSSM2_U_Agent::connect_phase(uvm_phase phase);
  
            super.connect_phase(phase);
            
            LTSSM2_U_Driver_h.seq_item_port.connect(LTSSM2_U_Sequencer_h.seq_item_export);
            LTSSM2_U_Driver_h.LPIF_vif_h = LTSSM2_Config_h.LPIF_vif_h;
            
            LTSSM2_U_Monitor_h.LPIF_vif_h = LTSSM2_Config_h.LPIF_vif_h;
            LTSSM2_U_Monitor_h.send_ap.connect(send_ap);
            
endfunction
