	const_def 1
	const PINK_PAGE  ; 1
	const GREEN_PAGE ; 2
	const BLUE_PAGE  ; 3
DEF NUM_STAT_PAGES EQU const_value - 1

DEF STAT_PAGE_MASK EQU %00000011
	const_def 4
	const STATS_SCREEN_PLACE_FRONTPIC ; 4
	const STATS_SCREEN_ANIMATE_MON    ; 5
	const STATS_SCREEN_ANIMATE_EGG    ; 6

BattleStatsScreenInit:
	ld a, [wLinkMode]
	cp LINK_MOBILE
	jr nz, StatsScreenInit

	ld a, [wBattleMode]
	and a
	jr z, StatsScreenInit
	jr _MobileStatsScreenInit

StatsScreenInit:
	ld hl, StatsScreenMain
	jr StatsScreenInit_gotaddress

_MobileStatsScreenInit:
	ld hl, StatsScreenMobile
	jr StatsScreenInit_gotaddress

StatsScreenInit_gotaddress:
	ldh a, [hMapAnims]
	push af
	xor a
	ldh [hMapAnims], a ; disable overworld tile animations
	ld a, [wBoxAlignment] ; whether sprite is to be mirrorred
	push af
	ld a, [wJumptableIndex]
	ld b, a
	ld a, [wStatsScreenFlags]
	ld c, a

	push bc
	push hl
	call ClearBGPalettes
	call ClearTilemap
	call UpdateSprites
	farcall StatsScreen_LoadFont
	pop hl
	call _hl_
	call ClearBGPalettes
	call ClearTilemap
	pop bc

	; restore old values
	ld a, b
	ld [wJumptableIndex], a
	ld a, c
	ld [wStatsScreenFlags], a
	pop af
	ld [wBoxAlignment], a
	pop af
	ldh [hMapAnims], a
	ret

StatsScreenMain:
	xor a
	ld [wJumptableIndex], a
	ld [wStatsScreenFlags], a

	ld a, [wStatsScreenFlags]
	and ~STAT_PAGE_MASK
	or PINK_PAGE ; first_page
	ld [wStatsScreenFlags], a

.loop
	ld a, [wJumptableIndex]
	and ~(1 << 7)
	ld hl, StatsScreenPointerTable
	rst JumpTable
	call StatsScreen_WaitAnim
	ld a, [wJumptableIndex]
	bit JUMPTABLE_EXIT_F, a
	jr z, .loop
	ret

StatsScreenMobile:
	xor a
	ld [wJumptableIndex], a
	ld [wStatsScreenFlags], a

	ld a, [wStatsScreenFlags]
	and ~STAT_PAGE_MASK
	or PINK_PAGE ; first_page
	ld [wStatsScreenFlags], a

.loop
	farcall Mobile_SetOverworldDelay
	ld a, [wJumptableIndex]
	and JUMPTABLE_INDEX_MASK
	ld hl, StatsScreenPointerTable
	rst JumpTable
	call StatsScreen_WaitAnim
	farcall MobileComms_CheckInactivityTimer
	jr c, .exit
	ld a, [wJumptableIndex]
	bit JUMPTABLE_EXIT_F, a
	jr z, .loop

.exit
	ret

StatsScreenPointerTable:
	dw MonStatsInit       ; regular pokémon
	dw EggStatsInit       ; egg
	dw StatsScreenWaitCry
	dw EggStatsJoypad
	dw StatsScreen_LoadPage
	dw StatsScreenWaitCry
	dw MonStatsJoypad
	dw StatsScreen_Exit

StatsScreen_WaitAnim:
	ld hl, wStatsScreenFlags
	bit STATS_SCREEN_ANIMATE_EGG, [hl]
	jr nz, .try_anim
	bit STATS_SCREEN_ANIMATE_MON, [hl]
	jr nz, .finish
	call DelayFrame
	ret

.try_anim
	farcall SetUpPokeAnim
	jr nc, .finish
	ld hl, wStatsScreenFlags
	res STATS_SCREEN_ANIMATE_EGG, [hl]
.finish
	ld hl, wStatsScreenFlags
	res STATS_SCREEN_ANIMATE_MON, [hl]
	farcall HDMATransferTilemapToWRAMBank3
	ret

StatsScreen_SetJumptableIndex:
	ld a, [wJumptableIndex]
	and JUMPTABLE_EXIT
	or h
	ld [wJumptableIndex], a
	ret

StatsScreen_Exit:
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

