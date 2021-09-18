; avr atmega8 simple encoder test
; used timer1 to delay cycles

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

.global main
.global __vector_default
.global INT0_vect
.global INT1_vect
.global TIMER1_OVF_vect

tc1    = 15 ; timer1 counter
temp   = 16 ; common reg
now    = 17 ; current port state
before = 18 ; port state before now

.section .text

__vector_default:
reti

main:
      	rcall extint_init
      	loop:
      	rcall enc_state
      	rjmp loop
ret

enc_state:
	 brtc enc_ret ; no shot
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
	 clt
	 ret
	es0: cpi now, 1
	 breq cw
	 cpi now, 2
	 breq ccw
         mov before, now
	 clt
	 ret
	es1: cpi now, 3
	 breq cw
	 tst now
	 breq ccw
         mov before, now
	 clt
	 ret
	es2: tst now
	 breq cw
	 cpi now, 3
	 breq ccw
         mov before, now
	 clt
	 ret
	es3: cpi now, 2
	 breq cw
	 cpi now, 1
	 breq ccw
         mov before, now
	 clt
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

INT0_vect:
	brts ret0
        in now, PIND
	set
	; delay
	; flags reset
	; and what about statuses?
	ret0:
reti

INT1_vect:
	brts ret1
        in now, PIND
	set
	ret1:
reti

extint_init:
	cbi DDRD, PD2 ; input
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

led_on1:
	sbi DDRD, PD6 ; two leds inverse-parallel
        sbi DDRD, PD7 ; output
        sbi PORTD, PD6 ; high
        cbi PORTD, PD7 ; low
	ret

led_on2:
	sbi DDRD, PD6 ; reverse
        sbi DDRD, PD7
        cbi PORTD, PD6
        sbi PORTD, PD7
	ret

delay_1s: ;
	ser temp
	mov tc1, temp
	ldi temp, 0x3c ; 15500
	out TCNT1H, temp
        ldi temp, 0x8c
	out TCNT1L, temp
        ldi temp, (1<<CS11)|(1<<CS10) ; 64
        out TCCR1B, temp
        sbr temp, (1<<TOIE1)
        out TIMSK, temp
        sei
	d1L: tst tc1
	brne d1L
        cbr temp, (1<<TOIE1)
        ret

delay_100ms:
        ser temp
	mov tc1, temp
        ldi temp, 0x0b ; 3000
        out TCNT1H, temp
        ldi temp, 0xb8
        out TCNT1L, temp
        ldi temp, (1<<CS11) ; 8
        out TCCR1B, temp
        sbr temp, (1<<TOIE1)
        out TIMSK, temp
        sei
        d100L: tst tc1
        brne d100L
        cbr temp, (1<<TOIE1)
 	ret

TIMER1_OVF_vect:
	clr tc1
	reti

.end
