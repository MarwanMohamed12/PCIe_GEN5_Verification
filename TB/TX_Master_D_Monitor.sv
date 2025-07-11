
class TX_Master_D_Monitor extends uvm_monitor;
  


`uvm_component_utils(TX_Master_D_Monitor)
    
  
virtual LPIF_if      LPIF_vif_h;
event set_reset_In_LPIF ;
uvm_analysis_port #(LPIF_seq_item) send_ap;

LPIF_seq_item  LPIF_seq_item_h;      

bit Start_TLP_f;
bit Start_DLLP_f;
int TLP_Counts;
    
extern function new(string name = "TX_Master_D_Monitor",uvm_component parent);
extern function void build_phase (uvm_phase phase);
extern function void connect_phase (uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task Extract_Packets ();
extern task set_reset();


endclass






function TX_Master_D_Monitor::new(string name = "TX_Master_D_Monitor",uvm_component parent);
        super.new(name , parent);
        `uvm_info(get_type_name() ," in constructor of driver ",UVM_HIGH)
endfunction 



function void TX_Master_D_Monitor::build_phase (uvm_phase phase);
  
        super.build_phase(phase);
        
        `uvm_info(get_type_name() ," in build_phase of driver ",UVM_LOW)
        
        send_ap = new("send_ap",this); 
             
endfunction: build_phase



function void TX_Master_D_Monitor::connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name() ," in connect_phase of driver ",UVM_LOW)
endfunction: connect_phase



task TX_Master_D_Monitor::set_reset();

    LPIF_seq_item_h = LPIF_seq_item::type_id::create("LPIF_seq_item_h");



  forever begin

        wait(set_reset_In_LPIF);
        LPIF_seq_item_h.set_reset = 1;

  

  end

endtask

task TX_Master_D_Monitor::run_phase(uvm_phase phase);
  
        super.run_phase(phase);
        `uvm_info(get_type_name() ," in run_phase of driver ",UVM_LOW)
      

        fork
            begin

              Extract_Packets();

            end

            begin

              set_reset();

            end


        join

          
endtask: run_phase





task TX_Master_D_Monitor::Extract_Packets();
  

  
  forever begin
     
     @(posedge LPIF_vif_h.lp_irdy)   
     
      for(int i =0; i<64; i++) begin
         
         
         if(LPIF_vif_h.lp_tlpstart[i] && LPIF_vif_h.lp_valid[i])begin
           LPIF_seq_item_h = LPIF_seq_item::type_id::create("LPIF_seq_item_h");
           Start_TLP_f = 1;
           LPIF_seq_item_h.TLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
         end
         
         
         
         else if(Start_TLP_f && !LPIF_vif_h.lp_tlpend[i] && LPIF_vif_h.lp_valid[i])begin
           LPIF_seq_item_h.TLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
         end
         
         
         
         else if(LPIF_vif_h.lp_tlpend[i] && LPIF_vif_h.lp_valid[i])begin
           LPIF_seq_item_h.TLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
           LPIF_seq_item_h.packet_type = 2'b00;
           LPIF_seq_item_h.Packet_Size = LPIF_seq_item_h.TLP.size();
           LPIF_seq_item_h.packets_trans=1;
           send_ap.write(LPIF_seq_item_h);
           Start_TLP_f = 0; 
         end         
         
         
         
         
         if(LPIF_vif_h.lp_dlpstart[i] && LPIF_vif_h.lp_valid[i])begin
           LPIF_seq_item_h = LPIF_seq_item::type_id::create("LPIF_seq_item_h");
           Start_DLLP_f = 1;
           LPIF_seq_item_h.DLLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
         end
         
         
         
         else if(Start_DLLP_f && !LPIF_vif_h.lp_dlpend[i] && LPIF_vif_h.lp_valid[i])begin 
           LPIF_seq_item_h.DLLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
         end
         
         
         
         else if(LPIF_vif_h.lp_dlpend[i] && LPIF_vif_h.lp_valid[i])begin 
           LPIF_seq_item_h.DLLP.push_back(LPIF_vif_h.lp_data[i*8+:8]);
           LPIF_seq_item_h.packet_type = 2'b10;
           LPIF_seq_item_h.packets_trans=1;
           send_ap.write(LPIF_seq_item_h); 
           Start_DLLP_f = 0;
         end         
                  
         
         
       end
 

    end
  

endtask