MonStatsInit:
	ld hl, wStatsScreenFlags
	res STATS_SCREEN_ANIMATE_EGG, [hl]
	call ClearBGPalettes
	call ClearTilemap
	farcall HDMATransferTilemapToWRAMBank3
	call StatsScreen_CopyToTempMon
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	call StatsScreen_InitUpperHalf
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_PLACE_FRONTPIC, [hl]
	ld h, 4
	call StatsScreen_SetJumptableIndex
	ret

.egg
	ld h, 1
	call StatsScreen_SetJumptableIndex
	ret

EggStatsInit:
	call EggStatsScreen
	ld a, [wJumptableIndex]
	inc a
	ld [wJumptableIndex], a
	ret

EggStatsJoypad:
	call StatsScreen_GetJoypad
	jr nc, .check
	ld h, 0
	call StatsScreen_SetJumptableIndex
	ret

.check
	bit B_PAD_A, a
	jr nz, .quit
if DEF(_DEBUG)
	cp PAD_START
	jr z, .hatch
endc
	and PAD_DOWN | PAD_UP | PAD_A | PAD_B
	jp StatsScreen_JoypadAction

.quit
	ld h, 7
	call StatsScreen_SetJumptableIndex
	ret

if DEF(_DEBUG)
.hatch
	ld a, [wMonType]
	or a
	jr nz, .skip
	push bc
	push de
	push hl
	ld a, [wCurPartyMon]
	ld bc, PARTYMON_STRUCT_LENGTH
	ld hl, wPartyMon1Happiness
	call AddNTimes
	ld [hl], 1
	ld a, 1
	ld [wTempMonHappiness], a
	ld a, 127
	ld [wStepCount], a
	ld de, .HatchSoonString
	hlcoord 8, 17
	call PlaceString
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_MON, [hl]
	pop hl
	pop de
	pop bc
.skip
	xor a
	jp StatsScreen_JoypadAction

.HatchSoonString:
	db "▶HATCH SOON!@"
endc

StatsScreen_LoadPage:
	call StatsScreen_LoadGFX
	ld hl, wStatsScreenFlags
	res STATS_SCREEN_PLACE_FRONTPIC, [hl]
	ld a, [wJumptableIndex]
	inc a
	ld [wJumptableIndex], a
	ret

MonStatsJoypad:
	call StatsScreen_GetJoypad
	jr nc, .next
	ld h, 0
	call StatsScreen_SetJumptableIndex
	ret

.next
	and PAD_CTRL_PAD | PAD_A | PAD_B
	jp StatsScreen_JoypadAction

StatsScreenWaitCry:
	call IsSFXPlaying
	ret nc
	ld a, [wJumptableIndex]
	inc a
	ld [wJumptableIndex], a
	ret

StatsScreen_CopyToTempMon:
	ld a, [wMonType]
	cp TEMPMON
	jr nz, .not_tempmon
	ld a, [wBufferMonSpecies]
	ld [wCurSpecies], a
	call GetBaseData
	ld hl, wBufferMon
	ld de, wTempMon
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes
	jr .done

.not_tempmon
	farcall CopyMonToTempMon
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .done
	ld a, [wMonType]
	cp BOXMON
	jr c, .done
	farcall CalcTempmonStats
.done
	and a
	ret

StatsScreen_GetJoypad:
	call GetJoypad
	ld a, [wMonType]
	cp TEMPMON
	jr nz, .not_tempmon
	push hl
	push de
	push bc
	farcall StatsScreenDPad
	pop bc
	pop de
	pop hl
	ld a, [wMenuJoypad]
	and PAD_DOWN | PAD_UP
	jr nz, .set_carry
	ld a, [wMenuJoypad]
	jr .clear_carry

.not_tempmon
	ldh a, [hJoyPressed]
.clear_carry
	and a
	ret

.set_carry
	scf
	ret

StatsScreen_JoypadAction:
	push af
	ld a, [wStatsScreenFlags]
	maskbits NUM_STAT_PAGES
	ld c, a
	pop af
	bit B_PAD_B, a
	jp nz, .b_button
	bit B_PAD_LEFT, a
	jr nz, .d_left
	bit B_PAD_RIGHT, a
	jr nz, .d_right
	bit B_PAD_A, a
	jr nz, .a_button
	bit B_PAD_UP, a
	jr nz, .d_up
	bit B_PAD_DOWN, a
	jr nz, .d_down
	jr .done

.d_down
	ld a, [wMonType]
	cp BOXMON
	jr nc, .done
	and a
	ld a, [wPartyCount]
	jr z, .next_mon
	ld a, [wOTPartyCount]
