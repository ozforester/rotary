; avr atmega8 double ext isr encoder test
; used timer1 as delay timer

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
port   = 17
dir    = 18

.section .text

__vector_default:
reti

main:
      	rcall extint_init
	ldi dir, 0
      	loop:
	rcall direction
        rcall delay_1s
      	rjmp loop
ret

direction:
        cpi dir, 1
        breq led1
        cpi dir, 2
        breq led2
        rjmp ex
        led1:
        rcall led_on1
        rjmp ex
        led2:
        rcall led_on2
        ex:
ret

INT0_vect:
        clr port
        out GIFR, port
        in port, PIND
	andi port, 12
	cpi port, 8
	breq cw0
	cpi port, 4
	breq ccw0
	reti
        cw0:
	ldi dir, 1
        ;rcall led_on1
	reti
        ccw0:
	ldi dir, 2
	;rcall led_on2
	rcall delay_100ms
	reti

INT1_vect:
        clr port
        out GIFR, port
        in port, PIND
        andi port, 12
        cpi port, 8
        breq cw1
        cpi port, 4
        breq ccw1
        reti
        cw1:
	ldi dir, 1
        reti
        ccw1:
	ldi dir, 2
        rcall delay_100ms
        reti

extint_init:
	cbi DDRD, PD2 ; input
        sbi PORTD, PD2 ; pulled-up
        cbi DDRD, PD3
        sbi PORTD, PD3
        ldi temp, 0b00001010 ; @falling
        ;ldi temp, 0b00000101 ; @any change
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
        ldi temp, (1<<CS11)|(1<<CS10) ; /64
        out TCCR1B, temp
        sbr temp, (1<<TOIE1)
        out TIMSK, temp
        sei
	d1L: tst tc1
	brne d1L
        cbr temp, (1<<TOIE1)
        out TIMSK, temp
        ret

delay_100ms:
        ser temp
	mov tc1, temp
        ldi temp, 0x0b ; 3000
        out TCNT1H, temp
        ldi temp, 0xb8
        out TCNT1L, temp
        ldi temp, (1<<CS11) ; /8
        out TCCR1B, temp
        sbr temp, (1<<TOIE1)
        out TIMSK, temp
        sei
        d100L: tst tc1
        brne d100L
        cbr temp, (1<<TOIE1)
	out TIMSK, temp
 	ret

TIMER1_OVF_vect:
	clr tc1
	reti

.end
