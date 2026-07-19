EngineFlagAction::
; Do action b on engine flag de
;
;   b = 0: reset flag
;     = 1: set flag
;     > 1: check flag, result in c
;
; Setting/resetting does not return a result.

; 16-bit flag ids are considered invalid, but it's nice
; to know that the infrastructure is there.

	ld a, d
	cp HIGH(NUM_ENGINE_FLAGS)
	jr z, .ceiling
	jr c, .read ; cp 0 can't set carry!
	jr .invalid

; There are only NUM_ENGINE_FLAGS engine flags, so
; anything beyond that is invalid too.

.ceiling
	ld a, e
	cp LOW(NUM_ENGINE_FLAGS)
	jr c, .read

; Invalid flags are treated as flag 00.

.invalid
	xor a
	ld e, a
	ld d, a

; Get this flag's location.

.read
	ld hl, EngineFlags
; location
	add hl, de
	add hl, de
; bit
	add hl, de

; location
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
; bit
	ld c, [hl]

; What are we doing with this flag?

	ld a, b
	cp 1
	jr c, .reset ; b = 0
	jr z, .set   ; b = 1

; Return the given flag in c.
; check
	ld a, [de]
	and c
	ld c, a
	ret

; Set the given flag.
.set
	ld a, [de]
	ld b, a
	or c
	ld [de], a

; If this newly set a Johto badge flag, record the order it was obtained in.
	ld a, e
	cp LOW(wJohtoBadges)
	jr nz, .done_set
	ld a, d
	cp HIGH(wJohtoBadges)
	jr nz, .done_set
	ld a, b
	and c
	jr nz, .done_set ; bit was already set; not newly obtained

	call RecordJohtoBadgeOrder

.done_set
	ret

; Reset the given flag.
.reset
	ld a, c
	cpl ; AND all bits except the one in question
	ld c, a
	ld a, [de]
	and c
	ld [de], a
	ret

RecordJohtoBadgeOrder:
; c = bit mask of the Johto badge that was just obtained
	push af
	push bc
	push de
	push hl

	ld b, c
	ld a, 0
.find_bit
	srl b
	jr c, .found_bit
	inc a
	jr .find_bit
.found_bit
; a = badge index (0-7)
	push af
	ld hl, wJohtoBadges
	ld b, 1
	call CountSetBits
; c = number of badges now set, including the one just obtained
	pop af

; wJohtoBadgeOrder packs two 4-bit order values per byte (index/2, low
; nibble for even indexes, high nibble for odd).
	ld e, a
	srl e
	ld d, 0
	ld hl, wJohtoBadgeOrder
	add hl, de

	and 1
	jr nz, .high_nibble

	ld a, [hl]
	and $f0
	ld d, a
	ld a, c
	and $0f
	or d
	ld [hl], a
	jr .done_record

.high_nibble
	ld a, [hl]
	and $0f
	ld d, a
	ld a, c
	swap a
	and $f0
	or d
	ld [hl], a

.done_record
	pop hl
	pop de
	pop bc
	pop af
	ret

INCLUDE "data/events/engine_flags.asm"
