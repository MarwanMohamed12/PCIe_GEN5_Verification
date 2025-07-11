module PCIe #(
	
	parameter MAXPIPEWIDTH = 32,
	parameter DEVICETYPE = 0, //0 for downstream 1 for upstream
	parameter LANESNUMBER =16,
	parameter GEN1_PIPEWIDTH = 8 ,	
	parameter GEN2_PIPEWIDTH = 8 ,	
	parameter GEN3_PIPEWIDTH = 8 ,								
	parameter GEN4_PIPEWIDTH = 8 ,	
	parameter GEN5_PIPEWIDTH = 8 ,	
	parameter MAX_GEN = 1
)
(
//clk and reset 
input CLK,
input lpreset,
output phy_reset,
//PIPE interface width
output [1:0] width, ///////////////////which module
//TX_signals
output [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData,
output [LANESNUMBER-1:0]TxDataValid,
output [LANESNUMBER-1:0]TxElecIdle,
output [LANESNUMBER-1:0]TxStartBlock,
output [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK,
output [2*LANESNUMBER -1:0]TxSyncHeader,
output [LANESNUMBER-1:0]TxDetectRx_Loopback,
//RX_signals
input  	[MAXPIPEWIDTH*LANESNUMBER-1:0]RxData,
input   [LANESNUMBER-1:0]RxDataValid,
input	[(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]RxDataK,
input	[LANESNUMBER-1:0]RxStartBlock,
input	[2*LANESNUMBER -1:0]RxSyncHeader,
input	[3*LANESNUMBER -1:0]RxStatus,
input   [15:0]RxElectricalIdle,
//commands and status signals
output  [4*LANESNUMBER-1:0]PowerDown,
output  [3:0] Rate,
input   [LANESNUMBER-1:0]PhyStatus,

//pclkcontrolsignal
output [4:0]PCLKRate,
output PclkChangeAck,
input  PclkChangeOk,
//eq_signals
input 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients,
output 	[18*LANESNUMBER -1:0]TxDeemph,
input 	[6*LANESNUMBER -1:0]LocalFS,
input 	[6*LANESNUMBER -1:0]LocalLF,
output 	[4*LANESNUMBER -1:0]LocalPresetIndex,
output 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients,
input 	[LANESNUMBER -1:0]LocalTxCoefficientsValid,
output 	[6*LANESNUMBER -1:0]LF,
output 	[6*LANESNUMBER -1:0]FS,
output 	[LANESNUMBER -1:0]RxEqEval,
output 	[LANESNUMBER -1:0]InvalidRequest,
input 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange,

output pl_trdy,
input  lp_irdy,
input  [512-1:0]lp_data,
input  [64-1:0]lp_valid,
output [512-1:0]pl_data,
output [64-1:0] pl_valid,
input  [3:0]lp_state_req,
output [3:0]pl_state_sts,
output [2:0]pl_speedmode,////////////////////////////////////////
input lp_force_detect,
////lPIF start & end of TLP DLLP
input [64-1:0]lp_dlpstart,
input [64-1:0]lp_dlpend,
input [64-1:0]lp_tlpstart,
input [64-1:0]lp_tlpend,
output [64-1:0]pl_dlpstart,
output [64-1:0]pl_dlpend,
output [64-1:0]pl_tlpstart,
output [64-1:0]pl_tlpend,
output [64-1:0]pl_tlpedb,
output pl_linkUp,
//optional Message bus
output [7:0] M2P_MessageBus,
input  [7:0] P2M_MessageBus,
output  [15:0] RxStandby
);

wire WriteDetectLanesFlag;
wire [4:0] SetTXState;
wire TXFinishFlag;
wire [4:0]TXExitTo;
wire WriteLinkNumFlagTx,WriteLinkNumFlagRx;
wire [4:0] NumberDetectLanesfromtx;
wire [2:0]GEN; 
wire [4:0]numberOfDetectedLanes;
wire [4:0]RXsubstate;
wire [7:0]linkNumberRxInput,linkNumberTxInput,linkNumberRxOutput,linkNumberTxOutput;
wire [7:0] rateid,rateIdInTx;
wire upConfigureCapability,upConfigureCapabilityInTX;
wire RXfinish;
wire [4:0]RXexitTo;
///////////output pl_linkUp,////////////
wire witeUpconfigureCapability;
wire writerateid;
wire  directed_speed_change;
wire  [47:0] ReceiverpresetHintDSP;
wire  [63:0] TransmitterPresetHintDSP;
wire  [47:0] ReceiverpresetHintUSP;
wire  [63:0] TransmitterPresetHintUSP;
wire  [6*16-1:0]LF_register;
wire  [6*16-1:0]FS_register;
wire  [6*16-1:0]CursorCoff;
wire  [6*16-1:0]PreCursorCoff;
wire  [6*16-1:0]PostCursorCoff;
wire  [47:0] ReceiverpresetHintDSPIn;
wire  [63:0] TransmitterPresetHintDSPIn;
wire  [47:0] ReceiverpresetHintUSPIn;
wire  [63:0] TransmitterPresetHintUSPIn;
wire writeReceiverpresetHintDSP;
wire writeTransmitterPresetHintDSP;
wire writeReceiverpresetHintUSP;
wire writeTransmitterPresetHintUSP;
wire directed_speed_change_In;
wire write_directed_speed_chang;
wire [2:0] trainToGen;
wire [16*6-1:0] FSDSP,LFDSP;
wire disableScrambler;
wire turnOffScrambler_flag;
wire startSend16;

mainLTSSM #(
.Width(MAXPIPEWIDTH),
.DEVICETYPE(DEVICETYPE), //0 for downstream 1 for upstream
.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),	
.GEN2_PIPEWIDTH (GEN2_PIPEWIDTH) ,	
.GEN3_PIPEWIDTH (GEN3_PIPEWIDTH),	
.GEN4_PIPEWIDTH (GEN4_PIPEWIDTH) ,	
.GEN5_PIPEWIDTH (GEN5_PIPEWIDTH),
.LANESNUMBER(LANESNUMBER),
.MAX_GEN(MAX_GEN)
) mainltssm(
    .clk(CLK),
    .reset(lpreset),
    .lpifStateRequest(lp_state_req),
    .numberOfDetectedLanesIn(NumberDetectLanesfromtx),
    .rateIdIn(rateid),
    .upConfigureCapabilityIn(upConfigureCapability),
    .writeNumberOfDetectedLanes(WriteDetectLanesFlag),
    .writeUpconfigureCapability(witeUpconfigureCapability),
    .writeRateId(writerateid),
    .finishTx(TXFinishFlag),
    .finishRx( RXfinish),
    .gotoTx(TXExitTo),
    .gotoRx(RXexitTo),
    .forceDetect(lp_force_detect),
    .linkUp(pl_linkUp),
    .GEN(GEN),
    .numberOfDetectedLanesOut(numberOfDetectedLanes),
    .rateIdOut(rateIdInTx),
    .upConfigureCapabilityOut(upConfigureCapabilityInTX),//////not used in tx
    .lpifStateStatus(pl_state_sts),
    .substateTx(SetTXState),
    .substateRx(RXsubstate),
    .linkNumberInTx(linkNumberTxOutput),
    .linkNumberInRx(linkNumberRxOutput),
    .writeLinkNumberTx(WriteLinkNumFlagTx),
    .writeLinkNumberRx(WriteLinkNumFlagRx),
    .linkNumberOutTx(linkNumberTxInput),
    .linkNumberOutRx(linkNumberRxInput),
    .width(width),
    .ReceiverpresetHintDSPIn(ReceiverpresetHintDSPIn),
    .TransmitterPresetHintDSPIn(TransmitterPresetHintDSPIn),
    .ReceiverpresetHintUSPIn(ReceiverpresetHintUSPIn),
    .TransmitterPresetHintUSPIn(TransmitterPresetHintUSPIn),
    .writeReceiverpresetHintDSP(writeReceiverpresetHintDSP),
    .writeTransmitterPresetHintDSP(writeTransmitterPresetHintDSP),
    .writeReceiverpresetHintUSP(writeReceiverpresetHintUSP),
    .writeTransmitterPresetHintUSP(writeTransmitterPresetHintUSP),
    .directed_speed_change_In(directed_speed_change_In),
    .write_directed_speed_change(write_directed_speed_change),
    .LocalTxPresetCoefficients(LocalTxPresetCoefficients),
    .LocalFS(LocalFS),
    .LocalLF(LocalLF),
    .LocalTxCoefficientsValid(LocalTxCoefficientsValid),
    .LinkEvaluationFeedbackDirectionChange(LinkEvaluationFeedbackDirectionChange),
    .TxDeemph(TxDeemph),
    .LocalPresetIndex(LocalPresetIndex),
    .GetLocalPresetCoeffcients(GetLocalPresetCoeffcients),
    .LF(LF),
    .FS(FS),
    .RxEqEval(RxEqEval),
    .InvalidRequest(InvalidRequest),
    .directed_speed_change(directed_speed_change),
    .ReceiverpresetHintDSP(ReceiverpresetHintDSP),
    .TransmitterPresetHintDSP(TransmitterPresetHintDSP),
    .ReceiverpresetHintUSP(ReceiverpresetHintUSP),
    .TransmitterPresetHintUSP(TransmitterPresetHintUSP),
    .LF_register(LF_register),
    .FS_register(FS_register),
    .CursorCoff(CursorCoff),
    .PreCursorCoff(PreCursorCoff),
    .PostCursorCoff(PostCursorCoff),
    .trainToGen(trainToGen),
    .LFDSP(LFDSP),
    .FSDSP(FSDSP),
    .disableScrambler(disableScrambler),
    .PCLKRate(PCLKRate),
    .startSend16(startSend16),
    .turnOffScrambler_flag(turnOffScrambler_flag)
);

RX #(.DEVICETYPE(DEVICETYPE),.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),.GEN2_PIPEWIDTH(GEN2_PIPEWIDTH),.GEN3_PIPEWIDTH(GEN3_PIPEWIDTH),.GEN4_PIPEWIDTH(GEN4_PIPEWIDTH),.GEN5_PIPEWIDTH(GEN5_PIPEWIDTH))
rx
( .reset(lpreset), 
.clk(CLK), 
.GEN(GEN), 
.PhyStatus(PhyStatus), 
.RxValid(RxDataValid),
.RxStartBlock(RxStartBlock), 
.RxStatus(RxStatus),
.RxSyncHeader(RxSyncHeader), 
.RxElectricalIdle(RxElectricalIdle),
.RxData(RxData), 
.RxDataK(RxDataK),
.numberOfDetectedLanes(numberOfDetectedLanes),
.substate(RXsubstate),
.linkNumber(linkNumberRxInput),
.pl_tlpstart(pl_tlpstart), 
.pl_dllpstart(pl_dlpstart), 
.pl_tlpend(pl_tlpend),
.pl_dllpend(pl_dlpend), 
.pl_tlpedb(pl_tlpedb), 
.pl_valid(pl_valid), 
.pl_data(pl_data),
.pl_speedmode(pl_speedmode), 
.rateid(rateid),
.linkup(pl_linkUp),
.upConfigureCapability(upConfigureCapability),
.finish( RXfinish),
.exitTo(RXexitTo),
.witeUpconfigureCapability(witeUpconfigureCapability),
.writerateid(writerateid),
.linkNumberOut(linkNumberRxOutput),
.writeLinkNumber(WriteLinkNumFlagRx),
.ReceiverpresetHintDSPout(ReceiverpresetHintDSPIn),
.TransmitterPresetHintDSPout(TransmitterPresetHintDSPIn),
.ReceiverpresetHintUSPout(ReceiverpresetHintUSPIn),
.TransmitterPresetHintUSPout(TransmitterPresetHintUSPIn),
.ReceiverpresetHintDSP(ReceiverpresetHintDSP),
.TransmitterPresetHintDSP(TransmitterPresetHintDSP),
.ReceiverpresetHintUSP(ReceiverpresetHintUSP),
.TransmitterPresetHintUSP(TransmitterPresetHintUSP),
.writeReceiverpresetHintDSP(writeReceiverpresetHintDSP),
.writeTransmitterPresetHintDSP(writeTransmitterPresetHintDSP),
.writeReceiverpresetHintUSP(writeReceiverpresetHintUSP),
.writeTransmitterPresetHintUSP(writeTransmitterPresetHintUSP),
.LFDSP(LFDSP),
.FSDSP(FSDSP),
.CursorCoff(CursorCoff),
.PreCursorCoff(PreCursorCoff),
.PostCursorCoff(PostCursorCoff),
.directed_speed_change(directed_speed_change),
.trainToGen(trainToGen),
.disableScrambler(disableScrambler)
);

TOP_MODULE #
(
.MAXPIPEWIDTH(MAXPIPEWIDTH),
.DEVICETYPE(DEVICETYPE), //0 for downstream 1 for upstream
.LANESNUMBER(LANESNUMBER),
.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),	
.GEN2_PIPEWIDTH (GEN2_PIPEWIDTH) ,	
.GEN3_PIPEWIDTH (GEN3_PIPEWIDTH),	
.GEN4_PIPEWIDTH (GEN4_PIPEWIDTH) ,	
.GEN5_PIPEWIDTH (GEN5_PIPEWIDTH),	
.MAX_GEN(MAX_GEN))
TX
(.pclk(CLK),
.reset_n(lpreset),
.pl_trdy(pl_trdy),
.lp_irdy(lp_irdy),
.lp_data(lp_data),
.lp_valid(lp_valid),
.lp_dlpstart(lp_dlpstart),
.lp_dlpend(lp_dlpend),
.lp_tlpstart(lp_tlpstart),
.lp_tlpend(lp_tlpend),
.RxStatus(RxStatus),
.NumberDetectLanes(NumberDetectLanesfromtx),
.TxDetectRx_Loopback(TxDetectRx_Loopback),
.PowerDown(PowerDown),
.PhyStatus(PhyStatus),
.TxElecIdle(TxElecIdle),
.WriteDetectLanesFlag(WriteDetectLanesFlag),
.SetTXState(SetTXState),
.TXFinishFlag(TXFinishFlag),
.TXExitTo(TXExitTo), /////////////////////////
.WriteLinkNum(linkNumberTxOutput),//////////////////////////////
.WriteLinkNumFlag(WriteLinkNumFlagTx),
.ReadLinkNum(linkNumberTxInput),
.rateIdIn(rateIdInTx),
.upConfigureCapabilityIn(upConfigureCapabilityInTX),
.MainLTSSMGen(GEN),
.TxData16(TxData[31:0]),
.TxData15(TxData[63:32]),
.TxData14(TxData[95:64]),
.TxData13(TxData[127:96]),
.TxData12(TxData[159:128]),
.TxData11(TxData[191:160]),
.TxData10(TxData[223:192]),
.TxData9(TxData[255:224]),
.TxData8(TxData[287:256]),
.TxData7(TxData[319:288]),
.TxData6(TxData[351:320]),
.TxData5(TxData[383:352]),
.TxData4(TxData[415:384]),
.TxData3(TxData[447:416]),
.TxData2(TxData[479:448]),
.TxData1(TxData[511:480]),
.TxDataValid16(TxDataValid[0]),
.TxDataValid15(TxDataValid[1]),
.TxDataValid14(TxDataValid[2]),
.TxDataValid13(TxDataValid[3]),
.TxDataValid12(TxDataValid[4]),
.TxDataValid11(TxDataValid[5]),
.TxDataValid10(TxDataValid[6]),
.TxDataValid9(TxDataValid[7]),
.TxDataValid8(TxDataValid[8]),
.TxDataValid7(TxDataValid[9]),
.TxDataValid6(TxDataValid[10]),
.TxDataValid5(TxDataValid[11]),
.TxDataValid4(TxDataValid[12]),
.TxDataValid3(TxDataValid[13]),
.TxDataValid2(TxDataValid[14]),
.TxDataValid1(TxDataValid[15]),
.TxDataK16(TxDataK[3:0]),
.TxDataK15(TxDataK[7:4]),
.TxDataK14(TxDataK[11:8]),
.TxDataK13(TxDataK[15:12]),
.TxDataK12(TxDataK[19:16]),
.TxDataK11(TxDataK[23:20]),
.TxDataK10(TxDataK[27:24]),
.TxDataK9(TxDataK[31:28]),
.TxDataK8(TxDataK[35:32]),
.TxDataK7(TxDataK[39:36]),
.TxDataK6(TxDataK[43:40]),
.TxDataK5(TxDataK[47:44]),
.TxDataK4(TxDataK[51:48]),
.TxDataK3(TxDataK[55:52]),
.TxDataK2(TxDataK[59:56]),
 .TxDataK1(TxDataK[63:60]),
.TxSyncHeader1(TxSyncHeader[1:0]),
 .TxSyncHeader2(TxSyncHeader[3:2]),
 .TxSyncHeader3(TxSyncHeader[5:4]),
 .TxSyncHeader4(TxSyncHeader[7:6]),
 .TxSyncHeader5(TxSyncHeader[9:8]),
 .TxSyncHeader6(TxSyncHeader[11:10]),
 .TxSyncHeader7(TxSyncHeader[13:12]),
 .TxSyncHeader8(TxSyncHeader[15:14]),
 .TxSyncHeader9(TxSyncHeader[17:16]),
 .TxSyncHeader10(TxSyncHeader[19:18]),
 .TxSyncHeader11(TxSyncHeader[21:20]),
 .TxSyncHeader12(TxSyncHeader[23:22]),
 .TxSyncHeader13(TxSyncHeader[25:24]),
 .TxSyncHeader14(TxSyncHeader[27:26]),
 .TxSyncHeader15(TxSyncHeader[29:28]),
 .TxSyncHeader16(TxSyncHeader[31:30]),
 .TxStartBlock1(TxStartBlock[0]), 
 .TxStartBlock2(TxStartBlock[1]), 
 .TxStartBlock3(TxStartBlock[2]), 
 .TxStartBlock4(TxStartBlock[3]), 
 .TxStartBlock5(TxStartBlock[4]), 
 .TxStartBlock6(TxStartBlock[5]), 
 .TxStartBlock7(TxStartBlock[6]), 
 .TxStartBlock8(TxStartBlock[7]), 
 .TxStartBlock9(TxStartBlock[8]),
 .TxStartBlock10(TxStartBlock[9]), 
 .TxStartBlock11(TxStartBlock[10]),
 .TxStartBlock12(TxStartBlock[11]), 
 .TxStartBlock13(TxStartBlock[12]), 
 .TxStartBlock14(TxStartBlock[13]), 
 .TxStartBlock15(TxStartBlock[14]), 
 .TxStartBlock16(TxStartBlock[15]),
 .ReceiverpresetHintDSP(ReceiverpresetHintDSP), 
 .TransmitterPresetHintDSP(TransmitterPresetHintDSP),
 .ReceiverpresetHintUSP(ReceiverpresetHintUSP),
 .TransmitterPresetHintUSP(TransmitterPresetHintUSP),
 .LF_register(LF_register),
 .FS_register(FS_register),
 .CursorCoff_register(CursorCoff),
 .PreCursorCoff_register(PreCursorCoff),
 .PostCursorCoff_register(PostCursorCoff),
 .TrainToGen(trainToGen),
 .ReadDirectSpeedChange(directed_speed_change),
 .turnOff(disableScrambler),
 .RxStandby(RxStandby),
 .startSend16(startSend16),
 .turnOffScrambler_flag(turnOffScrambler_flag)
 );

