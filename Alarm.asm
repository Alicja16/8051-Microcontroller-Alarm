;TIMER 0
T0_G EQU 0 ;GATE
T0_C EQU 0 ;COUNTER/-TIMER
T0_M EQU 1 ;MODE (0..3)
TIM0 EQU T0_M+T0_C*4+T0_G*8

;TIMER 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/-TIMER
T1_M EQU 1 ;MODE (0..3)
TIM1 EQU T1_M+T1_C*4+T1_G*8

TMOD_SET EQU TIM0+TIM1*16

;50[ms] = 50 000[ŠS]*(11.0592[MHz]/12) = 46 080 cykli = 180 * 256

TH0_SET EQU 256-180
TL0_SET EQU 0
TH1_SET EQU 256-180
TL1_SET EQU 0

TIME EQU 30H
TIME_1 EQU 60H

    LJMP START
;-----------------------------------------------
    ORG 0BH
    LJMP T0_ISR
;-----------------------------------------------
    ORG 1BH
    LJMP T1_ISR
;-----------------------------------------------
	ORG 100H
START:
    MOV SP, #30h
    MOV TMOD,#TMOD_SET ;Timer 0 liczy czas
    MOV TIME, #20
    SETB EA

    LCALL LCD_CLR
    LCALL PRINT_HOURS
    LCALL ENTER_START_TIME
    ;hh:mm:ss
    ;R1:R2:R3
WAIT_NEXT:
    LCALL WAIT_KEY
    CJNE A, #14, WAIT_NEXT

    LCALL LCD_CLR
    LCALL PRINT_HOURS
    LCALL ENTER_ALARM_TIME
    ;hh:mm:ss
    ;R4:R5:R6

WAIT_ENT:
    LCALL WAIT_KEY
    CJNE A, #14, WAIT_ENT
    MOV TH0,#TH0_SET
    MOV TL0,#TL0_SET
    MOV TIME,#20
    SETB ET0
    SETB TR0 

MAIN_LOOP:
    SJMP MAIN_LOOP

STOP:
	SJMP $
	NOP
;-------------------INTERRUPTS-------------------
T0_ISR:
    MOV  TH0, #TH0_SET
    MOV  TL0, #TL0_SET
    DJNZ TIME, NO_1SEC
    MOV  TIME, #20
    LCALL CLOCK_CHANGE
    LCALL WRITE_CLOCK
    LCALL IF_ALARM
NO_1SEC:
    RETI
;-----------------------------------------------
T1_ISR:
    MOV  TH1, #TH1_SET
    MOV  TL1, #TL1_SET
    DJNZ TIME_1, NO_3SEC
    SETB P1.5
    SETB P1.7
    CLR ET1
    CLR TR1
NO_3SEC:
    RETI
;-------------------FUNCTIONS--------------------
PRINT_HOURS:
    MOV A,#'H'
    LCALL WRITE_DATA
    MOV A,#'H'
    LCALL WRITE_DATA
    MOV A,#':'
    LCALL WRITE_DATA
    MOV A,#'M'
    LCALL WRITE_DATA
    MOV A,#'M'
    LCALL WRITE_DATA
    MOV A,#':'
    LCALL WRITE_DATA
    MOV A,#'S'
    LCALL WRITE_DATA
    MOV A,#'S'
    LCALL WRITE_DATA
    RET
;-----------------------------------------------
ENTER_START_TIME:
    MOV R6,#0
LOOP:
    MOV A,#' '
    LCALL WRITE_DATA
    INC R6
    CJNE R6,#08, LOOP

    MOV R0,#01
    LCALL ENTER_NUMBER
    MOV A,#':'
    LCALL WRITE_DATA
    MOV R0,#02
    LCALL ENTER_NUMBER
    MOV A,#':'
    LCALL WRITE_DATA
    MOV R0,#03
    LCALL ENTER_NUMBER
    RET
;-----------------------------------------------
ENTER_ALARM_TIME:
    MOV A,#' '
    LCALL WRITE_DATA
    MOV A,#'A'
    LCALL WRITE_DATA
    MOV A,#'L'
    LCALL WRITE_DATA
    MOV A,#'A'
    LCALL WRITE_DATA
    MOV A,#'R'
    LCALL WRITE_DATA
    MOV A,#'M'
    LCALL WRITE_DATA
    MOV A,#' '
    LCALL WRITE_DATA
    MOV A,#' '
    LCALL WRITE_DATA
    
    MOV R0,#04
    LCALL ENTER_NUMBER
    MOV A,#':'
    LCALL WRITE_DATA
    MOV R0,#05
    LCALL ENTER_NUMBER
    MOV A,#':'
    LCALL WRITE_DATA
    MOV R0,#06
    LCALL ENTER_NUMBER
    RET
;-----------------------------------------------
ENTER_NUMBER:
    LCALL WAIT_KEY
    PUSH ACC
    LCALL WAIT_KEY
    PUSH ACC
    LCALL BCD
    MOV @R0,A
    LCALL WRITE_HEX
    RET
;-----------------------------------------------
BCD:
    POP 06H
    POP 07H
    POP B ; B=J
    POP ACC ; A=T
    ANL A, #0FH
    SWAP A ; TT00
    ANL B, #0FH 
    ORL A,B ; A=TTJJ
    PUSH 07H
    PUSH 06H
    RET
;-----------------------------------------------
CLOCK_CHANGE:
    MOV R0,#03
    CJNE R3,#01011001B, INC_H_M_S
    MOV R3,#00 ; R3 = 00
    MOV R0,#02
    CJNE R2,#01011001B, INC_H_M_S
    MOV R2,#00 ; R2 = 00
    MOV R0,#01
    CJNE R1,#00100011B, INC_H_M_S
    MOV R1,#00
    RET
;-----------------------------------------------
INC_H_M_S:
    MOV A, @R0
    ANL A, #0FH
    CJNE A, #09, ADD_ONE
    MOV A, @R0
    ANL A, #0F0H
    ADD A, #10H
    MOV @R0, A
    RET
ADD_ONE:
    INC @R0
    RET
;-----------------------------------------------
WRITE_CLOCK:
    LCALL LCD_CLR
    MOV A,R1
    LCALL WRITE_HEX
    MOV A,#':'
    LCALL WRITE_DATA
    MOV A,R2
    LCALL WRITE_HEX
    MOV A,#':'
    LCALL WRITE_DATA
    MOV A,R3
    LCALL WRITE_HEX
    RET
;-----------------------------------------------
IF_ALARM:
    MOV A, R4
    CLR C
    SUBB A, R1
    JNZ NOT_YET

    MOV A, R5
    CLR C
    SUBB A, R2
    JNZ NOT_YET

    MOV A, R6
    CLR C
    SUBB A, R3
    JNZ NOT_YET

    CLR P1.5
    CLR P1.7
    JB TR1, ALARM_ON
    MOV TH1,#TH1_SET
    MOV TL1,#TL1_SET
    MOV TIME_1,#60
    SETB ET1
    SETB TR1 
    RET
ALARM_ON:
    RET
NOT_YET:
    RET
;-----------------------------------------------