class RX_Slave_U_Agent extends uvm_agent;
 
  
`uvm_component_utils(RX_Slave_U_Agent)

RX_Slave_Config        RX_Slave_U_Config_h;
RX_Slave_U_Monitor     RX_Slave_U_Monitor_h;
RX_Slave_U_Driver      RX_Slave_U_Driver_h;

uvm_analysis_port #(PIPE_seq_item) send_ap;
uvm_analysis_port #(PIPE_seq_item) receive_ap;






extern function new(string name="RX_Slave_U_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
 



endclass







function RX_Slave_U_Agent::new(string name="RX_Slave_U_Agent",uvm_component parent);
  
     super.new(name,parent);

endfunction




function void RX_Slave_U_Agent::build_phase(uvm_phase phase);
  
    super.build_phase(phase);

    RX_Slave_U_Monitor_h = RX_Slave_U_Monitor::type_id::create("RX_Slave_U_Monitor_h",this);
    RX_Slave_U_Driver_h = RX_Slave_U_Driver::type_id::create("RX_Slave_U_Driver_h",this);   

    if(!uvm_config_db#(RX_Slave_Config)::get(this,"","RX_Slave_U_Config_h",RX_Slave_U_Config_h))
                   `uvm_fatal(get_type_name(),"Can't be able to get TX_Slave_U configuration object")
                       
    send_ap = new("send_ap",this);
    receive_ap = new("receive_ap",this);
    
endfunction






function void RX_Slave_U_Agent::connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    receive_ap.connect(this.RX_Slave_U_Driver_h.receive_TLM_FIFO.analysis_export);
    RX_Slave_U_Monitor_h.send_ap.connect(this.send_ap);
    
    RX_Slave_U_Monitor_h.PIPE_vif_h = RX_Slave_U_Config_h.PIPE_vif_h;
    RX_Slave_U_Driver_h.PIPE_vif_h = RX_Slave_U_Config_h.PIPE_vif_h;
    
    RX_Slave_U_Monitor_h.Received_TS2_in_Polling_Configuration           = RX_Slave_U_Config_h.Received_TS2_in_Polling_Configuration;
    RX_Slave_U_Monitor_h.Received_2_TS1_in_Config_Link_Width_Start       = RX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Start;  
    RX_Slave_U_Monitor_h.Received_2_TS1_in_Config_Link_Width_Accept      = RX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Accept;            
    RX_Slave_U_Monitor_h.Received_2_TS2_in_Config_Lanenum_Wait           = RX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Wait;
    RX_Slave_U_Monitor_h.Received_2_TS2_in_Config_Lanenum_Accept         = RX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Accept;
    RX_Slave_U_Monitor_h.Received_TS2_in_Config_Complete                 = RX_Slave_U_Config_h.Received_TS2_in_Config_Complete;
    RX_Slave_U_Monitor_h.Received_Idle_in_Config_Idle                    = RX_Slave_U_Config_h.Received_Idle_in_Config_Idle;
    
    RX_Slave_U_Monitor_h.LinkUp_Completed_USD                            = RX_Slave_U_Config_h.LinkUp_Completed_USD;
    RX_Slave_U_Monitor_h.Received_TS1_in_L0                              = RX_Slave_U_Config_h.Received_TS1_in_L0;
    RX_Slave_U_Monitor_h.Received_TS1_in_recoveryRcvrLock_Substate       = RX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrLock_Substate;
    RX_Slave_U_Monitor_h.Received_TS2_in_recoveryRcvrCfg_Substate        = RX_Slave_U_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate;
    RX_Slave_U_Monitor_h.Received_TS1_in_recoveryRcvrCfg_Substate        = RX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrCfg_Substate;
    RX_Slave_U_Monitor_h.Device_on_electrical_ideal                      = RX_Slave_U_Config_h.Device_on_electrical_ideal;
    RX_Slave_U_Monitor_h.Received_IDLE_in_recoveryIdle_Substate          = RX_Slave_U_Config_h.Received_IDLE_in_recoveryIdle_Substate;
    RX_Slave_U_Monitor_h.Received_TS1_in_recoveryIdle_Substate           = RX_Slave_U_Config_h.Received_TS1_in_recoveryIdle_Substate;
    RX_Slave_U_Monitor_h.Received_TS1_in_phase0                          = RX_Slave_U_Config_h.Received_TS1_in_phase0;
    RX_Slave_U_Monitor_h.Received_TS1_in_phase1                          = RX_Slave_U_Config_h.Received_TS1_in_phase1;
    

    RX_Slave_U_Monitor_h.Config_Complete_Substate_Completed             = RX_Slave_U_Config_h.Config_Complete_Substate_Completed;
    RX_Slave_U_Monitor_h.Polling_Active_Substate_Completed              = RX_Slave_U_Config_h.Polling_Active_Substate_Completed;
    RX_Slave_U_Monitor_h.Polling_Configuration_Substate_Completed       = RX_Slave_U_Config_h.Polling_Configuration_Substate_Completed;
    RX_Slave_U_Monitor_h.Config_Link_Width_Start_Substate_Completed     = RX_Slave_U_Config_h.Config_Link_Width_Start_Substate_Completed;   

    RX_Slave_U_Monitor_h.L0_state_completed                             = RX_Slave_U_Config_h.L0_state_completed;
    RX_Slave_U_Monitor_h.recoveryRcvrLock_Substate_Completed            = RX_Slave_U_Config_h.recoveryRcvrLock_Substate_Completed;
    RX_Slave_U_Monitor_h.recoveryRcvrCfg_Substate_Completed             = RX_Slave_U_Config_h.recoveryRcvrCfg_Substate_Completed;
    RX_Slave_U_Monitor_h.recoverySpeed_Substate_Completed               = RX_Slave_U_Config_h.recoverySpeed_Substate_Completed;   
    RX_Slave_U_Monitor_h.phase0_Substate_Completed                      = RX_Slave_U_Config_h.phase0_Substate_Completed;
    RX_Slave_U_Monitor_h.phase1_Substate_Completed                      = RX_Slave_U_Config_h.phase1_Substate_Completed;
    RX_Slave_U_Monitor_h.recoveryIdle_Substate_Completed                = RX_Slave_U_Config_h.recoveryIdle_Substate_Completed;

	RX_Slave_U_Monitor_h.Time_out_U                                     = RX_Slave_U_Config_h.Time_out_U ;
    RX_Slave_U_Monitor_h.force_detect_trigger                           = RX_Slave_U_Config_h.force_detect_trigger;


endfunction





task RX_Slave_U_Agent::run_phase(uvm_phase phase);
  
    super.run_phase(phase);

endtask