.next_mon
	ld b, a
	ld a, [wCurPartyMon]
	inc a
	cp b
	jr z, .done
	ld [wCurPartyMon], a
	ld b, a
	ld a, [wMonType]
	and a
	jr nz, .load_mon
	ld a, b
	inc a
	ld [wPartyMenuCursor], a
	jr .load_mon

.d_up
	ld a, [wCurPartyMon]
	and a
	jr z, .done
	dec a
	ld [wCurPartyMon], a
	ld b, a
	ld a, [wMonType]
	and a
	jr nz, .load_mon
	ld a, b
	inc a
	ld [wPartyMenuCursor], a
	jr .load_mon

.a_button
	ld a, c
	cp BLUE_PAGE ; last page
	jr z, .b_button
.d_right
	inc c
	ld a, BLUE_PAGE ; last page
	cp c
	jr nc, .set_page
	ld c, PINK_PAGE ; first page
	jr .set_page

.d_left
	dec c
	jr nz, .set_page
	ld c, BLUE_PAGE ; last page
	jr .set_page

.done
	ret

.set_page
	ld a, [wStatsScreenFlags]
	and ~STAT_PAGE_MASK
	or c
	ld [wStatsScreenFlags], a
	ld h, 4
	call StatsScreen_SetJumptableIndex
	ret

.load_mon
	ld h, 0
	call StatsScreen_SetJumptableIndex
	ret

.b_button
	ld h, 7
	call StatsScreen_SetJumptableIndex
	ret

StatsScreen_InitUpperHalf:
	call .PlaceHPBar
	xor a
	ldh [hBGMapMode], a
	ld a, [wBaseDexNo]
	ld [wTextDecimalByte], a
	ld [wCurSpecies], a
	hlcoord 8, 0
	ld [hl], '№'
	inc hl
	ld [hl], '.'
	inc hl
	hlcoord 10, 0
	lb bc, PRINTNUM_LEADINGZEROS | 1, 3
	ld de, wTextDecimalByte
	call PrintNum
	hlcoord 14, 0
	call PrintLevel
	ld hl, .NicknamePointers
	call GetNicknamePointer
	call CopyNickname
	hlcoord 8, 2
	call PlaceString
	hlcoord 18, 0
	call .PlaceGenderChar
	hlcoord 9, 4
	ld a, '/'
	ld [hli], a
	ld a, [wBaseDexNo]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	call PlaceString
	call StatsScreen_PlaceHorizontalDivider
	call StatsScreen_PlacePageSwitchArrows
	call StatsScreen_PlaceShinyIcon
	ret

.PlaceHPBar:
	ld hl, wTempMonHP
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld hl, wTempMonMaxHP
	ld a, [hli]
	ld d, a
	ld e, [hl]
	farcall ComputeHPBarPixels
	ld hl, wCurHPPal
	call SetHPPal
	ld b, SCGB_STATS_SCREEN_HP_PALS
	call GetSGBLayout
	call DelayFrame
	ret

.PlaceGenderChar:
	push hl
	farcall GetGender
	pop hl
	ret c
	ld a, '♂'
	jr nz, .got_gender
	ld a, '♀'
.got_gender
	ld [hl], a
	ret

.NicknamePointers:
	dw wPartyMonNicknames
	dw wOTPartyMonNicknames
	dw sBoxMonNicknames
	dw wBufferMonNickname

StatsScreen_PlaceVerticalDivider: ; unreferenced
; The Japanese stats screen has a vertical divider.
	hlcoord 7, 0
	ld bc, SCREEN_WIDTH
	ld d, SCREEN_HEIGHT
.loop
	ld a, $31 ; vertical divider
	ld [hl], a
	add hl, bc
	dec d
	jr nz, .loop
	ret

StatsScreen_PlaceHorizontalDivider:
	hlcoord 0, 7
	ld b, SCREEN_WIDTH
	ld a, $62 ; horizontal divider (empty HP/exp bar)
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

StatsScreen_PlacePageSwitchArrows:
	hlcoord 12, 6
	ld [hl], '◀'
	hlcoord 19, 6
	ld [hl], '▶'
	ret

StatsScreen_PlaceShinyIcon:
	ld bc, wTempMonDVs
	farcall CheckShininess
	ret nc
	hlcoord 19, 0
	ld [hl], '⁂'
	ret

