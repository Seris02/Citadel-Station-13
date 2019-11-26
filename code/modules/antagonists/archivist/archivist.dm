/datum/antagonist/archivist
	name = "Archivist"
	roundend_category = "archivists"
	antagpanel_category = "Archivist"
	antag_moodlet = /datum/mood_event/focused
	job_rank = ROLE_ARCHIVIST

/datum/antagonist/archivist/greet()
	to_chat(owner, "<b><font size=3 color=orange>You are the Archivist.</font></b>")
	to_chat(owner, "<b>Secure, by any means necessary, artifacts of high historical value or items of prototype research.</b>")
	to_chat(owner, "<b>You have been given a tablet by the <color=orange>Archivist Association</font> which you may use in situations of desperation.</b>")
	owner.announce_objectives()
	..()

/datum/antagonist/archivist/on_gain()
	make_objectives()
	archivist_give_item(/obj/item/archivist_tablet,owner.current)
	..()

/datum/antagonist/archivist/proc/make_objectives()
	var/datum/objective/steal/archivist/steal_objective = new
	steal_objective.owner = owner
	steal_objective.find_target()
	objectives += steal_objective
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
	return

/datum/antagonist/archivist/proc/archivist_give_item(obj/item/item_path, mob/living/carbon/human/mob) //shamelessly copied from cult.dm
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/T = new item_path(mob)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		return 0 //fuck ahelping, you should be able to do archivist without the tablet
	else
		if(where == "backpack") //tells you elsewhere
			SEND_SIGNAL(mob.back, COMSIG_TRY_STORAGE_SHOW, mob)
		return TRUE


/datum/antagonist/archivist/on_removal()
	..()

GLOBAL_LIST_EMPTY(possible_items_archivist)
/datum/objective/steal/archivist
	name = "steal archivist"

/datum/objective/steal/archivist/New()
	..()
	if(!GLOB.possible_items_archivist.len)
		for(var/I in subtypesof(/datum/objective_item/archivist))
			new I

/datum/objective/steal/archivist/find_target()
	return set_target(pick(GLOB.possible_items_archivist))

/datum/objective_item/archivist/New()
	..()
	if(TargetExists())
		GLOB.possible_items_archivist += src
	else
		qdel(src)

/datum/objective_item/archivist/Destroy()
	GLOB.possible_items_archivist -= src
	return ..()

/datum/objective_item/archivist/lamarr
	name = "lamarr."
	targetitem = /obj/item/clothing/mask/facehugger/lamarr
	difficulty = 5

/datum/objective_item/archivist/coat
	name = "a cosmic winter coat."
	targetitem = /obj/item/clothing/suit/hooded/wintercoat/cosmic
	difficulty = 5