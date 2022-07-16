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

## References for informations:

- http://www.psxdev.net/forum/viewtopic.php?t=1265&start=20
- https://www.obscuregamers.com/threads/playstation-scph-7502-pu-22-pcb-modchip-question-and-modchip-diagrams-request.1311/
- http://www.psxdev.net/forum/viewtopic.php?t=1266
- PM41 with BIOS patch for PAL consoles Demo: https://youtu.be/Ahy8XMkAvQc The PIC version of this chip is better...!

## Descriptions

An Open Source arduino "full stealth" modchip developed for each model of PS1. The PU18 version is assumed working with PU8 / PU20 revisions. 

The chips include multi-disc support and initially started with a full serial monitor output which shows you exactly what's
happening, as well as acting like a built in debugger. There are of course stand-alone internal install versions with out a debugger.

No Audio CD delay- will boot straight to audio CD player

Thanks to all the other open source modchip writers and especially thanks to OldCrows old articles and for
releasing the first of the mighty PSX modchips!

A clone arduino nano will set you back a whopping 6.60AUD free post at the moment, please check compatible arduinos folder.
This will be updated when possible, but should work with many (if not all) 3.3v arduinos.

Optional reset: PIC leg 4 off MM3 diagrams to the RST on the arduino.
Without this, you can reset but you'd have to open the drive lid and close it again to get the game disc to boot again. 

## How it works

Precise timing of injections on each model then either stopping the injections but keeping the gate held low (earlier phats) or stopping the injections then reverting the DATA line to an input, thus letting the original signal in without
any interference (later phats) 

This is how it remains stealth. It only kicks back into an injection cycle when the drive lid is opened / closed again, or if it's reset (optional wire) or powered off/ on. The chip basically chops up the line signal to mimic the string, then disappears, it does however collide with the genuine string on later models, hence having a 'genuine' mode. To boot a genuine disc on PU22 / PU23 / PM41, turn the console on with the lid open - wait for the white screen - then close the lid. 

The timing isn't written in stone, but I'd suggest leaving it as is, as I've tested them thoroughly. I use solely Verbatim AZO these days as Taiyo Yuden (That's! CDR) have become too expensive.

By installing this chip **YOUR DRIVE IS RESTRICTED IN WORKING** within the boundaries of the chips programming!

### Benefit of this
Less wires, Discs must be in good shape! If your disc can't load within the parameters of the modchip then you've got a scratched up disc - make a fresh one. Scratched
discs are only going to wear out your laser faster. Each model has slightly different timing and counts either full string iterations or increments a counter per bit.

### Downfalls
If disc is scratched, disc maybe not load in time for injection.

## To do
- Uber-D-D (PM41 bios patch version) has being ported across in raw assembly for PIC12F675 ...The others will come eventually
- ATTINY85 version coming too
- May have identified a bug in PAL PSOne version, multidisc swap doesn't like BIOS patch routine. For arduino version, likely a separate injection routine to call, minus the BIOS patch after lid open/ close. For PIC version, simply not resetting the BIOS patch routine counters after the initial injection routine should fix it. The counters should just count backwards from 255, minus 1 per injection- after hitting zero. The counters hitting zero trigger the BIOS patch routine to kick in and to end.
- May be able to drive the PIC off the reference clock in the clock gen circuit on later phat models, this should allow the 7.22khz WFCK output on the PIC version of Uber-D-D



## This only applies to PU22+ 
Update: Wire link will not be required, the chip originally needed to run in "genuine mode" to boot genuine discs of the consoles region and wouldn't boot 
genuine imports without the old WFCK link (like if you used an oldcrow on PU22+)

A simulated WFCK signal has being added (D9 or D10) and will be added to the console folders in time.
'Genuine Mode' still exists if you wish to disable the chip for any reason. (<- removed on LGT8F328P version & Data moved from D12 to D7 on this version)

Source: https://pic-microcontroller.com/pic12f675-pwm-code-and-proteus-simulation/
" Then PWM is initialized using InitPWM() function. After that, PWM variable is assigned a value of 127, which corresponds to a duty cycle of 50% (as shown in figure 1). You can change duty cycle of PWM by just changing the value of PWM variable.
You can change PWM frequency by changing the CPU frequency of PIC12F675 microcontroller. In other words, currently I am using internal oscillator of 4MHz value which generates a PWM frequency of 1.8KHz. But you can use external crystal of upto 20MHz value to generate a maximum PWM frequency of 9KHz. Also, you can change PWM frequency by changing the frequency Pre-Scalar of timer0 in the code."

So I can't generate the WFCK frequency without an external XTAL on the PIC12F675 version,  PIC12F1822 should be able to do it, and priced reasonably well. Maybe at a later date. The Arduino version can do it as seen on V2.1, I haven't bothered adding the code to the PSONE arduino version yet. 


## 4.43361875 MHz Sub Carrier Output
July 2022: So after updating a version to work with the LGT8F328P I realised we can now output the PAL Sub Carrier Frequency on the PWM CLK pins on this chip.
The other nanos used prior had a limit of 4Mhz output due to the 16Mhz they ran at. 
These run @ 32Mhz so we should be able to output up to 8Mhz.
PAL Sub Carrier Target = 4.43361875 Mhz


This would be easy to get close to if you spent some time next a scope with a tiny sample of code and a calculator.
This would be like the old crow chips (I have amassed a small collection) that have the colour burst crystal (not the oscillator, just the small xtal that need supporting
circuitry) and act as a 2 in one by forcing NTSC games to use PAL Sub Carrier (and play in colour) and by injecting magic key to get your CD-R's and Imports to run.
