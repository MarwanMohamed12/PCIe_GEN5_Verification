class TX_Slave_Config extends uvm_object;



`uvm_object_utils(TX_Slave_Config)



virtual PIPE_if PIPE_vif_h;

uvm_active_passive_enum active = UVM_ACTIVE;

bit Has_Coverage_Collector = 1;


event Receiver_Detected;
event Received_TS2_in_Polling_Configuration;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS1_in_Config_Lanenum_Wait;
event Received_2_TS1_in_Config_Lanenum_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;
event Received_2_TS2_in_Config_Lanenum_Accept;
event Received_TS2_in_Config_Complete;
event Received_Idle_in_Config_Idle;
event LinkUp_Completed_USD;
event Received_TS1_in_L0 ;
event Received_TS1_in_recoveryRcvrLock_Substate;
event Received_TS2_in_recoveryRcvrCfg_Substate ;
event Received_TS1_in_recoveryRcvrCfg_Substate ;
event Device_on_electrical_ideal;
event Received_IDLE_in_recoveryIdle_Substate;
event Received_TS1_in_recoveryIdle_Substate;
event Received_TS1_in_phase0;
event Received_TS1_in_phase1; 

event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed;
event Polling_Configuration_Substate_Completed;
event Config_Link_Width_Start_Substate_Completed;
event L0_state_completed;
event recoveryRcvrLock_Substate_Completed;
event recoveryRcvrCfg_Substate_Completed;
event recoverySpeed_Substate_Completed;
event phase0_Substate_Completed;
event phase1_Substate_Completed;
event recoveryIdle_Substate_Completed;
event Time_out_D;
event Time_out_U;
	
event force_detect_trigger ;

function new (string name = "TX_Slave_Config");
  
   super.new(name);
  
endfunction



endclass