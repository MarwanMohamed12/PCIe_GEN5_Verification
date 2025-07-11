`uvm_analysis_imp_decl(_TX_LPIF_D_port)
`uvm_analysis_imp_decl(_RX_LPIF_D_port)


class Coverage_Model_D2 extends uvm_component;



`uvm_component_utils(Coverage_Model_D2)

LPIF_seq_item LPIF_seq_item_TX_h,LPIF_seq_item_RX_h;  


int last_packet_size_TX,last_packet_size_RX;
int last_packet_type_TX,last_packet_type_RX;


uvm_analysis_imp_TX_LPIF_D_port #(LPIF_seq_item,Coverage_Model_D2) TX_imp;
uvm_analysis_imp_RX_LPIF_D_port #(LPIF_seq_item,Coverage_Model_D2) RX_imp;

extern function new(string name = "Coverage_Model_D2",uvm_component parent);
extern function void  build_phase(uvm_phase phase);
extern function void  connect_phase(uvm_phase phase); 

extern function void  write_TX_LPIF_D_port(LPIF_seq_item LPIF_seq_item_TX_h); 
extern function void  write_RX_LPIF_D_port(LPIF_seq_item LPIF_seq_item_RX_h);  





covergroup TX_Data_Exchange_D_Cover;

option.per_instance=1;

Packet_Type_p:coverpoint LPIF_seq_item_TX_h.packet_type {

  bins TLP_Packet  = {`TLP};
  bins DLLP_Packet = {`DLLP};
  
}

 Packet_backtoback_p: coverpoint LPIF_seq_item_TX_h.packet_type {
    bins B2B_TLP  = (`TLP => `TLP); 
    bins B2B_DLLP = (`DLLP => `DLLP);
    bins TLP_DLLP = (`TLP => `DLLP); 
    bins DLLP_TLP = (`DLLP => `TLP);
    
  }

TLP_Size_p:coverpoint LPIF_seq_item_TX_h.Packet_Size iff(LPIF_seq_item_TX_h.packet_type==`TLP) {

bins TLP_MIN_SIZE = {`TLP_MIN_SIZE};
bins TLP_MAX_SIZE = {`TLP_MAX_SIZE};
bins TLP_other_sizes = {[17:63]} ;
illegal_bins TLP_less_than_16_bytes = {[0:15]};

}

B2B_Different_Packets_Sizes:coverpoint LPIF_seq_item_TX_h.packet_type {
  
  bins B2B_TLP_MAX_SIZE      = {`TLP}  iff(LPIF_seq_item_TX_h.Packet_Size==`TLP_MAX_SIZE && last_packet_size_TX==`TLP_MAX_SIZE );
  bins B2B_TLP_MIN_SIZE      = {`TLP}  iff(LPIF_seq_item_TX_h.Packet_Size==`TLP_MIN_SIZE && last_packet_size_TX==`TLP_MIN_SIZE);
  bins TLP_DLLP_MAX_SIZE     = {`DLLP} iff(last_packet_size_TX==`TLP_MAX_SIZE && last_packet_type_TX ==`TLP);
  bins TLP_DLLP_MIN_SIZE     = {`DLLP} iff(last_packet_size_TX==`TLP_MIN_SIZE && last_packet_type_TX ==`TLP);
  bins DLLP_TLP_MAX_SIZE     = {`TLP}  iff(LPIF_seq_item_TX_h.Packet_Size==`TLP_MAX_SIZE && last_packet_type_TX ==`DLLP );
  bins DLLP_TLP_MIN_SIZE     = {`TLP}  iff(LPIF_seq_item_TX_h.Packet_Size==`TLP_MIN_SIZE && last_packet_type_TX ==`DLLP );
  
}

endgroup:TX_Data_Exchange_D_Cover



covergroup RX_Data_Exchange_D_Cover;

option.per_instance=1;

