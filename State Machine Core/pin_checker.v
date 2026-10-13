/*  pin_checker.v - checks the 4 press button sequence as a pin
 *
 * created on : 27-04-2026
 * Author : Abhishek 
 *
*/

module pin_checker (
    input       clk,            // the clock
    input       reset,          // the reset
    input       btn_valid,      // high if button is pressed
    input [1:0] btn_pressed,    // which of the 4 button is pressed
    output reg  pin_correct,    // goes high if PIN is correct
    output reg  pin_wrong,      // goes high if PIN is wrong
    input       pin_active      // high state when pin is entered   
);


localparam [1:0]
    KEY1 = 2'b01,
    KEY2 = 2'b10,
    KEY3 = 2'b11,

reg [1:0] buf0, buf1;
reg[1:0] press_count; // to check how many correct presses so far

always @(posedge clk or posedge reset) begin 
if (reset) begin
        pin_correct <= 1'b0;
        pin_wrong   <= 1'b0;
        press_count <= 2'd0;
        buf0        <= 2'd0;
        buf1        <= 2'd0;

    end else begin
        // for default, if outputs low unless triggered this cycle
        pin_correct <= 1'b0;
        pin_wrong   <= 1'b0;

        if(!pin_active) begin
            // not in pin entry state
            press_count <= 2'd0;
            buf0        <= 2'd0;
            buf1        <= 2'd0;
        
        end else if (btn_valid) begin
            case (press_count)

                2'd0: begin
                    // the 1st attempt to press  
                    buf0        <= btn_pressed;
                    press_count <= 2'd1;
                end

                2'd1: begin
                    // the 2nd attempt to press  
                    buf1        <= btn_pressed;
                    press_count <= 2'd2;
                end

                2'd2: begin
                    // the 3nd attempt to press and also the final one 
                    // Correct sequence give by me for the correct pin (KEY2 - KEY3 - KEY1)
                    if (buf0 == KEY2 && buf1 == KEY3 && btn_pressed == KEY1)
                        pin_correct <= 1'b1;
                    else
                        pin_wrong   <= 1'b1;

                    // Reset for next attempt on board
                    press_count <= 2'd0;
                    buf0        <= 2'd0;
                    buf1        <= 2'd0;
                end

                default: press_count <= 2'd0;
 
            endcase
        end
    end
end

endmodule