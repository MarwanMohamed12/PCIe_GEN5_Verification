
class LTSSM2_U_Monitor extends uvm_monitor;
      
        `uvm_component_utils(LTSSM2_U_Monitor)
        virtual LPIF_if LPIF_vif_h; 
        
        uvm_analysis_port #(LTSSM2_seq_item) send_ap;
        
        LTSSM2_seq_item item;

        extern function new(string name="LTSSM2_U_Monitor",uvm_component parent);

        extern function void build_phase(uvm_phase phase);

        extern task run_phase(uvm_phase phase);

        

    endclass


        function LTSSM2_U_Monitor::new(string name="LTSSM2_U_Monitor",uvm_component parent);
            super.new(name,parent);
        endfunction 

        function void LTSSM2_U_Monitor::build_phase(uvm_phase phase);
            super.build_phase(phase);
            send_ap = new("send_ap",this);
        endfunction
     
        task LTSSM2_U_Monitor::run_phase(uvm_phase phase);
            super.run_phase(phase);


        /*forever begin
        item=LTSSM2_seq_item::type_id::create("item");

        // @(posedge LPIF_vif_h.LCLK)

         /*if( ( LPIF_vif_h.pl_linkUp == 1 ) && (LPIF_vif_h.pl_speedmode == 3'b101 ) )
            item.set_reset = 1 ;

        end*/
        endtask
        
