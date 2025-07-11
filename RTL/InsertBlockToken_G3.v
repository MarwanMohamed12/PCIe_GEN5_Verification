

  module InsertBlockToken_G3 #
(
parameter MAXPIPEWIDTH =32,
parameter LANESNUMBER = 16,
parameter GEN1_PIPEWIDTH = 8 ,	
parameter GEN2_PIPEWIDTH = 32 ,	
parameter GEN3_PIPEWIDTH = 16 ,	
parameter GEN4_PIPEWIDTH = 8 ,	
parameter GEN5_PIPEWIDTH = 8 	
)
(clk,ResetN,DataIn,ValidIn,TLPStart,DLLPStart,PEnd,Gen,length,Hold,Empty,ReadEn,DataOut,ValidOut,DKOut);
input clk;
input ResetN;
input [511:0] DataIn;
input [63:0] ValidIn;
input [63:0] TLPStart;
input [63:0] DLLPStart;
input [63:0] PEnd;
input [2:0] Gen;
input[79:0] length;
input Hold;
input Empty;
//input stop_DS;
output reg ReadEn;
output reg[511:0]DataOut;
output reg [63:0]ValidOut;
output reg [63:0] DKOut;
////GEN3
reg done = 0 ;
reg[511:0]DataOut_reg;
reg [63:0]ValidOut_reg;
reg[63:0]TLPStart_reg;
reg[63:0]DLLPStart_reg;
reg [63:0]PEnd_reg;
reg [63:0]ValidIn_reg;
reg [255:0]Valid_reg;
reg [255:0]Valid_comb;
reg[511:0]DataIn_reg;
reg [15:0]SDP;
reg [31:0]STP1;
reg [31:0]STP2;
reg [31:0]STP3;
reg [31:0]STP4;
reg [31:0]STP5;
reg [31:0]STP6;
reg [31:0]STP7;
reg [31:0]STP8;
reg [31:0]STP9;
reg [31:0]STP10;
reg [31:0]STP11;
reg [31:0]STP12;
reg [31:0]STP13;
reg [31:0]STP14;
reg [31:0]STP15;
reg [31:0]STP16;
reg [5:0]pipe;
reg [4:0]lanes;
reg [2047:0] out_comb;
reg [2047:0] out_reg;
reg [4:0]TLP_count;
reg start;
reg write_data;
reg read_data_reg;
reg read_data_comb;
reg finish;
reg flag_reg;
reg flag_comb;
reg [1023:0] temp_data;
reg [127:0] temp_valid;
//////////////GEN1
reg [7:0] count;
reg [MAXPIPEWIDTH/8*LANESNUMBER-1:0]DK;
wire[MAXPIPEWIDTH/8*LANESNUMBER-1:0]flag1;
reg [MAXPIPEWIDTH*LANESNUMBER-1:0] flag2; 
reg [MAXPIPEWIDTH*LANESNUMBER-1:0]   ShiftLeftVaLueData;
reg [MAXPIPEWIDTH/8*LANESNUMBER-1:0] ShiftLeftValueValid;
reg [2:0] width;
reg [MAXPIPEWIDTH*LANESNUMBER-1:0]   out_data_mask;
reg [MAXPIPEWIDTH/8*LANESNUMBER-1:0] out_valid_mask;
reg NoMoreData;
reg finishprocessing;
reg read_new;
reg [512+16*8-1:0] data_reg;

reg [64+16-1:0] STB_reg;
reg [64+16-1:0] SDB_reg;
reg [64+16-1:0] END_reg;
reg [64+16-1:0] valid_reg;
reg [MAXPIPEWIDTH*LANESNUMBER-1:0] data_temp;
reg [MAXPIPEWIDTH/8*LANESNUMBER-1:0] valid_temp;
reg [MAXPIPEWIDTH/8*LANESNUMBER-1:0] DK_temp;
reg [7:0] count_temp;
reg ConFlag ;
parameter STB=8'hFB,
			 SDB=8'h5C,
			 END_t=8'hFD;
