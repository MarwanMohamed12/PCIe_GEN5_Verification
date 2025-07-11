class PCIe_Test  extends uvm_test;



  `uvm_component_utils(PCIe_Test)
  
  virtual PIPE_if PIPE_if_up_t;
  virtual PIPE_if PIPE_if_down_t;

  
  PCIe_Env                     PCIe_Env_h;
  
  Reset_vseq                    Reset_vseq_h;

  LinkUp1_vseq                  LinkUp1_vseq_h;
  LinkUp2_vseq                  LinkUp2_vseq_h;

  DLLP_TLP_vSeq1_TX_MASTER      DLLP_TLP_vSeq1_TX_MASTER_h;
  DLLP_TLP_vSeq2_TX_MASTER      DLLP_TLP_vSeq2_TX_MASTER_h;
  TLP_vSeq_TX_MASTER            TLP_vSeq_TX_MASTER_h;
  DLLP_vSeq_TX_MASTER           DLLP_vSeq_TX_MASTER_h;
 
  TX_Slave_Config               TX_Slave_U_Config_h;
  RX_Slave_Config               RX_Slave_U_Config_h;
  

  LTSSM1_Config                 LTSSM1_U_Config_h;
  LTSSM2_Config                 LTSSM2_U_Config_h;
 

  TX_Slave_Config               TX_Slave_D_Config_h;
  RX_Slave_Config               RX_Slave_D_Config_h;
 

  LTSSM1_Config                 LTSSM1_D_Config_h;
  LTSSM2_Config                 LTSSM2_D_Config_h; 
   
  TX_Master_Config              TX_Master_D_Config_h;
  TX_Master_Config              TX_Master_U_Config_h;

  RX_Passive_Config             RX_Passive_D_Config_h;
  RX_Passive_Config             RX_Passive_U_Config_h;

  Inject_Error_vseq  Inject_Error_vseq_h;
  function new(string name = "PCIe_Test" ,uvm_component parent);
  
  
    super.new(name,parent);
  
    `uvm_info(get_type_name(),"Inside constructor of PCIe Test Class",UVM_LOW)
  
  
  endfunction :new
  
  
  
  
  
  
  
  
  
  function void build_phase(uvm_phase phase);
  
  
    super.build_phase(phase);
    
	 
	 `uvm_info(get_type_name(),"Inside build phase of PCIe Test Class",UVM_LOW)

	 
	 PCIe_Env_h = PCIe_Env::type_id::create("PCIe_Env_h",this);

	 Reset_vseq_h=Reset_vseq::type_id::create("Reset_vseq_h");

     LinkUp1_vseq_h = LinkUp1_vseq::type_id::create("LinkUp1_vseq_h");
	 LinkUp2_vseq_h = LinkUp2_vseq::type_id::create("LinkUp2_vseq_h");
	 Inject_Error_vseq_h=Inject_Error_vseq::type_id::create("Inject_Error_vseq_h");


	 DLLP_vSeq_TX_MASTER_h     = DLLP_vSeq_TX_MASTER::type_id::create("DLLP_vSeq_TX_MASTER_h");
	 TLP_vSeq_TX_MASTER_h      = TLP_vSeq_TX_MASTER::type_id::create("TLP_vSeq_TX_MASTER_h");
	 DLLP_TLP_vSeq1_TX_MASTER_h = DLLP_TLP_vSeq1_TX_MASTER::type_id::create("DLLP_TLP_vSeq1_TX_MASTER_h");
	 DLLP_TLP_vSeq2_TX_MASTER_h = DLLP_TLP_vSeq2_TX_MASTER::type_id::create("DLLP_TLP_vSeq2_TX_MASTER_h");
	 
	 LTSSM1_U_Config_h = LTSSM1_Config::type_id::create("LTSSM1_U_Config_h");
	 LTSSM2_U_Config_h = LTSSM2_Config::type_id::create("LTSSM2_U_Config_h");

	 LTSSM1_D_Config_h = LTSSM1_Config::type_id::create("LTSSM1_D_Config_h");
	 LTSSM2_D_Config_h = LTSSM2_Config::type_id::create("LTSSM2_D_Config_h");

	 TX_Slave_D_Config_h = TX_Slave_Config::type_id::create("TX_Slave_D_Config_h");
	 RX_Slave_D_Config_h = RX_Slave_Config::type_id::create("RX_Slave_D_Config_h");

	 TX_Slave_U_Config_h = TX_Slave_Config::type_id::create("TX_Slave_U_Config_h");
	 RX_Slave_U_Config_h = RX_Slave_Config::type_id::create("RX_Slave_U_Config_h");
	  	  
   TX_Master_D_Config_h=TX_Master_Config::type_id::create("TX_Master_D_Config_h");
	 TX_Master_U_Config_h=TX_Master_Config::type_id::create("TX_Master_U_Config_h");

	 RX_Passive_D_Config_h = RX_Passive_Config::type_id::create("RX_Passive_D_Config_h"); 
	 RX_Passive_U_Config_h = RX_Passive_Config::type_id::create("RX_Passive_U_Config_h"); 
	 
	  
	 if(!uvm_config_db #(virtual PIPE_if)::get(null,"","PIPE_if_U_h",PIPE_if_up_t))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
	 
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",LTSSM1_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",LTSSM2_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",LTSSM1_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",LTSSM2_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

   
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",TX_Master_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")
	 
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",TX_Master_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")

     if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_U_h",RX_Passive_U_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")
	
	 if(!uvm_config_db #(virtual LPIF_if)::get(this,"","LPIF_if_D_h",RX_Passive_D_Config_h.LPIF_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the LPIF interface")
   
   
     if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",PIPE_if_down_t))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")

	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",TX_Slave_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_D_h",RX_Slave_D_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",TX_Slave_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
  
	 if(!uvm_config_db #(virtual PIPE_if)::get(this,"","PIPE_if_U_h",RX_Slave_U_Config_h.PIPE_vif_h))
	          `uvm_fatal(get_type_name(),"can't get the PIPE interface")
     


	 TX_Slave_U_Config_h.Receiver_Detected = LTSSM1_U_Config_h.Receiver_Detected;
	 TX_Slave_D_Config_h.Receiver_Detected = LTSSM1_D_Config_h.Receiver_Detected;
	 
	 RX_Slave_D_Config_h.Received_TS2_in_Polling_Configuration          = TX_Slave_D_Config_h.Received_TS2_in_Polling_Configuration;
	 RX_Slave_D_Config_h.Received_2_TS1_in_Config_Link_Width_Start      = TX_Slave_D_Config_h.Received_2_TS1_in_Config_Link_Width_Start;
	 RX_Slave_D_Config_h.Received_2_TS1_in_Config_Lanenum_Wait          = TX_Slave_D_Config_h.Received_2_TS1_in_Config_Lanenum_Wait;
	 RX_Slave_D_Config_h.Received_2_TS1_in_Config_Lanenum_Accept        = TX_Slave_D_Config_h.Received_2_TS1_in_Config_Lanenum_Accept;
	 RX_Slave_D_Config_h.Received_TS2_in_Config_Complete                = TX_Slave_D_Config_h.Received_TS2_in_Config_Complete;
	 RX_Slave_D_Config_h.Received_Idle_in_Config_Idle                   = TX_Slave_D_Config_h.Received_Idle_in_Config_Idle;
	 RX_Slave_D_Config_h.Received_TS_in_L0_D                            = TX_Slave_D_Config_h.Received_TS1_in_L0;
	 RX_Slave_D_Config_h.Received_TS1_in_recoveryRcvrLock_Substate      = TX_Slave_D_Config_h.Received_TS1_in_recoveryRcvrLock_Substate;
	 RX_Slave_D_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate       = TX_Slave_D_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate;
	 RX_Slave_D_Config_h.recoveryRcvrLock_Substate_Completed            = TX_Slave_D_Config_h.recoveryRcvrLock_Substate_Completed  ;
	 RX_Slave_D_Config_h.recoveryIdle_Substate_Completed                = TX_Slave_D_Config_h.recoveryIdle_Substate_Completed  ; 
	 RX_Slave_D_Config_h.Time_out_D									  	= TX_Slave_D_Config_h.Time_out_D;

	 RX_Slave_U_Config_h.Received_TS2_in_Polling_Configuration          = TX_Slave_U_Config_h.Received_TS2_in_Polling_Configuration;
	 RX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Start      = TX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Start;
	 RX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Accept     = TX_Slave_U_Config_h.Received_2_TS1_in_Config_Link_Width_Accept;
	 RX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Wait          = TX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Wait;
	 RX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Accept        = TX_Slave_U_Config_h.Received_2_TS2_in_Config_Lanenum_Accept;
	 RX_Slave_U_Config_h.Received_TS2_in_Config_Complete                = TX_Slave_U_Config_h.Received_TS2_in_Config_Complete;
	 RX_Slave_U_Config_h.Received_Idle_in_Config_Idle                   = TX_Slave_U_Config_h.Received_Idle_in_Config_Idle;
	 RX_Slave_U_Config_h.LinkUp_Completed_USD                           = TX_Slave_U_Config_h.LinkUp_Completed_USD;
	 RX_Slave_U_Config_h.Received_TS1_in_L0                             = TX_Slave_U_Config_h.Received_TS1_in_L0;
	 RX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrLock_Substate      = TX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrLock_Substate;
	 RX_Slave_U_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate       = TX_Slave_U_Config_h.Received_TS2_in_recoveryRcvrCfg_Substate;
	 RX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrCfg_Substate       = TX_Slave_U_Config_h.Received_TS1_in_recoveryRcvrCfg_Substate;
	 RX_Slave_U_Config_h.Device_on_electrical_ideal                     = TX_Slave_U_Config_h.Device_on_electrical_ideal;
	 RX_Slave_U_Config_h.Received_IDLE_in_recoveryIdle_Substate         = TX_Slave_U_Config_h.Received_IDLE_in_recoveryIdle_Substate;
	 RX_Slave_U_Config_h.Received_TS1_in_recoveryIdle_Substate          = TX_Slave_U_Config_h.Received_TS1_in_recoveryIdle_Substate;
	 RX_Slave_U_Config_h.Received_TS1_in_phase0                         = TX_Slave_U_Config_h.Received_TS1_in_phase0;
	 RX_Slave_U_Config_h.Received_TS1_in_phase1                         = TX_Slave_U_Config_h.Received_TS1_in_phase1;
   
   
	  
     RX_Slave_D_Config_h.Config_Complete_Substate_Completed             =TX_Slave_D_Config_h.Config_Complete_Substate_Completed  ;
	 RX_Slave_D_Config_h.Polling_Active_Substate_Completed              =TX_Slave_D_Config_h.Polling_Active_Substate_Completed  ;
	 RX_Slave_D_Config_h.Polling_Configuration_Substate_Completed       =TX_Slave_D_Config_h.Polling_Configuration_Substate_Completed  ; 
	 RX_Slave_D_Config_h.Config_Link_Width_Start_Substate_Completed     =TX_Slave_D_Config_h.Config_Link_Width_Start_Substate_Completed  ;

	 RX_Slave_D_Config_h.set_reset_In_LPIF								=TX_Master_D_Config_h.set_reset_In_LPIF     ;

	 
	
	 RX_Slave_U_Config_h.Config_Complete_Substate_Completed             =TX_Slave_U_Config_h.Config_Complete_Substate_Completed  ;
	 RX_Slave_U_Config_h.Polling_Active_Substate_Completed              =TX_Slave_U_Config_h.Polling_Active_Substate_Completed  ;
	 RX_Slave_U_Config_h.Polling_Configuration_Substate_Completed       =TX_Slave_U_Config_h.Polling_Configuration_Substate_Completed  ; 
	 RX_Slave_U_Config_h.Config_Link_Width_Start_Substate_Completed     =TX_Slave_U_Config_h.Config_Link_Width_Start_Substate_Completed  ; 
	 RX_Slave_U_Config_h.L0_state_completed                             =TX_Slave_U_Config_h.L0_state_completed  ;
	 RX_Slave_U_Config_h.recoveryRcvrLock_Substate_Completed            =TX_Slave_U_Config_h.recoveryRcvrLock_Substate_Completed  ;

	 RX_Slave_U_Config_h.recoveryRcvrCfg_Substate_Completed             =TX_Slave_U_Config_h.recoveryRcvrCfg_Substate_Completed  ; 
	 RX_Slave_U_Config_h.recoverySpeed_Substate_Completed               =TX_Slave_U_Config_h.recoverySpeed_Substate_Completed  ; 
	 RX_Slave_U_Config_h.phase0_Substate_Completed                      =TX_Slave_U_Config_h.phase0_Substate_Completed  ;
	 RX_Slave_U_Config_h.phase1_Substate_Completed                      =TX_Slave_U_Config_h.phase1_Substate_Completed  ;
	 RX_Slave_U_Config_h.recoveryIdle_Substate_Completed                =TX_Slave_U_Config_h.recoveryIdle_Substate_Completed  ; 

	 RX_Slave_U_Config_h.Time_out_U										=TX_Slave_U_Config_h.Time_out_U ;


	 TX_Slave_D_Config_h.force_detect_trigger 							=LTSSM2_D_Config_h.force_detect_trigger	;
	 TX_Slave_U_Config_h.force_detect_trigger							=LTSSM2_D_Config_h.force_detect_trigger	;
	 RX_Slave_D_Config_h.force_detect_trigger							=LTSSM2_D_Config_h.force_detect_trigger	;
	 RX_Slave_U_Config_h.force_detect_trigger							=LTSSM2_D_Config_h.force_detect_trigger	;
							

	 
   uvm_config_db #(LTSSM1_Config)::set(this,"*","LTSSM1_D_Config_h",LTSSM1_D_Config_h);
   uvm_config_db #(LTSSM2_Config)::set(this,"*","LTSSM2_D_Config_h",LTSSM2_D_Config_h);

   uvm_config_db #(TX_Slave_Config)::set(this,"*","TX_Slave_D_Config_h",TX_Slave_D_Config_h);
   uvm_config_db #(RX_Slave_Config)::set(this,"*","RX_Slave_D_Config_h",RX_Slave_D_Config_h);

   uvm_config_db #(LTSSM1_Config)::set(this,"*","LTSSM1_U_Config_h",LTSSM1_U_Config_h);
   uvm_config_db #(LTSSM2_Config)::set(this,"*","LTSSM2_U_Config_h",LTSSM2_U_Config_h);

   uvm_config_db #(TX_Slave_Config)::set(this,"*","TX_Slave_U_Config_h",TX_Slave_U_Config_h);
   uvm_config_db #(RX_Slave_Config)::set(this,"*","RX_Slave_U_Config_h",RX_Slave_U_Config_h);
   
   uvm_config_db #(TX_Master_Config)::set(this,"*","TX_Master_D_Config_h",TX_Master_D_Config_h);
   uvm_config_db #(TX_Master_Config)::set(this,"*","TX_Master_U_Config_h",TX_Master_U_Config_h);

   uvm_config_db #(RX_Passive_Config)::set(this,"*","RX_Passive_D_Config_h",RX_Passive_D_Config_h);
   uvm_config_db #(RX_Passive_Config)::set(this,"*","RX_Passive_U_Config_h",RX_Passive_U_Config_h);
   
   
   
  endfunction :build_phase 
  
  
  
  
  
  
  
  
  function void connect_phase (uvm_phase phase);
  
  
    super.connect_phase(phase);
	 
	 
	 `uvm_info(get_type_name(),"Inside connect phase of PCIe Test Class",UVM_LOW)
	 

  endfunction :connect_phase
  
  
  
  
  
  
  
  
  
  task  run_phase(uvm_phase phase);
  
  
    super.run_phase(phase);
  
  
	 `uvm_info(get_type_name(),"Inside run phase of PCIe Test Class",UVM_LOW)
  
   
	
	 phase.raise_objection(this);
  
	  	  Reset_vseq_h.sqr_u1  = PCIe_Env_h.LTSSM2_D_Agent_h.LTSSM2_D_Sequencer_h;
		  Reset_vseq_h.sqr_u2  = PCIe_Env_h.LTSSM2_U_Agent_h.LTSSM2_U_Sequencer_h;

	  	  LinkUp1_vseq_h.sqr_u1 = PCIe_Env_h.LTSSM1_D_Agent_h.LTSSM1_D_Sequencer_h;
	  	  LinkUp1_vseq_h.sqr_u2 = PCIe_Env_h.LTSSM1_U_Agent_h.LTSSM1_U_Sequencer_h;
		
		  Inject_Error_vseq_h.sqr_u1 = PCIe_Env_h.LTSSM1_D_Agent_h.LTSSM1_D_Sequencer_h;
          Inject_Error_vseq_h.sqr_u2 = PCIe_Env_h.LTSSM1_U_Agent_h.LTSSM1_U_Sequencer_h;

	  	  LinkUp2_vseq_h.sqr_u1 = PCIe_Env_h.LTSSM2_D_Agent_h.LTSSM2_D_Sequencer_h;
	  	  LinkUp2_vseq_h.sqr_u2 = PCIe_Env_h.LTSSM2_U_Agent_h.LTSSM2_U_Sequencer_h;	
	  	  
 			DLLP_vSeq_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		   DLLP_vSeq_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;

		   TLP_vSeq_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		   TLP_vSeq_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;

		   DLLP_TLP_vSeq1_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		   DLLP_TLP_vSeq1_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ;  	  
		   DLLP_TLP_vSeq2_TX_MASTER_h.sqr_d = PCIe_Env_h.TX_Master_D_Agent_h.TX_Master_D_Sequencer_h ;
		   DLLP_TLP_vSeq2_TX_MASTER_h.sqr_u = PCIe_Env_h.TX_Master_U_Agent_h.TX_Master_U_Sequencer_h ; 

			`uvm_info(get_type_name(),"############### start Linkup Seq ###############",UVM_LOW)
   			PIPE_if_up_t.assertion_enable=1;
			PIPE_if_down_t.assertion_enable=1;

			
	  	 fork
	  	 
	  	         LinkUp1_vseq_h.start(null);
	            LinkUp2_vseq_h.start(null);
	     
	     join
		   
		   	 `uvm_info(get_type_name(),"############### LinkUp Completed Successfully ###############",UVM_LOW)


			`uvm_info(get_type_name(),"############### start send TLP Seq ###############",UVM_LOW)


	  	 	 TLP_vSeq_TX_MASTER_h.start(null);

			`uvm_info(get_type_name(),"############### start send DLLP Seq ###############",UVM_LOW)
			
			 DLLP_vSeq_TX_MASTER_h.start(null);

			`uvm_info(get_type_name(),"############### start send TLP and DLLP Seq ###############",UVM_LOW)
			 DLLP_TLP_vSeq1_TX_MASTER_h.start(null);
			 DLLP_TLP_vSeq2_TX_MASTER_h.start(null);
		


		
		
		
			#5000;
   			PIPE_if_up_t.assertion_enable=0;
			PIPE_if_down_t.assertion_enable=0;

			`uvm_info(get_type_name(),"############### start inject error Seq ###############",UVM_LOW)

			fork
				Reset_vseq_h.start(null);

				Inject_Error_vseq_h.start(null);
			join


			#1000000;	    
	    
	    
	 phase.drop_objection(this);
  
  
  
  
 
  endtask :run_phase
  
  
  
  
  
  
  
  
endclass :PCIe_Test
