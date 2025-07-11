interface PIPE_if #(parameter MAXPIPEWIDTH = 32,
                    parameter LANESNUMBER = 16 )
                 
                 (  
                   input bit PCLK
                 );




/////TX Related Signals\\\\\
logic [MAXPIPEWIDTH*LANESNUMBER-1:0] TxData;
logic [LANESNUMBER-1:0] TxDataValid;
logic [LANESNUMBER-1:0] TxElecIdle;
logic [LANESNUMBER-1:0] TxStartBlock;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] TxDataK;
logic [2*LANESNUMBER -1:0] TxSyncHeader;
logic [LANESNUMBER-1:0] TxDetectRx_Loopback;



/////RX Related Signals\\\\\
logic [MAXPIPEWIDTH*LANESNUMBER-1:0] RxData;
logic [LANESNUMBER-1:0] RxDataValid;
logic [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0] RxDataK;
logic [LANESNUMBER-1:0] RxStartBlock;
logic [2*LANESNUMBER -1:0] RxSyncHeader;
logic [3*LANESNUMBER -1:0] RxStatus;
logic [LANESNUMBER-1:0] RxElecIdle;



/////LTSSM Related Signals\\\\\
logic phy_reset;
logic [1:0] width;
logic [4*LANESNUMBER-1:0] PowerDown;
logic [3:0] Rate;
logic [LANESNUMBER-1:0] PhyStatus;
logic [4:0] PCLKRate;
logic PclkChangeAck;
logic PclkChangeOk;
logic [18*LANESNUMBER -1:0] LocalTxPresetCoefficients;
logic [18*LANESNUMBER -1:0] TxDeemph;
logic [6*LANESNUMBER -1:0] LocalFS;
logic [6*LANESNUMBER -1:0] LocalLF;
logic [4*LANESNUMBER -1:0] LocalPresetIndex;
logic [LANESNUMBER -1:0] GetLocalPresetCoeffcients;
logic [LANESNUMBER -1:0] LocalTxCoefficientsValid;
logic [6*LANESNUMBER -1:0] LF;
logic [6*LANESNUMBER -1:0] FS;
logic [LANESNUMBER -1:0] RxEqEval;
logic [LANESNUMBER -1:0] InvalidRequest;
logic [6*LANESNUMBER -1:0] LinkEvaluationFeedbackDirectionChange;
logic [7:0] M2P_MessageBus;
logic [7:0] P2M_MessageBus;
logic [15:0] RxStandby;


logic assertion_enable ;


property PHY_Reset;
  
  @(posedge PCLK) (phy_reset) |-> ##[1:$] (Rate==4'b0001 && PCLKRate==0 && RxElecIdle[0]==1);
  
endproperty

  


property Power_Down;
  
  @(posedge PCLK) (phy_reset) |-> ##[1:$] PowerDown[3:0]==4'b0010;
  
endproperty


property Power_Up;
  
  @(posedge PCLK) (TxDetectRx_Loopback[0] && PhyStatus[0]) |-> ##[1:$] PowerDown[3:0]==4'b0000;
  
endproperty





property Tx_RX_DataK_property;
  @(posedge PCLK)
  disable iff(!assertion_enable)
  (Rate > 2) |-> ((TxDataK == 0) && (RxDataK == 0));
endproperty


property Tx_RX_SyncHeader_property;
  @(posedge PCLK)
   disable iff(!assertion_enable)
  (Rate < 2) |-> ((TxSyncHeader == 0) && (RxSyncHeader == 0));
endproperty



property Tx_StartBlock_property;
  @(posedge PCLK)
   disable iff( ( (!assertion_enable) || (Rate < 2)  || ( LANESNUMBER != 16 )  || ( MAXPIPEWIDTH != 32 ) )  )
   (TxStartBlock > 0) |=> (TxStartBlock == 0) ;
endproperty

property Rx_StartBlock_property;
  @(posedge PCLK)
   disable iff( ( (!assertion_enable) || (Rate < 2)  || ( LANESNUMBER != 16 )  || ( MAXPIPEWIDTH != 32 ) )  )
   (RxStartBlock > 0) |=> (RxStartBlock == 0) ;
endproperty


property TxElecIdle_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   ( $rose(TxElecIdle) || $fell(TxElecIdle) ) |-> ( TxElecIdle == TxDataValid ) ;
endproperty

