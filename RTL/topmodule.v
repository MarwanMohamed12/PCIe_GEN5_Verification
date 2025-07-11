module emadTB;


//rxltssm signals
reg clk;
reg reset;
reg [2047:0] orderedSets;
reg [4:0]numberOfDetectedLanes;
reg [4:0]substate;
reg [7:0]linkNumber;
reg forceDetect;
reg rxElectricalIdle;
reg validOrderedSets;
wire [7:0] rateid;
wire upConfigureCapability;
wire finish;
wire [3:0]exitTo;
//wire linkUp;
wire witeUpconfigureCapability;
wire writerateid;
wire disableDescrambler;

// os decoder signals
reg [511:0]data;
reg validFromLMC;





//input substates from main ltssm
    localparam [4:0]
	detectQuiet =  5'd0,
	detectActive = 5'd1,
	pollingActive= 5'd2,
	pollingConfiguration= 5'd3,
    	configurationLinkWidthStart = 5'd4,
    	configurationLinkWidthAccept = 5'd5,
    	configurationLanenumWait = 5'd6,
    	configurationLanenumAccept = 5'd7,
    	configurationComplete = 5'd8,
    	configurationIdle = 5'd9;


/******************************************/

osDecoder os(
clk,
3'b001,
reset,
numberOfDetectedLanes,
data,
validFromLMC,
linkUp,
validOrderedSets,
orderedSets);

 wire writeLinkNumber;
    wire lpifStatus;
    wire ReceiverpresetHintDSPout;
    wire TransmitterPresetHintDSPout;
    wire ReceiverpresetHintUSPout;
    wire TransmitterPresetHintUSPout;
    wire ReceiverpresetHintDSP;
    wire TransmitterPresetHintDSP;
    wire ReceiverpresetHintUSP;
    wire TransmitterPresetHintUSP;
    wire writeReceiverpresetHintDSP;
    wire writeTransmitterPresetHintDSP;
    wire writeReceiverpresetHintUSP;
    wire writeTransmitterPresetHintUSP;
    wire LFDSP;
    wire FSDSP;
    wire CursorCoff;
    wire PreCursorCoff;
    wire PostCursorCoff;

    // Instantiate the DUT (Device Under Test)
    RxLTSSM #(0) rxltssm (
        .clk(clk),
        .reset(reset),
        .orderedSets(orderedSets),
        .numberOfDetectedLanes(numberOfDetectedLanes),
        .substate(substate),
        .linkNumber(linkNumber),
        .Gen(3'b001),
        .rxElectricalIdle(rxElectricalIdle),
        .validOrderedSets(validOrderedSets),
        .rateId(rateid),
        .upConfigureCapability(upConfigureCapability),
        .finish(finish),
        .exitTo(exitTo),
        
        .witeUpconfigureCapability(witeUpconfigureCapability),
        .writerateid(writerateid),
        .writeLinkNumber(writeLinkNumber),
        .lpifStatus(lpifStatus),
        .ReceiverpresetHintDSPout(ReceiverpresetHintDSPout),
        .TransmitterPresetHintDSPout(TransmitterPresetHintDSPout),
        .ReceiverpresetHintUSPout(ReceiverpresetHintUSPout),
        .TransmitterPresetHintUSPout(TransmitterPresetHintUSPout),
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
        .PostCursorCoff(PostCursorCoff)
    );

initial
begin
clk = 0;
reset = 1;
#10
reset = 0;
#10
reset = 1;
#10
substate = detectQuiet; //DETECET ELEC IDLE EXIT FROM THE OTHER DEVICE OR 12MS TIMEOUT
#10
rxElectricalIdle = 1'b1;
#10
substate = detectActive; //RX DOESN'T DO ANY THING SO IT WILL FINISH IMMEDIATELY
#10
reset = 1;
#100
numberOfDetectedLanes = 5'd2;
substate = pollingActive;//8 CONSEC TS2 WITH LINK = PAD AND LANE = PAD
validFromLMC = 1'b1; 	      
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
data = 128'h252525252525AAAAAAAAF7F7F7F7BCBC;
#10
data= 128'h25252525252525252525252525252525;
#10
validFromLMC = 1'b0;
data = 512'b0;

#60001000
substate = pollingConfiguration;//8 CONSEC TS2 WITH LINK = PAD AND LANE = PAD
#10
validOrderedSets = 1'b1;
orderedSets[127:0] =   128'h2525252525252525252525AAAAF7F7F7;
orderedSets[255:128] = 128'h2525252525252525252525AAAAF7F7F7;
#120000200
substate = configurationLinkWidthStart;//2 CONSEC TS1 WITH LINK = LINK# AND LANE = PAD
#10
linkNumber = 8'hBB;
orderedSets[127:0] =   128'h2A2A2A2A2A2A2A2A2A2A2AAAAAF7BBF7;
orderedSets[255:128] = 128'h2A2A2A2A2A2A2A2A2A2A2AAAAAF7BBF7;
#10
orderedSets[127:0] =   128'h2A2A2A2A2A2A2A2A2A2A2AAAAA000000;
orderedSets[255:128] = 128'h2A2A2A2A2A2A2A2A2A2A2AAAAA000000;
#20
orderedSets[127:0] =   128'h2A2A2A2A2A2A2A2A2A2A2AAAAAF7BBF7;
orderedSets[255:128] = 128'h2A2A2A2A2A2A2A2A2A2A2AAAAAF7BBF7;
#60001000
substate = configurationLanenumWait;//2 CONSEC TS1 WITH LINK = LINK# AND LANE = LANE#
#10
orderedSets[127:0] =   128'h2A2A2A2A2A2A2A2A2A2A2AAAAA00BBF7;
orderedSets[255:128] = 128'h2A2A2A2A2A2A2A2A2A2A2AAAAA01BBF7;
#600010
substate = configurationLanenumAccept;//2 CONSEC TS1 WITH LINK = LINK# AND LANE = LANE#
#60001000
orderedSets[127:0] =   128'h2A2A2A2A2A2A2A2A2A2A2AAAAA00BBF7;
orderedSets[255:128] = 128'h2A2A2A2A2A2A2A2A2A2A2AAAAA01BBF7;
#50
substate = configurationComplete;//8 CONSEC TS2 WITH LINK = LINK# AND LANE = LANE#
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#10
orderedSets[127:0] =   128'h252525252525252525252AAAAA00BBF7;
orderedSets[255:128] = 128'h252525252525252525252AAAAA01BBF7;
#60001000
substate = configurationIdle;//8 CONSEC TS2 WITH LINK = LINK# AND LANE = LANE#
#10
orderedSets[127:0] =   128'h00;
orderedSets[255:128] = 128'h00;


end


always #5 clk = ~clk;
endmodule