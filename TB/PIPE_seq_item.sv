class PIPE_seq_item extends uvm_sequence_item;
  
`uvm_object_utils(PIPE_seq_item)


bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] TxData;
bit [`LANESNUMBER-1:0] TxDataValid;
bit [`LANESNUMBER-1:0] TxElecIdle;
bit [`LANESNUMBER-1:0] TxStartBlock;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] TxDataK;
bit [2*`LANESNUMBER -1:0] TxSyncHeader;
bit [`LANESNUMBER-1:0] TxDetectRx_Loopback;





bit [`MAXPIPEWIDTH*`LANESNUMBER-1:0] RxData;
bit [`LANESNUMBER-1:0] RxDataValid;
bit [(`MAXPIPEWIDTH/8)*`LANESNUMBER-1:0] RxDataK;
bit [`LANESNUMBER-1:0] RxStartBlock;
bit [2*`LANESNUMBER-1:0] RxSyncHeader;
bit [3*`LANESNUMBER-1:0] RxStatus;
bit [`LANESNUMBER-1:0] RxElecIdle;

/////LTSSM Related Signals\\\\\

bit phy_reset;
bit [1:0] width;
bit [4*`LANESNUMBER-1:0] PowerDown;
bit [3:0] Rate;
bit [`LANESNUMBER-1:0] PhyStatus;
bit [4:0] PCLKRate;
bit PclkChangeAck;
bit PclkChangeOk;
bit [18*`LANESNUMBER-1:0] LocalTxPresetCoefficients;
bit [18*`LANESNUMBER-1:0] TxDeemph;
bit [6*`LANESNUMBER-1:0] LocalFS;
bit [6*`LANESNUMBER-1:0] LocalLF;
bit [4*`LANESNUMBER-1:0] LocalPresetIndex;
bit [`LANESNUMBER-1:0] GetLocalPresetCoeffcients;
bit [`LANESNUMBER-1:0] LocalTxCoefficientsValid;
bit [6*`LANESNUMBER-1:0] LF;
bit [6*`LANESNUMBER-1:0] FS;
bit [`LANESNUMBER-1:0] RxEqEval;
bit [`LANESNUMBER-1:0] InvalidRequest;
bit [6*`LANESNUMBER-1:0] LinkEvaluationFeedbackDirectionChange;
bit [7:0] M2P_MessageBus;
bit [7:0] P2M_MessageBus;
bit [15:0] RxStandby;





bit[5:0] Current_Substate,Next_Substate;
bit[16:0] TS_Count;
bit[2:0] TS_Type;
bit linkup_in_upstream,linkup_on_down_stream;
bit time_out ;

static bit time_out_to_rec_speed_U,time_out_to_rec_speed_D;
static bit [4:0] start_Timer_U,start_Timer_D;
static bit [2:0]supported_speed_in_upstream,supported_speed_in_downstream;


static bit Rx_polling_active_complete_U ,Rx_polling_active_complete_D ;
static bit Rx_Config_Link_Width_Start_U ,Rx_Config_Link_Width_Start_D ;
static bit Rx_Config_Idle_U ,Rx_Config_Idle_D ;

static bit Rx_Config_Complete_U ,Rx_Config_Complete_D ;

static bit Rx_recoveryRcvrLock_U ,Rx_recoveryRcvrLock_D ;
static bit Rx_recoveryRcvrCfg_U ,Rx_recoveryRcvrCfg_D ;
static bit Rx_recoveryIdle_U ,Rx_recoveryIdle_D ;


static bit Speed_change_bit_U;
static bit [7:0] rate_identifier_U;
static bit [7:0] symbol_6_U;
static bit [3:0] TX_Preset_U;
static bit Speed_change_bit_D;
static bit [7:0] rate_identifier_D;
static bit [7:0] symbol_6_D;
static bit [1:0] EC_u;
static bit[4:0]  Negotiated_Speed_D;
static bit[4:0]  Highest_Comm_Speed;
static bit reset_lfsr_now;
static bit start_error_injection;


static bit [5:0] substate_error_in_down;
static bit [5:0] substate_error_in_Up;

static bit [4:0] current_Rate;
bit[1:0] operation;

static bit[5:0] Current_Substate_U,Current_Substate_D;


function new(string name = "PIPE_seq_item");
    super.new(name);
endfunction



endclass