!cpu 6502
!to "bitmap.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0b,$08,$f0,$02,$9e           ; BASIC loader
!text "2061"        

;;; --------------------------------------------------
* = $080d
;;; ;;;;;;;;;;;;;;;;;;;;;;;;
main:
        lda $d011               ; goto bitmap mode
        ora #%00100000
        sta $d011

        lda $d018               ; set bitmap region to $2000
        ora #%00001000
        sta $d018
        
        lda #0                  ; set border color
        sta $d020
        
clear:
        ldx #$00                ; clear sreen ram
        lda #%00000010
.clearloop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne .clearloop

        jmp *

*=$2000
image:
        !bin "c64-speedracer.data"
        