property RxStatus_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   (RxStatus == {LANESNUMBER{3'b011}}) |-> ##[1:4] ( TxDetectRx_Loopback > 0 ) ;
endproperty



// there is no Reset# input in signals to check deassertion 

/*property PhyStatus_reset_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   () |-> ##[1:4] ( TxDetectRx_Loopback > 0 ) ;
endproperty*/


property PhyStatus_RxDetection_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   ( $rose(TxDetectRx_Loopback[0]) ) |->  (PhyStatus == TxDetectRx_Loopback)   ##1  ( PhyStatus == 0 )  ;
endproperty

property PhyStatus_RateChange_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   ( ( Rate > 1 ) && ( $past(Rate) == 1 ))  |-> ( PhyStatus == 16'hFFFF )   ##1  ( PhyStatus == 0 )  ;
endproperty


property PclkChangeAck_assert_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
   (   ( ( Rate > 1  ) && ( $past(Rate) == 1 )  )  || ( ( PCLKRate > 1  ) && ( $past(PCLKRate) == 1 ) )) |-> ( PclkChangeAck  )  ;
endproperty


property PclkChangeAck_deassert_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
    $fell(PclkChangeOk ) |-> ( ! PclkChangeAck  )  ;
endproperty


property GetLocalPresetCoeffcients_property;
  @(posedge PCLK)
   disable iff( !assertion_enable)
    $rose( GetLocalPresetCoeffcients[0] ) |=> (  GetLocalPresetCoeffcients == 0  )  ;
endproperty









///------------------------check -------------------------------///
Tx_RX_DataK_check: assert property (Tx_RX_DataK_property)
  else $info("DataK violation: Rate = %0d, TxDataK = %0d, RxDataK = %0d",
             $sampled(Rate), $sampled(TxDataK), $sampled(RxDataK));


Tx_RX_SyncHeader_check: assert property (Tx_RX_SyncHeader_property)
  else $info("SyncHeader violation: Rate = %0d, TxSyncHeader = %0d, RxSyncHeader = %0d",
             $sampled(Rate), $sampled(TxSyncHeader), $sampled(RxSyncHeader));


Tx_StartBlock_check: assert property (Tx_StartBlock_property)
  else $info("Tx StartBlock violation: Rate = %0d, TxStartBlock = %0d",
             $sampled(Rate), $sampled(TxStartBlock));


Rx_StartBlock_check: assert property (Rx_StartBlock_property)
  else $info("Rx StartBlock violation: Rate = %0d, RxStartBlock = %0d",
             $sampled(Rate), $sampled(RxStartBlock));

TxElecIdle_check: assert property (TxElecIdle_property)
  else $info("TxElecIdle violation: TxElecIdle = %0d, TxDataValid = %0d",
             $sampled(TxElecIdle), $sampled(TxDataValid));


RxStatus_check: assert property (RxStatus_property)
  else $info("Rx status violation: RxStatus = %0d, TxDetectRx_Loopback = %0d",
             $sampled(RxStatus), $sampled(TxDetectRx_Loopback));

PhyStatus_RxDetection_check: assert property (PhyStatus_RxDetection_property)
  else $info("******************Phy status violation: PhyStatus = %0d, TxDetectRx_Loopback = %0d",
             $sampled(PhyStatus), $sampled(TxDetectRx_Loopback));

PhyStatus_RateChange_check: assert property (PhyStatus_RateChange_property)
  else $info("Phy status violation: PhyStatus = %0d, Rate = %0d",
             $sampled(PhyStatus), $sampled(Rate));

PclkChangeAck_assert_check: assert property (PclkChangeAck_assert_property)
  else $info("PclkAck violation: PCLKRate = %0d, Rate = %0d ,PclkChangeAck =%0d ",
             $sampled(PCLKRate), $sampled(Rate) ,$sampled(PclkChangeAck));

PclkChangeAck_deassert_check: assert property (PclkChangeAck_deassert_property)
  else $info("PclkAck violation: PclkChangeOk = %0d, PclkChangeAck = %0d",
             $sampled(PclkChangeOk), $sampled(PclkChangeAck));


GetLocalPresetCoeffcients_check: assert property (GetLocalPresetCoeffcients_property)
  else $info("GetLocalPresetCoeffcients violation: GetLocalPresetCoeffcients = %0d",
             $sampled(GetLocalPresetCoeffcients));


///-------------------------------------------------------------------------///


///---------cover properties --------///


Tx_RX_DataK_cover                :cover property( Tx_RX_DataK_property);
Tx_RX_SyncHeader_cover           :cover property(Tx_RX_SyncHeader_property);
Tx_StartBlock_cover              :cover property(Tx_StartBlock_property);
Rx_StartBlock_cover              :cover property(Rx_StartBlock_property);
ElecIdle_check_cover             :cover property(TxElecIdle_property);
RxStatus_cover                   :cover property(RxStatus_property);
PhyStatus_RxDetection_cover      :cover property(PhyStatus_RxDetection_property);
PhyStatus_RateChange_cover       :cover property(PhyStatus_RateChange_property);
PclkChangeAck_assert_cover       :cover property(PclkChangeAck_assert_property);
PclkChangeAck_deassert_cover     :cover property(PclkChangeAck_deassert_property);
GetLocalPresetCoeffcients_cover  :cover property(GetLocalPresetCoeffcients_property);

PHY_Reset_cover                  :cover property (PHY_Reset);
Power_Down_cover                 :cover property (Power_Down);
Power_Up_cover                   :cover property (Power_Up);


///-------------------------------------------------------------------------///

endinterface