assign phy_reset = lpreset;
assign Rate = PCLKRate+1;


endmodule




module pcieTB;
    parameter MAXPIPEWIDTH = 32;
	parameter DEVICETYPE = 0; //0 for downstream 1 for upstream
	parameter LANESNUMBER =16;
	parameter GEN1_PIPEWIDTH = 8 ;	
	parameter GEN2_PIPEWIDTH = 8 ;	
	parameter GEN3_PIPEWIDTH = 8 ;								
	parameter GEN4_PIPEWIDTH = 8 ;	
	parameter GEN5_PIPEWIDTH = 8 ;	
	parameter MAX_GEN = 1;
reg CLK;
reg reset;
//output phy_reset,
//PIPE interface width
//output [1:0] width, ///////////////////which module
//TX_signals
wire [1:0] width1;
wire [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData1;
wire [LANESNUMBER-1:0]TxDataValid1;
wire [LANESNUMBER-1:0]TxElecIdle1;
wire [LANESNUMBER-1:0]TxStartBlock1;
wire [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK1;
wire [2*LANESNUMBER -1:0]TxSyncHeader1;
wire [LANESNUMBER-1:0]TxDetectRx_Loopback1;
//RX_signals

wire [LANESNUMBER-1:0]RxDataValid1;////////////////////////////////////////

wire[LANESNUMBER-1:0]RxStartBlock1;
wire[2*LANESNUMBER -1:0]RxSyncHeader1;
wire[LANESNUMBER-1:0]RxValid1;
wire [15:0]RxStandby1;
reg	[3*LANESNUMBER -1:0]RxStatus1;
reg [15:0]RxElectricalIdle1;
//commands and status signals
wire [4*LANESNUMBER-1:0]PowerDown1;
wire  [3:0]Rate1;
reg [LANESNUMBER-1:0]PhyStatus1;

//pclkcontrolsignal
wire [4:0]PCLKRate1;
wire PclkChangeAck1;
reg  PclkChangeOk1;
//eq_signals
reg 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients1;
wire 	[18*LANESNUMBER -1:0]TxDeemph1;
reg 	[6*LANESNUMBER -1:0]LocalFS1;
reg 	[6*LANESNUMBER -1:0]LocalLF1;
wire 	[4*LANESNUMBER -1:0]LocalPresetIndex1;
wire 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients1;
reg 	[LANESNUMBER -1:0]LocalTxCoefficientsValid1;
wire 	[6*LANESNUMBER -1:0]LF1;
wire 	[6*LANESNUMBER -1:0]FS1;
wire 	[LANESNUMBER -1:0]RxEqEval1;
wire 	[LANESNUMBER -1:0]InvalidRequest1;
reg 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange1;
wire    pl_trdy1;
reg     lp_irdy1;
reg     [512-1:0]lp_data1;
reg     [64-1:0]lp_valid1;
wire [512-1:0]pl_data1;
wire [64-1:0] pl_valid1;
reg  [3:0]lp_state_req1;
wire [3:0]pl_state_sts1;
wire [2:0]pl_speedmode1;////////////////////////////////////////
reg lp_force_detect1;
////lPIF start & end of TLP DLLP
reg [64-1:0]lp_dlpstart1;
reg [64-1:0]lp_dlpend1;
reg  [64-1:0]lp_tlpstart1;
reg  [64-1:0]lp_tlpend1;
wire [64-1:0]pl_dlpstart1;
wire [64-1:0]pl_dlpend1;
wire [64-1:0]pl_tlpstart1;
wire [64-1:0]pl_tlpend1;
wire [64-1:0]pl_tlpedb1;
wire pl_linkUp1;
//optional Message bus
wire [7:0] M2P_MessageBus1;
reg  [7:0] P2M_MessageBus1;



wire [2:0] width2;
wire [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData2;
wire [LANESNUMBER-1:0]TxDataValid2;
wire [LANESNUMBER-1:0]TxElecIdle2;
wire [LANESNUMBER-1:0]TxStartBlock2;
wire [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK2;
wire [2*LANESNUMBER -1:0]TxSyncHeader2;
wire [LANESNUMBER-1:0]TxDetectRx_Loopback2;
//RX_signals

wire [LANESNUMBER-1:0]RxDataValid2;

wire[LANESNUMBER-1:0]RxStartBlock2;
wire[2*LANESNUMBER -1:0]RxSyncHeader2;
wire[LANESNUMBER-1:0]RxValid2;
wire [15:0]RxStandby2;
reg	[3*LANESNUMBER -1:0]RxStatus2;
reg [15:0]RxElectricalIdle2;
//commands and status signals
wire [4*LANESNUMBER-1:0]PowerDown2;
wire  [3:0]Rate2;
reg [LANESNUMBER-1:0]PhyStatus2;

//pclkcontrolsignal
wire [4:0]PCLKRate2;
wire PclkChangeAck2;
reg  PclkChangeOk2;
//eq_signals
reg 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients2;
wire 	[18*LANESNUMBER -1:0]TxDeemph2;
reg 	[6*LANESNUMBER -1:0]LocalFS2;
reg 	[6*LANESNUMBER -1:0]LocalLF2;
wire 	[4*LANESNUMBER -1:0]LocalPresetIndex2;
wire 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients2;
reg 	[LANESNUMBER -1:0]LocalTxCoefficientsValid2;
wire 	[6*LANESNUMBER -1:0]LF2;
wire 	[6*LANESNUMBER -1:0]FS2;
wire 	[LANESNUMBER -1:0]RxEqEval2;
wire 	[LANESNUMBER -1:0]InvalidRequest2;
reg 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange2;
wire    pl_trdy2;
reg     lp_irdy2;
reg     [512-1:0]lp_data2;
reg     [64-1:0]lp_valid2;
wire [512-1:0]pl_data2;
wire [64-1:0] pl_valid2;
reg  [3:0]lp_state_req2;
wire [3:0]pl_state_sts2;
wire [2:0]pl_speedmode2;
reg lp_force_detect2;
////lPIF start & end of TLP DLLP
reg [64-1:0]lp_dlpstart2;
reg [64-1:0]lp_dlpend2;
reg  [64-1:0]lp_tlpstart2;
reg  [64-1:0]lp_tlpend2;
wire [64-1:0]pl_dlpstart2;
wire [64-1:0]pl_dlpend2;
wire [64-1:0]pl_tlpstart2;
wire [64-1:0]pl_tlpend2;
wire [64-1:0]pl_tlpedb2;
wire pl_linkUp2;
//optional Message bus
wire [7:0] M2P_MessageBus2;
reg  [7:0] P2M_MessageBus2;




localparam[1:0]
        reset_   = 2'd0,
        active_  = 2'd1,
        retrain_ = 2'd2;
integer i;

initial
begin
    CLK = 0;
    reset = 0;
    #20
    reset = 1;
    #10
    lp_state_req1 = reset_;
    lp_state_req2 = reset_;
    #10
    wait(TxDetectRx_Loopback1);
    #10
    PhyStatus1={16{1'b1}};
    RxStatus1={16{3'b011}};
    PhyStatus2={16{1'b1}};
    RxStatus2={16{3'b011}};    
    #10
    RxStatus1=16'd0;
    RxStatus2=16'd0;
    lp_state_req1 = active_;
    lp_state_req2 = active_;    
    //wait(pl_state_sts == 3)
    //lp_state_req = retrain_;
	wait(pl_linkUp1 && pl_state_sts1==active_ && pl_linkUp2 && pl_state_sts2==active_);
	
	    
  /* wait(GetLocalPresetCoeffcients1 == {16{1'b1}} && GetLocalPresetCoeffcients2 == {16{1'b1}});
    LocalTxCoefficientsValid1 = {16{1'b1}};
    LocalTxPresetCoefficients1={16*18{1'b1}};
    LocalLF1={16*6{1'b1}};
    LocalFS1={16*6{1'b1}};
    LocalTxCoefficientsValid2 = {16{1'b1}};
    LocalTxPresetCoefficients2={16*18{1'b1}};
    LocalLF2={16*6{1'b1}};
    LocalFS2={16*6{1'b1}}; */


	@(negedge CLK);
	lp_irdy1=1;
	for (i=0;i<512;i=i+1) 
	begin
		lp_data1[i]=$random;
		lp_tlpstart1[i]=0;
		lp_tlpend1[i]=0;
		lp_dlpend1[i]=0;
		lp_dlpstart1[i]=0;
	end
	lp_valid1={2'b00, {62{1'b1}}};
	lp_data1[15:4] = 62;
	lp_tlpstart1[0]=1;
	lp_tlpend1[61]=1;
    // lp_dlpstart[0]=1;
    // lp_dlpend[5]=1;
	#10
	lp_irdy1=0;
	#75000
	$finish();
end
always #5 CLK = ~CLK;


PCIe #(
    .MAXPIPEWIDTH(32),
    .DEVICETYPE(0), // 0 for downstream, 1 for upstream
    .LANESNUMBER(16),
    .GEN1_PIPEWIDTH(32),
    .GEN2_PIPEWIDTH(32),
    .GEN3_PIPEWIDTH(32),
    .GEN4_PIPEWIDTH(32),
    .GEN5_PIPEWIDTH(32),
    .MAX_GEN(1)
) pcie_dut1 (
    // clk and reset
    .CLK(CLK),
    .lpreset(reset),
    .phy_reset(phy_reset),
    
    // PIPE interface width
    .width(width1),
    
    // TX signals
    .TxData(TxData1),
    .TxDataValid(TxDataValid1),
    .TxElecIdle(TxElecIdle1),
    .TxStartBlock(TxStartBlock1),
    .TxDataK(TxDataK1),
    .TxSyncHeader(TxSyncHeader1),
    .TxDetectRx_Loopback(TxDetectRx_Loopback1),
    
    // RX signals
    .RxData(TxData2),
    .RxDataValid(TxDataValid2),
    .RxDataK(TxDataK2),
    .RxStartBlock(TxStartBlock2),
    .RxSyncHeader(TxSyncHeader2),
    .RxStatus(RxStatus1),
    .RxElectricalIdle(RxElectricalIdle1),
    
    
    // Commands and status signals
    .PowerDown(PowerDown1),
    .Rate(Rate1),
    .PhyStatus(PhyStatus1),
    
    // PCLK control signal
    .PCLKRate(PCLKRate1),
    .PclkChangeAck(PclkChangeAck1),
    .PclkChangeOk(PclkChangeOk1),
    
    // EQ signals
    .LocalTxPresetCoefficients(LocalTxPresetCoefficients1),
    .TxDeemph(TxDeemph1),
    .LocalFS(LocalFS1),
    .LocalLF(LocalLF1),
    .LocalPresetIndex(LocalPresetIndex1),
    .GetLocalPresetCoeffcients(GetLocalPresetCoeffcients1),
    .LocalTxCoefficientsValid(LocalTxCoefficientsValid1),
    .LF(LF1),
    .FS(FS1),
    .RxEqEval(RxEqEval1),
    .InvalidRequest(InvalidRequest1),
    .LinkEvaluationFeedbackDirectionChange(LinkEvaluationFeedbackDirectionChange1),
    .pl_trdy(pl_trdy1),
    .lp_irdy(lp_irdy1),
    .lp_data(lp_data1),
    .lp_valid(lp_valid1),
    .pl_data(pl_data1),
    .pl_valid(pl_valid1),
    .lp_state_req(lp_state_req1),
    .pl_state_sts(pl_state_sts1),
    .pl_speedmode(pl_speedmode1),
    .lp_force_detect(lp_force_detect1),
    
    // LPIF start & end of TLP DLLP
    .lp_dlpstart(lp_dlpstart1),
    .lp_dlpend(lp_dlpend1),
    .lp_tlpstart(lp_tlpstart1),
    .lp_tlpend(lp_tlpend1),
    .pl_dlpstart(pl_dlpstart1),
    .pl_dlpend(pl_dlpend1),
    .pl_tlpstart(pl_tlpstart1),
    .pl_tlpend(pl_tlpend1),
    .pl_tlpedb(pl_tlpedb1),
    .pl_linkUp(pl_linkUp1),
    
    // Optional Message bus
    .M2P_MessageBus(M2P_MessageBus1),
    .P2M_MessageBus(P2M_MessageBus1),
    .RxStandby(RxStandby1)
);

PCIe #(
    .MAXPIPEWIDTH(32),
    .DEVICETYPE(1), // 0 for downstream, 1 for upstream
    .LANESNUMBER(16),
    .GEN1_PIPEWIDTH(32),
    .GEN2_PIPEWIDTH(32),
    .GEN3_PIPEWIDTH(32),
    .GEN4_PIPEWIDTH(32),
    .GEN5_PIPEWIDTH(32),
    .MAX_GEN(1)
) pcie_dut2 (
    // clk and reset
    .CLK(CLK),
    .lpreset(reset),
    .phy_reset(phy_reset),
    
    // PIPE interface width
    .width(width2),
    
    // TX signals
    .TxData(TxData2),
    .TxDataValid(TxDataValid2),
    .TxElecIdle(TxElecIdle2),
    .TxStartBlock(TxStartBlock2),
    .TxDataK(TxDataK2),
    .TxSyncHeader(TxSyncHeader2),
    .TxDetectRx_Loopback(TxDetectRx_Loopback2),
    
    // RX signals
    .RxData(TxData1),
    .RxDataValid(TxDataValid1),
    .RxDataK(TxDataK1),
    .RxStartBlock(TxStartBlock1),
    .RxSyncHeader(TxSyncHeader1),
    .RxStatus(RxStatus2),
    .RxElectricalIdle(RxElectricalIdle2),
    
    
    
    // Commands and status signals
    .PowerDown(PowerDown2),
    .Rate(Rate2),
    .PhyStatus(PhyStatus2),
    
    // PCLK control signal
    .PCLKRate(PCLKRate2),
    .PclkChangeAck(PclkChangeAck2),
    .PclkChangeOk(PclkChangeOk2),
    
    // EQ signals
    .LocalTxPresetCoefficients(LocalTxPresetCoefficients2),
    .TxDeemph(TxDeemph2),
    .LocalFS(LocalFS2),
    .LocalLF(LocalLF2),
    .LocalPresetIndex(LocalPresetIndex2),
    .GetLocalPresetCoeffcients(GetLocalPresetCoeffcients2),
    .LocalTxCoefficientsValid(LocalTxCoefficientsValid2),
    .LF(LF2),
    .FS(FS2),
    .RxEqEval(RxEqEval2),
    .InvalidRequest(InvalidRequest2),
    .LinkEvaluationFeedbackDirectionChange(LinkEvaluationFeedbackDirectionChange2),
    .pl_trdy(pl_trdy2),
    .lp_irdy(lp_irdy2),
    .lp_data(lp_data2),
    .lp_valid(lp_valid2),
    .pl_data(pl_data2),
    .pl_valid(pl_valid2),
    .lp_state_req(lp_state_req2),
    .pl_state_sts(pl_state_sts2),
    .pl_speedmode(pl_speedmode2),
    .lp_force_detect(lp_force_detect2),
    
    // LPIF start & end of TLP DLLP
    .lp_dlpstart(lp_dlpstart2),
    .lp_dlpend(lp_dlpend2),
    .lp_tlpstart(lp_tlpstart2),
    .lp_tlpend(lp_tlpend2),
    .pl_dlpstart(pl_dlpstart2),
    .pl_dlpend(pl_dlpend2),
    .pl_tlpstart(pl_tlpstart2),
    .pl_tlpend(pl_tlpend2),
    .pl_tlpedb(pl_tlpedb2),
    .pl_linkUp(pl_linkUp2),
    
    // Optional Message bus
    .M2P_MessageBus(M2P_MessageBus2),
    .P2M_MessageBus(P2M_MessageBus2),
    .RxStandby(RxStandby2)
);





endmodule
