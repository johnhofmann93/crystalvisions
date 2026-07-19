DEF MAHOGANYTOWN_RAGECANDYBAR_PRICE EQU 300

	object_const_def
	const MAHOGANYTOWN_POKEFAN_M
	const MAHOGANYTOWN_GRAMPS
	const MAHOGANYTOWN_FISHER
	const MAHOGANYTOWN_LASS
	const MAHOGANYTOWN_BURT
	const MAHOGANYTOWN_TELEPORTER

MahoganyTown_MapScripts:
	def_scene_scripts
	scene_script MahoganyTownNoop1Scene, SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR
	scene_script MahoganyTownNoop2Scene, SCENE_MAHOGANYTOWN_NOOP

	def_callbacks
	callback MAPCALLBACK_NEWMAP, MahoganyTownFlypointCallback

MahoganyTownNoop1Scene:
	end

MahoganyTownNoop2Scene:
	end

MahoganyTownFlypointCallback:
	setflag ENGINE_FLYPOINT_MAHOGANY
	endcallback

MahoganyTownTryARageCandyBarScript:
	showemote EMOTE_SHOCK, MAHOGANYTOWN_POKEFAN_M, 15
	applymovement MAHOGANYTOWN_POKEFAN_M, MahoganyTownRageCandyBarMerchantBlocksYouMovement
	follow PLAYER, MAHOGANYTOWN_POKEFAN_M
	applymovement PLAYER, MahoganyTownPlayerStepLeftMovement
	stopfollow
	turnobject PLAYER, RIGHT
	scall RageCandyBarMerchantScript
	applymovement MAHOGANYTOWN_POKEFAN_M, MahoganyTownRageCandyBarMerchantReturnsMovement
	end

MahoganyTownPokefanMScript:
	faceplayer
RageCandyBarMerchantScript:
	checkevent EVENT_CLEARED_ROCKET_HIDEOUT
	iftrue .ClearedRocketHideout
	scall .SellRageCandyBars
	end

.ClearedRocketHideout:
	opentext
	writetext RageCandyBarMerchantSoldOutText
	waitbutton
	closetext
	end

.SellRageCandyBars:
	opentext
	writetext RageCandyBarMerchantTryOneText
	special PlaceMoneyTopRight
	yesorno
	iffalse .Refused
	checkmoney YOUR_MONEY, MAHOGANYTOWN_RAGECANDYBAR_PRICE
	ifequal HAVE_LESS, .NotEnoughMoney
	giveitem RAGECANDYBAR
	iffalse .NoRoom
	waitsfx
	playsound SFX_TRANSACTION
	takemoney YOUR_MONEY, MAHOGANYTOWN_RAGECANDYBAR_PRICE
	special PlaceMoneyTopRight
	writetext RageCandyBarMerchantSavorItText
	waitbutton
	closetext
	end

.NotEnoughMoney:
	writetext RageCandyBarMerchantNotEnoughMoneyText
	waitbutton
	closetext
	end

.Refused:
	writetext RageCandyBarMerchantRefusedText
	waitbutton
	closetext
	end

.NoRoom:
	writetext RageCandyBarMerchantNoRoomText
	waitbutton
	closetext
	end

MahoganyTownGrampsScript:
	faceplayer
	opentext
	checkevent EVENT_CLEARED_ROCKET_HIDEOUT
	iftrue .ClearedRocketHideout
	writetext MahoganyTownGrampsText
	waitbutton
	closetext
	end

.ClearedRocketHideout:
	writetext MahoganyTownGrampsText_ClearedRocketHideout
	waitbutton
	closetext
	end

MahoganyTownFisherScript:
	jumptextfaceplayer MahoganyTownFisherText

MahoganyTownLassScript:
	jumptextfaceplayer MahoganyTownLassText

MahoganyTownSign:
	jumptext MahoganyTownSignText

MahoganyTownRagecandybarSign:
	jumptext MahoganyTownRagecandybarSignText

MahoganyGymSign:
	opentext
	writetext MahoganyGymSignText
	waitbutton
	readvar VAR_BADGES
	ifgreater 7, .cap8
	ifgreater 6, .cap7
	ifgreater 5, .cap6
	ifgreater 4, .cap5
	ifgreater 3, .cap4
	ifgreater 2, .cap3
	ifgreater 1, .cap2
	ifgreater 0, .cap1
	farwritetext GymSignObeyCapText0
	sjump .done
.cap1:
	farwritetext GymSignObeyCapText1
	sjump .done
.cap2:
	farwritetext GymSignObeyCapText2
	sjump .done
.cap3:
	farwritetext GymSignObeyCapText3
	sjump .done
.cap4:
	farwritetext GymSignObeyCapText4
	sjump .done
.cap5:
	farwritetext GymSignObeyCapText5
	sjump .done
