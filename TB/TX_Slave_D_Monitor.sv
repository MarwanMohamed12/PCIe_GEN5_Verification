class TX_Slave_D_Monitor extends uvm_monitor;
  


`uvm_component_utils(TX_Slave_D_Monitor)
    
  
virtual PIPE_if      PIPE_vif_h;

event Receiver_Detected;//
event Received_TS2_in_Polling_Configuration;//
event Received_2_TS1_in_Config_Link_Width_Start;//
event Received_2_TS1_in_Config_Link_Width_Accept;//
event Received_2_TS1_in_Config_Lanenum_Wait;  //
event Received_2_TS1_in_Config_Lanenum_Accept;//

event Received_TS1_in_L0;//

//----------------------------------------------//
event Received_TS1_in_recoveryRcvrLock_Substate;//
event Received_8_TS2_in_recoveryRcvrLock_Substate;//

//----------------------------------------------//

event Received_TS2_in_recoveryRcvrCfg_Substate;//
event Received_TS1_in_recoveryRcvrCfg_Substate;//
//------------------------------------------------//

event Device_on_electrical_ideal;
//----------------------------------------------//

event Received_IDLE_in_recoveryIdle_Substate;//
event Received_TS1_in_recoveryIdle_Substate;//
//----------------------------------------------//

event Received_TS1_in_phase1;

bit  Received_TS2_in_Polling_Configuration_f ;


bit   Received_2_TS1_in_Config_Link_Width_Start_f;
bit   Received_2_TS1_in_Config_Link_Width_Accept_f;
bit   Received_2_TS1_in_Config_Lanenum_Wait_f;  
bit   Received_2_TS1_in_Config_Lanenum_Accept_f; 
bit   Received_Idle_in_Config_Idle_f;
bit   LinkUp_Completed_f;
bit   Received_TS1_in_L0_f;  

//------------------------------------------------//
bit   Received_TS1_in_recoveryRcvrLock_Substate_f;
bit   Received_8_TS2_in_recoveryRcvrLock_Substate_f;
//------------------------------------------------//

bit   Received_TS2_in_recoveryRcvrCfg_Substate_f;
bit   Received_TS1_in_recoveryRcvrCfg_Substate_f;

//------------------------------------------------//

bit   Device_on_electrical_ideal_f;

//----------------------------------------------//

bit   Received_IDLE_in_recoveryIdle_Substate_f;
bit   Received_TS1_in_recoveryIdle_Substate_f;
//----------------------------------------------//

bit Received_TS1_in_phase1_f;

event Received_TS2_in_Config_Complete;//
event Received_Idle_in_Config_Idle;//
event Polling_Active_Substate_Completed;//
event Polling_Configuration_Substate_Completed;//
event Config_Link_Width_Start_Substate_Completed;//
event Config_Complete_Substate_Completed;//

event LinkUp_Completed_DSD;//
event L0_state_completed;//
event recoveryRcvrLock_Substate_Completed;//
event recoveryRcvrCfg_Substate_Completed;//
event recoverySpeed_Substate_Completed;//

event phase1_Substate_Completed;//
event recoveryIdle_Substate_Completed;//
event force_detect_trigger ;
int previous_state;

bit[5:0] Current_Substate,Next_Substate;
bit[15:0] TS_Count,IDLE_Count,EIEOS_Count;
bit[3:0] Symbol_num;
bit[`MAXPIPEWIDTH-1:0] Lane_Data,Descrambled_Data,Lane_Datades;
bit [(`MAXPIPEWIDTH * `LANESNUMBER)-1 :0]All_data;
bit[(`MAXPIPEWIDTH/8)-1:0] Lane_DataK;
bit detected_os,reject_os;
bit[1:0] TS_Type;
bit[4:0] Negotiated_Speed_U;
bit[2:0] Highest_Comm_Speed;
int rejected_TS;
int wanted_count;
Descrambler_Scrambler  de_scrambler;
bit Time_out_D_f;
event Time_out_D;
static bit time_out ;


//--------------//
bit start_equalization_w_preset;
bit directed_speed_change;
bit changed_speed_recovery;
bit start_equalization_w_preset_variable;
bit select_deemphasis;
static bit linkup_gen5;

bit [3:0]TX_Preset_d ;
bit [4:0] next_state;
bit TIME_OUT;
int Time_period = 20;
bit state_completed_successfully;
bit [3:0]TX_Preset_u ;
bit linkup;
bit force_detect_trigger_f;
static bit kill_fork ;
static bit config_idle_complete;
uvm_analysis_port #(PIPE_seq_item) send_ap1;
uvm_analysis_port #(PIPE_seq_item) send_ap2;



    
extern function new(string name = "TX_Slave_D_Monitor",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task Pass_PIPE_TX_Signals ();
extern task Set_Flags();
extern task Monitoring_Substates_Transition ();
extern task Receiver_Detection ();
extern task Polling_Active ();
extern task Polling_Configuration ();
extern task Config_Link_Width_Start ();
extern task Config_Link_Width_Accept ();
extern task Config_Lanenum_Wait ();
extern task Config_Lanenum_Accept ();
extern task Config_Complete ();
extern task Config_Idle ();
extern task L0();
extern task recoveryRcvrLock();
extern task recoveryRcvrCfg();
extern task recoverySpeed();
extern task phase1();
extern task recoveryIdle();
extern task scramble_data();
extern task Timer();

endclass


function TX_Slave_D_Monitor::new(string name = "TX_Slave_D_Monitor",uvm_component parent);
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
endfunction 


function void TX_Slave_D_Monitor::build_phase (uvm_phase phase);
  
        super.build_phase(phase);
        
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        
        send_ap1 = new("send_ap1",this);
        send_ap2 = new("send_ap2",this);   
             
endfunction: build_phase


function void TX_Slave_D_Monitor::connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in connect_phase of driver ",UVM_LOW)
endfunction: connect_phase


task TX_Slave_D_Monitor::scramble_data();
  static bit start_scrambling;


  forever begin
  //start scrambling in right time
      reset_lfsr(de_scrambler,1);
      start_scrambling =0;
      wait(Current_Substate == `Config_Complete);
      All_data={64{8'hff}};

      while(1) begin
        
          PIPE_seq_item  PIPE_seq_item_h;         
          PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
          
              @(posedge PIPE_vif_h.PCLK) 

                        
              if(PIPE_vif_h.TxDataValid == 0) All_data={64{8'hff}}; 


              if((PIPE_vif_h.TxDataValid > 0 ) && (PIPE_vif_h.TxData[511 -: 8 ] != 8'hBC) && (PIPE_vif_h.TxData[511 -: 8 ] != 8'h3E) 
                  && (PIPE_vif_h.TxData[511 -: 8 ] != 8'h45) && (PIPE_vif_h.TxData[511 -: 8 ] != 8'h4A) && (PIPE_vif_h.TxData[511 -: 8 ] != 8'h00)) begin

                          for(int i = 0 ; i<`LANESNUMBER ; i++)begin
              
                          Lane_Datades = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];

                          Descrambled_Data= Descrambled_Data << `MAXPIPEWIDTH ;

                          Descrambled_Data = apply_descramble(de_scrambler,Lane_Datades,i,`GEN1);
                          
                          All_data [(`MAXPIPEWIDTH * i) +: `MAXPIPEWIDTH ] = 0;


                        end
                        break;


                  end

              if(config_idle_complete || time_out)  begin

                  break ;

              end

          

          
      end

      while(1) begin
      
        PIPE_seq_item  PIPE_seq_item_h;         
        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 

            @(posedge PIPE_vif_h.PCLK)  

                if(PIPE_vif_h.TxDataValid == 0) All_data={64{8'hff}};

                        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
            
                        Lane_Datades = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];

                        Descrambled_Data= Descrambled_Data << `MAXPIPEWIDTH ;

                        Descrambled_Data = apply_descramble(de_scrambler,Lane_Datades,i,`GEN1);

                        if(Descrambled_Data == 0)

                        All_data [(`MAXPIPEWIDTH * i) +: `MAXPIPEWIDTH ] = 0;
    
                      end

            if(config_idle_complete || time_out)  begin

              config_idle_complete=0;
              break ;

            end
        

    end

    
    
      reset_lfsr(de_scrambler,`GEN5);

      fork

      begin

        wait(Current_Substate == `Phase1 );

      end

      begin

        wait(time_out) ;

      end
      
    join_any

  

  
  while(1) begin
    
      PIPE_seq_item  PIPE_seq_item_h;         
      PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
      if((PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8] == 8'h1E) )begin

        start_scrambling=1;
      end
      
      if(start_scrambling && (PIPE_vif_h.PCLKRate >=2)    )begin
          for(int i = 0 ; i<`LANESNUMBER ; i++)begin
          
          Lane_Datades = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];


          Descrambled_Data = apply_descramble(de_scrambler,Lane_Datades,i,`GEN5);

          All_data = All_data ^ ( Descrambled_Data << (`MAXPIPEWIDTH * i) );

        end

      end

      if(PIPE_vif_h.TxDataValid == 0) All_data=0;
      
      
      @(posedge PIPE_vif_h.PCLK);
        if(linkup_gen5 || time_out)  begin
              time_out=0;
              linkup_gen5=0;
              break ;

        end
      
  end

end

endtask

task TX_Slave_D_Monitor::run_phase(uvm_phase phase);
  
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver ",UVM_LOW)
      
        fork
              begin
                Pass_PIPE_TX_Signals();
              end
              
              begin
                Monitoring_Substates_Transition();
              end
              
              begin
                Set_Flags();
              end

              begin
                scramble_data();
              end

              begin
                Timer();
              end

              begin
              
                forever begin

                     @(posedge PIPE_vif_h.PCLK)

                     if((PIPE_vif_h.phy_reset == 0))begin 
                          
                        kill_fork=1;
                      end


                  end

              end
              

              
        join
        
        wait fork;
        
endtask: run_phase


task TX_Slave_D_Monitor::Pass_PIPE_TX_Signals();
  
  forever begin
    
     PIPE_seq_item  PIPE_seq_item_h;         
     PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
     
     @(posedge PIPE_vif_h.PCLK)   
  
     PIPE_seq_item_h.TxData                  = PIPE_vif_h.TxData;
     PIPE_seq_item_h.TxDataValid             = PIPE_vif_h.TxDataValid;
     PIPE_seq_item_h.TxElecIdle              = PIPE_vif_h.TxElecIdle;
     PIPE_seq_item_h.TxStartBlock            = PIPE_vif_h.TxStartBlock;
     PIPE_seq_item_h.TxDataK                 = PIPE_vif_h.TxDataK;
     PIPE_seq_item_h.TxSyncHeader            = PIPE_vif_h.TxSyncHeader;
     PIPE_seq_item_h.TxDetectRx_Loopback     = PIPE_vif_h.TxDetectRx_Loopback;
     PIPE_seq_item_h.Rate                    = PIPE_vif_h.Rate ;
     send_ap1.write(PIPE_seq_item_h);
    
   end
  
endtask  
   
  
task TX_Slave_D_Monitor::Monitoring_Substates_Transition();
  
   Next_Substate = `Detect_Quiet;
   
    forever begin

            PIPE_seq_item  PIPE_seq_item_h;         
            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

            if(Next_Substate != `Phase1) begin
                @(posedge PIPE_vif_h.PCLK);
            end

           Current_Substate = Next_Substate;
          

          fork :state_fork

            begin
                    case(Current_Substate)
                      `Detect_Quiet:begin
                        linkup=0;
                        TS_Count=0;
                        Time_out_D_f=0;
                          wait(PIPE_vif_h.phy_reset == 1);
                            assert(PIPE_vif_h.TxDetectRx_Loopback == 0) ;
                            fork:Detect_Quiet_fork

                                            
                              begin
                                
                                #50; // not correct error on design 

                              end

                              begin

                                wait(PIPE_vif_h.TxElecIdle == 0 && PIPE_vif_h.TxDetectRx_Loopback);

                              end 


                            join_any
                            disable Detect_Quiet_fork;

                            `uvm_info(get_type_name() ,"Detect Quiet substate at downstream TX side completed successfully",UVM_LOW)
                            Next_Substate=`Detect_Active;
                            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                            PIPE_seq_item_h.Current_Substate = `Detect_Quiet;                      
                            PIPE_seq_item_h.Next_Substate = `Detect_Active;
                            send_ap2.write(PIPE_seq_item_h);


                  end
              
                  `Detect_Active: begin         
                    fork
                      begin     
                        wait(PIPE_vif_h.PhyStatus == {`LANESNUMBER{1'b1}} && PIPE_vif_h.TxDetectRx_Loopback == {`LANESNUMBER{1'b1}} && PIPE_vif_h.RxStatus == {`LANESNUMBER{3'b011}} );
                        Next_Substate   =`Polling_Active;
                        `uvm_info(get_type_name() , "Detect Active substate at Downstream TX side completed successfully",UVM_LOW)
                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = Current_Substate;
                        PIPE_seq_item_h.Next_Substate = Next_Substate ;
                        send_ap2.write(PIPE_seq_item_h);                     
                      end

                      begin

                                #(12ms / 100);
                                Next_Substate=`Detect_Quiet;
                                `uvm_info(get_type_name() ,"Rx not detected successfully",UVM_LOW)       
                                PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");       
                                PIPE_seq_item_h.Current_Substate = `Detect_Active;
                                PIPE_seq_item_h.Next_Substate = Next_Substate ;
                                PIPE_seq_item_h.time_out = 1 ;
                                send_ap2.write(PIPE_seq_item_h);                      
                      end
                    join_any

                    disable fork;
                    end
              
                  `Polling_Active:begin         
                    fork
                      begin     
                        Polling_Active(); 
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = `Polling_Active;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end
              
                  `Polling_Configuration:begin         
                    fork
                      begin     
                        Polling_Configuration();
                        
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = `Polling_Configuration;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end       
              
                  `Config_Link_Width_Start:begin  
                    PIPE_seq_item_h.start_Timer_D=1;       
                    fork
                      begin     
                        Config_Link_Width_Start(); 
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;
                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                        PIPE_seq_item_h.Current_Substate = `Config_Link_Width_Start;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end     
                      
                  `Config_Link_Width_Accept:begin  
                    PIPE_seq_item_h.start_Timer_D=1;       
            
                    fork
                      begin     
                        Config_Link_Width_Accept(); 
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;
                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                        PIPE_seq_item_h.Current_Substate = `Config_Link_Width_Accept;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end     
              
                  `Config_Lanenum_Wait:begin         
                    fork
                      begin     
                        Config_Lanenum_Wait();
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = `Config_Lanenum_Wait;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end          
              
                  `Config_Lanenum_Accept:begin         
                    fork
                      begin     
                        Config_Lanenum_Accept();
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = `Config_Lanenum_Accept;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end        
              
                  `Config_Complete:begin         
                    fork
                      begin     
                        Config_Complete();
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                        PIPE_seq_item_h.Current_Substate = `Config_Complete;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);
                      end
                    join_any

                    disable fork;
                    end                
                      
                  `Config_Idle: begin     
                                                                        
                    PIPE_seq_item_h.start_Timer_D=1;       
                    fork
                      begin     
                        Config_Idle();
                      end

                      begin
                        wait(Time_out_D_f);
                        `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                        Next_Substate = `Detect_Quiet;
                        Time_out_D_f = 0;

                        PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                        PIPE_seq_item_h.Current_Substate = `Config_Idle;
                        PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                        PIPE_seq_item_h.time_out = 1 ; 
                        send_ap2.write(PIPE_seq_item_h);

                      end
                    join_any

                    disable fork;
                    end                 

                  `L0:                          L0();
                    //here
                  `Recovery_RcvrLock:  begin          
                    
                      fork 
                                                  
                        begin

                          recoveryRcvrLock();

                        end

                        begin

                          wait(Time_out_D_f);
                          
                          
                          if(PIPE_seq_item_h.time_out_to_rec_speed_D)begin
                            PIPE_seq_item_h.time_out_to_rec_speed_D=0;
                            Next_Substate= `Recovery_Speed;
                            `uvm_info(get_type_name() ,"Time out occur , we get back to recovry speed state",UVM_LOW)
                          end
                          else begin
                            `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                            Next_Substate= `Detect_Quiet;
                          end
                            

                          Time_out_D_f=0;

                          PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
                          PIPE_seq_item_h.Current_Substate =  `Recovery_RcvrLock;
                          PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                          PIPE_seq_item_h.time_out = 1 ; 
                          send_ap2.write(PIPE_seq_item_h);

                        end
                      
                      join_any
                      disable fork;

                  end

                  `Recovery_RcvrCfg:begin  
                              
                    PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
                      fork 
                                                  
                        begin

                          recoveryRcvrCfg();
                        end

                        begin
                          wait(Time_out_D_f);
                          `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                          Next_Substate= `Detect_Quiet;
                          Time_out_D_f=0;

                          PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                          PIPE_seq_item_h.Current_Substate = `Recovery_RcvrCfg;
                          PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                          PIPE_seq_item_h.time_out = 1 ; 
                          send_ap2.write(PIPE_seq_item_h);

                        end
                      
                      join_any
                      disable fork;

                  end            

                  `Recovery_Speed:begin 
                      
                      fork
                      begin
                            recoverySpeed();

                      end
                      begin
                            wait(Time_out_D_f);
                            `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                            Next_Substate= `Detect_Quiet;
                            Time_out_D_f=0;

                            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                            PIPE_seq_item_h.Current_Substate = `Recovery_Speed;
                            PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                            PIPE_seq_item_h.time_out = 1 ; 
                            send_ap2.write(PIPE_seq_item_h);
                      end 
                    join_any
                    disable fork;
                  end

                  `Phase1:begin 
                    fork
                      begin
                            phase1();

                      end
                      begin
                            wait(Time_out_D_f);
                            `uvm_info(get_type_name() ,"Time out occur , we get back to recovry speed state",UVM_LOW)
                            Next_Substate= `Recovery_Speed;
                            Time_out_D_f=0;
                            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                            PIPE_seq_item_h.Current_Substate = `Phase1;
                            PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                            PIPE_seq_item_h.time_out = 1 ; 
                            send_ap2.write(PIPE_seq_item_h);

                      end 
                    join_any
                    disable fork;
                  end

                  `Recovery_Idle:begin          
                    
                      fork 
                                                  
                        begin

                          recoveryIdle();
                        end

                        begin
                            wait(Time_out_D_f);
                            `uvm_info(get_type_name() ,"Time out occur , we get back to detect state",UVM_LOW)
                            Next_Substate= `Detect_Quiet;
                            Time_out_D_f=0;
                            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

                            PIPE_seq_item_h.Current_Substate = `Recovery_Idle;
                            PIPE_seq_item_h.Next_Substate =  Next_Substate ;
                            PIPE_seq_item_h.time_out = 1 ; 
                            send_ap2.write(PIPE_seq_item_h);

                        end 
                      
                      join_any
                      disable fork;

                  end                  

                endcase

            end


            begin
              wait((kill_fork || force_detect_trigger_f));
              kill_fork = 0;
              force_detect_trigger_f = 0;

              Next_Substate=`Detect_Quiet;
              linkup=0;
            end
            
          join_any
          disable state_fork;




    end  

endtask


task TX_Slave_D_Monitor::Receiver_Detection();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
  wait(Receiver_Detected);

  `uvm_info(get_type_name() ,"Receiver Detection completed successfully",UVM_LOW)
    
  Next_Substate    = `Polling_Active;
  PIPE_seq_item_h.Current_Substate = Current_Substate;    
  PIPE_seq_item_h.Next_Substate = Next_Substate;
  PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
  send_ap2.write(PIPE_seq_item_h);
endtask


task TX_Slave_D_Monitor::Polling_Active();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
  while(TS_Count < 1024*`LANESNUMBER ) begin
      
    @(posedge PIPE_vif_h.PCLK)
    wait(PIPE_vif_h.TxDataValid != 0);
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
        
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];  
          Symbol_num = s*`MAXPIPEWIDTH/8;

          if(reject_os) rejected_TS++;
          reject_os = 0;

          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
                                                                      
            if(Symbol_num == 0)begin                             
              
                  if(PIPE_vif_h.TxDataK[i +: 1] == 1'b1)begin

                     assert(Lane_Data[k -: 8] == 8'hBC)  
                     else begin 
                      reject_os=1;
                      `uvm_error(get_type_name(),"Missing COM Character")
                     
                     end
                  end
                    
            end
            
            else if(Symbol_num > 5) begin
                  assert(Lane_Data[k -: 8] == 8'h4A)
                  else begin
                    reject_os=1;
                    `uvm_error(get_type_name(),$sformatf("Not Correct TS Identifier %h !",(Lane_Data[k -: 8])))              
                  end
            end
  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end

      if(rejected_TS <= `LANESNUMBER)begin
          
          TS_Count = TS_Count + (`LANESNUMBER - rejected_TS);
      end
      
      rejected_TS=0;
    
    end
     
     ->Polling_Active_Substate_Completed;
     wait(PIPE_seq_item_h.Rx_polling_active_complete_D);
     PIPE_seq_item_h.Rx_polling_active_complete_D=0;

   `uvm_info(get_type_name() ,"Polling Active substate at Downstream TX side completed successfully",UVM_LOW)
     

     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count;    
     PIPE_seq_item_h.TS_Type = `TS1;
     PIPE_seq_item_h.Next_Substate = `Polling_Configuration;
       PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
     send_ap2.write(PIPE_seq_item_h);
     PIPE_seq_item_h.start_Timer_D=1; 
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Polling_Configuration;
  
endtask


task TX_Slave_D_Monitor::Polling_Configuration();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    
  wait(Received_TS2_in_Polling_Configuration_f);
          Received_TS2_in_Polling_Configuration_f = 0;
     
     
  while(TS_Count < 16*`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
        @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;

          if(reject_os) rejected_TS++;

          reject_os = 0;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'hf7 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != 8'hf7 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if(Symbol_num > 6) begin

                  if(Lane_Data[k -: 8] != 8'h45 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   

  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end

      if(rejected_TS<=`LANESNUMBER)begin
          
          TS_Count = TS_Count + (`LANESNUMBER - rejected_TS);
      end
      rejected_TS=0;
    
    end
     


   `uvm_info(get_type_name() ,"Polling Configuration substate at Downstream TX side completed successfully",UVM_LOW)
     
     ->Polling_Configuration_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS2;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Link_Width_Start;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
    send_ap2.write(PIPE_seq_item_h);
    
endtask


task TX_Slave_D_Monitor::Config_Link_Width_Start();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
     
        
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS1_in_Config_Link_Width_Start_f) begin
          Received_2_TS1_in_Config_Link_Width_Start_f = 0;
          break ;

    end
     
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != 8'hf7 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end
    
    end
     
     ->Config_Link_Width_Start_Substate_Completed;
     wait(PIPE_seq_item_h.Rx_Config_Link_Width_Start_D)
     PIPE_seq_item_h.Rx_Config_Link_Width_Start_D =0;
   `uvm_info(get_type_name() ,"Config_Link_Width_Start substate at Downstream TX side completed successfully",UVM_LOW)
   
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Link_Width_Accept;
  PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
    PIPE_seq_item_h.Next_Substate = Next_Substate;
    send_ap2.write(PIPE_seq_item_h);
  
endtask


task TX_Slave_D_Monitor::Config_Link_Width_Accept();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(TS_Count <= `LANESNUMBER*1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);

     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
                   

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Config Link Width Accept substate at Downstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Lanenum_Wait;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
endtask


task TX_Slave_D_Monitor::Config_Lanenum_Wait();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS1_in_Config_Lanenum_Wait_f)begin
          Received_2_TS1_in_Config_Lanenum_Wait_f = 0;
           break ;
    end
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
                   

           end
      
        end
      
      end
    
    end

   `uvm_info(get_type_name() ,"Config Lanenum Wait substate at Downstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Lanenum_Accept;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
endtask


task TX_Slave_D_Monitor::Config_Lanenum_Accept ();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
      
  while(1) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
     
    if(Received_2_TS1_in_Config_Lanenum_Accept_f)begin
          Received_2_TS1_in_Config_Lanenum_Accept_f = 0;
           break ;
    end
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;
           end
      
        end
      
      end
    
    end

   `uvm_info(get_type_name() ,"Config Lanenum Accept substate at Downstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS2;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Complete;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
endtask


task TX_Slave_D_Monitor::Config_Complete();
  
      
      
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    
  wait(Received_TS2_in_Config_Complete);
     
     
  while(TS_Count < 16*`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)
         
        if(PIPE_vif_h.TxData[31:24]!= 8'hBC && Symbol_num == 0) break;
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
            
            if(Symbol_num == 0)begin
 
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;                     
                  
            end
            
            
            else if(Symbol_num == 1) begin
              
                  if(Lane_Data[k -: 8] != 8'h01 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                          reject_os = 1;             
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b1)
                         reject_os = 1;          
             
            end
            
            
            else if(Symbol_num == 6) begin
                  if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                         reject_os = 1;  
              
            end
            
            
            
            else if((Symbol_num > 6) && (Symbol_num !=15)) begin
                  if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                          reject_os = 1;  
              
            end
            
             
   
            else if(Symbol_num == 15) begin
              
              if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0)
                            reject_os = 1; 
                  
              if(!reject_os)          
                       TS_Count = TS_Count + 1;
                     
              reject_os = 0;    
                    
            end   
  
            Symbol_num = Symbol_num + 1;

            
           end
      
        end
      
      end
    
    end
     


   `uvm_info(get_type_name() ,"Config Complete substate at Downstream TX side completed successfully",UVM_LOW)
     
     ->Config_Complete_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS2;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Config_Idle;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);

     reset_lfsr(de_scrambler,1);   
  
  
endtask


task TX_Slave_D_Monitor::Config_Idle();
  
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");    
     
   while(IDLE_Count < 16*`LANESNUMBER) begin 
      
    @(posedge PIPE_vif_h.PCLK)        
                 
          if(All_data == 0)begin

                   IDLE_Count = IDLE_Count+64;    
                   
          end           
                  
   end
    
    wait(Received_Idle_in_Config_Idle_f && PIPE_seq_item_h.Rx_Config_Idle_D);

    Received_Idle_in_Config_Idle_f=0;
    PIPE_seq_item_h.Rx_Config_Idle_D= 0 ;

   `uvm_info(get_type_name() ,"Config Idle substate at Downstream TX side completed successfully",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = IDLE_Count; 
     PIPE_seq_item_h.TS_Type = `IDLE;   
     config_idle_complete =1 ;

     IDLE_Count       = 0;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `L0;
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
     ->LinkUp_Completed_DSD;
  
endtask


task TX_Slave_D_Monitor::L0();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 


 if(PIPE_seq_item_h.Negotiated_Speed_D[4] == 1 && Negotiated_Speed_U[4] ==1)
   
     PIPE_seq_item_h.Highest_Comm_Speed = 4;

 else if(PIPE_seq_item_h.Negotiated_Speed_D[3] == 1 && Negotiated_Speed_U[3] ==1)
   
     PIPE_seq_item_h.Highest_Comm_Speed = 3;

 else if(PIPE_seq_item_h.Negotiated_Speed_D[2] == 1 && Negotiated_Speed_U[2] ==1)
   
     PIPE_seq_item_h.Highest_Comm_Speed = 2;
  

 else if(PIPE_seq_item_h.Negotiated_Speed_D[1] == 1 && Negotiated_Speed_U[1] ==1)
   
     PIPE_seq_item_h.Highest_Comm_Speed = 1;



  wait(LinkUp_Completed_f)//asserted in set flag task

  while(1)begin
    @(posedge PIPE_vif_h.PCLK)


  if( (PIPE_seq_item_h.Highest_Comm_Speed > 1) &&( PIPE_vif_h.Rate <=1)) begin
      directed_speed_change  = 1;
      changed_speed_recovery = 1;


     `uvm_info(get_type_name() ,"Reached L0 state at Downstream TX side successfully ",UVM_LOW)
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     PIPE_seq_item_h.linkup_on_down_stream  =  1'b1;
     send_ap2.write(PIPE_seq_item_h);

     ->L0_state_completed;
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `Recovery_RcvrLock;
     Received_TS1_in_L0_f=0;

     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
     break;
  end
  else begin

    if(PIPE_vif_h.Rate > 1 & !linkup)begin

      `uvm_info(get_type_name() ,"Reached L0 state at Downstream TX side now in GEN 5 ",UVM_LOW);
      linkup=1;
      linkup_gen5=1;

    end
      
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type =  0       ;   
     PIPE_seq_item_h.linkup_on_down_stream  =  1'b1    ;
     
     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    = `L0;
     Received_TS1_in_L0_f=0;
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
     
  end


  end
  


endtask


task TX_Slave_D_Monitor::recoveryRcvrLock();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");


  while(1)begin
      @(posedge PIPE_vif_h.PCLK)
     
      
      if(PIPE_vif_h.Rate == `GEN5 && start_equalization_w_preset_variable)begin
          next_state=`Phase1;
          wanted_count=0;

          break;
      end
      //Yossef delete this line "previous_state==`Phase1 ||" if you managed to put Speed_change_bit_D directed_speed_change in the right values in RX
      else if(previous_state==`Phase1 || PIPE_seq_item_h.Speed_change_bit_D == directed_speed_change /* && Received_TS1_in_recoveryRcvrLock_Substate_f*/)begin
          next_state=`Recovery_RcvrCfg;

          wanted_count=8;

          break;
      end
      else if(PIPE_seq_item_h.Speed_change_bit_D == 0  && Received_TS1_in_recoveryRcvrLock_Substate_f)begin
          next_state=`Config_Link_Width_Start;
          wanted_count=0;
          break;
      end
      else if(!changed_speed_recovery  && PIPE_vif_h.Rate > `GEN1 && Received_TS1_in_recoveryRcvrLock_Substate_f)begin
          next_state=`Recovery_Speed;
          wanted_count=0;
          break;
      end
      else if(TIME_OUT)begin
          next_state=`Detect_Active;
          TIME_OUT=0;
          break;
      end

  end


  


  while(TS_Count < wanted_count * `LANESNUMBER) begin

    
    if(wanted_count == 0) break;

    
    if(PIPE_vif_h.PCLKRate <=1) begin

      
      wait(PIPE_vif_h.TxDataValid != 0 );

    end

    else if(PIPE_vif_h.PCLKRate >=2) begin
        wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0);
    end

    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
      @(posedge PIPE_vif_h.PCLK)     
      #1;

        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hBC /*8'h1E*/ && Symbol_num == 0 )begin

          if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h1E/*8'h2D*/ && Symbol_num == 0 ) begin

             rejected_TS=`LANESNUMBER;

            break;

          end 
         
        end 
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
         
          if(PIPE_vif_h.PCLKRate <=1)begin

                Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          end
          else if(PIPE_vif_h.PCLKRate >=2)begin

                Lane_Data = All_data[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          end
          
          Symbol_num = s*`MAXPIPEWIDTH/8; 

          if(reject_os)begin
            rejected_TS++;
          end
          reject_os = 0;


          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
             
            
            if(Symbol_num == 0)begin
                if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1) begin
                            reject_os = 1;
                    end
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin 
                    
                    if(Lane_Data[k -: 8] != 8'h1E || PIPE_vif_h.TxSyncHeader !=32'haaaa_aaaa)begin
                          reject_os = 1;
                          
                    end

                end
     
            end
            
            
            else if(Symbol_num == 1) begin
                  if(PIPE_vif_h.PCLKRate <= 1)begin
                      if(Lane_Data[k -: 8] != 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                          reject_os = 1;
                      end
                  end               
                  else if(PIPE_vif_h.PCLKRate >= 2)begin
                      if(Lane_Data[k -: 8] != 8'h01 )begin
                             reject_os = 1;
                      end

                  end            
              
            end
            
            
            else if(Symbol_num == 2 ) begin
                if(PIPE_vif_h.PCLKRate <= 1)begin

                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                          reject_os = 1; 
                  end                  
                end
                
                else if(PIPE_vif_h.PCLKRate >= 2)begin

                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i )begin
                             reject_os = 1;
                  end

                end
                     
            end
            
            else if(Symbol_num == 4 )begin
                  if(PIPE_vif_h.PCLKRate <= 1)begin
                    
                    if(Lane_Data[k] != 1'b1 || Lane_Data[ k-4 -: 3] <=1 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin 
                          reject_os = 1;
                    end


                  end
                  else if(PIPE_vif_h.PCLKRate >= 2)begin
                    
                    if(Lane_Data[k] != 1'b0 || Lane_Data[ k-4 -: 3] <=1 )begin
                             reject_os = 1;
                    end

                  end
                  
            end
            
            else if(Symbol_num == 6) begin
                  if(PIPE_vif_h.PCLKRate <= 1)begin
                      
                      if(next_state == `Recovery_RcvrCfg)begin

                        if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0 ) begin
                          reject_os = 1;
                        end

                      end
                      
                  end
                  else if(PIPE_vif_h.PCLKRate >= 2)begin
                    
                      if(next_state == `Recovery_RcvrCfg)begin

                        if(Lane_Data[k-7 -: 2] != 2'b00 ) begin
                             reject_os = 1;

                        end

                      end
                  end
    
            end
            
            
            
            else if((Symbol_num > 9) && next_state == `Recovery_RcvrCfg) begin
                  if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(Lane_Data[k -: 8] != 8'h4A || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin
                      
                      if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1] != 1'b0) begin
                          reject_os = 1;
                      end
                    end
                      
                  end
                  else if(PIPE_vif_h.PCLKRate >= 2)begin

                    if(Lane_Data[k -: 8] != 8'h4A )begin
                      
                      if(Lane_Data[k -: 8] != 8'h45 )begin
                             reject_os = 1;
                      end
                    end

                  end
            
          end         
  
            Symbol_num = Symbol_num + 1;




        end

      end
      All_data=0;
    end
      

      if(rejected_TS<=`LANESNUMBER)begin
          
          TS_Count = TS_Count + (`LANESNUMBER - rejected_TS);
      end
      
      rejected_TS=0;
  end
  ->recoveryRcvrLock_Substate_Completed;
  if(next_state != `Phase1)begin
    wait(PIPE_seq_item_h.Rx_recoveryRcvrLock_D);
    PIPE_seq_item_h.Rx_recoveryRcvrLock_D = 0 ;
  end
  `uvm_info(get_type_name() ,"Recovery.RcvrLock substate at Downstream TX side completed successfully",UVM_LOW)


  PIPE_seq_item_h.Current_Substate = Current_Substate;
  PIPE_seq_item_h.TS_Count = TS_Count; 
  PIPE_seq_item_h.TS_Type = `TS1;   
     send_ap2.write(PIPE_seq_item_h);

  Lane_Data        =  0;
  Symbol_num       =  0;
  TS_Count         =  0;
  Next_Substate    = next_state;
  rejected_TS      =  0;
  reject_os        =  0; 
  next_state       =  0;
  state_completed_successfully=1;
  Received_TS1_in_recoveryRcvrLock_Substate_f=0; 
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

  PIPE_seq_item_h.PCLKRate = PIPE_vif_h.PCLKRate;
  PIPE_seq_item_h.Next_Substate = Next_Substate;
  send_ap2.write(PIPE_seq_item_h);
endtask


task TX_Slave_D_Monitor:: recoveryRcvrCfg();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
  start_equalization_w_preset_variable=1;


  while(1)begin
      @(posedge PIPE_vif_h.PCLK) 

      if(PIPE_seq_item_h.Speed_change_bit_D ==directed_speed_change && PIPE_vif_h.PCLKRate < 4)begin
        next_state  =`Recovery_Speed;
        wanted_count=32;
        PIPE_seq_item_h.TS_Type = `TS2;
        break;

      end
      else if( previous_state == `Phase1 || Received_TS2_in_recoveryRcvrCfg_Substate_f)begin
        next_state  =`Recovery_Idle;
        PIPE_seq_item_h.TS_Type = `TS2;
        wanted_count=16;
        break;
      end

      else if(Received_TS1_in_recoveryRcvrCfg_Substate_f)begin
        next_state  =`Config_Link_Width_Start;
        PIPE_seq_item_h.TS_Type = `TS1;
        wanted_count=8;
        changed_speed_recovery=0;
        directed_speed_change=0;
        break;
      end

      else if(TIME_OUT)begin
        next_state  =`Detect_Active;
        wanted_count=0;
        break;
      end
  end
    
  while(TS_Count < wanted_count *`LANESNUMBER ) begin 

    if(wanted_count == 0) break;
    
       if(PIPE_vif_h.PCLKRate <=1) begin
         
        wait(PIPE_vif_h.TxDataValid != 0 );
   
       end else if(PIPE_vif_h.PCLKRate >=2)begin

        wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0);
       end
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
 
      @(posedge PIPE_vif_h.PCLK) #1; 

        if (PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hBC && Symbol_num == 0 )begin

            if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h2D && Symbol_num == 0)begin
                rejected_TS=`LANESNUMBER;
                break;
            end
        end

        
 
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          if(PIPE_vif_h.PCLKRate <=1)

                Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
   
          else if(PIPE_vif_h.PCLKRate >=2)

                Lane_Data = All_data[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];

          
          Symbol_num = s*`MAXPIPEWIDTH/8;

          if(reject_os) rejected_TS++;
          reject_os = 0;
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin
          
            if(Symbol_num == 0)begin
                if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b1)begin
                          reject_os = 1;
                          
                    end
                      
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin

                    if(Lane_Data[k -: 8] != 8'h2d ||  PIPE_vif_h.TxSyncHeader !=32'haaaa_aaaa) begin
                          reject_os = 1;
                    end

                end   
                    
            
            end

            
            else if(Symbol_num == 1) begin 
                if(PIPE_vif_h.PCLKRate <= 1)begin
                                       

                    if(next_state == `Recovery_Idle )begin 
                      if(Lane_Data[k -: 8] == 8'h7c ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                                TS_Count=0; 
                      end
                    end
                    else if( next_state == `Config_Link_Width_Start)begin
                      if(Lane_Data[k -: 8] == 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                                reject_os = 1; 
                      end
                    end 
                    else if(next_state == `Recovery_Speed)begin
                      if(Lane_Data[k -: 8] != 8'h01 ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                                reject_os = 1; 

                      end
                    end

                      
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin

                    if(next_state == `Recovery_Idle )begin 

                      if(Lane_Data[k -: 8] == 8'h7c  )begin
                            TS_Count=0; //edit

                      end
                                

                    end
                    else if( next_state == `Config_Link_Width_Start)begin
                      if(Lane_Data[k -: 8] == 8'h01 )begin
                                reject_os = 1;

 

                      end

                    end 
                    else if(next_state == `Recovery_Speed)begin
                     
                      if(Lane_Data[k -: 8] != 8'h01 )begin
                                reject_os = 1;
                                 

                      end

                    end
                      

                end
  

            end
            
            
            
            else if(Symbol_num == 2 ) begin
                if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(next_state == `Recovery_Idle )begin 

                      if(Lane_Data[k -: 8] == `LANESNUMBER-1-i ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                                TS_Count=0; 
                      end
                    end
                    else if( next_state == `Config_Link_Width_Start)begin

                      if(Lane_Data[k -: 8] == `LANESNUMBER-1-i ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                                reject_os = 1; 
                      end
                    end 
                    else if(next_state == `Recovery_Speed)begin

                      if(Lane_Data[k -: 8] != `LANESNUMBER-1-i  ||  PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin
                                reject_os = 1;
 
                      end

                    end

                      
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin
                    
                    if(next_state == `Recovery_Idle )begin 

                      if(Lane_Data[k -: 8] != `LANESNUMBER-1-i )begin
                                TS_Count=0;
                                  
                      end
 

                    end

                    else if( next_state == `Config_Link_Width_Start)begin

                      if(Lane_Data[k -: 8] == 8'h01 ) begin
                                reject_os = 1; 
                      end
                    end 

                    else if(next_state == `Recovery_Speed)begin

                      if(Lane_Data[k -: 8] != 8'h01 ) begin
                                reject_os = 1;
                      end
                    end
                      

                end            

            end
            
            else if(Symbol_num == 4 )begin
                
                if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(next_state == `Recovery_Speed)begin
                      if(Lane_Data[k -: 8] != PIPE_seq_item_h.rate_identifier_D || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0
                        || PIPE_seq_item_h.rate_identifier_D  <= 1) begin
                                reject_os = 1; 
                        end          
                    end
                    else if (next_state == `Recovery_Idle)begin
                        if(Lane_Data[k] != 0 || Lane_Data[k-4 -: 3] > 1 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0)begin
                                reject_os = 1; 
                        end

                    end
                      
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin

                    if(next_state == `Recovery_Speed)begin

                      if(Lane_Data[k -: 8] != PIPE_seq_item_h.rate_identifier_D || PIPE_seq_item_h.rate_identifier_D  <= 1) begin

                                reject_os = 1; 
                      end
                    end
                    else if (next_state == `Recovery_Idle)begin
                      
                        if(Lane_Data[k] != 0 || Descrambled_Data[k-2 -: 3] <= 1 )begin
                                reject_os = 1;
                        end 

                    end


                end

            
            end

            else if(Symbol_num > 6) begin
                if(PIPE_vif_h.PCLKRate <= 1)begin

                    if(next_state == `Recovery_Idle || next_state == `Recovery_Speed)begin

                      PIPE_seq_item_h.TS_Type = `TS2; 

                      if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                            reject_os = 1;
                         
                           
                          end

                    end
                    else if( next_state == `Config_Link_Width_Start)begin

                      PIPE_seq_item_h.TS_Type = `TS1; 
                      if(Lane_Data[k -: 8] != 8'h45 || PIPE_vif_h.TxDataK[(((i+1)*(k+1))/8)-1+(i*(Symbol_num % (`MAXPIPEWIDTH / 8 )))] != 1'b0) begin
                            reject_os = 1;
                      end

                    end
                      
                end
                else if(PIPE_vif_h.PCLKRate >= 2)begin

                    if(next_state == `Recovery_Idle || next_state == `Recovery_Speed)begin

                      PIPE_seq_item_h.TS_Type = `TS2; 

                      if(Lane_Data[k -: 8] != 8'h45 )begin
                            reject_os = 1;

                      end



                    end
                    else if( next_state == `Config_Link_Width_Start)begin

                      PIPE_seq_item_h.TS_Type = `TS1;

                      if(Lane_Data[k -: 8] != 8'h45 ) begin
                            
                            reject_os = 1;
                      end

                    end
                      

                end
         
            end
            

            Symbol_num = Symbol_num + 1;
 

           end

        end
        All_data=0;
        end
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end
        rejected_TS=0;

      end

    
    ->recoveryRcvrCfg_Substate_Completed;  
    wait(PIPE_seq_item_h.Rx_recoveryRcvrCfg_D);
    PIPE_seq_item_h.Rx_recoveryRcvrCfg_D = 0;
   `uvm_info(get_type_name() ,"Recovery.RcvrCfg substate at Downstream TX side completed successfully",UVM_LOW)
     

     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count;  
    
    Next_Substate    = next_state;

    Symbol_num       =  0;
    TS_Count         =  0;
    rejected_TS      =  0;
    reject_os        =  0;
    wanted_count     =  0;
    Received_TS2_in_recoveryRcvrCfg_Substate_f=0;
    state_completed_successfully=1;
    TIME_OUT=0;
    PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

    PIPE_seq_item_h.start_Timer_D=`Recovery_Speed;
    PIPE_seq_item_h.PCLKRate = PIPE_vif_h.PCLKRate; //used in the code
    PIPE_seq_item_h.Next_Substate = Next_Substate;
    send_ap2.write(PIPE_seq_item_h);
endtask

task TX_Slave_D_Monitor::recoverySpeed();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 
    
    

  while(TS_Count < 1 *`LANESNUMBER ) begin 
      
    @(posedge PIPE_vif_h.PCLK)
    
    wait(PIPE_vif_h.TxDataValid != 0);
     
    for(int s = 0 ; s< 32/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if((PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hBC && Symbol_num == 0) )begin

          if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h66 && Symbol_num == 0)begin

            rejected_TS=`LANESNUMBER;
            break;

          end
        end
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
            
          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

            
            if(Symbol_num == 0)begin
                  if(Lane_Data[k -: 8] != 8'hBC || PIPE_vif_h.TxDataK != '1)begin

                    if(Lane_Data[k -: 8] != 8'h66 )begin

                          reject_os = 1;

                    end

                  end

                  
            
            end
            else if(Symbol_num > 0) begin      
                  if(Lane_Data[k -: 8] != 8'h7C  )begin
                    
                    if(Lane_Data[k -: 8] != 8'h66 )begin

                          reject_os = 1;

                    end

                  end
                 

            end

            Symbol_num = Symbol_num + 1;
 

           end
        end
      end
      if(rejected_TS <= `LANESNUMBER)begin
        TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
      end


        rejected_TS=0;

      end

      PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `EIOS; 
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;


    send_ap2.write(PIPE_seq_item_h);

    
    wait(PIPE_vif_h.TxElecIdle == 16'hffff);
    Symbol_num=0;
    reject_os=0;
    rejected_TS=0;
    PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h"); 

    while( EIEOS_Count <= 2*`LANESNUMBER )begin
          
          wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock!= 0);
  
    
          
          for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
            
            @(posedge PIPE_vif_h.PCLK)
                            
              for(int i = 0 ; i<`LANESNUMBER ; i++)begin
              
                
                Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
                Symbol_num = s*`MAXPIPEWIDTH/8;
                  
                if(reject_os) rejected_TS++;

                reject_os = 0;
              
                for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

                  if((Symbol_num < 4&& Symbol_num >=0 )||(Symbol_num <12 && Symbol_num >=8 ))begin

                    if(Symbol_num == 0 && PIPE_vif_h.TxSyncHeader != 32'haaaa_aaaa) begin
                        reject_os = 1;
                
                    end

                    if(Lane_Data[k -: 8] != 8'h00)begin
                        reject_os = 1;
                    end
                                  
                  
                  end
                  else begin      
                    if(Lane_Data[k -: 8] != 8'hff)begin
                        reject_os = 1;  
                       
                      end
                  end
        
                  Symbol_num = Symbol_num + 1;
      

                end

              end

          end

          if(rejected_TS <= `LANESNUMBER)begin

            EIEOS_Count=EIEOS_Count+(`LANESNUMBER-rejected_TS);
       
          end

              rejected_TS=0;

            end

      Next_Substate=`Recovery_RcvrLock;

    if(PIPE_vif_h.PCLKRate == 4)begin

      changed_speed_recovery = 1;
    end
    else begin
      changed_speed_recovery = 0;

    end
   `uvm_info(get_type_name() ,"Recovery.Speed substate at Downstream TX side completed successfully",UVM_LOW)
     
     ->recoverySpeed_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = EIEOS_Count; 
     PIPE_seq_item_h.TS_Type = `EIEOS;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;
     PIPE_seq_item_h.PCLKRate = PIPE_vif_h.PCLKRate;
     PIPE_seq_item_h.Next_Substate = Next_Substate;

     send_ap2.write(PIPE_seq_item_h);
     
     Symbol_num       =  0;
     TS_Count         =  0;
     rejected_TS      =  0;
     reject_os        =  0;
     state_completed_successfully=1;
     directed_speed_change=0; 
     EIEOS_Count=0;
endtask





task TX_Slave_D_Monitor::phase1();

  bit start1;
  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

  
  while(1)begin
    
    
    /*if(start1)begin
       @(posedge PIPE_vif_h.PCLK);
    end*/
    
    start1 = 1;  
    
    wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0 );
    
    if( TS_Count >= 2 * `LANESNUMBER ) break;

   
    for(int s = 0; s< 128/`MAXPIPEWIDTH ; s++)begin //4 cycle loop

      @(posedge PIPE_vif_h.PCLK) #1;

      if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h1E && Symbol_num == 0 )begin
        
        if(PIPE_vif_h.TxDataValid != 0)begin
           rejected_TS=`LANESNUMBER;
           break;
        end
        
      end
         
     
    
      for(int i = 0; i< `LANESNUMBER ; i++)begin //16 lane loop

        Lane_Data=All_data[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
        Symbol_num = s*`MAXPIPEWIDTH/8;

       
        
        if(reject_os) rejected_TS++;

            reject_os = 0;

        for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8)begin 

            if(Symbol_num == 0)begin 
                  if(Lane_Data[k -: 8] != 8'h1E ||PIPE_vif_h.TxSyncHeader != 32'haaaa_aaaa)begin
                          reject_os = 1;
                  end
     
            end
            
            
            else if(Symbol_num == 1) begin 
              
                  if(Lane_Data[k -: 8] != 8'h01 )begin
                          reject_os = 1;               
                  end
            end
            
            
            else if(Symbol_num == 2 ) begin 
                  if(Lane_Data[k -: 8] != `LANESNUMBER-1-i)begin
                          reject_os = 1;  
                  end        
             
            end
            
           else if(Symbol_num == 4 )begin
                  
                  if( Lane_Data[k-2 -: 3] <=1 || Lane_Data[k-6] !=1 )begin
                        reject_os = 1;
                  end
            end
            
            else if(Symbol_num == 6) begin
                  
                  if(Lane_Data[ k-6 -: 2 ] != 2'b01 )begin
                        reject_os = 1;
                  end

            end

            else if(Symbol_num == 7) begin
                  
                  if(Lane_Data[ k-2 -: 6 ] != PIPE_vif_h.FS[i*6 +: 6] )begin
                        reject_os = 1;
                  end

            end

            else if(Symbol_num == 8) begin
                  if(Lane_Data[ k-2 -: 6 ] != PIPE_vif_h.LF[i*6 +: 6] )begin
                         reject_os = 1;
                  end

            end
            

            else if(Symbol_num > 9) begin
                  if(Lane_Data[k -: 8] != 8'h4A )begin
                         reject_os = 1;
                    end

            end
            

  
            Symbol_num = Symbol_num + 1;


        end
      end
      All_data=0;
    end

    if(rejected_TS <= `LANESNUMBER) begin

      TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);

    end
    
        rejected_TS=0;

  end

  `uvm_info(get_type_name() ,"Phase1 substate at Downstream TX side completed successfully",UVM_LOW)

    ->phase1_Substate_Completed;
     
     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `TS1;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     Symbol_num       =  0;
     TS_Count         =  0;
     rejected_TS      =  0;
     Next_Substate    = `Recovery_RcvrLock;

     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
     start_equalization_w_preset_variable=0;
     previous_state=`Phase1;

    
endtask

task TX_Slave_D_Monitor::recoveryIdle();

  PIPE_seq_item  PIPE_seq_item_h;         
  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");


  while(TS_Count  < 1 * `LANESNUMBER ) begin 

    wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0 );
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)

        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'h99 && Symbol_num == 0 )begin
          if(PIPE_vif_h.TxDataValid != 0)begin
            rejected_TS=`LANESNUMBER;
           break;
          end
        
        end
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;
          

          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

            if(Symbol_num == 0 )begin 

                if(Lane_Data[k -: 8] != 8'h99 || PIPE_vif_h.TxSyncHeader != 32'haaaa_aaaa)
                          reject_os = 1; 

            end

            if(Symbol_num >= 1 && Symbol_num < 12 )begin  
                
                if(Lane_Data[k -: 8] != 8'h99 )
                          reject_os = 1; 

            end

            else if(Symbol_num == 12) begin 

                if(Lane_Data[k -: 8] != 8'hE1 )
                          reject_os = 1; 
 
                    
            end

            else if(Symbol_num > 12) begin 

                if(Lane_Data[k -: 8] != 8'h00 )
                          reject_os = 1; 

                    
            end

            Symbol_num = Symbol_num + 1;

          end
            

        end

    end
       
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

  end

  
    PIPE_seq_item_h.Current_Substate = Current_Substate;
    PIPE_seq_item_h.TS_Count = TS_Count; 
    PIPE_seq_item_h.TS_Type = `SKP;   
    PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

    send_ap2.write(PIPE_seq_item_h);
    Symbol_num=0;
    rejected_TS=0;
    reject_os=0;
    TS_Count=0;

  //---detect sds //

  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

  while(TS_Count  < 1 * `LANESNUMBER ) begin 
    
    
    wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0 );
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
  

        if(PIPE_vif_h.TxData[`MAXPIPEWIDTH-1 -: 8]!= 8'hE1 && Symbol_num == 0 )begin
          if(PIPE_vif_h.TxDataValid != 0)begin
            rejected_TS=`LANESNUMBER;
           break;
          end
        
        end
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
          
          Lane_Data = PIPE_vif_h.TxData[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;

          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

           
            if(Symbol_num == 0)begin  
             
                if(Lane_Data[k -: 8] != 8'hE1 || PIPE_vif_h.TxSyncHeader != 32'haaaa_aaaa)
                          reject_os = 1;

            end

            else if(Symbol_num >= 1) begin 

                if(Lane_Data[k -: 8] != 8'h87 )
                          reject_os = 1; 
                    
            end

            Symbol_num = Symbol_num + 1;

          end
            
 

        end

    end
       
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

  end 

  PIPE_seq_item_h.Current_Substate = Current_Substate;
  PIPE_seq_item_h.TS_Count = TS_Count; 
  PIPE_seq_item_h.TS_Type = `SDS;   
  PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

  send_ap2.write(PIPE_seq_item_h);

  Symbol_num=0;
  rejected_TS=0;
  reject_os=0;
  TS_Count=0;

  PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");

  while(TS_Count  < 16 * `LANESNUMBER ) begin 
    
    wait(PIPE_vif_h.TxDataValid != 0 && PIPE_vif_h.TxStartBlock != 0 );
    for(int s = 0 ; s<128/`MAXPIPEWIDTH; s++)begin
      
       @(posedge PIPE_vif_h.PCLK)
         
        if(All_data[`MAXPIPEWIDTH-1 -: 8]!= 8'h00 && Symbol_num == 0 )begin
          if(PIPE_vif_h.TxDataValid != 0)begin
            rejected_TS=`LANESNUMBER;
           break;
          end
        
        end
         
        for(int i = 0 ; i<`LANESNUMBER ; i++)begin
        
          
          Lane_Data=All_data[i*`MAXPIPEWIDTH +: `MAXPIPEWIDTH];
          Symbol_num = s*`MAXPIPEWIDTH/8;          

          if(reject_os) rejected_TS++;

          reject_os = 0;
         
          for(int k = `MAXPIPEWIDTH-1 ; k>0 ; k=k-8 ) begin

           
            if(Symbol_num == 0)begin  
             
                  if(Lane_Data[k -: 8] != 8'h00 || PIPE_vif_h.TxSyncHeader != 32'haaaa_aaaa)
                          reject_os = 1;
 
            end

            else if(Symbol_num >= 1) begin 

                if(Lane_Data[k -: 8] != 8'h00 )
                          reject_os = 1;
                    
            end
                     
          end
            
            Symbol_num = Symbol_num + 1;
 

        end

    end
       
        if(rejected_TS <= `LANESNUMBER)begin
          TS_Count=TS_Count+(`LANESNUMBER-rejected_TS);
        end

        rejected_TS=0;

  end
    

         ->recoveryIdle_Substate_Completed;
    wait(PIPE_seq_item_h.Rx_recoveryIdle_D);
    PIPE_seq_item_h.Rx_recoveryIdle_D = 0;
   `uvm_info(get_type_name() ,"Recovery.Idle substate at Downstream TX side completed successfully",UVM_LOW)
     

     PIPE_seq_item_h.Current_Substate = Current_Substate;
     PIPE_seq_item_h.TS_Count = TS_Count; 
     PIPE_seq_item_h.TS_Type = `IDLE;   
     PIPE_seq_item_h.Rate = PIPE_vif_h.Rate;

     Symbol_num       =  0;
     TS_Count         =  0;
     Next_Substate    =  `L0;
     next_state       =  0;
     PIPE_seq_item_h.Next_Substate = Next_Substate;
     send_ap2.write(PIPE_seq_item_h);
endtask

task TX_Slave_D_Monitor::Set_Flags();
  
  
    fork

        begin  
        forever begin       
          wait(Received_TS2_in_Polling_Configuration);
          Received_TS2_in_Polling_Configuration_f = 1;
        end
       end
    
       begin  
        forever begin       
          wait(Received_2_TS1_in_Config_Link_Width_Start);
          Received_2_TS1_in_Config_Link_Width_Start_f = 1;
        end
       end
    
     
       begin  
        forever begin          
         wait(Received_2_TS1_in_Config_Link_Width_Accept);
         Received_2_TS1_in_Config_Link_Width_Accept_f = 1;
        end
       end
         
     
     
       begin
        forever begin   
          wait(Received_2_TS1_in_Config_Lanenum_Wait);
          Received_2_TS1_in_Config_Lanenum_Wait_f = 1; 
        end        
       end    


       begin
        forever begin    
          wait(Received_2_TS1_in_Config_Lanenum_Accept);
          Received_2_TS1_in_Config_Lanenum_Accept_f = 1; 
        end       
       end  
       
       begin
        forever begin   
          wait(Received_Idle_in_Config_Idle);
            Received_Idle_in_Config_Idle_f = 1;
        end
       end
      
      begin
        forever begin
          wait(LinkUp_Completed_DSD);
            LinkUp_Completed_f=1;
        end
      end 
        
      begin
        forever begin
          wait(Received_TS1_in_L0);
          Received_TS1_in_L0_f=1;
        end
         
      end

      begin
        forever begin
          wait(Received_TS1_in_recoveryRcvrLock_Substate);
          Received_TS1_in_recoveryRcvrLock_Substate_f=1;
        end
        
      end

      begin
        forever begin 
          wait(Received_8_TS2_in_recoveryRcvrLock_Substate);
          Received_8_TS2_in_recoveryRcvrLock_Substate_f=1;
        end
      end

      begin 
        forever begin 
          wait(Received_TS2_in_recoveryRcvrCfg_Substate);
          Received_TS2_in_recoveryRcvrCfg_Substate_f=1;
        end
      end

      begin
        forever begin 
          wait(Received_TS1_in_recoveryRcvrCfg_Substate);
          Received_TS1_in_recoveryRcvrCfg_Substate_f=1;
        end
      end


      begin
        forever begin 
          wait(Device_on_electrical_ideal);
          Device_on_electrical_ideal_f=1;
        end
      end

      begin
        forever begin 
          wait(Received_IDLE_in_recoveryIdle_Substate);
          Received_IDLE_in_recoveryIdle_Substate_f=1;
        end
      end

      begin
        forever begin 
          wait(Received_TS1_in_recoveryIdle_Substate);
          Received_TS1_in_recoveryIdle_Substate_f=1;
        end
      end

   
      begin
        forever begin 
          wait(Received_TS1_in_phase1);
          Received_TS1_in_phase1_f=1;
        end
      end


      begin
        forever begin 
          wait(force_detect_trigger);
          force_detect_trigger_f=1;
        end


      end

    join
  
  
  
  Received_2_TS1_in_Config_Link_Width_Start_f = 0;
  Received_2_TS1_in_Config_Link_Width_Accept_f = 0;
  Received_2_TS1_in_Config_Lanenum_Wait_f = 0;    
  Received_2_TS1_in_Config_Lanenum_Accept_f = 0; 
  Received_Idle_in_Config_Idle_f= 0;
  LinkUp_Completed_f=0;
  Received_TS1_in_L0_f=0;
  Received_TS1_in_recoveryRcvrLock_Substate_f=0;
  Received_TS2_in_recoveryRcvrCfg_Substate_f=0;

  Device_on_electrical_ideal_f=0;
  Received_IDLE_in_recoveryIdle_Substate_f=0;
  Received_TS1_in_recoveryIdle_Substate_f=0;
  
  
endtask

task TX_Slave_D_Monitor::Timer();
        forever begin
                wait(Time_out_D);
                Time_out_D_f=1;
                time_out =1;
        end

endtask
