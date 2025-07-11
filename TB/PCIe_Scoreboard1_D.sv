// `uvm_analysis_imp_decl(_TX_D)
// `uvm_analysis_imp_decl(_RX_D)
class PCIe_Scoreboard1_D extends uvm_scoreboard;
    `uvm_component_utils(PCIe_Scoreboard1_D)
    // uvm_analysis_imp_TX_D #(PIPE_seq_item, PCIe_Scoreboard1_D) TX_export;
    // uvm_analysis_imp_RX_D #(PIPE_seq_item, PCIe_Scoreboard1_D) RX_export;
    uvm_tlm_analysis_fifo #(PIPE_seq_item) FIFO_TX_af;
    uvm_tlm_analysis_fifo #(PIPE_seq_item) FIFO_RX_af;
    bit [1:0] Detect_Quiet_f,Detect_Active_f,Polling_Active_f,Polling_Configuration_f,Config_Link_Width_Start_f,Config_Link_Width_Accept_f,Config_Lanenum_Wait_f;
    bit [1:0] Config_Lanenum_Accept_f,Config_Complete_f,Config_Idle_f,L0_f,Recovery_RcvrLock_f,Recovery_RcvrCfg_f,Phase1_f;
    bit [1:0] Recovery_Speed_f,Recovery_Idle_f;
    event check_message;
    bit Link_up_done_flag,Entering_Recovery_flag;

    extern function new(string name = "PCIe_Scoreboard1_D", uvm_component parent);
    
    extern function void build_phase (uvm_phase phase);

    extern function void connect_phase (uvm_phase phase);

    extern task run_phase (uvm_phase phase);
    
    extern task check_TX_state();

    extern task check_RX_state();

    extern task Message_Display();

    // extern virtual function void write_TX_D(PIPE_seq_item item);

    // extern virtual function void write_RX_D(PIPE_seq_item item);

endclass 

function PCIe_Scoreboard1_D::new(string name = "PCIe_Scoreboard1_D", uvm_component parent);
        super.new(name, parent);
endfunction 

function void PCIe_Scoreboard1_D::build_phase (uvm_phase phase);
    super.build_phase(phase);
    FIFO_TX_af = new("FIFO_TX_af",this);
    FIFO_RX_af = new("FIFO_RX_af",this);
endfunction

function void PCIe_Scoreboard1_D::connect_phase (uvm_phase phase);
    super.connect_phase(phase);
endfunction

task PCIe_Scoreboard1_D::run_phase (uvm_phase phase);
    super.run_phase(phase);
    fork
        check_TX_state();
        check_RX_state();
        Message_Display();
    join
endtask

task PCIe_Scoreboard1_D::check_RX_state();
    PIPE_seq_item RX_item;
    forever begin 
        FIFO_RX_af.get(RX_item);
        case (RX_item.Current_Substate)
            `Detect_Quiet:begin
                if(RX_item.Next_Substate == `Detect_Active /*&& RX_item.Rate == `GEN1*/) begin
                    Detect_Quiet_f[0] = 1'b1;
                    ->check_message;
                end 
            end

            `Detect_Active:begin
                if(0  == RX_item.time_out)begin
                if( RX_item.Next_Substate == `Polling_Active) begin
                    Detect_Active_f[0] = 1'b1;
                    ->check_message;
                    
                end 
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Detect_Active] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Detect_Active] Invalid Time Out "),UVM_LOW)  
                    end
                    Detect_Active_f = 2'b00;
                end
            end
            `Polling_Active:begin
                if(0  == RX_item.time_out)begin
                    if( ( 8 <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Polling_Configuration == RX_item.Next_Substate) ) begin 
                        Polling_Active_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [ Polling_Active] Issue in TS Type or Count "),UVM_LOW)  
                        Polling_Active_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Polling_Active] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Polling_Active] Invalid Time Out "),UVM_LOW)  
                    end
                    Polling_Active_f = 2'b00;
                end
            end
            `Polling_Configuration:begin
                if(0  == RX_item.time_out)begin
                    if( ( 8 <= RX_item.TS_Count && `TS2 == RX_item.TS_Type && `Config_Link_Width_Start == RX_item.Next_Substate)) begin 
                        Polling_Configuration_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Polling_Configuration] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Polling_Configuration_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Polling_Configuration] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Polling_Configuration] Invalid Time Out "),UVM_LOW)  
                    end
                    Polling_Configuration_f = 2'b00;
                end
             end
            `Config_Link_Width_Start:begin
                if(0  == RX_item.time_out)begin
                    if( ( 2 <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Config_Link_Width_Accept == RX_item.Next_Substate)) begin 
                        Config_Link_Width_Start_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Start] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Link_Width_Start_f = 2'b00;
                    end
                end else begin 
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Start] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Start] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Link_Width_Start_f = 2'b00;
                end
             end
            `Config_Link_Width_Accept:begin
                if(0  == RX_item.time_out)begin
                if( ( 2 <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Config_Lanenum_Wait == RX_item.Next_Substate)) begin 
                        Config_Link_Width_Accept_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Accept] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Link_Width_Accept_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Accept] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Accept] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Link_Width_Accept_f = 2'b00;
                end
             end
            `Config_Lanenum_Wait:begin
                if(0  == RX_item.time_out)begin
                    if( ( 2 <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Config_Lanenum_Accept == RX_item.Next_Substate)) begin 
                        Config_Lanenum_Wait_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Wait] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Lanenum_Wait_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Wait] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Wait] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Lanenum_Wait_f = 2'b00;
                end
             end
            `Config_Lanenum_Accept:begin
                if(0  == RX_item.time_out)begin
                    if( ( 2 <= RX_item.TS_Count  && `TS1 == RX_item.TS_Type && `Config_Complete == RX_item.Next_Substate)) begin 
                        Config_Lanenum_Accept_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Accept] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Lanenum_Accept_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Accept] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Lanenum_Accept] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Lanenum_Accept_f = 2'b00;
                end
             end
            `Config_Complete:begin
                if(0  == RX_item.time_out)begin
                    if( ( 8 <= RX_item.TS_Count && `TS2 == RX_item.TS_Type && `Config_Idle == RX_item.Next_Substate)) begin 
                        Config_Complete_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Complete] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Complete_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Complete] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Complete] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Complete_f = 2'b00;
                end
             end
            `Config_Idle:begin
                if(0  == RX_item.time_out)begin
                    if( ( 8 <= RX_item.TS_Count && `IDLE == RX_item.TS_Type && `L0 == RX_item.Next_Substate)) begin 
                        Config_Idle_f[0] = 1'b1;
                        ->check_message;
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Idle] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Config_Idle_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Idle] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Config_Idle] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Idle_f = 2'b00;
                end
             end
            `L0:begin 
                if( ((1  <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Recovery_RcvrLock == RX_item.Next_Substate && RX_item.Rate <= 1) 
                || (0 == RX_item.TS_Type &&`L0 == RX_item.Next_Substate))
                //&& 1'b1 == Link_up_done_flag
                ) begin 
                    L0_f[0] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream RX [`L0] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    L0_f = 2'b00;
                end 
            end
            `Recovery_RcvrLock:begin
                if(0  == RX_item.time_out)begin
                if( /*(1 == Entering_Recovery_flag)&&*/((8 <= RX_item.TS_Count && (`TS1 == RX_item.TS_Type || `TS2 == RX_item.TS_Type) && `Recovery_RcvrCfg == RX_item.Next_Substate) //page 574 
                || (0 <= RX_item.TS_Count && (`TS1 == RX_item.TS_Type) &&`Phase1 == RX_item.Next_Substate && RX_item.PCLKRate == 4) //page 575
                || (`Recovery_Speed == RX_item.Next_Substate) 
                || (`Config_Link_Width_Start == RX_item.Next_Substate)))
                begin 
                    Recovery_RcvrLock_f[0] = 1'b1;
                    ->check_message;
 
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream RX [Recovery_RcvrLock] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Recovery_RcvrLock_f = 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_RcvrLock] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_RcvrLock] Invalid Time Out "),UVM_LOW)  
                    end
                    Recovery_RcvrLock_f = 2'b00;
                end
             end
             `Recovery_Speed:begin
                if(0  == RX_item.time_out)begin
                if((1 <= RX_item.TS_Count && (`EIOS == RX_item.TS_Type) && RX_item.Rate == `GEN1)
                ||  (1  <= RX_item.TS_Count && (`EIEOS == RX_item.TS_Type) && ((RX_item.Rate == `GEN5 && 4 == RX_item.PCLKRate && `Recovery_RcvrLock == RX_item.Next_Substate) || ((4 != RX_item.PCLKRate && `Detect_Quiet == RX_item.Next_Substate))))
                )begin
                    Recovery_Speed_f[0] = 1'b1;
                    ->check_message;
                    $display("1");
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream RX speed does not change to GEN5"),UVM_LOW)
                    Recovery_Speed_f = 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_Speed] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_Speed] Invalid Time Out "),UVM_LOW)  
                    end
                    Recovery_Speed_f = 2'b00;
                end
                
             end
             `Phase1:begin
                if(0  == RX_item.time_out)begin
                if( (2 <= RX_item.TS_Count && (`TS1 == RX_item.TS_Type) && `Recovery_RcvrLock == RX_item.Next_Substate && RX_item.Rate == `GEN5)  //page 574
                )
                begin 
                    Phase1_f[0] = 1'b1;
                    ->check_message;

                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream RX [phase1] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Phase1_f = 2'b00;
                end
                end else begin
                    if(`Recovery_Speed == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [phase1] Time Out To Recovery_Speed"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [phase1] Invalid Time Out "),UVM_LOW)  
                    end
                    Phase1_f = 2'b00;
                end
             end

             `Recovery_RcvrCfg:begin
                if(0  == RX_item.time_out)begin
                    if( (8 <= RX_item.TS_Count && `TS2 == RX_item.TS_Type && `Recovery_Idle == RX_item.Next_Substate )
                    ||  (8 <= RX_item.TS_Count && `TS2 == RX_item.TS_Type && `Recovery_Speed == RX_item.Next_Substate )
                    ||  (8 <= RX_item.TS_Count && `TS1 == RX_item.TS_Type && `Config_Link_Width_Start == RX_item.Next_Substate )
                    ) begin 
                        Recovery_RcvrCfg_f[0] = 1'b1;
                        ->check_message;
    
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Recovery_RcvrCfg] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Recovery_RcvrCfg_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_RcvrCfg] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_RcvrCfg] Invalid Time Out "),UVM_LOW)  
                    end
                    Recovery_RcvrCfg_f = 2'b00;
                end
             end
             `Recovery_Idle:begin
                if(0  == RX_item.time_out)begin
                    if( ((8 <= RX_item.TS_Count) && (`IDLE == RX_item.TS_Type) && (`L0 == RX_item.Next_Substate) )
                    ||  ((2 <= RX_item.TS_Count) && (`TS1 == RX_item.TS_Type) && (`Config_Link_Width_Start == RX_item.Next_Substate) )
                    ) begin 
                        Recovery_Idle_f[0] = 1'b1;
                        ->check_message;
    
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream RX [Recovery_Idle] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                        Recovery_Idle_f = 2'b00;
                    end
                end else begin
                    if(`Detect_Quiet == RX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_Idle] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream RX [Recovery_Idle] Invalid Time Out "),UVM_LOW)  
                    end
                    Recovery_Idle_f = 2'b00;
                end 
             end
        endcase
    end
