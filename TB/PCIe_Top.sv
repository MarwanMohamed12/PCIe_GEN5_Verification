
`include "Defines.sv"
`include "LPIF_if.sv"
`include "PIPE_if.sv"

`timescale 1ps/1ps

module PCIe_Top ( );
                                 

   
	

                             
import PCIe_pkg::*;

import uvm_pkg::*;

bit CLK;
 




LPIF_if LPIF_if_U_h (.LCLK(CLK));

PIPE_if PIPE_if_U_h (.PCLK(CLK));

 
LPIF_if LPIF_if_D_h (.LCLK(CLK));

PIPE_if PIPE_if_D_h (.PCLK(CLK));


//////////////////////////////////////////////////////////////
/*********************PCIe DownStream************************/
//////////////////////////////////////////////////////////////

PCIe #(
    .MAXPIPEWIDTH(32),
    .DEVICETYPE(0), // 0 for downstream, 1 for upstream
    .LANESNUMBER(16),
    .GEN1_PIPEWIDTH(32),
    .GEN2_PIPEWIDTH(32),
    .GEN3_PIPEWIDTH(32),
    .GEN4_PIPEWIDTH(32),
    .GEN5_PIPEWIDTH(32),
    .MAX_GEN(5)
) PCIe_DownStream (
    // clk and reset
    .CLK(CLK),
    .lpreset(LPIF_if_D_h.lpreset),
    .phy_reset(PIPE_if_D_h.phy_reset),
    
    // PIPE interface width
    .width(PIPE_if_D_h.width),
    
    // TX signals
    .TxData(PIPE_if_D_h.TxData),
    .TxDataValid(PIPE_if_D_h.TxDataValid),
    .TxElecIdle(PIPE_if_D_h.TxElecIdle),
    .TxStartBlock(PIPE_if_D_h.TxStartBlock),
    .TxDataK(PIPE_if_D_h.TxDataK),
    .TxSyncHeader(PIPE_if_D_h.TxSyncHeader),
    .TxDetectRx_Loopback(PIPE_if_D_h.TxDetectRx_Loopback),
    
    // RX signals
    .RxData(PIPE_if_D_h.RxData),
    .RxDataValid(PIPE_if_D_h.RxDataValid),
    .RxDataK(PIPE_if_D_h.RxDataK),
    .RxStartBlock(PIPE_if_D_h.RxStartBlock),
    .RxSyncHeader(PIPE_if_D_h.RxSyncHeader),
    .RxStatus(PIPE_if_D_h.RxStatus),
    .RxElectricalIdle(PIPE_if_D_h.RxElecIdle),
    
    
    // Commands and status signals
    .PowerDown(PIPE_if_D_h.PowerDown),
    .Rate(PIPE_if_D_h.Rate),
    .PhyStatus(PIPE_if_D_h.PhyStatus),
    
    // PCLK control signal
    .PCLKRate(PIPE_if_D_h.PCLKRate),
    .PclkChangeAck(PIPE_if_D_h.PclkChangeAck),
    .PclkChangeOk(PIPE_if_D_h.PclkChangeOk),
    
    // EQ signals
    .LocalTxPresetCoefficients(PIPE_if_D_h.LocalTxPresetCoefficients),
    .TxDeemph(PIPE_if_D_h.TxDeemph),
    .LocalFS(PIPE_if_D_h.LocalFS),
    .LocalLF(PIPE_if_D_h.LocalLF),
    .LocalPresetIndex(PIPE_if_D_h.LocalPresetIndex),
    .GetLocalPresetCoeffcients(PIPE_if_D_h.GetLocalPresetCoeffcients),
    .LocalTxCoefficientsValid(PIPE_if_D_h.LocalTxCoefficientsValid),
    .LF(PIPE_if_D_h.LF),
    .FS(PIPE_if_D_h.FS),
    .RxEqEval(PIPE_if_D_h.RxEqEval),
    .InvalidRequest(PIPE_if_D_h.InvalidRequest),
    .LinkEvaluationFeedbackDirectionChange(PIPE_if_D_h.LinkEvaluationFeedbackDirectionChange),
    .pl_trdy(LPIF_if_D_h.pl_trdy),
    .lp_irdy(LPIF_if_D_h.lp_irdy),
    .lp_data(LPIF_if_D_h.lp_data),
    .lp_valid(LPIF_if_D_h.lp_valid),
    .pl_data(LPIF_if_D_h.pl_data),
    .pl_valid(LPIF_if_D_h.pl_valid),
    .lp_state_req(LPIF_if_D_h.lp_state_req),
    .pl_state_sts(LPIF_if_D_h.pl_state_sts),
    .pl_speedmode(LPIF_if_D_h.pl_speedmode),
    .lp_force_detect(LPIF_if_D_h.lp_force_detect),
    
    // LPIF start & end of TLP DLLP
    .lp_dlpstart(LPIF_if_D_h.lp_dlpstart),
    .lp_dlpend(LPIF_if_D_h.lp_dlpend),
    .lp_tlpstart(LPIF_if_D_h.lp_tlpstart),
    .lp_tlpend(LPIF_if_D_h.lp_tlpend),
    .pl_dlpstart(LPIF_if_D_h.pl_dlpstart),
    .pl_dlpend(LPIF_if_D_h.pl_dlpend),
    .pl_tlpstart(LPIF_if_D_h.pl_tlpstart),
    .pl_tlpend(LPIF_if_D_h.pl_tlpend),
    .pl_tlpedb(LPIF_if_D_h.pl_tlpedb),
    .pl_linkUp(LPIF_if_D_h.pl_linkUp),
    
    // Optional Message bus
    .M2P_MessageBus(PIPE_if_D_h.M2P_MessageBus),
    .P2M_MessageBus(PIPE_if_D_h.P2M_MessageBus),
    .RxStandby(PIPE_if_D_h.RxStandby)
);



