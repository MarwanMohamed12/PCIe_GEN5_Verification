class LinkUp1_vseq  extends uvm_sequence #(PIPE_seq_item) ;
  
`uvm_object_utils(LinkUp1_vseq)

LTSSM1_D_Sequencer sqr_u1;
LTSSM1_U_Sequencer sqr_u2;

PIPE_seq_item PIPE_Item_h;

linkup_seq1 Linkup_seq_D,Linkup_seq_U;
Reset_LTSSM1_seq reset_seq_D,reset_seq_U;
set_preset_seq					set_preset_seq_U,set_preset_seq_D;


function new (string name = "LinkUp1_vseq");
		super.new (name);
	endfunction


task body ();
  
  PIPE_Item_h = PIPE_seq_item::type_id::create("seq_item");

  reset_seq_D = Reset_LTSSM1_seq::type_id::create("reset_seq_D");
  reset_seq_U = Reset_LTSSM1_seq::type_id::create("reset_seq_U");

  Linkup_seq_D = linkup_seq1::type_id::create("Linkup_seq_D");
  Linkup_seq_U = linkup_seq1::type_id::create("Linkup_seq_U"); 

  set_preset_seq_U = set_preset_seq::type_id::create("set_preset_seq_U");
	set_preset_seq_D = set_preset_seq::type_id::create("set_preset_seq_D"); 

  reset_seq_D.start(sqr_u1);
  reset_seq_U.start(sqr_u2);

   
  #50;

  fork

    Linkup_seq_D.start(sqr_u1);

    Linkup_seq_U.start(sqr_u2);

  join

	wait( PIPE_Item_h.Current_Substate_D == `Recovery_RcvrLock );



  fork

		set_preset_seq_D.start(sqr_u1);

		set_preset_seq_U.start(sqr_u2);

	join


endtask


endclass
