!cpu 6502
!to "sid2.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0b,$08,$f0,$02,$9e           ; BASIC loader
!text "2061"

;;; --------------------------------------------------
* = $080d
;;; ;;;;;;;;;;;;;;;;;;;;;;;;
main:
	jsr setup_irq

	lda #15
	sta $d418		; volume 1

	lda #0
	sta $d400
	lda #1
	sta $d401		; freq 1

	lda #$33
	sta $d405		; attack decay 1

	lda #$ff
	sta $d406		; sustain release 1
	
	lda #$11
	sta $d404		; turn voice 1 on
	
	jmp *
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_irq:
        sei           ; set interrupt disable flag

        ldy #$7f     ; $7f = %01111111
        sty $dc0d    ; Turn off CIAs Timer interrupts
        sty $dd0d    ; Turn off CIAs Timer interrupts
        lda $dc0d    ; cancel all CIA-IRQs in queue/unprocessed
        lda $dd0d    ; cancel all CIA-IRQs in queue/unprocessed

        lda #$01     ; Set Interrupt Request Mask...
        sta $d01a    ; ...we want IRQ by Rasterbeam

        lda #<irq    ; point IRQ Vector to our custom irq routine
        ldx #>irq
        sta $314     ; store in $314/$315
        stx $315

        lda #$00     ; trigger first interrupt at row zero
        sta $d012

        lda $d011    ; Bit#0 of $d011 is basically...
        and #$7f     ; ...the 9th Bit for $d012
        sta $d011    ; we need to make sure it is set to zero

        cli          ; clear interrupt disable flag
        rts
;;;
!macro lsr4 {
	lsr
	lsr
	lsr
	lsr
}	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
irq:
        dec $d019               ; ack irq
	inc .count
	lda .count
	+lsr4
	beq .exit_irq		; exit if .count < 16
	lda #0
	sta .count
	ldx .loc
	lda freqs,x
	sta $d400		; voice 1 freq lo
	inx
	lda freqs,x
	sta $d401		; voice 2 freq hi
	inx
	txa
	and #%00001111 		; loc = loc + 1 mod 8
	sta .loc	
.exit_irq:
        jmp $ea81    ; return to kernel interrupt routine
.count:
	!byte $00
.loc:
	!byte $00
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
freqs:
	!byte $00,$01
	!byte $00,$08
	!byte $00,$02
	!byte $00,$04
	!byte $00,$08
	!byte $00,$10
	!byte $00,$04
	!byte $00,$08
	
