                                                                                       
;                                                     ,-.             ,---,                 
;       ,---.                                     ,--/ /|   ,--,    .'  .' `\               
;      /__./|                   .--.            ,--. :/ | ,--.'|  ,---.'     \              
; ,---.;  ; |                 .--,`|  .--.--.   :  : ' /  |  |,   |   |  .`\  |  .--.--.    
;/___/ \  | |   ,--.--.       |  |.  /  /    '  |  '  /   `--'_   :   : |  '  | /  /    '   
;\   ;  \ ' |  /       \      '--`_ |  :  /`./  '  |  :   ,' ,'|  |   ' '  ;  :|  :  /`./   
; \   \  \: | .--.  .-. |     ,--,'||  :  ;_    |  |   \  '  | |  '   | ;  .  ||  :  ;_     
;  ;   \  ' .  \__\/: . .     |  | ' \  \    `. '  : |. \ |  | :  |   | :  |  ' \  \    `.  
;   \   \   '  ," .--.; |     :  | |  `----.   \|  | ' \ \'  : |__'   : | /  ;   `----.   \ 
;    \   `  ; /  /  ,.  |   __|  : ' /  /`--'  /'  : |--' |  | '.'|   | '` ,/   /  /`--'  / 
;     :   \ |;  :   .'   \.'__/\_: |'--'.     / ;  |,'    ;  :    ;   :  .'    '--'.     /  
;      '---" |  ,     .-./|   :    :  `--'---'  '--'      |  ,   /|   ,.'        `--'---'   
;             `--`---'     \   \  /                        ---`-' '---'                     
;                           `--`-'          
;	     _   _ _                     ______       ______ 
;	    | | | | |                    |  _  \      |  _  \
;	    | | | | |__   ___ _ __ ______| | | |______| | | |
;	    | | | | '_ \ / _ \ '__|______| | | |______| | | |
;	    | |_| | |_) |  __/ |         | |/ /       | |/ / 
;	     \___/|_.__/ \___|_|         |___/        |___/  
;
;						     
;
;
;		  __             _____ _____ _____   __ ___  ______ ________ _____ 
;		 / _|           |  __ \_   _/ ____| /_ |__ \|  ____/ /____  | ____|
;		| |_ ___  _ __  | |__) || || |       | |  ) | |__ / /_   / /| |__  
;		|  _/ _ \| '__| |  ___/ | || |       | | / /|  __| '_ \ / / |___ \ 
;		| || (_) | |    | |    _| || |____   | |/ /_| |  | (_) / /   ___) |
;		|_| \___/|_|    |_|   |_____\_____|  |_|____|_|   \___/_/   |____/  (c) 2021
; Squeezed in a couple more hours today, this is basically a public back-up :)
; If this got wiped, i doubt I'd bother starting from scratch again
                                                                    
                                                  
    LIST P=12F675
   #INCLUDE <P12F675.inc>
   
   ; Register  locations  20h-5Fh  are  GeneralPurpose registers, implemented as static RAM and are
   ; mapped  across  both  banks
   
   ; Defines for readability
   
   #DEFINE		    LED_TR		0x85,0;Pins - TRISIO Register BITs  (bank 1)
   #DEFINE		    DATA_TR		0x85,4 
   #DEFINE		    Reset_TR		0x85,3
   #DEFINE		    DriveLid_TR		0x85,2 
   #DEFINE		    BIOS_TR		0x85,5
   
   #DEFINE		    LED_GP		0x05,0 ;Pins - GPIO Register BITs   (bank 0)
   #DEFINE		    DATA_GP		0x05,4 
   #DEFINE		    Reset_GP		0x05,3 
   #DEFINE		    DriveLid_GP		0x05,2
   #DEFINE		    BIOS_GP		0x05,5
   
   
   ; Defines for bank switching with single words
   
   #DEFINE		    bank0		bcf 0x03,5
   #DEFINE		    bank1		bsf 0x03,5
   

   ; Defines for repeated instructions
   #DEFINE		    data_low		bcf 0x05,4 ;Data leg as output, low bit
   #DEFINE		    data_high		bsf 0x85,4 ;Data leg to input
   #DEFINE		    data_out		bcf 0x85,4 ;Data leg to output
   
   ; injection routine defines

   cblock 0x20
		; Defines for counter variables
   
	StringsTotal	    ; @20h	    Variable location for total string injections
	StringsDuring	    ; @21h	    Variable location for string injections during the BIOS patch (25)
	StringsPrior	    ; @22h	    Variable location for string injections prior to BIOS patch (4)
	CounterA	    ; @23h	    Counter variable locations for delays (using PICLOOPS)
	CounterB	    ; @24h	    now in cblock, previously all defined with manual RAM locations assigned (better for debugging)
	CounterC	    ; @25h
	CounterD	    ; @26h	
	
		; Defines for Injection stuff
		
		
	stringbyte  ; @27h 0x09 (half a byte)
	fullbcount  ; @28h Decimal 9, after first pass it will be at 8 (for full byte counter, bit by bit)
	
		
		; Defines for 'switch byte' counters
	
	byte2	    ; @29h	
	byte3	    ; @2Ah
	byte4	    ; @2Bh
	byte5	    ; @2Ch
	byte6	    ; @2Dh
	
	
	nextstring   ; @2Eh
   endc
   
   ; MPlab config bits for extra pin functionality settings, WDOG timer etc. (autogenerated by drop down selections)
   
    __CONFIG _FOSC_INTRCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _CP_OFF & _CPD_OFF
   
  ; Reset Vector
    
    ORG 0x00					     ;Begin @ start of PROG MEM
   
   
    ; Store integers @ FREG locations set above
   
    
    
    bsf	    byte2,1	; 000000010 = D'2'
    bsf	    byte3,1     ; load decimal '2' into  'switch byte' counters
    bsf	    byte4,1 
    bsf	    byte5,1 
    bsf	    byte6,1 
   
    bsf    nextstring,1 ; 6
    bsf    nextstring,2 ; 
   
   
   
   movlw    D'9'		; Full bit by bit byte counter
   movwf    fullbcount
    
   movlw    0x09		; Store first injection string byte in RAM
   movwf    stringbyte
   
   bsf	    StringsPrior,2	; Move 4 into this variable (@22h)
   	
   addlw    D'20'		; Add 20 to WREG	    (@21h)
   movwf    StringsDuring	; then move it into our Strings variable(is now equal to 29)
   
   addlw    D'50'		; Add 50 to WREG	    (@20h)
   movwf    StringsTotal	; then move it into our Strings variable(is now equal to 79)
   
   
   
   
   GOTO Setup
   
   
