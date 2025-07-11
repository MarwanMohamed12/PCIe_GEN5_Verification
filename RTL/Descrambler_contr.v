 module Descrambler_contr (input OS_detection,clk,reset,input[2:0]GEN,input[5:0]PIPEWIDTH,output reg pass_it );
 
 
  reg[3:0] count;
 
always@(posedge clk or negedge reset) begin
 if(GEN == 1 || GEN == 2) begin
   if (!reset) begin
            count<=0;
            pass_it <= 0;            
   end
 
   else begin
   
    if(OS_detection == 1) begin
         count<= count+1;
         pass_it <= 1;
       end
       
    else if ((count< 32/PIPEWIDTH *4 -1)&&  count!=0 )
          count<= count+1;
    
    else begin
           pass_it <= 0;
           count<=0;
         end
  
    end

  end
  
end

endmodule
