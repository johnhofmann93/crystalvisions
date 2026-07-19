	object_const_def
	const CIANWOODPORT_SAILOR

CianwoodPort_MapScripts:
	def_scene_scripts
	scene_script CianwoodPortNoopScene,      SCENE_CIANWOODPORT_ASK_ENTER_SHIP
	scene_script CianwoodPortLeaveShipScene, SCENE_CIANWOODPORT_LEAVE_SHIP

	def_callbacks

CianwoodPortNoopScene:
	end

CianwoodPortLeaveShipScene:
	sdefer CianwoodPortLeaveShipScript
	end

CianwoodPortLeaveShipScript:
	applymovement PLAYER, CianwoodPortLeaveFastShipMovement
	appear CIANWOODPORT_SAILOR
	setscene SCENE_CIANWOODPORT_ASK_ENTER_SHIP
	clearevent EVENT_OLIVINE_PORT_PASSAGE_POKEFAN_M
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	blackoutmod CIANWOOD_CITY
	end

CianwoodPortSailorScript:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue .AlreadyRode
	writetext CianwoodPortAskBoardingText
	yesorno
	iffalse CianwoodPortNotRidingScript
	closetext
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	playsound SFX_EXIT_BUILDING
	disappear CIANWOODPORT_SAILOR
	waitsfx
	applymovement PLAYER, CianwoodPortEnterFastShipMovement
	playsound SFX_EXIT_BUILDING
	special FadeOutToWhite
	waitsfx
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iffalse .FirstTime
	clearevent EVENT_FAST_SHIP_PASSENGERS_EASTBOUND
	setevent EVENT_FAST_SHIP_PASSENGERS_WESTBOUND
	clearevent EVENT_BEAT_POKEMANIAC_ETHAN
	clearevent EVENT_BEAT_BURGLAR_COREY
	clearevent EVENT_BEAT_BUG_CATCHER_KEN
	clearevent EVENT_BEAT_GUITARIST_CLYDE
	clearevent EVENT_BEAT_POKEFANM_JEREMY
	clearevent EVENT_BEAT_POKEFANF_GEORGIA
	clearevent EVENT_BEAT_SAILOR_KENNETH
	clearevent EVENT_BEAT_TEACHER_SHIRLEY
	clearevent EVENT_BEAT_SCHOOLBOY_NATE
	clearevent EVENT_BEAT_SCHOOLBOY_RICKY
.FirstTime:
	setevent EVENT_FAST_SHIP_DESTINATION_OLIVINE
	appear CIANWOODPORT_SAILOR
	setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_ENTER_SHIP
	warp FAST_SHIP_1F, 25, 1
	end

.AlreadyRode:
	writetext CianwoodPortCantBoardText
	waitbutton
	closetext
	end

CianwoodPortNotRidingScript:
	writetext CianwoodPortComeAgainText
	waitbutton
	closetext
	end

CianwoodPortEnterFastShipMovement:
	step DOWN
	step_end

CianwoodPortLeaveFastShipMovement:
	step UP
	step_end

CianwoodPortAskBoardingText:
	text "Welcome to FAST"
	line "SHIP S.S.AQUA."

	para "Will you be board-"
	line "ing today?"
	done

CianwoodPortComeAgainText:
	text "We hope to see you"
	line "again!"
	done

CianwoodPortCantBoardText:
	text "Sorry. You can't"
	line "board now."
	done

CianwoodPort_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9,  5, CIANWOOD_CITY, 8
	warp_event  7, 17, FAST_SHIP_1F, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  7, 17, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodPortSailorScript, -1
