!cpu 6502
!to "multicolor.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0b,$08,$f0,$02,$9e           ; BASIC loader
!text "2061"        

;;; --------------------------------------------------
* = $080d
;;; ;;;;;;;;;;;;;;;;;;;;;;;;
main:   
        lda $d016               ;setup multicolor mode
        ora #%00010000
        sta $d016

        jsr clear

        lda #$1a                ; setup char/video memory regions
        sta $d018               ; vmem = $0400 char = $2800

        lda #$00                ; setup border/background colors
        sta $d020
        lda #$04
        sta $d021
        lda #$05
        sta $d022
        lda #$06
        sta $d023
        
        ldx #$07                ; load custom character
.load_char:        
        lda custom_char,x
        sta $2800,x
        dex
        bpl .load_char

        jsr setup_irq
        
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

        lda $d016               ; increment x hardware scroll
        and #%11111000
        ora .count
        sta $d016
        dec .count
        lda .count
        and #%00000111
        sta .count
        
.exit_irq:   
        jmp $ea81    ; return to kernel interrupt routine
.count:
        !byte $00
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear:
        ldx #$00
        lda #0
.clearloop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne .clearloop
        rts

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
custom_char:
!byte %00011011
!byte %01101100
!byte %10110001
!byte %11000110
!byte %00011011
!byte %01101100
!byte %10110001
!byte %11000110
        