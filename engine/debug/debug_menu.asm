; All-purpose debug menu, opened from the Start Menu.
; Lets the player give any Pokemon, give any item, warp to any city,
; set/clear any event flag, or start a wild battle against any species/level.

DebugMenuScript::
	loadmenu DebugMenu_MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .GiveMon
	ifequal 2, .GiveItem
	ifequal 3, .Warp
	ifequal 4, .SetFlag
	ifequal 5, .WildBattle
	end

.GiveMon:
	special DebugGiveMon
	end

.GiveItem:
	special DebugGiveItem
	end

.SetFlag:
	special DebugSetFlag
	end

.WildBattle:
	special DebugPickWildMon
	startbattle
	reloadmapafterbattle
	end

.Warp:
	loadmenu DebugWarp_MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .NewBark
	ifequal 2, .Cherrygrove
	ifequal 3, .Violet
	ifequal 4, .Azalea
	ifequal 5, .Goldenrod
	ifequal 6, .Ecruteak
	ifequal 7, .Olivine
	ifequal 8, .Cianwood
	ifequal 9, .Mahogany
	ifequal 10, .Blackthorn
	end

.NewBark:
	warp NEW_BARK_TOWN, 8, 10
	end

.Cherrygrove:
	warp CHERRYGROVE_POKECENTER_1F, 4, 7
	end

.Violet:
	warp VIOLET_POKECENTER_1F, 4, 7
	end

.Azalea:
	warp AZALEA_POKECENTER_1F, 4, 7
	end

.Goldenrod:
	warp GOLDENROD_POKECENTER_1F, 4, 7
	end

.Ecruteak:
	warp ECRUTEAK_POKECENTER_1F, 4, 7
	end

.Olivine:
	warp OLIVINE_POKECENTER_1F, 4, 7
	end

.Cianwood:
	warp CIANWOOD_POKECENTER_1F, 4, 7
	end

.Mahogany:
	warp MAHOGANY_POKECENTER_1F, 4, 7
	end

.Blackthorn:
	warp BLACKTHORN_POKECENTER_1F, 4, 7
	end

DebugMenu_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option
.MenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items
	db "Give Pokemon@"
	db "Give Item@"
	db "Warp@"
	db "Set Flag@"
	db "Wild Battle@"

DebugWarp_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option
.MenuData:
	db STATICMENU_CURSOR ; flags
	db 10 ; items
	db "New Bark Town@"
	db "Cherrygrove City@"
	db "Violet City@"
	db "Azalea Town@"
	db "Goldenrod City@"
	db "Ecruteak City@"
	db "Olivine City@"
	db "Cianwood City@"
	db "Mahogany Town@"
	db "Blackthorn City@"


; --- Number picker ---
; A small on-screen counter, adjusted with the d-pad and confirmed with A.
;   Up/Down: +-1 (wraps between 1 and max)
;   Left/Right: +-10 (clamps to 1..max)
;   B: cancel
; Input: de = max value (1..de)
; Output: de = selected value; carry set if the player cancelled.
DebugMenu_PickNumber::
	ld a, e
	ld [wDebugPickerMax], a
	ld a, d
	ld [wDebugPickerMax + 1], a
	ld a, 1
	ld [wDebugPickerValue], a
	xor a
	ld [wDebugPickerValue + 1], a
	ld hl, DebugPicker_MenuHeader
	call LoadMenuHeader
.loop
	call DebugMenu_UpdatePickerDisplay
	call DebugMenu_InterpretPickerJoypad
	jr nc, .loop
	cp -1
	jr nz, .selected
	scf
	ret

.selected
	ld a, [wDebugPickerValue]
	ld e, a
	ld a, [wDebugPickerValue + 1]
	ld d, a
	and a
	ret

DebugMenu_UpdatePickerDisplay:
	call MenuBox
	call MenuBoxCoord2Tile
	ld de, wDebugPickerValue
	lb bc, PRINTNUM_LEADINGZEROS | 1, 3
	call PrintNum
	ret

