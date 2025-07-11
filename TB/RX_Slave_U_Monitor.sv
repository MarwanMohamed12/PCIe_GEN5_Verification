
`timescale  1ns/1ns

class RX_Slave_U_Monitor  extends uvm_monitor;
  
`uvm_component_utils(RX_Slave_U_Monitor)


virtual PIPE_if PIPE_vif_h; 

uvm_analysis_port #(PIPE_seq_item) send_ap;
PIPE_seq_item PIPE_Item_h;
//typedef enum bit[1:0] {Not_Defined=0, TS1=1,TS2=2,Idle=3 } LinkUp_Ordersets_en;
bit[16*8-1:0] LinkUp_OS [`LANESNUMBER];
//LinkUp_Ordersets_en LinkUp_OS_Type;

bit Speed_change_bit;
bit [7:0] rate_identifier;
bit [7:0] symbol_6;

bit start_flag;
Descrambler_Scrambler  de_scrambler;
bit[`MAXPIPEWIDTH-1:0] Lane_Data,Lane_Datades;
bit [(`MAXPIPEWIDTH * `LANESNUMBER)-1 :0]All_data;
static int pass;

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
                RECOVERY_RcvrLock,
                RECOVERY_Rcvrcfg,
                Recovery_Equalization,
                phase0 ,
                phase1 ,
                RECOVERY_Rcvrspeed,
                RECOVERY_RcvrIdle 
                } LinkUp_States;
LinkUp_States LinkUp_Current_State;
int TS1_Counter, TS2_Counter, Idle_Counter , EIEOS_Counter;
event TS_Receiving_Complete, idle_8_Receiving_Complete; /*TS_Type_Check_Complete, Idle_Type_Check_Complete,*/
event Updata_TS1_Counter_e, Updata_TS2_Counter_e, Updata_Idle_Counter_e, Update_EIEOS_Counter_e;
event Idle_16_Is_Sent,TS1_16_Is_Sent,TS2_16_Is_Sent;
event TS_Configuration_Linkwidth_Accept_sent;
event Received_TS2_in_Polling_Configuration,Received_TS2_in_Config_Complete;
int Negosiated_Link_Number;
int Negosiated_Lane_Number[`LANESNUMBER-1 : 0]='{15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
bit Upconfigure_Capability_bit;
bit speed_change_asserted ,TS_Receiving_Complete_f;
bit [1:0] TS_OK = 2'b00 ;

bit [5:0]PAD_TS1;

event Received_2_TS1_in_Config_Link_Width_Start;
event Received_2_TS1_in_Config_Link_Width_Accept;
event Received_2_TS2_in_Config_Lanenum_Wait;
event Received_2_TS2_in_Config_Lanenum_Accept;
event Received_Idle_in_Config_Idle;
event Config_Complete_Substate_Completed;
event Polling_Active_Substate_Completed; 
event Polling_Configuration_Substate_Completed; 
event Config_Link_Width_Start_Substate_Completed;
event LinkUp_Completed_USD;
event DONE_SCRAMBLING ;
event force_detect_trigger ;

event Received_TS1_in_L0 ;
//---------------------------------------------------//
event Received_TS1_in_recoveryRcvrLock_Substate;

//---------------------------------------------------//


event Received_TS2_in_recoveryRcvrCfg_Substate ;
event Received_TS1_in_recoveryRcvrCfg_Substate ;

//---------------------------------------------------//
event Device_on_electrical_ideal;
//----------------------------------------------//

event Received_IDLE_in_recoveryIdle_Substate;
event Received_SKIP_in_recoveryIdle_Substate;
event Received_SDS_in_recoveryIdle_Substate;
event Received_TS1_in_recoveryIdle_Substate;

//----------------------------------------------//
event Received_TS1_in_phase0;
event Received_TS1_in_phase1;


//---------------------------------------------------//
event L0_state_completed ;
event recoveryRcvrLock_Substate_Completed;
event recoveryRcvrCfg_Substate_Completed ;
event recoverySpeed_Substate_Completed ;
event recoveryIdle_Substate_Completed;
event phase0_Substate_Completed;
event phase1_Substate_Completed;

event Time_out_U ;

bit recoveryRcvrLock_Substate_Completed_f;
bit[`MAXPIPEWIDTH-1:0] Descrambled_Data1,Descrambled_Data2,Descrambled_Data;
bit start_equalization_w_preset ,changed_speed_recovery,directed_speed_change;
bit[4:0] Negotiated_Speed_D;
static bit kill_fork,linkup_gen5,kill_check_fork;
bit force_detect_trigger_f ;

extern function new(string name="RX_Slave_U_Monitor",uvm_component parent);
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
extern task Update_EIEOS_Counter ();
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
extern task Check_TS_recoveryRcvrCfg();
extern task Check_TS_recoveryRcvrspeed();
extern task Check_TS_recoveryRcvrIdle();
extern task Check_TS_phase0();
extern task Check_TS_phase1();
extern task Check_TS();
extern task LinkUp_State_recognition();
extern task scramble_data();
extern task Main();
extern task run_phase(uvm_phase phase);
extern task set_flag();
extern task check_reset();
endclass



function RX_Slave_U_Monitor::new(string name="RX_Slave_U_Monitor",uvm_component parent);
  
        super.new(name,parent);

        
endfunction 




function void RX_Slave_U_Monitor::build_phase(uvm_phase phase);
  
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in monitor build_phase ",UVM_HIGH)

        send_ap = new("send_ap",this);
                
endfunction




function void RX_Slave_U_Monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in monitor connect_phase ",UVM_HIGH)
endfunction
   
   
   
   
    
task RX_Slave_U_Monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in monitor run_phase ",UVM_HIGH)
        Main ();
endtask

