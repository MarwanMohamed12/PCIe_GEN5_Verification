module  masterRxLTSSM #(parameter MAXLANES = 16 , DEVICETYPE = 0,
    parameter GEN1_PIPEWIDTH = 8, parameter GEN2_PIPEWIDTH = 8, parameter GEN3_PIPEWIDTH = 8,
    parameter GEN4_PIPEWIDTH = 8,parameter GEN5_PIPEWIDTH = 8)
 (
    input clk,
    input [4:0]numberOfDetectedLanes,
    input [4:0]substate,
    input [15:0]countersComparators,
    input rxElectricalIdle,
    input timeOut,
    input reset,
    input [15:0]RcvrCfgToidle,
    input [2:0] trainToGen,
    input [15:0]detailedRecoverySubstates,
    input [2:0] gen,
    output reg finish,
    output reg [4:0]exitTo,
    output reg [15:0]resetOsCheckers,
    output [3:0]lpifStatus,
    output reg [2:0]timeToWait,
    output reg enableTimer,
    output reg startTimer,
    output reg resetTimer,
    output reg[4:0]comparatorsCount,
    input PAD_TS);
    
    reg[4:0] lastState,lastState_next;
    reg[1:0] currentState,nextState;
    reg[15:0]comparatorsCondition;


//timer parameters
parameter t0ms = 3'd0,t12ms= 3'd1,t24ms = 3'd2,t48ms = 3'd3,t2ms = 3'd4,t8ms = 3'd5,t1ms=3'd6;
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
        configurationIdle = 5'd9,
        L0 = 5'd10,
        recoveryRcvrLock = 5'd11,
        recoveryRcvrCfg = 5'd12,
        recoverySpeed = 5'd13,
        phase0 = 5'd14,
        phase1 = 5'd15,
        phase2 = 5'd16,
        phase3 =5'd17,
        recoveryIdle = 5'd18,
        recoverySpeedeieos = 5'd19,
        recoverywait = 5'd20;

    

