	object_const_def
	const BLACKTHORNMAGNETTRAINSTATION_OFFICER
	const BLACKTHORNMAGNETTRAINSTATION_GYM_GUIDE
	const BLACKTHORNMAGNETTRAINSTATION_TEACHER
	const BLACKTHORNMAGNETTRAINSTATION_LASS

BlackthornMagnetTrainStation_MapScripts:
	def_scene_scripts
	scene_script BlackthornMagnetTrainStationNoopScene, SCENE_BLACKTHORNMAGNETTRAINSTATION_ARRIVE_FROM_GOLDENROD

	def_callbacks

BlackthornMagnetTrainStationNoopScene:
	end

BlackthornMagnetTrainStationOfficerScript:
	faceplayer
	opentext
	writetext BlackthornMagnetTrainStationOfficerAreYouComingOnBoardText
	yesorno
	iffalse .DecidedNotToRide
	writetext BlackthornMagnetTrainStationOfficerRightThisWayText
	waitbutton
	closetext
	applymovement BLACKTHORNMAGNETTRAINSTATION_OFFICER, BlackthornMagnetTrainStationOfficerApproachTrainDoorMovement
	applymovement PLAYER, BlackthornMagnetTrainStationPlayerApproachAndEnterTrainMovement
	setval TRUE
	special MagnetTrain
	warpcheck
	newloadmap MAPSETUP_TRAIN
	applymovement PLAYER, .MovementBoardTheTrain
	wait 20
	end

.MovementBoardTheTrain:
	turn_head DOWN
	step_end

.DecidedNotToRide:
	writetext BlackthornMagnetTrainStationOfficerHopeToSeeYouAgainText
	waitbutton
	closetext
	end

Script_ArriveFromGoldenrod:
	applymovement BLACKTHORNMAGNETTRAINSTATION_OFFICER, BlackthornMagnetTrainStationOfficerApproachTrainDoorMovement
	applymovement PLAYER, BlackthornMagnetTrainStationPlayerLeaveTrainAndEnterStationMovement
	applymovement BLACKTHORNMAGNETTRAINSTATION_OFFICER, BlackthornMagnetTrainStationOfficerReturnToBoardingGateMovement
	opentext
	writetext BlackthornMagnetTrainStationOfficerArrivedInBlackthornText
	waitbutton
	closetext
	end

BlackthornMagnetTrainStationGymGuideScript:
	jumptextfaceplayer BlackthornMagnetTrainStationGymGuideText

BlackthornMagnetTrainStationTeacherScript:
	jumptextfaceplayer BlackthornMagnetTrainStationTeacherText

BlackthornMagnetTrainStationLassScript:
	jumptextfaceplayer BlackthornMagnetTrainStationLassText

BlackthornMagnetTrainStationOfficerApproachTrainDoorMovement:
	step UP
	step UP
	step RIGHT
	turn_head LEFT
	step_end

BlackthornMagnetTrainStationOfficerReturnToBoardingGateMovement:
	step LEFT
	step DOWN
	step DOWN
	step_end

BlackthornMagnetTrainStationPlayerApproachAndEnterTrainMovement:
	step UP
	step UP
	step UP
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

BlackthornMagnetTrainStationPlayerLeaveTrainAndEnterStationMovement:
	step LEFT
	step LEFT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	turn_head UP
	step_end

BlackthornMagnetTrainStationOfficerAreYouComingOnBoardText:
	text "We'll soon depart"
	line "for GOLDENROD."

	para "Are you coming on"
	line "board?"
	done

BlackthornMagnetTrainStationOfficerRightThisWayText:
	text "Right this way,"
	line "please."
	done

BlackthornMagnetTrainStationOfficerHopeToSeeYouAgainText:
	text "We hope to see you"
	line "again."
	done

BlackthornMagnetTrainStationOfficerArrivedInBlackthornText:
	text "We have arrived in"
	line "BLACKTHORN."

	para "We hope to see you"
	line "again."
	done

BlackthornMagnetTrainStationGymGuideText:
	text "The MAGNET TRAIN"
	line "is a super-modern"

	para "rail liner that"
	line "uses electricity"

	para "and magnets to"
	line "attain incredible"
	cont "speed."
	done

BlackthornMagnetTrainStationTeacherText:
	text "Before the MAGNET"
	line "TRAIN STATION was"

	para "built, this was"
	line "a quiet mountain"
	cont "trail."

	para "Dragon trainers"
	line "still walk this"
	cont "path to the DEN."
	done

BlackthornMagnetTrainStationLassText:
	text "Hi. Do you have a"
	line "rail PASS? I have"

	para "one. All the peo-"
	line "ple in BLACKTHORN"

	para "who ride the"
	line "MAGNET TRAIN have"
	cont "PASSES."
	done

BlackthornMagnetTrainStation_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  8, 17, BLACKTHORN_CITY, 9
	warp_event  9, 17, BLACKTHORN_CITY, 9
	warp_event  6,  5, GOLDENROD_MAGNET_TRAIN_STATION, 4
	warp_event 11,  5, GOLDENROD_MAGNET_TRAIN_STATION, 3

	def_coord_events
	coord_event 11,  6, SCENE_BLACKTHORNMAGNETTRAINSTATION_ARRIVE_FROM_GOLDENROD, Script_ArriveFromGoldenrod

	def_bg_events

	def_object_events
	object_event  9,  9, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMagnetTrainStationOfficerScript, -1
	object_event 10, 14, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMagnetTrainStationGymGuideScript, -1
	object_event  6, 11, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMagnetTrainStationTeacherScript, EVENT_BLACKTHORN_TRAIN_STATION_POPULATION
	object_event  6, 10, SPRITE_LASS, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, BlackthornMagnetTrainStationLassScript, EVENT_BLACKTHORN_TRAIN_STATION_POPULATION