task RX_Slave_U_Monitor::scramble_data();
  
  reset_lfsr(de_scrambler,`GEN5);
  
 wait(LinkUp_Current_State == phase0  && PIPE_vif_h.RxData[`MAXPIPEWIDTH-1 -: 8] == 8'h1E); //#475;
 
  

 forever begin
  
     PIPE_seq_item  PIPE_seq_item_h;         
     PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
     
     @(posedge PIPE_vif_h.PCLK)   

     wait(TS_Receiving_Complete.triggered && LinkUp_Current_State != RECOVERY_RcvrIdle);
     
  
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





task RX_Slave_U_Monitor::Detect_Data_Idle_generic();
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
task RX_Slave_U_Monitor::Detect_First_COM_general();
        //generic for all lanes
        //Watching the link for any COM character coming
        int COM = 8'hBC;
        int lane_number=`LANESNUMBER;
        case (lane_number)
                 1:begin if(PIPE_vif_h.PCLKRate > 1)begin
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
                        else if(LinkUp_Current_State != RECOVERY_Rcvrspeed) begin
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

task RX_Slave_U_Monitor::check_reset();

        fork
                begin
                        forever begin


                                @(posedge PIPE_vif_h.PCLK);

                                if(PIPE_vif_h.phy_reset == 0)begin

                                        kill_fork=1;
                                        kill_check_fork=1;
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

task RX_Slave_U_Monitor::Receive_TS_OS_general ();
        //generic for all lanes
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit[0:((`MAXPIPEWIDTH/8)-1)] control_character=0;

        forever begin

                if((LinkUp_Current_State >=  Polling_Active) && (LinkUp_Current_State <= RECOVERY_RcvrIdle) ) begin
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
                TS_Receiving_Complete_f=1;
                end else begin
                        wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State < Configuration_Idle);
                end

                 
        end

        
endtask

