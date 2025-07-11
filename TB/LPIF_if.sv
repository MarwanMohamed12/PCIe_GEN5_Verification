interface LPIF_if (input bit LCLK);



/////LTSSM Related Signals\\\\\
logic lpreset; 
logic[3:0] lp_state_req;
logic[3:0] pl_state_sts;
logic[2:0] pl_speedmode;
bit lp_force_detect;
logic pl_linkUp;




/////TX Related Signals\\\\\
logic  lp_irdy;    
logic[64-1:0] lp_dlpstart;
logic[64-1:0] lp_dlpend;
logic[64-1:0] lp_tlpstart;
logic[64-1:0] lp_tlpend;
logic[512-1:0] lp_data;
logic[64-1:0] lp_valid;




/////RX Related Signals\\\\\
logic pl_trdy;
logic[64-1:0] pl_dlpstart;
logic[64-1:0] pl_dlpend;
logic[64-1:0] pl_tlpstart;
logic[64-1:0] pl_tlpend;
logic[64-1:0] pl_tlpedb;
logic[512-1:0] pl_data;
logic[64-1:0] pl_valid;






property PCIe_Reset;
  
  @(posedge LCLK) (lpreset==0) |-> ##[0:$] (pl_state_sts==0 && pl_speedmode==0);
  
endproperty


property Link_up;
  
  @(posedge LCLK) (lp_state_req==1) |-> ##[1:$] $rose(pl_linkUp);
  
endproperty




property Speed_Change;
  
  @(posedge LCLK) (pl_speedmode==1 && pl_state_sts==11) |-> ##[1:$] (pl_speedmode==2 || pl_speedmode==3 || pl_speedmode==4 || pl_speedmode==5);
  
endproperty



property Forcing_Detect; 
  
  @(posedge LCLK) (lp_force_detect==1) |-> ##[1:$] (pl_state_sts == 0);
  
endproperty




property PHY_Ready_To_Accept_Data;
  
  @(posedge LCLK) (lp_irdy==1) |-> ##[1:$] $rose(pl_trdy);
  
endproperty


cover property (PCIe_Reset);
cover property (Link_up);
cover property (Speed_Change);
cover property (Forcing_Detect);
cover property (PHY_Ready_To_Accept_Data);



endinterface