Setup				;   Pin Setup  [Page 19 Datasheet]
	

				; Set status register bank select bit @ 0x03h 0x83h (bank 0 / bank 1) 
				; "It is recommended, therefore, that only BCF,  BSF,SWAPF and MOVWF 
				; instructions are used to alter the STATUS  register,"
				; "bit 5 = RP0: Register Bank Select bit (used for direct addressing)
	bank0			; 0  = Bank 0 (bcf) (00h - 7Fh)	    1 = Bank 1 (bsf) (80h - FFh)"
	clrf    0x05		; Init GPIO
	movlw	B'111'		; move literal 07h/0B111 to WREG
	movwf	0x19		; Then move WREG contents to CMCON REG (turn off comparator)
				; byte @ 05h is  GPIO Register / 85h for corresponding TRISIO Register
				; set bits to '0' for output, '1' for input
				; 0  0  0  0  0  0  0  0
				;	5  4  3  2  1  GPIO     (GP3 is always an input)
				
	bank1			;	Sw to Bank 1  
	clrf    0X9F		;	init for Digital I/O
	movlw	0x3D		;	AKA move '00111101' to WREG then move 
	movwf	0X85		;	WREG contents to TRISIO reg (INPUT Pins: Pin5 / GP2
				;	for drivelid, Pin 7 / GP0 for LED status light, Pin 3 / GP4 DATA STARTS AS AN INPUT ('HIGH line')
				;	PIN  2 =BIOS / GP5 starts as an INPUT
			
			
	bank0			; SW to Bank 0 for GPIO control
	
	
	GOTO	inject ;FOR DEBUGGING to skip delay \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	GOTO	StartUpDelay		

	
	
	
	
DriveLidCheck
	
	
	
	
;LED SUBROUTINES************************************
LEDOFF				    
		bank1	
		bsf	LED_TR	    ; set LED pin as input
		return
		
LEDON	
		bank1
		bcf	LED_TR	    ; set LED pin as output
		bank0
		bcf	LED_GP	    ; set LED pin low (console provides 5v, modchip sinks)
;****************************************************	
		
	
	
	
	
	
	
;DELAY SUBROUTINES***********************************
		
bitdelay	;delay between bitS
		;PIC Time Delay = 0.00003800 s with Osc = 4000000 Hz
		
		rlf	stringbyte,1 ; rotate bytes bits left, bit 1 is now bit 0, then bit 2 is bit 0 etc.
		movlw	D'11'
		movwf	CounterA
bitloop		decfsz	CounterA,1
		goto	bitloop
		retlw	0
		return
	
		
	
stringdelay		
;PIC Time Delay = 0.16700100 s with Osc = 4000000 Hz
		
		
		
		;reset variables and store 1st injection byte back in 'stringbyte'
		bsf    nextstring,0 ; 5
		bsf    nextstring,2 ;
		
		movlw	0x95	    
		addwf	stringbyte
		
		bsf	    fullbcount,0 ;9
		bsf	    fullbcount,3
		
		bsf	    byte2,1	
		bsf	    byte3,1     ; load decimal '2' into  'switch byte' counters
		bsf	    byte4,1 
		bsf	    byte5,1 
		bsf	    byte6,1 
   
				
		;need to check drive lid status here after variables are all reset
		
		
		
		return ;ONLY FOR DEBUGGING TO SKIP DELAY \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
		
		movlw	D'217'
		movwf	CounterB
		movlw	D'224'
		movwf	CounterA
sloop		decfsz	CounterA,1
		goto	sloop
		decfsz	CounterB,1
		goto	sloop
		retlw	0
		return
;****************************************************	
		
		
		
				
;BIOS STUFF**********************************************************************************		
BIOSPATCH
		bank1				    ;Sw to bank 1 for TRISIO REG
		BCF	BIOS_TR			    ;Clear BIOS bit in TRISIO (now an output)
		bcf	BIOS_GP			    ;Make sure D2 is pulled low
		return	inject			    ;Jump back to Injection cycle
		
		
		
		
RELEASEBIOS
		bank1				    ;Sw to bank 1 for TRISIO REG
		BSF	BIOS_TR			    ;Set BIOS bit in TRISIO (now an input)
		return
;********************************************************************************************			
		
		
		
	
		
		
StartUpDelay
;PIC Time Delay = 3.80000400 s with Osc = 4000000 Hz
		movlw	D'20'
		movwf	CounterC
		movlw	D'72'
		movwf	CounterB
		movlw	D'1'
		movwf	CounterA
stloop		decfsz	CounterA,1
		goto	stloop
		decfsz	CounterB,1
		goto	stloop
		decfsz	CounterC,1
		goto	stloop
		retlw	0
		GOTO inject
    
		
resetfullbitcount
	movlw	D'9'	    ;reset bit counter (one additional for first dec pass)
	movwf	fullbcount
	return
		

	
	
	
	
	
	
	
;***************************************= INJECTION ROUTINE =******************************************************
inject			    ; SCEE: 1001 1010 1001 0011 1101 0010 1011 1010 0101 0111 0100
			    ; in Hex: 09     A9        3D        2B        A5        74
			    ; Bank1 for TRISIO to set input/ output 
			    ; Bank0 for GPIO to pull output low (unless it defaults to that when set?)
		
		decfsz	    StringsPrior,1	    ; decf by 1 x 4 , when zero apply BIOSPATCH
		goto	    _inject		    ; otherwise continue  to inject post
		call	    BIOSPATCH
		
_inject

		decfsz	    StringsDuring,1	    ; @21h - 25 string injections during BIOS patch + 4 for initial loops 
		goto	    Total
		call	    RELEASEBIOS		    ; which then goes backwards from 255 after '0' (no harm done, reset later)
		
Total		
		decfsz	    StringsTotal,1	    ; @20h - 79 total injections, when it hits '0' goto DriveLidStatus (stealth mode/ monitor)
		goto	    maininject
		goto	    DriveLidStatus
			    
maininject			       
		decfsz	    fullbcount,1
		goto	    continueinject
		goto	    setupnextbyte
continueinject
		call	    LEDON
		btfsc	    stringbyte,7 ; bit test FREG byte2, bit 7 (reads from MSB), skip if clear
		call	    highbit
		call	    lowbit
		
highbit
    bank1	    ;b1
    data_high	    ;release (make input)
    call bitdelay   
    goto inject
			    
lowbit
    bank1
    data_out	    ;make output
    bank0	    ;b0
    data_low	    ;pull
    call bitdelay
    goto inject
 
setupnextbyte
    
    ;***=next string injection setup=***
    decfsz  nextstring,1 ;dec 1 per byte x 5, when 0 is hit, call string delay
    goto    continue
    call    LEDOFF
    call    stringdelay
    goto    inject
    ;************************************
    
continue
    
    decfsz  byte2   ; dec 1, now contains 1, jump to _byte 2 and back to inject
    goto    _byte2  ; next cycle, dec 1 again, hits zero, jumps to _byte3 and back to inject
    
    
    decfsz  byte3   ; ***** 3Dh *****
    goto    _byte3  ; continue this algorithm through each byte of the injection string
    
    decfsz  byte4   ;***** 2Bh *****
    goto    _byte4
   
    
    decfsz  byte5   ;***** A5h *****
    goto    _byte5
    
    
    decfsz  byte6   ;***** 74h *****
    goto    _byte6
    goto    stringdelay
_byte2
    call    resetfullbitcount
    movlw   0xA9
    movwf   stringbyte
    goto    inject
_byte3
    bsf	    byte2,0 ; with each passing byte injection, set
    bsf	    byte3,0 ; the already completed 'switch byte' counters back to '1'
    call    resetfullbitcount
    movlw   0x3D
    movwf   stringbyte
    goto    inject
_byte4
    bsf	    byte2,0 ; so that they're skipped on further
    bsf	    byte3,0 ; passes, reset at string delay to initial values
    bsf	    byte4,0
    call    resetfullbitcount
    movlw   0x2B
    movwf   stringbyte
    goto    inject
_byte5
    bsf	    byte2,0
    bsf	    byte3,0
    bsf	    byte4,0
    bsf	    byte5,0
    call    resetfullbitcount
    movlw   0xA5
    movwf   stringbyte
    goto    inject
_byte6
    call    resetfullbitcount
    movlw   0x74
    movwf   stringbyte
    goto    inject
;*******************************************************************************************************************
    
    
    
    
    

DriveLidStatus
    
    end
