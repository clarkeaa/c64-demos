!cpu 6502
!to "raining.prg",cbm    ; output file

;;; --------------------------------------------------
* = $0801                           ; BASIC start address (#2049)
!byte $0d,$08,$dc,$07               ; BASIC loader
!byte $9e,$20                       ; sys
!text "49152"        
!byte $00

;;; --------------------------------------------------
        
speed = $1          ;60
num_chars = 8
        
;;; --------------------------------------------------
* = $c000

main:
        jsr clear
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
        jmp *        ; infinite loop

;;; --------------------------------------------------
;;; a = free
;;; x = memory offset
;;; y = free
;;; .src = source
;;; .dst = destination
!macro transfer_char .src, .dst {
        lda .src,x
        cmp #$ff
        beq .space
        tay
        lda char_seq,y
        dec .src,x
        jmp .exit
.space:
        lda #$20
.exit:   
        sta .dst,x
}        

;;; --------------------------------------------------
!macro add16 op1, op2, res {
        clc
        lda op1
        adc op2
        sta res
        lda op1+1
        adc op2+1
        sta res+1        
}
        
;;; --------------------------------------------------
;;; a = in=free, out=value
;;; x = in/out=input memory offset
;;; y = in=free
;;; $FB = vector to array
move_head: 
        txa
        tay
        +add16 $FB,.adder,$FB
        lda #(num_chars-1)
        sta ($FB),y
        rts
.adder:
        !byte $28,$00           ; 40
                
;;; --------------------------------------------------
;;; a = free
;;; x = memory offset
;;; y = free
;;; .src = source
!macro update .src {
        lda .src,x
        cmp #$ff
        beq .exit_update
        cmp #(num_chars-2)
        bne .exit_update
        lda #<.src
        sta $FB
        lda #>.src
        sta $FB+1
        jsr move_head
.exit_update:
}
        
;;; --------------------------------------------------
irq:    dec $d019    ; acknowledge IRQ

        dec .speed_counter
        beq .on_tick
        jmp $ea81    ; return to kernel interrupt routine
.on_tick:        
        lda #speed
        sta .speed_counter

        ldx #$00
.draw_loop:
        +transfer_char workspace_0, $0400
        +transfer_char workspace_1, $0500
        +transfer_char workspace_2, $0600
        +transfer_char workspace_3, $0700
        dex
        bne .draw_loop

        ldx #$00
.update_loop:
        +update workspace_0
        +update workspace_1
        +update workspace_2
        +update workspace_3
        dex
        bne .update_loop

        jsr spawn
        
.exit_irq:   
        jmp $ea81    ; return to kernel interrupt routine
.speed_counter:
        !byte speed

;;; -------------------------------------------------
spawn:
        lda .start_offset
        cmp #40
        bcs .dont_spawn
        tax
        lda #(num_chars-1)
        sta workspace_0,x
        txa
.dont_spawn:     
        clc
        adc #71
        sta .start_offset
        rts
.start_offset:
        !byte $0d            ;13

;;; --------------------------------------------------
clear:  
        lda #$00
        sta $d020
        sta $d021
        tax
        lda #$20
.clearloop:      
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne .clearloop
        rts

;;; --------------------------------------------------
char_seq:
        !byte $2e,$5d,$67,$76,$e1,$f5,$e7,$e0
*=$c600
workspace:
workspace_0:
        !fill $100, $ff
workspace_1:      
        !fill $100, $ff
workspace_2:      
        !fill $100, $ff
workspace_3:      
        !fill $100, $ff
