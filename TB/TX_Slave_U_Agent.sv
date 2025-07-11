class TX_Slave_U_Agent extends uvm_agent;
  
  
`uvm_component_utils(TX_Slave_U_Agent)


TX_Slave_Config           TX_Slave_U_Config_h;
TX_Slave_U_Monitor        TX_Slave_U_Monitor_h;

uvm_analysis_port #(PIPE_seq_item) send_ap1;
uvm_analysis_port #(PIPE_seq_item) send_ap2;




extern function new(string name="TX_Slave_U_Agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);




endclass








function TX_Slave_U_Agent::new(string name="TX_Slave_U_Agent",uvm_component parent);
  
    super.new(name,parent);

endfunction




function void TX_Slave_U_Agent::build_phase(uvm_phase phase);
  
    super.build_phase(phase);
    
    if(!uvm_config_db#(TX_Slave_Config)::get(this,"","TX_Slave_U_Config_h",TX_Slave_U_Config_h))
                   `uvm_fatal(get_type_name(),"Can't be able to get TX_Slave_U configuration object")
                   
    TX_Slave_U_Monitor_h = TX_Slave_U_Monitor::type_id::create("TX_Slave_U_Monitor_h",this);
    
    send_ap1 = new("send_ap1",this);
    send_ap2 = new("send_ap2",this);

endfunction




function void TX_Slave_U_Agent::connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    TX_Slave_U_Monitor_h.send_ap1.connect(this.send_ap1);
    TX_Slave_U_Monitor_h.send_ap2.connect(this.send_ap2);
    
    TX_Slave_U_Monitor_h.PIPE_vif_h = TX_Slave_U_Config_h.PIPE_vif_h; 

    TX_Slave_U_Monitor_h.Receiver_Detected                              = TX_Slave_U_Config_h.Receiver_Detected;
    TX_Slave_U_Monitor_h.Received_TS2_in_Polling_Configuration          = TX_Slave_U_Config_h.Received_TS2_in_Polling_Configuration;
    TX_Slave_U_Monitor_h.Received_2_TS1_in_Config_Link_Width_Start      = TX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Start;
    TX_Slave_U_Monitor_h.Received_2_TS1_in_Config_Link_Width_Accept     = TX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Accept;   
    TX_Slave_U_Monitor_h.Received_2_TS2_in_Config_Lanenum_Wait          = TX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Wait;
    TX_Slave_U_Monitor_h.Received_2_TS2_in_Config_Lanenum_Accept        = TX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Accept;
    TX_Slave_U_Monitor_h.Received_TS2_in_Config_Complete                = TX_Slave_U_Config_h.Received_TS2_in_Config_Complete;
    TX_Slave_U_Monitor_h.Received_Idle_in_Config_Idle                   = TX_Slave_U_Config_h.Received_Idle_in_Config_Idle;
    
    TX_Slave_U_Monitor_h.LinkUp_Completed_USD                           = TX_Slave_U_Config_h.LinkUp_Completed_USD;
    TX_Slave_U_Monitor_h.Received_TS1_in_L0                             = TX_Slave_U_Config_h.Received_TS1_in_L0;
    TX_Slave_U_Monitor_h.Received_TS1_in_recoveryRcvrLock_Substate      = TX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrLock_Substate;
    TX_Slave_U_Monitor_h.Received_TS2_in_recoveryRcvrCfg_Substate       = TX_Slave_U_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate;   
    TX_Slave_U_Monitor_h.Received_TS1_in_recoveryRcvrCfg_Substate       = TX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrCfg_Substate;
    TX_Slave_U_Monitor_h.Device_on_electrical_ideal                     = TX_Slave_U_Config_h.Device_on_electrical_ideal;
    TX_Slave_U_Monitor_h.Received_IDLE_in_recoveryIdle_Substate         = TX_Slave_U_Config_h.Received_IDLE_in_recoveryIdle_Substate;
    TX_Slave_U_Monitor_h.Received_TS1_in_recoveryIdle_Substate          = TX_Slave_U_Config_h.Received_TS1_in_recoveryIdle_Substate;
    TX_Slave_U_Monitor_h.Received_2_TS2_in_Config_Lanenum_Accept        = TX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Accept;
    TX_Slave_U_Monitor_h.Received_TS1_in_phase0                         = TX_Slave_U_Config_h.Received_TS1_in_phase0;
    TX_Slave_U_Monitor_h.Received_TS1_in_phase1                         = TX_Slave_U_Config_h.Received_TS1_in_phase1;    
    
    
    TX_Slave_U_Monitor_h.Config_Complete_Substate_Completed             = TX_Slave_U_Config_h.Config_Complete_Substate_Completed;
    TX_Slave_U_Monitor_h.Polling_Active_Substate_Completed              = TX_Slave_U_Config_h.Polling_Active_Substate_Completed;
    TX_Slave_U_Monitor_h.Polling_Configuration_Substate_Completed       = TX_Slave_U_Config_h.Polling_Configuration_Substate_Completed;
    TX_Slave_U_Monitor_h.Config_Link_Width_Start_Substate_Completed     = TX_Slave_U_Config_h.Config_Link_Width_Start_Substate_Completed;
    TX_Slave_U_Monitor_h.L0_state_completed                             = TX_Slave_U_Config_h.L0_state_completed;
    TX_Slave_U_Monitor_h.recoveryRcvrLock_Substate_Completed            = TX_Slave_U_Config_h.recoveryRcvrLock_Substate_Completed;
    TX_Slave_U_Monitor_h.recoveryRcvrCfg_Substate_Completed             = TX_Slave_U_Config_h.recoveryRcvrCfg_Substate_Completed;
    TX_Slave_U_Monitor_h.recoverySpeed_Substate_Completed               = TX_Slave_U_Config_h.recoverySpeed_Substate_Completed;    
    TX_Slave_U_Monitor_h.phase0_Substate_Completed                      = TX_Slave_U_Config_h.phase0_Substate_Completed;
    TX_Slave_U_Monitor_h.phase1_Substate_Completed                      = TX_Slave_U_Config_h.phase1_Substate_Completed;
    TX_Slave_U_Monitor_h.recoveryIdle_Substate_Completed                = TX_Slave_U_Config_h.recoveryIdle_Substate_Completed;


    TX_Slave_U_Monitor_h.Time_out_U                                     = TX_Slave_U_Config_h.Time_out_U ;
    TX_Slave_U_Monitor_h.force_detect_trigger                           = TX_Slave_U_Config_h.force_detect_trigger ;

       
endfunction



task TX_Slave_U_Agent::run_phase(uvm_phase phase);
  
    super.run_phase(phase);

endtask
