

`ifndef MAXPIPEWIDTH
   `define MAXPIPEWIDTH 32
`endif

`ifndef LANESNUMBER
   `define LANESNUMBER 16
`endif



`define TS1      1
`define TS2      2
`define IDLE     3
`define EIOS     4
`define EIEOS    5 
`define SKP      6
`define SDS      7


`define TLP 0
`define DLLP 2

`define TLP_MIN_SIZE 16
`define TLP_MAX_SIZE 64   // size in Bytes  (supported in design) (it should be 4096 bytes as per specs.)


`define Detect_Quiet  0
`define Detect_Active  1
`define Polling_Active 2
`define Polling_Configuration 3
`define Config_Link_Width_Start 4
`define Config_Link_Width_Accept 5
`define Config_Lanenum_Wait 6
`define Config_Lanenum_Accept 7
`define Config_Complete 8    
`define Config_Idle 9
`define L0 10
`define Recovery_RcvrLock 11
`define Recovery_RcvrCfg 12
`define Recovery_Equalization 13
`define Phase0 14
`define Phase1 15
`define Recovery_Speed 16
`define Recovery_Idle 17


`define Current_GEN  5

`define MAX_GEN_PCIE_D 5
`define MAX_GEN_PCIE_U 5 

`define GEN1  1
`define GEN2  2
`define GEN3  3
`define GEN4  4
`define GEN5  5


`define DW  32


`define Time_between_sequence 	4000000
