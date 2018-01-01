; LE 22/08/1997
; Edited with PFE and assembled with MPASM
; alain.fort.f1cjn@orange.fr
; 5*7 new routines 
; 7 characters visible scrolling long text on upper line, yes the pic do it !
; 8 Grey level bars in the middle of the screen
; 4 digits clock in the bottom 
; setup of the clock with two push buttons
; the 625 lines TV screen looks like this
; By Alain FORT and Peter KNIGHT 
; Free for public domain by Internet
;
;			  *************
;			  *  T E X T  * this line is scrolling to the left
;			  * grey bars *
;			  *   12:00   *    (This is the clock)
;			  *************
;
; 

	TITLE	"PICDREAM"

	LIST	P=16C84


#Define	W	0
#Define	F	1

	cblock	0x00
		INDF,RTCC,PCL,Status,FSR,PortA,PortB
	endc
	cblock	0x08
		EEData,EEAdr,PClath,IntCon
	endc

	cblock	0x00
		C,DC,Z,PD,TO,RP0,RP1,IRP
	endc

; Page 1 registers
Roption	EQU	01H
TrisA	EQU	05H
TrisB	EQU	06H
RAMbase	EQU	0CH


#define	Sync	PortA,0  ; Synchro out at RA0  (PIN 17)

; DNOP - Double NOP. Delay of 2 cycles, takes only one instruction

DNOP	MACRO
	LOCAL	Label
Label	GOTO	Label+1
	ENDM

; Delay3W - Delay 3 * W cycles, three instructions

Delay3W	MACRO
	LOCAL	Label
	MOVWF	Delay		
Label	DECFSZ	Delay
	GOTO	Label
	ENDM

SKIPCC	MACRO
	BTFSC	Status,C
	ENDM

SKIPNZ	MACRO
	BTFSC	Status,Z
	ENDM

	LIST

	CBLOCK	RAMbase
		Delay,Count,Count2,Count3,SubSec	; 5 various registers
		HrT,HrU,MiT,MiU,SeU			; 5 clock registers 
		CA0,CA1,CA2,CA3,CA4,CA5,CA6 		; 6 caracters pointers
		Ta0,Ta1,Ta2,Ta3,Ta4,Ta5,Ta6,TNB,TNB1  	; 7 caracter lines pointers
		Ptrtxt					; 1 text pointer	
	ENDC

	ORG	0
	GOTO	Main

	ORG	4
	RETURN

; Table of caracters

Table	ADDWF	PCL,F
Tbase	equ	$
Car0	equ	$-Tbase
CarO	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
Car1	equ	$-Tbase
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001100'	; ....**..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001110'	; ....***.
Car2	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001000'	; ....*...
	RETLW	B'00011111'	; ...*****
Car3	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001' 	;....*...*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000110'	; .....**.
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
Car4	equ	$-Tbase
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000110'	; .....**.
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00010010'	; ...*..*.
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000010'	; ......*.
Car5	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011110'	; ...****.
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
Car6	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
Car7	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
Car8	equ	$-Tbase
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001110'	; ....***.
Car9	equ	$-Tbase
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001111'	; ....****
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.	
;B0  	D'70'
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00001000'	; ....*...
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000010'	; ......*.
;B3  	D'75'
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001000'	; ....*...
CarSP	equ	$-Tbase
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
CarA	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011111'	; ...*****
CarH	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011111'	; ...*****
CarU	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	;.....***.
CarD	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarB	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarP	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011110'	; ...****.
CarL	equ	$-Tbase
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarE	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011100'	; ...***..
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarF	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011100'	; ...***..
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarJ	equ	$-Tbase
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
CarG	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010011'	; ...*..**
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarQ	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010011'	; ...*..**
CarS	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00001110'	; ....***.
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
CarC	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010001'	; ...*...*
CarI	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001110'	; ....***.
CarK	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010010'	; ...*..*.
	RETLW	B'00010100'	; ...*.*..
	RETLW	B'00011000'	; ...**...
	RETLW	B'00010100'	; ...*.*..
	RETLW	B'00010010'	; ...*..*.
