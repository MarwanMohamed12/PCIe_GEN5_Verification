class LPIF_seq_item extends uvm_sequence_item;
`uvm_object_utils(LPIF_seq_item)


bit  lp_irdy;    
bit[64-1:0] lp_dlpstart;
bit[64-1:0] lp_dlpend;
bit[64-1:0] lp_tlpstart;
bit[64-1:0] lp_tlpend;
rand bit[512-1:0] lp_data;
bit[64-1:0] lp_valid;

bit lpreset; 
bit[3:0] lp_state_req;
bit[3:0] pl_state_sts;
bit[2:0] pl_speedmode;
bit lp_force_detect;
bit pl_linkUp;

bit packets_trans;



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
int Packet_Size;
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

bit[1:0] operation;

static bit set_reset ;

// ---------------//
constraint TLP_const {
    no_of_DLLP==0;
    no_of_tlp inside {[1:4]};
    
    no_of_tlp dist { 1:=40 ,2:=20,3:=20 ,4:=20 };
    
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
            tlp_shift[i] >=(( 64 / (no_of_tlp ) ) * i ) + tlp_size[i] ;

            
        }

 
                      
    }
    
}



constraint DLLP_const {
    lp_tlpstart==0;
    lp_tlpend==0;
    no_of_tlp==0;
    //  size 2 dw 
    payload.size() ==1 ;
    
    no_of_DLLP inside {[1:10]};

 
    DLLP_shift.size() == no_of_DLLP;


        foreach(DLLP_shift[i]){

            DLLP_shift[i] <= (60 / no_of_DLLP) *(i+1);
            DLLP_shift[i] >= ( ( 60 / ( no_of_DLLP ) ) * i ) + 6 ;           

        }
     
}

constraint DLLP_TLP_const {
    payload.size() inside {[1:65]} ;

    no_of_tlp inside {[1:3]};
    
    no_of_tlp dist { 1:=60 ,2:=20,3:=20};

    no_of_DLLP > 0;
    no_of_tlp  > 0;

        


    tlp_size.size() == no_of_tlp;



   if(payload.size()==1){ 

        tlp_size.sum() < 58 ;
        foreach(tlp_size[i]){

            tlp_size[i] % 4 == 0 ;
            tlp_size[i] >= 16 ;
            tlp_size[i] <= (64 / no_of_DLLP  );

        }

        no_of_DLLP < ((64 - tlp_size.sum()) / 6);

 
     
    
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


                    lp_dlpstart = lp_dlpstart ^ ( 1 << (  DLLP_shift[i] -6 ) )  ;
                    lp_dlpend   = lp_dlpend   ^ ( 1 << (  DLLP_shift[i]-1 ) ) ;

        end

    end


endfunction 


function new(string name = "LPIF_seq_item");
    super.new(name);
endfunction



endclass