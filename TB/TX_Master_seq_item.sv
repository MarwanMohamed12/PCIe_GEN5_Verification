class TX_Master_seq_item extends uvm_sequence_item;
`uvm_object_utils(TX_Master_seq_item)


bit  lp_irdy;    
bit[64-1:0] lp_dlpstart;
bit[64-1:0] lp_dlpend;
bit[64-1:0] lp_tlpstart;
bit[64-1:0] lp_tlpend;
rand bit[512-1:0] lp_data;
bit[64-1:0] lp_valid;




// ---------------//
rand bit [511:0] payload[];

bit [7:0] TLP[$]; 
bit [7:0] DLLP[$]; 

bit [1:0] packet_type;         // tlp 00
                               // DLLP 10
                               // invalid 11
rand bit [5:0] no_of_shift_start ;               
rand bit [5:0] no_of_shift_end ;            

rand bit [15:0] start_arr[4];
rand bit [15:0] end_arr[4];
rand bit [4:0] x [4];

rand bit [3:0] no_of_tlp,no_of_DLLP;
rand int tlp_size[] ;
rand int tlp_shift[],DLLP_shift[],TLP_DLLP_shift[] ;
// ---------------//

static int number_of_TLP_D,number_of_DLLP_D,number_of_TLP_U,number_of_DLLP_U;

// RX Related Signals // 
bit pl_trdy;
bit[64-1:0] pl_dlpstart;
bit[64-1:0] pl_dlpend;
bit[64-1:0] pl_tlpstart;
bit[64-1:0] pl_tlpend;
bit[64-1:0] pl_tlpedb;
bit[512-1:0] pl_data;
bit[64-1:0] pl_valid;


// ---------------//
constraint TLP_const {
    lp_dlpstart==0;
    lp_dlpend==0;
    no_of_DLLP==0;

    no_of_tlp inside {[1:4]};
    no_of_shift_start % 4 == 0 ;

    // max size 1024 dw and min size 3 to 4 


    // when randomize make higher distribution for low size data transfer
    
    payload.size() dist { [1:10] := 20, [11:65] := 80 };

    if(payload.size()>1){ 
        // to make only 1 bit is set in start and end  
        // if i want to send alot of TLP per transfer -> overwrite with in line constraint 

        no_of_shift_start dist {[50:63] := 70 ,[0:49] := 30 };
        lp_tlpstart == 1 << no_of_shift_start;

        no_of_shift_end dist {[50:63] := 70 ,[0:49] := 30 };
        lp_tlpend == 1 << no_of_shift_end;               
    }
    

    if(payload.size()==1){ 

        tlp_size.size() == no_of_tlp;
        tlp_shift.size() == no_of_tlp;

        foreach(tlp_size[i]){

            tlp_size[i] % 4 == 0 ;
            tlp_size[i] >= 16 ;
            tlp_size[i] <= (64 / no_of_tlp);
            tlp_shift[i] <= (64 / no_of_tlp) * (i+1);
            tlp_shift[i] >=(( 64 / ( no_of_DLLP + no_of_tlp ) ) * i ) + tlp_size[i] ;

            
        }
                      
    }
    
}



constraint DLLP_const {
    lp_tlpstart==0;
    lp_tlpend==0;
    no_of_tlp==0;
    //  size 2 dw 
    payload.size() ==1 ;
    
    no_of_DLLP inside {[1:4]};

 
    DLLP_shift.size() == no_of_DLLP;


        foreach(DLLP_shift[i]){

            DLLP_shift[i] <= (64 / no_of_DLLP) *(i+1);
            DLLP_shift[i] >= ( ( 64 / ( no_of_DLLP + no_of_tlp ) ) * i ) + 16 ;           

        }
     
}

constraint DLLP_TLP_const {
    payload.size() inside {[1:65]} ;

    no_of_DLLP + no_of_tlp inside {[1:4]};
    no_of_DLLP > 0;
    no_of_tlp  > 0;


    tlp_size.size() == no_of_tlp;

    TLP_DLLP_shift.size() == no_of_DLLP + no_of_tlp  ;


   if(payload.size()==1){ 


        foreach(tlp_size[i]){

            tlp_size[i] % 4 == 0 ;
            tlp_size[i] >= 16 ;
            tlp_size[i] <= (64 / (no_of_DLLP + no_of_tlp));

        }
        
        foreach(TLP_DLLP_shift[i]){

            if(i < no_of_tlp){
                            
                TLP_DLLP_shift[i] <= ( 64 / (no_of_DLLP+no_of_tlp) ) * (i+1);
                TLP_DLLP_shift[i] >= (( 64 / ( no_of_DLLP + no_of_tlp ) ) * i ) + tlp_size[i]  ;


            }
            if(i >= no_of_tlp){

                TLP_DLLP_shift[i] <= ( 64 / ( no_of_DLLP + no_of_tlp ) ) * (i+1) ;
                TLP_DLLP_shift[i] >= ( ( 64 / ( no_of_DLLP + no_of_tlp ) ) * i ) + 16 ; 

            }

        }

    }

     
}

function void post_randomize();
    lp_tlpend=0;
    lp_tlpstart=0;
    if(no_of_DLLP > 0 && no_of_tlp > 0 && payload.size()==1)begin
        lp_dlpstart=0;
        lp_dlpend=0;  
        lp_tlpend=0;
        lp_tlpstart=0;
        foreach(TLP_DLLP_shift[i])begin

            if(i < no_of_tlp )begin

                lp_tlpstart = lp_tlpstart ^ ( 1 << (    TLP_DLLP_shift[i]  - tlp_size[i] ) )  ;
                lp_tlpend   = lp_tlpend   ^ ( 1 << (    TLP_DLLP_shift[i] -1 ) ) ;

            end
            else if(i >= no_of_tlp)begin

                lp_dlpstart = lp_dlpstart ^ ( 1 << (  TLP_DLLP_shift[i] -16 ) )  ;
                lp_dlpend   = lp_dlpend   ^ ( 1 << (  TLP_DLLP_shift[i]-1 ) ) ;
            end


        end

        
    end
    else if(no_of_tlp > 0 && payload.size()==1 )begin
                foreach(tlp_size[i])begin

                    lp_tlpstart = lp_tlpstart ^ ( 1 << (    tlp_shift[i]  - tlp_size[i] ) )  ;
                    lp_tlpend   = lp_tlpend   ^ ( 1 << (   tlp_shift[i] -1 ) ) ;
                end

    end
    else if(no_of_DLLP > 0)begin
        lp_dlpstart=0;
        lp_dlpend=0;    
        foreach(DLLP_shift[i])begin


                    lp_dlpstart = lp_dlpstart ^ ( 1 << (  DLLP_shift[i] -16 ) )  ;
                    lp_dlpend   = lp_dlpend   ^ ( 1 << (  DLLP_shift[i]-1 ) ) ;

        end

    end


endfunction 


function new(string name = "TX_Master_seq_item");
    super.new(name);
endfunction



endclass