CarM	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011011'	; ...**.**
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarN	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011001'	; ...**..*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010011'	; ...*..**
CarY	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
CarR	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011110'	; ...****.
CarV	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarX	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001010'	; ....*.*.
CarW	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00011011'	; ...**.**
	RETLW	B'00010001'	; ...*...*
CarZ	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00000001'	; ...... *
	RETLW	B'00000010'	; ..... *.
	RETLW	B'00000100'	; .... *..
	RETLW	B'00001000'	; ....*...
	RETLW	B'00010000'	; ...*....
CarT	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..

Main
	BSF	Status,RP0	;  adressing bank 1
	MOVLW	B'11110'
	MOVWF	TrisA
	MOVLW	B'11000000'
	MOVWF	TrisB		; ports B as outputs except  RB7 and RB6
	BCF	Roption,7	; we need the integrated pull-up resistors
	BCF	Status,RP0	; adressing bank 0 for the rest of the program

	CLRF	SeU	;Initialisation clock at 00.00
	CLRF	MiU
	CLRF	MiT
	CLRF	HrU
	CLRF	HrT
	CLRF	Count3

; Frame starts here.
;
; Frame must be exactly 312.5 Lignes long, each Ligne 64 cycles.
; That ensures frame rate of exactly 50Hz to crystal accuracy.

;5 Long Equalisation pulses

Frame				;Main Loop
	BCF	Sync		; 1		;30us Sync
	DNOP			; 3
	MOVLW	4		; 4
	MOVWF	Count		; 5
Loop1	MOVLW	8		; 6  6
	Delay3W			;30 30
	BSF	Sync		;31 31	;2us Black
	NOP			;32 32
	BCF	Sync		; 1  1	;30us Sync
	NOP			; 2  2
	DECFSZ Count		; -  -
	GOTO	Loop1		; 5
	MOVLW	8		;    5
	Delay3W			;   29
	NOP			;   30
	BSF	Sync		;   31	;2us Black
	NOP			;   32

; Now 5 short equalisation pulses, 4 on interlace

	BCF	Sync		; 1	;2us Sync
	NOP			; 2
	BSF	Sync		; 3	;30us Black
	MOVLW	4		; 4
	BTFSC	SubSec,0	;	; 3 on interlace (SubSec odd)
	MOVLW	3		; 6
	MOVWF	Count		; 7
Loop2	MOVLW	8		; 8  8  8  8
	Delay3W			;32 32 32 32
	BCF	Sync		; 1  1  1  1	;2us Sync
	NOP			; 2  2  2  2
	BSF	Sync		; 3  3  3  3	;30us Black
	NOP			; 4  4  4  4
	DECFSZ Count		; -  -  -  -
	GOTO	Loop2		; 7  7  7
	CLRF	TNB		;          7   RAZ de TBN a chaque trame
	MOVLW	8		;          8
	Delay3W			;         32
		

; 304 visible Lines

; 41 black Lines 
	BCF	Sync		; 1
	MOVLW	D'41'		; 2
	CALL	BlkLns		;64

; ****     INIT TEXTE ******   line  42

	BCF 	Sync
	Call 	Preptxt3

; ****    INIT TEXTE CONTINUED ****** line 43

	BCF 	Sync
	Call 	Preptxt4

;********** DISPLAY TEXTE ********* ( + 60 lines) = 103

	BCF	Sync		; 1
	CALL	DisTxt		;64

; 15 black lines = 118

	BCF	Sync		; 1
	MOVLW	D'15'		; 2
	CALL	BlkLns		;64

; ***** GREY BARS ***** 60 lines = 178

	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64 ligne 10
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64 Line 20
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64 Line 30
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64 Line 40
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64 Line 50
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64
	BCF Sync		;1
	CALL BARRE		;64  

;*****  14  BLACK LINES =192  *****
	BCF	Sync		; 1
	MOVLW	D'14'		; 2
	CALL	BlkLns		;64

;*****  KEYS TEST 1 line = 193 *****
	BCF	Sync		; 1	Line 54
	CALL	TOUCHE		;64

;***** PREPARE CLOCK    =  194 *****
	BCF	Sync		; 1	Line 54
	CALL	PREPH		;64

;***** DISPLAY CLOCK 	= 254  ***** (this takes 60 Lignes)
	BCF	Sync
	CALL	DisTxt

