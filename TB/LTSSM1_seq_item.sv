class LTSSM1_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(LTSSM1_seq_item)

// Items // 
bit [1:0] operation;
bit phy_reset;
bit[`LANESNUMBER-1:0] TxDetectRx_Loopback;
bit[3*`LANESNUMBER -1:0] RxStatus;
bit [1:0] width;
bit [4*`LANESNUMBER-1:0] PowerDown;
bit [3:0] Rate;
bit [`LANESNUMBER-1:0] PhyStatus;
bit [4:0] PCLKRate;
bit PclkChangeAck;
bit PclkChangeOk;
bit [18*`LANESNUMBER -1:0] LocalTxPresetCoefficients;
bit [18*`LANESNUMBER -1:0] TxDeemph;
bit [6*`LANESNUMBER -1:0] LocalFS;
bit [6*`LANESNUMBER -1:0] LocalLF;
bit [4*`LANESNUMBER -1:0] LocalPresetIndex;
bit [`LANESNUMBER -1:0] GetLocalPresetCoeffcients;
bit [`LANESNUMBER -1:0] LocalTxCoefficientsValid;
bit [6*`LANESNUMBER -1:0] LF;
bit [6*`LANESNUMBER -1:0] FS;
bit [`LANESNUMBER -1:0] RxEqEval;
bit [`LANESNUMBER -1:0] InvalidRequest;
bit [6*`LANESNUMBER -1:0] LinkEvaluationFeedbackDirectionChange;
bit [7:0] M2P_MessageBus;
bit [7:0] P2M_MessageBus;
bit [15:0] RxStandby;

//-----------------------
static bit [5:0] substate_err;
static bit [4:0] current_Rate;



// Constructor //
function new (string name = "LTSSM1_seq_item");

super.new(name);

endfunction


function string convert2string();

return $sformatf("%s , operation = 0b%b ",super.convert2string(),operation);

endfunction

function string convert2string_stimulus();

return $sformatf("operation = 0b%b ",operation);

endfunction


// Constraint Blocks //



endclass