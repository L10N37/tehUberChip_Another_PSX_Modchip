/*
  ╔╗░╔╦══╗╔═══╦═══╦═══╦╗░╔╦══╦═══╗░░░░░░░░░░░░░░░░░░░░░░░░░
  ║║░║║╔╗║║╔══╣╔═╗║╔═╗║║░║╠╣╠╣╔═╗║░░░░░░░░░░░░░░░░░░░░░░░░░
  ║║░║║╚╝╚╣╚══╣╚═╝║║░╚╣╚═╝║║║║╚═╝║░░░░░░░░░░░░░░░░░░░░░░░░░
  ║║░║║╔═╗║╔══╣╔╗╔╣║░╔╣╔═╗║║║║╔══╝░░░░░░░░░░░░░░░░░░░░░░░░░
  ║╚═╝║╚═╝║╚══╣║║╚╣╚═╝║║░║╠╣╠╣║░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ╚═══╩═══╩═══╩╝╚═╩═══╩╝░╚╩══╩╝░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  PU8 / PU18 / PU20 VERSION
  (c) VajskiDs Consoles 2022
  V2.00 [WIP]   Re-wrote to suit LG8F328P QFP32 Mini-EVB for PU8 / PU18/ PU20 - added easy region select for console magic key selection.
                Added a flag to adjust magic key injection quantity between cold boot, or boot with lid open / close lid / multi-disc games (extra injections in those cases)
                I have given up on this for now, when it's not broken i will remove the WIP and it will be a proper release.
                I don't have the motivation to get my logic analyser out and start probing points with meters and scopes.
                All the new ideas are here, these LGT8F328P's are a pain in the dick
                Even though there's more code and logic its down to 3% of program space
                Using PU20 (SCPH-7002) atm

  v2.1 [WIP]    Still broken, haven't touched the hardware ...just tied up the code for easy adjustments in defines. Combined all keys into a define selection
                which allows a single FOR loop.
*/





//***************** MAGIC KEYS *****************************
// EUROPE / AUSTRALIA / NEWZEALAND = SCEE
// USA = SCEA
// JP = SCEI
//
//**********************************************************






//#define F_CPU 1600000UL          // Run @ 16mhz, FLASH @ 32mhz setting!

#define SELECT_MAGICKEY SCEE                                                //<----------------------------------------------------------------------------------REGION SELECT!! ENTER CONSOLE REGION

#define LidOpenedProcess do{;}while (bitRead (LIDPORT, lidbit) == 1);
#define LidClosedProcess do{;}while (bitRead (LIDPORT, lidbit) == 0);
#define DriveLidOpen (bitRead (LIDPORT, lidbit) == 1)
#define LowBit bitClear (DATAPORT, databit), delayMicroseconds (bitdelay);
#define HighBit bitWrite (DATAPORT, databit, 1), delayMicroseconds(bitdelay);
#define EndOfMagicKey injectcounter++, delay (stringdelay);
#define StealthModeNotActive (injectcounter < 100 && LoadAtBoot == true || injectcounter < 135 && LoadAtBoot == false );
#define databit 7
#define lidbit 0
#define gatebit 2
#define LIDPORT PORTB
#define LIDIO DDRB
#define DATAPORT PORTD
#define DATAIO DDRD


boolean LoadAtBoot = true;

int injectcounter = 0x00;
int bitdelay (3794);    //delay between bits sent to drive controller (MS)
int stringdelay (67);  //delay between string injections

char SCEE[] = "S10011010100100111101001010111010010101110100";
char SCEA[] = "S10011010100100111101001010111010010111110100";
char SCEI[] = "S10011010100100111101001010111010010110110100";




void setup() {

  delay (7200);                    // Initial start-up delay
  bitWrite (LIDIO, gatebit, 1);    // Gate as output
  bitClear (LIDPORT, gatebit);     // Gate tied LOW entire duration
  bitClear(LIDIO, lidbit);         // Lid sensor as high-z input
  bitWrite (DATAIO, databit, 1);   // Data as output
  //bitClear (DATAPORT, databit);  // Tie Data Low

}


void NewDisc() {

  LidOpenedProcess       // Do 'nothing'while the lid is open between disc swaps
  Inject();             // Then jump to corresponding inject routine via switch case in Region()

}


void DriveLidStatus() {

  bitClear (DATAIO, databit);  // high-z data line
  injectcounter = 0;           // reset magic key inject counter
  LoadAtBoot = false;          // False the LoadAtBoot flag, the lids being opened. We aren't booting a disc from cold boot.
  LidClosedProcess;            //Do 'nothing'while the lid is closed
  NewDisc();                   //Jump to NewDisc() once the lid is opened

}


void Inject() {

  do
  {

    for (byte i = 0; i < sizeof(SELECT_MAGICKEY) - 1; i++)

      if (SELECT_MAGICKEY [i] == '0')
      {
        LowBit
      }
      else if (SELECT_MAGICKEY[i] == '1')
      {
        HighBit
      }
      else if (DriveLidOpen) // Magic Key injection broken by drive lid being opened?
      {
        DriveLidStatus();
      }
      else if (SELECT_MAGICKEY[i] == 'S')
      {
        EndOfMagicKey
      }
  }
  while StealthModeNotActive;
}



void loop()
{
  if (injectcounter >= 100) {
    DriveLidStatus();
  }

  Inject();

}
