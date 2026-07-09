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
; Compute Hidden Power's type and base power from a mon's DVs.
; in: de = pointer to that mon's 2-byte DVs.
; out: a = type (TypeNames/PrintType-compatible index), d = power (31-70).
; e also holds the type on return: the `farcall` trampoline (ReturnFarCall)
; clobbers `a` with leftover garbage while restoring the ROM bank, but it
; never touches d/e/h/l, so callers reaching this via `farcall` (rather than
; a same-bank `call`) must read the type from e instead of a.

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
	ret
