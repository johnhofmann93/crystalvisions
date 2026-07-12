	object_const_def
	const WOOPERWELLB1F_ROCKET1
	const WOOPERWELLB1F_ROCKET2
	const WOOPERWELLB1F_ROCKET3
	const WOOPERWELLB1F_ROCKET_GIRL
	const WOOPERWELLB1F_WOOPER1
	const WOOPERWELLB1F_WOOPER2
	const WOOPERWELLB1F_KURT
	const WOOPERWELLB1F_BOULDER
	const WOOPERWELLB1F_POKE_BALL

WooperWellB1F_MapScripts:
	def_scene_scripts

	def_callbacks

WooperWellB1FKurtScript:
	jumptextfaceplayer WooperWellB1FKurtText

TrainerGruntM29:
	trainer GRUNTM, GRUNTM_29, EVENT_BEAT_ROCKET_GRUNTM_29, GruntM29SeenText, GruntM29BeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext GruntM29AfterBattleText
	waitbutton
	closetext
	end

TrainerGruntM1:
	trainer GRUNTM, GRUNTM_1, EVENT_BEAT_ROCKET_GRUNTM_1, GruntM1SeenText, GruntM1BeatenText, 0, .Script

.Script:
	opentext
	writetext TrainerGruntM1WhenTalkText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	disappear WOOPERWELLB1F_ROCKET1
	disappear WOOPERWELLB1F_ROCKET2
	disappear WOOPERWELLB1F_ROCKET3
	disappear WOOPERWELLB1F_ROCKET_GIRL
	pause 15
	special FadeInFromBlack
	disappear WOOPERWELLB1F_KURT
	moveobject WOOPERWELLB1F_KURT, 11, 6
	appear WOOPERWELLB1F_KURT
	applymovement WOOPERWELLB1F_KURT, KurtWooperWellVictoryMovementData
	turnobject PLAYER, RIGHT
	opentext
	writetext KurtLeaveWooperWellText
	waitbutton
	closetext
	setevent EVENT_CLEARED_WOOPER_WELL
	variablesprite SPRITE_AZALEA_ROCKET, SPRITE_RIVAL
	setmapscene AZALEA_TOWN, SCENE_AZALEATOWN_RIVAL_BATTLE
	clearevent EVENT_ILEX_FOREST_APPRENTICE
	clearevent EVENT_ILEX_FOREST_FARFETCHD
	setevent EVENT_CHARCOAL_KILN_FARFETCH_D
	setevent EVENT_CHARCOAL_KILN_APPRENTICE
	setevent EVENT_WOOPER_WELL_WOOPERS
	setevent EVENT_WOOPER_WELL_KURT
	clearevent EVENT_AZALEA_TOWN_WOOPERS
	clearevent EVENT_KURTS_HOUSE_WOOPER
	clearevent EVENT_KURTS_HOUSE_KURT_1
	special FadeOutToWhite
	special HealParty
	pause 15
	warp KURTS_HOUSE, 3, 3
	end

TrainerGruntM2:
	trainer GRUNTM, GRUNTM_2, EVENT_BEAT_ROCKET_GRUNTM_2, GruntM2SeenText, GruntM2BeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext GruntM2AfterBattleText
	waitbutton
	closetext
	end

TrainerGruntF1:
	trainer GRUNTF, GRUNTF_1, EVENT_BEAT_ROCKET_GRUNTF_1, GruntF1SeenText, GruntF1BeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext GruntF1AfterBattleText
	waitbutton
	closetext
	end

WooperWellB1FWooperWithMailScript:
	faceplayer
	opentext
	cry WOOPER
	writetext WooperWellB1FWooperWithMailText
	yesorno
	iftrue .ReadMail
	closetext
	end

.ReadMail:
	writetext WooperWellB1FWooperMailText
	waitbutton
	closetext
	end

WooperWellB1FTaillessWooperScript:
	faceplayer
	opentext
	writetext WooperWellB1FTaillessWooperText
	cry WOOPER
	waitbutton
	closetext
	end

WooperWellB1FBoulder:
	jumpstd StrengthBoulderScript

WooperWellB1FSuperPotion:
	itemball SUPER_POTION

KurtWooperWellVictoryMovementData:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	step_sleep 8
	step_sleep 8
	step_sleep 8
	step LEFT
	step UP
	step UP
	step_sleep 8
	step_sleep 8
	step_sleep 8
	turn_head LEFT
	step_end