;Increment time
	BCF	Sync		;1
	INCF	SubSec		;2	Increment 1/50th sec
	MOVLW	-D'50'		;3
	ADDWF	SubSec,W	;4	Carry now set if second has expired
	BSF	Sync		;5
	SKIPCC			;6	Zero SubSec if =50
	CLRF	SubSec		;7
	SKIPCC			;8
	INCF	SeU		;9	And increment Second Units
	SKIPCC			;10
	NOP			;11 	seconds counter modulo 256
	MOVLW	-D'60'		;12
	ADDWF	SeU,W		;13	Carry if needed Second Units->Tens
	SKIPCC			;14
	CLRF	SeU		;15
	SKIPCC			;16
	INCF	MiU		;17	Minutes Units
	MOVLW	-D'10'		;18
	ADDWF	MiU,W		;19
	SKIPCC			;20
	CLRF	MiU		;21
	SKIPCC			;22
	INCF	MiT		;23	Minutes tens
	MOVLW	-D'6'		;24
	ADDWF	MiT,W		;25
	SKIPCC			;26
	CLRF	MiT		;27
	SKIPCC			;28
	INCF	HrU		;29
	MOVLW	-D'10'		;30
	ADDWF	HrU,W		;31 
	SKIPCC			;32
	CLRF	HrU		;33
	SKIPCC			;34
	INCF	HrT		;35
	MOVF	HrU,W		;36  Now check for Hours=24
	BTFSC	HrT,0		;37
	ADDLW	D'10'		;38  
	BTFSC	HrT,1		;39
	ADDLW	-D'4'		;40
	SKIPCC			;41
	CLRF	HrU		;42 clear hours units
	SKIPCC			;43
	CLRF	HrT		;44 clear hours tens
	MOVLW	D'6'		;45         
	Delay3W			;63

; *****  489 BLACK LINES = 304 *****
	BCF	Sync		; 1		;5us Sync
	MOVLW	D'49'		; 2
	CALL	BlkLns		; 64

; insert half Ligne here on interlace

; Now 5 short equalisation pulses
; prefixed by half video Ligne on interlace

; Slight bodge of CCIR/PAL - the half Ligne segment is actually a short eq pulse
	BCF	Sync		; 1		;2us Sync
	NOP			; 2
	BSF	Sync		; 3		;30us Black
	MOVLW	4		; 4
	BTFSS	SubSec,0	; -
	MOVLW	5		; 6
	MOVWF	Count		; 7
Loop6	MOVLW	8		; 8  8  8  8
	Delay3W			;32 32 32 32
	BCF	Sync		; 1  1  1  1 ; 2us Sync
	NOP			; 2  2  2  2
	BSF	Sync		; 3  3  3   	; 30us Black
	NOP			; 4  4  4  4
	DECFSZ	Count		; -  -  -  -
	GOTO	Loop6		; 7  7  7
	MOVLW	7		;          7
	Delay3W			;         28
	DNOP			;         30
	GOTO	Frame		;         32

; Delay routines

Delay6	NOP
Delay5	NOP
Delay4	RETURN

; Some black Lignes
BlkLns	ADDLW	-1
	BSF	Sync		; 1		;59us black
	MOVWF	Count
	DNOP			; 1
Loop5	MOVLW	D'17'		; 1  1  1  1
	MOVWF	Delay		; 1  1  1  1
LoopD9	DECFSZ	Delay		;18 18 18 18
	GOTO	LoopD9		;32 32 32 32
	NOP			; 1  1  1  1
	DNOP			; 2  2  2  2
	BCF	Sync		; 1  1  1  1	;5us Sync
	CALL	Delay4		; 4  4  4  4
	BSF	Sync		; 1  1  1  1	;59us Black
	DECFSZ	Count		; 1  1  1  2
	GOTO	Loop5		; 2  2  2
	NOP			;          1
	MOVLW	D'17'		;          1
	Delay3W			;         51
	NOP			;          1
	RETURN			;          2


;Display
; Call immediately after BCF Sync, takes 60 Ligne periods