.cap6:
	farwritetext GymSignObeyCapText6
	sjump .done
.cap7:
	farwritetext GymSignObeyCapText7
	sjump .done
.cap8:
	farwritetext GymSignObeyCapText8
.done:
	waitbutton
	closetext
	end

MahoganyTownPokecenterSign:
	jumpstd PokecenterSignScript

MahoganyTownCollideDownFaceLeftMovement: ; unreferenced
	step DOWN
	big_step UP
	turn_head DOWN
MahoganyTownPlayerStepLeftMovement:
	step LEFT
	step_end

MahoganyTownRageCandyBarMerchantBlocksYouMovement:
	step RIGHT
	step DOWN
	turn_head LEFT
	step_end

MahoganyTownRageCandyBarMerchantReturnsMovement:
	step UP
	turn_head DOWN
	step_end

RageCandyBarMerchantTryOneText:
	text "Hiya, kid!"

	para "I see you're new"
	line "in MAHOGANY TOWN."

	para "Since you're new,"
	line "you should try a"

	para "yummy RAGECANDY-"
	line "BAR!"

	para "Right now, it can"
	line "be yours for just"
	cont "¥300! Want one?"
	done

RageCandyBarMerchantSavorItText:
	text "Good! Savor it!"
	done

RageCandyBarMerchantNotEnoughMoneyText:
	text "You don't have"
	line "enough money."
	done

RageCandyBarMerchantRefusedText:
	text "Oh, fine then…"
	done

RageCandyBarMerchantNoRoomText:
	text "You don't have"
	line "room for this."
	done

RageCandyBarMerchantSoldOutText:
	text "RAGECANDYBAR's"
	line "sold out."

	para "I'm packing up."
	line "Don't bother me,"
	cont "kiddo."
	done

MahoganyTownGrampsText:
	text "Are you off to see"
	line "the GYARADOS ram-"
	cont "page at the LAKE?"
	done

MahoganyTownGrampsText_ClearedRocketHideout:
	text "MAGIKARP have"
	line "returned to LAKE"
	cont "OF RAGE."

	para "That should be"
	line "good news for the"
	cont "anglers there."
	done

MahoganyTownFisherText:
	text "Since you came"
	line "this far, take the"

	para "time to do some"
	line "sightseeing."

	para "You should head"
	line "north and check"

	para "out LAKE OF RAGE"
	line "right now."
	done

MahoganyTownLassText:
	text "Visit Grandma's"
	line "shop. She sells"

	para "stuff that nobody"
	line "else has."
	done

MahoganyTownSignText:
	text "MAHOGANY TOWN"

	para "Welcome to the"
	line "Home of the Ninja"
	done

MahoganyTownRagecandybarSignText:
	text "While visiting"
	line "MAHOGANY TOWN, try"
	cont "a RAGECANDYBAR!"
	done

MahoganyGymSignText:
	text "MAHOGANY TOWN"
	line "#MON GYM"
	cont "LEADER: PRYCE"

	para "The Teacher of"
	line "Winter's Harshness"
	done

BurtScript:
	faceplayer
	opentext
	checkevent EVENT_GAVE_KURT_RED_APRICORN
	iftrue .GiveRedApricornBall
	checkevent EVENT_GAVE_KURT_BLU_APRICORN
	iftrue .GiveBluApricornBall
	checkevent EVENT_GAVE_KURT_YLW_APRICORN
	iftrue .GiveYlwApricornBall
	checkevent EVENT_GAVE_KURT_GRN_APRICORN
	iftrue .GiveGrnApricornBall
	checkevent EVENT_GAVE_KURT_WHT_APRICORN
	iftrue .GiveWhtApricornBall
	checkevent EVENT_GAVE_KURT_BLK_APRICORN
	iftrue .GiveBlkApricornBall
	checkevent EVENT_GAVE_KURT_PNK_APRICORN
	iftrue .GivePnkApricornBall
	checkitem RED_APRICORN
	iftrue .AskApricorn
	checkitem BLU_APRICORN
	iftrue .AskApricorn
	checkitem YLW_APRICORN
	iftrue .AskApricorn
	checkitem GRN_APRICORN
	iftrue .AskApricorn
	checkitem WHT_APRICORN
	iftrue .AskApricorn
	checkitem BLK_APRICORN
	iftrue .AskApricorn
	checkitem PNK_APRICORN
	iftrue .AskApricorn
	writetext BurtIntroText
	waitbutton
	closetext
	end

.AskApricorn:
	writetext BurtAskApricornText
	promptbutton
	special SelectApricornForKurt
	ifequal FALSE, .Cancel
	ifequal BLU_APRICORN, .Blu
	ifequal YLW_APRICORN, .Ylw
	ifequal GRN_APRICORN, .Grn
	ifequal WHT_APRICORN, .Wht
	ifequal BLK_APRICORN, .Blk
	ifequal PNK_APRICORN, .Pnk
