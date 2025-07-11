class LTSSM1_U_Driver  extends uvm_driver #(PIPE_seq_item);
  
`uvm_component_utils(LTSSM1_U_Driver)



PIPE_seq_item PIPE_seq_item_h;

virtual PIPE_if PIPE_vif_h;

event Receiver_Detected;


extern function new(string name = "LTSSM1_U_Driver",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase (uvm_phase phase);
extern task drive (PIPE_seq_item PIPE_seq_item_h);


endclass








function LTSSM1_U_Driver::new(string name = "LTSSM1_U_Driver",uvm_component parent);
  
        super.new(name , parent);
        
endfunction 




function void LTSSM1_U_Driver::build_phase (uvm_phase phase);
  
super.build_phase(phase);

endfunction



function void LTSSM1_U_Driver::connect_phase (uvm_phase phase);
  
super.connect_phase(phase);

endfunction




task LTSSM1_U_Driver::run_phase (uvm_phase phase);
  
forever begin
  
   PIPE_seq_item_h =  PIPE_seq_item::type_id::create("PIPE_seq_item_h",this);
   
   seq_item_port.get_next_item(PIPE_seq_item_h);
   
   drive(PIPE_seq_item_h);
   
   seq_item_port.item_done();


end

endtask




task LTSSM1_U_Driver::drive (PIPE_seq_item  PIPE_seq_item_h);
  
`uvm_info(get_type_name() ," in LTSSM1_U_Driver ",UVM_HIGH)
        

   case (PIPE_seq_item_h.operation) 
     
       2'b00: begin
                    @(PIPE_vif_h.phy_reset);
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b1}};
                    @(posedge PIPE_vif_h.PCLK);
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b0}};;
    
               end

      2'b01: begin
                    `uvm_info(get_type_name() ," before detection ",UVM_LOW)
                    wait(PIPE_vif_h.TxDetectRx_Loopback == {`LANESNUMBER{1'b1}});
                     -> Receiver_Detected;
                    `uvm_info(get_type_name() ," after detection ",UVM_LOW)
                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b1}};
                    PIPE_vif_h.RxStatus={3*`LANESNUMBER{3'b011}};;
                    @(posedge PIPE_vif_h.PCLK);
                    @(posedge PIPE_vif_h.PCLK);
                    @(posedge PIPE_vif_h.PCLK);
                    @(posedge PIPE_vif_h.PCLK);
                    @(posedge PIPE_vif_h.PCLK);

                    PIPE_vif_h.PhyStatus = {`LANESNUMBER{1'b0}};
                    PIPE_vif_h.RxStatus={3*`LANESNUMBER{3'b000}};
             end
             
      2'b10: begin
                    wait(PIPE_vif_h.GetLocalPresetCoeffcients == {16{1'b1}});
                    PIPE_vif_h.LocalTxCoefficientsValid = {16{1'b1}};
                    PIPE_vif_h.LocalTxPresetCoefficients={16*18{1'b1}};
                    PIPE_vif_h.LocalLF={16*6{1'b1}};
                    PIPE_vif_h.LocalFS={16*6{1'b1}};
             end
    endcase


endtask

