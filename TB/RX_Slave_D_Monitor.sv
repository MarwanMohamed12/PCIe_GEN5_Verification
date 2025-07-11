
`timescale  1ns/1ns

class RX_Slave_D_Monitor  extends uvm_monitor;
  
`uvm_component_utils(RX_Slave_D_Monitor)


virtual PIPE_if PIPE_vif_h; 

uvm_analysis_port #(PIPE_seq_item) send_ap;


PIPE_seq_item PIPE_Item_h;

bit[16*8-1:0] LinkUp_OS [`LANESNUMBER];
bit start_flag;
bit speed_change;
bit Recovery_Idle_TS_is_idle;
bit directed_speed_change,changed_speed_recovery,start_equalization_w_preset;
bit [1:0] TS_OK = 2'b00 ;
bit[`MAXPIPEWIDTH-1:0] Descrambled_Data1,Descrambled_Data2,Descrambled_Data;

int Negosiated_Link_Number;
int Negosiated_Lane_Number[`LANESNUMBER-1 : 0]='{15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
bit Upconfigure_Capability_bit;
bit Recovery_RcvrLock_Transition;
event Time_out_D;
int Recovery_RcvrCfg_state_change;
bit [7:0]  idle_to_rlock_transitioned;
static int pass;
Descrambler_Scrambler  de_scrambler;
bit recoveryRcvrLock_Substate_Completed_f;
static bit linkup_gen5,TimeOut ;

typedef enum int {
                Reset,
                Detect_Quiet,
                Detect_Active,
                Polling_Active,
                Polling_Active_To_Config,
                Polling_Config,
                Configuration_Linkwidth_Start,
                Configuration_Linkwidth_Accept,
                Configuration_Lanenum_Wait,
                Configuration_Lanenum_Accept,
                Configuration_Complete,
                Configuration_Idle,
                L0_,
                Recovery_RcvrLock,
                Recovery_RcvrCfg,
                Recovery_Equalization,
                phase0,
                phase1,
                Recovery_Speed,
                Recovery_Idle
                } LinkUp_States;



LinkUp_States LinkUp_Current_State,previous_state;
int TS1_Counter, TS2_Counter, Idle_Counter, EIEOS_Counter;
int PAD_link_lane_Counter;
int Negotiated_Speed_D;

event TS_Receiving_Complete, idle_8_Receiving_Complete; /*TS_Type_Check_Complete, Idle_Type_Check_Complete,*/
event Updata_TS1_Counter_e, Updata_TS2_Counter_e, Updata_Idle_Counter_e;
event Idle_16_Is_Sent,TS1_16_Is_Sent,TS2_16_Is_Sent;
event TS_Configuration_Linkwidth_Accept_sent;
event Received_TS2_in_Polling_Configuration,Received_TS2_in_Config_Complete;
event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS1_in_Config_Lanenum_Wait;
event Received_2_TS1_in_Config_Lanenum_Accept;
event Received_Idle_in_Config_Idle;
event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed; 
event Polling_Configuration_Substate_Completed; 
event Config_Link_Width_Start_Substate_Completed;
event Received_TS_in_L0_D ; 
event L0_state_completed_D;
event Received_TS1_in_recoveryRcvrLock_Substate;
event recoveryRcvrLock_Substate_Completed;
event Recovery_RcvrCfg_Substate_Completed;
event Received_TS2_in_recoveryRcvrCfg_Substate;
event Received_TS1_in_phase1;
event phase1_Substate_Completed;
event Receive_Idle_Recovery_Idle;
event recoveryIdle_Substate_Completed;
event Update_EIEOS_Counter_e;
event Update_EIOS_Counter_e;
event EIOS_Received;
event Received_TS1_or_TS2_in_recoveryRcvrLock_Substate;
event Received_EIOS_in_recoveryRcvrLock_Substate;
event recoverySpeed_Substate_Completed;
event LinkUp_Completed_DSD;
event set_reset_In_LPIF;
event force_detect_trigger ;

bit Speed_change_bit;
bit [7:0] rate_identifier;
bit [7:0] symbol_6;
bit Recovery_Idle_Substate_Completed_f;
bit force_detect_trigger_f ;
static bit go_to_rec_speed;

static bit kill_fork,kill_check_fork,back,Kill_LinkUp_State_recognition ;
extern function new(string name="RX_Slave_D_Monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task Detect_Data_Idle_generic();
extern task Detect_First_COM_general();
//extern task Detect_State_recognition();
extern task Receive_TS_OS_general();
extern task Receive_Data_Idle_generic();
extern task Update_Idle_Counter();
extern task Update_TS1_Counter();
extern task Update_TS2_Counter();
extern task Update_EIEOS_Counter();
extern task Check_TS_Polling_Active();
extern task Check_TS_Polling_Config();
extern task Check_TS_Configuration_Linkwidth_Start();
extern task Check_TS_Configuration_Linkwidth_Accept();
extern task Check_TS_Configuration_Lanenum_Accept();
extern task Check_TS_Configuration_Lanenum_Wait();
extern task Check_TS_Configuration_Complete();
extern task Check_TS_Configuration_Idle();
extern task Check_TS_L0();
extern task Check_TS_Recovery_RcvrLock();
extern task Check_TS_Recovery_RcvrCfg();
extern task Check_TS_Recovery_Speed();
extern task Check_TS_phase1();
extern task Check_TS_Recovery_Idle();
extern task Check_TS();
extern task LinkUp_State_recognition();
extern task Main();
extern task run_phase(uvm_phase phase);
extern task scramble_data();
extern task set_flag();
extern task check_reset();
endclass



function RX_Slave_D_Monitor::new(string name="RX_Slave_D_Monitor",uvm_component parent);
  
        super.new(name,parent);

        
endfunction 



function void RX_Slave_D_Monitor::build_phase(uvm_phase phase);
  
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in monitor build_phase ",UVM_HIGH)

        send_ap = new("send_ap",this);
                
endfunction



function void RX_Slave_D_Monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in monitor connect_phase ",UVM_HIGH)
endfunction
   
   
       
task RX_Slave_D_Monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in monitor run_phase ",UVM_HIGH)
        Main ();
endtask



task RX_Slave_D_Monitor::scramble_data();
  
        reset_lfsr(de_scrambler,`GEN5);
  
        wait(LinkUp_Current_State == phase1  && PIPE_vif_h.RxData[`MAXPIPEWIDTH-1 -: 8] == 8'h1E); //#475;
 
  

 forever begin
  
     PIPE_seq_item  PIPE_seq_item_h;         
     PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
     
     @(posedge PIPE_vif_h.PCLK)   

     wait(TS_Receiving_Complete.triggered );
  
     if( PIPE_vif_h.PCLKRate >=2  )begin
       
         for(int i=(16*8);i>0;i=i-`MAXPIPEWIDTH)begin 

                        for ( int j=0 ; j<`LANESNUMBER; j=j+1  ) begin
                                
                                   Descrambled_Data1 = apply_descramble(de_scrambler,LinkUp_OS[j][(i-1) -: `MAXPIPEWIDTH],j,`GEN5);    
                                  
                                    LinkUp_OS[j][(i-1) -: `MAXPIPEWIDTH]    =   Descrambled_Data1;
                       
                                
                        end
                                 
                end
       end
     
    
         
       for(int i =0 ; i<2 ; i+=1)begin
            for ( int j=0 ; j<`LANESNUMBER; j=j+1  ) begin
              
              de_scrambler.lfsr_gen_3[j] = advance_lfsr_gen_3(de_scrambler.lfsr_gen_3[j]);
              
            end
      
      end

 end
      
      
     
endtask

task RX_Slave_D_Monitor::check_reset();

                fork
                        begin

                                forever begin
                                        @(posedge PIPE_vif_h.PCLK);

                                        if(PIPE_vif_h.phy_reset == 0)begin

                                                kill_fork=1;
                                                kill_check_fork = 1;
                                        end

                                end

                        end

                        begin                                
                                
                                forever begin

                                        wait(force_detect_trigger)
                                                force_detect_trigger_f=1;

                                end

                        end
                join



endtask

task RX_Slave_D_Monitor::Detect_Data_Idle_generic();
        //Watching the link for any COM character coming
        int idle = 8'h00;
        int lane_number=`LANESNUMBER;
        case (lane_number)
                 1: begin
                        // assumed that the first lane connected
        
                        wait( idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                
                 end
                
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        wait(      idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                 end
                
                 4: begin 
                        wait(      idle == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                
                 8: begin     wait(      idle == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && idle == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                
                 16: begin   wait(      0 != PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8]  
                                && 0 != PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8]
                                && 0 != PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && 0 != PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] && 8'h45 != PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                 end
                
                default: wait(     idle == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
        
        endcase



endtask



task RX_Slave_D_Monitor::Detect_First_COM_general();

        //generic for all lanes
        //Watching the link for any COM character coming
        int COM = 8'hBC;
        int lane_number=`LANESNUMBER;
        case (lane_number)
                
                 1: begin if(PIPE_vif_h.PCLKRate > 1)begin
                        // assumed that the first lane connected 
                                wait((8'h1E == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]))   ;
                        end
                       
                        else begin
                                wait( COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                        end
                end
                
                 2: begin 
                        /*
                        assumsion: the 2 connected lanes is the first 2 lanes lane0 and lane1
                        we can extend this case
                        the other cases of lane number have the same assumsion above
                        */
                        if(PIPE_vif_h.PCLKRate > 1)begin
                        // assumed that the first lane connected 

                                wait((8'h1E == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8])
                                &&    (8'h1E == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8])) ;
                        end
                        else begin
                                wait(      COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
                        end
                 end
                 
                 4: begin 
                        wait(      COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                        
                        if(PIPE_vif_h.PCLKRate > 1)begin
                        // assumed that the first lane connected 

                                wait((8'h1E == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8])  
                                  && (8'h1E == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8])
                                  && (8'h1E == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8])
                                  && (8'h1E == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8])) ;
                        end
                        else begin
                                wait(      COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                        end
                 end
                 
                 8: begin   
                        if(PIPE_vif_h.PCLKRate > 1)begin
                        // assumed that the first lane connected 

                                wait((8'h1E == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8])  
                                && (8'h1E == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8]) 
                                && (8'h1E == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8])) ;
                        end
                        else begin
                                wait( COM == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );
                        end 
                        
                         
                 end
                
                16: begin    
                        if(PIPE_vif_h.PCLKRate > 1 )begin

                              wait((8'h1E == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8])  
                                && (8'h1E == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8] || 8'h2D == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8]) 
                                && (8'h1E == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8])
                                && (8'h1E == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]  || 8'h2D == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8])
                                 );

                        end
                        else if(LinkUp_Current_State != Recovery_Speed) begin

                                wait(COM == PIPE_vif_h.RxData[((16*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((15*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((14*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((13*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((12*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((11*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((10*`MAXPIPEWIDTH)-1) -: 8]  
                                && COM == PIPE_vif_h.RxData[((9*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((8*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((7*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((6*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((5*`MAXPIPEWIDTH)-1) -: 8]
                                && COM == PIPE_vif_h.RxData[((4*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((3*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((2*`MAXPIPEWIDTH)-1) -: 8] 
                                && COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8] );


                                                          

                        end
                        
                 end
                
                default: wait(     COM == PIPE_vif_h.RxData[((1*`MAXPIPEWIDTH)-1) -: 8]);
        
        endcase
                

                

endtask


task RX_Slave_D_Monitor::Receive_TS_OS_general ();
        //generic for all lanes
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit[0:((`MAXPIPEWIDTH/8)-1)] control_character=0;

        forever begin

                   
                if((LinkUp_Current_State >=  Polling_Active) && (LinkUp_Current_State <= Recovery_Idle) ) begin

                        Detect_First_COM_general();
                      
                        for(int i=(16*8);i>0;i=i-`MAXPIPEWIDTH)begin 

                                for ( int j=0 ; j<`LANESNUMBER; j=j+1  ) begin
                                        control_character=0;

                                LinkUp_OS[j][(i-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH];
                                      

                                        for (int M=0 ;M < (`MAXPIPEWIDTH/8) ;M =M+1 ) begin
                                                if((COM_Gen_1_2 == PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-(M*8)-1) -: 8]) || (PAD_Gen_1_2 == PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-(M*8)-1) -: 8])) begin
                                                        control_character[M] = 1; 
                                                end else begin
                                                        control_character[M] = 0; 
                                                end
                                        end

                                end
                                if(i > `MAXPIPEWIDTH) begin //do not wait a clk cycle to trigger the TS_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end

                        end
                ->TS_Receiving_Complete;
                end else begin

                        wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State < Configuration_Idle);
                end

                 
        end


        
endtask



task RX_Slave_D_Monitor::Receive_Data_Idle_generic ();
        // for lane 0
        forever begin
                
                if(Configuration_Idle == LinkUp_Current_State)begin//only care about idles in configuration_idle
                        Detect_Data_Idle_generic();
                        //LinkUp_OS=~('h0);//FF..F to make a clear contrast between idle bits and other bits
                        /*
                        Receiving pipewidth/8 idle symbols in one lane transmission  
                        so idle counter increased by pipewidth/8 every time
                        */
                        ->Received_Idle_in_Config_Idle;
                        for(int i = (8/(`MAXPIPEWIDTH/8));i>0;i=i-1) begin//how much cycles 
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin//how much lanes
                                        // LinkUp_OS[j][(i*(`MAXPIPEWIDTH)+`MAXPIPEWIDTH-1) : i*(`MAXPIPEWIDTH)] = PIPE_vif_h.RxData[(j*`MAXPIPEWIDTH + `MAXPIPEWIDTH-1) : (j*`MAXPIPEWIDTH)];
                                        //linkup_os [63:32] = RxData[32:0]
                                        LinkUp_OS[j][(i*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH ];
                                end
                                if( i > 1) begin //do not wait a clk cycle to trigger the idle_8_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end
                        end
                        
                        ->idle_8_Receiving_Complete;
                end 

        else if (Recovery_Idle == LinkUp_Current_State)begin
                     Detect_Data_Idle_generic();  
                     for(int i = (8/(`MAXPIPEWIDTH/8));i>0;i=i-1) begin//how much cycles 
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin//how much lanes
                                        
                                        LinkUp_OS[j][(i*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH ];
                                end
                                if( i > 1) begin //do not wait a clk cycle to trigger the idle_8_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end
                        end
                end 
                
                else begin
                        wait(Configuration_Idle == LinkUp_Current_State ||  Recovery_Idle == LinkUp_Current_State);
                end
        end
endtask



task RX_Slave_D_Monitor::Update_Idle_Counter ();
        forever begin
               
                wait(Updata_Idle_Counter_e.triggered);
               
                Idle_Counter+=4;
               
                if(Idle_Counter==4) ->Received_Idle_in_Config_Idle;
                
                #1;
        end
endtask



task RX_Slave_D_Monitor::Update_TS1_Counter ();
        forever begin
               
                wait(Updata_TS1_Counter_e.triggered);
               
                TS1_Counter+=1;
                
                #1;
        end
        
endtask
task RX_Slave_D_Monitor::Update_TS2_Counter ();
        forever begin
               
                wait(Updata_TS2_Counter_e.triggered);
               
                TS2_Counter+=1;
                
                #1;
        end 
        
endtask



task RX_Slave_D_Monitor::Update_EIEOS_Counter ();
        forever begin
              
                wait(Update_EIEOS_Counter_e.triggered);
              
                EIEOS_Counter+=1;
                
                #1;
        end
        
endtask


task RX_Slave_D_Monitor::Check_TS_Polling_Active();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                && (PAD_Gen_1_2 == LinkUp_OS[j][119:112]) //S1
                                && (PAD_Gen_1_2 == LinkUp_OS[j][111:104]) //S2
                                && ((5'b00001 == LinkUp_OS[j][93:89])
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) //rate bits check
                                && (1'b0 == LinkUp_OS[j][95]) //  speed_change. This bit can be set to 1b only in theRecovery.RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                        -> Updata_TS1_Counter_e; 

                                end

                                
                                       
        end 

        
endtask

task RX_Slave_D_Monitor::Check_TS_Polling_Config();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS2=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                && PAD_Gen_1_2 == LinkUp_OS[j][119:112] //S1
                                && PAD_Gen_1_2 == LinkUp_OS[j][111:104] //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                && ((5'b00001 == LinkUp_OS[j][93:89])
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) //rate bits check
                                && 1'b0 == LinkUp_OS[j][95] //  speed_change. This bit can be set to 1b only in theRecovery.RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& TS2_ID == LinkUp_OS[j][79:72] //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                ) begin
                                        if(TS2_Counter<= 2)begin
                                                ->Received_TS2_in_Polling_Configuration; //This event for the Tx
                               
                                        end
                                        -> Updata_TS2_Counter_e;

                                end

                                
        end 
        
endtask



task RX_Slave_D_Monitor::Check_TS_Configuration_Linkwidth_Start();//downstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number
                                with the link number Tx transmitted in TS1 it sends*/
                                //&& Negosiated_Link_Number== LinkUp_OS[j][119:112] //S1 
                                && PAD_Gen_1_2 != LinkUp_OS[j][119:112] //S1
                                && PAD_Gen_1_2 == LinkUp_OS[j][111:104] //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                ) begin
                                  Negotiated_Speed_D = LinkUp_OS[j][93:89];
                                  -> Updata_TS1_Counter_e;
                                  Negosiated_Link_Number =   LinkUp_OS[j][119:112];
                                end
                                       

        end 




endtask
task RX_Slave_D_Monitor::Check_TS_Configuration_Linkwidth_Accept();//Dstreamam
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        bit [`LANESNUMBER-1:0] reversed_lane_number=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && (8'h1 == LinkUp_OS[j][119:112]) //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && (PAD_Gen_1_2 == LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && (1'b0 == LinkUp_OS[j][95]) //S4
                                && 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                
                                -> Updata_TS1_Counter_e;

                                
                                
                                end else begin
                                        if((PAD_Gen_1_2 == LinkUp_OS[j][119:112]) 
                                        && (PAD_Gen_1_2 == LinkUp_OS[j][111:104])) begin
                                                PAD_link_lane_Counter ++;

                                        end

                                end
        end 
  
        
endtask


task RX_Slave_D_Monitor::Check_TS_Configuration_Lanenum_Accept();//downstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        bit [`LANESNUMBER-1:0] reversed_lane_number=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                        -> Updata_TS1_Counter_e;
                                end
                                else begin
                                        if(0==j)begin
                                                //`uvm_info(get_type_name (),"TS1 does not meet the specs of downstream Configuration_Lanenum_Accept!!", UVM_LOW)
                                        end
                                        if((PAD_Gen_1_2 == LinkUp_OS[j][119:112]) 
                                        && (PAD_Gen_1_2 == LinkUp_OS[j][111:104])) begin
                                                PAD_link_lane_Counter ++;

                                        end
                                        
                                end

        end

        
endtask



task RX_Slave_D_Monitor::Check_TS_Configuration_Lanenum_Wait();//downstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                
                                && (PAD_Gen_1_2 != LinkUp_OS[j][119:112]) //S1
                                
                                && (PAD_Gen_1_2 != LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                
                                        
                                         -> Updata_TS1_Counter_e;
                                         Negosiated_Link_Number = LinkUp_OS[0][119:112];
                                end else begin
                                        if((PAD_Gen_1_2 == LinkUp_OS[j][119:112]) 
                                        && (PAD_Gen_1_2 == LinkUp_OS[j][111:104])) begin
                                                PAD_link_lane_Counter ++;

                                        end

                                end
        end 

        
endtask



task RX_Slave_D_Monitor::Check_TS_Configuration_Complete();
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS2=0;
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                
                && (Negosiated_Link_Number != LinkUp_OS[j][119:112]) //S1
                
                && (Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104]) //S2
                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                /*rate bits check*/
                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                ||(5'b01111 == LinkUp_OS[j][93:89])
                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                //Upconfigure Capability bit
                &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                /*  speed_change. This bit can be set to 1b only in theRecovery.
                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                && 1'b0 == LinkUp_OS[j][95] //S4
                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                //&& TS2_ID == LinkUp_OS[j][55:48] //S6
                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                )begin
                
                if(TS2_Counter==0)begin
                                ->Received_TS2_in_Config_Complete;
                   end
                   -> Updata_TS2_Counter_e;
                        
                end
        end 

        
endtask



task RX_Slave_D_Monitor::Check_TS_Configuration_Idle();
  
  
       
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2 = 8'hBC;
        bit [7:0] PAD_Gen_1_2 = 8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [31:0] Lane_Data,Descrambled_Data1 ,Descrambled_Data2;
        bit [`LANESNUMBER-1:0] error_idle=0;
        
      
                
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
              Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
              if( (Lane_Data != 0)  && (Lane_Data  != {4{TS2_ID}}) ) begin
                Descrambled_Data1 = apply_descramble(de_scrambler,Lane_Data,j,1);
                
                if({4{idle}} == Descrambled_Data1) -> Updata_Idle_Counter_e;
                                                        
              end
  
      end

endtask



task RX_Slave_D_Monitor::Check_TS_L0();
  
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [`LANESNUMBER-1:0] error_TS1=0;
        if(PIPE_Item_h.Highest_Comm_Speed > 1) begin
                        directed_speed_change  = 1;
                        changed_speed_recovery=1;
        end 

       for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                                
                                && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                                
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b1 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                        
                                         //PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                         //send_ap.write(PIPE_Item_h);
                                         -> Updata_TS1_Counter_e;   
                                         -> Received_TS_in_L0_D;
                                         
                                end
                                else begin
                                         `uvm_info(get_type_name (),"TS1 does not meet the specs of downstream L0 to go to recovery", UVM_LOW)
                                         if(j==0) begin
                                       
                                        //temporary code to bypass the wrong TS1
                                        if( (COM_Gen_1_2 == LinkUp_OS[j][127:120])
                                                && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                                                && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                                && (TS1_ID == LinkUp_OS[j][7:0]))//S15) 
                                                begin

                                                //PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                Speed_change_bit= LinkUp_OS[j][95];
                                                rate_identifier= LinkUp_OS[j][95:88];
                                                symbol_6= LinkUp_OS[j][79:72];
                                                //send_ap.write(PIPE_Item_h);
                                                -> Updata_TS1_Counter_e;   
                                                -> Received_TS_in_L0_D;


                                                end
                                       
                                         end

                                end
                end

      

endtask

task RX_Slave_D_Monitor::Check_TS_Recovery_RcvrLock();
 
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] COM_Gen_3_4_5_TS1 =8'h1E;
        bit [7:0] COM_Gen_3_4_5_TS2 =8'h2D;

        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;


       
        
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin

                        if( (COM_Gen_1_2 == LinkUp_OS[j][127:120] ) //S0
                        
                        && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                        
                        && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                        //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                        /*rate bits check*/
                        && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                        ||(5'b00011 == LinkUp_OS[j][93:89]) 
                        ||(5'b00111 == LinkUp_OS[j][93:89]) 
                        ||(5'b01111 == LinkUp_OS[j][93:89])
                        ||(5'b11111 == LinkUp_OS[j][93:89])) 
                        //Upconfigure Capability bit
                        &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                        /*  speed_change. This bit can be set to 1b only in theRecovery.
                        RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                        && (1'b1 == LinkUp_OS[j][95]) //S4
                        && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                        && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                        && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                        && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                        && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                        && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                        && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                        && (TS1_ID == LinkUp_OS[j][23:16])//S13
                        && (TS1_ID == LinkUp_OS[j][15:8])//S14
                        && (TS1_ID == LinkUp_OS[j][7:0])//S15
                        
                        )begin
   
                                        Speed_change_bit= LinkUp_OS[j][95];
                                        rate_identifier= LinkUp_OS[j][95:88];
                                        symbol_6= LinkUp_OS[j][79:72];
                                        -> Updata_TS1_Counter_e;
                                        -> Received_TS1_in_recoveryRcvrLock_Substate;

                                        TS_OK = 2'b01;

                                       
                        end


                        else if ((COM_Gen_1_2 == LinkUp_OS[j][127:120]) //S0
                        
                        && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                        
                        && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                        //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                        /*rate bits check*/
                        && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                        ||(5'b00011 == LinkUp_OS[j][93:89]) 
                        ||(5'b00111 == LinkUp_OS[j][93:89]) 
                        ||(5'b01111 == LinkUp_OS[j][93:89])
                        ||(5'b11111 == LinkUp_OS[j][93:89])) 
                        //Upconfigure Capability bit
                        &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                        /*  speed_change. This bit can be set to 1b only in theRecovery.
                        RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                       && 1'b1 == LinkUp_OS[j][95] //S4
                        && TS1_ID == LinkUp_OS[j][79:72] //S6
                        && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                        && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                        && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                        && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                        && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                        && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                        && (TS2_ID == LinkUp_OS[j][23:16])//S13
                        && (TS2_ID == LinkUp_OS[j][15:8])//S14
                        && (TS2_ID == LinkUp_OS[j][7:0])//S15
                        )begin
                                // if(j==0)
                                        //PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                        Speed_change_bit= LinkUp_OS[j][95];
                                        rate_identifier= LinkUp_OS[j][95:88];
                                        symbol_6= LinkUp_OS[j][79:72];
                                        //send_ap.write(PIPE_Item_h);
                                        -> Updata_TS2_Counter_e;
                                        -> Received_TS1_in_recoveryRcvrLock_Substate;
                                        // if(j==0)begin
                                        // end
                                        TS_OK = 2'b10;

                        end

                         else if (COM_Gen_3_4_5_TS1 == LinkUp_OS[j][127:120]  //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                               // && idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][83] //S5 //Disable Scrambling (for Gen1 and 2)
                               && (3'b0 == LinkUp_OS[j][74:72]) //S6
                                // && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                &&(1'b0 == LinkUp_OS[j][71])
                                && (2'b0 == LinkUp_OS[j][63:62])  //S8
                                && (1'b0 == LinkUp_OS[j][54]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15*/
                                )begin

                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                         -> Updata_TS1_Counter_e;
                                        
                                        TS_OK = 2'b01;
                                  
                                end
                                else if ( COM_Gen_3_4_5_TS2 ==LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89]))
                                //Upconfigure Capability bit
                               // &&( Upconfigure_Capability_bit == LinkUp_OS[j][94])
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                //&& (1'b0 == LinkUp_OS[j][95]) //S4
                                //&& (1'b1 == LinkUp_OS[j][43]) //S5 //Disable Scrambling (for Gen1 and 2)
                                && (0 == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                        Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                        -> Updata_TS2_Counter_e;
                                        TS_OK = 2'b10;
                                  
                                end
        end
        
endtask


task RX_Slave_D_Monitor::Check_TS_Recovery_RcvrCfg();
 
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] COM_Gen_3_4_5_TS2 =8'h2D;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;


        start_equalization_w_preset =1 ;

        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                
                                if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                //&& (1 == LinkUp_OS[j][79]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                  
                                        -> Updata_TS2_Counter_e;
                                        TS_OK = 2'b10;

                                end
                
                                else if (COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               // && (TS1_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];

                                        -> Updata_TS1_Counter_e;
                                 
                                        TS_OK = 2'b01;
                                  
                                end
 
                                else if (COM_Gen_3_4_5_TS2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                               && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                && 1'b0 == LinkUp_OS[j][95] //speed change is required..........
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               // && (TS2_ID == LinkUp_OS[j][79:72]) //S6
                                && (TS2_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS2_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS2_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS2_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS2_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS2_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS2_ID == LinkUp_OS[j][23:16])//S13
                                && (TS2_ID == LinkUp_OS[j][15:8])//S14
                                && (TS2_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                  
                                         -> Updata_TS2_Counter_e;
                                         -> Received_TS2_in_recoveryRcvrCfg_Substate ;
                                        TS_OK = 2'b10;
                                
                                end


        end 

 
endtask 

task RX_Slave_D_Monitor::Check_TS_phase1(); 

        
        bit [7:0] COM_Gen_5=8'h1E;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [`LANESNUMBER-1:0] error_TS1=0;

       for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                if((COM_Gen_5 == LinkUp_OS[j][127:120]) //S0
                                
                                && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                                
                                && (Negosiated_Lane_Number[`LANESNUMBER-j-1]== LinkUp_OS[j][111:104]) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                //&& 1'b1 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (2'b01 == LinkUp_OS[j][73:72]) // EC Bits =2'b01
                                //&& (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                //&& (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (6'b111111 == LinkUp_OS[j][69:64]) //FS CHECK
                                && (6'b111111 == LinkUp_OS[j][61:56])  //LS CHECK
                                //&& (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                                && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                        
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                         -> Updata_TS1_Counter_e;   
                                         -> Received_TS1_in_phase1;
                                         
                                end
                                else begin
                                         `uvm_info(get_type_name (),"TS1 does not meet the specs of phase1", UVM_HIGH)
                                         

                                          error_TS1[j]=1'b1;
                                          
                                end
        end 


endtask


task RX_Slave_D_Monitor::Check_TS_Recovery_Idle();  
  
       
                bit [7:0] idle=8'h00;
                bit [7:0] COM_Gen_1_2 = 8'hBC;
                bit [7:0] PAD_Gen_1_2 = 8'hF7;
                bit [7:0] TS1_ID=8'h4A;
                bit [7:0] TS2_ID=8'h45;
                bit [31:0] Lane_Data,Descrambled_Data1 ,Descrambled_Data2;
                bit [`LANESNUMBER-1:0] error_idle=0;

        bit [128:0] SKIP_GEN5 = 128'hE1000000999999999999999999999999 ;
        bit [128:0] SDS_GEN5 =  128'h878787878787878787878787E1878787 ;
        int lane_number=`LANESNUMBER;
        int SKIP_compl,SDS_compl;
        bit skip_detected,sds_detected;


        Recovery_Idle_TS_is_idle=1'b1;

        if(Idle_Counter>=8) return;   
                
        
        fork
        
        begin
                forever begin
                @(posedge PIPE_vif_h.PCLK);
                        for ( int j=0 ; j<`LANESNUMBER; j=j+1  ) begin
                        de_scrambler.lfsr_gen_3[j] = advance_lfsr_gen_3(de_scrambler.lfsr_gen_3[j]);
                        end
                end
                
        end
        
        
        
        begin
                
                wait(PIPE_vif_h.RxData[31:0]==32'h99999999);
        
        //////////////SKIP_DETECTION///////////////////////////
                if(PIPE_vif_h.RxDataValid == '1)  begin
                
                        for(int i = 0 ; i<128/`MAXPIPEWIDTH ; i=i+1 )begin

                        @(posedge PIPE_vif_h.PCLK);
        
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin

                                Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                
                                        if(Lane_Data == SKIP_GEN5[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH] )
                        
                                                SKIP_compl = SKIP_compl+1;
        
                                end 
                
                        end
                end     
                
                SKIP_compl = SKIP_compl/64;
        
                
                if(SKIP_compl==1)begin
                        
                        skip_detected=1;
                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                        PIPE_Item_h.TS_Type = `SKP;
                        PIPE_Item_h.TS_Count = 1;
                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                        send_ap.write(PIPE_Item_h);                        


                end


                ////////////////SDS_DETECTION//////////////////////


        wait(PIPE_vif_h.RxData[31:0]==32'hE1878787);
        
                for(int i = 0 ; i<128/`MAXPIPEWIDTH ; i=i+1 )begin

                @(posedge PIPE_vif_h.PCLK);
                
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                        Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                                        if(Lane_Data == SDS_GEN5[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH] )
                        
                                                SDS_compl = SDS_compl+1;
        
                                end 
                
                end    
                
                SDS_compl = SDS_compl/64;
        
                
                if(SDS_compl==1)begin
                        
                        sds_detected=1;
                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                        PIPE_Item_h.TS_Type = `SDS;
                        PIPE_Item_h.TS_Count = 1;
                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                        send_ap.write(PIPE_Item_h);  

                end
                
        
                
        end
        

        
        join_any  


        disable fork;
        
 
        ///////////////IDLE_DETECTION///////////////////////
        
        while(Idle_Counter<8) begin
        
                @(posedge PIPE_vif_h.PCLK);
                        
                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                if( (Lane_Data != 0) ) begin
                        Descrambled_Data1 = apply_descramble(de_scrambler,Lane_Data,j,`GEN5);

                end
                end


                        if({4{idle}} == Descrambled_Data1) begin
                        -> Updata_Idle_Counter_e;
                
                        ->Receive_Idle_Recovery_Idle; 
                        end

                


        end

 
endtask

task RX_Slave_D_Monitor::Check_TS_Recovery_Speed(); 
	
	bit [128:0] EIEOS_GEN5 = 128'h00000000ffffffff00000000ffffffff ;
	int lane_number=`LANESNUMBER;
	bit[31:0] Lane_Data;
	int EIEOS_compl;



        if(PIPE_vif_h.RxDataValid == '1)  begin

        for(int i = 0 ; i<128/`MAXPIPEWIDTH ; i=i+1 )begin

                @(posedge PIPE_vif_h.PCLK)

                        
                        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];

                                if(Lane_Data == EIEOS_GEN5[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH] ) begin
                                        EIEOS_compl = EIEOS_compl+1;

                                end 
                                
                        end
        end     
      
        EIEOS_compl = EIEOS_compl/64;

        end


        if(EIEOS_compl==1) begin
                 -> Update_EIEOS_Counter_e;
        end

endtask

task RX_Slave_D_Monitor::Check_TS ();//according to state
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;


        forever begin

                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= Recovery_Idle);

                                case (LinkUp_Current_State)

                                        Polling_Active:begin
                                                @(posedge PIPE_vif_h.PCLK);
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Polling_Active();

                                                #1;
                                                
                                                                        
                                        end 
                                        
                                        Polling_Config:begin
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Polling_Config();
                                                #1;
                                        end 
                                        Configuration_Linkwidth_Start:begin
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Configuration_Linkwidth_Start();
                                                #1;
                                        end 
                                        Configuration_Linkwidth_Accept:begin
                                        
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Configuration_Linkwidth_Accept();
                                                #1;
                                                
                                        end 
                                        Configuration_Lanenum_Wait:begin
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Configuration_Lanenum_Wait();
                                                #1;
                                        end 
                                        Configuration_Lanenum_Accept:begin
                                                wait(TS_Receiving_Complete.triggered);
                                                Check_TS_Configuration_Lanenum_Accept();
                                                #1;
                                        end 
                                        Configuration_Complete:begin
                                                wait(TS_Receiving_Complete.triggered || LinkUp_Current_State == Configuration_Idle);
                                                Check_TS_Configuration_Complete();
                                                #1;
                                        end 
                                        Configuration_Idle:begin
                                                @(posedge PIPE_vif_h.PCLK);
                                                Check_TS_Configuration_Idle ();
                                                
                                                
                                        end 
                                        L0_:begin
                                        wait(TS_Receiving_Complete.triggered); 
                                        Check_TS_L0();
                                        #1;

                                        end  
                                        Recovery_RcvrLock:begin
                                        wait(TS_Receiving_Complete.triggered);
                                        @(posedge PIPE_vif_h.PCLK)
                                        Check_TS_Recovery_RcvrLock();
                                        #1; 
                                        
                                        end 
                                        Recovery_RcvrCfg:begin
                                                wait(TS_Receiving_Complete.triggered);

                                                Check_TS_Recovery_RcvrCfg();
                                                #1;
                                        
                                        end 
                                        Recovery_Speed:begin
                                                @(posedge PIPE_vif_h.PCLK)
                                                Check_TS_Recovery_Speed();
                                                #1; 
                                                
                                                
                                        end 
                                        phase1:begin
                                                @(posedge PIPE_vif_h.PCLK);

                                                fork
                                                        begin

                                                                wait(TS_Receiving_Complete.triggered);


                                                        end


                                                        begin
                                                                wait(go_to_rec_speed);
                                                                go_to_rec_speed=0;        

                                                        end


                                                join_any
                                                Check_TS_phase1();
                                                #1;   
                                        end 

                                        Recovery_Idle:begin
                                                @(posedge PIPE_vif_h.PCLK)
                                                Check_TS_Recovery_Idle();
                                                #1;
                                                
                                        end 
                                
                                endcase



                
        end
        
endtask



task RX_Slave_D_Monitor::LinkUp_State_recognition ();//parallel
        while(1) begin


                                        case (LinkUp_Current_State)
                                                Detect_Quiet:begin
                                                        linkup_gen5=0;
                                                        Idle_Counter = 0;
                                                        TS2_Counter  =0;
                                                        TS1_Counter  =0;
                                                        wait(PIPE_vif_h.phy_reset == 1); //at begining it wait the reset end and after that won't wait
                                                        fork 
                                                                begin//Detect.Active need to start detection (or periodicly try to predict receiver)
                                                                        PIPE_Item_h.Current_Substate_D=`Detect_Quiet; 
                                                                        #50; // not correct error on design
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Active;
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ; 
                                                                        send_ap.write(PIPE_Item_h); 
                                                                end  
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Detect_Quiet;
                                                                        wait(PIPE_vif_h.TxElecIdle == 0 && PIPE_vif_h.TxDetectRx_Loopback);
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ; 

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Active;
                                                                        send_ap.write(PIPE_Item_h);
                                                                end   
                                                        join_any
                                                        disable fork;
                                                        LinkUp_Current_State = Detect_Active;
                                                        
                                                 `uvm_info(get_type_name() ,"Detect Quiet substate at Downstraem RX side completed successfully",UVM_LOW)

                                                        
                                                end
                                                Detect_Active:begin

                                                        Idle_Counter = 0;

                                                        fork
                                                                //i have nothing to tell me if the RX is detected or to get back to the Quiet so suppose detection is successful
                                                                begin //Detect_Quiet 
                                                                        PIPE_Item_h.Current_Substate_D=`Detect_Active;
                                                                        #(12ms / 100 );
                                                                        LinkUp_Current_State = Detect_Quiet;

                                                                        `uvm_info(get_type_name() ,"Rx not detected successfully",UVM_LOW)

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Detect_Active;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ; 

                                                                        send_ap.write(PIPE_Item_h);
                                                                end
                                                                begin //Polling_Active
                                                                        PIPE_Item_h.Current_Substate_D=`Detect_Active;
                                                                        wait(PIPE_vif_h.PhyStatus == {`LANESNUMBER{1'b1}}  && PIPE_vif_h.RxStatus == {`LANESNUMBER{3'b011}} &&  PIPE_vif_h.TxDetectRx_Loopback == {`LANESNUMBER{1'b1}});
                                                                        LinkUp_Current_State=Polling_Active;
                                                                        `uvm_info(get_type_name() ,"Detect Active substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Detect_Active;
                                                                        PIPE_Item_h.Next_Substate=`Polling_Active;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);

                                                                end
                                                        join_any
                                                        disable fork;

                                                end
                                                Polling_Active:begin
                                                        fork

                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Polling_Active;
                                                                        wait(8==TS1_Counter);

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Polling_Active;
                                                                        PIPE_Item_h.Next_Substate=`Polling_Configuration;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rx_polling_active_complete_D=1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        wait(Polling_Active_Substate_Completed);
                                                                        
                                                                        TS1_Counter=0;//its better to reset counter here 
                                                                        LinkUp_Current_State = Polling_Config;
                                                                        `uvm_info(get_type_name (),"Polling_Active substate at Downstraem RX side completed successfully", UVM_LOW)
                                                                end

                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Polling_Active;
                                                                        #(24ms / 100);
                                                                        ->Time_out_D;
                                                                        back =1;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Polling_Active;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        // PIPE_Item_h.TS_Count = 8;
                                                                        // PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;//its better to reset counter here 
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Polling Active , we get back to detect state",UVM_LOW)


                                                                end
                                                        join_any
                                                        disable fork;
                                                end 
                                                Polling_Config:begin

                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Polling_Configuration;
                                                                        wait(8 == TS2_Counter);
                                                                        wait(PIPE_Item_h.start_Timer_D);
                                                                        PIPE_Item_h.start_Timer_D=0;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Polling_Configuration;
                                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.TS_Type = `TS2;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                                                                                                
                                                                        TS2_Counter=0;
                                                                        TS1_Counter=0;
                                                                        LinkUp_Current_State = Configuration_Linkwidth_Start ;
                                                                        `uvm_info(get_type_name() ,"Polling Configuration substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                end
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Polling_Configuration;
                                                                        #(48ms / 100);
                                                                        ->Time_out_D;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Polling_Configuration;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1 ;

                                                                        // PIPE_Item_h.TS_Count = 8;
                                                                        // PIPE_Item_h.TS_Type = `TS2;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS2_Counter=0;
                                                                        TS1_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet ;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Polling Configuration , we get back to detect state",UVM_LOW)

                                                                end
                                                        join_any
                                                        disable fork;
                                                end 
                                                Configuration_Linkwidth_Start:begin

                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Link_Width_Start;
                                                                        wait(2==TS1_Counter);

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Start;
                                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Accept;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Negotiated_Speed_D = Negotiated_Speed_D;
                                                                        PIPE_Item_h.Rx_Config_Link_Width_Start_D=1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);

                                                                        ->Received_2_TS1_in_Config_Link_Width_Start;
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Configuration_Linkwidth_Accept;
                                                                        `uvm_info(get_type_name() ,"Configuration Linkwidth Start substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                end
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Link_Width_Start;
                                                                        wait(PIPE_Item_h.start_Timer_D);
                                                                        PIPE_Item_h.start_Timer_D = 0;
                                                                        #(24ms / 100);
                                                                        ->Time_out_D;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Start;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                        `uvm_info(get_type_name() ,"Time out occur Configuration Linkwidth Start , we get back to detect state",UVM_LOW)


                                                                end
                                                        join_any
                                                        disable fork;
                                                end 
                                                Configuration_Linkwidth_Accept:begin
                                               
                                                        /*
                                                        The next state is Detect after a 2 ms timeout 
                                                        or if no Link can be configured 
                                                        or if all Lanes receive two consecutive TS1 Ordered Sets with Link and Lane numbers set to PAD.
                                                        */
                                                        wait(PIPE_Item_h.start_Timer_D);
                                                                        
                                                        PIPE_Item_h.start_Timer_D = 0;
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Link_Width_Accept;
                                                                        wait(2 <= TS1_Counter);
                                                                        
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                                                        PIPE_Item_h.Next_Substate=`Config_Lanenum_Wait;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);                                

                                                                        ->Received_2_TS1_in_Config_Link_Width_Accept;
                                                                        TS1_Counter=0;
                                                                        LinkUp_Current_State = Configuration_Lanenum_Wait;
                                                                        `uvm_info(get_type_name() ,"Configuration Linkwidth Accept substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                end

                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Link_Width_Accept;
                                                                        #(2ms / 100);
                                                                        ->Time_out_D;
                                                                        

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Configuration Linkwidth Accept , we get back to detect state",UVM_LOW)
                                                                end

                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Link_Width_Accept;
                                                                        wait(PAD_link_lane_Counter>= 2* `LANESNUMBER );
                                                                        ->Time_out_D;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Configuration Linkwidth Accept , we get back to detect state",UVM_LOW)
                                                                end
                                                                //there is another case were the next substate is itself

                                                        join_any
                                                        disable fork;
                                                        PAD_link_lane_Counter=0;

                                                end 
                                                Configuration_Lanenum_Wait:begin
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Lanenum_Wait;                                  
                                                                        wait(2==TS1_Counter);
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                                        PIPE_Item_h.Next_Substate=`Config_Lanenum_Accept;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        ->Received_2_TS1_in_Config_Lanenum_Wait ;
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        

                                                                        LinkUp_Current_State = Configuration_Lanenum_Accept;
                                                                        `uvm_info(get_type_name() ,"  Configuration Lanenum Wait substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                end
                                                                begin
                                                                        /*
                                                                        Exit to “Detect State”
                                                                        After a 2ms timeout or if all Lanes receive 
                                                                        two consecutive TS1s with Link and Lane numbers set to PAD.
                                                                        */
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Lanenum_Wait;
                                                                        #(2ms /100 );
                                                                        ->Time_out_D;
                                                                        

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in  Configuration Lanenum Wait, we get back to detect state",UVM_LOW)

                                                                end
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Lanenum_Wait;
                                                                        wait(PAD_link_lane_Counter>= (2* `LANESNUMBER ));
                                                                        ->Time_out_D;
                                                                        

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in  Configuration Lanenum Wait , we get back to detect state",UVM_LOW)

                                                                        

                                                                end
                                                        join_any
                                                        disable fork;
                                                        PAD_link_lane_Counter=0;

                                                end 
                                                Configuration_Lanenum_Accept:begin
                                                        //if downstream
                                                        /*
                                                        If no Link can be configured, or if all Lanes 
                                                        receive two consecutive TS1s with PAD for Link and Lane numbers.
                                                        */
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Lanenum_Accept;
                                                                        wait(2==TS1_Counter);

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                                                        PIPE_Item_h.Next_Substate=`Config_Complete;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);

                                                                        ->Received_2_TS1_in_Config_Lanenum_Accept;
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        

                                                                        LinkUp_Current_State = Configuration_Complete;
                                                                        `uvm_info(get_type_name() ," Configuration Lanenum Accept substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Lanenum_Accept;
                                                                        wait(PAD_link_lane_Counter>= (2* `LANESNUMBER ));
                                                                        ->Time_out_D;
                                                                        
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                        PAD_link_lane_Counter=0;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Configuration Lanenum Accept , we get back to detect state",UVM_LOW)



                                                                end
                                                                //another case to go back to lanenum_wait
                                                                

                                                        join_any
                                                        disable fork;
                                                        PAD_link_lane_Counter=0;
                                                end 
                                                //Here
                                                Configuration_Complete:begin

                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Complete;
                                                                        wait(8==TS2_Counter);

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Config_Complete;
                                                                        PIPE_Item_h.Next_Substate=`Config_Idle;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.TS_Type = `TS2;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);

                                                                        
                                                                        wait(Config_Complete_Substate_Completed);
                                                                        
                                                                        TS2_Counter=0;
                                                                        TS1_Counter=0;
                                                                        LinkUp_Current_State = Configuration_Idle;
                                                                        `uvm_info(get_type_name() ," Configuration Complete substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                        reset_lfsr(de_scrambler,1);
                                                                end

                                                                begin
                                                                        /*
                                                                        After a 2 ms timeout:
                                                                                ◦ The next state is Detect if the current data rate is 2.5 GT/s or 5.0 GT/s.
                                                                        */
                                                                        PIPE_Item_h.Current_Substate_D=`Config_Complete;
                                                                        #(2ms / 100 );
                                                                        if(PIPE_vif_h.Rate == `GEN1 || PIPE_vif_h.Rate == `GEN2) begin
                                                                                ->Time_out_D;
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Config_Complete;
                                                                                PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                                PIPE_Item_h.time_out = 1 ;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);
                                                                                TS2_Counter=0;
                                                                                TS1_Counter=0;
                                                                                LinkUp_Current_State = Detect_Quiet;
                                                                                 `uvm_info(get_type_name() ,"Time out occur in Configuration Complete, we get back to detect state",UVM_LOW)
                                                                        end


                                                                end
                                                        join_any
                                                        disable fork;
                                                end 
                                                Configuration_Idle:begin

                                                fork
                                                        begin
                                                                PIPE_Item_h.Current_Substate_D=`Config_Idle;
                                                                wait(8==Idle_Counter);

                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Config_Idle;
                                                                PIPE_Item_h.Next_Substate=`L0;
                                                                PIPE_Item_h.TS_Count = 8;
                                                                PIPE_Item_h.TS_Type = `IDLE;
                                                                PIPE_Item_h.Rx_Config_Idle_D =1;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                send_ap.write(PIPE_Item_h);
                                                                ->LinkUp_Completed_DSD;
                                                                Idle_Counter=0;
                                                                LinkUp_Current_State = L0_;
                                                                `uvm_info(get_type_name() ," Configuration Idle substate at Downstraem RX side completed successfully",UVM_LOW)
                                                        end
                                                        begin
                                                                /*
                                                                Otherwise, after a minimum 2 ms timeout:
                                                                ▪ If the idle_to_rlock_transitioned variable is less than FFh, the next state is
                                                                Recovery.RcvrLock.
                                                                ▪ On transition to Recovery.RcvrLock:
                                                                ▪ If the data rate is 8.0 GT/s or higher, the idle_to_rlock_transitioned
                                                                variable is incremented by 1.
                                                                ▪ If the data rate is 2.5 GT/s or 5.0 GT/s, the idle_to_rlock_transitioned
                                                                variable is set to FFh.
                                                                ▪ Else the next state is Detect.
                                                                */
                                                                /*
                                                                we do not have such variable in the design
                                                                */
                                                                PIPE_Item_h.Current_Substate_D=`Config_Idle;
                                                                #(2ms / 100 );
                                                                ->Time_out_D;
                                                                ->set_reset_In_LPIF ;
                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Config_Idle;
                                                                PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                PIPE_Item_h.time_out = 1 ;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                send_ap.write(PIPE_Item_h);
                                                                Idle_Counter=0;
                                                                LinkUp_Current_State = Detect_Quiet;
                                                                `uvm_info(get_type_name() ,"Time out occur in Configuration Idle , we get back to detect state",UVM_LOW)

                                                        end
                                                join_any
                                                disable fork;
                                                end 
                                                L0_:begin 
                                                        PIPE_Item_h.Current_Substate_D=`L0;

                                                        if(PIPE_vif_h.PCLKRate==4)begin

                                                        @(posedge PIPE_vif_h.PCLK)

                                                        if(!linkup_gen5)begin
                                                                linkup_gen5=1;
                                                                `uvm_info(get_type_name() ,"Reached L0 state at Downstream RX side now in GEN 5",UVM_LOW)

                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                PIPE_Item_h.Current_Substate=`L0;
                                                                PIPE_Item_h.Next_Substate=`L0;

                                                                send_ap.write(PIPE_Item_h);
                                                        end
                                        

                                                        end
                                                        else if(PIPE_vif_h.PCLKRate <=1 )begin
                                                                        
                                                                `uvm_info(get_type_name() ,"Reached L0 state at Downstream RX side successfully",UVM_LOW)
                                                                wait(1==TS1_Counter);      
                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`L0;
                                                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                                PIPE_Item_h.TS_Count = 1;
                                                                PIPE_Item_h.TS_Type = `TS1;
                                                                PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                                PIPE_Item_h.linkup_on_down_stream = 1'b1 ;
                                                                
                                                                PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                PIPE_Item_h.symbol_6_D= symbol_6;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                send_ap.write(PIPE_Item_h);
                                                                TS2_Counter=0;
                                                                TS1_Counter=0;
                                                                previous_state = LinkUp_Current_State;
                                                                LinkUp_Current_State = Recovery_RcvrLock;
                                                        
                                                        end
                                                        
                                                        
                                                        
                                                end  
                                                Recovery_RcvrLock:begin
                                                
                                                fork
                                                        begin  
                                                                PIPE_Item_h.Current_Substate_D=`Recovery_RcvrLock;
                                                                if(Speed_change_bit == directed_speed_change )begin
                                                                        if(previous_state == L0_)begin
                                                                                wait((TS_OK == 2'b01 && TS1_Counter >= 7) || (TS_OK == 2'b10  &&  TS2_Counter >= 8));
                                                                        end else if(previous_state != Recovery_Speed) begin

                                                                
                                                                        wait((TS_OK == 2'b01 && TS1_Counter >= 8) || (TS_OK == 2'b10  &&  TS2_Counter >= 8));
                                                                end
                                                                
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrCfg;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        //
                                                                        PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                        PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                        PIPE_Item_h.symbol_6_D= symbol_6;
                                                                        //
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        wait(recoveryRcvrLock_Substate_Completed_f);
                                                                        recoveryRcvrLock_Substate_Completed_f = 0;
                                                                        LinkUp_Current_State = Recovery_RcvrCfg;
                                                                        PIPE_Item_h.Rx_recoveryRcvrLock_D = 1 ;
                                                                        `uvm_info(get_type_name() ," Recovery RcvrLock substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                
                                                                end
                                                                
                                                                else if(PIPE_vif_h.PCLKRate ==  PIPE_Item_h.Highest_Comm_Speed && start_equalization_w_preset)begin
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.Next_Substate=`Phase1;
                                                                        PIPE_Item_h.TS_Count = 0;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                                        //
                                                                        PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                        PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                        PIPE_Item_h.symbol_6_D= symbol_6;
                                                                        //
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        @(posedge PIPE_vif_h.PCLK);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        LinkUp_Current_State = phase1;
                                                                        `uvm_info(get_type_name() ," Recovery RcvrLock substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                        
                                                                end
                                                        end
                                                                begin
                                                                        #(24ms/100);
                                                                        ->Time_out_D;
                                                                        ->set_reset_In_LPIF ;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1 ;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;//its better to reset counter here 
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Recovery RcvrLock , we get back to detect state",UVM_LOW)

                                                                end 
                                                        join_any
                                                        disable fork; 
                                                
                                                end 
                                                Recovery_RcvrCfg:begin
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_RcvrCfg;
                                                                        if(Speed_change_bit == 1 )begin
                                                                        
                                                                                wait(TS_OK == 2'b10 && TS2_Counter==8 );
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                                PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                                                                PIPE_Item_h.TS_Count = 8;
                                                                                PIPE_Item_h.TS_Type = `TS2;
                                                                                //
                                                                                PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                                PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                                PIPE_Item_h.symbol_6_D= symbol_6;
                                                                                //
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);

                                                                                TS1_Counter=0;
                                                                                TS2_Counter=0;

                                                                                PIPE_Item_h.Rx_recoveryRcvrCfg_D = 1;
                                                                                LinkUp_Current_State = Recovery_Speed;
                                                                                `uvm_info(get_type_name() ," Recovery RcvrCfg  substate at Downstraem RX side completed successfully",UVM_LOW)


                                                                        end
                                                                        else if(!Speed_change_bit )begin
                                                                        
                                                                                wait(TS_OK == 2'b10 && TS2_Counter >= 8);
                                                                                
                                                                                
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                                PIPE_Item_h.Next_Substate=`Recovery_Idle;
                                                                                PIPE_Item_h.TS_Count = 8;
                                                                                PIPE_Item_h.TS_Type = `TS2;
                                                                                //
                                                                                PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                                PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                                PIPE_Item_h.symbol_6_D= symbol_6;
                                                                                //
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);
                                                                                TS1_Counter=0;
                                                                                TS2_Counter=0;
                                                                                PIPE_Item_h.Rx_recoveryRcvrCfg_D = 1;

                                                                                
                                                                                LinkUp_Current_State = Recovery_Idle;
                                                                                `uvm_info(get_type_name() ," Recovery RcvrCfg  substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                end
                                                                //sohaib: the code below is matched with the specs
                                                                begin 
                                                                        /*
                                                                        Next state is Configuration if eight consecutive TS1 Ordered Sets are received on any configured Lanes with
                                                                        Link or Lane numbers that do not match what is being transmitted on those same Lanes and 16 TS2 Ordered
                                                                        Sets are sent after receiving one TS1 Ordered Set and one of the following two conditions apply: 
                                                                        ◦ the speed_change bit is 0b on the received TS1 Ordered Sets
                                                                        ◦ current data rate is 2.5 GT/s and either no 5.0 GT/s, or higher, data rate identifiers are set in the received eight consecutive TS1 Ordered Sets, 
                                                                        or no 5.0 GT/s, or higher, data rate identifiers are being transmitted in the TS2 Ordered Sets
                                                                        The changed_speed_recovery variable and the directed_speed_change variable are reset to 0b if the LTSSM transitions to Configuration.
                                                                        
                                                                        */
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_RcvrCfg;

                                                                        wait( TS1_Counter >= 8); // The 8 TS1 must satisfy one of the two conditions to be counted
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;
                                                                        TS2_Counter=0;
                                                                        directed_speed_change  = 0;
                                                                        changed_speed_recovery=0;
                                                                        
                                                                        LinkUp_Current_State = Configuration_Linkwidth_Start;
                                                                        `uvm_info(get_type_name() ," Recovery RcvrCfg  substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin 
                                                                        /*
                                                                        After a 48 ms timeout;
                                                                        ◦ The next state is Detect if the current data rate is 2.5 GT/s or 5.0 GT/s. 
                                                                        ◦ The next state is Recovery.Idle if the idle_to_rlock_transitioned variable is less than FFh and the
                                                                        current data rate is 8.0 GT/s or higher.
                                                                        i. The changed_speed_recovery variable and the directed_speed_change variable are reset
                                                                        to 0b on entry to Recovery.Idle.
                                                                        ◦ Else the next state is Detect.
                                                                        */
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_RcvrCfg;

                                                                        #(48ms / 100);
                                                                        ->Time_out_D;
                                                                        idle_to_rlock_transitioned=8'hff;
                                                                        if(`GEN2 >= PIPE_vif_h.Rate ) begin
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                                PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                                PIPE_Item_h.time_out = 1;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);
                                                                                TS1_Counter=0;
                                                                                TS2_Counter=0;
                                                                                
                                                                                LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                                                                        end else if (8'hFF > idle_to_rlock_transitioned && `GEN3 <= PIPE_vif_h.Rate) begin
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                                PIPE_Item_h.Next_Substate=`Recovery_Idle;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);
                                                                                TS1_Counter=0;
                                                                                TS2_Counter=0;
                                                                                changed_speed_recovery = 0;
                                                                                directed_speed_change = 0;
                                                                                LinkUp_Current_State = Recovery_Idle;
                                                                                `uvm_info(get_type_name() ," Recovery RcvrCfg  substate at Downstraem RX side completed successfully",UVM_LOW)



                                                                        end else begin
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                                PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                                PIPE_Item_h.time_out = 1 ;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h);
                                                                                TS1_Counter=0;
                                                                                TS2_Counter=0;
                                                                                
                                                                                LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Recovery RcvrCfg , we get back to detect state",UVM_LOW)
                                                                        end
                                                                end

                                                        join_any
                                                        disable fork;
                                                        end 
                                                
                                        
                                                
                                                phase1:begin
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Phase1;
                                                                        wait(TS1_Counter==2);
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Phase1;

                                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.TS_Count = 2; // not sure as specs are not clear.
                                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate ;
                                                                        PIPE_Item_h.Speed_change_bit_D= Speed_change_bit;
                                                                        PIPE_Item_h.rate_identifier_D= rate_identifier;
                                                                        PIPE_Item_h.symbol_6_D= symbol_6;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h); 
                                                                        //wait(phase1_Substate_Completed.triggered)
                                                                        TS1_Counter = 0;
                                                                        previous_state = LinkUp_Current_State;

                                                                        LinkUp_Current_State = Recovery_RcvrLock;
                                                                        `uvm_info(get_type_name() ,"Phase1 substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Phase1;
                                                                        #(12ms / 100 );
                                                                        ->Time_out_D;
                                                                        ->set_reset_In_LPIF ;
                                                                        go_to_rec_speed=1;
                                                                        
                                                                        PIPE_Item_h.time_out_to_rec_speed_D=1;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.time_out = 1;
                                                                        PIPE_Item_h.Current_Substate=`Phase1;
                                                                        PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        TS1_Counter=0;//its better to reset counter here 
                                                                        LinkUp_Current_State = Recovery_Speed;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Phase1 , we get back to Recovery speed state",UVM_LOW)

                                                                end
                                                                join_any
                                                                disable fork;
                                                        
                                                end 
                                                Recovery_Speed:begin
                                                        fork
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_Speed;
                                                                        wait(EIEOS_Counter >= 2);
                                                                        speed_change =1;

                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `EIOS;
                                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                                        PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                                        send_ap.write(PIPE_Item_h);


                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.TS_Type = `EIEOS;
                                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                                        PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        directed_speed_change=0;       
                                                                        EIEOS_Counter=0;
                                                                        ->recoverySpeed_Substate_Completed;
                                                                        previous_state = LinkUp_Current_State;
                                                                        LinkUp_Current_State = Recovery_RcvrLock;
                                                                        `uvm_info(get_type_name() ,"Recovery Speed substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin

                                                                        wait( PIPE_Item_h.start_Timer_D == `Recovery_Speed);
                                                                        PIPE_Item_h.start_Timer_D=0;

                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_Speed;
                                                                        #(48ms / 100);
                                                                        ->Time_out_D;
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                        PIPE_Item_h.time_out = 1;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h);
                                                                        Idle_Counter=0;
                                                                        EIEOS_Counter=0;
                                                                        LinkUp_Current_State = Detect_Quiet;
                                                                         `uvm_info(get_type_name() ,"Time out occur in Recovery speed , we get back to detect state",UVM_LOW)

                                                                end
                                                        join_any
                                                        disable fork;
                                                end 
                                                Recovery_Idle:begin
                                                        fork 
                                                                begin
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_Idle;
                                                                        wait(Idle_Counter == 8) // not sure if it's just one or 8
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                                        PIPE_Item_h.Next_Substate=`L0;
                                                                        PIPE_Item_h.TS_Type = `IDLE;
                                                                        PIPE_Item_h.TS_Count = 8;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h); 
                                                                        wait(Recovery_Idle_Substate_Completed_f)
                                                                        Recovery_Idle_Substate_Completed_f=0;
                                                                        PIPE_Item_h.Rx_recoveryIdle_D=1;
                                                                // Idle_Counter = 0;
                                                                        LinkUp_Current_State = L0_;
                                                                        `uvm_info(get_type_name() ,"Recovery Idle substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin

                                                                        wait(PAD_link_lane_Counter == 2* `LANESNUMBER); 
                                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                                                        PIPE_Item_h.TS_Type = `TS1;
                                                                        PIPE_Item_h.TS_Count = 2;
                                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                        send_ap.write(PIPE_Item_h); 
                                                                        wait(Recovery_Idle_Substate_Completed_f);
                                                                        Recovery_Idle_Substate_Completed_f=0;
                                                                        TS1_Counter = 0;
                                                                        LinkUp_Current_State = Configuration_Linkwidth_Start;
                                                                        `uvm_info(get_type_name() ,"Recovery Idle substate at Downstraem RX side completed successfully",UVM_LOW)

                                                                end
                                                                begin
                                                                        wait(PIPE_Item_h.start_Timer_D);
                                                                        PIPE_Item_h.start_Timer_D = 0;
                                                                        PIPE_Item_h.Current_Substate_D=`Recovery_Idle;
                                                                        #(2ms / 100);
                                                                        ->set_reset_In_LPIF ;
                                                                        idle_to_rlock_transitioned = 8'hFF; //In design after time  out it goes to Detect Quiet but this is not what the specs says if we fixed the design we can delete this line
                                                                        if(8'hFF > idle_to_rlock_transitioned) begin
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                                send_ap.write(PIPE_Item_h); 
                                                                                wait(Recovery_Idle_Substate_Completed_f);
                                                                                Recovery_Idle_Substate_Completed_f=0;
                                                                                TS1_Counter = 0;
                                                                                LinkUp_Current_State = Recovery_RcvrLock;
                                                                                if(`GEN3 <= PIPE_vif_h.Rate)begin
                                                                                        idle_to_rlock_transitioned++;
                                                                                end else begin
                                                                                        idle_to_rlock_transitioned = 8'hFF;
                                                                                end
                                                                                `uvm_info(get_type_name() ,"Recovery Idle substate at Downstraem RX side completed successfully",UVM_LOW)
                                                                        end else begin
                                                                                ->Time_out_D;
                                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                                PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                                                PIPE_Item_h.Current_Substate_D=`Recovery_Idle;
                                                                                PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                                                PIPE_Item_h.time_out = 1;
                                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;        
                                                                                send_ap.write(PIPE_Item_h); 
                                                                                TS1_Counter = 0;
                                                                                LinkUp_Current_State = Detect_Quiet;
                                                                                 `uvm_info(get_type_name() ,"Time out occur in Recovery Idle, we get back to Recovery speed state",UVM_LOW)
                                                                        end
                                                                end
                                                        join_any
                                                        disable fork;
                                                        
                                                end 
                                        
                                        endcase 


        end
endtask

task RX_Slave_D_Monitor::set_flag();

        forever begin

                fork
                        begin
                                forever begin

                                        wait(recoveryRcvrLock_Substate_Completed.triggered);
                                        recoveryRcvrLock_Substate_Completed_f=1;
                                        #1;

                                end

                        end

                        begin
                                forever begin

                                        wait(recoveryIdle_Substate_Completed.triggered);
                                        Recovery_Idle_Substate_Completed_f=1;
                                        #1;

                                end


                        end

                join



        end

endtask


task RX_Slave_D_Monitor::Main ();
        LinkUp_Current_State = Detect_Quiet;
        forever begin

                fork :state_fork
                        begin
                                fork :state_fork_inside
                                        set_flag();
                                        LinkUp_State_recognition ();
                                        Check_TS ();
                                        Receive_TS_OS_general ();
                                        Update_Idle_Counter ();
                                        Update_TS1_Counter ();
                                        Update_TS2_Counter ();
                                        Update_EIEOS_Counter ();
                                        scramble_data();
                                        check_reset();
                                join

                        end 

                        begin
                                wait(kill_fork || force_detect_trigger_f);
                                kill_fork=0;
                                force_detect_trigger_f=0;
                                LinkUp_Current_State = Detect_Quiet;
                        end


                join_any
                disable fork;
                #5;


        end


endtask

        
        