//local states
    localparam [1:0]
    start = 2'b00,
    counting = 2'b01,
    success = 2'b10,
    failed = 2'b11;

    //CURRENT STATE FF
    always @(posedge clk or negedge reset)
    begin
        if(!reset)
        begin
            currentState <= start;
	        finish <= 1'b0;
		    lastState<=4'hF;
            lastState_next<=4'hF;
            finish<= 0;
            exitTo<= 0;
            resetOsCheckers<= 0;
            
            timeToWait<= 0;
            enableTimer<= 0;
            startTimer<= 0;
            resetTimer<= 0;
            nextState<=0;
            comparatorsCondition<= 0;
            comparatorsCount<=0;

		    //forcedetectflag<=1'b0;
        end
        else
        begin
            currentState <= nextState;

            if( !(( substate == 1 ) && ( lastState == 1 )))
                lastState<=lastState_next;
        end    


        if((substate ==1 )&& (lastState ==1 ))
                lastState<=0;
    
    end

    always @(*)
    begin
        case(currentState)
        start:
        begin

            
          if(substate != lastState) //ensure that this is a new request
            begin
            lastState_next = substate;
            resetOsCheckers = {16{1'b1}};
            if(substate == detectQuiet)
            begin
                comparatorsCount = 5'd0;
                timeToWait = t0ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		 
            end
            else if(substate == detectActive)
            begin
                comparatorsCount = 5'd0;
                timeToWait = t0ms; 
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end
            //---marwan-----/
            else if(substate==configurationComplete)
            begin
                comparatorsCount = 5'd8;
                timeToWait = t2ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end
            //---marwan-----/
            else if(substate==pollingActive)
            begin
                comparatorsCount = 5'd8;
                timeToWait = t24ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end
            else if (substate==configurationLinkWidthStart||substate==configurationLinkWidthAccept||
                    substate==configurationLanenumAccept||substate==phase0||substate==phase1||substate==phase2||substate==phase3)
            begin
              if(DEVICETYPE == 0 && substate==phase1)
                comparatorsCount = 5'd0;                
              else
                comparatorsCount = 5'd2;
                
                //------------marwan-----------//
                if((substate==phase1) || ( substate==phase0))begin
                    timeToWait = t12ms;// for now
                    nextState = counting;
                    startTimer = 1'b1;
                    enableTimer = 1'b1;

                end
                else if(substate==configurationLinkWidthStart )begin
                    timeToWait = t24ms;
                    nextState = counting;
                    startTimer = 1'b1;
                    enableTimer = 1'b1;
                    comparatorsCount = 5'd1;

                end 
                else if(substate==configurationLinkWidthAccept && DEVICETYPE)begin
                    timeToWait = t2ms;
                    nextState = counting;
                    startTimer = 1'b1;
                    enableTimer = 1'b1;
                    comparatorsCount = 5'd1;

                end 
                else if(substate==configurationLinkWidthAccept &&  !DEVICETYPE)begin
                    timeToWait = t2ms;
                    nextState = counting;
                    startTimer = 1'b1;
                    enableTimer = 1'b1;
                    comparatorsCount = 5'd1;

                end
                else begin
                    timeToWait = t24ms;
                    nextState = counting;
                    startTimer = 1'b1;
                    enableTimer = 1'b1;


                end
                //------------marwan-----------//

		                
            end
            else if (substate==configurationLanenumWait)
            begin
                comparatorsCount=5'd2;
                timeToWait = t2ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end
            else if (substate==pollingConfiguration||substate==recoveryRcvrCfg)
            begin
                comparatorsCount=5'd8;
                timeToWait = t48ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end //----marwan-----//
            else if (substate==recoveryRcvrLock)begin
                comparatorsCount=5'd8;
                timeToWait = t24ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;


            end//----marwan-----//
 	    else if (substate==configurationIdle || substate==recoveryIdle)
            begin
                if(gen == 3'd1)     comparatorsCount = 64/GEN1_PIPEWIDTH;
                else if(gen == 3'd5)comparatorsCount = 64/GEN5_PIPEWIDTH;
                timeToWait = t2ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
		
            end

        else if ((substate == L0 && DEVICETYPE) || substate==recoverySpeed || substate==recoverySpeedeieos) 
            begin
                comparatorsCount=5'd1;
                timeToWait = t48ms;
                nextState = counting;
                startTimer = 1'b1;
                enableTimer = 1'b1;
			end
		
       end
        
       else 
        begin
            comparatorsCount=5'd0;
            timeToWait = t0ms;
            enableTimer = 1'b0;
            startTimer = 1'b0;
            resetTimer = 1'b0;
            resetOsCheckers = 16'b0;
            nextState = start;
        end

    end
        
         
    counting:
    begin
        enableTimer = 1'b1;
        resetTimer  = 1'b1;
        resetOsCheckers = {16{1'b1}};
        startTimer = 1'b0;
	    finish = 1'b0;
      //  timeOut=0;
        if((!timeOut && (countersComparators >= comparatorsCondition)) || (substate == detectQuiet && rxElectricalIdle) || (substate == detectQuiet && timeOut)|| (substate == detectActive && timeOut)
       || (substate == pollingActive && /*marwan*/(countersComparators >= comparatorsCondition) ) || (substate == pollingConfiguration &&  /*marwan*/(countersComparators >= comparatorsCondition) )|| (substate == configurationLinkWidthStart &&/*marwan*/ (countersComparators >= comparatorsCondition))
       || (substate == configurationLinkWidthAccept && (countersComparators >= comparatorsCondition) ) || (substate == configurationComplete && (countersComparators >= comparatorsCondition))|| (substate == configurationLanenumAccept && timeOut) || (substate == configurationLanenumWait && (countersComparators >= comparatorsCondition))|| (substate == configurationIdle && (countersComparators >= comparatorsCondition)) ||(substate==recoverySpeed && (countersComparators >= comparatorsCondition))
       || (substate == recoveryIdle && (countersComparators >= comparatorsCondition) ))
        begin
            //**marwan**//
            if((substate==recoverySpeed && countersComparators >= comparatorsCondition) || substate==recoverySpeedeieos )begin

                nextState = success;

            end
            else if( ( ( (substate == configurationLanenumAccept) ||(substate == configurationLanenumWait) ) && (PAD_TS == 1) ))begin

                nextState = failed;
                enableTimer = 1'b0;
                resetTimer  = 1'b0;
                startTimer = 1'b0;

            end
            else begin
                enableTimer = 1'b0;
                resetTimer  = 1'b0;
                startTimer = 1'b0;
                nextState = success;

            end


            //**marwan**//

  
                 
        end
        else if(timeOut)
            begin
            nextState = failed;
            end	
        else nextState = counting;
    end
    success:
    begin
        if(RcvrCfgToidle[0])exitTo = recoveryIdle;
        else if(substate == phase1 && detailedRecoverySubstates[0])exitTo = recoveryRcvrLock;
        else if(substate == recoveryIdle)exitTo = L0;
        else if(substate==recoverySpeed)exitTo = recoverywait;
        else if(substate==recoverySpeedeieos && trainToGen<3'd3)exitTo=recoveryRcvrLock;
        else if(substate==recoverySpeedeieos && trainToGen>=3'd3)exitTo=phase0;
        else exitTo = substate+1'b1;

        //*************marwan********************//
        if(substate==recoverySpeed || substate==recoverySpeedeieos )begin

            resetOsCheckers = 16'b0;
            //enableTimer = 1'b0;
            //resetTimer = 1'b0;
            startTimer = 0 ;
            finish = 1'b1;
            nextState = start;

        end 
       /* else if( ( ( (substate == configurationLanenumAccept) ||(substate == configurationLanenumWait) ) && (PAD_TS == 1) ))begin

                nextState = failed;
                enableTimer = 1'b0;
                resetTimer  = 1'b0;
                startTimer = 1'b0;

        end*/
        else begin
            resetOsCheckers = 16'b0;
            enableTimer = 1'b0;
            resetTimer = 1'b0;
            finish = 1'b1;
            nextState = start;
        end

        //****************marwan**********//


    end
    failed:
    begin
        //lastState_next = substate;
        resetOsCheckers = 16'b0;
        enableTimer = 1'b0;
        resetTimer = 1'b0;
        finish = 1'b1;
        //-------------marwan------------//
        if((substate == phase1  ) || (substate == phase0  ))begin

            exitTo = recoverySpeed;
        end
        else begin

            exitTo = detectQuiet;
            

        end
        //-------------marwan------------//
        nextState = start;
    end
    default:
    begin
        nextState = start;
        enableTimer = 1'b0;
        resetTimer = 1'b0;
        resetOsCheckers = 16'b0;
    end
    


    endcase
    end
    


always@(*)
begin
    if(numberOfDetectedLanes==5'd1)       comparatorsCondition = 16'd1;
    else if(numberOfDetectedLanes == 5'd2)comparatorsCondition = {{14{1'b0}},{2{1'b1}}};
    else if(numberOfDetectedLanes == 5'd4)comparatorsCondition = {{12{1'b0}},{4{1'b1}}};
    else if(numberOfDetectedLanes == 5'd8)comparatorsCondition = {{8{1'b0}},{8{1'b1}}};
    else if(numberOfDetectedLanes == 5'd16)comparatorsCondition= {16{1'b1}};
    else comparatorsCondition = 16'd0;
end

endmodule