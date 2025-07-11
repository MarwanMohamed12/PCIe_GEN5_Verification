
`timescale  1ns/1ns

class Inject_Error_vseq  extends uvm_sequence #(PIPE_seq_item) ;
  
`uvm_object_utils(Inject_Error_vseq)


PIPE_seq_item PIPE_Item_h;

polling_active_error_seq 		polling_active_error_seq_D,polling_active_error_seq_U;
polling_config_error_seq 		polling_config_error_seq_D,polling_config_error_seq_U;

Config_Link_Width_Start_seq 	Config_Link_Width_Start_seq_U,Config_Link_Width_Start_seq_D;
Config_Link_Width_Accept_seq 	Config_Link_Width_Accept_seq_U,Config_Link_Width_Accept_seq_D;
Config_Lanenum_Wait_seq 		Config_Lanenum_Wait_seq_U,Config_Lanenum_Wait_seq_D;
Config_Lanenum_Accept_seq 		Config_Lanenum_Accept_seq_U,Config_Lanenum_Accept_seq_D;

Config_Lanenum_Accept_in_Up_seq Config_Lanenum_Accept_in_Up_seq_U,Config_Lanenum_Accept_in_Up_seq_D ;

Config_Complete_seq_in_up 		Config_Complete_seq_in_up_U,Config_Complete_seq_in_up_D;
Config_Complete_seq_in_down 	Config_Complete_seq_in_down_U,Config_Complete_seq_in_down_D;

Config_Idle_seq 				Config_Idle_seq_U,Config_Idle_seq_D;


Recovery_RcvrLock_seq 			Recovery_RcvrLock_seq_U,Recovery_RcvrLock_seq_D;
Recovery_RcvrCfg_seq 			Recovery_RcvrCfg_seq_D,Recovery_RcvrCfg_seq_U;
Recovery_RcvrCfg2_seq			Recovery_RcvrCfg2_seq_D,Recovery_RcvrCfg2_seq_U;

Phase0_seq 						Phase0_seq_U,Phase0_seq_D;
phase1_seq						phase1_seq_D,phase1_seq_U;

Recovery_speed_seq  			Recovery_speed_seq_D,Recovery_speed_seq_U;
Recovery_Idle_seq 				Recovery_Idle_seq_U,Recovery_Idle_seq_D;



LTSSM1_D_Sequencer sqr_u1;
LTSSM1_U_Sequencer sqr_u2;

set_preset_seq 					set_preset_seq_U,set_preset_seq_D;

Reset_LTSSM1_seq reset_seq_D,reset_seq_U;

function new (string name = "Inject_Error_vseq");
		super.new (name);
	endfunction