DebugMenu_InterpretPickerJoypad:
	call JoyTextDelay_ForcehJoyDown
	bit B_PAD_B, c
	jr nz, .b
	bit B_PAD_A, c
	jr nz, .a
	bit B_PAD_DOWN, c
	jr nz, .down
	bit B_PAD_UP, c
	jr nz, .up
	bit B_PAD_LEFT, c
	jr nz, .left
	bit B_PAD_RIGHT, c
	jr nz, .right
	and a
	ret

.b
	ld a, -1
	scf
	ret

.a
	xor a
	scf
	ret

.down
	ld hl, wDebugPickerValue
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec de
	ld a, d
	or e
	jr nz, .down_store
	ld a, [wDebugPickerMax]
	ld e, a
	ld a, [wDebugPickerMax + 1]
	ld d, a
.down_store
	ld a, e
	ld [wDebugPickerValue], a
	ld a, d
	ld [wDebugPickerValue + 1], a
	and a
	ret

.up
	ld hl, wDebugPickerValue
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc de
	ld a, [wDebugPickerMax]
	ld l, a
	ld a, [wDebugPickerMax + 1]
	ld h, a
	ld a, l
	sub e
	ld a, h
	sbc d
	jr nc, .up_store
	ld de, 1
.up_store
	ld a, e
	ld [wDebugPickerValue], a
	ld a, d
	ld [wDebugPickerValue + 1], a
	and a
	ret

.left
	ld hl, wDebugPickerValue
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, e
	sub 10
	ld e, a
	ld a, d
	sbc 0
	ld d, a
	jr c, .left_min
	ld a, d
	or e
	jr nz, .left_store
.left_min
	ld de, 1
.left_store
	ld a, e
	ld [wDebugPickerValue], a
	ld a, d
	ld [wDebugPickerValue + 1], a
	and a
	ret

.right
	ld hl, wDebugPickerValue
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, e
	add 10
	ld e, a
	ld a, d
	adc 0
	ld d, a
	ld a, [wDebugPickerMax]
	ld l, a
	ld a, [wDebugPickerMax + 1]
	ld h, a
	ld a, l
	sub e
	ld a, h
	sbc d
	jr nc, .right_store
	ld d, h
	ld e, l
.right_store
	ld a, e
	ld [wDebugPickerValue], a
	ld a, d
	ld [wDebugPickerValue + 1], a
	and a
	ret

DebugPicker_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 1, 0, 6, 2
	dw .NoDisplay
	db 0 ; default option
.NoDisplay:
	ret


; --- Specials ---
; These run mid-script via the `special` command (see data/events/special_pointers.asm).

DebugGiveMon:
	ld de, NUM_POKEMON
	call DebugMenu_PickNumber
	ret c
	ld a, e
	ld [wCurPartySpecies], a
	ld de, MAX_LEVEL
	call DebugMenu_PickNumber
	ret c
	ld a, e
	ld [wCurPartyLevel], a
	xor a
	ld [wCurItem], a
	ld b, a ; trainer flag: wild-style gift, single nickname prompt
	farcall GivePoke
	ret

DebugGiveItem:
	ld de, NUM_ITEMS
	call DebugMenu_PickNumber
	ret c
	ld a, e
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantityChange], a
	ld hl, wNumItems
	call ReceiveItem
	ret

DebugSetFlag:
	ld de, NUM_EVENTS - 1
	call DebugMenu_PickNumber
	ret c
	push de
	ld hl, DebugSetOrClear_MenuHeader
	call LoadMenuHeader
	call VerticalMenu
	call CloseWindow
	pop de
	jr c, .cancelled
	ld a, [wMenuCursorY]
	cp 1
	ld b, RESET_FLAG
	jr nz, .go
	ld b, SET_FLAG
.go
	call EventFlagAction
.cancelled
	ret

DebugSetOrClear_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option
.MenuData:
	db STATICMENU_CURSOR ; flags
	db 2 ; items
	db "Set@"
	db "Clear@"

DebugPickWildMon:
	ld de, NUM_POKEMON
	call DebugMenu_PickNumber
	ret c
	ld a, e
	ld [wTempWildMonSpecies], a
	ld de, MAX_LEVEL
	call DebugMenu_PickNumber
	ret c
	ld a, e
	ld [wCurPartyLevel], a
	ld a, 1 << 7
	ld [wBattleScriptFlags], a
	ret
