/*  pin_checker_tb.v - checks the 4 press button sequence as a pin - testbench
 *
 * created on : 27-04-2026
 * Author : Abhishek 
 *
*/

`timescale 1ns/1ps

module pin_checker_tb;

//  inputs driven by testbench
reg        clk;
reg        reset;
reg        btn_valid;
reg [1:0]  btn_pressed;

// outputs of testbench
wire       pin_correct;
wire       pin_wrong;

// instantiate the module to be tested
pin_checker uut (
    .clk         (clk),
    .reset       (reset),
    .btn_valid   (btn_valid),
    .btn_pressed (btn_pressed),
    .pin_correct (pin_correct),
    .pin_wrong   (pin_wrong)
);

initial clk = 0;
always #10 clk = ~clk;

initial begin
// initial conditions set for the test
    reset = 1;
    pin_active = 0;
    btn_valid = 0;
    btn_pressed = 0;

    repeat(3) @(posedge clk);
    reset = 0;
    @(posedge clk); #1;

    pin_active = 1;

    // To test the correct sequence set by myself  (KEY2 KEY3 KEY1)
    @(negedge clk); 
    btn_pressed = 2'b10; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0; 
    @(posedge clk); #1;

    @(negedge clk); 
    btn_pressed = 2'b11; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0; 
    @(posedge clk); #1;

    @(negedge clk); 
    btn_pressed = 2'b01; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0;
    $display("For the correct pin entered: correct=%0b wrong=%0b", pin_correct, pin_wrong);
    @(posedge clk); #1;

    // For the first wrong key
    @(negedge clk); 
    btn_pressed = 2'b01; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0;
    $display("When the  first wrong key entered: wrong=%0b", pin_wrong);
    @(posedge clk); #1;

    // For the second wrong key
    @(negedge clk); 
    btn_pressed = 2'b10; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0; 
    @(posedge clk); #1;

    @(negedge clk); 
    btn_pressed = 2'b10; btn_valid = 1; // should be KEY3
    @(posedge clk); #1; 
    btn_valid = 0;
    $display("When the second wrong key entered: wrong=%0b", pin_wrong);
    @(posedge clk); #1;

    // when the pin_active is low
    pin_active = 0;
    @(negedge clk); 
    btn_pressed = 2'b10; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0; @(posedge clk); #1;

    @(negedge clk); 
    btn_pressed = 2'b11; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0; @(posedge clk); #1;
    
    @(negedge clk); 
    btn_pressed = 2'b01; btn_valid = 1;
    @(posedge clk); #1; 
    btn_valid = 0;
    $display("when the pin_active=0: correct=%0b wrong=%0b", pin_correct, pin_wrong);
    pin_active = 1; 
    @(posedge clk); #1;

    $finish;
end

endmodule