; .Red
	setevent EVENT_GAVE_KURT_RED_APRICORN
	sjump .GiveRedApricornBall

.Blu:
	setevent EVENT_GAVE_KURT_BLU_APRICORN
	sjump .GiveBluApricornBall

.Ylw:
	setevent EVENT_GAVE_KURT_YLW_APRICORN
	sjump .GiveYlwApricornBall

.Grn:
	setevent EVENT_GAVE_KURT_GRN_APRICORN
	sjump .GiveGrnApricornBall

.Wht:
	setevent EVENT_GAVE_KURT_WHT_APRICORN
	sjump .GiveWhtApricornBall

.Blk:
	setevent EVENT_GAVE_KURT_BLK_APRICORN
	sjump .GiveBlkApricornBall

.Pnk:
	setevent EVENT_GAVE_KURT_PNK_APRICORN
	sjump .GivePnkApricornBall

.GiveRedApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectRedBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_RED_APRICORN
	sjump ._TurnedOutGreat

.GiveBluApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectBluBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_BLU_APRICORN
	sjump ._TurnedOutGreat

.GiveYlwApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectYlwBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_YLW_APRICORN
	sjump ._TurnedOutGreat

.GiveGrnApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectGrnBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_GRN_APRICORN
	sjump ._TurnedOutGreat

.GiveWhtApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectWhtBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_WHT_APRICORN
	sjump ._TurnedOutGreat

.GiveBlkApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectBlkBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_BLK_APRICORN
	sjump ._TurnedOutGreat

.GivePnkApricornBall:
	writetext BurtHereYouGoText
	promptbutton
	callasm KurtSelectPnkBall
	verbosegiveitemvar ITEM_FROM_MEM, VAR_KURT_APRICORNS
	iffalse .NoRoomForBall
	clearevent EVENT_GAVE_KURT_PNK_APRICORN

._TurnedOutGreat:
	writetext BurtTurnedOutGreatText
	waitbutton
.NoRoomForBall:
	closetext
	end

.Cancel:
	writetext BurtCancelText
	waitbutton
	closetext
	end

BurtIntroText:
	text "BURT: I'm BURT."
	line "KURT's brother."
	para "I make BALLS from"
	line "APRICORNS, too."
	done

BurtAskApricornText:
	text "BURT: An APRICORN!"
	line "Hand it over and"
	para "I'll have your BALL"
	line "done in no time."
	done

BurtHereYouGoText:
	text "BURT: Here you go!"
	line "Runs in the family."
	done

BurtTurnedOutGreatText:
	text "BURT: Come back"
	line "anytime!"
	done

BurtCancelText:
	text "BURT: No worries."
	line "Come back when"
	para "you've got some"
	line "APRICORNS!"
	done

MahoganyTown_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 11,  7, MAHOGANY_MART_1F, 1
	warp_event 17,  7, MAHOGANY_RED_GYARADOS_SPEECH_HOUSE, 1
	warp_event  6, 13, MAHOGANY_GYM, 1
	warp_event 15, 13, MAHOGANY_POKECENTER_1F, 1
	warp_event  9,  1, ROUTE_43_MAHOGANY_GATE, 3

	def_coord_events
	coord_event 19,  8, SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR, MahoganyTownTryARageCandyBarScript
	coord_event 19,  9, SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR, MahoganyTownTryARageCandyBarScript

	def_bg_events
	bg_event  1,  5, BGEVENT_READ, MahoganyTownSign
	bg_event  9,  7, BGEVENT_READ, MahoganyTownRagecandybarSign
	bg_event  3, 13, BGEVENT_READ, MahoganyGymSign
	bg_event 16, 13, BGEVENT_READ, MahoganyTownPokecenterSign

	def_object_events
	object_event 19,  8, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MahoganyTownPokefanMScript, EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST
	object_event  6,  9, SPRITE_GRAMPS, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MahoganyTownGrampsScript, -1
	object_event  6, 14, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, MahoganyTownFisherScript, EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM
	object_event 12,  8, SPRITE_LASS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MahoganyTownLassScript, EVENT_MAHOGANY_MART_OWNERS
	object_event  5,  4, SPRITE_KURT, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BurtScript, -1
	object_event 14, 13, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, MahoganyTownTeleporterScript, -1

MahoganyTownTeleporterScript:
	faceplayer
	opentext
	writetext MahoganyTownTeleporterText
	waitbutton
	closetext
	loadmenu MahoganyTownTeleporter_MenuHeader
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

MahoganyTownTeleporter_MenuHeader:
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

MahoganyTownTeleporterText:
	text "Where would you"
	line "like to go?"
	done