DisTxt	DNOP			; 5	;Ligne 1 noire
	BSF	Sync		; 6
	MOVLW	D'19'		; 7    delai=57
	Delay3W			;64
	BCF	Sync		; 1	lignes 2 et 3 noires
	MOVLW	D'2'		; 2
	CALL	BlkLns		;64
	BCF	Sync		; 1	Ligne 4 au noir , +1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 5
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 6  
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 7  
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 8 
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 9 
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 10 
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 11 
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 12 is black, + 1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 13
	CALL	Showline	;64	
	BCF	Sync		; 1	Ligne 14
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 15
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 16
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 17
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 18
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 19
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 20 is black, +1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 21
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 22
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 23
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 24
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 25
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 26
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 27
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 28 is black,+1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 29
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 30
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 31
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 32
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 33
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 34
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 35
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 36 is black, +1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 37
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 38
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 39
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 40
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 41
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 42
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 43
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 44 is black, +1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 45
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 46
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 47
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 48
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 49
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 50
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 51
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 52 is black, +1 for caracters line
	CALL	INCLIN		;64
	BCF	Sync		; 1	Ligne 53
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 54
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 55
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 56
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 57
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 58
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 59
	CALL	Showline	;64
	BCF	Sync		; 1	Ligne 60
	GOTO	Showline	;64


Showline MOVF	TNB1,W		; 4  old TNB (without plus one)
	ADDWF	CA6,W		; 5  Incline (continued), seventh caracter preparation
	BSF	Sync		; 6
	CALL 	Table		;12
	MOVWF	Ta6		;13
	MOVF	Ta0,W		;15 Carac 1
	MOVWF	PortB		;16  
	RLF	PortB		;18
	RLF	PortB		;19
	RLF	PortB		;20
	RLF	PortB		;21
	CLRF	PortB		;22
	MOVF	Ta1,W		;23 Carac 2
	MOVWF	PortB		;24
	RLF	PortB		;25
	RLF	PortB		;26
	RLF	PortB		;27
	RLF	PortB		;28
	CLRF	PortB		;29
	MOVF	Ta2,W		;30 Carac 3
	MOVWF	PortB		;31
	RLF	PortB		;32
	RLF	PortB		;33
	RLF	PortB		;34
	RLF	PortB		;35
	CLRF	PortB		;36
	MOVF	Ta3,W		;37 Carac 4
	MOVWF	PortB		;38  
	RLF	PortB		;39
	RLF	PortB		;40
	RLF	PortB		;41
	RLF	PortB		;42
	CLRF	PortB		;43
	MOVF	Ta4,W		;44 Carac 5
	MOVWF	PortB		;45
	RLF	PortB		;46
	RLF	PortB		;47
	RLF	PortB		;48
	RLF	PortB		;49
	CLRF	PortB		;50
	MOVF	Ta5,W		;51 Carac 6
	MOVWF	PortB		;50
	RLF	PortB		;51
	RLF	PortB		;52
	RLF	PortB		;53
	RLF	PortB		;54
	CLRF	PortB		;55 Put 0 ( black video between 2 caracters)
	MOVF	Ta6,W		;56 Carac 7
	MOVWF	PortB		;57  
	RLF	PortB		;58
	RLF	PortB		;59
	RLF	PortB		;60
	RLF	PortB		;61
	CLRF	PortB		;62 Ouf! no more room for any NOP
	RETURN			;64

Preptxt3  DNOP			; 5	
	BSF	Sync		; 6
	MOVF	SubSec,w	; 7
	ANDLW	B'00000001'	; 8
	SKIPNZ			; 9
	GOTO	GT4		; 10/11	
	MOVLW	D'16'		; 11
	ADDWF	Count3		; 12
	SKIPNZ			; 13
	INCF	Ptrtxt		; 14
	GOTO 	GT5		; 16
GT4	CALL	Delay4		; 15
	NOP			; 16
GT5 	MOVLW   HIGH Texte	; 17	prepare to read the text page at 3C0
	MOVWF	PClath		; 18 	
	MOVF	Ptrtxt,W	; 19	first caracter
	CALL	Texte		; 25
	MOVWF	CA0		; 26
	INCF	Ptrtxt		; 27
	MOVF	Ptrtxt,W	; 28	Second caracter
	CALL	Texte		; 34
	MOVWF	CA1		; 35
	INCF	Ptrtxt		; 36
	MOVF	Ptrtxt,W	; 37	Third caracter
	CALL	Texte		; 43
	MOVWF	CA2		; 44
	INCF	Ptrtxt		; 45	
	MOVF	Ptrtxt,W	; 46	Fourth caracter
	CALL	Texte		; 52
	MOVWF	CA3		; 53
	INCF	Ptrtxt		; 54
	MOVLW	D'2'		; 55  
	Delay3W			; 61	equ 6 cycles			
	NOP			; 62 
	RETURN			; 64

