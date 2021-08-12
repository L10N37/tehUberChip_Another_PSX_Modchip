; VAJSKIDS CONSOLES 2021 - UBER-D-D WIP
; WORK IN PROGRESS!! have being poking away here and there when I get time. Took me quite a few hours of thinking and googling to come up with an alternate algorithm
; to manually switching back and forth banks, changing pins from inputs to outputs etc etc to something a little nicer like this.
; Just confirmed it as working nicely in a debugger, will have to use the algorithm byte and use variables to count each bit to know when to jump to the next byte 
; and continue
; For pure back-up purposes only - and a lot more work to go
; no prior experience in assembly or anything at all, so this doesn't just 'come to me'


 LIST P=12F675
   #INCLUDE <P12F675.inc>
   
   ; Register  locations  20h-5Fh  are  GeneralPurpose registers, implemented as static RAM and are
   ; mapped  across  both  banks
   
   ; Defines for readability
   
   #DEFINE		    LED_TR		0X85,0;Pins - TRISIO Register BITs
   #DEFINE		    DATA_TR		0X85,4 
   #DEFINE		    Reset_TR		0X85,3
   #DEFINE		    DriveLid_TR		0X85,2 
   #DEFINE		    BIOS_TR		0x85,5
   
   #DEFINE		    LED_GP		0X05,0 ;Pins - GPIO Register BITs
   #DEFINE		    DATA_GP		0X05,4 
   #DEFINE		    Reset_GP		0X05,3 
   #DEFINE		    DriveLid_GP		0X05,2
   #DEFINE		    BIOS_GP		0x05,5
   
   ; Defines for bank switching with single words
   
   #DEFINE		    bank0		bcf 0x03,5
   #DEFINE		    bank1		bsf 0x03,5
   

   ; Defines for repeated instructions
   #DEFINE		    data_low		bcf 0x05,4 ;Data leg as output, low bit
   #DEFINE		    data_high		bsf 0x85,4 ;Data leg to input
   #DEFINE		    data_out		bcf 0x85,4 ;Data leg to output
   
   ; injection routine defines
			    ; SCEE: 1001 1010 1001 0011 1101 0010 1011 1010 0101 0111 0100
			    ; in Hex: 09     A9        3D        2B        A5        74
   cblock 0x20
		; Defines for counter variables
   
	StringsPost	    ; @20h	    Variable location for string injections post BIOS patch (50
	StringsDuring	    ; @21h	    Variable location for string injections during the BIOS patch (25)
	StringsPrior	    ; @22h	    Variable location for string injections prior to BIOS patch (4)
	CounterA	    ; @23h	    Counter variable locations for delays (using PICLOOPS)
	CounterB	    ; @24h	    now in cblock, previously all defined with manual RAM locations assigned (better for debugging)
	CounterC	    ; @25h
	CounterD	    ; @26h	
	
		; Defines for Injection stuff
		
	compare	    ; @27h '10000000'
	compare1    ; @28h '00001000'
	byte1	    ; @29h 0x09 (half a byte)
   	byte2	    ; @2Ah 0xA9
	byte3	    ; @2Bh 0x3D
	byte4	    ; @2Ch 0x2B
	byte5	    ; @2Dh 0xA5
	byte6	    ; @2Eh 0x74
	
   endc
   
   ; MPlab config bits for extra pin functionality settings, WDOG timer etc. (autogenerated by drop down selections)
   
    __CONFIG _FOSC_INTRCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _CP_OFF & _CPD_OFF ;from config bit setup
   
  ; Reset Vector
    
    ORG 0x00					     ;Begin @ start of PROG MEM
   
   
  
    ; Store integers @ FREG locations set above
   
   movlw    B'10000000'		; set up compare FREG
   movwf    compare
   
   
   movlw    B'00001000'		; set up compare1 FREG for first half byte of string
   movwf    compare1
   
   
   movlw    0xA9
   movwf    byte2		; Store injection string Byte 2 in RAM
   
   
   movlw    D'4'		; Move the decimal number 76 into WREG
   movwf    StringsPrior	; then move it into our Strings variable(is now equal to 4)
   		
   
   movlw    D'25'		; Move the decimal number 76 into WREG
   movwf    StringsDuring	; then move it into our Strings variable(is now equal to 25)
   
   
   movlw    D'50'		; Move the decimal number 76 into WREG
   movwf    StringsPost		; then move it into our Strings variable(is now equal to 50)
   
   
   
   
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
	
	
	GOTO	inject ;FOR DEBUGGING to skip start delay
	
	GOTO	StartUpDelay		

	
	
	
	
DriveLidCheck
	return
	
	
	
	
	
	
	
	
;DELAY SUBROUTINES***********************************
	
bitdelay	;delay between bitS
		;PIC Time Delay = 0.00003800 s with Osc = 4000000 Hz
		
		rlf	byte2,1 ; rotate bytes bits left, bit 1 is now bit 0, then bit 2 is bit 0 etc.
		movlw	D'11'
		movwf	CounterA
bitloop		decfsz	CounterA,1
		goto	bitloop
		retlw	0
		return
	
		
	
stringdelay		
;PIC Time Delay = 0.16700100 s with Osc = 4000000 Hz
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
		
PATCH_COUNT				  ; F REGS available in both banks
		DECFSZ	StringsDuring,1	  ; decrement during BIOS patch injection counter
		return			  ; then return where called , unless counter hits zero
		movlw	H'FF'		  ; counter hit zero, stick max value
		movwf	StringsPrior	  ; in strings counter variable (is bios patch even needed for multiple discs when video modes already set?)
		GOTO	inject		  ; .. it's a high/ arbitary number so we don't hit zero again on the next inject run
					  ; then jump back for final 50 injections
		
		
BIOSPATCH
		bank1				    ;Sw to bank 1 for TRISIO REG
		BCF	BIOS_TR			    ;Clear BIOS bit in TRISIO (now an output)
		bcf	BIOS_GP			    ;Make sure D2 is pulled low
		GOTO	inject			    ;Jump back to Injection cycle
		
		
		
		
RELEASEBIOS
		bank1				    ;Sw to bank 1 for TRISIO REG
		BSF	BIOS_TR			    ;Set BIOS bit in TRISIO (now an input)
		return
		
		
		
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
    
 
		
		
;***********************************************************************************************************
inject			  
			    ;Bank1 for TRISIO to set input/ output 
			    ;Bank0 for GPIO to pull output low (unless it defaults to that when set?)
		
		
		
		btfsc	byte2,7 ; bit test FREG byte2, bit 7 (reads from MSB), skip if clear
		call	highbit
		call	lowbit
		
		
		
		
		
		
		goto inject
		goto highbit			    
		goto lowbit	    
			    
highbit
    bank1
    data_high
    call bitdelay
    goto inject
			    
lowbit
    bank1
    data_out	    ;output
    bank0	    ;bo
    data_low
    call bitdelay
    goto inject
    
		
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
DriveLidStatus
		
    END