task body ();

	PIPE_Item_h = PIPE_seq_item::type_id::create("seq_item");

  	set_preset_seq_U = set_preset_seq::type_id::create("set_preset_seq_");
	set_preset_seq_D = set_preset_seq::type_id::create("set_preset_seq_"); 

	reset_seq_D = Reset_LTSSM1_seq::type_id::create("reset_seq_D");
	reset_seq_U = Reset_LTSSM1_seq::type_id::create("reset_seq_U");

	polling_active_error_seq_D = polling_active_error_seq::type_id::create("polling_active_error_seq_D");  
	polling_active_error_seq_U = polling_active_error_seq::type_id::create("polling_active_error_seq_U");  

	polling_config_error_seq_D = polling_config_error_seq::type_id::create("polling_config_error_seq_D");
	polling_config_error_seq_U = polling_config_error_seq::type_id::create("polling_config_error_seq_U");

	Config_Link_Width_Start_seq_D = Config_Link_Width_Start_seq::type_id::create("Config_Link_Width_Start_seq_D");
	Config_Link_Width_Start_seq_U = Config_Link_Width_Start_seq::type_id::create("Config_Link_Width_Start_seq_U");

	Config_Link_Width_Accept_seq_D = Config_Link_Width_Accept_seq::type_id::create("Config_Link_Width_Accept_seq_D");
	Config_Link_Width_Accept_seq_U = Config_Link_Width_Accept_seq::type_id::create("Config_Link_Width_Accept_seq_U");

	Config_Lanenum_Wait_seq_D = Config_Lanenum_Wait_seq::type_id::create("Config_Lanenum_Wait_seq_D");
	Config_Lanenum_Wait_seq_U = Config_Lanenum_Wait_seq::type_id::create("Config_Lanenum_Wait_seq_U");

	Config_Lanenum_Accept_seq_D = Config_Lanenum_Accept_seq::type_id::create("Config_Lanenum_Accept_seq_D");
	Config_Lanenum_Accept_seq_U = Config_Lanenum_Accept_seq::type_id::create("Config_Lanenum_Accept_seq_U");


	Config_Lanenum_Accept_in_Up_seq_D = Config_Lanenum_Accept_in_Up_seq::type_id::create("Config_Lanenum_Accept_in_Up_seq_D");
	Config_Lanenum_Accept_in_Up_seq_U = Config_Lanenum_Accept_in_Up_seq::type_id::create("Config_Lanenum_Accept_in_Up_seq_U");

	Config_Complete_seq_in_up_D = Config_Complete_seq_in_up::type_id::create("Config_Complete_seq_in_up_D");
	Config_Complete_seq_in_up_U = Config_Complete_seq_in_up::type_id::create("Config_Complete_seq_in_up_U");

	Config_Complete_seq_in_down_D = Config_Complete_seq_in_down::type_id::create("Config_Complete_seq_in_down_D");
	Config_Complete_seq_in_down_U = Config_Complete_seq_in_down::type_id::create("Config_Complete_seq_in_down_U");

	Config_Idle_seq_D = Config_Idle_seq::type_id::create("Config_Idle_seq_D");
	Config_Idle_seq_U = Config_Idle_seq::type_id::create("Config_Idle_seq_U");

	Recovery_RcvrCfg_seq_D = Recovery_RcvrCfg_seq::type_id::create("Recovery_RcvrCfg_seq_D");
	Recovery_RcvrCfg_seq_U = Recovery_RcvrCfg_seq::type_id::create("Recovery_RcvrCfg_seq_U");

	Recovery_RcvrCfg2_seq_D = Recovery_RcvrCfg2_seq::type_id::create("Recovery_RcvrCfg2_seq_D");
	Recovery_RcvrCfg2_seq_U = Recovery_RcvrCfg2_seq::type_id::create("Recovery_RcvrCfg2_seq_U");

	Recovery_speed_seq_D = Recovery_speed_seq::type_id::create("Recovery_speed_seq_D");
	Recovery_speed_seq_U = Recovery_speed_seq::type_id::create("Recovery_speed_seq_U");

	phase1_seq_D = phase1_seq::type_id::create("phase1_seq_D");
	phase1_seq_U = phase1_seq::type_id::create("phase1_seq_U");

	Recovery_RcvrLock_seq_D = Recovery_RcvrLock_seq::type_id::create("Recovery_RcvrLock_seq_D");
	Recovery_RcvrLock_seq_U = Recovery_RcvrLock_seq::type_id::create("Recovery_RcvrLock_seq_U");

	Phase0_seq_D = Phase0_seq::type_id::create("Phase0_seq_D");
	Phase0_seq_U = Phase0_seq::type_id::create("Phase0_seq_U");

	Recovery_Idle_seq_D = Recovery_Idle_seq::type_id::create("Recovery_Idle_seq_D");
	Recovery_Idle_seq_U = Recovery_Idle_seq::type_id::create("Recovery_Idle_seq_U");


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	#(`Time_between_sequence);
	$display("------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------2- start polling active error Injection sequence ----------------",UVM_LOW)
	$display("------------------------------------------------------------------------------");


    fork
		polling_active_error_seq_D.start(sqr_u1);

		polling_active_error_seq_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------3- start config active error Injection sequence ----------------",UVM_LOW)
	$display("------------------------------------------------------------------------------");

	#(`Time_between_sequence);

	fork
		polling_config_error_seq_D.start(sqr_u1);

		polling_config_error_seq_U.start(sqr_u2);
	join


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------4- start config Link Width Start error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#5000000;
	fork
		Config_Link_Width_Start_seq_D.start(sqr_u1);

		Config_Link_Width_Start_seq_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------6-Config Lanenum Wait error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);


	/*fork    //error
		Config_Link_Width_Accept_seq_D.start(sqr_u1);

		Config_Link_Width_Accept_seq_U.start(sqr_u2);
	join
	wait( PIPE_Item_h.Current_Substate_D == `Detect_Quiet );*/

	
	fork
		Config_Lanenum_Wait_seq_D.start(sqr_u1);

		Config_Lanenum_Wait_seq_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------7.1- start Config Lanenum Accept error In down Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);

	fork
		Config_Lanenum_Accept_seq_D.start(sqr_u1); 

		Config_Lanenum_Accept_seq_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	/*$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------7.2- start Config Lanenum Accept error in Up Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);

	fork
		Config_Lanenum_Accept_in_Up_seq_D.start(sqr_u1); //error

		Config_Lanenum_Accept_in_Up_seq_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );*/


	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------8,1-start Config Complete error Injection sequence in Down stream Device ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");


	#(`Time_between_sequence);

	fork
		Config_Complete_seq_in_down_D.start(sqr_u1);

		Config_Complete_seq_in_down_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );


	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------8,2-start Config Complete error Injection sequence in Up stream Device ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");


	#(`Time_between_sequence);

	fork
		Config_Complete_seq_in_up_D.start(sqr_u1);

		Config_Complete_seq_in_up_U.start(sqr_u2);
	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

 
	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------9-start Config Idle error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#6000000;

	fork
		Config_Idle_seq_D.start(sqr_u1);

		Config_Idle_seq_U.start(sqr_u2);
	join

	#(`Time_between_sequence);


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------11-start Recovery RcvrLock error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);

	fork
		Recovery_RcvrLock_seq_D.start(sqr_u1);

		Recovery_RcvrLock_seq_U.start(sqr_u2);
	join


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------start reset sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	fork
		reset_seq_D.start(sqr_u1);
	
		reset_seq_U.start(sqr_u2);

	join


	#1000000;

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ," ---------------12-start Recovery RcvrCfg error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");



	fork
		Recovery_RcvrCfg_seq_D.start(sqr_u1);

		Recovery_RcvrCfg_seq_U.start(sqr_u2);
	join


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------13-start Recovery speed error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);

	fork
		Recovery_speed_seq_D.start(sqr_u1);

		Recovery_speed_seq_U.start(sqr_u2);
	join


	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active  );

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------14-start phase1 error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);
	fork
		phase1_seq_D.start(sqr_u1);

		phase1_seq_U.start(sqr_u2);
	join


	wait( PIPE_Item_h.Current_Substate_D == `Recovery_Speed);

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------start reset sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	fork
		reset_seq_D.start(sqr_u1);
	
		reset_seq_U.start(sqr_u2);

	join

	#(`Time_between_sequence);

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active);

	$display("---------------------------------------------------------------------------------------");
    `uvm_info(get_type_name() ,"---------------18-start Recovery Idle error Injection sequence ----------------",UVM_LOW)
	$display("---------------------------------------------------------------------------------------");

	#(`Time_between_sequence);


	fork
		Recovery_Idle_seq_D.start(sqr_u1);

		Recovery_Idle_seq_U.start(sqr_u2);
	join


	wait(PIPE_Item_h.Current_Substate_D == `Recovery_RcvrLock);

	fork

		set_preset_seq_D.start(sqr_u1);

		set_preset_seq_U.start(sqr_u2);

	join

	wait( PIPE_Item_h.Current_Substate_D == `Detect_Active );


endtask


endclass