StatsScreen_LoadGFX:
	ld a, [wBaseDexNo]
	ld [wTempSpecies], a
	ld [wCurSpecies], a
	xor a
	ldh [hBGMapMode], a
	call .ClearBox
	call .PageTilemap
	call .LoadPals
	ld hl, wStatsScreenFlags
	bit STATS_SCREEN_PLACE_FRONTPIC, [hl]
	jr nz, .place_frontpic
	call SetDefaultBGPAndOBP
	ret

.place_frontpic
	call StatsScreen_PlaceFrontpic
	ret

.ClearBox:
	ld a, [wStatsScreenFlags]
	maskbits NUM_STAT_PAGES
	ld c, a
	call StatsScreen_LoadPageIndicators
	hlcoord 0, 8
	lb bc, 10, 20
	call ClearBox
	ret

.LoadPals:
	ld a, [wStatsScreenFlags]
	maskbits NUM_STAT_PAGES
	ld c, a
	farcall LoadStatsScreenPals
	call DelayFrame
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_MON, [hl]
	ret

.PageTilemap:
	ld a, [wStatsScreenFlags]
	maskbits NUM_STAT_PAGES
	dec a
	ld hl, .Jumptable
	rst JumpTable
	ret

.Jumptable:
; entries correspond to *_PAGE constants
	table_width 2
	dw LoadPinkPage
	dw LoadGreenPage
	dw LoadBluePage
	assert_table_length NUM_STAT_PAGES

LoadPinkPage:
	hlcoord 0, 9
	ld b, $0
	predef DrawPlayerHP
	hlcoord 8, 9
	ld [hl], $41 ; right HP/exp bar end cap
	ld de, .Status_Type
	hlcoord 0, 12
	call PlaceString
	ld a, [wTempMonPokerusStatus]
	ld b, a
	and $f
	jr nz, .HasPokerus
	ld a, b
	and $f0
	jr z, .NotImmuneToPkrs
	hlcoord 8, 8
	ld [hl], '.' ; Pokérus immunity dot
.NotImmuneToPkrs:
	ld a, [wMonType]
	cp BOXMON
	jr z, .StatusOK
	hlcoord 6, 13
	push hl
	ld de, wTempMonStatus
	predef PlaceStatusString
	pop hl
	jr nz, .done_status
	jr .StatusOK
.HasPokerus:
	ld de, .PkrsStr
	hlcoord 1, 13
	call PlaceString
	jr .done_status
.StatusOK:
	ld de, .OK_str
	call PlaceString
.done_status
	hlcoord 1, 15
	predef PrintMonTypes
	hlcoord 9, 8
	ld de, SCREEN_WIDTH
	ld b, 10
	ld a, $31 ; vertical divider
.vertical_divider
	ld [hl], a
	add hl, de
	dec b
	jr nz, .vertical_divider
	ld de, .ExpPointStr
	hlcoord 10, 9
	call PlaceString
	hlcoord 17, 14
	call .PrintNextLevel
	hlcoord 13, 10
	lb bc, 3, 7
	ld de, wTempMonExp
	call PrintNum
	call .CalcExpToNextLevel
	hlcoord 13, 13
	lb bc, 3, 7
	ld de, wExpToNextLevel
	call PrintNum
	ld de, .LevelUpStr
	hlcoord 10, 12
	call PlaceString
	ld de, .ToStr
	hlcoord 14, 14
	call PlaceString
	hlcoord 11, 16
	ld a, [wTempMonLevel]
	ld b, a
	ld de, wTempMonExp + 2
	predef FillInExpBar
	hlcoord 10, 16
	ld [hl], $40 ; left exp bar end cap
	hlcoord 19, 16
	ld [hl], $41 ; right exp bar end cap
	ret

.PrintNextLevel:
	ld a, [wTempMonLevel]
	push af
	cp MAX_LEVEL
	jr z, .AtMaxLevel
	inc a
	ld [wTempMonLevel], a
.AtMaxLevel:
	call PrintLevel
	pop af
	ld [wTempMonLevel], a
	ret

.CalcExpToNextLevel:
	ld a, [wTempMonLevel]
	cp MAX_LEVEL
	jr z, .AlreadyAtMaxLevel
	inc a
	ld d, a
	farcall CalcExpAtLevel
	ld hl, wTempMonExp + 2
	ld hl, wTempMonExp + 2
	ldh a, [hQuotient + 3]
	sub [hl]
	dec hl
	ld [wExpToNextLevel + 2], a
	ldh a, [hQuotient + 2]
	sbc [hl]
	dec hl
	ld [wExpToNextLevel + 1], a
	ldh a, [hQuotient + 1]
	sbc [hl]
	ld [wExpToNextLevel], a
	ret

