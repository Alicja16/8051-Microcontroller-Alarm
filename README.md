# 8051 Microcontroller Alarm Clock (LCD + Keypad + Timers) — DSM-51 Ready

An assembly project for 8051 implementing a fully functional Alarm Clock with real-time clock tracking, keypad input, LCD output, and interrupt-driven timing.

User enters current time and alarm time in the format HH:MM:SS, validated digit-by-digit.
The system uses Timer0 to generate precise 1-second ticks, and Timer1 to drive the alarm output.

> The same **`Alarm.hex`** runs in the **DSM-51 simulator** and on the **DSM-51 hardware board**.

---

## 📂 Repository contents

| File        | Description                                                                                               |
| ----------- | --------------------------------------------------------------------------------------------------------- |
| `Alarm.asm` | Main 8051 assembly source                                                                                 |
| `Alarm.hex` | Intel HEX firmware (ready for DSM-51 simulator & board)                                                   |
| `Alarm.lst` | Assembler **listing** (addresses, opcodes, decoded instructions, symbols) — useful for debugging/studying |

---

## 🟠 Features

* Two-digit decimal input for **hours**, **minutes**, and **seconds**
* Automatic range validation:
  * hours → `00–23`
  * minutes → `00–59`
  * seconds → `00–59`
* Keypad-based input:
  * **Simulator:** on-screen keypad or PC keyboard (digits 0–9)
  * **Hardware board:** physical numeric keypad
* All time components stored as packed **BCD `TTJJ`**
* Interrupt-driven architecture:
  * **Timer0** → precise 1-second real-time ticks  
  * **Timer1** → 3-second alarm state (LED/buzzer on P1.5, P1.7)
* LCD support:
  * Displays prompts for entering time
  * Shows formatted `HH:MM:SS`
  * Displays alarm time before the clock starts
* Alarm triggers when **current time matches alarm time**
* Robust balanced stack usage (`PUSH/POP`) — no `RET` corruption
* Extensive **indirect addressing (`@R0`)** for:
  * reading/writing R1–R6 time fields  
  * increment logic  
  * LCD output  
  * alarm comparison

---

## 🖼 Screenshots (DSM-51 Simulator)

### ⌨️ Entering alarm time (HH:MM:SS)
<p align="center">
  <img width="1056" height="594" alt="image" src="https://github.com/user-attachments/assets/91526330-5b4f-4d04-8e37-d0c2642c58e8" />
</p>

### 🚨 Alarm triggered (LED/buzzer active)
<p align="center">
  <img width="1056" height="594" alt="image" src="https://github.com/user-attachments/assets/5fe9900b-aff4-4ec3-886d-d86ce3bb95e4" />
</p>

---

## 🟠 Run in DSM-51 Simulator

1. Launch **DSM-51.EXE**  
2. *Load program* → select `Alarm.hex`  
3. **Run**  
4. Enter:
   * hours → 2 digits  
   * minutes → 2 digits  
   * seconds → 2 digits  
5. Press **E** (`14` on keypad)  
6. Enter alarm time  
7. Clock starts automatically  
8. Alarm activates when the current time matches the alarm time

---

## 🟠 Run on DSM-51 Hardware Board

1. Open **DSM51Ass** (or your DSM-51 loader/programmer).
2. Select **`Alarm.hex`** (Intel HEX) and upload to program memory.
3. Reset the board.
4. Enter current time on the physical keypad  
5. Enter alarm time  
6. LEDs/buzzer on **P1.5** and **P1.7** activate for ~3 seconds when alarm triggers  

---

## 🟠 Program flow

1. LCD prints a prompt for `HH:MM:SS`  
2. User enters 6 digits  
3. LCD prints a prompt for alarm time  
4. Timer0 generates 1-second increments  
5. Clock updates seconds, minutes, hours (BCD)  
6. Alarm comparisons run inside the Timer0 ISR  
7. Timer1 handles alarm duration  

---

## 🛠️ Build (optional)

A ready **`.hex`** is provided. To rebuild, use DSM51Ass, or SDCC’s 8051 tools (e.g. `sdas8051`).

---

## 🟠 Limitations & ideas

* No backspace or correction during input  
* No snooze  
* Possible enhancements:
  * snooze mode  
  * multiple alarms  
  * 12h/24h switch  
  * EEPROM storage  

---

## Author

**Alicja P.** — educational project for the **DSM-51** 8051 training system.

---

## 📦 Release

**v1.0.0 — Initial DSM-51 Release**

* Full HH:MM:SS entry with validation  
* Real-time clock via Timer0  
* Alarm via Timer1 (LED/buzzer)  
* Packed BCD time representation  
* Safe and clean stack usage
  
**Artifacts:** `Alarm.hex`, `Alarm.asm`, `Alarm.lst`
