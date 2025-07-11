class Adapter extends uvm_component;

  `uvm_component_utils(Adapter)
 
  typedef enum {COM,Link_Number,Lane_Number,Speed_Change,Supported_Speed,TS_ID,Bypass,Prevent,EC,LF,FS,IDLE} Error_Inject;
  randc Error_Inject Error_Inject_Operation;

  rand byte COM_Value,Link_Number_Value,Lane_Number_Value,Supported_Speed_Value,TS_ID_Value;
  randc bit [5:0] LF_Value,FS_Value;
  randc bit [1:0] EC_Value;
  rand bit [32:0] IDLE_Value;
  static int TS_quarter_D,TS_quarter_U;


  static int TS_num_to_up = 0 ;
  static int TS_num_to_down = 0 ;
  static bit [2:0] err_index = 3'b000;
  static bit [2:0] err_index2 = 3'b000;
  bit first_time_down =1'b1;
  bit first_time_up =1'b1;

  

  uvm_analysis_port#(PIPE_seq_item)     Adapter_To_D_RX_ap;
  uvm_analysis_port#(PIPE_seq_item)     Adapter_To_U_RX_ap;

  
  uvm_tlm_analysis_fifo#(PIPE_seq_item) Adapter_From_D_TX_af;
  uvm_tlm_analysis_fifo#(PIPE_seq_item) Adapter_From_U_TX_af;
  
  
  PIPE_seq_item PIPE_seq_item_From_Up;
  PIPE_seq_item PIPE_seq_item_From_Down;

  PIPE_seq_item PIPE_seq_item_f;


  extern function void inject_error_Polling_Active(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Polling_Configration(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);

  extern function void inject_error_Config_Link_Width_Start(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Link_Width_Accept(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Lanenum_Wait(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Lanenum_Accept(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Complete(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Idle(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);

  extern function void inject_error_rec_CFG(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down,PIPE_seq_item PIPE_seq_item_f);
  extern function void inject_error_phase1(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_rec_speed(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  
  extern function void inject_error_Rec_Lock(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_rec_idle(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_phase0(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  
  extern function void inject_error_Config_Complete_U(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
  extern function void inject_error_Config_Lanenum_Accept_U(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);

  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Inside Adapter class constructor", UVM_LOW);


    Adapter_To_D_RX_ap = new("Adapter_To_D_RX_ap", this);
    Adapter_To_U_RX_ap = new("Adapter_To_U_RX_ap", this);


    Adapter_From_D_TX_af = new("Adapter_From_D_TX_af", this);
    Adapter_From_U_TX_af = new("Adapter_From_U_TX_af", this);
    
  endfunction




  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Inside Adapter class build phase", UVM_LOW);
    
  endfunction




  task run_phase(uvm_phase phase);
    
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Inside Adapter class run phase", UVM_LOW);


             begin

                forever begin
                  PIPE_seq_item_f = PIPE_seq_item::type_id::create("PIPE_seq_item_From_Up");
                  PIPE_seq_item_From_Up = PIPE_seq_item::type_id::create("PIPE_seq_item_From_Up");
                  

                  Adapter_From_D_TX_af.get(PIPE_seq_item_From_Down);
                  Adapter_From_U_TX_af.get(PIPE_seq_item_From_Up);
                                     

                  if( PIPE_seq_item_From_Up.Current_Substate_D == PIPE_seq_item_f.substate_error_in_down )begin
                          Inject_Error_2Down();
                  end
                  else if(PIPE_seq_item_From_Up.Current_Substate_U == PIPE_seq_item_f.substate_error_in_Up)begin
                          Inject_Error_2UP();
                  end
                  else begin
                      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down); 
                  end


                end 

             end 
        
        
  endtask





 task ByPassData2Up();
   
   
     forever begin
       
      Adapter_From_D_TX_af.get(PIPE_seq_item_From_Down);
   
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);  
      
    end
   
   
 endtask
 




 task ByPassData2Down();
   
   
   forever begin
   
       Adapter_From_U_TX_af.get(PIPE_seq_item_From_Up);
   
       Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
   
   end
   
   
 endtask

 task Inject_Error_2Down();
   
    case(PIPE_seq_item_From_Up.Current_Substate_D)

      `Polling_Active:begin

          inject_error_Polling_Active( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Polling_Configuration:begin

          inject_error_Polling_Configration( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Link_Width_Start:begin

          inject_error_Config_Link_Width_Start( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down); 


      end
      `Config_Link_Width_Accept:begin

          inject_error_Config_Link_Width_Accept( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Lanenum_Wait:begin

          inject_error_Config_Lanenum_Wait( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Lanenum_Accept:begin

            inject_error_Config_Lanenum_Accept( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Complete:begin

            inject_error_Config_Complete( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Idle:begin

            inject_error_Config_Idle( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Recovery_RcvrLock:begin
        inject_error_Rec_Lock(PIPE_seq_item_From_Up,PIPE_seq_item_From_Down);

      end
      `Recovery_RcvrCfg:begin

        inject_error_rec_CFG(PIPE_seq_item_From_Up,PIPE_seq_item_From_Down,PIPE_seq_item_f);

      end
      `Phase0:begin

        inject_error_phase0(PIPE_seq_item_From_Up ,PIPE_seq_item_From_Down);
        
      end
      `Phase1:begin

        inject_error_phase1(PIPE_seq_item_From_Up,PIPE_seq_item_From_Down);

      end
      `Recovery_Speed:begin

          inject_error_rec_speed(PIPE_seq_item_From_Up,PIPE_seq_item_From_Down);

      end
      `Recovery_Idle:begin

          inject_error_rec_idle(PIPE_seq_item_From_Up,PIPE_seq_item_From_Down);

      end



    endcase

    

 endtask


 task Inject_Error_2UP();
   
    case(PIPE_seq_item_From_Up.Current_Substate_U)

      `Config_Complete:begin

            inject_error_Config_Complete_U( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end
      `Config_Lanenum_Accept:begin

            inject_error_Config_Lanenum_Accept_U( PIPE_seq_item_From_Up, PIPE_seq_item_From_Down);

      end

    endcase

    
 endtask

 



endclass




function void Adapter::inject_error_Polling_Active(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
      //com not correct 3'b000
      //pad link not padded 3'b001
      //pad lane not padded 3'b010
      //rate bits zeros 3'b011
      //speed change bit not zero 3'b100
      //OS id wrong 3'b101
      //switch TS1 id with TS2 id 3'b110
      //com s1
      //link num s2
      //lane num s3
      //rate bits s5
      //speed change bit s5
      //TS_id s7->16
      int sym =0; //injection traget sym
      int sym_updated = 0;
      int get_cycle =0;
      int sym_cycle = `MAXPIPEWIDTH/8;
      if((PIPE_seq_item_From_Up.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_down = 0;
            if(first_time_down == 1'b1)begin
              err_index2 = 3'b000;
              first_time_down = 1'b0;
            end
            else
              err_index2 = err_index2 + 1;
            
      end
      else
            TS_num_to_down++;

      if((PIPE_seq_item_From_Down.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_up = 0;
            if(first_time_up == 1'b1)begin
              err_index = 3'b000;
              first_time_up = 1'b0;
            end
            else
              err_index = err_index + 1;
            
      end
      else
            TS_num_to_up++;

      
      
      
      case(err_index)
            
            3'b000:begin //com injection

                  sym = 1;
                  get_cycle = 0;   
            
                  if(TS_num_to_up == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com
                             
                        end
                  end
            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   
            

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; //  block the pad of link num 
                              
                        end
                  end
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0; 

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; //  block the pad of lane num 
                              
                        end
                  end
            end
            3'b011:begin //rate bits injection
                  sym = 1;
                  get_cycle = 1;   
            

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-3 -: 5] = 5'b00000; // block the rate bits      
                              
                        end
                  end
            end

            3'b100:begin //TS1_id injection
                   
                  if(PIPE_seq_item_From_Down.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end

                  end
            end

      endcase
      case(err_index2)
            
            3'b000:begin //com injection

                  sym = 1;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com 
                              
                        end
                  end

            end
            3'b001:begin //link num injection
                  sym = 2;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the pad of link num
                             
                        end
                  end
                  
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;

            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the pad of lane num 
                              
                        end
                  end

            end
            3'b011:begin //rate bits injection
                  sym = 1;
                  get_cycle = 1;   

            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-3 -: 5] = 5'b00000; // block the rate bits 
                              
                        end
                  end

            end

            3'b100:begin //TS1_id injection

            
                  if(PIPE_seq_item_From_Up.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end
                  end

            end


      endcase
      if(err_index == 3'b100 && TS_num_to_up ==3)  //change the the err_index to the last available error injection to use the commented types
            first_time_up = 1'b1;

      if(err_index2 == 3'b100 && TS_num_to_down ==3)
            first_time_down = 1'b1;
                        
                        Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                        Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

endfunction
function void Adapter::inject_error_Polling_Configration(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
      //com not correct 3'b000
      //pad link not padded 3'b001
      //pad lane not padded 3'b010
      //rate bits zeros 3'b011
      //speed change bit not zero 3'b100
      //OS id wrong 3'b101
      //switch TS1 id with TS2 id 3'b110
      //com s1
      //link num s2
      //lane num s3
      //rate bits s5
      //speed change bit s5
      //TS_id s7->16
      int sym =0; //injection traget sym
      int sym_updated = 0;
      int get_cycle =0;
      int sym_cycle = `MAXPIPEWIDTH/8;
      if((PIPE_seq_item_From_Up.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_down = 0;
            if(first_time_down == 1'b1)begin
              err_index2 = 3'b000;
              first_time_down = 1'b0;
            end
            else
              err_index2 = err_index2 + 1;
            
      end
      else
            TS_num_to_down++;

      if((PIPE_seq_item_From_Down.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_up = 0;
            if(first_time_up == 1'b1)begin
              err_index = 3'b000;
              first_time_up = 1'b0;
            end
            else
              err_index = err_index + 1;
            
      end
      else
            TS_num_to_up++;

      
      
      
      case(err_index)
            
            3'b000:begin //com injection

                  sym = 1;
                  get_cycle = 0;   
            

                  if(TS_num_to_up == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com
                             
                        end
                  end
            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   
            

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; //  block the pad of link num 
                              
                        end
                  end
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;  
            
                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; //  block the pad of lane num 
                              
                        end
                  end
            end
            3'b011:begin //rate bits injection
                  sym = 1;
                  get_cycle = 1;   

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-3 -: 5] = 5'b00000; // block the rate bits      
                              
                        end
                  end
            end

            3'b100:begin //TS2_id injection
            
 
                  if(PIPE_seq_item_From_Down.TxData == {64{8'h45}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS2 id
                              
                        end
                  end
            end


      endcase
      case(err_index2)
            
            3'b000:begin //com injection
                  sym = 1;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com 
                              
                        end
                  end

            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the pad of link num
                             
                        end
                  end
                  

            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;

                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the pad of lane num 
                              
                        end
                  end
 
            end
            3'b011:begin //rate bits injection
                  sym = 1;
                  get_cycle = 1;   

                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-3 -: 5] = 5'b00000; // block the rate bits 
                              
                        end
                  end

            end

            3'b100:begin //TS2_id injection

            
                  if(PIPE_seq_item_From_Up.TxData == {64{8'h45}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS2 id
                              
                        end
                  end

            end

      endcase
      if(err_index == 3'b100 && TS_num_to_up ==3)
            first_time_up = 1'b1;

      if(err_index2 == 3'b100 && TS_num_to_down ==3)
            first_time_down = 1'b1;
                        
                        Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                        Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

endfunction 


function void Adapter::inject_error_Config_Link_Width_Start(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
      //com not correct 3'b000
      //pad link not padded 3'b001
      //pad lane not padded 3'b010
      //rate bits zeros 3'b011
      //speed change bit not zero 3'b100
      //OS id wrong 3'b101
      //switch TS1 id with TS2 id 3'b110
      //com s1
      //link num s2
      //lane num s3
      //rate bits s5
      //speed change bit s5
      //TS_id s7->16
      int sym =0; //injection traget sym
      int sym_updated = 0;
      int get_cycle =0;
      int sym_cycle = `MAXPIPEWIDTH/8;

      if((PIPE_seq_item_From_Up.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_down = 0;
            if(first_time_down == 1'b1)begin
              err_index2 = 3'b000;
              first_time_down = 1'b0;
            end
            else
              err_index2 = err_index2 + 1;
            
      end
      else
            TS_num_to_down++;

      if((PIPE_seq_item_From_Down.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_up = 0;
            if(first_time_up == 1'b1)begin
              err_index = 3'b000;
              first_time_up = 1'b0;
            end
            else
              err_index = err_index + 1;
            
      end
      else
            TS_num_to_up++;

      
      
      
      case(err_index)
            
            3'b000:begin //com injection
                  sym = 1;
                  get_cycle = 0;   

                  if(TS_num_to_up == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com
                             
                        end
                  end
            end
            3'b001:begin //link num //
                  sym = 2;
                  get_cycle = 0;   

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'hf7; //  block the pad of link num 
                              
                        end
                  end
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; //  block the pad of lane num 
                              
                        end
                  end
            end
 
            3'b100:begin //TS1_id injection

                  if(PIPE_seq_item_From_Down.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end
                  end
            end
            3'b110:begin //TS1_id injection
                   
                              PIPE_seq_item_From_Down.TxData = 0; 
                              

            end
            3'b111:begin //TS1_id injection

                             PIPE_seq_item_From_Down.TxData = 0; 
            end
            default:begin
                             PIPE_seq_item_From_Down.TxData = 0; 


            end

      endcase
      case(err_index2)
            
            3'b000:begin //com injection
 
                  sym = 1;
                  get_cycle = 0;   

                  if(TS_num_to_down == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com 
                              
                        end
                  end

            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   

                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'hf7; // block the pad of link num
                             
                        end
                  end
                  
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;

                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the pad of lane num 
                              
                        end
                  end

            end

            3'b100:begin //TS1_id injection
                   


                  if(PIPE_seq_item_From_Up.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end
                  end

            end
            3'b110:begin //TS1_id injection


                              PIPE_seq_item_From_Up.TxData = 0; 
                              

            end
            3'b111:begin //TS1_id injection

                             PIPE_seq_item_From_Up.TxData = 0; 
            end
            default:begin

                             PIPE_seq_item_From_Up.TxData = 0; 

            end


      endcase
      if(err_index == 3'b100 && TS_num_to_up ==3)  //change the the err_index to the last available error injection to use the commented types
            first_time_up = 1'b1;

      if(err_index2 == 3'b100 && TS_num_to_down ==3)
            first_time_down = 1'b1;
                        
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction

function void Adapter::inject_error_Config_Link_Width_Accept(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down); 

      //com not correct 3'b000
      //pad link not padded 3'b001
      //pad lane not padded 3'b010
      //rate bits zeros 3'b011
      //speed change bit not zero 3'b100
      //OS id wrong 3'b101
      //switch TS1 id with TS2 id 3'b110
      //com s1
      //link num s2
      //lane num s3
      //rate bits s5
      //speed change bit s5
      //TS_id s7->16
      int sym =0; //injection traget sym
      int sym_updated = 0;
      int get_cycle =0;
      int sym_cycle = `MAXPIPEWIDTH/8;

      if((PIPE_seq_item_From_Up.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_down = 0;
            if(first_time_down == 1'b1)begin
              err_index2 = 3'b000;
              first_time_down = 1'b0;
            end
            else
              err_index2 = err_index2 + 1;
            
      end
      else
            TS_num_to_down++;

      if((PIPE_seq_item_From_Down.TxData[31 -: 8]==8'hBC ) )begin //checking for com 
            TS_num_to_up = 0;
            if(first_time_up == 1'b1)begin
              err_index = 3'b000;
              first_time_up = 1'b0;
            end
            else
              err_index = err_index + 1;
            
      end
      else
            TS_num_to_up++;

      
      
      
      case(err_index)
            
            3'b000:begin //com injection

                  sym = 1;
                  get_cycle = 0;   
            
                  if(TS_num_to_up == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com
                             
                        end
                  end
            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   
            

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h3; //  block the pad of link num 
                              
                        end
                  end
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;
   

                  if(TS_num_to_up == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h55; //  block the pad of lane num 
                              
                        end
                  end
            end

            3'b100:begin //TS1_id injection


                  if(PIPE_seq_item_From_Down.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Down.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end
                  end
            end
            default:begin

                              PIPE_seq_item_From_Down.TxData = 0; // block TS1 id


            end

      endcase
      case(err_index2)
            
            3'b000:begin //com injection

                  sym = 1;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin //first part of TS
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h00; // block the com 
                              
                        end
                  end

            end
            3'b001:begin //link num injection

                  sym = 2;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h3; // block the pad of link num
                             
                        end
                  end
                  
            end
            3'b010:begin //lane num injection
                  sym = 3;
                  get_cycle = 0;   
            
                  if(TS_num_to_down == get_cycle)begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-((sym-1)*8)-1 -: 8] = 8'h55; // block the pad of lane num 
                              
                        end
                  end

            end

            3'b100:begin //TS1_id injection
            
                  if(PIPE_seq_item_From_Up.TxData == {64{8'h4A}})begin 
                        for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                              PIPE_seq_item_From_Up.TxData[(j*`MAXPIPEWIDTH)-1 -: 32] = 32'h00000000; // block TS1 id
                              
                        end
                  end

            end
            default:begin

                              PIPE_seq_item_From_Up.TxData = 0; // block TS1 id


            end

      endcase
      if(err_index == 3'b100 && TS_num_to_up ==3)  //change the the err_index to the last available error injection to use the commented types
            first_time_up = 1'b1;

      if(err_index2 == 3'b100 && TS_num_to_down ==3)
            first_time_down = 1'b1;
                        
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction

function void Adapter::inject_error_Config_Lanenum_Wait(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);

                  for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                        if(8'hBC == PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-1) -: 8])begin

                              PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-1) -: 8] = 8'hF7; // COM error 
                        end
                  end

                  for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                        if(8'hBC == PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-1) -: 8])begin

                              PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-1) -: 8] = 8'hF7; // COM error 
                        end
                  end
                  
                  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                  Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction

function void Adapter::inject_error_Config_Lanenum_Accept(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);  
                  
                 static int counter;

                        if(PIPE_seq_item_From_Up.TxData[511 -: 8]== 8'hbc)begin
                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-9) -: 8])begin

                                          PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-9) -: 8] = 8'hF7; // link number shouldn't be PAD 
                                    end
                              end



                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-17) -: 8])begin

                                          PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-17) -: 8] = 8'hF7; // lane number shouldn't be PAD 
                                    end
                              end

                        end

                        if(PIPE_seq_item_From_Down.TxData[511 -: 8]== 8'hbc)begin
                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-17) -: 8])begin

                                          PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-17) -: 8] = 8'hF7; // lane number shouldn't be PAD 
                                    end
                              end

                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-9) -: 8])begin

                                          PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-9) -: 8] = 8'hF7; // link number shouldn't be PAD 
                                    end
                              end


                        end



                // end
                 counter ++;


                  
                  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                  Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction

function void Adapter::inject_error_Config_Lanenum_Accept_U(PIPE_seq_item PIPE_seq_item_From_Up,PIPE_seq_item PIPE_seq_item_From_Down);
                 static int counter;

                        if(PIPE_seq_item_From_Up.TxData[511 -: 8]== 8'hbc)begin
                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-9) -: 8])begin

                                          PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-9) -: 8] = 8'hF7; // link number shouldn't be PAD 
                                    end
                              end



                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-17) -: 8])begin

                                          PIPE_seq_item_From_Up.TxData[((j*`MAXPIPEWIDTH)-17) -: 8] = 8'hF7; // lane number shouldn't be PAD 
                                    end
                              end

                        end

                        if(PIPE_seq_item_From_Down.TxData[511 -: 8]== 8'hbc)begin
                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-17) -: 8])begin

                                          PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-17) -: 8] = 8'hF7; // lane number shouldn't be PAD 
                                    end
                              end

                              for (int j =1 ;j<=`LANESNUMBER ; j=j+1 ) begin

                                    if(8'hF7 != PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-9) -: 8])begin

                                          PIPE_seq_item_From_Down.TxData[((j*`MAXPIPEWIDTH)-9) -: 8] = 8'hF7; // link number shouldn't be PAD 
                                    end
                              end


                        end



                // end
                 counter ++;


                  
                  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                  Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
endfunction

function void Adapter::inject_error_Config_Complete(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
                  if( PIPE_seq_item_From_Up.TxData[7 : 0 ] == 8'h45)

                         PIPE_seq_item_From_Up.TxData= {64{8'h4a}};

                  if( PIPE_seq_item_From_Down.TxData[7 : 0 ] == 8'h45)

                        PIPE_seq_item_From_Down.TxData= {64{8'h4a}};
                  
                  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
                  Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction


function void Adapter::inject_error_Config_Complete_U(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);

      if( PIPE_seq_item_From_Up.TxData[7 : 0 ] == 8'h45)

            PIPE_seq_item_From_Up.TxData= {64{8'h4a}};

      if( PIPE_seq_item_From_Down.TxData[7 : 0 ] == 8'h45)

            PIPE_seq_item_From_Down.TxData= {64{8'h4a}};
                  
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

endfunction


function void Adapter::inject_error_Config_Idle(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);

      
      PIPE_seq_item_From_Down.TxData = {64{8'h4a}} ; //  block the pad of link num 

      PIPE_seq_item_From_Up.TxData   = {64{8'h4a}} ; // speed change bit 
        
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
                  
endfunction


function void Adapter::inject_error_rec_CFG(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down,PIPE_seq_item PIPE_seq_item_f);
    static int counter ;
    static bit speed_change_bit_u,speed_change_bit_D;

    if(PIPE_seq_item_From_Down.Rate == PIPE_seq_item_f.current_Rate )begin
        
        counter ++;
        if(counter < 10000 )begin // destroy COM
          if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h2D ) begin
              for(int i = 0; i < 16 ; i++)
                PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 8 ] = 8'h1C ;

          end
          if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h2D)begin
              for(int i = 0; i < 16 ; i++)
                PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 8 ] = 8'h1C ;
          end

        end
        else if(counter < 20000)begin // destroy ID

          if( PIPE_seq_item_From_Up.TxData[7 : 0 ] == 8'h45)begin
              PIPE_seq_item_From_Up.TxData= {64{8'h50}};
          end
          else if(PIPE_seq_item_From_Up.Rate > 1)begin 

              PIPE_seq_item_From_Up.TxData = {64{8'h50}};
          end 

          if( PIPE_seq_item_From_Down.TxData[7 : 0] == 8'h45)begin
            PIPE_seq_item_From_Down.TxData = {64{8'h50}};
          end
          else if(PIPE_seq_item_From_Down.Rate > 1)begin 
            PIPE_seq_item_From_Down.TxData = {64{8'h50}};
          end 


        end
        else if( counter < 30000)begin // destroy link number

          if( PIPE_seq_item_From_Up.TxData[503 -: 8 ] == 8'h01)begin

              for(int i = 0; i < 16 ; i++)
              PIPE_seq_item_From_Up.TxData[(503- (i*32)) -: 8 ] = 8'h10;

          end
          else if(PIPE_seq_item_From_Up.Rate > 1)begin 

              for(int i = 0; i < 16 ; i++)
              PIPE_seq_item_From_Up.TxData[(503- (i*32)) -: 8 ] = 8'h10;

          end 

          if( PIPE_seq_item_From_Down.TxData[503 -: 8 ] == 8'h01)begin

              for(int i = 0; i < 16 ; i++)
                PIPE_seq_item_From_Down.TxData[(503- (i*32)) -: 8 ] = 8'h10;

          end
          else if(PIPE_seq_item_From_Down.Rate > 1)begin 

              for(int i = 0; i < 16 ; i++)
                PIPE_seq_item_From_Down.TxData[(503- (i*32)) -: 8 ] = 8'h10;

          end 




        end
        else if(counter < 40000)begin

          if(speed_change_bit_u)begin
            speed_change_bit_u=0;

                for(int i = 0; i < 16 ; i++)
                  PIPE_seq_item_From_Up.TxData[(503 - (32 * i)) -: 8 ] = 8'h00 ;

          end

          if(speed_change_bit_D)begin
              
              speed_change_bit_D=0;

                for(int i = 0; i < 16 ; i++)
                  PIPE_seq_item_From_Down.TxData[(503 - (32 * i)) -: 8 ] = 8'h00 ;

          end


          if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h2D)begin
            speed_change_bit_u=1;
          end
          

          if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h2D)
            speed_change_bit_D=1;
          





        end
        else if(counter == 40000)begin
          counter = 0 ;


        end

        
            Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
            Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

    end
    else begin

      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

    end
      

endfunction

function void Adapter::inject_error_phase1(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
    static int counter ;
    static int TS_detected_U,TS_detected_D;

      counter ++;
      TS_detected_U++;
      TS_detected_D++;
    
  if(counter ==0 )begin

      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);  
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

  end
  else begin

  if( counter < 10000 )begin // destroy COM
    if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h1E) begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 8 ] = 8'h1F ;

    end
    
    if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E )begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 8 ] = 8'h1F ;
    end


  end
  else if(counter < 20000)begin // destroy ID

    if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h1E) begin
        TS_detected_U=0;

    end

    if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E) begin
        TS_detected_D=0;

    end

    if(TS_detected_U == 3)begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData = {64{8'h50}};
    end

    if(TS_detected_D == 3)begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData = {64{8'h50}};
    end

  end
  else if( counter < 50000)begin // destroy link number

     if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h1E) begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(503 - (32 * i)) -: 8 ] = 8'h55 ;

    end
    
    if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E )begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(503 - (32 * i)) -: 8 ] = 8'h55 ;
    end



  end
  else if(counter < 2000)begin // destroy speed change

        if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h1E) begin
            TS_detected_U=0;

        end

        if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E) begin
            TS_detected_D=0;

        end

        if(TS_detected_U == 1)begin
               for(int i = 0; i < 16 ; i++)
                  PIPE_seq_item_From_Up.TxData[(503 - (32 * i)) -: 8 ] = 8'h00 ;
        end

        if(TS_detected_D == 3)begin
            for(int i = 0; i < 16 ; i++)
                  PIPE_seq_item_From_Down.TxData[(503 - (32 * i)) -: 8 ] = 8'h00 ;
        end


  end
  else if(counter == 50000)begin
    counter = 3 ;


  end
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

  end
  



endfunction



function void Adapter::inject_error_rec_speed(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);  

    static int counter ;
    static int TS_detected_U,TS_detected_D;

      counter ++;
      TS_detected_U++;
      TS_detected_D++;
    

  if(counter < 10000 )begin // destroy COM
    if(PIPE_seq_item_From_Up.TxData[511 -: 16 ] == 16'hbc7c) begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 8 ] = 8'h1F ;

    end
    
    if(PIPE_seq_item_From_Down.TxData[511 -: 16 ] == 16'hbc7c )begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 8 ] = 8'h1F ;
    end

  end
  else if(counter < 50000)begin // destroy EIOS



    if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'hBC)begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(503 - (32 * i)) -: 24 ] = 24'hc7c7c7;

    end

    if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'hBC)begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData = 24'hc7c7c7;
    end

  end
  else if(counter == 50000)begin
    counter = 1 ;


  end

  
      Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
      Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);

endfunction

function void Adapter::inject_error_Rec_Lock(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);

  //inject error in the TS goes to Downstream
  
  if(PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Up.TxData[511 -: 8 ] == 8'h1E ) begin
    TS_quarter_D = 0;
    if(!(this.randomize() with {
      !(Supported_Speed_Value[5:1] inside {5'b00001,5'b00011,5'b00111,5'b01111,5'b11111}); 
      Error_Inject_Operation != EC;
      Error_Inject_Operation != LF;
      Error_Inject_Operation != FS;
      Error_Inject_Operation != IDLE;
      Error_Inject_Operation != Bypass;
      !(Lane_Number_Value inside {[8'd0 : 8'd15]}); 
      !(Lane_Number_Value inside {[8'd240 : 8'd255]});
      TS_ID_Value != 8'h4a;
      TS_ID_Value != 8'h45;
      } ) )begin //randomize in the first quarter
      Error_Inject_Operation = Prevent;
    end
    case (Error_Inject_Operation)
      COM:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 8 ] = COM_Value ;
      end
      Link_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(503 - (32 * i)) -: 8 ] = Link_Number_Value ;
      end
      Lane_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(495 - (32 * i)) -: 8 ] = Lane_Number_Value + i ;

      end
      Prevent:begin
          PIPE_seq_item_From_Up.TxData = 0 ;

      end 
    endcase
    /* if byBass or speed change or supported speed or Ts id N.OP should be made in first quarter*/
    Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
    TS_quarter_D++;


  
  end  else if(1 == TS_quarter_D)begin
    case (Error_Inject_Operation)
      Supported_Speed:begin
        //change supported speed without changing speed change bit
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(510 - (32 * i)) -: 7 ] = Supported_Speed_Value ;
        end
      end
      Speed_Change:begin
       //change speed change bit without changing supported speed
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i))] = ~PIPE_seq_item_From_Up.TxData[(511 - (32 * i))] ;
        end
      end
      
      Prevent:begin
          PIPE_seq_item_From_Up.TxData = 0 ;

      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber N.OP should be made in second quarter*/
    Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
    TS_quarter_D++;

  end else if (2 == TS_quarter_D) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData[(495 - (32 * i)) -: 16 ] = {2{TS_ID_Value}} ;
      end
      Prevent:begin
        PIPE_seq_item_From_Up.TxData = 0 ;
      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber or speed change or supported speed N.OP should be made in second quarter*/
    Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
    TS_quarter_D++;

  end else if(3 == TS_quarter_D) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData = {64{TS_ID_Value}} ;
      end
      Prevent:begin
        PIPE_seq_item_From_Up.TxData = 0 ;
      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber or speed change or supported speed N.OP should be made in second quarter*/
    Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
    TS_quarter_D++;
  end

  //inject error in the TS goes to Upstream
  if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E ) begin
    TS_quarter_U = 0;
    if(!(this.randomize() with {
      !(Supported_Speed_Value[5:1] inside {5'b00001,5'b00011,5'b00111,5'b01111,5'b11111});
      Error_Inject_Operation != EC;
      Error_Inject_Operation != LF;
      Error_Inject_Operation != FS;
      Error_Inject_Operation != IDLE;
      Error_Inject_Operation != Bypass;
      !(Lane_Number_Value inside {[8'd0 : 8'd15]}); 
      !(Lane_Number_Value inside {[8'd240 : 8'd255]});
      TS_ID_Value != 8'h4a;
      TS_ID_Value != 8'h45;

      } ) )begin //randomize in the first quarter
      Error_Inject_Operation = Prevent;
    end
    case (Error_Inject_Operation)
      COM:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 8 ] = COM_Value ;
      end
      Link_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(503 - (32 * i)) -: 8 ] = Link_Number_Value ;
      end
      Lane_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(495 - (32 * i)) -: 8 ] = Lane_Number_Value + i ;

      end
      Prevent:begin
          PIPE_seq_item_From_Down.TxData = 0 ;

      end 
    endcase
    /* if byBass or speed change or supported speed or Ts id N.OP should be made in first quarter*/
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;


  
  end  else if(1 == TS_quarter_U)begin
    case (Error_Inject_Operation)
      Supported_Speed:begin
        //change supported speed without changing speed change bit
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(510 - (32 * i)) -: 7 ] = Supported_Speed_Value ;
        end
      end
      Speed_Change:begin
       //change speed change bit without changing supported speed
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i))] = ~PIPE_seq_item_From_Down.TxData[(511 - (32 * i))] ;
        end
      end
      
      Prevent:begin
          PIPE_seq_item_From_Down.TxData = 0 ;

      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber N.OP should be made in second quarter*/
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;

  end else if (2 == TS_quarter_U) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(495 - (32 * i)) -: 16 ] = {2{TS_ID_Value}} ;
      end
      Prevent:begin
        PIPE_seq_item_From_Down.TxData = 0 ;
      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber or speed change or supported speed N.OP should be made in second quarter*/
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;

  end else if(3 == TS_quarter_U) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData = {64{TS_ID_Value}} ;
      end
      Prevent:begin
        PIPE_seq_item_From_Down.TxData = 0 ;
      end 
    endcase
    /* if byBass or Com or linknumber or lanenumber or speed change or supported speed N.OP should be made in second quarter*/
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;
  end
  
endfunction

function void Adapter::inject_error_phase0(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
  //by pass the TS going to the Downstream to let it pass the phase0 (design issue)
  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);
    //inject error in the TS goes to Upstream
  if(PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'hBC || PIPE_seq_item_From_Down.TxData[511 -: 8 ] == 8'h1E ) begin
    TS_quarter_U = 0;
    if(!(this.randomize() with {
      Supported_Speed_Value inside {8'b00000010,8'b00000110,8'b00001110,8'b00011110,8'b00111110}; 
      Error_Inject_Operation != Speed_Change;
      Error_Inject_Operation != IDLE;
      EC_Value != 2'b01;
      LF_Value != 6'b111111;
      FS_Value != 6'b111111;
      } ) )begin 
      Error_Inject_Operation = Prevent;
    end
    case (Error_Inject_Operation)
      COM:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 8 ] = COM_Value ;
      end
      Link_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(503 - (32 * i)) -: 8 ] = Link_Number_Value ;
      end
      Lane_Number:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(495 - (32 * i)) -: 8 ] = Lane_Number_Value + i ;

      end
      Prevent:begin
          PIPE_seq_item_From_Down.TxData = 0 ;

      end 
    endcase

    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;


  
  end  else if(1 == TS_quarter_U)begin
    case (Error_Inject_Operation)
      Supported_Speed:begin

        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(510 - (32 * i)) -: 7 ] = Supported_Speed_Value ;
        end
      end
      Speed_Change:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i))] = ~PIPE_seq_item_From_Down.TxData[(511 - (32 * i))] ;
        end
      end
      EC:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(489 - (32 * i)) -: 2] = EC_Value ;
        end

      end
      FS:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(485 - (32 * i)) -: 6] = FS_Value ;
        end
      end
      Prevent:begin
          PIPE_seq_item_From_Down.TxData = 0 ;

      end 
    endcase
   
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;

  end else if (2 == TS_quarter_U) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData[(495 - (32 * i)) -: 16 ] = {2{TS_ID_Value}} ;
      end
      LF:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(509 - (32 * i)) -: 6] = LF_Value ;
        end
      end
      Prevent:begin
        PIPE_seq_item_From_Down.TxData = 0 ;
      end 
    endcase
   
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;

  end else if(3 == TS_quarter_U) begin
    case (Error_Inject_Operation)
      TS_ID:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData = {64{TS_ID_Value}} ;
      end
      Prevent:begin
        PIPE_seq_item_From_Down.TxData = 0 ;
      end 
    endcase
    
    Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
    TS_quarter_U++;
  end


  
endfunction

function void Adapter::inject_error_rec_idle(PIPE_seq_item PIPE_seq_item_From_Up ,PIPE_seq_item PIPE_seq_item_From_Down);
      static bit [3:0] count_up,count_down;
      static bit start;
  //from down to up
  if(PIPE_seq_item_From_Down.TxData[511 -: 32 ] == 32'hE1000000)begin //SKP
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 32] = 32'hF1000000 ;
    end
  end else if(PIPE_seq_item_From_Down.TxData[511 -: 32 ] == 32'h99999999)begin//SKP
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 32] = 32'h66666666 ;
    end
  end else if( PIPE_seq_item_From_Down.TxData[511 -: 32 ] == 32'hE1878787)begin//SDS
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 32] = 32'hF1898989;
    end
    count_up++;
        start = 1;

  end else if(PIPE_seq_item_From_Down.TxData[511 -: 32 ] == 32'h87878787)begin//SDS
      for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 32] = 32'h89898989;
    end
    count_up++;
    start = 1;
  end else if((count_up >= 3'b100 || start) && PIPE_seq_item_From_Down.TxData[511 -: 32 ] != 32'h00000000) begin //IDLE
    if(!(this.randomize() with {
      Error_Inject_Operation inside {Prevent, IDLE};
    }) )begin 
      Error_Inject_Operation = Prevent;
      end

      case (Error_Inject_Operation)
      Prevent:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Down.TxData = 0 ;


      end
      IDLE:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Down.TxData[(511 - (32 * i)) -: 32] = IDLE_Value;
        end

      end
    endcase
  end 

  if(PIPE_seq_item_From_Up.TxData[511 -: 32 ] == 32'hE1000000)begin //SKP
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 32] = 32'hF1000000 ;
    end
  end else if(PIPE_seq_item_From_Up.TxData[511 -: 32 ] == 32'h99999999)begin//SKP
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 32] = 32'h66666666 ;
    end
  end else if( PIPE_seq_item_From_Up.TxData[511 -: 32 ] == 32'hE1878787)begin//SDS
    for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 32] = 32'hF1898989;
    end
        start = 1;

    count_down++;
  end else if(PIPE_seq_item_From_Up.TxData[511 -: 32 ] == 32'h87878787)begin//SDS
      for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 32] = 32'h89898989;
    end
    count_down++;
    start = 1;
  end else if((count_down == 3'b100 || start) && PIPE_seq_item_From_Up.TxData[511 -: 32 ] != 32'h00000000) begin //IDLE
    if(!(this.randomize() with {
      Error_Inject_Operation inside {Prevent, IDLE};
    }) )begin 
      Error_Inject_Operation = Prevent;
      end
      
      case (Error_Inject_Operation)
      Prevent:begin
        for(int i = 0; i < 16 ; i++)
          PIPE_seq_item_From_Up.TxData = 0 ;
      end
      IDLE:begin
        for(int i = 0; i < 16 ; i++)begin
          PIPE_seq_item_From_Up.TxData[(511 - (32 * i)) -: 32] = IDLE_Value;
        end
      end
    endcase
  end
  Adapter_To_U_RX_ap.write(PIPE_seq_item_From_Down);
  Adapter_To_D_RX_ap.write(PIPE_seq_item_From_Up);


endfunction