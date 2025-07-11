class TLP_vSeq_TX_MASTER  extends uvm_sequence #(LPIF_seq_item) ;
  
`uvm_object_utils(TLP_vSeq_TX_MASTER)

TX_Master_D_Sequencer sqr_d;
TX_Master_U_Sequencer sqr_u;


TLP_Seq_TX_MASTER_D TLP_Seq_TX_MASTER_D_h;
TLP_Seq_TX_MASTER_U TLP_Seq_TX_MASTER_U_h;


function new (string name = "TLP_vSeq_TX_MASTER");
		super.new (name);
	endfunction


task body ();
  
TLP_Seq_TX_MASTER_U_h = TLP_Seq_TX_MASTER_U::type_id::create("TLP_Seq_TX_MASTER_U");
TLP_Seq_TX_MASTER_D_h = TLP_Seq_TX_MASTER_D::type_id::create("TLP_Seq_TX_MASTER_D");



fork

 begin
	TLP_Seq_TX_MASTER_U_h.start(sqr_u);
 end
 
 begin
	TLP_Seq_TX_MASTER_D_h.start(sqr_d);
 end
	     
join_any


endtask


endclass