endtask

task PCIe_Scoreboard1_D::check_TX_state();
    PIPE_seq_item TX_item;
    forever begin 
        //wait(FIFO_TX_af.size());
        FIFO_TX_af.get(TX_item);
        case (TX_item.Current_Substate)
            `Detect_Quiet:begin
                if(TX_item.Next_Substate == `Detect_Active /*&& TX_item.Rate == `GEN1*/) begin
                    Detect_Quiet_f[1] = 1'b1;
                    ->check_message;
                end 
            end

            `Detect_Active:begin
                if(0  == TX_item.time_out)begin
                if(( TX_item.Next_Substate == `Polling_Active)) begin
                    Detect_Active_f[1] = 1'b1;
                    ->check_message;
                    
                end 
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Detect_Active] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Detect_Active] Invalid Time Out "),UVM_LOW)  
                    end
                    Detect_Active_f = 2'b00;
                end
            end
            `Polling_Active:begin
                if(0  == TX_item.time_out)begin
                if( ( 1024 * `LANESNUMBER  <= TX_item.TS_Count  
                && `TS1 == TX_item.TS_Type 
                && `Polling_Configuration == TX_item.Next_Substate)
                ) begin //next substate is not included in tx
                    Polling_Active_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Polling_Active] Issue in TS Type or Count "), UVM_LOW)  
                    Polling_Active_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Polling_Active] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Polling_Active] Invalid Time Out "),UVM_LOW)  
                    end
                    Polling_Active_f = 2'b00;
                end
            end
            `Polling_Configuration:begin
                if(0  == TX_item.time_out)begin
                if( (16 * `LANESNUMBER <= TX_item.TS_Count  
                && `TS2 == TX_item.TS_Type 
                && `Config_Link_Width_Start == TX_item.Next_Substate)
                ) begin 
                    Polling_Configuration_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Polling_Configuration] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Polling_Configuration_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Polling_Configuration] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Polling_Configuration] Invalid Time Out "), UVM_LOW)  
                    end
                    Polling_Configuration_f = 2'b00;
                end
             end
            `Config_Link_Width_Start:begin
                if(0  == TX_item.time_out)begin
                if( (1 * `LANESNUMBER <= TX_item.TS_Count  
                && `TS1 == TX_item.TS_Type  
                && `Config_Link_Width_Accept == TX_item.Next_Substate)
                ) begin 
                    Config_Link_Width_Start_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Start] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Link_Width_Start_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Start] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Start] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Link_Width_Start_f = 2'b00;
                end
             end
            `Config_Link_Width_Accept:begin
                if(0  == TX_item.time_out)begin
                if( (1 <= TX_item.TS_Count  
                && `TS1 == TX_item.TS_Type 
                && `Config_Lanenum_Wait == TX_item.Next_Substate)
                ) begin 
                    Config_Link_Width_Accept_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Accept] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Link_Width_Accept_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Accept] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Link_Width_Accept] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Link_Width_Accept_f = 2'b00;
                end
                //`uvm_info(get_type_name (),$sformatf("Downstream RX [Config_Link_Width_Accept]  state %d,next state %d,timeout %d,type %d count %d", TX_item.Current_Substate, TX_item.Next_Substate, TX_item.time_out, TX_item.TS_Type, TX_item.TS_Count),UVM_LOW)
             end
            `Config_Lanenum_Wait:begin
                if(0  == TX_item.time_out)begin
                if( (2 * `LANESNUMBER <= TX_item.TS_Count  
                && (`TS1 == TX_item.TS_Type || `TS2 == TX_item.TS_Type)  
                && `Config_Lanenum_Accept == TX_item.Next_Substate)
                ) begin 
                    Config_Lanenum_Wait_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Wait] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Lanenum_Wait_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Wait] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Wait] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Lanenum_Wait_f = 2'b00;
                end
             end
            `Config_Lanenum_Accept:begin
                if(0  == TX_item.time_out)begin
                if( (0 <= TX_item.TS_Count  
                && (`TS1 == TX_item.TS_Type || `TS2 == TX_item.TS_Type)
                && `Config_Complete == TX_item.Next_Substate)
                ) begin 
                    Config_Lanenum_Accept_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Accept] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Lanenum_Accept_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Accept] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Lanenum_Accept] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Lanenum_Accept_f = 2'b00;
                end
             end
            `Config_Complete:begin
                if(0  == TX_item.time_out)begin
                if( (16 * `LANESNUMBER <= TX_item.TS_Count  
                && `TS2 == TX_item.TS_Type 
                && `Config_Idle == TX_item.Next_Substate)
                ) begin 
                    Config_Complete_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Complete] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Complete_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Complete] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Complete] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Complete_f = 2'b00;
                end
             end
            `Config_Idle:begin
                if(0  == TX_item.time_out)begin
                if( (16*`LANESNUMBER <= TX_item.TS_Count  
                && `IDLE == TX_item.TS_Type 
                && `L0 == TX_item.Next_Substate)
                ) begin 
                    Config_Idle_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Config_Idle] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Config_Idle_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Idle] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Config_Idle] Invalid Time Out "),UVM_LOW)  
                    end
                    Config_Idle_f = 2'b00;
                end
             end
            `L0:begin 
                if( 0  <= TX_item.TS_Count  
                && ((`TS1 == TX_item.TS_Type && `Recovery_RcvrLock == TX_item.Next_Substate && TX_item.Rate <= 1) //used in the code
                || (0 == TX_item.TS_Type &&`L0 == TX_item.Next_Substate))
                //&& 1'b1 == Link_up_done_flag
                ) begin 
                    L0_f[1] = 1'b1;
                    ->check_message;
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [`L0] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    L0_f= 2'b00;
                end
            end
            `Recovery_RcvrLock:begin
                if(0  == TX_item.time_out)begin
                if(/*(1 == Entering_Recovery_flag)&&*/((8 * `LANESNUMBER <= TX_item.TS_Count && (`TS1 == TX_item.TS_Type || `TS2 == TX_item.TS_Type) && `Recovery_RcvrCfg == TX_item.Next_Substate) //page 574 // timeout
                || (0 <= TX_item.TS_Count && (`TS1 == TX_item.TS_Type) && `Phase1 == TX_item.Next_Substate && TX_item.PCLKRate == 4) //page 575 if directed it need not to be comming from config idle or recovery idle
                || (0 <= TX_item.TS_Count && (`TS1 == TX_item.TS_Type) && `Recovery_Speed == TX_item.Next_Substate) 
                || (0 <= TX_item.TS_Count && (`TS1 == TX_item.TS_Type) && `Config_Link_Width_Start == TX_item.Next_Substate))
                ) begin 
                    Recovery_RcvrLock_f[1] = 1'b1;
                    ->check_message;
 
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Recovery_RcvrLock] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Recovery_RcvrLock_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_RcvrLock] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_RcvrLock] Invalid Time Out "),UVM_LOW)  
                    end
                    Recovery_RcvrLock_f = 2'b00;
                end
             end
             `Recovery_Speed:begin
              if(0  == TX_item.time_out)begin
                if(
                    (1 *`LANESNUMBER <= TX_item.TS_Count && (`EIOS == TX_item.TS_Type) && TX_item.Rate == `GEN1)
                ||  (1 *`LANESNUMBER <= TX_item.TS_Count && (`EIEOS == TX_item.TS_Type) && ((TX_item.Rate == `GEN5 && 4 == TX_item.PCLKRate && `Recovery_RcvrLock == TX_item.Next_Substate) || ((4 != TX_item.PCLKRate && `Detect_Quiet == TX_item.Next_Substate))))
                ) begin /*&& TX_item.pl_state_sts == 'b1011 not in pipe intf*/ //Retrain state_sts

                    if(`EIOS != TX_item.TS_Type) begin
                        Recovery_Speed_f[1] = 1'b1;
                        ->check_message;
                        $display("21");
                    end
                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX speed does not change to GEN5"),UVM_LOW)
                    Recovery_Speed_f= 2'b00;
                end
              end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_Speed] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_Speed] Invalid Time Out "), UVM_LOW)  
                    end
                    Recovery_Speed_f = 2'b00;
                end
                
             end
             `Phase1:begin //page 589
                if(0  == TX_item.time_out)begin
                if( (2 * `LANESNUMBER <= TX_item.TS_Count 
                    && (`TS1 == TX_item.TS_Type) 
                    && `Recovery_RcvrLock == TX_item.Next_Substate
                    && TX_item.Rate == `GEN5)
                     
                )begin 
                    Phase1_f[1] = 1'b1;
                    ->check_message;

                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [phase1] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Phase1_f= 2'b00;
                end
                end else begin
                    if(`Recovery_Speed == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [phase1] Time Out To Recovery_Speed"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [phase1] Invalid Time Out "), UVM_LOW)  
                    end
                    Phase1_f = 2'b00;
                end
             end 
             `Recovery_RcvrCfg:begin
                if(0  == TX_item.time_out)begin
                if( (16 * `LANESNUMBER <= TX_item.TS_Count && `TS2 == TX_item.TS_Type && `Recovery_Idle == TX_item.Next_Substate )
                ||  (32 * `LANESNUMBER <= TX_item.TS_Count && `TS2 == TX_item.TS_Type && `Recovery_Speed == TX_item.Next_Substate && (TX_item.PCLKRate <= 1)) //page 600
                ||  (128 * `LANESNUMBER <= TX_item.TS_Count && `TS2 == TX_item.TS_Type && `Recovery_Speed == TX_item.Next_Substate && (TX_item.PCLKRate >= 2))
                ||  (8 * `LANESNUMBER <= TX_item.TS_Count  && `TS1 == TX_item.TS_Type && `Config_Link_Width_Start == TX_item.Next_Substate)  
                ) begin 
                    // `uvm_info(get_type_name (),$sformatf("Recovery_RcvrCfg pass"), UVM_LOW)
                    Recovery_RcvrCfg_f[1] = 1'b1;
                    ->check_message;

                end else begin
                    `uvm_info(get_type_name (),$sformatf("Downstream TX [Recovery_RcvrCfg] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)  
                    Recovery_RcvrCfg_f= 2'b00;
                end
                end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_RcvrCfg] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_RcvrCfg] Invalid Time Out "), UVM_LOW)  
                    end
                    Recovery_RcvrCfg_f = 2'b00;
                end
                
             end
             `Recovery_Idle:begin//page 602
             if(0  == TX_item.time_out)begin
                
                    if( ((16 * `LANESNUMBER <= TX_item.TS_Count) && (`IDLE == TX_item.TS_Type) && (`L0 == TX_item.Next_Substate) )
                    ||  ((2 * `LANESNUMBER <= TX_item.TS_Count) && (`TS1 == TX_item.TS_Type) && (`Config_Link_Width_Start == TX_item.Next_Substate) ) 
                    ||  ( `SKP == TX_item.TS_Type && 1 * `LANESNUMBER <= TX_item.TS_Count)
                    ||  ( `SDS == TX_item.TS_Type && 1 * `LANESNUMBER <= TX_item.TS_Count)
                    ) begin 
                        // `uvm_info(get_type_name (),$sformatf("Recovery_Idle pass"), UVM_LOW)
                        Recovery_Idle_f[1] = 1'b1;
                        ->check_message;
    
                    end else begin
                        `uvm_info(get_type_name (),$sformatf("Downstream TX [Recovery_Idle] Issue in TS Type or Count or current or next state Transitioning "), UVM_LOW)
                        Recovery_Idle_f= 2'b00;
                    end
             end else begin
                    if(`Detect_Quiet == TX_item.Next_Substate) begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_Idle] Time Out To Detect_Quiet"),UVM_LOW)  
                    end else begin
                    `uvm_info (get_type_name (),$sformatf("Downstream TX [Recovery_Idle] Invalid Time Out "), UVM_LOW)  
                    end
                    Recovery_Idle_f = 2'b00;
            
             end 
             end
        endcase
    end 
endtask

task PCIe_Scoreboard1_D::Message_Display();
    forever begin
        
        @(check_message);
       if(2'b11 ==Detect_Quiet_f)begin
        `uvm_info(get_type_name (),$sformatf("Downstream Detect_Quiet Approved"), UVM_LOW)
        Detect_Quiet_f = 2'b00;
       end else if(2'b11 ==Detect_Active_f)begin
        `uvm_info(get_type_name (),$sformatf("Downstream Detect_Active Approved"), UVM_LOW)
        Detect_Active_f = 2'b00;

       end else if (2'b11 ==Polling_Active_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Polling_Active Approved"), UVM_LOW)
        Polling_Active_f = 2'b00;
       end else if (2'b11 ==Polling_Configuration_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Polling_Configuration Approved"), UVM_LOW)
        Polling_Configuration_f = 2'b00;
       end else if (2'b11 ==Config_Link_Width_Start_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Link_Width_Start Approved"), UVM_LOW)
        Config_Link_Width_Start_f = 2'b00;
       end else if (2'b11 ==Config_Link_Width_Accept_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Link_Width_Accept Approved"), UVM_LOW)
        Config_Link_Width_Accept_f = 2'b00;
       end else if (2'b11 ==Config_Lanenum_Wait_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Lanenum_Wait Approved"), UVM_LOW)
        Config_Lanenum_Wait_f = 2'b00;
       end else if (2'b11 ==Config_Lanenum_Accept_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Lanenum_Accept Approved"), UVM_LOW)
        Config_Lanenum_Accept_f = 2'b00;
       end else if (2'b11 ==Config_Complete_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Complete Approved"), UVM_LOW)
        Config_Complete_f = 2'b00;
       end else if (2'b11 ==Config_Idle_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Config_Idle Approved"), UVM_LOW)
        Config_Idle_f = 2'b00;
       end else if (2'b11 ==L0_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream L0 Approved"), UVM_LOW)
        L0_f = 2'b00;
       end else if (2'b11 ==Recovery_Speed_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Recovery_Speed Approved"), UVM_LOW)
        Recovery_Speed_f = 2'b00;
       end else if (2'b11 ==Recovery_RcvrLock_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Recovery_RcvrLock Approved"), UVM_LOW)
        Recovery_RcvrLock_f = 2'b00;
       end else if (2'b11 ==Recovery_RcvrCfg_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Recovery_RcvrCfg Approved"), UVM_LOW)
        Recovery_RcvrCfg_f = 2'b00;
       end else if (2'b11 ==Phase1_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Phase1 Approved"), UVM_LOW)
        Phase1_f = 2'b00;
       end  else if (2'b11 ==Recovery_Idle_f) begin
        `uvm_info(get_type_name (),$sformatf("Downstream Recovery_Idle Approved"), UVM_LOW)
        Recovery_Idle_f = 2'b00;
       end 

    end

endtask
// function void PCIe_Scoreboard1_D::write_TX_D(PIPE_seq_item item);
//         FIFO_TX.push_back(item);
// endfunction

// function void PCIe_Scoreboard1_D::write_RX_D(PIPE_seq_item item);
//         FIFO_RX.push_back(item);
// endfunction