Packet_Type_p:coverpoint LPIF_seq_item_RX_h.packet_type {

  bins TLP_Packet  = {`TLP};
  bins DLLP_Packet = {`DLLP};
  
}

 Packet_backtoback_p: coverpoint LPIF_seq_item_RX_h.packet_type {
    bins B2B_TLP  = (`TLP => `TLP); 
    bins B2B_DLLP = (`DLLP => `DLLP);
    bins TLP_DLLP = (`TLP => `DLLP); 
    bins DLLP_TLP = (`DLLP => `TLP);
    
  }

TLP_Size_p:coverpoint LPIF_seq_item_RX_h.Packet_Size iff(LPIF_seq_item_RX_h.packet_type==`TLP) {

bins TLP_MIN_SIZE = {`TLP_MIN_SIZE};
bins TLP_MAX_SIZE = {`TLP_MAX_SIZE};
bins TLP_other_sizes = {[17:63]} ;
illegal_bins TLP_less_than_16_bytes = {[0:15]};

}


//2,3,4 tlps 


B2B_Different_Packets_Sizes:coverpoint LPIF_seq_item_RX_h.packet_type {
  
  bins B2B_TLP_MAX_SIZE      = {`TLP}  iff(LPIF_seq_item_RX_h.Packet_Size==`TLP_MAX_SIZE && last_packet_size_RX==`TLP_MAX_SIZE );
  bins B2B_TLP_MIN_SIZE      = {`TLP}  iff(LPIF_seq_item_RX_h.Packet_Size==`TLP_MIN_SIZE && last_packet_size_RX==`TLP_MIN_SIZE);
  bins TLP_DLLP_MAX_SIZE     = {`DLLP} iff(last_packet_size_RX==`TLP_MAX_SIZE && last_packet_type_RX ==`TLP);
  bins TLP_DLLP_MIN_SIZE     = {`DLLP} iff(last_packet_size_RX==`TLP_MIN_SIZE && last_packet_type_RX ==`TLP);
  bins DLLP_TLP_MAX_SIZE     = {`TLP}  iff(LPIF_seq_item_RX_h.Packet_Size==`TLP_MAX_SIZE && last_packet_type_RX ==`DLLP );
  bins DLLP_TLP_MIN_SIZE     = {`TLP}  iff(LPIF_seq_item_RX_h.Packet_Size==`TLP_MIN_SIZE && last_packet_type_RX ==`DLLP );

  
}


endgroup:RX_Data_Exchange_D_Cover

  
endclass



function Coverage_Model_D2::new(string name = "Coverage_Model_D2",uvm_component parent);
  
  super.new(name,parent);
  `uvm_info(get_type_name(),"inside constructor of Coverage_Model_D2",UVM_LOW)
  

  TX_Data_Exchange_D_Cover = new();
  RX_Data_Exchange_D_Cover = new();


endfunction 



function void  Coverage_Model_D2::build_phase(uvm_phase phase);
  
  super.build_phase(phase);
  `uvm_info(get_type_name(),"inside build phase of Coverage_Model_U2",UVM_LOW)

  TX_imp = new("TX_imp",this);
  RX_imp = new("RX_imp",this);

  
endfunction 




function void Coverage_Model_D2::connect_phase(uvm_phase phase);
  
  super.connect_phase(phase);
  `uvm_info(get_type_name(),"inside connect phase of Coverage_Model_U2",UVM_LOW)
  
endfunction



function void Coverage_Model_D2::write_TX_LPIF_D_port(LPIF_seq_item LPIF_seq_item_TX_h );
  
  this.LPIF_seq_item_TX_h = LPIF_seq_item_TX_h;
  
  TX_Data_Exchange_D_Cover.sample();
  last_packet_size_TX = LPIF_seq_item_TX_h.Packet_Size;
  last_packet_type_TX = LPIF_seq_item_TX_h.packet_type;

endfunction





function void Coverage_Model_D2::write_RX_LPIF_D_port(LPIF_seq_item LPIF_seq_item_RX_h );
  
  this.LPIF_seq_item_RX_h = LPIF_seq_item_RX_h;
  
  RX_Data_Exchange_D_Cover.sample();
  last_packet_size_RX = LPIF_seq_item_RX_h.Packet_Size;
  last_packet_type_RX = LPIF_seq_item_RX_h.packet_type;

endfunction