Preptxt4  DNOP			; 5	
	BSF	Sync		; 6
	MOVF	Ptrtxt,W	; 7	Fith caracter
	CALL	Texte		;13
	MOVWF	CA4		;14
	INCF	Ptrtxt		;15	
	MOVF	Ptrtxt,W	;16	Sixth caracter
	CALL	Texte		;22
	MOVWF	CA5		;23 

	INCF	Ptrtxt		;24	
	MOVF	Ptrtxt,W	;25	Seventh caracter
	CALL	Texte		;31
	MOVWF	CA6		;32       

	MOVLW	D'7'		; 33  
	Delay3W			; 54   equ 21

	MOVLW	-D'6'		; 55   plus 6 for a one caracter shift
	ADDWF	Ptrtxt		; 56   voila 
	MOVF	Ptrtxt,W	; 57   
	ADDLW	-(FTexte-DTexte); 58 compar to text length
	SKIPCC			; 59
	CLRF	Ptrtxt		; 60 RAZ text pointer if end of scroll
	CLRF 	PClath		; 61 RAZ PClath for reading lire caracters table page at page 0	
	CLRF	TNB		; 62 TNB initialisation
	RETURN			; 64	
			

INCLIN	MOVF	TNB,W		; 4  Computing the table input adress 
	MOVWF	TNB1		; 5
	BSF	Sync		; 6  and store in  Ta0 to Ta5 registers
	NOP			; 7 
	MOVF 	TNB,W		; 8	
	ADDWF	CA0,W		; 9   Add TNB to result
	CALL 	Table		; 15  Call line number NB
	MOVWF	Ta0		; 16  Table in TA0
	MOVF 	TNB,W		; 17	
	ADDWF	CA1,W		; 18
	CALL 	Table		; 24
	MOVWF	Ta1		; 25
	MOVF 	TNB,W		; 26	
	ADDWF	CA2,W		; 27
	CALL 	Table		; 33
	MOVWF	Ta2		; 34
	MOVF 	TNB,W		; 35	
	ADDWF	CA3,W		; 36
	CALL 	Table		; 42
	MOVWF	Ta3		; 43
	MOVF 	TNB,W		; 44	
	ADDWF	CA4,W		; 45
	CALL 	Table		; 51
	MOVWF	Ta4		; 52 
	MOVF 	TNB,W		; 53 
	ADDWF	CA5,W		; 54 
	CALL 	Table		; 60 
	MOVWF	Ta5		; 61 
	INCF	TNB		; 62  the (Ta6) is in the Showline routine !!
	RETURN			; 64

PREPH	DNOP			; 5	Clock 
	BSF	Sync		; 6
	BCF 	Status,C	; 7

	MOVLW	D'80'		; 8 First caracter is space (black)
	MOVWF	CA0		; 9  

	MOVF	HrT,W		; 10  Hours Tens 
	MOVWF	CA1		; 11
	RLF	CA1		; 12  multiply by 7 for table access
	RLF	CA1		; 13  
	ADDWF	CA1		; 14
	ADDWF	CA1		; 15
	ADDWF	CA1		; 16

	MOVF	HrU,W		; 17  Heures Units
	MOVWF	CA2		; 18
	RLF	CA2		; 19  multiply by 7 for table access
	RLF	CA2		; 20
	ADDWF	CA2		; 21
	ADDWF	CA2		; 22
	ADDWF	CA2		; 23

	MOVLW 	D'70'		; 24
	BTFSC	SeU,0		; 25 parity test for seconds
	ADDLW	D'5'		; 26
	MOVWF	CA3		; 27 result = 70 or 75

	MOVF	MiT,W		; 28 Minutes Tens
	MOVWF	CA4		; 29
	RLF	CA4		; 30 multiply by 7 for table access
	RLF	CA4		; 31
	ADDWF	CA4		; 32
	ADDWF	CA4		; 33
	ADDWF	CA4		; 34

	MOVF	MiU,W		; 35 Minutes Units
	MOVWF	CA5		; 36
	RLF	CA5		; 37 multiply by 7 for table access
	RLF	CA5		; 38
	ADDWF	CA5		; 39
	ADDWF	CA5		; 40
	ADDWF	CA5		; 41

	MOVLW	D'80'		; 42
	MOVWF	CA6		; 43 Last caracter is a space

	MOVLW	D'5'		; 44
	Delay3W			; 59 eq (15)
	
	DNOP			; 61
	CLRF	TNB		; 62
	RETURN			; 64

