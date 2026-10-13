# Burglar Alarm System
---

## Project Description

This is a Burglar Alarm system project on the ARM Cortex-A9 (DE1-SoC) with real_time LCD Display, hardware button input, a countdown timer, audio feedback.
The system replicates a real security alarm with four states - Disarmed, Armed, Triggered, and Lockout. These are controlled by a state machine running on the DE1-SoC Board. A four button press PIN sequence is used to disarm or disable the system, with a lockout activating after three consecutive wrong attempts. The system will provide a visual feedback on the LT24 LCD display and also on the seven segment displays onboard the DE1-SoC Board.

---

## System design

The Burglar Alarm System is implemented on the DE1-SoC platform, utilizing a hardware & software co design approach. The core logic is governed by a synchronous Finite State Machine (FSM), which ensures reliable transitions between security states based on user input and sensor data.

---
### Functional Block Diagram

The system is partitioned into several dedicated modules to ensure modularity and ease of debugging:

*   **State Control Logic (FSM):** The main part of the system. It handles the transition between the following states:
    *   `DISARMED`: System is idle; waiting for the correct arming sequence.
    *   `ARMING`: Provides a grace period for the user to exit the premises.
    *   `ARMED`: Actively monitoring sensor inputs (switches/GPIO).
    *   `TRIGGERED`: Alarm is active; requires the correct PIN to reset.
*   **Pin Verification Module:** A comparator circuit that validates the input from the toggle switches against a hardcoded or programmable security key.
*   **LCD Interface Controller:** A driver module that translates system state data into ASCII characters for real-time status updates on the **LT24** Display.
*   **User Interface (I/O Handler):**
    *   **Inputs:** Push-buttons (`KEYs`) for PIN entry and Toggle Switches (`SWs`) for reset.
    *   **Outputs:** Hex Displays for countdowns and LEDs for visual status indicators.

```
IDLE ──(SW0 up)──► ARMED ──(SW1 flipped)──► TRIGGERED ──(5s) ──────►  PIN_ENTRY
                      ▲                                               │      │
                      │                                               │    3 wrong / 60s
                      │                                               │      │
                      └──────────────── SUCCESS ◄─────────────────────┘   LOCKOUT
                                                                             │ (30s)
                                                                             ▼
                                                                            IDLE
```

 #
 
### Design Methodology

*   **Hardware Description:** The peripheral controllers and the FSM logic are authored in **Verilog HDL**, synthesized using **Intel Quartus Prime lite**.
*   **Clock Management:** A clock divider module is employed to step down the 50MHz onboard oscillator to a human-readable frequency for the alarm delay and LED blinking patterns.
*   **Synchronization:** All asynchronous inputs from buttons and switches are passed through a **debouncing circuit** to prevent false triggers.

#

### State Transition

- **IDLE** : Nothing is happening. LCD shows a blue "LOCK THE SYSTEM" screen with an unlocked padlock.
 
- **ARMED** : System is watching for the sensor. LCD shows green "LOCKED". Flip SW[0] back down to return to idle.
 
- **TRIGGERED** : Motion detected. LCD goes red with "ALARM / TRIGGERED". The 5-second countdown starts on HEX0/HEX1. After 5 seconds the system moves to PIN entry automatically.
 
- **PIN_ENTRY** : User has 60 seconds and 3 attempts to enter the PIN. The 60-second countdown runs on the 7-seg displays. LCD shows "ENTER THE PIN" on the first attempt. After each wrong attempt the screen changes to show how many attempts are left.
 
- **SUCCESS** : Correct PIN entered. LCD shows green "PIN ENTERED / SUCCESSFULLY" for 2 seconds, then the system goes back to ARMED (or IDLE if SW[0] was flipped down).
 
- **LOCKOUT** : Too many wrong attempts or timed out. LCD shows red "WRONG PIN / SYSTEM LOCKED". Locked for 30 seconds then resets to IDLE.

#

## Hardware pin setup
 
| Input | Board Pin | What it does |
|---|---|---|
| SW[0] | AB12 | Arm switch — flip up to arm the system |
| SW[1] | AC12 | Sensor trigger — flip up to simulate motion detection |
| KEY[0] | AA14 | System reset (hold down) |
| KEY[1] | AA15 | PIN button 1 |
| KEY[2] | W15 | PIN button 2 |
| KEY[3] | Y16 | PIN button 3 |
 

#

## PIN entry
 
The correct sequence is: **KEY2 → KEY3 → KEY1**
 
Each attempt requires exactly 3 button presses. The system only decides if the attempt is right or wrong after the third press — pressing a wrong button on the first press doesn't immediately count as a failed attempt, you still need to complete all 3 presses. This means you get the full 9 button presses across 3 attempts before the system locks out.
 
The buttons are debounced (20ms counter at 50MHz) so each physical press produces exactly one pulse regardless of how long you hold the button.

#

 ## LCD screens
 
