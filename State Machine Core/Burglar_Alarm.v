/* Burglar_Alarm.v - ELEC5566M Burglar Alarm state machine Skeleton
 * 
 * created on : 25-04-2026
 * Author : Abhishek 
 *
*/

module Burglar_Alarm (
    input               clk,                // Board clock
    input               reset,              // active high reset
    input               sensor,             // button for simulating sensor
    input   [3:0]       pin_input,          // 4 buttons for pin entry
    output reg [1:0]    state_out,          // the current state
    output reg          alarm_active,        // high when the alarm is going off
    input               sw0,                // switch 0 to arm/activate the system
    input               btn_valid,          // high if button is pressed
    input [1:0]         btn_pressed,        // which of the 4 button is pressed
    input               lockout_done,       // lockout for the system
    output reg [1:0]    attempts_left,        // to show the attmepts left
    input               trigger_timer_done,  // for 5seconds in TRIGGERED screen
    input               pin_timer_done,     // 60seconds for PIN_ENTRY 
    output reg          lockout_active     // high during LOCKOUT

);

/* states of the Burglar Alarm system  */
localparam [1:0]
    IDLE         = 3'b000,  // system off, waiting for sw0
    ARMED        = 3'b001,  // Alarm system active, watching for any motion
    TRIGGERED    = 3'b010,  // Alarm going off/triggered
    PIN_ENTRY    = 3'b011,  // user to enter the pin
    SUCCESS      = 3'b100,  // pin enter successfully 
    LOCKOUT      = 3'b101;  // system lockout , alarm & LEDs turned on


wire pin_correct;
wire pin_wrong;

/* initalise the pin_checker module */
pin_checker u_pin (
    .clk            (clk),
    .reset          (reset),
    .btn_valid      (btn_valid),
    .btn_pressed    (btn_pressed),
    .pin_correct    (pin_correct),
    .pin_wrong      (pin_wrong),
    .pin_active  (current_state == PIN_ENTRY)  // only runs in PIN_ENTRY case
);

/* state registers  */
reg [1:0]  current_state;
reg [1:0]  next_state;
reg [1:0]  wrong_attempts;     // counts the woring pin attempts
reg [26:0] success_cnt;

/* initial states */
always @(*) begin
    state_out = current_state;
    alarm_active = (current_state == TRIGGERED);
    lockout_active = (current_state == LOCKOUT);
    attempts_left = 2'd3 - wrong_attempts;
end

/* the state transition logic */
always @(*) begin
    next_state = current_state; // to stay in the same state

    case (current_state)

    /* DISARMED - waiting for the user to arm the system */
        IDLE: begin
            if (sw0)
                next_state = ARMED;
        end

        /* ARMED - The system is activated and watching the intruders */
        ARMED: begin
            if(!sw0)
                next_state = IDLE;
            else if (sensor)
                next_state = TRIGGERED;
        end

        /* TRIGGERED -  wait for 5 seconds to go to pin entry state */
        TRIGGERED: begin
            if (trigger_timer_done)
                    next_state = PIN_ENTRY;
            end

        PIN_ENTRY: begin
            if (pin_correct) begin
                next_state = SUCCESS;
            end else if (pin_timer_done) begin
                next_state = LOCKOUT;
            end else if (pin_wrong && wrong_attempts >= 2'd2) begin
                next_state = LOCKOUT;
            end
        end
        /*SUCCESS - when the pin is entered correct it will come to this case */
        SUCCESS: begin
            if(success_cnt == SUCCESS_HOLD_CYCLES - 1) begin
                if(sw0)
                    next_state = ARMED;
                else
                    next_state = IDLE;
            end
        end

        /* LOCKOUT - Too many wrong attempts then the timer is triggered till timeout */
        LOCKOUT: begin
            if (lockout_done)
            next_state = IDLE;
        end

        default: next_state = IDLE;
        
    endcase
end

/* To update the state register and also wrong attempt counter*/
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state  <= IDLE;
        wrong_attempts <= 2'd0;
        success_cnt    <= 27'd0;
    end else begin
        current_state <= next_state;

        // To count the wrong pin attempts when it is triggered
        if (current_state == PIN_ENTRY && next_state != PIN_ENTRY) begin
            //  the worng attempts
            wrong_attempts <= 2'd0;
        end else if (current_state == PIN_ENTRY && pin_wrong) begin
            // to reset attempt counter when exiting Triggered state
            wrong_attempts <= wrong_attempts + 1'b1;
        end

        // for the success counter
        if (current_state == SUCCESS)
            success_cnt <= success_cnt + 1'b1;
        else
            success_cnt <= 27'd0;
    end
end

endmodule