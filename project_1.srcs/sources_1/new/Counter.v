`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2020 12:09:50 AM
// Design Name: 
// Module Name: Counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//100Hz Clock Divider
module divide(
    input clock,
    output clk_out
);
    reg elapsed;
    reg[27:0]state;
    
    always @ (posedge clock)
        if(state == 1000000) state<=0;
        else state<=state+1;
    always @ (state)
        if (state == 1000000) elapsed = 1;
        else elapsed = 0;
    assign clk_out = elapsed;
endmodule

//1 Hz Clock Divider
module timer(
 input clock,
    output clk_out
);
    reg elapsed;
    reg[27:0]state;
    
    always @ (posedge clock)
        if(state == 100000000) state<=0;
        else state<=state+1;
    always @ (state)
        if (state == 100000000) elapsed = 1;
        else elapsed = 0;
    assign clk_out = elapsed;
endmodule


//Synconize Basys3 VGA controller
module vga_sync
	(
		input wire clk, reset,
		output wire hsync, vsync, video_on, p_tick,
		output wire [9:0] x, y
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  10; // vertical top border
	localparam V_B_BORDER      =  33; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
    localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	
	// mod-2 counter to generate 25 MHz pixel tick
	reg [1:0] pixel_reg;
	wire [1:0] pixel_next;
	wire pixel_tick;
	
	always @(posedge clk, posedge reset)
		if(reset)
		  pixel_reg <= 0;
		else
		  pixel_reg <= pixel_next;
	
	assign pixel_next = pixel_reg + 1; // increment pixel_reg 
	
	assign pixel_tick = (pixel_reg == 0); // assert tick 1/4 of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
 
	// infer registers
	always @(posedge clk, posedge reset)
		if(reset)
			begin
           		v_count_reg <= 0;
            		h_count_reg <= 0;
            		vsync_reg   <= 0;
            		hsync_reg   <= 0;
			end
		else
			begin
            		v_count_reg <= v_count_next;
            		h_count_reg <= h_count_next;
            		vsync_reg   <= vsync_next;
            		hsync_reg   <= hsync_next;
			end
			
	// next-state logic of horizontal vertical sync counters
	always @*
		begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			       : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
		end
		
   // hsync and vsync are active low signals
   // hsync signal asserted during horizontal retrace
   assign hsync_next = h_count_reg >= START_H_RETRACE && h_count_reg <= END_H_RETRACE;
   
   // vsync signal asserted during vertical retrace
   assign vsync_next = v_count_reg >= START_V_RETRACE && v_count_reg <= END_V_RETRACE;

   // video only on when pixels are in both horizontal and vertical display region
   assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);

   // output signals
   assign hsync  = hsync_reg;
   assign vsync  = vsync_reg;
   assign x      = h_count_reg;
   assign y      = v_count_reg;
   assign p_tick = pixel_tick;
endmodule



//Counter for bcdTo7seg
module refreshcounter (
    input clock,
    output reg [16:0] refreshcount
);
    initial
        refreshcount = 0;
    always @ (posedge clock)
        begin
            refreshcount <= refreshcount + 1;
        end
endmodule


//Binary Coded decimal to 7 segment LED
module bcdto7seg(
    input[3:0]led,
    output reg[6:0]seg
  );
    always @(led)
    case (led)
    4'b0000 :    
    seg = 7'b1000000;
    4'b0001 :    		
    seg = 7'b1111001 ;
    4'b0010 :  		
    seg = 7'b0100100 ; 
    4'b0011 : 		
    seg = 7'b0110000 ;
    4'b0100 :		
    seg = 7'b0011001 ;
    4'b0101 :		
    seg = 7'b0010010 ;  
    4'b0110 :		
    seg = 7'b0000010 ;
    4'b0111 :		
    seg = 7'b1111000;
    4'b1000 :     		
    seg = 7'b0000000;
    4'b1001 :    		
    seg = 7'b0010000 ;
    default : seg = 7'b0000000;
endcase 
endmodule


//Counter for fourteen bit input from switch
module Counter(
    input clk_in, 
    input [15:0]sw,
    output reg [13:0]fourteen_bit_input,
    output reg [15:0]led
    );
    
     always @(posedge clk_in)begin
        fourteen_bit_input[13:0] = sw;
        led = sw;
        end
endmodule

//Select position for 7Seg LED
module Positionselector (
    input [16:0] refreshcount,
    input [3:0] led1, led2,led3,led4,
    output reg [3:0] led, an
);
    always @ (refreshcount or led1 or led2 or led3 or led4)
        begin
            case (refreshcount[16:15])
                2'b00: 
                    begin
                        an = 4'b1110;
                        led = led1;
                    end
                2'b01: 
                    begin
                        an = 4'b1101;
                        led = led2;
                    end
                2'b10: 
                    begin
                        an = 4'b1011;
                        led = led3;
                    end
                2'b11: 
                    begin
                        an = 4'b0111;
                        led = led4;
                    end
            endcase
       end
endmodule


//Binary number to Binary coded Decimal
module binary_to_BCD(
    input clock,
    input [13:0] fourteen_bit_value,
    output reg [3:0] ones = 0,
    output reg [3:0] tens = 0,
    output reg [3:0] hundreds = 0,
    output reg [3:0] thousands = 0
);
reg[3:0] i = 0;
reg[29:0] shift = 0;
reg[3:0] temp_thousands = 0;
reg[3:0] temp_hundreds = 0;
reg[3:0] temp_tens = 0;
reg[3:0] temp_ones = 0;
reg[13:0] LAST_fourteen_bit_value = 0;

always @ (posedge clock)
begin
    if( i==0 & (LAST_fourteen_bit_value != fourteen_bit_value)) begin
        shift = 30'd0;
    
    LAST_fourteen_bit_value = fourteen_bit_value;
    
    shift[13:0] = fourteen_bit_value;
    temp_thousands = shift[29:26];
    temp_hundreds = shift[25:22];
    temp_tens = shift[21:18];
    temp_ones = shift[17:14];
    
    shift = shift << 1;
    i = i+1;    
    end
    
    if(i<14 & i>0) begin
        if(temp_thousands >= 5) temp_thousands = temp_thousands + 3;
        if(temp_hundreds >= 5) temp_hundreds = temp_hundreds + 3;
        if(temp_tens >= 5) temp_tens = temp_tens + 3;
        if(temp_ones >= 5) temp_ones = temp_ones + 3;
        
        shift [29:14] = {temp_thousands,temp_hundreds,temp_tens,temp_ones};
        
        shift = shift << 1;
        
        temp_thousands = shift[29:26];
        temp_hundreds = shift[25:22];
        temp_tens = shift[21:18];
        temp_ones = shift[17:14];
        i = i+1;
    end
    if(i == 14)begin
        i<=0;
        thousands = temp_thousands;
        hundreds = temp_hundreds;
        tens = temp_tens;
        ones = temp_ones;
    end
end
endmodule

//Random Number Generator
module RNG(
    input clk ,
    output reg [13:0]rng
);
    always @ (posedge clk)
        begin
            rng = rng + 1;
        end
endmodule

//Game Controller
module gamecontrol (
    input clk ,
    input btnC,
    input [13:0]rng,
    input timer,
    input [13:0]fourteen_bit_input,
    output reg [13:0] score = 0,
    output reg [13:0] numOne = 0,
    output reg [13:0] numTwo = 0,
    output reg [13:0] numThree = 0,
    output reg [4:0]count1 = 15,
    output reg [4:0]count2 = 15,
    output reg [4:0]count3 = 15,
    output reg gameState = 0
);
    reg [0:0]buttonOld;
    reg [13:0]difficult = 3;
    reg [7:0]i = 0;
    


    always @ (posedge clk)
    begin           
            if(i == 100)
            begin
            if( count1 > 0  && gameState == 1)
                count1 = count1 - 1;
        
            if( count2 > 0  && gameState == 1)
                count2 = count2 - 1;
            
            if( count3 > 0  && gameState == 1)
                count3 = count3 - 1;   
            
                i = 0;
            end
            
            if( buttonOld != btnC && btnC == 1'b1 && gameState == 1)
            begin
                if(numOne == fourteen_bit_input) begin
                      difficult = difficult + 1;
                      numOne = rng%difficult + 1; 
                      count1 = 15;     
                      score = score + 1;          
                      end
                 
                 if(numTwo == fourteen_bit_input) begin
                      difficult = difficult + 1;
                      numTwo = rng%difficult + 2; 
                      count2 = 15;   
                      score = score + 1;              
                      end      
                 
                if(numThree == fourteen_bit_input) begin
                      difficult = difficult + 1;
                      numThree = rng%difficult + 3; 
                      count3 = 15;        
                      score = score + 1;          
                      end   
                      
            
            end 


            else if( buttonOld != btnC && btnC == 1'b1 && gameState == 0)
            begin
                      difficult = 3;
                      numOne    = 1;
                      numTwo    = 2;
                      numThree  = 3;
                      gameState = 1;   
                      count1 = 15;     
                      count2 = 15;
                      count3 = 15;    
                      score  = 0;
            end
            
            if((count1 == 0 || count2 == 0 || count3 == 0) && gameState == 1)
            begin 
                      gameState = 0;
            end
        buttonOld <= btnC;

        i = i+1;
    end

endmodule

//Display Number on Screen (Based on wolf)
module wolf_display
	(	
	    input wire clk, reset,   // clock, reset signal inputs for synchronous roms and registers
	    input wire [3:0] bcd3, bcd2, bcd1, bcd0, // current score routed in from eggs module
	    input wire [9:0] x, y,   // vga x/y pixel location
	    input wire [9:0] addX , addY,
	    output reg score_on      // output asserted when x/y are within score location in display
        );	
   // *** on screen score display ***
	
	// row and column regs to index numbers_rom
	reg [7:0] row;
	reg [3:0] col;
	
	// output from numbers_rom
	wire color_data;
	
	// infer number bitmap rom
	numbers_rom numbers_rom_unit(.clk(clk), .row(row), .col(col), .color_data(color_data));
	
	// display 4 digits on screen
	always @* 
		begin
		// defaults
		score_on = 0;
		row = 0;
		col = 0;
		
		// if vga pixel within bcd3 location on screen
		if( (x >= (50 + addX)) && (x < (66 + addX)) &&( y >= (50 + addY)) &&( y < (66 + addY) ))
			begin
			col = x - (50 + addX) ;
			row = y - (50 + addY) + (bcd3 * 16); // offset row index by scaled bcd3 value
			if(color_data == 1'b1)      // if bit is 1, assert score_on output
				score_on = 1;
			end
		
		// if vga pixel within bcd2 location on screen
		if((x >= (66 + addX) )&&( x < (82 + addX)) &&( y >= (50 + addY)) &&( y < (66 + addY)))
			begin
			col = x - (50 + addX);
			row = y - (50+ addY) + (bcd2 * 16); // offset row index by scaled bcd2 value
			if(color_data == 1'b1)      // if bit is 1, assert score_on output
				score_on = 1;
			end
		
		// if vga pixel within bcd1 location on screen
		if((x >= (82 + addX ))&&( x < (98 + addX) )&& (y >= (50 + addY)) && (y < (66 + addY)))
			begin
			col = x - (50 + addX);
			row = y - (50 + addY) + (bcd1 * 16); // offset row index by scaled bcd1 value
			if(color_data == 1'b1)      // if bit is 1, assert score_on output
				score_on = 1;
			end
		
		// if vga pixel within bcd0 location on screen
		if((x >= (98 + addX ))&& (x < (114 + addX)) && (y >= (50 + addY ))&& (y < (66 + addY)))
			begin
			col = x - (50 + addX);
			row = y - (50 + addY) + (bcd0 * 16); // offset row index by scaled bcd0 value
			if(color_data == 1'b1)      // if bit is 1, assert score_on output
				score_on = 1;
			end
		end
		
endmodule

//Wolf Movement
module movementFromCount(
    input  [4:0]count,
    input  [9:0]addition,
    input  secClock,
    output reg[9:0]addX,
    output reg[9:0]addY
);
    always @ (posedge secClock)
        begin
            addX = (15 - count) * 24;
            
            if(count % 2 == 0)
                addY = 120 + addition;
            else
                addY = addition + 70;
      
        end  
endmodule

//Display Number on Screen (Based on wolf)
module sprite_display
	(	
	    input wire clk, reset,   // clock, reset signal inputs for synchronous roms and registers
	    input wire [9:0] x, y,   // vga x/y pixel location
	    input wire [9:0] addX , addY,
	    input wire [4:0]count,
	    output reg score_on  ,    // output asserted when x/y are within score location in display
	    output reg [11:0]out_color
        );	
   // *** on screen score display ***
	
	// row and column regs to index numbers_rom
	reg [5:0] row;
	reg [5:0] col;
	
	// output from numbers_rom
	wire [11:0]color_data1;
	wire [11:0]color_data2;
	
	// infer number bitmap rom
	wolfSprite1 (.clk(clk), .row(row), .col(col), .color_data(color_data1));
	wolfSprite2 (.clk(clk), .row(row), .col(col), .color_data(color_data2));
	
	// display 4 digits on screen
	always @* 
		begin
        
        score_on = 0;
		row = 0;
		col = 0;
		
		// if vga pixel within bcd3 location on screen
		if(count%2 == 0) begin
		  if( (x >= (50 + addX)) && (x < (114 + addX)) &&( y >= (66 + addY)) &&( y < (130 + addY) ))
			 begin
			 col = x - (50 + addX) ;
			 row = y - (66 + addY) ; // offset row index by scaled bcd3 value
			 if(color_data1 != 12'b111111111110)      // if bit is 1, assert score_on output
				begin
				score_on = 1;
				out_color =  color_data1;
		        end
			 end
	       end
	    else if(count%2 == 1) begin
	     if( (x >= (50 + addX)) && (x < (114 + addX)) &&( y >= (66 + addY)) &&( y < (130 + addY) ))
	       begin
			 col = x - (50 + addX) ;
			 row = y - (66 + addY) ; // offset row index by scaled bcd3 value
			 if(color_data2 != 12'b111111111110)      // if bit is 1, assert score_on output
				begin
				score_on = 1;
				out_color =  color_data2;
		        end
			 end
		   end
	   end
endmodule	 


//Display Number on Screen (Based on wolf)
module sheep_display
	(	
	    input wire clk, reset,   // clock, reset signal inputs for synchronous roms and registers
	    input wire [9:0] x, y,   // vga x/y pixel location
	    input wire gameState,
	    output reg score_on  ,    // output asserted when x/y are within score location in display
	    output reg [11:0]out_color
        );	
   // *** on screen score display ***
	
	// row and column regs to index numbers_rom
	reg [5:0] row;
	reg [5:0] col;
	
	// output from numbers_rom
	wire [11:0]color_data1;
	wire [11:0]color_data2;
	
	// infer number bitmap rom
	sheep (.clk(clk), .row(row), .col(col), .color_data(color_data1));
	sheep (.clk(clk), .row(64-row), .col(col), .color_data(color_data2));
	
	// display 4 digits on screen
	always @* 
		begin
        
        score_on = 0;
		row = 0;
		col = 0;
		
		// if vga pixel within bcd3 location on screen
		if(gameState == 1) begin
		  if( (x >= (500)) && (x < (564)) &&( y >= (266 )) &&( y < (330) ))
			 begin
			 col = x - (500) ;
			 row = y - (266) ; // offset row index by scaled bcd3 value
			 if(color_data1 != 12'b111111111110)      // if bit is 1, assert score_on output
				begin
				score_on = 1;
				out_color =  color_data1;
		        end
			 end
	       end
	    else if(gameState == 0) begin
	     if( (x >= (500)) && (x < (564 )) &&( y >= (266)) &&( y < (330) ))
	       begin
			 col = x - (500) ;
			 row = y - (266) ; // offset row index by scaled bcd3 value
			 if(color_data2 != 12'b111111111110)      // if bit is 1, assert score_on output
				begin
				score_on = 1;
				out_color =  color_data2;
		        end
			 end
		   end
	   end
endmodule	 


module top_module (
    input clk,hard_reset,
    input [15:0] sw,
    output [6:0] seg,
    input btnC,
    output [3:0] an,
    output [15:0] led,
    output hsync,
    output vsync,
    output wire [11:0] rgb
);
    wire clock;
    wire secClock;
    wire reset; 
    wire video_on, pixel_tick;                                   
    wire [16:0] refreshcount;
    wire [13:0] wolfOne , wolfTwo , wolfThree , rng;
    wire [3:0] wolfOne0,wolfOne1,wolfOne2,wolfOne3 ,wolfTwo0 , wolfTwo1 , wolfTwo2 , wolfTwo3 , wolfThree0 , wolfThree1, wolfThree2, wolfThree3 ,score0,score1,score2,score3;
    wire [3:0] ledin, led1in, led2in , led3in ,led4in;
    wire [4:0] count1,count2,count3;
    wire [13:0] fourteen_bit_input;
    wire enableVCounter;
    wire game_reset; 
    wire [13:0] score;        
    wire sprite_wolf1_on,sprite_wolf2_on,sprite_wolf3_on,sprite_sheep;        
    wire [11:0] wolf1color,wolf2color,wolf3color,sheepcolor;                          
    wire [15:0] HCountValue;
    wire [15:0] VCountValue;
    wire wolf1_on,wolf2_on,wolf3_on,score_on,sheep_on,gameState;
    reg [11:0] rgb_reg, rgb_next;     
    wire [9:0] x, y , addX1 , addY1 , addX2 , addY2  ,addX3 , addY3 ,addScoreX,addScoreY,addition1, addition2 ,addition3 ;      
    assign reset = hard_reset || game_reset;                                                              

    divide (clk, clock);
    refreshcounter (clk, refreshcount);
    Counter (clock, sw, fourteen_bit_input,led);
    RNG(clock , rng);
    timer(clk,secClock);
    gamecontrol (clock , btnC ,rng ,secClock,fourteen_bit_input,score , wolfOne , wolfTwo , wolfThree,count1,count2,count3,gameState);
    binary_to_BCD (clock,fourteen_bit_input,led1in,led2in,led3in,led4in);
    binary_to_BCD (clock,score,score0,score1,score2,score3);
    binary_to_BCD (clock,wolfOne,wolfOne0,wolfOne1,wolfOne2,wolfOne3);
    binary_to_BCD (clock,wolfTwo,wolfTwo0,wolfTwo1,wolfTwo2,wolfTwo3);
    binary_to_BCD (clock,wolfThree,wolfThree0,wolfThree1,wolfThree2,wolThree3);

    Positionselector (refreshcount, led1in, led2in,led3in,led4in ,ledin, an);
    bcdto7seg (ledin, seg);
    
    assign addition1 = 0;
    assign addition2 = 120;
    assign addition3 = 240;
    assign addXScore = 260 ;
    assign addYScore = 0;
    
    //instantiate wolf display circuit
    wolf_display  (.clk(clk), .reset(reset), .bcd0(score0),.bcd1(score1),.bcd2(score2),.bcd3(score3),
					  .x(x), .y(y),.addX(addXScore),.addY(addYScore),.score_on(score_on));	
					  
    movementFromCount(count1,addition1,clk,addX1,addY1);
	wolf_display   (.clk(clk), .reset(reset), .bcd0(wolfOne0),.bcd1(wolfOne1),.bcd2(wolfOne2),.bcd3(wolfOne3),
					  .x(x), .y(y),.addX(addX1),.addY(addY1),.score_on(wolf1_on));	
	sprite_display (.clk(clk), .reset(reset),
					  .x(x), .y(y),.addX(addX1),.addY(addY1),.count(count1),.score_on(sprite_wolf1_on),.out_color(wolf1color));
    
    movementFromCount(count2,addition2,clk,addX2,addY2);
    wolf_display (.clk(clk), .reset(reset), .bcd0(wolfTwo0),.bcd1(wolfTwo1),.bcd2(wolfTwo2),.bcd3(wolfTwo3),
   				  .x(x), .y(y),.addX(addX2),.addY(addY2),.score_on(wolf2_on));	
   	sprite_display (.clk(clk), .reset(reset),
					  .x(x), .y(y),.addX(addX2),.addY(addY2),.count(count2),.score_on(sprite_wolf2_on),.out_color(wolf2color));
	
	movementFromCount(count3,addition3,clk,addX3,addY3);				
    wolf_display  (.clk(clk), .reset(reset), .bcd0(wolfThree0),.bcd1(wolfThree1),.bcd2(wolfThree2),.bcd3(wolfThree3),
					  .x(x), .y(y),.addX(addX3),.addY(addY3),.score_on(wolf3_on));	
	sprite_display (.clk(clk), .reset(reset),
					  .x(x), .y(y),.addX(addX3),.addY(addY3),.count(count3),.score_on(sprite_wolf3_on),.out_color(wolf3color));
					  
	sheep_display (.clk(clk), .reset(reset),
					  .x(x), .y(y),.gameState(gameState),.score_on(sheep_on),.out_color(sheepcolor));
    
    //outputs
    vga_sync vsync_unit (.clk(clk), .reset(hard_reset), .hsync(hsync), .vsync(vsync),
                             .video_on(video_on), .p_tick(pixel_tick), .x(x), .y(y));
                
    always @*
		begin
		  if(~video_on)
		      rgb_next = 12'b0;
		 else if(score_on)
		    begin 
		     if(score % 40 < 20)
	           rgb_next =  12'h000;
	         else
	            rgb_next = 12'hFFF;
	        end
	        
	     else if(sheep_on)
		    rgb_next =  sheepcolor;
		    
		 else if(wolf1_on)
			begin 
		     if(score % 40 < 20)
	           rgb_next =  12'h000;
	         else
	            rgb_next = 12'hFFF;
	        end
			
		 else if(wolf2_on)
			begin 
		     if(score % 40 < 20)
	           rgb_next =  12'h000;
	         else
	            rgb_next = 12'hFFF;
	        end
			
		 else if(wolf3_on)
			begin 
		     if(score % 40 < 20)
	           rgb_next =  12'h000;
	         else
	            rgb_next = 12'hFFF;
	        end
	        
		else if(sprite_wolf1_on)
		     begin 
		     if(score % 40 < 20)
	           rgb_next =  wolf1color;
	         else
	            rgb_next = ~wolf1color;
	        end
	     else if(sprite_wolf2_on)
		     begin 
		     if(score % 40 < 20)
	           rgb_next =  wolf2color;
	         else
	            rgb_next = ~wolf2color;
	        end
	      else if(sprite_wolf3_on)
		     begin 
		     if(score % 40 < 20)
	           rgb_next =  wolf3color;
	         else
	            rgb_next = ~wolf3color;
	        end
		  else if(score % 40 < 20) //Day
		      rgb_next = 12'h1E3;
		  else                    //Night
		      rgb_next = 12'h037;
		end         
		    
    always @(posedge clk)
		if (pixel_tick)
			rgb_reg <= rgb_next;		
			
	// output rgb data to VGA DAC
	assign rgb = rgb_reg;
    
   
endmodule



