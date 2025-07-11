
class TX_Master_D_Sequencer extends uvm_sequencer #(LPIF_seq_item);
        `uvm_component_utils(TX_Master_D_Sequencer)

        extern function new(string name="TX_Master_D_Sequencer",uvm_component phase);

endclass



function TX_Master_D_Sequencer::new(string name="TX_Master_D_Sequencer",uvm_component phase);
            super.new(name,phase);
endfunction
