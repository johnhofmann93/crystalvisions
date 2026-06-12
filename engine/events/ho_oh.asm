DEF SPECIALHOOHEVENT_HO_OH EQU $84

HoOhFlyoverEvent:
	call DelayFrame
	ld a, [wStateFlags]
	push af
	xor a
	ld [wStateFlags], a
	call LoadHoOhGFX
	call StartHoOhPass1
.loop
	ld a, [wJumptableIndex]
	bit JUMPTABLE_EXIT_F, a
	jr nz, .done
	push bc
	ld a, 36 * OBJ_SIZE
	ld [wCurSpriteOAMAddr], a
	farcall DoNextFrameForAllSprites
	call HoOhEvent_Update
	ld c, 2
	call DelayFrames
	pop bc
	jr .loop

.done
	pop af
	ld [wStateFlags], a
	ret

LoadHoOhGFX:
	farcall ClearSpriteAnims
	ld de, SpecialHoOhGFX
	ld hl, vTiles0 tile SPECIALHOOHEVENT_HO_OH
	lb bc, BANK(SpecialHoOhGFX), 4 * 2
	call Request2bpp
	xor a
	ld [wJumptableIndex], a
	ret

StartHoOhPass1:
	depixel 8, 20, 0, 0
	ld a, SPRITE_ANIM_OBJ_HO_OH
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], SPECIALHOOHEVENT_HO_OH
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_FUNC_HO_OH
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld [hl], 1 ; pass 1
	ld a, 30
	ld [wFrameCounter], a
	ret

HoOhEvent_Update:
	ld hl, wFrameCounter
	ld a, [hl]
	and a
	jr z, .pass_done
	dec [hl]
	; Fire cry at midpoint of passes 2 and 3
	cp 20
	jr nz, .no_cry
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld a, [hl]
	cp 5
	jr z, .cry
	jr .no_cry
.cry
	push bc
	ld a, HO_OH
	call PlayMonCry
	pop bc
.no_cry
	call UpdateHoOhPosition
	ret

.pass_done
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld a, [hl]
	inc a
	ld [hl], a
	cp 2
	jr z, .pause
	cp 3
	jr z, .start_pass2
	cp 4
	jr z, .pause
	cp 5
	jr z, .start_pass3
	cp 6
	jr z, .pause
	; All done
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

.pause
	ld a, 30
	ld [wFrameCounter], a
	ret

.start_pass2:
	farcall ClearSpriteAnims
	call LoadHoOhGFX
	depixel 12, 0, 0, 0
	ld a, SPRITE_ANIM_OBJ_HO_OH
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], SPECIALHOOHEVENT_HO_OH
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_FUNC_HO_OH
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld [hl], 3 ; pass 2
	ld a, 50
	ld [wFrameCounter], a
	ret

.start_pass3:
	farcall ClearSpriteAnims
	call LoadHoOhGFX
	depixel 14, 20, 0, 0
	ld a, SPRITE_ANIM_OBJ_HO_OH
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], SPECIALHOOHEVENT_HO_OH
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_FUNC_HO_OH
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld [hl], 5 ; pass 3
	ld a, 50
	ld [wFrameCounter], a
	ret

UpdateHoOhPosition:
	ld hl, SPRITEANIMSTRUCT_VAR4
	add hl, bc
	ld a, [hl]
	cp 1
	jr z, .pass1
	cp 3
	jr z, .pass2
	cp 5
	jr z, .pass3
	ret  ; pause — do nothing

.pass1
	; Middle right → top center: left and up
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	dec [hl]
	dec [hl]
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	dec [hl]
	jr .flap

.pass2
	; Middle left → bottom center: right and down
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	inc [hl]
	inc [hl]
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	inc [hl]
	jr .flap

.pass3
	; Middle right → top left:
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	dec [hl]
	dec [hl]
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	dec [hl]

.flap
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	inc [hl]
	ld a, [hl]
	and $7
	ret nz
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld a, [hl]
	cp SPECIALHOOHEVENT_HO_OH
	jr z, .frame2
	ld a, SPECIALHOOHEVENT_HO_OH
	jr .done
.frame2
	ld a, SPECIALHOOHEVENT_HO_OH + 4
.done
	ld [hl], a
	ret

SpecialHoOhGFX:
INCBIN "gfx/icons/ho_oh.2bpp"