//////////////////////////////////////
always @ (posedge clk)
begin 
	if(~ResetN) begin width <= 0; end
	else begin
		if (Gen == 1)begin  
			case(GEN1_PIPEWIDTH)
			8:width<=0;
			16:width<=1;
			32:width<=2;
			endcase
		end
		/*else if (Gen == 2)begin  
			case(GEN2_PIPEWIDTH)
			8:width<=0;
			16:width<=1;
			32:width<=2;
			endcase
		end
		else if (Gen == 3)begin  
			case(GEN3_PIPEWIDTH)
			8:width<=0;
			16:width<=1;
			32:width<=2;
			endcase
		end
		else if (Gen == 4)begin  
			case(GEN4_PIPEWIDTH)
			8:width<=0;
			16:width<=1;
			32:width<=2;
			endcase
		end*/
		else if (Gen == 5)begin  
			case(GEN5_PIPEWIDTH)
			8:width<=0;
			16:width<=1;
			32:width<=2;
			endcase
		end
		
	end
end 
always @ *
begin
out_data_mask<=0;
		out_valid_mask<=0;
		case(width)
			0: //8 bit
			begin 
				out_data_mask[LANESNUMBER*8-1:0]<={LANESNUMBER{8'hFF}};
				out_valid_mask [LANESNUMBER-1:0]<={LANESNUMBER{1'b1}};
				ShiftLeftVaLueData<=LANESNUMBER << 3; //multiply by 8 is the same as shift left by 3
				ShiftLeftValueValid<=LANESNUMBER<<0;
			end
			/*1:
			begin
				out_data_mask[LANESNUMBER*16-1:0]<={LANESNUMBER{16'hFFFF}};
				out_valid_mask [LANESNUMBER*2-1:0]<={LANESNUMBER{2'b11}};
				ShiftLeftVaLueData<=LANESNUMBER << 4; //multiply by 16 is the same as shift left by 4
				ShiftLeftValueValid<=LANESNUMBER<<1;
			end*/
			2:
			begin
				out_data_mask[LANESNUMBER*32-1:0]<={LANESNUMBER{32'hFFFF_FFFF}};
				out_valid_mask [LANESNUMBER*4-1:0]<={LANESNUMBER{4'b1111}};
				ShiftLeftVaLueData<=LANESNUMBER << 5; //multiply by 32 is the same as shift left by 4
				ShiftLeftValueValid<=LANESNUMBER<<2;
			end
		endcase
end 
assign flag1 = valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0];

integer i;
integer j;
integer x,y,z;
always @ *
begin
if(finishprocessing && |valid_reg)
begin
 for(i=0 ; i<80 ; i=i+1)
begin
   j=i*8;
	if(!valid_reg[i]) data_reg[j+:8]<=8'h00;
end
end
if(valid_reg[79]) count<=80;

	for(x = 2 ; x >= 80 ; x = x +1)begin
		if (valid_reg[80-x]) count<= 80-x+1;
	end

end

always @(negedge clk)begin
 if(ResetN==0)begin
   TLPStart_reg<=0;
   out_reg<=0;
   DataIn_reg<=0;
   DLLPStart_reg <=0;
   ValidIn_reg<=0;
   Valid_reg<=0;
   STP1<=0;
   STP2<=0;
   STP3<=0;
   STP4<=0;
   STP5<=0;
   STP6<=0;
   STP7<=0;
   STP8<=0;
   STP9<=0;
   STP10<=0;
   STP11<=0;
   STP12<=0;
   STP13<=0;
   STP14<=0;
   STP15<=0;
   STP16<=0;
   SDP<=0;
   start<=0;
   read_data_reg<=0;
   finish <=1;	
   lanes<=LANESNUMBER;
   ReadEn<=0;
   DataOut_reg<=0;
   ValidOut_reg<=0;
   flag_reg<=0;
   temp_data<=0;
   temp_valid<=0;
   /////GEN1
   data_reg<=0;
   STB_reg<=0;
   SDB_reg<=0;
   END_reg<=0;
   DK<=0;
   valid_reg<=0;
  NoMoreData<=1;
  finishprocessing<=0;
   end  
  else begin
	 if(Gen==3'b101)
   			 pipe<=GEN5_PIPEWIDTH;
  write_data<=0;
  ReadEn<=0;
  DataOut_reg<=0;
  ValidOut_reg<=0;
  read_data_reg<=read_data_comb;
  Valid_reg<=Valid_comb;
  out_reg<=out_comb;
  flag_reg<=flag_comb;
  done <=0;
  if((~Hold && ~Empty && finish) || (~Hold && ~Empty && NoMoreData))begin
   ReadEn<=1;
   start<=1;
   finish<=0;
   finishprocessing <=0;
   NoMoreData<=0;
   end
   else if (Gen==3'b001)begin
   if(valid_reg[0]&&(STB_reg[0]||SDB_reg[0]||END_reg[0]))
		begin
			done <= 1;
			if(STB_reg[0])
			begin
				data_reg<={data_reg[632-1:0],STB};
				STB_reg <={STB_reg[80-1-1:1],2'b00};
				SDB_reg <={SDB_reg[80-1-1:0],1'b0};
				END_reg <={END_reg[80-1-1:0],1'b0};
				valid_reg<={valid_reg[80-1-1:0],1'b1};
				DK<={DK[80-1-1:0],1'b1};
			end
			else if(SDB_reg[0])
			begin
				data_reg<={data_reg[632-1:0],SDB};
				SDB_reg <={SDB_reg[80-1-1:1],2'b00};
				STB_reg <={STB_reg[80-1-1:0],1'b0};
				END_reg <={END_reg[80-1-1:0],1'b0};
				valid_reg<={valid_reg[80-1-1:0],1'b1};
				DK<={DK[80-1-1:0],1'b1};
			end
			else if(END_reg[0])
			begin 
				data_reg<={data_reg[632-1:8],END_t,data_reg[7:0]};
				STB_reg <={STB_reg[80-1-1:1],1'b0,STB_reg[0:0]};
				SDB_reg <={SDB_reg[80-1-1:1],1'b0,SDB_reg[0:0]};
				END_reg <={END_reg[80-1-1:1],2'b00};
				valid_reg<={valid_reg[80-1-1:1],1'b1,valid_reg[0:0]};
				DK={DK[80-1-1:1],1'b1,DK[0:0]};
			end
		end
			for(i = 1 ; i<= 77 ; i=i+1)begin
				if(valid_reg[i]&&(STB_reg[i]||SDB_reg[i]||END_reg[i]) && !done) 
					begin
						done <=1; 
						if (STB_reg[i]) begin
							data_reg[8*i +: 8] <= STB;
							STB_reg[i] <= 0;
							STB_reg[i-1] <= 0;
							SDB_reg[i] <= 0;
							END_reg[i] <= 0;
							valid_reg[i] <= 1;
							DK[i] <= 1;
						end
						else if (SDB_reg[i]) begin
							data_reg[8*i +: 8] <= SDB;

							SDB_reg[i] <= 0;
							SDB_reg[i+1] <= 0;

							STB_reg[i] <= 0;
							END_reg[i] <= 0;

							valid_reg[i] <= 1;
							DK[i] <= 1;
						end

						else if (END_reg[i]) begin
						data_reg[8*(i+1) +: 8] <= END_t;

						STB_reg[i+1] <= 0;
						SDB_reg[i+1] <= 0;

						END_reg[i] <= 0;
						END_reg[i+1] <= 0;

						valid_reg[i+1] <= 1;
						DK[i+1] <= 1;
						end

				end 

			end
		end

	if( (~|SDB_reg && ~|SDB_reg && ~|END_reg)&& |valid_reg) begin finishprocessing <=1; end
   end
   
   if (start)begin
	 TLPStart_reg <= TLPStart;
	 DLLPStart_reg <= DLLPStart;
	 PEnd_reg<=PEnd;
	 DataIn_reg <= DataIn;
	 ValidIn_reg<=ValidIn;
	 STP1<={23'b0,length[4:0],4'b1111};
	 STP2<={23'b0,length[9:5],4'b1111};
	 STP3<={23'b0,length[14:10],4'b1111};
	 STP4<={23'b0,length[19:15],4'b1111};
	 STP5<={23'b0,length[24:20],4'b1111};
	 STP6<={23'b0,length[29:25],4'b1111};
	 STP7<={23'b0,length[34:30],4'b1111};
	 STP8<={23'b0,length[39:35],4'b1111};
	 STP9<={23'b0,length[44:40],4'b1111};
	 STP10<={23'b0,length[49:45],4'b1111};
	 STP11<={23'b0,length[54:50],4'b1111};
	 STP12<={23'b0,length[59:55],4'b1111};
	 STP13<={23'b0,length[64:60],4'b1111};
	 STP14<={23'b0,length[69:65],4'b1111};
	 STP15<={23'b0,length[74:70],4'b1111};
	 STP16<={23'b0,length[79:75],4'b1111};
	 SDP <= 16'b1010110011110000;
	 start<=0;
	 write_data<=1;
	 end
	 if (read_data_reg)begin

	  ////////////// 32 bit pipewidth
	  
	  if (pipe==6'b100000)begin

		   if(lanes==5'b10000)begin
				if(Valid_reg[63:0]==64'hffffffffffffffff || Empty==1)begin
					ValidOut_reg<=Valid_reg[63:0];
					Valid_reg <= Valid_reg >> 64;
					DataOut_reg<= out_reg[511:0];
					out_reg<= out_reg >> 512;
				end
				else begin
					if (Valid_reg[63:0]!=0 && Valid_reg[63:0]!=64'hffffffffffffffff&& Empty==0) begin
					flag_reg <= 1;
					temp_data<=out_reg[511:0];
					temp_valid<=Valid_reg[63:0];
					Valid_reg <= Valid_reg >> 64;
					out_reg<= out_reg >> 512;
					end
					read_data_reg<=0;
					finish<=1;
				end
		  end
		 end
		end
     end

  always@(posedge clk) begin
   if (Gen >= 3'b011) begin
    DataOut<=DataOut_reg;
	ValidOut<=ValidOut_reg;
	DKOut<=64'b0;
    end
  else if (Gen < 3'b011) begin
    DataOut<=0;
ValidOut<=0;
if(~Hold && finishprocessing && |valid_reg )
	begin
		flag2<=0;
		if (ConFlag)
		begin
				if(((flag1 & (out_valid_mask >>count_temp))==(out_valid_mask >>count_temp) )|| Empty)
				begin 
					ValidOut<=valid_temp|((valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & (out_valid_mask >>count_temp)) << count_temp );
					DataOut <= data_temp |((data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0] & (out_data_mask >>(count_temp<<3))) << (count_temp<<3) ); 
					DKOut<=DK_temp|((DK[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & (out_valid_mask >>count_temp)) << count_temp );
					data_reg <=data_reg>>(ShiftLeftVaLueData-(count_temp<<3));
					valid_reg<=valid_reg>>(ShiftLeftValueValid-count_temp);
					DK<=DK>>(ShiftLeftValueValid-count_temp);
					ConFlag<=0; 
				end
				else 
				begin
					valid_temp<=valid_temp|((valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & (out_valid_mask >>count_temp)) << count_temp );
					data_temp <= data_temp |((data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0] & (out_data_mask >>(count_temp<<3))) <<(count_temp<<3) ); 
					DK_temp<=DK_temp|((DK[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & (out_valid_mask >>count_temp)) << count_temp );
					count_temp<=count_temp + count;
					ConFlag<=1;
					data_reg <=0;
					valid_reg<=0;
					DK<=0;
					NoMoreData<=1;
				end
		end
		else if( (flag1&out_valid_mask) == out_valid_mask)//there is enough data to send now
		begin
			flag2<=data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0] & out_data_mask;
			DataOut <=data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0] & out_data_mask;
			ValidOut<=valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & out_valid_mask;
			DKOut<=DK[MAXPIPEWIDTH/8*LANESNUMBER-1:0] & out_valid_mask;
			data_reg <=data_reg>>ShiftLeftVaLueData;
			valid_reg<=valid_reg>>ShiftLeftValueValid;
			DK<=DK>>ShiftLeftValueValid;
			
		end
		else if (|(flag1&out_valid_mask) & ~Empty)
		begin
			data_temp <=data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0];
			valid_temp<=valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0];
			DK_temp<=DK[MAXPIPEWIDTH/8*LANESNUMBER-1:0]; 
			count_temp<=count;
			ConFlag<=1;
			data_reg <=0;
			valid_reg<=0;
			DK<=0;
			NoMoreData<=1;
		end
		
		
		else
		begin
		   DataOut <=data_reg[MAXPIPEWIDTH*LANESNUMBER-1:0] ;
			ValidOut<=valid_reg[MAXPIPEWIDTH/8*LANESNUMBER-1:0] ;
			DKOut<=DK[MAXPIPEWIDTH/8*LANESNUMBER-1:0];
			data_reg <=0;
			valid_reg<=0;
			DK<=0;
		end
	end
  end
end
 always@(*)begin
  TLP_count=0;
  if (length[4:0]!=5'b0)
   TLP_count=TLP_count+1;
  if (length[9:5]!=5'b0)
   TLP_count=TLP_count+1;
  if (length[14:10]!=5'b0)
   TLP_count=TLP_count+1;
  if (length[19:15]!=5'b0)
   TLP_count=TLP_count+1;

  out_comb=out_reg;
  read_data_comb=read_data_reg;
  Valid_comb=Valid_reg;
  flag_comb=flag_reg;
  if (write_data)begin
      data_reg[640-1:512] = {128{1'b0}};
     data_reg[512-1:0] = DataIn_reg;

    STB_reg[80-1:64] = {16{1'b0}};
    STB_reg[64-1:0] = TLPStart_reg;

  SDB_reg[80-1:64] = {16{1'b0}};
  SDB_reg[64-1:0] = DLLPStart_reg;

 END_reg[80-1:64] = {16{1'b0}};
 END_reg[64-1:0]= PEnd_reg;

  valid_reg[80-1:64]= {16{1'b0}};
  valid_reg[64-1:0]= ValidIn_reg;

 DK=0;

	for(i = 63 ; i >= 0 ; i = i - 1) begin
	if (ValidIn_reg[i] == 1) begin	
		if (TLPStart_reg[i]) begin	
			/*if (TLP_count == 5'b10000) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP16};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01111) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP15};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01110) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP14};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01101) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP13};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01100) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP12};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01011) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP11};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01010) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP10};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01001) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP9};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b01000) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP8};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00111) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP7};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00110) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP6};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00101) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP5};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	*/
			if (TLP_count == 5'b00100) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP4};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00011) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP3};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00010) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP2};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end else if (TLP_count == 5'b00001) begin	
				out_comb = out_comb << 40;	
				out_comb[39:0] = {DataIn_reg[8*i +: 8], STP1};	
				Valid_comb = Valid_comb << 5;	
				Valid_comb[4:0] = 5'b11111;	
				TLP_count = TLP_count - 1;	
			end	
		end else if (DLLPStart_reg[i]) begin	
			out_comb = out_comb << 24;
			out_comb[23:0] = {DataIn_reg[8*i +: 8], SDP};	
			Valid_comb = Valid_comb << 3;	
			Valid_comb[2:0] = 3'b111;	
		end else begin	
			out_comb = out_comb << 8;	
			out_comb[7:0] = DataIn_reg[8*i +: 8];	
			Valid_comb = Valid_comb << 1;	
			Valid_comb[0] = 1'b1;	
		end
	end else begin	
		out_comb = out_comb << 8;	
		out_comb[7:0] = 0;	
		Valid_comb = Valid_comb << 1;	
		Valid_comb[0] = 1'b0;	
	end
end


		read_data_comb=1;
		if (flag_comb)begin

		for (x = 0; x <= 127; x = x + 1) begin
			if (temp_valid[127 - x]) begin
				Valid_comb = Valid_comb << 1;
				Valid_comb[0] = 1'b1;
				out_comb = out_comb << 8;
				out_comb[7:0] = temp_data[((127 - x) * 8) +: 8];
			end
		end

          flag_comb=0;		  
	    end
	  end 
	end
  endmodule
   
   
 
 
 
 
 
 
 
 
 
 
 
