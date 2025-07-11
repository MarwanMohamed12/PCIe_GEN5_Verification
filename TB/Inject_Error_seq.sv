


class set_preset_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(set_preset_seq)

    PIPE_seq_item seq_item;


    function new (string name = "set_preset_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);

        seq_item.operation = 2'b10;

    finish_item(seq_item);

    endtask

endclass


class polling_active_error_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(polling_active_error_seq)

    PIPE_seq_item seq_item;

    function new (string name = "polling_active_error_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Polling_Active;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);

    endtask

endclass


class polling_config_error_seq extends uvm_sequence #(PIPE_seq_item);
  `uvm_object_utils(polling_config_error_seq)

    PIPE_seq_item seq_item;

    function new (string name = "polling_config_error_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");


    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Polling_Configuration ;
        seq_item.substate_error_in_Up   = 100;
    finish_item(seq_item);


    endtask

endclass

class Config_Link_Width_Start_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Link_Width_Start_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Link_Width_Start_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Config_Link_Width_Start;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Config_Link_Width_Accept_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Link_Width_Accept_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Link_Width_Accept_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Config_Link_Width_Accept;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);



    endtask

endclass

class Config_Lanenum_Wait_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Lanenum_Wait_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Lanenum_Wait_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Config_Lanenum_Wait;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass


class Config_Lanenum_Accept_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Lanenum_Accept_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Lanenum_Accept_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Config_Lanenum_Accept;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass


class Config_Lanenum_Accept_in_Up_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Lanenum_Accept_in_Up_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Lanenum_Accept_in_Up_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down =  100; //invalid substate
        seq_item.substate_error_in_Up   = `Config_Lanenum_Accept;

    finish_item(seq_item);


    endtask

endclass

class Config_Complete_seq_in_down extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Complete_seq_in_down)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Complete_seq_in_down");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;  
        seq_item.substate_error_in_down = `Config_Complete;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Config_Complete_seq_in_up extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Complete_seq_in_up)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Complete_seq_in_up");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;  
        seq_item.substate_error_in_down = 100     ;
        seq_item.substate_error_in_Up   = `Config_Complete;

    finish_item(seq_item);


    endtask

endclass


class Config_Idle_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Config_Idle_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Config_Idle_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Config_Idle;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Recovery_RcvrLock_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Recovery_RcvrLock_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Recovery_RcvrLock_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01; 
        seq_item.substate_error_in_down = `Recovery_RcvrLock;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Phase0_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Phase0_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Phase0_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Phase0;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Recovery_Idle_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Recovery_Idle_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Recovery_Idle_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Recovery_Idle;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Recovery_RcvrCfg_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Recovery_RcvrCfg_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Recovery_RcvrCfg_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Recovery_RcvrCfg;
        seq_item.current_Rate      = 1    ;       
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Recovery_RcvrCfg2_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Recovery_RcvrCfg2_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Recovery_RcvrCfg2_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01; 
        seq_item.substate_error_in_down = `Recovery_RcvrCfg;
        seq_item.current_Rate      = 5    ;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class Recovery_speed_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(Recovery_speed_seq)

    PIPE_seq_item seq_item;

    function new (string name = "Recovery_speed_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Recovery_Speed;
        seq_item.substate_error_in_Up   = 100;

    finish_item(seq_item);


    endtask

endclass

class phase1_seq extends uvm_sequence #(PIPE_seq_item);
 `uvm_object_utils(phase1_seq)

    PIPE_seq_item seq_item;

    function new (string name = "phase1_seq");

    super.new(name);

    endfunction

    task body ();

    seq_item = PIPE_seq_item::type_id::create("seq_item");

    start_item(seq_item);
        
        seq_item.operation = 2'b01;
        seq_item.substate_error_in_down = `Phase1;
        seq_item.substate_error_in_Up   = 100;
        
    finish_item(seq_item);


    endtask

endclass



