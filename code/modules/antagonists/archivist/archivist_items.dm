/obj/item/card/id/archivist
	name = "quantum card"
	icon_state = "quantum"
	icon = 'icons/obj/archivist.dmi'
	desc = "An ID that encompasses all IDs all at once, it can be used to access anything, anywhere, but it's instability will make it disappear after a while once activated."

/obj/item/card/id/archivist/attack_self(mob/user)
	access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
	addtimer(CALLBACK(src,.proc/erase,user),1 MINUTES)
	to_chat(user, "<span class='warning'>The [src] starts shaking violently as it uses up the yellowspace crystals embedded on it's surface.</span>")
	icon_state = "[icon_state]0"

/obj/item/card/id/archivist/proc/erase(mob/user)
	to_chat(user, "<span class='warning'>The [src] disappears in a flash of orange light!</span>")
	flash_lighting_fx(9, 9, LIGHT_COLOR_ORANGE)
	qdel(src)

/obj/item/archivist_tool/tele
	name = "archivist teleporter"
	desc = "For when you've accomplished the tasks you set out to do and need to store precious relics."
	icon_state = "tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/archivist_tool/tele/attack_self(mob/user)
	if (user)
		if (isarchivist(user))
			icon_state = "tele0"
			addtimer(CALLBACK(src,.proc/start_anim,user),26)

/obj/item/archivist_tool/tele/proc/start_anim(mob/user)
	icon_state = "tele1"
	flash_lighting_fx(9, 9, LIGHT_COLOR_ORANGE)
	do_teleport(user,locate(111,156,1),channel=null,forced=TRUE)

/obj/item/archivist_tool/injector
	name = "yellowspace injector"
	desc = "It's an injector that allows you to escape from any foe by tapping into the yellowspace network."
	icon_state = "yellowinjector"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/usedup = FALSE
	w_class = WEIGHT_CLASS_TINY

/obj/item/archivist_tool/injector/attack(mob/M,mob/user)
	if (M == user && usedup == FALSE)
		if (isarchivist(user))
			var/turf/open/floor/F = find_safe_turf(extended_safety_checks=TRUE)
			to_chat(user, "<span class='warning'>You inject yourself with the [src].</span>")
			flash_lighting_fx(9, 9, LIGHT_COLOR_ORANGE)
			do_teleport(user,F,channel=null,forced=TRUE)
			icon_state = "[icon_state]0"
			desc = "[desc]\nIt is spent."


/obj/item/archivist_tool/sleeperbaton
	name = "sleeper baton"
	desc = "A baton that makes anyone it's used on fall asleep. They will forget anything they know about anything you have done for the past hour."
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "sleepbaton0"
	var/uses = 3

/obj/item/archivist_tool/sleeperbaton/attack(mob/t,mob/user)
	if (uses <= 0)
		to_chat(user, "<span class='warning'>The [src.name] has no uses remaining!</span>")
	if (isliving(t))
		var/mob/living/target = t
		if (!target.IsSleeping())
			playsound(loc,'sound/weapons/egloves.ogg',50,1,-1)
			to_chat(target, "<span class='userdanger'>You forget <b>everything</b> you know about [user]!</span>")
			target.Sleeping(15 SECONDS)
			uses--
			icon_state = "sleepbaton[3-uses]"

/obj/item/clothing/gloves/paralysis
	name = "paralysis gloves"
	desc = "These will paralyze anyone you touch with them for a few seconds, giving you quick escapes."
	icon_state = "paralysis"
	item_state = "paralysisgloves"
	var/power = 1
	var/recharging = FALSE

/obj/item/clothing/gloves/paralysis/Touch(mob/living/target,proximity=TRUE)
	if (!istype(target))
		return
	var/mob/living/M = loc
	if (recharging == TRUE)
		to_chat(M, "<span class='warning'>The [src.name] are recharging, they can't be used.</span>")
		return
	if (M.a_intent == INTENT_HARM)
		playsound(loc,'sound/weapons/egloves.ogg',50,1,-1)
		target.Stun(200*power)
		target.visible_message("<span class='danger'>[M] stuns [target] with the [src.name]!</span>","<span class='danger'>[M] has stunned you with the [src.name]!</span>")
		power -= 0.05
		if (power <= 0)
			icon_state = "paralysisnopower"
			desc = "[desc]\nThey seem to be out of charge."
			recharging = TRUE
			addtimer(CALLBACK(src,.proc/recharge),50)

/obj/item/clothing/gloves/paralysis/proc/recharge() //fully recharges in 4 minutes, 10 seconds
	if (power < 1)
		power += 0.01
		addtimer(CALLBACK(src,.proc/recharge),50)
		return
	recharging = FALSE
	icon_state = initial(icon_state)
	desc = initial(desc)
/*
/obj/item/archivist_tool
	name = "archivist_tool"
	desc = "desc"

/obj/item/archivist_tool
	name = "archivist_tool"
	desc = "desc"
*/
/obj/item/archivist_tool
	name = "archivist_tool"
	desc = "desc"
	icon = 'icons/obj/archivist.dmi'
	var/includeinlist = TRUE
