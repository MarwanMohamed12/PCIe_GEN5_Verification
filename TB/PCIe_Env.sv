class PCIe_Env extends uvm_env;
  
`uvm_component_utils(PCIe_Env)

TX_Slave_D_Agent TX_Slave_D_Agent_h; 
TX_Slave_U_Agent TX_Slave_U_Agent_h;
RX_Slave_D_Agent RX_Slave_D_Agent_h; 
RX_Slave_U_Agent RX_Slave_U_Agent_h;

TX_Master_D_Agent TX_Master_D_Agent_h;
TX_Master_U_Agent TX_Master_U_Agent_h;
RX_Passive_D_Agent RX_Passive_D_Agent_h;
RX_Passive_U_Agent RX_Passive_U_Agent_h;

LTSSM1_D_Agent   LTSSM1_D_Agent_h;
LTSSM1_U_Agent   LTSSM1_U_Agent_h;
LTSSM2_D_Agent   LTSSM2_D_Agent_h;
LTSSM2_U_Agent   LTSSM2_U_Agent_h;

Adapter          Adapter_h;

Coverage_Model_D1 Coverage_Model_D1_h;
Coverage_Model_U1 Coverage_Model_U1_h;

Coverage_Model_D2 Coverage_Model_D2_h;
Coverage_Model_U2 Coverage_Model_U2_h;

PCIe_Scoreboard1_U PCIe_Scoreboard1_U_h;
PCIe_Scoreboard1_D PCIe_Scoreboard1_D_h;

PCIe_Scoreboard2_U PCIe_Scoreboard2_U_h;
PCIe_Scoreboard2_D PCIe_Scoreboard2_D_h;


function new(string name = "PCIe_Env",uvm_component parent);
  
    super.new(name,parent);
    
endfunction




function void build_phase(uvm_phase phase);
  
    super.build_phase(phase);
    
    
    TX_Master_D_Agent_h = TX_Master_D_Agent::type_id::create("TX_Master_D_Agent_h",this);
    TX_Master_U_Agent_h = TX_Master_U_Agent::type_id::create("TX_Master_U_Agent",this);

    RX_Passive_D_Agent_h = RX_Passive_D_Agent::type_id::create("RX_Passive_D_Agent_h",this);
    RX_Passive_U_Agent_h = RX_Passive_U_Agent::type_id::create("RX_Passive_U_Agent_h",this);
    
    TX_Slave_D_Agent_h    = TX_Slave_D_Agent::type_id::create("TX_Slave_D_Agent_h",this);
    TX_Slave_U_Agent_h    = TX_Slave_U_Agent::type_id::create("TX_Slave_U_Agent_h",this);
    
    RX_Slave_D_Agent_h    = RX_Slave_D_Agent::type_id::create("RX_Slave_D_Agent_h",this);
    RX_Slave_U_Agent_h    = RX_Slave_U_Agent::type_id::create("RX_Slave_U_Agent_h",this);
    
    LTSSM1_D_Agent_h      = LTSSM1_D_Agent::type_id::create("LTSSM1_D_Agent_h",this);
    LTSSM1_U_Agent_h      = LTSSM1_U_Agent::type_id::create("LTSSM1_U_Agent_h",this);
    
    LTSSM2_D_Agent_h      = LTSSM2_D_Agent::type_id::create("LTSSM2_D_Agent_h",this);
    LTSSM2_U_Agent_h      = LTSSM2_U_Agent::type_id::create("LTSSM2_U_Agent_h",this);

    Coverage_Model_D1_h   = Coverage_Model_D1::type_id::create("Coverage_Model_D1_h",this);
    Coverage_Model_U1_h   = Coverage_Model_U1::type_id::create("Coverage_Model_U1_h",this);
    
    Coverage_Model_D2_h   = Coverage_Model_D2::type_id::create("Coverage_Model_D2_h",this);
    Coverage_Model_U2_h   = Coverage_Model_U2::type_id::create("Coverage_Model_U2_h",this);

    Adapter_h             = Adapter::type_id::create("Adapter_h",this);    

    PCIe_Scoreboard1_D_h = PCIe_Scoreboard1_D::type_id::create("PCIe_Scoreboard1_D_h",this);
    PCIe_Scoreboard1_U_h = PCIe_Scoreboard1_U::type_id::create("PCIe_Scoreboard1_U_h",this);
    
    PCIe_Scoreboard2_D_h = PCIe_Scoreboard2_D::type_id::create("PCIe_Scoreboard2_D_h",this);
    PCIe_Scoreboard2_U_h = PCIe_Scoreboard2_U::type_id::create("PCIe_Scoreboard2_U_h",this);
    
endfunction





function void connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    Adapter_h.Adapter_To_D_RX_ap.connect(RX_Slave_D_Agent_h.receive_ap);
    Adapter_h.Adapter_To_U_RX_ap.connect(RX_Slave_U_Agent_h.receive_ap);
    
    TX_Slave_D_Agent_h.send_ap1.connect(Adapter_h.Adapter_From_D_TX_af.analysis_export);
    TX_Slave_U_Agent_h.send_ap1.connect(Adapter_h.Adapter_From_U_TX_af.analysis_export);
    
    TX_Slave_D_Agent_h.send_ap2.connect(Coverage_Model_D1_h.TX_imp);
    RX_Slave_D_Agent_h.send_ap.connect(Coverage_Model_D1_h.RX_imp);
    
    TX_Slave_U_Agent_h.send_ap2.connect(Coverage_Model_U1_h.TX_imp);
    RX_Slave_U_Agent_h.send_ap.connect(Coverage_Model_U1_h.RX_imp);
    
    TX_Master_U_Agent_h.send_ap.connect(Coverage_Model_U2_h.TX_imp);
    RX_Passive_U_Agent_h.send_ap.connect(Coverage_Model_U2_h.RX_imp);
    
    TX_Master_D_Agent_h.send_ap.connect(Coverage_Model_D2_h.TX_imp);
    RX_Passive_D_Agent_h.send_ap.connect(Coverage_Model_D2_h.RX_imp);
 

 
    TX_Slave_U_Agent_h.send_ap2.connect(PCIe_Scoreboard1_U_h.FIFO_TX_af.analysis_export);
    TX_Slave_D_Agent_h.send_ap2.connect(PCIe_Scoreboard1_D_h.FIFO_TX_af.analysis_export);
    RX_Slave_U_Agent_h.send_ap.connect(PCIe_Scoreboard1_U_h.FIFO_RX_af.analysis_export);
    RX_Slave_D_Agent_h.send_ap.connect(PCIe_Scoreboard1_D_h.FIFO_RX_af.analysis_export);
 

    TX_Master_U_Agent_h.send_ap.connect(PCIe_Scoreboard2_U_h.TX_af.analysis_export);
    TX_Master_D_Agent_h.send_ap.connect(PCIe_Scoreboard2_D_h.TX_af.analysis_export);    
    RX_Passive_D_Agent_h.send_ap.connect(PCIe_Scoreboard2_U_h.RX_af.analysis_export);
    RX_Passive_U_Agent_h.send_ap.connect(PCIe_Scoreboard2_D_h.RX_af.analysis_export);
    
    

endfunction




task run_phase(uvm_phase phase);
  
    super.run_phase(phase);
    
endtask


endclass