!cpu 6502
!to "astrosmash.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0b,$08,$f0,$02,$9e           ; BASIC loader
!text "2061"

;;; --------------------------------------------------
char_loc = $2800
sprite_0_loc = $340
;;; --------------------------------------------------
* = $080d

main:
        lda $d016               ;setup multicolor mode
        ora #%00010000
        sta $d016

        lda #0
        sta $d020               ;set border color
        lda #0
        sta $d021               ;set 00 color
        lda #5
        sta $d022               ;set 01 color
        lda #5
        sta $d022               ;set 10 color
        lda #$1a                ; setup char/video memory regions
        sta $d018               ; vmem = $0400 char = $2800

        jsr setup_bg
        jsr load_ship
        jsr load_chars
        jsr setup_irq
        
        jmp *

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
load_ship:
!zone {
	    lda $d015		;turn on sprite 0
	    ora #%00000001
	    sta $d015

        lda #$01
	    sta $d027		; set sprite 0 color
	    lda #13
	    sta $7f8		; set sprite 0 pointer to 13*64=$340
	    lda ship_x
	    sta $d000		; set x sprite 0
	    lda ship_y
	    sta $d001		; set y sprite 0
	    lda $d010
	    and #%11111110
	    sta $d010		; clear x msb sprite 0

	    ldx #63			; load sprite
.loop:
	    lda ship_sprite,x
	    sta sprite_0_loc,x
	    dex
	    bpl .loop
	    rts
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_chars:
!zone {
        ldx #0
.loop:
        lda chars,x
        sta char_loc,x
        inx
        txa
        cmp #8*3
        bne .loop
        rts
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_bg:
        ldx #$0
        lda #$0
.clearloop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne .clearloop

        ldx #$bf
.groundloop:
        lda #1
        sta $0700,x
        dex
        txa
        cmp #$98
        bne .groundloop

        lda #2
        sta $0555
        sta $0455
        sta $04f5
        sta $0601
        sta $04c1
        rts

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

        lda $dc00               ; joystick2
        and #%00000100          ; left
        bne .not_right
        dec ship_x
.not_right:
        lda $dc00               ; joystick2
        and #%00001000          ; right
        bne .not_left
        inc ship_x
.not_left:               
	    lda ship_x
	    sta $d000		; set x sprite 0
	    lda ship_y
	    sta $d001		; set y sprite 0
.exit_irq:
        jmp $ea81    ; return to kernel interrupt routine

chars:
        ;;
        !8 %........
        !8 %........
        !8 %........
        !8 %........
        !8 %........
        !8 %........
        !8 %........
        !8 %........
        ;;
        !8 %........
        !8 %........
        !8 %........
        !8 %.#.#.#.#
        !8 %.#.#.#.#
        !8 %........
        !8 %........
        !8 %........
        ;;
        ;;
        !8 %........
        !8 %........
        !8 %........
        !8 %..#.#...
        !8 %..#.#...
        !8 %........
        !8 %........
        !8 %........
        ;;
ship_x:
        !byte $80, $00
ship_y:
        !byte $d8
!macro SpriteLine .v {
		!by .v>>16, (.v>>8)&255, .v&255
}

ship_sprite:
        +SpriteLine %.........#####..........
        +SpriteLine %....##...#####...##.....
        +SpriteLine %....###############.....
        +SpriteLine %.........#####..........
        +SpriteLine %.........#####..........
        +SpriteLine %........#######.........
        +SpriteLine %.......###...###........
        +SpriteLine %.......###...###........
        +SpriteLine %.......###...###........
        +SpriteLine %........#######.........
        +SpriteLine %.........#####..........
        +SpriteLine %.........#####..........
        +SpriteLine %.......#########........
        +SpriteLine %......###########.......
        +SpriteLine %..####################..
        +SpriteLine %..####################..
        +SpriteLine %..###..###....###..###..
        +SpriteLine %..###..###....###..###..
        +SpriteLine %..###..###....###..###..
        +SpriteLine %..###..###....###..###..
        +SpriteLine %..###..###....###..###..
        +SpriteLine %..###..###....###..###..

