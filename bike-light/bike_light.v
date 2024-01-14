`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineers: Aidan Quigney, Jeremy Joy
// 
// Create Date: 02.11.2023 10:18:52
// Design Name: 
// Module Name: bike_light
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple bicycle light which has 3 modes: constant on, slow flash, fast flash.
//              Created as a project for EEEN30190 (Digital System Design) at University College Dublin
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module bike_light #(parameter bounce_in_cycles = 16'd50000, button_count_cycles = 24'd10000000, half_slow_cycle = 21'd1666667, half_fast_cycle = 20'd625000)(
    input clock,
    input reset,
    input button,
    output reg [2:0] light
    );
    localparam [1:0] OFF = 2'b00;
    localparam [1:0] CONST = 2'b01;
    localparam [1:0] SLOW = 2'b10;
    localparam [1:0] FAST = 2'b11;
    
    reg[15:0] pulsecount, nextpulsecount;
    wire pulse = ( pulsecount == bounce_in_cycles);
    reg sample_button;
    reg [23:0] button_count, next_button_count;
    wire long =  (button_count == button_count_cycles);
    reg [1:0]press;
    reg [1:0] light_state, next_light_state;
    wire slow_flash, fast_flash;
    
    reg [21:0]next_slow_count, slow_count;
    reg [20:0]next_fast_count, fast_count;
    
    
    //Pulse Generator
    always @ (posedge clock)
        begin
            if (reset) pulsecount<= 16'b0;
            else pulsecount<= nextpulsecount;
        end
        
    always @ (pulsecount, pulse)
        begin
            if (pulse) nextpulsecount = 15'b0;
            else nextpulsecount = pulsecount + 16'b1;
        end
    always @ (posedge clock)
        begin
            if (reset)sample_button <=1'b0;
            else if (pulse) sample_button <= button;
        end
    //clean up
    always @ (posedge clock)
        begin 
            if (reset) button_count <= 24'b0;
            else button_count <= next_button_count;
        end
        
    always @ (button_count, sample_button,long)
        begin
            case ({sample_button, long})
                2'b00: next_button_count = 24'b0;
                2'b01: next_button_count = 24'b0;
                2'b10: next_button_count = 24'b1 + button_count;
                2'b11: next_button_count = button_count;
            endcase
        end
    always @ (sample_button, button_count)
        case({((button_count< button_count_cycles) &&(button_count != 24'b0) ), sample_button, (button_count== button_count_cycles - 24'b1)})
            3'b000: press = 2'b00;
            3'b001: press = 2'b00;
            3'b010: press = 2'b00;
            3'b011: press = 2'b00;
            3'b100: press = 2'b01;
            3'b101: press = 2'b00;
            3'b110: press = 2'b00;
            3'b111: press = 2'b10;
        endcase

    //light state machine
    always @ (light_state, press)
        case(light_state)
            OFF: if(press == 2'b00 || press ==2'b01|| press==2'b11) next_light_state = OFF;
                else next_light_state = CONST;
            CONST: if(press== 2'b01) next_light_state = SLOW;
                else if (press == 2'b10) next_light_state = OFF;
                else next_light_state = CONST;
            SLOW: if(press== 2'b01) next_light_state = FAST;
                else if (press == 2'b10) next_light_state = OFF;
                else next_light_state = SLOW;
            FAST: if(press== 2'b01) next_light_state = CONST;
                else if (press == 2'b10) next_light_state = OFF;
                else next_light_state = FAST;
        endcase
    
    always @(posedge clock)
        begin
            if (reset) light_state <= 2'b0;
            else light_state <= next_light_state;
        end
    
    //flash slow
    always @(posedge clock)
            begin
                if (reset) slow_count <= 22'b0;
                else slow_count <= next_slow_count;
            end
    
    always @ (slow_count) 
        begin
            if ( slow_count == 2 * half_slow_cycle) next_slow_count = 22'b0;
            else next_slow_count = slow_count + 22'b1;
        end
    //flash fast
   always @(posedge clock)
           begin
               if (reset) fast_count <= 22'b0;
               else fast_count <= next_fast_count;
           end
       
   always @ (fast_count) 
       begin
           if ( fast_count == 2 * half_fast_cycle) next_fast_count = 22'b0;
           else next_fast_count = fast_count + 22'b1;
       end
     assign slow_flash = (slow_count < half_slow_cycle);
     assign fast_flash = (fast_count < half_fast_cycle);
     
     
    always@(light_state, slow_flash, fast_flash)
        case (light_state)
            OFF:  light = 3'd0;
            CONST:  light = 3'd7;
            SLOW: if(slow_flash) light = 3'd7;
                  else light = 3'd0;
            FAST: if(fast_flash) light = 3'd7;
                   else light = 3'd0;
        endcase
endmodule
