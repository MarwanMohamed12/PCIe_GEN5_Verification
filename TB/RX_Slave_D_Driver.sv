class RX_Slave_D_Driver  extends uvm_driver#(PIPE_seq_item );


`uvm_component_utils(RX_Slave_D_Driver)

virtual PIPE_if       PIPE_vif_h;
    
uvm_tlm_analysis_fifo #(PIPE_seq_item) receive_TLM_FIFO;
    
    
    
    
    
extern function new(string name = "RX_Slave_D_Driver",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase(uvm_phase phase); 
extern task Drive_PIPE_RX_Signals (PIPE_seq_item PIPE_seq_item_h);






endclass







function RX_Slave_D_Driver::new(string name = "RX_Slave_D_Driver",uvm_component parent);
      
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
        
endfunction 



function void RX_Slave_D_Driver::build_phase (uvm_phase phase);
      
        super.build_phase(phase);
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        
         receive_TLM_FIFO = new("receive_TLM_FIFO",this);
        
endfunction: build_phase




function void RX_Slave_D_Driver::connect_phase (uvm_phase phase);
      
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in connect_phase of driver ",UVM_LOW)
        
endfunction: connect_phase




task RX_Slave_D_Driver::run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver ",UVM_LOW)
        
        forever begin
            
            PIPE_seq_item      PIPE_seq_item_h;
            PIPE_seq_item_h = PIPE_seq_item::type_id::create("PIPE_seq_item_h");
            receive_TLM_FIFO.get(PIPE_seq_item_h);
            Drive_PIPE_RX_Signals(PIPE_seq_item_h);

            
        end
        
        
endtask: run_phase
    
    
    
task RX_Slave_D_Driver::Drive_PIPE_RX_Signals (PIPE_seq_item PIPE_seq_item_h);
        
        PIPE_vif_h.RxData                   = PIPE_seq_item_h.TxData;
        PIPE_vif_h.RxDataValid              = PIPE_seq_item_h.TxDataValid;
        PIPE_vif_h.RxDataK                  = PIPE_seq_item_h.TxDataK;
        PIPE_vif_h.RxStartBlock             = PIPE_seq_item_h.TxStartBlock;
        PIPE_vif_h.RxSyncHeader             = PIPE_seq_item_h.TxSyncHeader;
        PIPE_vif_h.RxElecIdle               = PIPE_seq_item_h.TxElecIdle;
        

endtask

