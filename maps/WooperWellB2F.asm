	object_const_def
	const WOOPERWELLB2F_GYM_GUIDE
	const WOOPERWELLB2F_POKE_BALL

WooperWellB2F_MapScripts:
	def_scene_scripts

	def_callbacks

WooperWellB2FGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_KINGS_ROCK_IN_WOOPER_WELL
	iftrue .GotKingsRock
	writetext WooperWellB2FGymGuideText
	promptbutton
	verbosegiveitem KINGS_ROCK
	iffalse .NoRoom
	setevent EVENT_GOT_KINGS_ROCK_IN_WOOPER_WELL
.NoRoom:
	closetext
	end

.GotKingsRock:
	writetext WooperWellB2FGymGuideText_GotKingsRock
	waitbutton
	closetext
	end

WooperWellB2FTMRainDance:
	itemball TM_RAIN_DANCE

WooperWellB2FGymGuideText:
	text "I'm waiting to see"
	line "a WOOPER pop out"
	cont "of its hole."

	para "They're shy, but"
	line "if you stay still"
	cont "long enough…"

	para "Oh, that reminds"
	line "me--I found this"
	cont "while waiting."

	para "Here, I'll share a"
	line "KING'S ROCK with"
	cont "you."
	done

WooperWellB2FGymGuideText_GotKingsRock:
	text "I'm still waiting"
	line "for a WOOPER to"
	cont "show itself."

	para "Patience is the"
	line "name of the game."
	done

WooperWellB2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 11, WOOPER_WELL_B1F, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  4, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_WANDER, 1, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 1, WooperWellB2FGymGuideScript, -1
	object_event 15,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, WooperWellB2FTMRainDance, EVENT_WOOPER_WELL_B2F_TM_RAIN_DANCE