BARRE	DNOP			; 5	Grey for outputs RA1 RA2 RA3
	BSF	Sync		; 6
	MOVLW	B'10000'	; 7    Outputs Activation RA1 RA2 RA3 on portA
	TRIS	PortA		; 8  	
	MOVLW	D'1'		; 9    Only even numbers (for sync='1')
	MOVWF	PortA		; 10
	CALL 	Delay4		; 14
	CALL 	Delay4		; 18
	MOVLW	D'3'		; 
	MOVWF	PortA		;   
	CALL 	Delay4		; 24
	MOVLW	D'5'		; 
	MOVWF	PortA		;   
	CALL	Delay4		; 30
	MOVLW	D'7'		;
	MOVWF	PortA		; 
	CALL 	Delay4		; 36
	MOVLW	D'9'		;
	MOVWF	PortA		; 
	CALL	Delay4		; 42
	MOVLW	D'11'		;
	MOVWF	PortA		; 
	CALL	Delay4		; 48
	MOVLW	D'13'		;
	MOVWF	PortA		; 
	CALL	Delay4		; 54
	MOVLW	D'15'		; 55
	MOVWF	PortA		; 56
	CALL	Delay4		; 60
	MOVLW	B'11110'	; 61 Ouput in tristate (except sync) on Port A
	TRIS	PortA		; 62
	RETURN			; 64

TOUCHE
	DNOP			;5
	BSF Sync		;6
	MOVF	PortB,w		;7	reading PortB
	XORLW	B'11111111'	;8	compare with before which was '1' due to the pull-up loads
	ANDLW	B'11000000'	;9      mask for RB7 et RB6
	BTFSC	Status,Z	;10	zero set=no buttons
	GOTO	RT2		;12	out if no key press	
	INCFSZ 	Count2		;13	delay (with frame counter) if a key at 1
	GOTO 	RT1		;15
	BTFSC	PortB,7		;15	minutes button test
	INCF	MiU		;16
	BTFSC	PortB,6		;17	hours button test
	INCF	HrU		;18
	MOVLW	D'236'		;19	Wait a while
	MOVWF 	Count2		;20
	GOTO	RT3		;22		
RT2	MOVLW	D'236'		;13	
	MOVWF	Count2		;14
RT1	CALL Delay4		;18	
	CALL Delay4		;22
RT3	MOVLW	D'13'		;23
	Delay3W			;62
	return			;64

	Org	3A0

Texte	ADDWF	PCL,F
DTexte	equ	$
	RETLW	CarSP	; 1  LENGTH = 95 MAXIMUM (characters plus space)
	RETLW	CarSP	; 2
	RETLW	CarSP	; 3
	RETLW	CarSP	; 4
	RETLW	CarSP	; 5  
	RETLW	CarSP	; 6  *** do not modify the first 6 SP characters **
	RETLW	CarB	; 7
	RETLW	CarA	; 8
	RETLW	CarT	; 9
	RETLW	CarC	;10
	RETLW	CarSP	;
	RETLW	CarP	; 
	RETLW	CarI	;  
	RETLW	CarC	;
	RETLW	CarD
	RETLW	CarR
	RETLW	CarE
	RETLW	CarA
	RETLW	CarM
	RETLW	CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW	CarSP
	RETLW	CarSP
	RETLW	CarSP
	RETLW	CarSP	
FTexte	equ	$-6	; necessairy for scrolling 7 caracters on the screen
	RETLW	CarSP

	END


