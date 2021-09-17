; avr atmega8 simple encoder test

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

.global main
.global __vector_default
.global INT0_vect
.global INT1_vect

temp   = 16 ; common reg
now    = 17 ; current port state
before = 18 ; port state before now

.section .text

__vector_default: reti

main: rcall iinit
      loop: rcall enc_state
      rjmp loop
      ret

enc_state: brtc enc_ret ; no shot
         andi now, 0x0c
	 lsr now
	 lsr now
	 tst before
	 breq es0
	 cpi before, 1
	 breq es1
	 cpi before, 2
	 breq es2
	 cpi before, 3
	 breq es3
	 mov before, now
	 ret
	es0: cpi now, 1
	 breq cw
	 cpi now, 2
	 breq ccw
         mov before, now
	 ret
	es1: cpi now, 3
	 breq cw
	 tst now
	 breq ccw
         mov before, now
	 ret
	es2: tst now
	 breq cw
	 cpi now, 3
	 breq ccw
         mov before, now
	 ret
	es3: cpi now, 2
	 breq cw
	 cpi now, 1
	 breq ccw
         mov before, now
	 ret
	cw: rcall led_on1
         mov before, now
	 clt
	 ret
	ccw: rcall led_on2
         mov before, now
	 clt
	 enc_ret:
	 ret

INT0_vect: brts ret0 ; ext0 occures
	   set
           in now, PIND
	   ret0: reti

INT1_vect: brts ret1 ; ext1 ocuures
	   set
           in now, PIND
	   ret1: reti

iinit: cbi DDRD, PD2 ; input
       sbi PORTD, PD2 ; pulled-up
       cbi DDRD, PD3
       sbi PORTD, PD3
       in before, PIND
       andi before, 0b00001100
       lsr before
       lsr before
       ldi temp, 0b00000101 ; @any change
       out MCUCR, temp
       in temp, GICR
       ori temp, 0b11000000 ; enable both
       out GICR, temp
       sei
       ret

led_on1: sbi DDRD, PD6 ; two leds inverse-parallel
         sbi DDRD, PD7 ; output
         sbi PORTD, PD6 ; high
         cbi PORTD, PD7 ; low
	 ret

led_on2: sbi DDRD, PD6 ; reverse
         sbi DDRD, PD7
         cbi PORTD, PD6
         sbi PORTD, PD7
	 ret

.end