.AlreadyAtMaxLevel:
	ld hl, wExpToNextLevel
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

.Status_Type:
	db   "STATUS/"
	next "TYPE/@"

.OK_str:
	db "OK @"

.ExpPointStr:
	db "EXP POINTS@"

.LevelUpStr:
	db "LEVEL UP@"

.ToStr:
	db "TO@"

.PkrsStr:
	db "#RUS@"

LoadGreenPage:
	ld de, .Item
	hlcoord 0, 8
	call PlaceString
	call .GetItemName
	hlcoord 8, 8
	call PlaceString
	ld de, .Move
	hlcoord 0, 10
	call PlaceString
	ld hl, wTempMonMoves
	ld de, wListMoves_MoveIndicesBuffer
	ld bc, NUM_MOVES
	call CopyBytes
	hlcoord 8, 10
	ld a, SCREEN_WIDTH * 2
	ld [wListMovesLineSpacing], a
	predef ListMoves
	hlcoord 12, 11
	ld a, SCREEN_WIDTH * 2
	ld [wListMovesLineSpacing], a
	predef ListMovePP
	ret

.GetItemName:
	ld de, .ThreeDashes
	ld a, [wTempMonItem]
	and a
	ret z
	ld b, a
	farcall TimeCapsule_ReplaceTeruSama
	ld a, b
	ld [wNamedObjectIndex], a
	call GetItemName
	ret

.Item:
	db "ITEM@"

.ThreeDashes:
	db "---@"

.Move:
	db "MOVE@"

