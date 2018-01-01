August 22,1997  updated January, 1 2018 (email adress)
       *************************************
       *     PICDREAM by Alain Fort        *
       *    alain.fort.f1cjn@sfr.fr        *
       *************************************

Programmable Intelligent Circuit Dedicated to
 Radio and Electronic Amateurs, Mainly  (Ouf !!)

Here is the first version of a video PIC system with :
	- a 7 scrolling 5*7 caracters message in the top of screen,
	- gray scale bars in the middle,	
	- a real time clock in the bottom.

I wrote this program for all TV radio amateurs, looking for a low
cost video generator.

 
Thanks a lot to Peter Knight's original 4 Mhz synchronisation routines.
Thanks to the British Amateur TV Club for its good pages on the PIC
which decided me to use the PIC, to build my own programmer and write
this little program. 

I wrote all caracters routines to get real 5*7 characters à 1 MHz
with a 7 characters scrolling display, designed the
clock routines and the gray bars and clock set-up routines.

Output video circuit:

         |   ___ 470R
      RA3|---___--------+                       RA3 is the msb
         |   ___ 910R   |
      RA2|---___--------+		
         |   ___ 1,8K   |
      RA1|---___--------+			RA1 is the lsb
         |   ___ 1K     |
      RA0|---___--------+			RA0 is the sync
         |   ___ 270R    |
      RB4|---___--------+---------- CVBS OUT	RB4 is the text O/P
                             |
                            | | 75R (not wired if you have a 75 Ohms
                            | |      monitor)
                             |
                            GND
	       /
      RB7|---+/  +----- GND       SET HOURS

	       /
      RB6|---+/ +------ GND       SET MINUTES

     MCLR|------------- VCC





The PIC16C84 uses a 5V power supply and a 4 MHz crystal oscillator .


Using this code is free for amateurs.

Mail:	Alain Fort
	8 rue G. Péri
	78420
	Carrières sur Seine
	France 

France Phone:    0139577678
World phone :  33 1 39577678
Packet radio:  F1CJN@F6KBF.FRPA     
Email	    :  alain.fort.f1cjn@sfr.fr

