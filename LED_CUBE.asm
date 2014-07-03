.include "m16def.inc"
.def temp = r16      // Hilfsvariable
.def temp2 = r19     // Hilfsvariable

.def Pos = r17       // Aktueller Animationsschritt
.def Counter = r18   // Erster Zähler
.def Counter2 = r21  // Zweiter Zähler
.def Max = r20       // Anzahl der Animiationsschritte
.def Merk = r22      // Merkt sich Counter2
.def Zustand = r23   // Speichert den Zustand der Taster
.def Animation = r24 // ausgwählte Animation
.def Ebene = r25     // Enthält die zu zeichnende Ebene
.def Freq = r15
.def Schalt = r14
.def Schalt2 = r13
.def Warte = r12

.equ XTAL = 8000000  // Frequenz 4Mhz oder 8 Mhz sind gedacht

.equ WARTEZEIT = 20
.equ SCHALTSTUFEN = 40;
.equ ERHOEHUNG = 1

.org 0x0000
rjmp reset
.org OC1Aaddr  
rjmp loop

reset:

; Init

ldi temp, 0
mov Warte, temp

ldi Merk, 0
ldi Counter, 0
ldi Counter2, 0 

ldi Pos, 0 
ldi     zl,low(Animation1_Anz*2);            
ldi     zh,high(Animation1_Anz*2);
lpm Max, Z
ldi Animation, 5
ldi Ebene,0

mov temp, Pos
inc temp
ldi temp2, 10
mul temp, temp2

ldi temp, 0
mov Freq,temp

ldi     zl,low(Animation1*2);            
ldi     zh,high(Animation1*2);
add zl, r0
adc zh, r1
adiw zl, 8

lpm temp, Z+
mov Counter ,temp
lsr Counter
lsr Counter
lsr Counter
lpm temp, Z+
mov Counter2 ,temp
mov Merk, Counter2


ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

; Ausgänge einstellen
ldi temp, 0xFF
out DDRA, temp
out PORTA, temp
out DDRB, temp
out PORTB, temp
out DDRC, temp
out PORTC, temp

//ldi temp, 0x00
//out PORTC, temp

//ldi temp, 0xFF
//out PORTA, temp
//out PORTB, temp

// Eingänge einstellen
ldi temp, 0x00
out DDRD, temp
ldi temp, 0xFF
out PORTD, temp

in Zustand, PIND

ldi     zl,low(Block_1);            
ldi     zh,high(Block_1);
ldi temp2, 0
ldi temp, 64
schleife_init:
st Z+, temp2
dec temp
brne schleife_init


// Timer 1

 ldi     temp, high( 400- 1 )// 320
        out     OCR1AH, temp
        ldi     temp, low( 400 - 1 ) //320
        out     OCR1AL, temp
		 ldi     temp, ( 1 << WGM12 ) | ( 1 << CS10 )
        out     TCCR1B, temp
        ldi     temp, 1 << OCIE1A  
        out     TIMSK, temp
sei



do: 
//ldi temp, 0xFF
//out DDRC, temp
//ldi temp, 0xFF
//ldi temp2, 0b10000000
//out PORTA, temp
//out PORTC, temp2
rjmp do

// Start Schleife
loop:
// Prüfen ob Animationswechsel
//rjmp no_wechsel

sbic PIND, 0x00
rjmp ende_0
sbrc Zustand, 0x00
rjmp ende_0
ldi Animation,0
ldi Pos, 0
ldi     zl,low(Animation1_Anz*2);            
ldi     zh,high(Animation1_Anz*2);
lpm Max, Z
ende_0:

sbic PIND, 0x01
rjmp ende_1
sbrc Zustand, 0x01
rjmp ende_1
ldi Animation,1
ldi Pos, 0
ldi     zl,low(Animation2_Anz*2);            
ldi     zh,high(Animation2_Anz*2);
lpm Max, Z
ende_1:

sbic PIND, 0x02
rjmp ende_2
sbrc Zustand, 0x02
rjmp ende_2
ldi Animation,2
ldi Pos, 0
ldi     zl,low(Animation3_Anz*2);            
ldi     zh,high(Animation3_Anz*2);
lpm Max, Z
ende_2:

sbic PIND, 0x03
rjmp ende_3
sbrc Zustand, 0x03
rjmp ende_3
ldi Animation,3
ldi Pos, 0
ldi     zl,low(Animation4_Anz*2);            
ldi     zh,high(Animation4_Anz*2);
lpm Max, Z
ende_3:

in Zustand, PIND
no_wechsel:


mov temp, Pos

ldi temp2, 10
mul temp, temp2
cpi Animation,0
brne no_0_2
ldi     zl,low(Animation1*2);            
ldi     zh,high(Animation1*2);
rjmp no_3_2
no_0_2:
cpi Animation,1
brne no_1_2
ldi     zl,low(Animation2*2);            
ldi     zh,high(Animation2*2);
rjmp no_3_2
no_1_2:
cpi Animation,2
brne no_2_2
ldi     zl,low(Animation3*2);            
ldi     zh,high(Animation3*2);
rjmp no_3_2
no_2_2:
cpi Animation,3
brne no_3_2
ldi     zl,low(Animation4*2);            
ldi     zh,high(Animation4*2);
no_3_2:
add zl, r0
adc zh, r1

cpi Animation, 5
brne normal
rcall Ebene_bestimmen
//ldi temp2, 0b00001111
out PORTC, temp2
ldi temp, 255
out PORTA, temp
out PORTB, temp
rjmp End_Ebene

normal:
ldi temp, ERHOEHUNG
mov Schalt, temp
ldi temp, SCHALTSTUFEN
mov Schalt2, temp

ldi temp2, 0x00
out PORTC, temp2
ldi temp2, 0x00
out PORTA, temp2
out PORTB, temp2

// Ebenen Zeichnen
cpi Ebene,0
brne no_Ebene1
ldi     xl,low(Block_1);            
ldi     xh,high(Block_1);
no_Ebene1:

cpi Ebene,1
brne no_Ebene2
ldi     xl,low(Block_2);            
ldi     xh,high(Block_2);
lpm temp, Z+
lpm temp, Z+
no_Ebene2:

cpi Ebene,2
brne no_Ebene3
ldi     xl,low(Block_3);            
ldi     xh,high(Block_3);
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
no_Ebene3:

cpi Ebene,3
brne no_Ebene4
ldi     xl,low(Block_4);            
ldi     xh,high(Block_4);
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
lpm temp, Z+
no_Ebene4:



// A Zeichnen
push Max
ldi Max, 0b00000000
//ldi temp, 8
ldi temp2, 0b00000001

schleifeA:
//push temp
//lpm temp, Z+
//st X, temp
ld temp, X+

cp Freq, temp
brsh onA
or Max, temp2 
onA:
//pop temp

lsl temp2
//dec temp
brne schleifeA
out PORTA, Max
pop Max

mov temp, warte
cpi temp, 0
breq Aschalten
rjmp no_Aschalt
Aschalten:

// A Schalten
lpm temp2, Z+ // 1 bis 8
ldi temp, 8
schleifeAUp:
push temp2
andi temp2, 128

breq downA

// hochschalten
ld temp2, -X
cp temp2, Schalt2
breq no_upper
add temp2, Schalt
st X, temp2
no_upper:
rjmp nodownA
downA: 
// runterschalten
ld temp2, -X
cpi temp2, 0
breq no_downer
sub temp2, Schalt
st X, temp2
no_downer:
nodownA:

pop temp2
lsl temp2
dec temp
brne schleifeAUp

ld temp, X+
ld temp, X+
ld temp, X+
ld temp, X+
ld temp, X+
ld temp, X+
ld temp, X+
ld temp, X+
no_Aschalt:

