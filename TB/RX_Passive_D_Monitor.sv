class RX_Passive_D_Monitor extends uvm_monitor;

        `uvm_component_utils(RX_Passive_D_Monitor)
        
        uvm_analysis_port #(LPIF_seq_item) send_ap;
        
        virtual LPIF_if LPIF_vif_h;

        LPIF_seq_item LPIF_seq_item_h;
        


        // Handling DLLP //
        typedef enum {DLLP_WAIT ,DLLP_DONE} DLLP_Status;
        DLLP_Status DLLP_status;
        bit [7:0] DLLP_Byte;
        bit detect_DLLP ; 

        // Handling TLP //
        typedef enum {TLP_WAIT ,TLP_DONE} TLP_Status;
        TLP_Status TLP_status;
        bit [7:0] TLP_Byte;
        bit detect_TLP; 

        

        extern function new (string name = "RX_Passive_D_Monitor", uvm_component parent = null);
        
        extern function void build_phase (uvm_phase phase);
        
        extern function void connect_phase (uvm_phase phase);
        
        extern task run_phase (uvm_phase phase);

//        extern task Link_Ready ();

 //       extern task check_if_valid_data ();

        extern task Handle_TLP_DLLP ();

        extern task Broadcast_DLLP (LPIF_seq_item LPIF_seq_item_h);

        extern task Broadcast_TLP (LPIF_seq_item LPIF_seq_item_h);


endclass



        function RX_Passive_D_Monitor::new (string name = "RX_Passive_D_Monitor", uvm_component parent = null);
            
            super.new(name,parent);

        endfunction




        function void RX_Passive_D_Monitor::build_phase (uvm_phase phase);
        
            super.build_phase(phase);
            
            send_ap = new("send_ap",this);
        
        endfunction



        function void RX_Passive_D_Monitor::connect_phase (uvm_phase phase);
        
            super.connect_phase(phase);

        endfunction



        task RX_Passive_D_Monitor::run_phase (uvm_phase phase);

            super.run_phase(phase);

            forever begin
             
                
                @(posedge LPIF_vif_h.LCLK);
                
                if(LPIF_vif_h.pl_valid != 0)

                       Handle_TLP_DLLP();
                
                  
            end
                
        endtask
        



        task RX_Passive_D_Monitor::Handle_TLP_DLLP();

                for (int i =0 ; i<64 ; i++) begin

                            TLP_Byte = LPIF_vif_h.pl_data  >> (8*i) ;
                            DLLP_Byte = LPIF_vif_h.pl_data >> (8*i) ;                          

                            if( LPIF_vif_h.pl_tlpstart[i] == 1 ) begin
                              
                                LPIF_seq_item_h = LPIF_seq_item::type_id::create("LPIF_seq_item_h"); 
                                
                                TLP_status = TLP_WAIT;
                                
                                detect_TLP = 1'b1;
                                
                                if( LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.TLP.push_back(TLP_Byte);
                                
                                end
                            
                            end

                            else if( LPIF_vif_h.pl_tlpend[i] == 1 ) begin
                                
                                TLP_status = TLP_DONE;
                                
                                detect_TLP = 1'b0;

                                if(LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.TLP.push_back(TLP_Byte);
                                    
                                    Broadcast_TLP(LPIF_seq_item_h);

                                end
                            
                            end

                            else if ( detect_TLP ) begin
                                
                                if( LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.TLP.push_back(TLP_Byte);

                                end 
                            
                            end

                            if( LPIF_vif_h.pl_dlpstart[i] == 1 ) begin
                              
                                LPIF_seq_item_h = LPIF_seq_item::type_id::create("LPIF_seq_item_h"); 
                                
                                DLLP_status = DLLP_WAIT;
                                
                                detect_DLLP = 1'b1;
                                
                                if(LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.DLLP.push_back(DLLP_Byte);
                                
                                end
                            
                            end

                            else if( LPIF_vif_h.pl_dlpend[i] == 1 ) begin
                                
                                DLLP_status = DLLP_DONE;

                                detect_DLLP = 1'b0;

                                if(LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.DLLP.push_back(DLLP_Byte);
                                    
                                    Broadcast_DLLP(LPIF_seq_item_h);

                                end
                            
                            end

                            else if ( detect_DLLP ) begin
                                
                                if( LPIF_vif_h.pl_valid[i] == 1 ) begin
                                    
                                    LPIF_seq_item_h.DLLP.push_back(DLLP_Byte);

                                end 
                            
                            end
                            
                                                
                end
        
        
        
        endtask


        task RX_Passive_D_Monitor::Broadcast_TLP (LPIF_seq_item LPIF_seq_item_h);

                LPIF_seq_item_h.number_of_TLP_D++;

                LPIF_seq_item_h.packet_type = 2'b00;
                
                LPIF_seq_item_h.Packet_Size = LPIF_seq_item_h.TLP.size();
                
                send_ap.write(LPIF_seq_item_h);

                TLP_status = TLP_WAIT;


        endtask

         task RX_Passive_D_Monitor::Broadcast_DLLP (LPIF_seq_item LPIF_seq_item_h);

                LPIF_seq_item_h.number_of_DLLP_D++;

                LPIF_seq_item_h.packet_type = 2'b10;
                
                send_ap.write(LPIF_seq_item_h);

                DLLP_status = DLLP_WAIT;

                

        endtask



