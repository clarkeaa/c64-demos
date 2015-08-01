!cpu 6502
!to "sprite.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0b,$08,$f0,$02,$9e           ; BASIC loader
!text "2061"

;;; --------------------------------------------------
* = $080d
;;; ;;;;;;;;;;;;;;;;;;;;;;;;
main:
	jsr clear
        jsr setup_irq

	lda $d015		;turn on sprite 0
	ora #%00000001
	sta $d015

	lda #$03
	sta $d027		; set sprite 0 color

	lda #13
	sta $7f8		; set sprite 0 pointer to 13*64=$340

	lda spritex
	sta $d000		; set x sprite 0
	lda spritey			
	sta $d001		; set y sprite 0

	lda $d010
	ora spritex+1
	sta $d010		; clear x msb sprite 0

	lda #0			; set border/background
	sta $d020
	sta $d021
	
	ldx #63			; load sprite
.loop:
	lda sprite1,x
	sta $340,x
	dex
	bpl .loop	
	
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
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
irq:
        dec $d019               ; ack irq

	ldx .idx
	lda sintable,x
	sta $d001		; set y sprite 0
	inx
	txa
	and #%01111111
	sta .idx
		
.exit_irq:
        jmp $ea81    ; return to kernel interrupt routine
.idx:
	!byte $00
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear:
        ldx #$00
        lda #$20
.clearloop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne .clearloop
        rts

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spritex:
	!byte $64, $00
spritey:
	!byte $64
sprite1:
	!24 %########################
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %######..########..######
	!24 %##...##.########...#####
	!24 %######..########..######
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %...........##...........
	!24 %########################
sintable:
	!byte $84
	!byte $86
	!byte $88
	!byte $8b
	!byte $8d
	!byte $90
	!byte $92
	!byte $94
	!byte $97
	!byte $99
	!byte $9b
	!byte $9d
	!byte $9f
	!byte $a1
	!byte $a3
	!byte $a5
	!byte $a7
	!byte $a9
	!byte $aa
	!byte $ac
	!byte $ad
	!byte $ae
	!byte $b0
	!byte $b1
	!byte $b2
	!byte $b3
	!byte $b3
	!byte $b4
	!byte $b5
	!byte $b5
	!byte $b5
	!byte $b5
	!byte $b6
	!byte $b5
	!byte $b5
	!byte $b5
	!byte $b5
	!byte $b4
	!byte $b3
	!byte $b3
	!byte $b2
	!byte $b1
	!byte $b0
	!byte $ae
	!byte $ad
	!byte $ac
	!byte $aa
	!byte $a9
	!byte $a7
	!byte $a5
	!byte $a3
	!byte $a1
	!byte $9f
	!byte $9d
	!byte $9b
	!byte $99
	!byte $97
	!byte $94
	!byte $92
	!byte $90
	!byte $8d
	!byte $8b
	!byte $88
	!byte $86
	!byte $84
	!byte $81
	!byte $7f
	!byte $7c
	!byte $7a
	!byte $77
	!byte $75
	!byte $73
	!byte $70
	!byte $6e
	!byte $6c
	!byte $6a
	!byte $68
	!byte $66
	!byte $64
	!byte $62
	!byte $60
	!byte $5e
	!byte $5d
	!byte $5b
	!byte $5a
	!byte $59
	!byte $57
	!byte $56
	!byte $55
	!byte $54
	!byte $54
	!byte $53
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $52
	!byte $53
	!byte $54
	!byte $54
	!byte $55
	!byte $56
	!byte $57
	!byte $59
	!byte $5a
	!byte $5b
	!byte $5d
	!byte $5e
	!byte $60
	!byte $62
	!byte $64
	!byte $66
	!byte $68
	!byte $6a
	!byte $6c
	!byte $6e
	!byte $70
	!byte $73
	!byte $75
	!byte $77
	!byte $7a
	!byte $7c
	!byte $7f
	!byte $81
