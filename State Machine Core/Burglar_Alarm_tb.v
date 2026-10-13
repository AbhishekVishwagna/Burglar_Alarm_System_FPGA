/* Burglar_Alarm.v - ELEC5566M Burglar Alarm state machine Skeleton
 * 
 * created on : 25-04-2026
 * Author : Abhishek 
 *
*/

`timescale 1ns/1ps

// Testbecnh for the Burglar_alram_tb
module Burglar_Alarm_tb;

reg clk; 
reg reset; 
reg sw0; 
reg sensor; 
reg btn_valid;
reg [1:0] btn_pressed;
reg trigger_timer_done; 
reg pin_timer_done; 
reg lockout_done;

wire [2:0] state_out;
wire alarm_active, lockout_active;
wire [1:0] attempts_left;

Burglar_Alarm #(.SUCCESS_HOLD_CYCLES(10)) dut (
    .clk(clk),
    .reset(reset),
    .sw0(sw0),
    .sensor(sensor),
    .btn_valid(btn_valid),
    .btn_pressed(btn_pressed),
    .trigger_timer_done(trigger_timer_done),
    .pin_timer_done(pin_timer_done),
    .lockout_done(lockout_done),
    .state_out(state_out),
    .alarm_active(alarm_active),
    .lockout_active(lockout_active),
    .attempts_left(attempts_left)
);

initial clk = 0;
always #10 clk = ~clk;

// initial conditions setting for the test
initial begin

    reset = 1;
    sw0 = 0; sensor = 0;
    btn_valid = 0; btn_pressed = 0;
    trigger_timer_done = 0;
    pin_timer_done = 0;
    lockout_done = 0;

    repeat(3) @(posedge clk);
    reset = 0;
    @(posedge clk); #1;
    $display("when is reset done, state = %0d", state_out);

    // arm state
    @(negedge clk); sw0 = 1;
    @(posedge clk); #1;
    $display("when it is armed, state = %0d", state_out);

    // disarmed state
    @(negedge clk); sw0 = 0;
    @(posedge clk); #1;
    $display("when it is disarmed, state = %0d", state_out);

    // arm state again now
    @(negedge clk); sw0 = 1;
    @(posedge clk); #1;

    // trigger sensor states
    @(negedge clk); sensor = 1;
    @(posedge clk); #1;
    sensor = 0;
    $display("when some sensor is triggered: state = %0d alarm = %0b", state_out, alarm_active);

    @(negedge clk); trigger_timer_done = 1;
    @(posedge clk); #1;
    trigger_timer_done = 0;
    $display("when the pin entry: state = %0d attempts = %0d", state_out, attempts_left);

    // entering correct pin pattern set by us (KEY2 KEY3 KEY1)
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
    @(posedge clk); #1;
    $display("correct pin: state = %0d", state_out);

    // waiting for success to go back to armed
    repeat(11) begin
        @(posedge clk); #1;
    end
    $display("after success hold: state = %0d", state_out);

    //for the second cycle to test wrong pins
    @(negedge clk); sensor = 1;
    @(posedge clk); #1;
    sensor = 0;

    @(negedge clk); trigger_timer_done = 1;
    @(posedge clk); #1;
    trigger_timer_done = 0;

    // for the wrong pin 1
    @(negedge clk);
    btn_pressed = 2'b01; btn_valid = 1;
    @(posedge clk); #1;
    btn_valid = 0;
    @(posedge clk); #1;
    $display("For the wrong pin 1: attempts = %0d", attempts_left);

    // for the wrong pin 2
    @(negedge clk);
    btn_pressed = 2'b11; btn_valid = 1;
    @(posedge clk); #1;
    btn_valid = 0;
    @(posedge clk); #1;
    $display("For the wrong pin 2: attempts = %0d", attempts_left);

    // When wrong pin 3 then it should lockout
    @(negedge clk);
    btn_pressed = 2'b01; btn_valid = 1;
    @(posedge clk); #1;
    btn_valid = 0;
    @(posedge clk); #1;
    $display("The lockout: state = %0d lockout_active = %0b", state_out, lockout_active);

    @(negedge clk); lockout_done = 1;
    @(posedge clk); #1;
    lockout_done = 0;
    $display("after the lockout: state = %0d", state_out);

    // To testing  the pin timeout
    @(negedge clk); sw0 = 1;
    @(posedge clk); #1;

    @(negedge clk); sensor = 1;
    @(posedge clk); #1;
    sensor = 0;

    @(negedge clk); trigger_timer_done = 1;
    @(posedge clk); #1;
    trigger_timer_done = 0;

    @(negedge clk); pin_timer_done = 1;
    @(posedge clk); #1;
    pin_timer_done = 0;
    $display("pin timeout lockout: state = %0d", state_out);

    @(negedge clk); lockout_done = 1;
    @(posedge clk); #1;
    lockout_done = 0;
    $display("final: state = %0d", state_out);

    $finish;
end

endmodule