| State | Screen | Colour |
|---|---|---|
| IDLE | "LOCK THE  SYSTEM" + unlocked padlock | Blue |
| ARMED | "LOCKED" + padlock icon | Green |
| TRIGGERED | "ALARM  TRIGGERED" | Red |
| PIN_ENTRY  | "ENTER THE  PIN" | Blue |
| PIN_ENTRY  | "WRONG PIN  ATTEMPTS: 2" | Red |
| PIN_ENTRY  | "WRONG PIN  ATTEMPTS: 1" | Red |
| SUCCESS | "PIN ENTERED  SUCCESSFULLY" | Green |
| LOCKOUT | "WRONG PIN  SYSTEM LOCKED" | Red |
 
---
---
## Hardware Testing

Hardware testing was done on the DE1-SoC board in the lab. Each state transition was tested manually by operating the switches and buttons and observing the LCD screen, 7-seg displays, and LEDs to confirm the system behaved as expected.


### Arming and Disarming

The first thing tested was the basic arm and disarm. Flipping SW[0] up moved the system from the blue "LOCK THE SYSTEM" screen to the green "LOCKED" screen, and flipping it back down returned it to idle. This confirmed the IDLE to ARMED transition and back was working correctly through the 2 stage synchroniser in the top level.

<img width="1280" height="719" alt="WhatsApp Image 2026-05-08 at 1 09 50 PM" src="https://github.com/user-attachments/assets/5821424a-3a4b-457a-ac6f-c9b03ef56ea7" />

#

### Sensor Trigger

SW[1] was flipped up to simulate a motion detection event. The LCD immediately switched to the red alarm screen and the 5 second countdown appeared on HEX0 and HEX1. The key thing tested here was leaving SW[1] up after triggering, because of the rising edge detector in the top level, the alarm only fired once and did not keep retriggering while the switch stayed high. After 5 seconds the system automatically moved to the PIN entry screen.

<img width="1265" height="739" alt="WhatsApp Image 2026-05-08 at 1 09 50 PM (1)" src="https://github.com/user-attachments/assets/4d7c9a7b-8bb9-459a-a0c2-3d6c8a19cb89" />

#

### PIN Entry

The correct sequence (KEY2 → KEY3 → KEY1) was entered and the system moved to the green success screen then re armed back to LOCKED. I also tested entering wrong sequences — after each wrong 3 press attempt the LCD correctly updated to show the remaining attempts going from 2 down to 1. On the third wrong attempt the system went to the red lockout screen and the 30-second countdown started on the 7 seg displays. The attempt counter on LEDR[6:5] was also watched during this test and decremented correctly alongside the LCD.

<img width="1162" height="739" alt="WhatsApp Image 2026-05-08 at 1 09 50 PM (2)" src="https://github.com/user-attachments/assets/5a55d941-fc83-4b24-ac8c-971fae80ce52" />

#

### Timeout

Let the 60 second PIN entry timer run out without pressing any buttons. The system moved to LOCKOUT automatically once the countdown hit zero, which confirmed the `pin_timer_done` signal from timer module was being received correctly by the state machine.

<img width="1151" height="739" alt="WhatsApp Image 2026-05-08 at 1 09 50 PM (3)" src="https://github.com/user-attachments/assets/33ee16a1-959f-42b4-aa6f-586998c8892f" />

#

### Reset

KEY[0] was held down from several different states — ARMED, TRIGGERED, PIN_ENTRY, and LOCKOUT and in every case the system returned to IDLE and the LCD went back to the blue lock screen. This confirmed the synchronised reset was working correctly from any state.

<img width="1138" height="739" alt="WhatsApp Image 2026-05-08 at 1 09 50 PM (4)" src="https://github.com/user-attachments/assets/fbab374b-e8e7-4f4d-b628-a5ed10db7f74" />

#

---
## File Structure

```text
    ├── State Machine Core/         # Core Logic & Verification
    │   ├── Burglar_Alarm.v         # State machine core logic
    │   ├── Burglar_Alarm_tb.v      # Testbench for state machine logic
    │   ├── pin_checker.v           # PIN logic pattern (KEY2-KEY3-KEY1) 
    │   └── pin_checker_tb.v        # Testbench for PIN logic 
    ├── LCD DISPLAY/                # UI Assets & Screens
    │   ├── alarm_screen.v          # UI for Triggered state 
    │   ├── enter_pin_screen.v      # UI for PIN Entry state 
    │   ├── lockout_screen.v        # UI for Lockout state 
    │   └── success_screen.v        # UI for Success state 
    ├── Timers and 7 Segment/       # Hardware Outputs
    │   ├── clock_divider_1s.v      # 1Hz pulse generation
    │   ├── hex_to_7seg.v           # Decoder for HEX displays 
    │   └── timer_demo_top.v        # Test wrapper for timers 
    ├── Button Debouncer/           # Input Processing
    │   ├── Button_Debouncing.v     # Signal cleaning 
    │   └── Input_Router.v          # Signal distribution 
    |
    └── README.md
```
---