//////////////////////////////////////////////////////////////
/*********************PCIe UpStream************************/
//////////////////////////////////////////////////////////////


PCIe #(
    .MAXPIPEWIDTH(32),
    .DEVICETYPE(1), // 0 for downstream, 1 for upstream
    .LANESNUMBER(16),
    .GEN1_PIPEWIDTH(32),
    .GEN2_PIPEWIDTH(32),
    .GEN3_PIPEWIDTH(32),
    .GEN4_PIPEWIDTH(32),
    .GEN5_PIPEWIDTH(32),
    .MAX_GEN(5)
) PCIe_UpStream (
    // clk and reset
    .CLK(CLK),
    .lpreset(LPIF_if_U_h.lpreset),
    .phy_reset(PIPE_if_U_h.phy_reset),
    
    // PIPE interface width
    .width(width),
    
    // TX signals
    .TxData(PIPE_if_U_h.TxData),
    .TxDataValid(PIPE_if_U_h.TxDataValid),
    .TxElecIdle(PIPE_if_U_h.TxElecIdle),
    .TxStartBlock(PIPE_if_U_h.TxStartBlock),
    .TxDataK(PIPE_if_U_h.TxDataK),
    .TxSyncHeader(PIPE_if_U_h.TxSyncHeader),
    .TxDetectRx_Loopback(PIPE_if_U_h.TxDetectRx_Loopback),
    
    // RX signals
    .RxData(PIPE_if_U_h.RxData),
    .RxDataValid(PIPE_if_U_h.RxDataValid),
    .RxDataK(PIPE_if_U_h.RxDataK),
    .RxStartBlock(PIPE_if_U_h.RxStartBlock),
    .RxSyncHeader(PIPE_if_U_h.RxSyncHeader),
    .RxStatus(PIPE_if_U_h.RxStatus),
    .RxElectricalIdle(PIPE_if_U_h.RxElecIdle),
    
    // Commands and status signals
    .PowerDown(PIPE_if_U_h.PowerDown),
    .Rate(PIPE_if_U_h.Rate),
    .PhyStatus(PIPE_if_U_h.PhyStatus),
    
    // PCLK control signal
    .PCLKRate(PIPE_if_U_h.PCLKRate),
    .PclkChangeAck(PIPE_if_U_h.PclkChangeAck),
    .PclkChangeOk(PIPE_if_U_h.PclkChangeOk),
    
    // EQ signals
    .LocalTxPresetCoefficients(PIPE_if_U_h.LocalTxPresetCoefficients),
    .TxDeemph(PIPE_if_U_h.TxDeemph),
    .LocalFS(PIPE_if_U_h.LocalFS),
    .LocalLF(PIPE_if_U_h.LocalLF),
    .LocalPresetIndex(PIPE_if_U_h.LocalPresetIndex),
    .GetLocalPresetCoeffcients(PIPE_if_U_h.GetLocalPresetCoeffcients),
    .LocalTxCoefficientsValid(PIPE_if_U_h.LocalTxCoefficientsValid),
    .LF(PIPE_if_U_h.LF),
    .FS(PIPE_if_U_h.FS),
    .RxEqEval(PIPE_if_U_h.RxEqEval),
    .InvalidRequest(PIPE_if_U_h.InvalidRequest),
    .LinkEvaluationFeedbackDirectionChange(PIPE_if_U_h.LinkEvaluationFeedbackDirectionChange),
    .pl_trdy(LPIF_if_U_h.pl_trdy),
    .lp_irdy(LPIF_if_U_h.lp_irdy),
    .lp_data(LPIF_if_U_h.lp_data),
    .lp_valid(LPIF_if_U_h.lp_valid),
    .pl_data(LPIF_if_U_h.pl_data),
    .pl_valid(LPIF_if_U_h.pl_valid),
    .lp_state_req(LPIF_if_U_h.lp_state_req),
    .pl_state_sts(LPIF_if_U_h.pl_state_sts),
    .pl_speedmode(LPIF_if_U_h.pl_speedmode),
    .lp_force_detect(LPIF_if_U_h.lp_force_detect),
    
    // LPIF start & end of TLP DLLP
    .lp_dlpstart(LPIF_if_U_h.lp_dlpstart),
    .lp_dlpend(LPIF_if_U_h.lp_dlpend),
    .lp_tlpstart(LPIF_if_U_h.lp_tlpstart),
    .lp_tlpend(LPIF_if_U_h.lp_tlpend),
    .pl_dlpstart(LPIF_if_U_h.pl_dlpstart),
    .pl_dlpend(LPIF_if_U_h.pl_dlpend),
    .pl_tlpstart(LPIF_if_U_h.pl_tlpstart),
    .pl_tlpend(LPIF_if_U_h.pl_tlpend),
    .pl_tlpedb(LPIF_if_U_h.pl_tlpedb),
    .pl_linkUp(LPIF_if_U_h.pl_linkUp),
    
    // Optional Message bus
    .M2P_MessageBus(PIPE_if_U_h.M2P_MessageBus),
    .P2M_MessageBus(PIPE_if_U_h.P2M_MessageBus),
    .RxStandby(PIPE_if_U_h.RxStandby)
);









initial begin 


 
  forever begin 

            if(PIPE_if_D_h.PCLKRate == 4)begin
                  #500 CLK = ~CLK;

            end
            else begin
                  #8000 CLK = ~CLK;

            end
          end


end







initial begin 


  uvm_config_db #(virtual PIPE_if)::set(null,"*","PIPE_if_U_h",PIPE_if_U_h);
  uvm_config_db #(virtual LPIF_if)::set(null,"*","LPIF_if_U_h",LPIF_if_U_h);
 

  uvm_config_db #(virtual PIPE_if)::set(null,"*","PIPE_if_D_h",PIPE_if_D_h);
  uvm_config_db #(virtual LPIF_if)::set(null,"*","LPIF_if_D_h",LPIF_if_D_h);
 
  
  run_test("PCIe_Test");
  

end







/*initial begin 


  #900000000

  $finish();


end*/








                                 
endmodule 
