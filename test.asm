; vim: set ft=acme
*=$0801

	!byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

    lda #0
    sta $9f25

    ; Clear VRAM
    lda #1 
    sta $9f20
    lda #0
    sta $9f21
    lda #$20 ; inc
    sta $9f22

    lda #$01
    ldx #0
    ldy #$20
loop0:
    sta $9f23
    dex
    bne loop0
    dey
    bne loop0

    ; Point to color
    lda #0
    sta $9f25
    lda #1
    sta $9f22
    lda #$fa
    sta $9f21
    lda #0
    sta $9f20
        
    lda #1
    sta $9f25
    lda #1
    sta $9f22
    lda #$fa
    sta $9f21
    lda #1
    sta $9f20

    ; Prepare for raster loop
    sei
    lda #2
    sta $9f26

loop1
    ldx #0
    lda #0
    ldy #0
.cloop
    sta raster_lo,y
    sta raster_hi,y
    dey
    bne .cloop

    ldx ypos
    jsr draw_red

    ldx ypos+1
    jsr draw_green

    ldx ypos+2
    jsr draw_blue

    inc ypos
    dec ypos+1
    inc ypos+2
    inc ypos+2

    lda #2
    sta $9f27

    lda #10
    sta $9f28

    ldy #240

.loop
    lda $9f27
    and #$2
    beq .loop
    sta $9f27
    lda raster_lo,y
    sta $9f23
    lda raster_hi,y
    sta $9f24

    inc $9f28
    dey
    bne .loop

    ;inc $9f37

    lda #0
    sta $9f23
    sta $9f24

    jsr scroller

    jmp loop1
    rts

scroller:

    clc 
    lda $9f37
    adc #1
    cmp #8
    beq .more
    sta $9f37
    rts
.more
    lda #0
    sta $9f37
    rts


copy:
    lda #0
    sta $9f25
    lda #1
    sta $9f22
    lda #$fa
    sta $9f21
    lda #0
    sta $9f20
        
    lda #1
    sta $9f25
    lda #1
    sta $9f22
    lda #$fa
    sta $9f21
    lda #1
    sta $9f20

    lda $9f23
    sta $9f24




textpos: !byte 0

text:
    !text "THIS IS A SCROLLTEXT"

ypos: !byte 0,0,0

draw_red:
    ldy #red_end-red-1
.rloop
    lda red,y
    sta raster_hi,x
    inx
    sta raster_hi,x
    inx
    sta raster_hi,x
    inx
    dey
    bne .rloop
    rts



draw_green:
    ldy #green_end-green-1
.gloop
    lda raster_lo,x
    ora green,y
    sta raster_lo,x
    inx
    sta raster_lo,x
    inx
    sta raster_lo,x
    inx
    dey
    bne .gloop
    rts

draw_blue:
    ldy #blue_end-blue-1
.bloop
    lda raster_lo,x
    ora blue,y
    sta raster_lo,x
    inx
    sta raster_lo,x
    inx
    sta raster_lo,x
    inx
    dey
    bne .bloop
    rts

red:
    !byte 0,2,4,8,10,12,13,14,15,15,14,13,12,10,8,4,2,0
red_end:

green:
    !byte 0, $20,$40,$80,$a0,$c0,$d0,$e0,$f0,$f0,$e0,$d0,$c0,$a0,$80,$40,$20,0
green_end:

blue:
    !byte 0,2,4,8,10,12,13,14,15,15,14,13,12,10,8,4,2,0
blue_end:

raster_lo = $1000
raster_hi = $1100


!macro vset0 .addr {
    lda #0
    sta $9f25
	lda #<(.addr >> 16) | $10
	sta $9f22
	lda #<(.addr >> 8)
	sta $9f21
	lda #<(.addr)
	sta $9f20
}

!macro vset1 .addr {
    lda #1
    sta $9f25
	lda #<(.addr >> 16) | $10
	sta $9f22
	lda #<(.addr >> 8)
	sta $9f21
	lda #<(.addr)
	sta $9f20
}

    !zone

copy_char:

    +vset0 $f800
    +vset1 $0000

.loop0
    lda $9f23

    ldy #8
.loop
    tax
    and #1
    sta $9f24
    txa
    lsr
    dey
    bne .loop

    ;jmp .loop0

    !zone

.loop
    cmp $9f28
    bne .loop


    !zone

    sta $9f28
.loop
    lda $9f27
    and #$2
    beq .loop
    sta $9f27
