╔╗░╔╦══╗╔═══╦═══╦═══╦╗░╔╦══╦═══╗░░░░░░░░░░░░░░░░░░░░░░░░░
║║░║║╔╗║║╔══╣╔═╗║╔═╗║║░║╠╣╠╣╔═╗║░░░░░░░░░░░░░░░░░░░░░░░░░
║║░║║╚╝╚╣╚══╣╚═╝║║░╚╣╚═╝║║║║╚═╝║░░░░░░░░░░░░░░░░░░░░░░░░░
║║░║║╔═╗║╔══╣╔╗╔╣║░╔╣╔═╗║║║║╔══╝░░░░░░░░░░░░░░░░░░░░░░░░░
║╚═╝║╚═╝║╚══╣║║╚╣╚═╝║║░║╠╣╠╣║░░░░░░░░░░░░░░░░░░░░░░░░░░░░
╚═══╩═══╩═══╩╝╚═╩═══╩╝░╚╩══╩╝░░░░░░░░░░░░░░░░░░░░░░░░░░░░

# UberChip

The Supreme PSX Modchip (C) 2021

LGT8F328P PU20/ PU22/ PU23 version (c) 2022

VajskiDs Consoles

**'The Black Screen of Injection Acception'**
**For 3.3v compatible Arduino / clones & PIC 12F675**

## Credit where it's Due

The delays used in the PIC ASM version were generated by 'PICLOOPS'
The WFCK Frequency was calculated with RTM Timer Calculator

## References for informations:

- http://www.psxdev.net/forum/viewtopic.php?t=1265&start=20
- https://www.obscuregamers.com/threads/playstation-scph-7502-pu-22-pcb-modchip-question-and-modchip-diagrams-request.1311/
- http://www.psxdev.net/forum/viewtopic.php?t=1266
- PM41 with BIOS patch for PAL PSOne consoles - Demo: https://youtu.be/Ahy8XMkAvQc 

## Descriptions

An Open Source arduino "full stealth" modchip developed for each model of PS1. The PU18 Is assumed to be working

The chips include multi-disc support and initially started with a full serial monitor output which shows you exactly what's
happening, as well as acting like a built in debugger. There are of course stand-alone internal install versions with out a debugger.

No Audio CD delay- will boot straight to audio CD player

Thanks to all the other open source modchip writers and especially thanks to OldCrows old articles and for
releasing the first of the mighty PSX modchips! (though, I did write this from scratch before looking at other source code!)

A clone arduino nano will set you back a whopping 6.60AUD free post at the moment, please check compatible arduinos folder.
This will be updated when possible, but should work with many (if not all) 3.3v arduinos.

Optional reset: PIC leg 4 off MM3 diagrams to the RST on the arduino.
Without this, you can reset but you'd have to open the drive lid and close it again to get the game disc to boot again. 

## How it works

Precise timing of injections on each model and cutting them off in time for anti-mod discs not to detect them (Stealth).

For PU8/ PU18 the gate is tied low for entire duration of console power on. 
Later models require a WFCK frequency instead.

The chip only kicks back into the magic key injection routine when the drive lid is opened / closed again (for Multi-Disc games), or if it's reset (optional wire) or powered off/ on.

The timing isn't written in stone, but I'd suggest leaving it as is, as I've tested them thoroughly. Try and use high quality CD-R’s


## To do

- ATTINY85 version would be cool to write.
- May have identified a bug in PAL PSOne version, multidisc swap doesn't like BIOS patch routine. For arduino version, likely a separate injection routine to call, minus the BIOS patch after lid open/ close. For PIC version, simply not resetting the BIOS patch routine counters after the initial injection routine should fix it. The counters should just count backwards from 255, minus 1 per injection- after hitting zero. The counters hitting zero trigger the BIOS patch routine to kick in and to end.
- Uber-D-D (PM41 bios patch version) has being ported across in raw assembly for PIC12F675. 
It would be nice to port the others across as well, though the WFCK frequency can’t be generated on the PIC chips without an external 20Mhz clock. You might be able to drive the PIC off the reference clock in the clock gen circuit on later phat models, this should allow the 7.22khz WFCK output on the PIC 12F675 version of Uber-D-D

## Some notes from the listed source in relation to WFCK frequency on PIC version