LoadBluePage:
; 3-column stat table: current value / IV / stat exp, for all 6 stats.
	ld de, .StatHeader
	hlcoord 6, 8
	call PlaceString
	ld de, .IVHeader
	hlcoord 10, 8
	call PlaceString
	ld de, .ExpHeader
	hlcoord 13, 8
	call PlaceString

	ld de, .HPName
	hlcoord 3, 9
	call PlaceString
	ld de, wTempMonMaxHP
	hlcoord 6, 9
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_HP
	hlcoord 10, 9
	call .PrintIV
	ld de, wTempMonHPExp
	hlcoord 13, 9
	lb bc, 2, 5
	call PrintNum

	ld de, .AtkName
	hlcoord 2, 10
	call PlaceString
	ld de, wTempMonAttack
	hlcoord 6, 10
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_ATK
	hlcoord 10, 10
	call .PrintIV
	ld de, wTempMonAtkExp
	hlcoord 13, 10
	lb bc, 2, 5
	call PrintNum

	ld de, .DefName
	hlcoord 2, 11
	call PlaceString
	ld de, wTempMonDefense
	hlcoord 6, 11
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_DEF
	hlcoord 10, 11
	call .PrintIV
	ld de, wTempMonDefExp
	hlcoord 13, 11
	lb bc, 2, 5
	call PrintNum

	ld de, .SatkName
	hlcoord 0, 12
	call PlaceString
	ld de, wTempMonSpclAtk
	hlcoord 6, 12
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_SATK
	hlcoord 10, 12
	call .PrintIV
	ld de, wTempMonSpcExp
	hlcoord 13, 12
	lb bc, 2, 5
	call PrintNum

	ld de, .SdefName
	hlcoord 0, 13
	call PlaceString
	ld de, wTempMonSpclDef
	hlcoord 6, 13
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_SDEF
	hlcoord 10, 13
	call .PrintIV
	ld de, wTempMonSpcExp
	hlcoord 13, 13
	lb bc, 2, 5
	call PrintNum

	ld de, .SpdName
	hlcoord 0, 14
	call PlaceString
	ld de, wTempMonSpeed
	hlcoord 6, 14
	lb bc, 2, 3
	call PrintNum
	ld c, STAT_SPD
	hlcoord 10, 14
	call .PrintIV
	ld de, wTempMonSpdExp
	hlcoord 13, 14
	lb bc, 2, 5
	call PrintNum

	call StatsScreen_LoadHiddenPowerFont



	ld de, wTempMonDVs
	farcall CalcHiddenPower
	; farcall clobbers a on return; read the type from e instead (see
	; CalcHiddenPower's out: comment in engine/battle/hidden_power.asm).
	; wNamedObjectIndex and wTextDecimalByte are the same byte (see
	; ram/wram.asm), so print the power now, before writing the type
	; into wNamedObjectIndex clobbers it.
	ld a, d
	ld [wTextDecimalByte], a
	ld a, e
	push af
	ld de, wTextDecimalByte
	hlcoord 8, 16
	lb bc, 1, 2
	call PrintNum

	pop af
	ld [wNamedObjectIndex], a
	farcall GetTypeName
	ld de, wStringBuffer1
	hlcoord 0, 16
	call PlaceString_UnownFont
	ret

.HiddenPowerName:
	db "HIDDEN POWER@"

.BPName:
	db "BP@"

.PrintIV:
; c = STAT_HP..STAT_SDEF, hl = destination tilemap coord.
	push hl
	call .GetStatIV
	ld [wTextDecimalByte], a
	pop hl
	ld de, wTextDecimalByte
	lb bc, 1, 2
	call PrintNum
	ret

.GetStatIV:
; c = STAT_HP..STAT_SDEF. Returns a = that stat's IV (0-15).
; Mirrors the DV layout/formula in CalcMonStatC (move_mon.asm):
; wTempMonDVs+0 = Attack (hi nybble) / Defense (lo nybble)
; wTempMonDVs+1 = Speed (hi nybble) / Special (lo nybble)
; HP = (Atk&1)<<3 | (Def&1)<<2 | (Spd&1)<<1 | (Spc&1)
	ld hl, wTempMonDVs
	ld a, c
	cp STAT_ATK
	jr z, .iv_atk
	cp STAT_DEF
	jr z, .iv_def
	cp STAT_SPD
	jr z, .iv_spd
	cp STAT_SATK
	jr z, .iv_spc
	cp STAT_SDEF
	jr z, .iv_spc

; STAT_HP
	ld a, [hl]
	swap a
	and 1
	add a
	add a
	add a
	ld b, a
	ld a, [hli]
	and 1
	add a
	add a
	add b
	ld b, a
	ld a, [hl]
	swap a
	and 1
	add a
	add b
	ld b, a
	ld a, [hl]
	and 1
	add b
	ret

.iv_atk
	ld a, [hl]
	swap a
	and $f
	ret

.iv_def
	ld a, [hl]
	and $f
	ret

.iv_spd
	inc hl
	ld a, [hl]
	swap a
	and $f
	ret

.iv_spc
	inc hl
	ld a, [hl]
	and $f
	ret

.StatHeader:
	db "VAL@"

.IVHeader:
	db "DV@"

.ExpHeader:
	db "EXP@"

.HPName:
	db "HP@"

.AtkName:
	db "ATK@"

.DefName:
	db "DEF@"

.SpdName:
	db "SPEED@"

.SatkName:
	db "SpATK@"

.SdefName:
	db "SpDEF@"

StatsScreen_LoadHiddenPowerFont:
; Load the Unown alphabet into VRAM tile slots with no charmap character
; mapped to them (see constants/charmap.asm), so nothing else on screen —
; on any page, not just this one — is ever disturbed by the overwrite.
	ld a, BANK(sScratch)
	call OpenSRAM
	ld hl, UnownFont
	ld de, sScratch + $188
	ld bc, 26 tiles
	ld a, BANK(UnownFont)
	call FarCopyBytes

	; A-F -> 6-tile gap after "z" ($ba-$bf)
	ld de, sScratch + $188
	ld hl, vTiles1 tile $3a
	lb bc, BANK(StatsScreen_LoadHiddenPowerFont), 6
	call Request2bpp

	; G-P -> 10-tile gap after "u"/"ü" ($c6-$cf)
	ld de, sScratch + $188 + 6 tiles
	ld hl, vTiles1 tile $46
	lb bc, BANK(StatsScreen_LoadHiddenPowerFont), 10
	call Request2bpp

	; Q-X -> 8-tile gap after "'v" ($d7-$de)
	ld de, sScratch + $188 + 16 tiles
	ld hl, vTiles1 tile $57
	lb bc, BANK(StatsScreen_LoadHiddenPowerFont), 8
	call Request2bpp

	; Y-Z -> 2-tile gap between "-" and "?" ($e4-$e5)
	ld de, sScratch + $188 + 24 tiles
	ld hl, vTiles1 tile $64
	lb bc, BANK(StatsScreen_LoadHiddenPowerFont), 2
	call Request2bpp

	call CloseSRAM
	ret

PlaceString_UnownFont:
; Print the @-terminated string at de, at hl, using the Unown-glyph tiles
; loaded by StatsScreen_LoadHiddenPowerFont instead of the normal font.
.loop
	ld a, [de]
	inc de
	cp "@"
	ret z
	cp " "
	jr z, .space
	sub "A"
	push de
	push hl
	ld d, 0
	ld e, a
	ld hl, UnownFontTileMap
	add hl, de
	ld a, [hl]
	pop hl
	pop de
	ld [hli], a
	jr .loop
.space
	ld [hl], " "
	inc hl
	jr .loop

UnownFontTileMap:
; Indexed by letter - "A" (0-25); values are the BG tile numbers
; each letter was loaded to by StatsScreen_LoadHiddenPowerFont.
	db $ba, $bb, $bc, $bd, $be, $bf ; A-F
	db $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf ; G-P
	db $d7, $d8, $d9, $da, $db, $dc, $dd, $de ; Q-X
	db $e4, $e5 ; Y-Z

IDNoString:
	db "<ID>№.@"

OTString:
	db "OT/@"

StatsScreen_PlaceFrontpic:
	ld hl, wTempMonDVs
	predef GetUnownLetter
	call StatsScreen_GetAnimationParam
	jr c, .egg
	and a
	jr z, .no_cry
	jr .cry

.egg
	call .AnimateEgg
	call SetDefaultBGPAndOBP
	ret

.no_cry
	call .AnimateMon
	call SetDefaultBGPAndOBP
	ret

.cry
	call SetDefaultBGPAndOBP
	call .AnimateMon
	ld a, [wCurPartySpecies]
	call PlayMonCry2
	ret

.AnimateMon:
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_MON, [hl]
	ld a, [wCurPartySpecies]
	cp UNOWN
	jr z, .unown
	hlcoord 0, 0
	call PrepMonFrontpic
	ret

.unown
	xor a
	ld [wBoxAlignment], a
	hlcoord 0, 0
	call _PrepMonFrontpic
	ret

.AnimateEgg:
	ld a, [wCurPartySpecies]
	cp UNOWN
	jr z, .unownegg
	ld a, TRUE
	ld [wBoxAlignment], a
	call .get_animation
	ret

.unownegg
	xor a
	ld [wBoxAlignment], a
	call .get_animation
	ret

.get_animation
	ld a, [wCurPartySpecies]
	call IsAPokemon
	ret c
	call StatsScreen_LoadTextboxSpaceGFX
	ld de, vTiles2 tile $00
	predef GetAnimatedFrontpic
	hlcoord 0, 0
	ld d, $0
	ld e, ANIM_MON_MENU
	predef LoadMonAnimation
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_EGG, [hl]
	ret

StatsScreen_GetAnimationParam:
	ld a, [wMonType]
	ld hl, .Jumptable
	rst JumpTable
	ret

.Jumptable:
	dw .PartyMon
	dw .OTPartyMon
	dw .BoxMon
	dw .Tempmon
	dw .Wildmon

.PartyMon:
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld b, h
	ld c, l
	jr .CheckEggFaintedFrzSlp

.OTPartyMon:
	xor a
	ret

.BoxMon:
	ld hl, sBoxMons
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	call AddNTimes
	ld b, h
	ld c, l
	ld a, BANK(sBoxMons)
	call OpenSRAM
	call .CheckEggFaintedFrzSlp
	push af
	call CloseSRAM
	pop af
	ret

.Tempmon:
	ld bc, wTempMonSpecies
	jr .CheckEggFaintedFrzSlp ; utterly pointless

.CheckEggFaintedFrzSlp:
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	call CheckFaintedFrzSlp
	jr c, .FaintedFrzSlp
.egg
	xor a
	scf
	ret

.Wildmon:
	ld a, $1
	and a
	ret

.FaintedFrzSlp:
	xor a
	ret

StatsScreen_LoadTextboxSpaceGFX:
	nop
	push hl
	push de
	push bc
	push af
	call DelayFrame
	ldh a, [rVBK]
	push af
	ld a, $1
	ldh [rVBK], a
	ld de, TextboxSpaceGFX
	lb bc, BANK(TextboxSpaceGFX), 1
	ld hl, vTiles2 tile ' '
	call Get2bpp
	pop af
	ldh [rVBK], a
	pop af
	pop bc
	pop de
	pop hl
	ret

StatsScreenSpaceGFX: ; unreferenced
INCBIN "gfx/font/space.2bpp"

EggStatsScreen:
	xor a
	ldh [hBGMapMode], a
	ld hl, wCurHPPal
	call SetHPPal
	ld b, SCGB_STATS_SCREEN_HP_PALS
	call GetSGBLayout
	call StatsScreen_PlaceHorizontalDivider
	ld de, EggString
	hlcoord 8, 1
	call PlaceString
	ld de, IDNoString
	hlcoord 8, 3
	call PlaceString
	ld de, OTString
	hlcoord 8, 5
	call PlaceString
	ld de, FiveQMarkString
	hlcoord 11, 3
	call PlaceString
	ld de, FiveQMarkString
	hlcoord 11, 5
	call PlaceString
if DEF(_DEBUG)
	ld de, .PushStartString
	hlcoord 8, 17
	call PlaceString
	jr .placed_push_start

.PushStartString:
	db "▶PUSH START.@"

.placed_push_start
endc
	ld a, [wTempMonHappiness] ; egg status
	ld de, EggSoonString
	cp $6
	jr c, .picked
	ld de, EggCloseString
	cp $b
	jr c, .picked
	ld de, EggMoreTimeString
	cp $29
	jr c, .picked
	ld de, EggALotMoreTimeString
.picked
	hlcoord 1, 9
	call PlaceString
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_MON, [hl]
	call SetDefaultBGPAndOBP
	call DelayFrame
	hlcoord 0, 0
	call PrepMonFrontpic
	farcall HDMATransferTilemapToWRAMBank3
	call StatsScreen_AnimateEgg

	ld a, [wTempMonHappiness]
	cp 6
	ret nc
	ld de, SFX_2_BOOPS
	call PlaySFX
	ret

EggString:
	db "EGG@"

FiveQMarkString:
	db "?????@"

EggSoonString:
	db   "It's making sounds"
	next "inside. It's going"
	next "to hatch soon!@"

EggCloseString:
	db   "It moves around"
	next "inside sometimes."
	next "It must be close"
	next "to hatching.@"

EggMoreTimeString:
	db   "Wonder what's"
	next "inside? It needs"
	next "more time, though.@"

EggALotMoreTimeString:
	db   "This EGG needs a"
	next "lot more time to"
	next "hatch.@"

StatsScreen_AnimateEgg:
	call StatsScreen_GetAnimationParam
	ret nc
	ld a, [wTempMonHappiness]
	ld e, $7
	cp 6
	jr c, .animate
	ld e, $8
	cp 11
	jr c, .animate
	ret

.animate
	push de
	ld a, $1
	ld [wBoxAlignment], a
	call StatsScreen_LoadTextboxSpaceGFX
	ld de, vTiles2 tile $00
	predef GetAnimatedFrontpic
	pop de
	hlcoord 0, 0
	ld d, $0
	predef LoadMonAnimation
	ld hl, wStatsScreenFlags
	set STATS_SCREEN_ANIMATE_EGG, [hl]
	ret

StatsScreen_LoadPageIndicators:
	hlcoord 13, 5
	ld a, $36 ; first of 4 small square tiles
	call .load_square
	hlcoord 15, 5
	ld a, $36 ; " " " "
	call .load_square
	hlcoord 17, 5
	ld a, $36 ; " " " "
	call .load_square
	ld a, c
	cp GREEN_PAGE
	ld a, $3a ; first of 4 large square tiles
	hlcoord 13, 5 ; PINK_PAGE (< GREEN_PAGE)
	jr c, .load_square
	hlcoord 15, 5 ; GREEN_PAGE (= GREEN_PAGE)
	jr z, .load_square
	hlcoord 17, 5 ; BLUE_PAGE (> GREEN_PAGE)
.load_square
	push bc
	ld [hli], a
	inc a
	ld [hld], a
	ld bc, SCREEN_WIDTH
	add hl, bc
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	pop bc
	ret

CopyNickname:
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	jr .okay ; utterly pointless
.okay
	ld a, [wMonType]
	cp BOXMON
	jr nz, .partymon
	ld a, BANK(sBoxMonNicknames)
	call OpenSRAM
	push de
	call CopyBytes
	pop de
	call CloseSRAM
	ret

.partymon
	push de
	call CopyBytes
	pop de
	ret

GetNicknamePointer:
	ld a, [wMonType]
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wMonType]
	cp TEMPMON
	ret z
	ld a, [wCurPartyMon]
	jp SkipNames

CheckFaintedFrzSlp:
	ld hl, MON_HP
	add hl, bc
	ld a, [hli]
	or [hl]
	jr z, .fainted_slp
	ld hl, MON_STATUS
	add hl, bc
	ld a, [hl]
	and SLP_MASK
	jr nz, .fainted_slp
	and a
	ret

.fainted_slp
	scf
	ret
