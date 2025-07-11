class LTSSM2_D_Sequencer extends uvm_sequencer #(LPIF_seq_item);
        `uvm_component_utils(LTSSM2_D_Sequencer);

        extern function new(string name="LTSSM2_D_Sequencer",uvm_component phase);

endclass


    function LTSSM2_D_Sequencer::new(string name="LTSSM2_D_Sequencer",uvm_component phase);
        super.new(name,phase);
    endfunction