// B Zeichnen
push Max
ldi Max, 0b00000000
//ldi temp, 8
ldi temp2, 0b00000001
schleifeB:
//push temp
ld temp, X+
cp Freq, temp
brsh onB
or Max, temp2 
onB:
//pop temp
lsl temp2
//dec temp
brne schleifeB
out PORTB, Max
pop Max

mov temp, warte
cpi temp, 0
breq Bschalten
rjmp no_Bschalt
Bschalten:

// B Schalten
lpm temp2, Z+ // 1 bis 8
ldi temp, 8
schleifeBUp:
push temp2
andi temp2, 128
breq downB
// hochschalten
ld temp2, -X
cp temp2, Schalt2
breq no_upperB
add temp2, Schalt
st X, temp2
no_upperB:
rjmp nodownB
downB: 
// runterschalten
ld temp2, -X
cpi temp2, 0
breq no_downerB
sub temp2, Schalt
st X, temp2
no_downerB:
nodownB:

pop temp2
lsl temp2
dec temp
brne schleifeBUp

ldi temp, WARTEZEIT
mov warte, temp
rjmp over_no_schalt
no_Bschalt:
dec warte
over_no_schalt:

rcall Ebene_bestimmen
out PORTC, temp2
rjmp End_Ebene

End_Ebene:

inc Ebene
cpi Ebene, 4
brne no_new_Ebene
ldi Ebene,0
inc Freq

cp Freq,Schalt2
brne no_new_Ebene
ldi temp, 0
mov Freq, temp
no_new_Ebene:



cpi Counter2, 0
brne no_next2
mov Counter2, Merk

cpi Counter, 0
brne no_next
inc Pos
cp Pos, Max // Animation zurücksetzen
brne no_res
ldi Pos, 0
no_res:

mov temp, Pos
ldi temp2, 10
mul temp, temp2

cpi Animation,0
brne no_0
ldi     zl,low(Animation1*2);            
ldi     zh,high(Animation1*2);
rjmp no_3
no_0:
cpi Animation,1
brne no_1
ldi     zl,low(Animation2*2);            
ldi     zh,high(Animation2*2);
rjmp no_3
no_1:
cpi Animation,2
brne no_2
ldi     zl,low(Animation3*2);            
ldi     zh,high(Animation3*2);
rjmp no_3
no_2:
cpi Animation,3
brne no_3
ldi     zl,low(Animation4*2);            
ldi     zh,high(Animation4*2);
no_3:

add zl, r0
adc zh, r1
adiw zl, 8

lpm temp, Z+
mov Counter ,temp
lpm temp, Z+
mov Counter2 ,temp
lsr Counter
lsr Counter
//lsr Counter
mov Merk, Counter2

reti
no_next:
dec Counter
reti

no_next2:
dec Counter2
reti
// Ende Schleife

// Beispiel:
//
//    [16 Bit für 1. Ebene] [16 bit für 2. Ebene] [16 bit für 3. Ebene] [16 bit für 4. Ebene] [ Zeit ]
//.db 0b00000000,0b10000000,0b00000000,0b00000000,0b00000000,0b00000000,0b00000000,0b00000000,250, 250
//
// Zeit = (Counter * Counter2 / 12500) Sekunden
//
// Bsp. Counter = 250, Counter2 = 50, Zeit = 1s
//      Counter = 250, Counter2 = 10, Zeit = 200ms
//      Counter = 125, Counter2 = 50, Zeit = 500ms

Ebene_bestimmen:
ldi temp2, 00000001
cpi Ebene,0
breq no2_einstellen
push Ebene
schieben:
lsl temp2
dec Ebene
brne schieben
pop Ebene
no2_einstellen:
ret

.include "Animation1.asm"
.include "Animation2.asm"
.include "Animation3.asm"
.include "Animation4.asm"

.DSEG ; Arbeitsspeicher
Block_1: .BYTE  16 
Block_2: .BYTE  16
Block_3: .BYTE  16
Block_4: .BYTE  16