Source: https://pic-microcontroller.com/pic12f675-pwm-code-and-proteus-simulation/
" Then PWM is initialized using InitPWM() function. After that, PWM variable is assigned a value of 127, which corresponds to a duty cycle of 50% (as shown in figure 1). You can change duty cycle of PWM by just changing the value of PWM variable.
You can change PWM frequency by changing the CPU frequency of PIC12F675 microcontroller. In other words, currently I am using internal oscillator of 4MHz value which generates a PWM frequency of 1.8KHz. But you can use external crystal of upto 20MHz value to generate a maximum PWM frequency of 9KHz. Also, you can change PWM frequency by changing the frequency Pre-Scalar of timer0 in the code."


##  PU22+ notes
A 'Genuine Mode' (Chip disable) originally existed for early revision of the chip. You would start the console with the Lid open, then close it a few seconds later to boot genuine games. This would disable the chip completely as the magic keys would collide and genuine discs would not orginally boot.
Chip disable mode was left in place up to V2.1J though, it would never be required. Later versions output the WFCK frequency required. Chip disable mode was removed on the LGT8F328P version (V2.1Jx)  & the Data pin moved from D12 to D7 on this version.

## 4.43361875 MHz Sub Carrier Output
July 2022: So after updating a version to work with the LGT8F328P I realised we can now output the PAL Sub Carrier Frequency on the PWM CLK pins on this chip.
The other nanos used prior had a limit of 4Mhz output due to the 16Mhz they ran at. 
These run @ 32Mhz so we should be able to output up to 8Mhz.
PAL Sub Carrier Target = 4.43361875 Mhz


This would be easy to get close to if you spent some time next to a scope with a tiny sample of code and a calculator.
This would be like the old crow chips (I have amassed a small collection) that have the colour burst crystal (not the oscillator, just the small xtal that need supporting
circuitry) and act as a 2 in one by forcing NTSC games to use PAL Sub Carrier (and play in colour on PAL machines) and by injecting magic key to get your CD-R's and Imports to run.

This would only be useful in PU8/ PU18 machines - The sub carrier is not step locked to the GPU frequency in later revisions, it is a separate rail altogether off the onboard clock synth. It already outputs a fixed sub carrier regardless of game region (so don't even ask me why people were doing the link wire hacks back in the day).



## PU8 / PU18 Revision History
V1.00: Developed on a PU18 (SCPH-5502), would work on PU8 as well. I was an ABSOLUTE noob to programming, having only written a few apps in Visual Basic 6 in high school. I still remember going to the book store and grabbing the “how to VB6” book! Other than that, I had attempted MANY times to write new missions for Command and Conquer Red Alert on my Pentium 1, 133Mhz beast with a 2Mb graphics card and 500Mb hard drive. I had extremely basic batch knowledge having being introduced to 286, 386 and 486 PC’s when I was 14 (Prior to this, just consoles!)and having to learn how to automate things in DOS as best as possible.

This version has the 1’s and 0’s for the PAL magic key string (SCEE) all written as individual ‘digital writes’ as this was all I knew.
 
V1.5 (DEBUG): Still Developing on a PU18 (SCPH-5502). Program flow was doing my head in, I made this into a debug version. I would power it off USB from the PC and It would print on the serial monitor lots of random information. 

Basically, this was to relay to me where in the the program it was up to at all times.  This way I could tell if the program never made it to a function that was meant to be called. I Found out you could add a delay at boot and have the console jump straight into CD player – there was absolutely no point starting magic key injections from the Get Go at power on. This delay would give the console just enough time to detect an Audio CD as an Audio CD before the magic key injections confused it, and you were hit with a massive waiting time before the Audio CD player on the console would launch. There were other minor timing tweaks as well.

I was using a wire to one of the Arduino I/O pins as a ‘sense wire’ whilst being powered off USB on the PC. When I switched the console on, it would sense the pin as ‘high/ true/ 1’. This would then let the code run. This was required, or the code would just start running as soon as it was plugged into the USB.


V1.5 (Stand-Alone): Still Devving on PU18... Basically stripped all the debug stuff out of the above version and had it power off the console as a proper installed modchip. No serial monitor stuff. Not sure what I was thinking at the time, but I was running power to the chip, then linking the power wire across to the sense I/O pin from when I was debugging to get the code running when the console was powered on.


V1.5.1 (Stand-Alone): As above but added drive lid status check during magic key injections. This would monitor for a drive lid opening during the key injections and allow a halt and re-injection after closing the lid.

V1.5.2:  I realised it was dumb to have a link wire to a ‘sense pin’ to get the code running. I can just power the console on, and that switches the Nano on – then the code runs – DERP. That’s all that was changed.


## PU20 + Revision History
