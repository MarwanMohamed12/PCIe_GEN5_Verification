

class PCIe_Scoreboard2_U extends uvm_scoreboard;

`uvm_component_utils(PCIe_Scoreboard2_U)

uvm_tlm_analysis_fifo #(LPIF_seq_item) TX_af;  
uvm_tlm_analysis_fifo #(LPIF_seq_item) RX_af;

LPIF_seq_item LPIF_seq_item_from_TX ,LPIF_seq_item_from_RX;


bit[7:0] TX_Data,RX_Data;

int mismatch_data_count,TLP_Count,DLLP_Count;
bit mismatch_packet_len;


extern function new(string name ="PCIe_Scoreboard2_U" , uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task Check_Data( bit[7:0] TX_Data_q[$] ,  bit[7:0] RX_Data_q[$]);
extern function void report_phase(uvm_phase phase);


endclass




  
function PCIe_Scoreboard2_U::new(string name ="PCIe_Scoreboard2_U" , uvm_component parent);
   
   super.new(name,parent);

endfunction
  
  
  
  
function void PCIe_Scoreboard2_U::build_phase(uvm_phase phase);
  
  super.build_phase(phase);
  
  TX_af = new("TX_af",this);  
  RX_af = new("RX_af",this);
  
endfunction
  
  


function void PCIe_Scoreboard2_U::connect_phase(uvm_phase phase);
  
  super.connect_phase(phase);
  
endfunction




task PCIe_Scoreboard2_U::run_phase(uvm_phase phase);
  
  super.run_phase(phase);
  
  
  forever begin
    
    TX_af.get(LPIF_seq_item_from_TX);
    RX_af.get(LPIF_seq_item_from_RX);
    

    if(LPIF_seq_item_from_TX.packet_type ==2'b00 && LPIF_seq_item_from_RX.packet_type ==2'b00)begin
       
          Check_Data(LPIF_seq_item_from_TX.TLP,LPIF_seq_item_from_RX.TLP);
          TLP_Count++;
          
        end
          
    else if(LPIF_seq_item_from_TX.packet_type ==2'b10 && LPIF_seq_item_from_RX.packet_type ==2'b10) begin
       
          Check_Data(LPIF_seq_item_from_TX.DLLP,LPIF_seq_item_from_RX.DLLP);
          DLLP_Count++;
          
        end    
                      
  end
  
  
endtask
  
  





task PCIe_Scoreboard2_U::Check_Data( bit[7:0] TX_Data_q[$] ,  bit[7:0] RX_Data_q[$]);
  
  
  if(TX_Data_q.size() != RX_Data_q.size()) begin
     mismatch_packet_len = 1;
     `uvm_error(get_type_name(),$sformatf("TX Data Queue size =%d    RX Data Queue size =%d",TX_Data_q.size(),RX_Data_q.size()))
   end
     
     

  while(TX_Data_q.size()>0 && RX_Data_q.size()>0 && !mismatch_packet_len)begin
    
     TX_Data = TX_Data_q.pop_front();
     RX_Data = RX_Data_q.pop_front();
     
     `uvm_info(get_type_name(),$sformatf("TX_Data = %h  , RX_Data = %h  ",TX_Data,RX_Data),UVM_HIGH)
     if(TX_Data!=RX_Data)
           mismatch_data_count++;
  
  end
  


   if(mismatch_packet_len)begin
     `uvm_info(get_type_name(),"Packet length mismatch detected",UVM_LOW)
      mismatch_packet_len = 0;
     end
     
    


endtask
  
 
 
 
 
 function void PCIe_Scoreboard2_U::report_phase (uvm_phase phase);
   
     super.report_phase(phase);

    `uvm_info(get_type_name(), "------------------------------------------------------------", UVM_LOW)
    `uvm_info(get_type_name(), "          Scoreboard Summary Report For Data Integrity: TX Upstream -> RX Downstream", UVM_LOW)
    `uvm_info(get_type_name(), "------------------------------------------------------------", UVM_LOW)
   
    `uvm_info(get_type_name(), $sformatf("   Transaction Layer Packets (TLP) verified : %0d", TLP_Count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("   Data Link Layer Packets (DLLP) verified  : %0d", DLLP_Count), UVM_LOW)

     if(mismatch_data_count>0)  
        `uvm_error(get_type_name(),$sformatf("   Mismatch detected: %d data values didn't match expected results",mismatch_data_count))  
     else
        `uvm_info(get_type_name(), "   All data matched the expected results", UVM_LOW)
   
 endfunction
 