WooperWellB1FKurtText:
	text "KURT: Hey there,"
	line "<PLAYER>!"

	para "The guard up top"
	line "took off when I"
	cont "shouted at him."

	para "But then I took a"
	line "tumble down the"
	cont "WELL."

	para "I slammed down"
	line "hard on my back,"
	cont "so I can't move."

	para "Rats! If I were"
	line "fit, my #MON"

	para "would've punished"
	line "them…"

	para "Ah, it can't be"
	line "helped."

	para "<PLAYER>, show them"
	line "how gutsy you are"
	cont "in my place!"
	done

KurtLeaveWooperWellText:
	text "KURT: Way to go,"
	line "<PLAYER>!"

	para "TEAM ROCKET has"
	line "taken off."

	para "My back's better"
	line "too. Let's get out"
	cont "of here."
	done

GruntM29SeenText:
	text "Darn! I was stand-"
	line "ing guard up top"

	para "when some old coot"
	line "yelled at me."

	para "He startled me so"
	line "much that I fell"
	cont "down here."

	para "I think I'll vent"
	line "my anger by taking"
	cont "it out on you!"
	done

GruntM29BeatenText:
	text "Arrgh! This is NOT"
	line "my day!"
	done

GruntM29AfterBattleText:
	text "Sure, we've been"
	line "hacking the tails"

	para "off WOOPER and"
	line "selling them."

	para "Everything we do"
	line "is for profit."

	para "That's right!"
	line "We're TEAM ROCKET,"

	para "and we'll do any-"
	line "thing for money!"
	done

GruntM1SeenText:
	text "What do you want?"

	para "If you interrupt"
	line "our work, don't"
	cont "expect any mercy!"
	done

GruntM1BeatenText:
	text "You did OK today,"
	line "but wait till next"
	cont "time!"
	done

TrainerGruntM1WhenTalkText:
	text "Yeah, TEAM ROCKET"
	line "was broken up"
	cont "three years ago."

	para "But we continued"
	line "our activities"
	cont "underground."

	para "Now you can have"
	line "fun watching us"
	cont "stir up trouble!"
	done

GruntM2SeenText:
	text "Quit taking"
	line "WOOPERTAILS?"

	para "If we obeyed you,"
	line "TEAM ROCKET's rep"
	cont "would be ruined!"
	done

GruntM2BeatenText:
	text "Just…"
	line "Too strong…"
	done

GruntM2AfterBattleText:
	text "We need the money,"
	line "but selling"
	cont "WOOPERTAILS?"

	para "It's tough being a"
	line "ROCKET GRUNT!"
	done

GruntF1SeenText:
	text "Stop taking TAILS?"

	para "Yeah, just try to"
	line "defeat all of us!"
	done

GruntF1BeatenText:
	text "You rotten brat!"
	done

GruntF1AfterBattleText:
	text "WOOPERTAILS"
	line "grow back fast!"

	para "What's wrong with"
	line "selling them?"
	done

WooperWellB1FWooperWithMailText:
	text "A WOOPER with"
	line "its TAIL cut off…"

	para "Huh? It has MAIL."
	line "Read it?"
	done

WooperWellB1FWooperMailText:
	text "<PLAYER> read the"
	line "MAIL."

	para "Be good and look"
	line "after the house"

	para "with Grandpa and"
	line "WOOPER."

	para "Love, Dad"
	done

WooperWellB1FTaillessWooperText:
	text "A WOOPER with"
	line "its TAIL cut off…"
	done

WooperWellB1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17, 15, AZALEA_TOWN, 6
	warp_event  7, 11, WOOPER_WELL_B2F, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event 15,  7, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM29, EVENT_WOOPER_WELL_ROCKETS
	object_event  5,  2, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, TrainerGruntM1, EVENT_WOOPER_WELL_ROCKETS
	object_event  5,  6, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerGruntM2, EVENT_WOOPER_WELL_ROCKETS
	object_event 10,  4, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerGruntF1, EVENT_WOOPER_WELL_ROCKETS
	object_event  7,  4, SPRITE_WOOPER, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, WooperWellB1FWooperWithMailScript, EVENT_WOOPER_WELL_WOOPERS
	object_event  6,  2, SPRITE_WOOPER, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, WooperWellB1FTaillessWooperScript, EVENT_WOOPER_WELL_WOOPERS
	object_event 16, 14, SPRITE_KURT, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WooperWellB1FKurtScript, EVENT_WOOPER_WELL_KURT
	object_event  3,  2, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WooperWellB1FBoulder, -1
	object_event 10,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, WooperWellB1FSuperPotion, EVENT_WOOPER_WELL_B1F_SUPER_POTION