task RX_Slave_U_Monitor::Receive_Data_Idle_generic ();
        forever begin
                
                if(Configuration_Idle == LinkUp_Current_State)begin //only care about idles in configuration_idle
                        Detect_Data_Idle_generic();
                        //LinkUp_OS=~('h0);//FF..F to make a clear contrast between idle bits and other bits
                        /*
                        Receiving pipewidth/8 idle symbols in one lane transmission  
                        so idle counter increased by pipewidth/8 every time
                        */
                        ->Received_Idle_in_Config_Idle;
                        for(int i = (8/(`MAXPIPEWIDTH/8));i>0;i=i-1) begin//how much cycles 
                                for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin//how much lanes

                                        LinkUp_OS[j][(i*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH] = PIPE_vif_h.RxData[((j+1)*`MAXPIPEWIDTH-1) -: `MAXPIPEWIDTH ];
                                end
                                if( i > 1) begin //do not wait a clk cycle to trigger the idle_8_Receiving_Complete event
                                                @(posedge PIPE_vif_h.PCLK);
                                                #1;
                                end
                        end
                        
                        ->idle_8_Receiving_Complete;
                end 

                else if (RECOVERY_RcvrIdle == LinkUp_Current_State)begin
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
                        wait(Configuration_Idle == LinkUp_Current_State || RECOVERY_RcvrIdle == LinkUp_Current_State);
                end
        end
endtask 

task RX_Slave_U_Monitor::Update_EIEOS_Counter ();
        forever begin
                wait(Update_EIEOS_Counter_e.triggered);
                EIEOS_Counter+=1;
                
                #1;
        end
        
endtask


task RX_Slave_U_Monitor::Update_Idle_Counter ();
        forever begin
                wait(Updata_Idle_Counter_e.triggered);
                Idle_Counter+=4;
               
                if(Idle_Counter==4) ->Received_Idle_in_Config_Idle;
               
                #1;
        end
endtask

task RX_Slave_U_Monitor::Update_TS1_Counter ();
        forever begin
                wait(Updata_TS1_Counter_e.triggered);
                TS1_Counter+=1;
                
                #1;
        end
        
endtask

task RX_Slave_U_Monitor::Update_TS2_Counter ();
        forever begin
                wait(Updata_TS2_Counter_e.triggered);
                TS2_Counter+=1;
                
                #1;
        end 
        
endtask



task RX_Slave_U_Monitor::Check_TS_Polling_Active();
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
                                //&& idle != LinkUp_OS[j][103:96] //N_FTS S3
                                && ((5'b00001 == LinkUp_OS[j][93:89])
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) //rate bits check
                                && (1'b0 == LinkUp_OS[j][95]) //  speed_change. This bit can be set to 1b only in theRecovery.RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.
                                //&& 1'b1 == LinkUp_OS[j][83] //S5 //Disable Scrambling (for Gen1 and 2)
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

task RX_Slave_U_Monitor::Check_TS_Polling_Config();
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
                                )begin
                                  
                                  
                                  
                                  
                                  if(TS2_Counter<=2)begin
                                    
                                           ->Received_TS2_in_Polling_Configuration; //This event for the Tx
                                           
                                  end
                                       
                                  
                                 -> Updata_TS2_Counter_e;     
                                     
                                  
                                end
              end 

endtask


task RX_Slave_U_Monitor::Check_TS_Configuration_Linkwidth_Start();//Upstream
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






task RX_Slave_U_Monitor::Check_TS_Configuration_Linkwidth_Accept();//Upstreamam
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
                                
                                
                                end
                                else if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && PAD_Gen_1_2 == LinkUp_OS[j][119:112] //S1
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
                                
                                        PAD_TS1++  ;
                                
                                
                                end

        end 
  
        
endtask




task RX_Slave_U_Monitor::Check_TS_Configuration_Lanenum_Accept();//Upstreamam
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
                                  
                                  -> Updata_TS2_Counter_e;
                                  
                                end
                                else if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && PAD_Gen_1_2 == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
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
                                //&& (TS2_ID == LinkUp_OS[j][79:72]) //S6
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
                                  
                                  PAD_TS1++ ;
                                  
                                end 

        end 
       
       
endtask

task RX_Slave_U_Monitor::Check_TS_Configuration_Lanenum_Wait();//Upstream
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
                                && (1'b0 == LinkUp_OS[j][95]) //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS2_ID == LinkUp_OS[j][79:72]) //S6
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
                                
                                         -> Updata_TS2_Counter_e;
                                        
                                end
                                else if(COM_Gen_1_2 == LinkUp_OS[j][127:120] //S0            //mostafa edited//
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                && PAD_Gen_1_2 == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && PAD_Gen_1_2 == LinkUp_OS[j][111:104] //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                               /* && ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                /*  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                               // && 1'b0 == LinkUp_OS[j][95] //S4
                                //&& 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                //&& (TS2_ID == LinkUp_OS[j][79:72]) //S6
                              /*  && (TS1_ID == LinkUp_OS[j][71:64]) //S7
                                && (TS1_ID == LinkUp_OS[j][63:56])  //S8
                                && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                                && (TS1_ID == LinkUp_OS[j][47:40]) //S10
                                && (TS1_ID == LinkUp_OS[j][39:32]) //S11
                                && (TS1_ID == LinkUp_OS[j][31:24]) //S12
                                && (TS1_ID == LinkUp_OS[j][23:16])//S13
                                && (TS1_ID == LinkUp_OS[j][15:8])//S14
                               */ && (TS1_ID == LinkUp_OS[j][7:0])//S15
                                )begin
                                   `uvm_info(get_type_name (),"TS1 does not meet the specs of upstream Configuration_Lanenum_Wait!!", UVM_HIGH)
                                  PAD_TS1++ ;
                                  
                                end 
        end 

        
endtask


task RX_Slave_U_Monitor::Check_TS_Configuration_Complete();
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



task RX_Slave_U_Monitor::Check_TS_Configuration_Idle();
  
       
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2 = 8'hBC;
        bit [7:0] PAD_Gen_1_2 = 8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [31:0] Lane_Data,Descrambled_Data1 ,Descrambled_Data2;
        bit [`LANESNUMBER-1:0] error_idle=0;
        
               
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
              Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
              if( (Lane_Data != 0)  && (Lane_Data[31:24] != 8'hBC)&& (Lane_Data[31:24] != 8'h3E) && (Lane_Data  != {4{TS2_ID}}) ) begin
                Descrambled_Data1 = apply_descramble(de_scrambler,Lane_Data,j,1);
                //`uvm_info(get_type_name(),$sformatf("Lane_Data = %h           Descrambled_Data1 = %h",Lane_Data,Descrambled_Data1 ),UVM_LOW)
                if({4{idle}} == Descrambled_Data1) -> Updata_Idle_Counter_e;
                            
              end
  
      end
endtask


task RX_Slave_U_Monitor::Check_TS_L0();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;
                if(PIPE_Item_h.Highest_Comm_Speed > 1) begin
                        directed_speed_change  = 1;
                        changed_speed_recovery=1;
                end 

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
                                  -> Received_TS1_in_L0 ;
                                  

                                  
                                end

                                       

        end 
endtask


task RX_Slave_U_Monitor::Check_TS_Recovery_RcvrLock();

        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] COM_Gen_3_4_5_TS1 =8'h1E;
        bit [7:0] COM_Gen_3_4_5_TS2 =8'h2D;

        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;


       
        
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin

                       if( (COM_Gen_1_2 == LinkUp_OS[j][127:120] ) //S0
                        
                        && (Negosiated_Link_Number == LinkUp_OS[j][119:112]) //S1
                        
                        &&( (Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
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
                        && (1'b1 == LinkUp_OS[j][95] )//S4
                        && (TS1_ID == LinkUp_OS[j][79:72] )//S6
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
                       && (1'b1 == LinkUp_OS[j][95]) //S4
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
                                
                                         Speed_change_bit= LinkUp_OS[j][95];
                                         rate_identifier= LinkUp_OS[j][95:88];
                                         symbol_6= LinkUp_OS[j][79:72];
                                        
                                        -> Updata_TS2_Counter_e;
                                        -> Received_TS1_in_recoveryRcvrLock_Substate;
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
                                  -> Received_TS1_in_recoveryRcvrLock_Substate ;

                                 TS_OK = 2'b01;
                                  
                                end
                                else if ( COM_Gen_3_4_5_TS2 ==LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
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

task RX_Slave_U_Monitor::Check_TS_recoveryRcvrCfg();//Upstream
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
                                && (1 == LinkUp_OS[j][79]) //S6
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


task RX_Slave_U_Monitor::Check_TS_recoveryRcvrspeed();
     bit [128:0] EIEOS_GEN5 = 128'h00000000ffffffff00000000ffffffff ;
     int lane_number=`LANESNUMBER;
     bit[31:0] Lane_Data;
     int EIEOS_compl;
     
    
    if (PIPE_vif_h.RxElecIdle == '1)  ->Device_on_electrical_ideal ;  
    
    
    if(PIPE_vif_h.RxDataValid == '1)  begin
      
     for(int i = 0 ; i<128/`MAXPIPEWIDTH ; i=i+1 )begin

        @(posedge PIPE_vif_h.PCLK)
  
          
        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
              Lane_Data = PIPE_vif_h.RxData[j*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                if(Lane_Data == EIEOS_GEN5[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH] )
                  
                       EIEOS_compl = EIEOS_compl+1;
  
         end 
         
     end
  end     
        
        EIEOS_compl = EIEOS_compl/64;
     
        
          if(EIEOS_compl==1)                         -> Update_EIEOS_Counter_e;
          
           
endtask



task RX_Slave_U_Monitor::Check_TS_phase0();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] COM_Gen_3_4_5_TS1 =8'h1E;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;


       



        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                
                                if(COM_Gen_3_4_5_TS1 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                //&& Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                /*&& ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                //&& 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                               // && 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                                && (2'b01 == LinkUp_OS[j][73:72]) //EC bits checker for phase0
                                && (6'b111111 == LinkUp_OS[j][69:64]) //FS CHECK
                                && (6'b111111 == LinkUp_OS[j][61:56])  //LS CHECK
                               // && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                               // && (TS1_ID == LinkUp_OS[j][47:40]) //S10
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
                                
                       
                                end

                                       

        end 
endtask

task RX_Slave_U_Monitor::Check_TS_phase1();//Upstream
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        bit [7:0] COM_Gen_3_4_5_TS1 =8'h1E;
        bit [7:0] TS1_ID=8'h4A;
        bit [7:0] TS2_ID=8'h45;
        bit [`LANESNUMBER-1:0] error_TS1=0;

     


       
      

        for (int j =0 ;j<`LANESNUMBER ; j=j+1 ) begin
                                
                                if(COM_Gen_3_4_5_TS1 == LinkUp_OS[j][127:120] //S0
                                /*Transmitter must initialize the Negosiated_Link_Number & Negosiated_Lane_Number
                                with the link number Tx transmitted in TS1 it sends
                                and same for the lane numbers as well.
                                */
                                //&& Negosiated_Link_Number == LinkUp_OS[j][119:112] //S1
                                /*
                                lane numbers may be same as transmitted or reversed
                                */
                                && ((Negosiated_Lane_Number[j]== LinkUp_OS[j][111:104])||(Negosiated_Lane_Number[`LANESNUMBER-1-j]== LinkUp_OS[j][111:104])) //S2
                                //&& idle != LinkUp_OS[j][31:24] //N_FTS S3
                                /*rate bits check*/
                                /*&& ((5'b00001 == LinkUp_OS[j][93:89])//S4
                                ||(5'b00011 == LinkUp_OS[j][93:89]) 
                                ||(5'b00111 == LinkUp_OS[j][93:89]) 
                                ||(5'b01111 == LinkUp_OS[j][93:89])
                                ||(5'b11111 == LinkUp_OS[j][93:89])) 
                                  speed_change. This bit can be set to 1b only in theRecovery.
                                RcvrLockLTSSM state. In all other LTSSM states, it is Reserved.*/
                                //&& 1'b1 == LinkUp_OS[j][95] //speed change is required..........
                               // && 1'b1 == LinkUp_OS[j][43] //S5 //Disable Scrambling (for Gen1 and 2)
                               && (2'b00 == LinkUp_OS[j][73:72]) //EC bits checker for phase0
                               && (6'b111111 == LinkUp_OS[j][69:64]) //FS CHECK
                               && (6'b111111 == LinkUp_OS[j][61:56])  //LS CHECK
                               // && (TS1_ID == LinkUp_OS[j][55:48]) //S9
                               // && (TS1_ID == LinkUp_OS[j][47:40]) //S10
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
                       
                                end

                                       

        end  
endtask


task RX_Slave_U_Monitor::Check_TS_recoveryRcvrIdle();

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
        
                
                if(SKIP_compl==1)  begin  
                        
                        skip_detected=1;
                
                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                        PIPE_Item_h.TS_Count = 1;
                        PIPE_Item_h.TS_Type = `SKP;
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
                        PIPE_Item_h.TS_Count = 1;
                        PIPE_Item_h.TS_Type =  `SDS;
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
                        ->Received_IDLE_in_recoveryIdle_Substate; 
                        end 
                


        end

 
endtask




task RX_Slave_U_Monitor::Check_TS ();//according to state
        bit [7:0] idle=8'h00;
        bit [7:0] COM_Gen_1_2=8'hBC;
        bit [7:0] PAD_Gen_1_2=8'hF7;
        forever begin
                wait(LinkUp_Current_State >= Polling_Active && LinkUp_Current_State <= RECOVERY_RcvrIdle);

                        case (LinkUp_Current_State)
                                Polling_Active:begin
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
                                        wait(TS_Receiving_Complete.triggered);
                                        Check_TS_Configuration_Complete();
                                        #1;
                                end 
                                Configuration_Idle:begin
                                        //wait(idle_8_Receiving_Complete.triggered);
                                        @(posedge PIPE_vif_h.PCLK)                                        
                                        Check_TS_Configuration_Idle();
                                        #1;
                                end 
                                L0_:begin
                                        @(posedge PIPE_vif_h.PCLK)
                                        wait(TS_Receiving_Complete.triggered);
                                        Check_TS_L0();
                                        #1;
                                end  
                                RECOVERY_RcvrLock:begin
                                        wait(TS_Receiving_Complete.triggered);
                                        Check_TS_Recovery_RcvrLock();
                                        #1;
                                end 
                                RECOVERY_Rcvrcfg:begin
                                        wait(TS_Receiving_Complete.triggered || LinkUp_Current_State ==RECOVERY_Rcvrspeed );
                                        Check_TS_recoveryRcvrCfg();
                                        #1;
                                end  

                                RECOVERY_Rcvrspeed:begin              
                                        @(posedge PIPE_vif_h.PCLK)
                                        Check_TS_recoveryRcvrspeed();
                                        #1;
                                end 
        
                                RECOVERY_RcvrIdle:begin
                                        @(posedge PIPE_vif_h.PCLK)
                                        Check_TS_recoveryRcvrIdle();

                                end

                                phase0:begin
                                        @(posedge PIPE_vif_h.PCLK)
                                        wait(TS_Receiving_Complete.triggered);
                                        Check_TS_phase0();
                                        #1;

                                end

                                phase1:begin
                                        @(posedge PIPE_vif_h.PCLK)
                                        wait(TS_Receiving_Complete.triggered);
                                        Check_TS_phase1();
                                        #1;
                                        
                                end

                        
                        endcase
    
        end
        
endtask

task RX_Slave_U_Monitor::LinkUp_State_recognition ();//parallel
        forever begin


                        case (LinkUp_Current_State)

                                Detect_Quiet:begin
                                        linkup_gen5=0;
                                        Idle_Counter=0;
                                        TS1_Counter = 0;
                                        TS2_Counter = 0;
                                        wait(PIPE_vif_h.phy_reset == 1);
                                        fork:Detect_Quiet_fork
                                                
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Detect_Quiet;
                                                        #50; // not correct error on design
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.Next_Substate=`Detect_Active;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                end

                                                begin
                                                        wait(PIPE_vif_h.TxElecIdle == 0 && PIPE_vif_h.TxDetectRx_Loopback);

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.Next_Substate=`Detect_Active;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        
                                                end

                                        join_any
                                        disable Detect_Quiet_fork;
                                        LinkUp_Current_State=Detect_Active;

                                        `uvm_info(get_type_name() ,"Detect Quiet substate at Upstream RX side completed successfully",UVM_LOW)

                                end

                                Detect_Active:begin

                                        fork:Detect_Active_fork

                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Detect_Active;
                                                        #(12ms / 100);
                                                        LinkUp_Current_State=Detect_Quiet;

                                                        `uvm_info(get_type_name() ,"Rx not detected successfully",UVM_LOW)
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Detect_Active;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                end

                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Detect_Active;
                                                        wait(PIPE_vif_h.PhyStatus == {`LANESNUMBER{1'b1}}  && PIPE_vif_h.RxStatus == {`LANESNUMBER{3'b011}} &&  PIPE_vif_h.TxDetectRx_Loopback == {`LANESNUMBER{1'b1}});
                                                        LinkUp_Current_State=Polling_Active;
                                                        `uvm_info(get_type_name() ,"Detect Active substate at Upstream RX side completed successfully",UVM_LOW)

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Detect_Active;
                                                        PIPE_Item_h.Next_Substate=`Polling_Active;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                        send_ap.write(PIPE_Item_h);

                                                end   

                                        join_any
                                disable Detect_Active_fork;
                                end

                                Polling_Active:begin
                                        fork    : Polling_Active_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Polling_Active;
                                                        wait(8==TS1_Counter);
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Polling_Active;
                                                        PIPE_Item_h.Next_Substate=`Polling_Configuration;
                                                        PIPE_Item_h.TS_Count = 8;
                                                        PIPE_Item_h.TS_Type = `TS1;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        PIPE_Item_h.Rx_polling_active_complete_U=1;
                                                        wait(Polling_Active_Substate_Completed);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Polling_Config;
                                                        `uvm_info(get_type_name (),"Polling Active substate at Upstream RX side completed successfully", UVM_LOW)

                                                end

                                                begin
                                                        #(24ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Polling_Active;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Polling Active , we get back to detect state",UVM_LOW)

                                                end
                                                

                                        join_any 
                                        disable Polling_Active_fork;
                                        
                                
                                end 
                                Polling_Config:begin
                                        
                                        fork    : Polling_Config_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Polling_Configuration;
                                                        wait(8 == TS2_Counter);
                                                        //wait(PIPE_Item_h.start_Timer_U);
                                                        //PIPE_Item_h.start_Timer_U=0;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Polling_Configuration;
                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Start;
                                                        PIPE_Item_h.TS_Count = 8;
                                                        PIPE_Item_h.TS_Type = `TS2;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        //wait(Polling_Configuration_Substate_Completed);                                                
                                                        TS2_Counter=0;
                                                        TS1_Counter=0;
                                                        LinkUp_Current_State = Configuration_Linkwidth_Start ;
                                                        `uvm_info(get_type_name() ,"Polling Configuration substate at Upstream RX side completed successfully",UVM_LOW)

                                                end

                                                begin   
                                                        #(48ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Polling_Configuration;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;       
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;                                         
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Polling Configuration , we get back to detect state",UVM_LOW)
                                                end
                                                

                                        join_any 
                                        disable Polling_Config_fork;

                                end 
                                Configuration_Linkwidth_Start:begin

                                        fork    : Configuration_Linkwidth_Start_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Link_Width_Start;
                                                        wait(2==TS1_Counter);

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Start;
                                                        PIPE_Item_h.Next_Substate=`Config_Link_Width_Accept;
                                                        PIPE_Item_h.TS_Count = 2;
                                                        PIPE_Item_h.TS_Type = `TS1;
                                                        PIPE_Item_h.Negotiated_Speed_D = Negotiated_Speed_D;
                                                        PIPE_Item_h.Rx_Config_Link_Width_Start_U=1;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                        send_ap.write(PIPE_Item_h);
                                                        ->Received_2_TS1_in_Config_Link_Width_Start;
                                                        TS1_Counter=0;
                                                        TS2_Counter=0;
                                                        LinkUp_Current_State = Configuration_Linkwidth_Accept;
                                                        `uvm_info(get_type_name() ,"Config Link Width Start substate at Upstream RX side completed successfully",UVM_LOW)       

                                                end

                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Link_Width_Start;
                                                        wait(PIPE_Item_h.start_Timer_U);
                                                        PIPE_Item_h.start_Timer_U = 0;

                                                        #(24ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Start;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur Configuration Linkwidth Start , we get back to detect state",UVM_LOW)

                                                end
                                                

                                        join_any 
                                        disable Configuration_Linkwidth_Start_fork;
                                        

                                end 
                                Configuration_Linkwidth_Accept:begin//back
                                
                                        fork    : Configuration_Linkwidth_Accept_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Link_Width_Accept;
                                                        wait(2<=TS1_Counter); //sohaib

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
                                                        `uvm_info(get_type_name() ,"Config Link Width Accept substate at Upstream RX side completed successfully",UVM_LOW)     

                                                end

                                                begin
                                                        #(2ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Configuration Linkwidth Accept , we get back to detect state",UVM_LOW)

                                                end

                                                begin
                                                        wait(PAD_TS1 == 2 * `LANESNUMBER);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Link_Width_Accept;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Configuration Linkwidth Accept , we get back to detect state",UVM_LOW)

                                                end
                                                

                                        join_any 
                                        disable Configuration_Linkwidth_Accept_fork;
                                        PAD_TS1=0;
                                        

                                end 
                                Configuration_Lanenum_Wait:begin
                                        //if Upstream
                                        fork    : Configuration_Lanenum_Wait_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Lanenum_Wait;

                                                        wait(2==TS2_Counter);
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                        PIPE_Item_h.Next_Substate=`Config_Lanenum_Accept;
                                                        PIPE_Item_h.TS_Count = 2;
                                                        PIPE_Item_h.TS_Type = `TS1;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h); 
                                                        ->Received_2_TS2_in_Config_Lanenum_Wait ;
                                                        TS1_Counter=0;
                                                        TS2_Counter=0;
                                                        LinkUp_Current_State = Configuration_Lanenum_Accept;
                                                        `uvm_info(get_type_name() ,"Config Lanenum Wait substate at Upstream RX side completed successfully",UVM_LOW)            
        

                                                end

                                                begin
                                                        #(2ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name (),"Config Lanenum Wait substate at Upstream RX side completed To detect", UVM_LOW)

                                                end

                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Lanenum_Wait;  /// mostafa edited ///
                                                        wait(PAD_TS1 >= (2* `LANESNUMBER ));
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Wait;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in  Configuration Lanenum Wait , we get back to detect state",UVM_LOW)

                                                end
                                                

                                        join_any 
                                        disable Configuration_Lanenum_Wait_fork;
                                        PAD_TS1=0;
        
                                end 
                                Configuration_Lanenum_Accept:begin // back//
                                        //if Upstream
                                        
                                        fork    : Configuration_Lanenum_Accept_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Lanenum_Accept;

                                                        wait(2==TS2_Counter);

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                                        PIPE_Item_h.Next_Substate=`Config_Complete;
                                                        PIPE_Item_h.TS_Count = 2;
                                                        PIPE_Item_h.TS_Type = `TS2;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);

                                                        ->Received_2_TS2_in_Config_Lanenum_Accept;
                                                        TS1_Counter=0;
                                                        TS2_Counter=0;
                                                        

                                                        LinkUp_Current_State = Configuration_Complete;
                                                        `uvm_info(get_type_name() ,"Config Lanenum Accept substate at Upstream RX side completed successfully",UVM_LOW)                                                          
        
                                                end

                                                begin
                                                        wait(PAD_TS1 == (2* `LANESNUMBER ));
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Lanenum_Accept;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Configuration Lanenum Accept , we get back to detect state",UVM_LOW)

                                                end
                                                

                                        join_any 
                                        disable Configuration_Lanenum_Accept_fork;
                                        PAD_TS1=0;
                                end 
                                Configuration_Complete:begin

                                        fork    : Configuration_Complete_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Complete;

                                                        wait(8==TS2_Counter);
                                
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Complete;
                                                        PIPE_Item_h.Next_Substate=`Config_Idle;
                                                        PIPE_Item_h.TS_Count = 8;
                                                        PIPE_Item_h.TS_Type = `TS2;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                
                                                        wait(Config_Complete_Substate_Completed);
                                                        PIPE_Item_h.Rx_Config_Complete_U  = 1; 
                                                        
                                                        TS2_Counter=0;
                                                        LinkUp_Current_State = Configuration_Idle;
                                                        `uvm_info(get_type_name() ,"Config Complete substate at Upstream RX side completed successfully",UVM_LOW)

                                                        reset_lfsr(de_scrambler,1);                                                         
        
                                                end

                                                begin
                                                        #(2ms / 100 );
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Complete;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Configuration Complete, we get back to detect state",UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable Configuration_Complete_fork;
                                        
                                end 
                                Configuration_Idle:begin

                                        fork    : Configuration_Idle_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Config_Idle;
                                                        wait(8==Idle_Counter);
                                                        PIPE_Item_h.Rx_Config_Idle_U = 1;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Idle;
                                                        PIPE_Item_h.Next_Substate=`L0;
                                                        PIPE_Item_h.TS_Count = 8;
                                                        PIPE_Item_h.TS_Type = `IDLE;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        ->LinkUp_Completed_USD;
                                                
                                                        Idle_Counter=0;
                                                        LinkUp_Current_State = L0_;
                                                        `uvm_info(get_type_name() ,"Config Idle substate at Upstream RX side completed successfully",UVM_LOW)                                                       
        
                                                end

                                                begin
                                                        #(2ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Config_Idle;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Configuration Idle , we get back to detect state",UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable Configuration_Idle_fork;
                                end 
                                L0_:begin

                                        PIPE_Item_h.Current_Substate_U=`L0;
        
                                        if(PIPE_vif_h.PCLKRate==4)begin

                                                @(posedge PIPE_vif_h.PCLK)

                                                if(!linkup_gen5)begin
                                                        linkup_gen5=1;
                                                        `uvm_info(get_type_name() ,"Reached L0 state at Upstream RX side now in GEN 5",UVM_LOW)
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        PIPE_Item_h.Current_Substate=`L0;
                                                        PIPE_Item_h.Next_Substate=`L0;
                                                        send_ap.write(PIPE_Item_h);
                                                        
                                                end




                                        end

                                        else begin
                                                `uvm_info(get_type_name() ,"Reached L0 state at Upstream RX side successfully",UVM_LOW)
                                                                
                                                wait(1==TS1_Counter);      
                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                PIPE_Item_h.Current_Substate=`L0;
                                                PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                PIPE_Item_h.TS_Count = 1;
                                                PIPE_Item_h.TS_Type = `TS1;
                                                PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                PIPE_Item_h.symbol_6_U= symbol_6;
                                                
                                                PIPE_Item_h.linkup_in_upstream = 1'b1 ;
                                                PIPE_Item_h.Rate = PIPE_vif_h.Rate;

                                                send_ap.write(PIPE_Item_h);

                                                TS1_Counter=0;
                                                TS2_Counter=0;
                                                
                                                wait(L0_state_completed);
                                                LinkUp_Current_State = RECOVERY_RcvrLock;
                                        end

                                        
                                end 
                                RECOVERY_RcvrLock:begin

                                        fork    : RECOVERY_RcvrLock_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Recovery_RcvrLock;
                                                        if(Speed_change_bit == directed_speed_change )begin

                                                        wait((TS_OK == 2'b01 || TS_OK == 2'b10 ) && (( TS1_Counter + TS2_Counter) >= 8));

                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                                PIPE_Item_h.Next_Substate=`Recovery_RcvrCfg;
                                                                PIPE_Item_h.TS_Count = 8;
                                                                PIPE_Item_h.TS_Type = `TS1;
                                                                PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                                PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                                PIPE_Item_h.symbol_6_U= symbol_6;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                                send_ap.write(PIPE_Item_h);

                                                                TS1_Counter=0;
                                                                TS2_Counter=0;
                                                                wait(1==recoveryRcvrLock_Substate_Completed_f);
                                                                recoveryRcvrLock_Substate_Completed_f = 0 ;      
                                                                PIPE_Item_h.Rx_recoveryRcvrLock_U     = 1 ;

                                                                LinkUp_Current_State = RECOVERY_Rcvrcfg;
                                                                `uvm_info(get_type_name() ,"Recovery.RcvrLock substate at Upstream RX side completed successfully",UVM_LOW)



                                                        end
                                                        
                                                        else if(PIPE_vif_h.PCLKRate ==  PIPE_Item_h.Highest_Comm_Speed && start_equalization_w_preset)begin
                
                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                                PIPE_Item_h.Next_Substate=`Phase0;
                                                                PIPE_Item_h.TS_Count = 0;
                                                                PIPE_Item_h.TS_Type = `TS1;
                                                                PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                                PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                                PIPE_Item_h.symbol_6_U= symbol_6;
                                                                PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                                send_ap.write(PIPE_Item_h);

                                                                TS1_Counter=0;
                                                                TS2_Counter=0;
                                                                
                                                                LinkUp_Current_State = phase0;
                                                                `uvm_info(get_type_name() ,"Recovery.RcvrLock STATE at Upstream RX side completed successfully",UVM_LOW)

                                                        end
                                                                                
        
                                                end

                                                begin

                                                        #(24ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_RcvrLock;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Recovery RcvrLock , we get back to detect state",UVM_LOW)
                                                end                                        

                                        join_any 
                                        disable RECOVERY_RcvrLock_fork;                        
                

                                        end 
                                        
                                RECOVERY_Rcvrcfg:begin

                                        
                                        fork    : RECOVERY_Rcvrcfg_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Recovery_RcvrCfg;


                                                        if(Speed_change_bit == 1 )begin
                                                        
                                                                wait(TS_OK == 2'b10 && TS2_Counter==8 );
                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                                                PIPE_Item_h.TS_Count = 8;
                                                                PIPE_Item_h.TS_Type = `TS2;
                                                                PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                                PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                                PIPE_Item_h.symbol_6_U= symbol_6;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                                
                                                                send_ap.write(PIPE_Item_h);

                                                                TS1_Counter=0;
                                                                TS2_Counter=0;
                                                                PIPE_Item_h.Rx_recoveryRcvrCfg_U = 1 ;
                                                                
                                                                LinkUp_Current_State = RECOVERY_Rcvrspeed;
                                                        `uvm_info(get_type_name() ,"Recovery.RcvrCfg substate at Upstream RX side completed successfully",UVM_LOW)


                                                        end
                                                        else if(!Speed_change_bit )begin
                                                        
                                                                wait(TS_OK == 2'b10 && TS2_Counter>8)
                                                                
                                                                
                                                                PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                                PIPE_Item_h.Current_Substate=`Recovery_RcvrCfg;
                                                                PIPE_Item_h.Next_Substate=`Recovery_Idle;
                                                                PIPE_Item_h.TS_Count = 8;
                                                                PIPE_Item_h.TS_Type = `TS2;
                                                                PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                                PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                                PIPE_Item_h.symbol_6_U= symbol_6;
                                                                PIPE_Item_h.Rx_recoveryRcvrCfg_U = 1 ;
                                                                PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;

                                                                send_ap.write(PIPE_Item_h);
                                                                
                                                                TS1_Counter=0;
                                                                TS2_Counter=0;

                                                                
                                                                LinkUp_Current_State = RECOVERY_RcvrIdle;
                                                                `uvm_info(get_type_name() ,"Recovery.RcvrCfg substate at Upstream RX side completed successfully",UVM_LOW)

                                                                
                                                        end                                                  
                        
                                                end

                                                begin

                                                        #(48ms / 100);
                                                        ->Time_out_U;
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

                                        join_any 
                                        disable RECOVERY_Rcvrcfg_fork;


                                        end

                                RECOVERY_Rcvrspeed:begin 


                                        
                                        fork    : RECOVERY_Rcvrspeed_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Recovery_Speed;

                                                        wait( (2==EIEOS_Counter  && changed_speed_recovery==1 && PIPE_vif_h.PCLKRate == 4)
                                                        || (1==EIEOS_Counter  && changed_speed_recovery==0 && PIPE_vif_h.PCLKRate == 0));  
                                                                                                               
                                                                                                               
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                        PIPE_Item_h.TS_Count = 1;
                                                        PIPE_Item_h.TS_Type = `EIOS;
                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                        PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                        send_ap.write(PIPE_Item_h);

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                        PIPE_Item_h.TS_Count = 1;
                                                        PIPE_Item_h.TS_Type = `EIEOS;
                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                        PIPE_Item_h.PCLKRate = PIPE_vif_h.PCLKRate;
                                                        send_ap.write(PIPE_Item_h);

                                                        EIEOS_Counter=0;
                                                        directed_speed_change=0;
                                                
                                                        LinkUp_Current_State = RECOVERY_RcvrLock;
                                                        `uvm_info(get_type_name() ,"Recovery.Speed substate at Upstream RX side completed successfully",UVM_LOW)                                                    
        
                                                end

                                                begin   
                                                        wait(PIPE_Item_h.start_Timer_U);
                                                        PIPE_Item_h.start_Timer_U=0;
                                                        #(48ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_Speed;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Recovery speed , we get back to detect state",UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable RECOVERY_Rcvrspeed_fork;                               
                                        

                                end  

                                RECOVERY_RcvrIdle:begin

                                        fork    : RECOVERY_RcvrIdle_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Recovery_Idle;

                                                        wait(8==Idle_Counter);
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                        PIPE_Item_h.Next_Substate=`L0;
                                                        PIPE_Item_h.TS_Count = 8;
                                                        PIPE_Item_h.TS_Type = `IDLE;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        PIPE_Item_h.Rx_recoveryIdle_U =1;                                                
                                                        LinkUp_Current_State = L0_;
                                                        `uvm_info(get_type_name() ,"Recovery.Idle substate at Upstream RX side completed successfully",UVM_LOW)                                                      
        
                                                end

                                                begin
                                                        #(2ms/100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Recovery_Idle;
                                                        PIPE_Item_h.Next_Substate=`Detect_Quiet;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        Idle_Counter=0;
                                                        LinkUp_Current_State = Detect_Quiet;
                                                        `uvm_info(get_type_name() ,"Time out occur in Recovery Idle, we get back to Recovery speed state",UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable RECOVERY_RcvrIdle_fork;


                                        

                                end

                        
                                phase0:begin//back

                                        fork    : phase0_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Phase0;

                                                        wait(2==TS1_Counter);
                                                        -> Received_TS1_in_phase0 ;
                                                

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Phase0;
                                                        PIPE_Item_h.Next_Substate=`Phase1;
                                                        PIPE_Item_h.TS_Count = 2;
                                                        PIPE_Item_h.TS_Type = `TS1;
                                                        PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                        PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                        PIPE_Item_h.symbol_6_U= symbol_6;
                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;

                                                        send_ap.write(PIPE_Item_h);
                                                
                                                        TS1_Counter=0;
                                                        LinkUp_Current_State = phase1;
                                                        
                                                        `uvm_info(get_type_name() ,"Phase0 substate at Upstream RX side completed successfully",UVM_LOW)                                                      
        
                                                end

                                                begin
                                                        #( 12ms / 100 );
                                                        ->Time_out_U;
                                                        PIPE_Item_h.time_out_to_rec_speed_U=1;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Phase0;
                                                        PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = RECOVERY_Rcvrspeed;
                                                        `uvm_info(get_type_name (),"Timeout occur.. we get back to  to detect", UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable phase0_fork;                          

                                end

                                phase1:begin//back

                                        fork    : phase1_fork
                                                begin
                                                        PIPE_Item_h.Current_Substate_U=`Phase1;

                                                        wait(2==TS1_Counter);
                                                        -> Received_TS1_in_phase1 ;
                                                

                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Phase1;
                                                        PIPE_Item_h.Next_Substate=`Recovery_RcvrLock;
                                                        PIPE_Item_h.TS_Count = 2;
                                                        PIPE_Item_h.TS_Type = `TS1;
                                                        PIPE_Item_h.Speed_change_bit_U= Speed_change_bit;
                                                        PIPE_Item_h.rate_identifier_U= rate_identifier;
                                                        PIPE_Item_h.symbol_6_U= symbol_6;
                                                        PIPE_Item_h.Rate = PIPE_vif_h.Rate;
                                                        
                                                        send_ap.write(PIPE_Item_h);
                                                        
                                                        TS1_Counter=0;
                                                        LinkUp_Current_State = RECOVERY_RcvrLock;
                                                        `uvm_info(get_type_name() ,"Phase1 substate at Upstream RX side completed successfully",UVM_LOW)                                                      
        
                                                end

                                                begin
                                                        #(12ms / 100);
                                                        ->Time_out_U;
                                                        PIPE_Item_h.time_out_to_rec_speed_U=1;
                                                        PIPE_Item_h= PIPE_seq_item::type_id::create("PIPE_Item_h");
                                                        PIPE_Item_h.Current_Substate=`Phase1;
                                                        PIPE_Item_h.Next_Substate=`Recovery_Speed;
                                                        PIPE_Item_h.time_out = 1 ;
                                                        PIPE_Item_h.Rate     = PIPE_vif_h.Rate  ;
                                                        send_ap.write(PIPE_Item_h);
                                                        TS1_Counter=0;//its better to reset counter here 
                                                        LinkUp_Current_State = RECOVERY_Rcvrspeed;
                                                        `uvm_info(get_type_name (),"Time out occur in Phase1 , we get back to detect", UVM_LOW)

                                                end                                        

                                        join_any 
                                        disable phase1_fork; 

                                        
                                
                                        
                                end

                                

                        
                        endcase



        end
endtask

task RX_Slave_U_Monitor::set_flag();
        forever begin

                wait(recoveryRcvrLock_Substate_Completed.triggered);
                recoveryRcvrLock_Substate_Completed_f=1;
                #1;
        end

endtask



task RX_Slave_U_Monitor::Main ();

        LinkUp_Current_State = Detect_Quiet;
        forever begin
                fork :state_fork

                        begin
                                fork   
                                        set_flag(); 
                                        LinkUp_State_recognition ();
                                        Check_TS ();
                                        Receive_TS_OS_general ();
                                        Update_EIEOS_Counter ();
                                        Update_Idle_Counter ();
                                        Update_TS1_Counter ();
                                        Update_TS2_Counter ();
                                        scramble_data();
                                        check_reset();

                                join

                        end

                        begin
                                wait((kill_fork || force_detect_trigger_f) );
                                kill_fork=0;
                                force_detect_trigger_f=0;
                                LinkUp_Current_State = Detect_Quiet;

                        end

                join_any
                disable fork;

        end

endtask

                
                