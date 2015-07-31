!cpu 6502
!to "sidplay.prg",cbm    ; output file

;;; --------------------------------------------------
sid_start = $1035    
sid_init = $1035
sid_play = $1038        
        
;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0d,$08,$dc,$07               ; BASIC loader
!byte $9e,$20                       ; sys
!text "49152"        
!byte $00
        
;;; --------------------------------------------------
* = sid_start
!bin "S-Express.sid",,$7e
        
;;; --------------------------------------------------
* = $c000
        sei           ; set interrupt disable flag

        jsr sid_init
        
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
        jmp *        ; infinite loop
        
;;; --------------------------------------------------
irq:    dec $d019    ; acknowledge IRQ

.exit:
        inc $d020               ; inc border colour
        jsr sid_play
        dec $d020    ; dec border colour
        jmp $ea81    ; return to kernel interrupt routine
        
.counter:
        !byte $00
        
