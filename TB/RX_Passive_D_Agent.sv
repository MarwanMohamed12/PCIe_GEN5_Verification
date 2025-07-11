class RX_Passive_D_Agent extends uvm_agent;


      `uvm_component_utils(RX_Passive_D_Agent)


      uvm_analysis_port#(LPIF_seq_item) send_ap;


      RX_Passive_D_Monitor RX_Passive_D_Monitor_h;
      
      
      RX_Passive_Config RX_Passive_D_Config_h;


      extern function new (string name = "RX_Passive_D_Agent", uvm_component parent = null);
     
      extern function void build_phase (uvm_phase phase);
      
      extern function void connect_phase (uvm_phase phase);
      
      extern task run_phase (uvm_phase phase);



endclass




      function RX_Passive_D_Agent::new (string name = "RX_Passive_D_Agent", uvm_component parent = null);
         
         super.new(name,parent);

      endfunction




      function void RX_Passive_D_Agent::build_phase (uvm_phase phase);
      
         super.build_phase(phase);

         RX_Passive_D_Monitor_h = RX_Passive_D_Monitor::type_id::create("RX_Passive_D_Monitor_h",this);
         

         if(!uvm_config_db #(RX_Passive_Config)::get(this,"","RX_Passive_D_Config_h",RX_Passive_D_Config_h))begin
            
            `uvm_fatal("build_phase","Can't be able to get RX_Passive_D configuration object");

         end
         
         send_ap = new("send_ap",this);
         
      endfunction



      function void RX_Passive_D_Agent::connect_phase (uvm_phase phase);
      
         super.connect_phase(phase);
         
         RX_Passive_D_Monitor_h.LPIF_vif_h = RX_Passive_D_Config_h.LPIF_vif_h;
         
         RX_Passive_D_Monitor_h.send_ap.connect(this.send_ap);

      endfunction



      task RX_Passive_D_Agent::run_phase (uvm_phase phase);

         super.run_phase(phase);

      endtask