`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineers: Aidan Quigney, Jeremy Joy
// Create Date: 23.11.2023 10:09:38
// Design Name: Calculator
// Module Name: Calculator_Core_Logic
// Description: Simple calculator design, which can perform addition, multiplication, sqauring and contains an AC and CE button
//              Made as a project for EEEN30190 (Digital System Design) at Univeristy College Dublin
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module Calculator_Core_Logic(
    input clock,
    input reset,
    input newkey,
    input [4:0] keycode,
    output [19:0] value
    );
    reg [19:0]x;
      reg [19:0]y;
      reg [19:0] result;
      reg[1:0] op;
      
      reg [19:0] nextx;
      reg [19:0] nexty;
      reg [1:0] nextop;
      reg [19:0] userinput;
      reg lastwasnum;
      
      wire [19:0] square = x *x;
      wire isop = (keycode[4:2] == 3'b010);
      wire issquare = (keycode == 5'b1);
      wire isequals = (keycode == 5'd4);
      wire isnum = (keycode[4] == 1'b1);
      wire [19:0] conc = {x[15:0], keycode[3:0]};
      wire isadd = (keycode == 5'b01001);
      wire ismul = (keycode == 5'b01010);
      wire isce = (keycode == 5'b00010);
      wire isac = (keycode == 5'b01100);
      
      //nextx comb logic
      always @ (newkey, conc, x, result, issquare, square, isop, isequals, isnum, userinput, isce, isac)
        begin
          if(newkey == 0) nextx = x;
          else
            if (isce || isac) nextx = 20'b0;
              else
                case({issquare, isop, isequals,isnum})
                  4'b0000: nextx = x;
                  4'b0001: nextx = userinput;
                  4'b0010: nextx = result;
                  4'b0011: nextx = x;
                  4'b0100: nextx = x;
                  4'b0101: nextx = x;
                  4'b0110: nextx = x;
                  4'b0111: nextx = x;
                  4'b1000: nextx = square;
                  4'b1001: nextx = x;
                  4'b1010: nextx = x;
                  4'b1011: nextx = x;
                  4'b1100: nextx = x;
                  4'b1101: nextx = x;
                  4'b1110: nextx = x;
                  4'b1111: nextx = x;
                  default: nextx = x;
                endcase
        end
      //X register
      always @ (posedge clock)
        begin
          if (reset) x <= 20'b0;
          else x <= nextx;
        end
      
    //Y combinational logic
      always @ (x,y, keycode, isequals, isop, newkey, isac)
          begin
          if (isac) nexty = 20'b0;
          else
            case({newkey, isop, isequals})
              3'b000: nexty = y;
              3'b001: nexty = y;
              3'b010: nexty = y;
              3'b011: nexty = y;
              3'b100: nexty = y;
              3'b101: nexty = 20'b0;
              3'b110: nexty = x;
              3'b111: nexty = y;
              default nexty = y;
            endcase
        end
      
    //Y register
      always @ (posedge clock)
        begin
          if (reset) y <= 20'b0;
          else y <= nexty;
        end
      
    //op logic
      always @ (keycode, newkey, op, ismul,isadd, isac)
        begin
          if (isac) nextop = 2'b0;
          else 
            case({newkey, ismul,isadd})
              3'b000: nextop = op;
              3'b001: nextop = op;
              3'b010: nextop = op;
              3'b011: nextop = op;
              3'b100: nextop = op;
              3'b101: nextop = 2'b10;
              3'b110: nextop = 2'b01;
              3'b111: nextop = op;
              default: nextop = op;
            endcase
        end
    // Operation register
      always @ (posedge clock)
        begin
          if (reset) op <= 2'b0;
          else op <= nextop;
        end
      
    //result logic
      always @(x, y, op)
        begin
          case (op)
            2'b00: result = 20'b0;
            2'b01: result = x*y;
            2'b10: result = x +y;
            2'b11: result = 20'b0;
            default: result = 20'b0; 
          endcase
        end
    //userinput combinational logic
    always @ (lastwasnum, keycode, conc)
        begin
          if(lastwasnum) userinput = conc;
          else userinput = {16'b0, keycode[3:0]};
        end
    //lastwasnum register
    always @ (posedge clock)
        begin
            if (reset) lastwasnum = 1'b0;
            else
                if (newkey) lastwasnum = isnum;
                else lastwasnum = lastwasnum;
        end
          
      assign value = x;
endmodule
