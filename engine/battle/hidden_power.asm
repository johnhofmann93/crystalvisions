HiddenPowerDamage:
; Override Hidden Power's type and power based on the user's DVs.

	ld de, wBattleMonDVs
	ldh a, [hBattleTurn]
	and a
	jr z, .got_dvs
	ld de, wEnemyMonDVs
.got_dvs
	call CalcHiddenPower
	; a = type, d = power

; Overwrite the current move type.
	push af
	ld a, BATTLE_VARS_MOVE_TYPE
	call GetBattleVarAddr
	pop af
	ld [hl], a

; Get the rest of the damage formula variables
; based on the new type, but keep base power.
	ld a, d
	push af
	farcall BattleCommand_DamageStats ; damagestats
	pop af
	ld d, a
	ret

CalcHiddenPower::
; Compute Hidden Power's type, base power, and secondary effect slot from a
; mon's DVs.
; in: de = pointer to that mon's 2-byte DVs.
; out: a = type (TypeNames/PrintType-compatible index), d = power (31-70),
; c = secondary effect index (0-15, see HiddenPowerEffects).
; e also holds the type on return: the `farcall` trampoline (ReturnFarCall)
; clobbers `a` with leftover garbage while restoring the ROM bank, but it
; never touches b/c/d/e/h/l, so callers reaching this via `farcall` (rather
; than a same-bank `call`) must read the type from e instead of a.

	ld h, d
	ld l, e

; Power:

; Take the top bit from each stat

	; Attack
	ld a, [hl]
	swap a
	and %1000

	; Defense
	ld b, a
	ld a, [hli]
	and %1000
	srl a
	or b

	; Speed
	ld b, a
	ld a, [hl]
	swap a
	and %1000
	srl a
	srl a
	or b

	; Special
	ld b, a
	ld a, [hl]
	and %1000
	srl a
	srl a
	srl a
	or b

; Multiply by 5
	ld b, a
	add a
	add a
	add b

; Add Special & 3
	ld b, a
	ld a, [hld]
	and %0011
	add b

; Divide by 2 and add 30 + 1
	srl a
	add 30
	inc a

	ld d, a

; Type:

	; Def & 3
	ld a, [hl]
	and %0011
	ld b, a

	; + (Atk & 3) << 2
	ld a, [hl]
	and %0011 << 4
	swap a
	add a
	add a
	or b

; Skip Normal
	inc a

; Skip Bird
	cp BIRD
	jr c, .done
	inc a

; Skip unused types
	cp UNUSED_TYPES
	jr c, .done
	add UNUSED_TYPES_END - UNUSED_TYPES

.done
	ld e, a

; Secondary effect index (0-15), from DV bits the type/power math above
; never touches: Speed's bottom 3 bits (index bits 0-2) and Defense's bit 2
; (index bit 3). h/l still point at the DVs' first byte (Attack/Defense).
	ld a, [hl]
	and %0100
	add a
	ld b, a
	inc hl
	ld a, [hl]
	swap a
	and %0111
	or b
	ld c, a

	ret

RerollHiddenPower::
; Recompute Hidden Power's type, power, and secondary effect from the
; user's DVs; overwrite the move's type and power in place; return the
; secondary effect's real EFFECT_* constant.
; out: e = EFFECT_* to run this turn instead of EFFECT_HIDDEN_POWER
; (farcall clobbers a on return, same caveat as CalcHiddenPower).

	ld de, wBattleMonDVs
	ldh a, [hBattleTurn]
	and a
	jr z, .got_dvs
	ld de, wEnemyMonDVs
.got_dvs
	call CalcHiddenPower
	; a = type, d = power, e = type (dup), c = effect index 0-15

; Overwrite the current move type.
	push af
	ld a, BATTLE_VARS_MOVE_TYPE
	call GetBattleVarAddr
	pop af
	ld [hl], a

; Overwrite the current move power.
	ld a, BATTLE_VARS_MOVE_POWER
	call GetBattleVarAddr
	ld [hl], d

; Map the effect index to a real EFFECT_* constant.
	ld hl, HiddenPowerEffects
	ld b, 0
	add hl, bc
	ld e, [hl]
	ret

HiddenPowerEffects:
; indexed by CalcHiddenPower's effect index (0-15)
	db EFFECT_BURN_HIT
	db EFFECT_PARALYZE_HIT
	db EFFECT_POISON_HIT
	db EFFECT_FREEZE_HIT ; frostbite
	db EFFECT_FLINCH_HIT
	db EFFECT_LEECH_HIT
	db EFFECT_ATTACK_DOWN_HIT
	db EFFECT_DEFENSE_DOWN_HIT
	db EFFECT_SP_ATK_DOWN_HIT
	db EFFECT_SP_DEF_DOWN_HIT
	db EFFECT_SPEED_DOWN_HIT
	db EFFECT_ATTACK_UP_HIT
	db EFFECT_DEFENSE_UP_HIT
	db EFFECT_SP_ATK_UP_HIT
	db EFFECT_SP_DEF_UP_HIT
	db EFFECT_SPEED_UP_HIT

GetHiddenPowerEffectName::
; Copy the name of secondary effect index [wNamedObjectIndex] (0-15, see
; HiddenPowerEffects) to wStringBuffer1.
; Takes its argument from memory rather than a, since this is called via
; `farcall`, which clobbers a with the target bank number before the callee
; ever runs (same reason GetTypeName reads from wNamedObjectIndex instead
; of a).

	ld a, [wNamedObjectIndex]
	ld hl, HiddenPowerEffectNames
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wStringBuffer1
	ld bc, MOVE_NAME_LENGTH
	jp CopyBytes

HiddenPowerEffectNames:
; indexed by CalcHiddenPower's effect index (0-15)
	table_width 2
	dw .Burn
	dw .Paralyze
	dw .Poison
	dw .Frostbite
	dw .Flinch
	dw .Leech
	dw .AttackDown
	dw .DefenseDown
	dw .SpAtkDown
	dw .SpDefDown
	dw .SpeedDown
	dw .AttackUp
	dw .DefenseUp
	dw .SpAtkUp
	dw .SpDefUp
	dw .SpeedUp

.Burn:        db "BRN@"
.Paralyze:    db "PAR@"
.Poison:      db "PSN@"
.Frostbite:   db "FRB@"
.Flinch:      db "FLINCH@"
.Leech:       db "LEECH@"
.AttackDown:  db "ATK DN@"
.DefenseDown: db "DEF DN@"
.SpAtkDown:   db "SPA DN@"
.SpDefDown:   db "SDF DN@"
.SpeedDown:   db "SPE DN@"
.AttackUp:    db "ATK UP@"
.DefenseUp:   db "DEF UP@"
.SpAtkUp:     db "SPA UP@"
.SpDefUp:     db "SDF UP@"
.SpeedUp:     db "SPE UP@"
