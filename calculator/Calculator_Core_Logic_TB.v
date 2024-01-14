`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineers: Aidan Quigney, Jeremy Joy
// Create Date: 23.11.2023 10:11:32
// Design Name: Calculator Testbench
// Module Name: Calculator_Core_Logic_TB
// Project Name: Calculator
// Description: This is a simple testbench which checks the functionality of the calculator core logic module
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module Calculator_Core_Logic_TB(

  );
    reg clock, reset, newkey;
    reg [4:0] keycode;
    wire [19:0] value;
    integer error_count =0;
    
    Calculator_Core_Logic calc(.clock(clock), .reset(reset),.newkey( newkey), .keycode(keycode), .value(value));
    
    initial 
      begin
        clock = 1'b0;
        newkey =1'b0;
        reset = 1'b0;
        forever
          #100 clock = ~clock;
      
        end
    
    task PRESS (input [4:0] key);
      begin
        keycode = key;
        #600
        @ (posedge clock) #1 newkey =1;
        #50
        @ (posedge clock) #1 newkey =0;
        
      end
    endtask
    
    task CHECK (input [19:0] check);
      #300
        begin
          if(value !== check)
              begin
                $display("Error at %t: value%h, expected=%h",$time, value, check);
                error_count = error_count + 1;
            end
        end
    endtask
        
    task AC ();
      begin
        #200
        PRESS(5'b01100); //AC
        #200
        CHECK(20'b0);
      end
    endtask
    
    initial 
      begin
      //reset to begin
        reset= 1;
        #200
        reset =0;
        #10
        CHECK(20'b0);
        #10
      //Checking simple addition 25 + 6b = 90
        PRESS(5'h12);
        
        CHECK(20'h2);
        
        PRESS(5'h15);
        
        CHECK(20'h25);
        
        PRESS(5'b01001); //+
        
        CHECK(20'h25);
        
        PRESS(5'h16);
        
        CHECK(20'h6);
        
        PRESS(5'h1b);
        
        CHECK(20'h6b);
        
        PRESS(5'b00100);
        
        CHECK(20'h90);

        //AC, then Check Multiplication 3bx1a = 5fe
        
        AC();
        
        CHECK(20'b0);
        
        
        PRESS(5'h13);
        
        CHECK(20'h3);
        
        PRESS(5'h1b);
        
        CHECK(20'h3b);
        
        PRESS(5'b01010); // (x) multiplication
        
        CHECK(20'h3b);
        
        PRESS(5'h11);
        
        CHECK(20'h1);
        
        PRESS(5'h1a);
        
        CHECK(20'h1a);
        
        PRESS(5'b00100);
        
        CHECK(20'h5fe);
        
        
        //Testing the square function on 5fe that is in the register = 23E804 (Should cause overflow)
        PRESS(5'b00001);
        
        CHECK(20'h3e804);
        
        //testing CE Button to clear the second number. c5 + 72 then CE 72, replace with 9d. Should be 162
        // ie c5+72 CE 9d =162
        
      AC();
      
        PRESS(5'h1c);
        
        CHECK(20'hc);
        
        PRESS(5'h15);
        
        CHECK(20'hc5);
        
        PRESS(5'b01001);
        
        CHECK(20'hc5);
        
        PRESS(5'h17);
                  
        CHECK(20'h7);
        
        PRESS(5'h12);
        
        CHECK(20'h72);
        
        PRESS(5'b00010); //CE
        
        CHECK(20'b0);
        
        PRESS(5'h19);
                
        CHECK(20'h9);
        
        PRESS(5'h1d);
        
        CHECK(20'h9d);
        
        PRESS(5'b00100);
        
        CHECK(20'h162);
        
        //checking multiple operations in sequence
        //da + 81 = 15b x 4c = 6704
        AC();
        
        PRESS(5'h1d);
        CHECK(20'hd);
        
        PRESS(5'h1a);
        CHECK(20'hda);
        
        PRESS(5'b01001);
        CHECK(20'hda);
        
        PRESS(5'h18);
        CHECK(20'h8);
        
        PRESS(5'h11);
        CHECK(20'h81);
        
        PRESS(5'b00100);
        CHECK(20'h15b);
        
        PRESS(5'b01010);
        CHECK(20'h15b);
        
        PRESS(5'h14);
        CHECK(20'h4);
        
        PRESS(5'h1c);
        CHECK(20'h4c);
        
        PRESS(5'b00100);
        CHECK(20'h6704);
        
        
        $display ("Total Error Count: %d", error_count);
        $stop;
      end
//      initial begin
//        $dumpfile("dump.vcd");
//        $dumpvars(2);
//      end
endmodule
