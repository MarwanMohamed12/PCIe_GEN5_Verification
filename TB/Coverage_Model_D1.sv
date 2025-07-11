`uvm_analysis_imp_decl(_RX_D_port)
`uvm_analysis_imp_decl(_TX_D_port)


class Coverage_Model_D1 extends uvm_component;



`uvm_component_utils(Coverage_Model_D1)


PIPE_seq_item PIPE_seq_item_TX_h,PIPE_seq_item_RX_h;


uvm_analysis_imp_TX_D_port #(PIPE_seq_item,Coverage_Model_D1) TX_imp;
uvm_analysis_imp_RX_D_port #(PIPE_seq_item,Coverage_Model_D1) RX_imp;

extern function new(string name = "Coverage_Model_D1",uvm_component parent);
extern function void  build_phase(uvm_phase phase);
extern function void  connect_phase(uvm_phase phase); 
extern function void  write_TX_D_port(PIPE_seq_item PIPE_seq_item_TX_h); 
extern function void  write_RX_D_port(PIPE_seq_item PIPE_seq_item_RX_h);  


covergroup TX_D_LTSSM_Trans_Cover;

option.per_instance = 1;

LTSSM_Trans_Cover: coverpoint PIPE_seq_item_TX_h.Current_Substate
{
  
bins Detect_Quiet_to_Detect_Active                         = (`Detect_Quiet=>`Detect_Active);
bins Detect_Active_to_Polling_Active                       = (`Detect_Active=>`Polling_Active);
bins Polling_Active_to_Polling_Configuration               = (`Polling_Active=>`Polling_Configuration);
bins Polling_Active_to_Detect_Quiet                        = (`Polling_Active=>`Detect_Quiet);
bins Polling_Configuration_to_Config_Link_Width_Start      = (`Polling_Configuration=>`Config_Link_Width_Start);
bins Config_Link_Width_Start_to_Config_Link_Width_Accept   = (`Config_Link_Width_Start=>`Config_Link_Width_Accept);
//bins Config_Link_Width_Start_to_Config_Link_Width_Start    = (`Config_Link_Width_Start=>`Config_Link_Width_Start);
bins Config_Link_Width_Start_to_Detect_Quiet               = (`Config_Link_Width_Start=>`Detect_Quiet);
bins Config_Link_Width_Accept_to_Config_Lanenum_Wait       = (`Config_Link_Width_Accept=>`Config_Lanenum_Wait);
bins Config_Link_Width_Accept_to_Detect_Quiet              = (`Config_Link_Width_Accept=>`Detect_Quiet);   
bins Config_Lanenum_Wait_to_Config_Lanenum_Accept          = (`Config_Lanenum_Wait=>`Config_Lanenum_Accept);
bins Config_Lanenum_Wait_to_Detect_Quiet                   = (`Config_Lanenum_Wait=>`Detect_Quiet);
bins Config_Lanenum_Accept_to_Config_Complete              = (`Config_Lanenum_Accept=>`Config_Complete);
//bins Config_Lanenum_Accept_to_Config_Lanenum_Wait          = (`Config_Lanenum_Accept=>`Config_Lanenum_Wait);
bins Config_Lanenum_Accept_to_Detect_Quiet                 = (`Config_Lanenum_Accept=>`Detect_Quiet);
bins Config_Complete_to_Config_Idle                        = (`Config_Complete=>`Config_Idle);
bins Config_Complete_to_Detect_Quiet                       = (`Config_Complete=>`Detect_Quiet);
bins Config_Idle_to_L0                                     = (`Config_Idle=>`L0);
bins Config_Idle_to_Detect_Quiet                           = (`Config_Idle=>`Detect_Quiet);
bins L0_to_Recovery_RcvrLock                               = (`L0=>`Recovery_RcvrLock);
bins Recovery_RcvrLock_to_Recovery_RcvrCfg                 = (`Recovery_RcvrLock=>`Recovery_RcvrCfg);
//bins Recovery_RcvrLock_to_Recovery_Speed                   = (`Recovery_RcvrLock=>`Recovery_Speed);
bins Recovery_Speed_to_Recovery_RcvrLock                   = (`Recovery_Speed=>`Recovery_RcvrLock);
bins Phase1_EQ_to_Recovery_RcvrLock                        = (`Phase1=>`Recovery_RcvrLock);
bins Recovery_RcvrLock_to_Phase1_EQ                        = (`Recovery_RcvrLock=>`Phase1);
//bins Recovery_RcvrLock_to_Config_Link_Width_Start          = (`Recovery_RcvrLock=>`Config_Link_Width_Start);
bins Recovery_RcvrLock_to_Detect_Quiet                     = (`Recovery_RcvrLock=>`Detect_Quiet);
bins Recovery_RcvrCfg_to_Recovery_Speed                    = (`Recovery_RcvrCfg=>`Recovery_Speed);
bins Recovery_RcvrCfg_to_Recovery_Idle                     = (`Recovery_RcvrCfg=>`Recovery_Idle);
bins Recovery_RcvrCfg_to_Detect_Quiet                      = (`Recovery_RcvrCfg=>`Detect_Quiet);
//bins Recovery_RcvrCfg_to_Config_Link_Width_Start           = (`Recovery_RcvrCfg=>`Config_Link_Width_Start);
bins Recovery_Idle_to_L0                                   = (`Recovery_Idle=>`L0);
bins Recovery_Idle_to_Detect_Quiet                         = (`Recovery_Idle=>`Detect_Quiet);
//bins Recovery_Idle_to_Config_Link_Width_Start              = (`Recovery_Idle=>`Config_Link_Width_Start);

 
  
}


endgroup: TX_D_LTSSM_Trans_Cover

 




covergroup TX_D_OS_Cover;

option.per_instance = 1;

OS_Types_Cover: coverpoint PIPE_seq_item_TX_h.TS_Type
{
  
bins TS1_gen_1  = {`TS1} iff(PIPE_seq_item_RX_h.Rate==4'b0001);
bins TS2_gen_1  = {`TS2} iff(PIPE_seq_item_RX_h.Rate==4'b0001);
bins TS1_gen_5  = {`TS1} iff(PIPE_seq_item_RX_h.Rate==4'b0101); 
bins TS2_gen_5  = {`TS2} iff(PIPE_seq_item_RX_h.Rate==4'b0101); 
bins EIOS       = {`EIOS};
bins EIEOS      = {`EIEOS};
bins SKP        = {`SKP};
bins SDS        = {`SDS};
bins IDLE       = {`IDLE};
  
}


endgroup: TX_D_OS_Cover






covergroup RX_D_LTSSM_Trans_Cover;

option.per_instance = 1;

LTSSM_Trans_Cover: coverpoint PIPE_seq_item_RX_h.Current_Substate
{
  
bins Detect_Quiet_to_Detect_Active                         = (`Detect_Quiet=>`Detect_Active);
bins Detect_Active_to_Polling_Active                       = (`Detect_Active=>`Polling_Active);
bins Polling_Active_to_Polling_Configuration               = (`Polling_Active=>`Polling_Configuration);
bins Polling_Active_to_Detect_Quiet                        = (`Polling_Active=>`Detect_Quiet);
bins Polling_Configuration_to_Config_Link_Width_Start      = (`Polling_Configuration=>`Config_Link_Width_Start);
bins Config_Link_Width_Start_to_Config_Link_Width_Accept   = (`Config_Link_Width_Start=>`Config_Link_Width_Accept);
//bins Config_Link_Width_Start_to_Config_Link_Width_Start    = (`Config_Link_Width_Start=>`Config_Link_Width_Start);
bins Config_Link_Width_Start_to_Detect_Quiet               = (`Config_Link_Width_Start=>`Detect_Quiet);
bins Config_Link_Width_Accept_to_Config_Lanenum_Wait       = (`Config_Link_Width_Accept=>`Config_Lanenum_Wait);
bins Config_Link_Width_Accept_to_Detect_Quiet              = (`Config_Link_Width_Accept=>`Detect_Quiet);
bins Config_Lanenum_Wait_to_Config_Lanenum_Accept          = (`Config_Lanenum_Wait=>`Config_Lanenum_Accept);
bins Config_Lanenum_Wait_to_Detect_Quiet                   = (`Config_Lanenum_Wait=>`Detect_Quiet);
bins Config_Lanenum_Accept_to_Config_Complete              = (`Config_Lanenum_Accept=>`Config_Complete);
//bins Config_Lanenum_Accept_to_Config_Lanenum_Wait          = (`Config_Lanenum_Accept=>`Config_Lanenum_Wait);
bins Config_Lanenum_Accept_to_Detect_Quiet                 = (`Config_Lanenum_Accept=>`Detect_Quiet);
bins Config_Complete_to_Config_Idle                        = (`Config_Complete=>`Config_Idle);
bins Config_Complete_to_Detect_Quiet                       = (`Config_Complete=>`Detect_Quiet);
bins Config_Idle_to_L0                                     = (`Config_Idle=>`L0);
bins Config_Idle_to_Detect_Quiet                           = (`Config_Idle=>`Detect_Quiet);
bins L0_to_Recovery_RcvrLock                               = (`L0=>`Recovery_RcvrLock);
bins Recovery_RcvrLock_to_Recovery_RcvrCfg                 = (`Recovery_RcvrLock=>`Recovery_RcvrCfg);
//bins Recovery_RcvrLock_to_Recovery_Speed                   = (`Recovery_RcvrLock=>`Recovery_Speed);
bins Recovery_Speed_to_Recovery_RcvrLock                   = (`Recovery_Speed=>`Recovery_RcvrLock);
bins Phase1_EQ_to_Recovery_RcvrLock                        = (`Phase1=>`Recovery_RcvrLock);
bins Recovery_RcvrLock_to_Phase1_EQ                        = (`Recovery_RcvrLock=>`Phase1);
//bins Recovery_RcvrLock_to_Config_Link_Width_Start          = (`Recovery_RcvrLock=>`Config_Link_Width_Start);
bins Recovery_RcvrLock_to_Detect_Quiet                     = (`Recovery_RcvrLock=>`Detect_Quiet);
bins Recovery_RcvrCfg_to_Recovery_Speed                    = (`Recovery_RcvrCfg=>`Recovery_Speed);
bins Recovery_RcvrCfg_to_Recovery_Idle                     = (`Recovery_RcvrCfg=>`Recovery_Idle);
bins Recovery_RcvrCfg_to_Detect_Quiet                      = (`Recovery_RcvrCfg=>`Detect_Quiet);
//bins Recovery_RcvrCfg_to_Config_Link_Width_Start           = (`Recovery_RcvrCfg=>`Config_Link_Width_Start);
bins Recovery_Idle_to_L0                                   = (`Recovery_Idle=>`L0);
bins Recovery_Idle_to_Detect_Quiet                         = (`Recovery_Idle=>`Detect_Quiet);
//bins Recovery_Idle_to_Config_Link_Width_Start              = (`Recovery_Idle=>`Config_Link_Width_Start);



  
}


endgroup: RX_D_LTSSM_Trans_Cover




covergroup RX_D_OS_Cover;

option.per_instance = 1;

OS_Types_Cover: coverpoint PIPE_seq_item_RX_h.TS_Type
{
  
bins TS1_gen_1  = {`TS1} iff(PIPE_seq_item_RX_h.Rate==4'b0001);
bins TS2_gen_1  = {`TS2} iff(PIPE_seq_item_RX_h.Rate==4'b0001);
bins TS1_gen_5  = {`TS1} iff(PIPE_seq_item_RX_h.Rate==4'b0101); 
bins TS2_gen_5  = {`TS2} iff(PIPE_seq_item_RX_h.Rate==4'b0101); 
bins EIOS       = {`EIOS};
bins EIEOS      = {`EIEOS};
bins SKP        = {`SKP};
bins SDS        = {`SDS};
bins IDLE       = {`IDLE};
  
}


endgroup: RX_D_OS_Cover







  
endclass






function Coverage_Model_D1::new(string name = "Coverage_Model_D1",uvm_component parent);
  
  super.new(name,parent);
  `uvm_info(get_type_name(),"inside constructor of Coverage_Model_D1",UVM_LOW)
  
  TX_D_LTSSM_Trans_Cover = new();
  TX_D_OS_Cover          = new();
  RX_D_LTSSM_Trans_Cover = new();
  RX_D_OS_Cover          = new();
  
endfunction 



function void  Coverage_Model_D1::build_phase(uvm_phase phase);
  
  super.build_phase(phase);
  `uvm_info(get_type_name(),"inside build phase of Coverage_Model_D1",UVM_LOW)
  
  TX_imp = new("TX_imp",this);
  RX_imp = new("RX_imp",this);
  
endfunction 




function void Coverage_Model_D1::connect_phase(uvm_phase phase);
  
  super.connect_phase(phase);
  `uvm_info(get_type_name(),"inside connect phase of Coverage_Model_D1",UVM_LOW)
  
endfunction





function void Coverage_Model_D1::write_TX_D_port(PIPE_seq_item PIPE_seq_item_TX_h);
  
  this.PIPE_seq_item_TX_h = PIPE_seq_item_TX_h;
  TX_D_LTSSM_Trans_Cover.sample();
  TX_D_OS_Cover.sample();
  
endfunction





function void Coverage_Model_D1::write_RX_D_port(PIPE_seq_item PIPE_seq_item_RX_h);
  
  this.PIPE_seq_item_RX_h = PIPE_seq_item_RX_h;
  RX_D_LTSSM_Trans_Cover.sample();
  RX_D_OS_Cover.sample();
  
endfunction
