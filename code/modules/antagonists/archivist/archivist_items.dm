/*
LITERALLY EVERYTHING TO DO WITH ARCHIVIST ITEMS IS STORED IN HERE. CLOTHING, ITEMS,
ANYTHING IN THE ARCHIVIST TABLET EXCEPT THE STAFF IS IN HERE.

*/

/obj/item/card/id/archivist
	name = "quantum card"
	icon_state = "quantum"
	icon = 'icons/obj/archivist.dmi'
	desc = "An ID that encompasses all IDs all at once, it can be used to access anything, anywhere, but it's instability will make it disappear after a while once activated."

/obj/item/card/id/archivist/attack_self(mob/user)
	access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
	addtimer(CALLBACK(src,.proc/erase,user),30 SECONDS)
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
	desc = "These will paralyze anyone you touch with them for a few seconds, giving you quick escapes. <b><font color='orange'>You can't hurt anyone with them on.</font></b>"
	icon_state = "paralysis"
	item_state = "paralysisgloves"
	var/power = 1
	var/chargecost = 1
	var/recharging = FALSE

/obj/item/clothing/gloves/paralysis/Touch(mob/living/target,proximity=TRUE)
	if (!istype(target))
		return
	var/mob/living/M = loc
	if (recharging == TRUE)
		to_chat(M, "<span class='warning'>The [src.name] are recharging, they can't be used.</span>")
		return
	if (M.a_intent == INTENT_DISARM)
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

/obj/item/clothing/gloves/paralysis/equipped(mob/living/carbon/human/user,slot)
	. = ..()
	if (slot == ITEM_SLOT_GLOVES)
		ADD_TRAIT(user,TRAIT_PACIFISM,ABSTRACT_ITEM_TRAIT)
		return
	REMOVE_TRAIT(user,TRAIT_PACIFISM,ABSTRACT_ITEM_TRAIT)

/obj/item/clothing/gloves/paralysis/dropped(mob/living/carbon/human/user)
	..()
	REMOVE_TRAIT(user,TRAIT_PACIFISM,ABSTRACT_ITEM_TRAIT)

/obj/item/clothing/neck/shifter
	name = "molecular delocalising scarf"
	desc = "A scarf that allows you to walk through walls for a very short period of time."
	icon = 'icons/obj/archivist.dmi'
	icon_state = "shifter"
	var/wallwalkcooldown = 0
	var/chargecost = 2
	actions_types = list(/datum/action/item_action/molecularise)
	var/cooldowntime = 3 MINUTES + 2 SECONDS
	var/shiftcooldown = 0

/obj/item/clothing/neck/shifter/ui_action_click(mob/living/carbon/user, action)
	if (istype(user))
		if (wallwalkcooldown < world.time && user.get_item_by_slot(SLOT_NECK) == src)
			if (user.pulledby)
				pulledby.stop_pulling()
			LAZYADD(user.user_movement_hooks,src)
			user.alpha = max(user.alpha - 100, 0)
			addtimer(CALLBACK(src,.proc/unmolecularise,user),2 SECONDS)
			if (cooldowntime)
				wallwalkcooldown = world.time + cooldowntime

/obj/item/clothing/neck/shifter/proc/unmolecularise(mob/living/carbon/user)
	LAZYREMOVE(user.user_movement_hooks,src)
	user.alpha = min(user.alpha + 100, 255)

/obj/item/clothing/neck/shifter/intercept_user_move(dir,mob/living/m,newloc,oldloc)
	if (shiftcooldown < world.time)
		m.forceMove(newloc)
		shiftcooldown = world.time + m.movement_delay()

/obj/item/clothing/neck/shifter/debug
	name = "debug archivist scarf"
	cooldowntime = FALSE

/obj/item/clothing/shoes/magboots/archivist
	name = "high-power magboots"
	desc = "Magboots that constantly slip you in between molecules around you, preventing anyone from pulling you."
	icon = 'icons/obj/archivist.dmi'
	icon_state = "archivistmag0"
	magboot_state = "archivistmag"
	slowdown_active = 3
	var/chargecost = 1

/obj/item/clothing/shoes/magboots/archivist/attack_self(mob/user)
	if (magpulse)
		user.anchored = FALSE
	else
		user.anchored = TRUE
	..()

/obj/item/clothing/shoes/magboots/archivist/equipped(mob/user, slot)
	..()
	if (slot == SLOT_SHOES && magpulse)
		user.anchored = TRUE
	else
		user.anchored = FALSE


/obj/item/clothing/shoes/magboots/archivist/dropped(mob/user)
	..()
	user.anchored = FALSE

/obj/item/storage/box/archivist
	name = "box of holding"
	desc = "A box with yellowspace crystals embedded on it's surface."
	illustration = null
	icon = 'icons/obj/archivist.dmi'
	icon_state = "boxholding"
	foldable = null

/obj/item/storage/box/archivist/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 14
	STR.max_combined_w_class = 20

/obj/item/clothing/mask/archivist
	name = "quantum soundwave alterer"
	desc = "A gas mask that searches through all parallel universes to find someone with the name you select saying what you say."
	var/voice = ""
	icon = 'icons/obj/archivist.dmi'
	icon_state = "archivistmask"
	flags_cover = MASKCOVERSMOUTH
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/mask/archivist/AltClick(mob/user)
	voice = input(user,"Voice to disguise as", text("Input"))

/obj/item/archivist_tool/energy
	name = "energy conversion tool"
	desc = "A device that converts any and all damage taken into a slight speed boost."
	icon_state = "energy"
	var/timeon = 0
	var/speedcool = 0
	var/ison = FALSE
	var/cooldown = 0

/obj/item/archivist_tool/energy/Destroy()
	SSobj.processing -= src
	return ..()

/obj/item/archivist_tool/energy/attack_self(mob/user)
	if (cooldown > world.time && !ison)
		return ..()
	if (!ison)
		START_PROCESSING(SSobj,src)
		icon_state = "[initial(icon_state)]0"
		timeon = world.time + 30 SECONDS
	else
		icon_state = initial(icon_state)
		STOP_PROCESSING(SSobj,src)
	ison = !ison
	..()

/obj/item/archivist_tool/energy/process()
	if (timeon < world.time)
		icon_state = initial(icon_state)
		STOP_PROCESSING(SSobj,src)
		cooldown = world.time + 1 MINUTES
		return
	if (iscarbon(loc))
		var/mob/living/carbon/H = loc
		var/gothealed = FALSE
		if (H.getBruteLoss())
			H.adjustBruteLoss(-min(1,H.getBruteLoss()))
			gothealed = TRUE
		if (H.getFireLoss())
			H.adjustFireLoss(-min(1,H.getFireLoss()))
			gothealed = TRUE
		if (H.getOxyLoss())
			H.adjustOxyLoss(-min(1,H.getOxyLoss()))
			gothealed = TRUE
		if (H.getToxLoss())
			H.adjustToxLoss(-min(1,H.getToxLoss()))
			gothealed = TRUE
		if (gothealed && speedcool < world.time)
			H.add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = 0.6)
			speedcool = world.time + 2 SECONDS
			addtimer(CALLBACK(H,/mob/proc/add_movespeed_modifier,MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED,1),2 SECONDS)

/obj/item/radio/headset/heads/archivist
	name = "archivist's headset"
	desc = "The headset of an Archivist. <span color='#ff9900'>We hear everything.</span>"
	icon = 'icons/obj/archivist.dmi'
	icon_state = "archivistheadset"
	archivist = TRUE
	commandspan = SPAN_ARCHIVISTLOUD
	keyslot = new /obj/item/encryptionkey/archivist

/obj/item/encryptionkey/archivist
	name = "archivist encryption key"
	icon = 'icons/obj/archivist.dmi'
	icon_state = "archivistcypherkey"
	archivist = TRUE
	independent = TRUE
	channels = list(RADIO_CHANNEL_COMMON = 1/*in case you change the frequency*/, RADIO_CHANNEL_SYNDICATE = 1,RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1,RADIO_CHANNEL_CENTCOM = 1,RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_ARCHIVIST = 1)
/*
/obj/item/archivist_tool/darklight
	name = "darklight"
	desc = "A flashlight that extinguishes light near it instead of emitting light."
	icon_state = "darklight"
	var/list/objectsdarkened = list()
	var/ison = FALSE

/obj/item/archivist_tool/darklight/Destroy()
	SSobj.processing -= src
	return ..()

/obj/item/archivist_tool/darklight/process()
	var/list/objects = orange(4,src)
	for (var/obj/item/D in objectsdarkened)
		if (!(D in objects))
			D.light_power = initial(D.light_power)
			LAZYREMOVE(objectsdarkened,D)
	for (var/H in objects)
		if (isitem(H))
			var/obj/item/S = H
			if (S.light_range && S.light_power)
				LAZYADD(objectsdarkened,S)
				S.light_power = 0
		if (isliving(H))
			for (var/obj/item/O in H)
				if(O.light_range && O.light_power)
					LAZYADD(objectsdarkened,O)
					O.light_power = 0


/obj/item/archivist_tool/darklight/attack_self(mob/user)
	if (!ison)
		START_PROCESSING(SSobj,src)
		icon_state = "[initial(icon_state)]0"
	else
		icon_state = initial(icon_state)
		STOP_PROCESSING(SSobj,src)
	ison = !ison
	..()
*/
/*
/obj/item/archivist_tool/slipspacepen //make a subtype of pens
	name = "pen"
	desc = "A normal black ink pen."
	//works as a desync, except you can move, can't see anyone
	//around you though, and you can move past them.
	//same as scarf but only check for mobs.density on turf
*/
/obj/item/pen/slipspace
	var/cooldown = 0
	var/timeconcealed = 0
	var/ison = FALSE
	var/list/image/concealed = list()
	var/mob/usercurrent

/obj/item/pen/slipspace/attack_self(mob/user)
	if (!ison)
		to_chat(user,"<span class='notice'>You press the button on the pen and disappear into the yellowspace slipstream.</span>")
		turnon(user)
	else
		to_chat(user,"<span class='notice'>You press the button on the pen and reappear from the yellowspace slipstream.</span>")
		turnoff(user)
	ison = !ison

/obj/item/pen/slipspace/proc/turnon(mob/user)
	for (var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if (H == user)
			continue
		var/image/A = image('icons/effects/effects.dmi',H,"nothing")
		A.name = ""
		A.override = 1
		if (user.client)
			concealed |= A
			user.client.images |= A
	user.invisibility = INVISIBILITY_OBSERVER
	user.see_invisible = SEE_INVISIBLE_OBSERVER
	LAZYADD(user.user_movement_hooks,src)
	usercurrent = user

/obj/item/pen/slipspace/proc/turnoff(mob/user)
	LAZYREMOVE(user.user_movement_hooks,src)
	user.invisibility = initial(user.invisibility)
	user.see_invisible = initial(user.see_invisible)
	if (user.client)
		for (var/image/I in concealed)
			user.client.images.Remove(I)
	usercurrent = null

/obj/item/pen/slipspace/Destroy()
	if (ison)
		turnoff(usercurrent)

/obj/item/pen/slipspace/intercept_user_move(dir,mob/living/m,newloc,oldloc)
	if (isturf(newloc))
		var/turf/n = newloc
		if (!n.CanPass(m,newloc))
			return
		for (var/M in newloc)
			if (ismob(M))
				continue
			var/obj/F = M
			if (!F.CanPass(m,newloc))
				return
		for (var/L in oldloc)
			if (ismob(L))
				continue
			var/obj/J = L
			if (!J.CanPass(m,oldloc))
				return
	m.forceMove(newloc)

/obj/item/archivist_tool/soundbarrier
	name = "soundwave propulsion device"
	desc = "Creates a standing wave that gets pushed towards the target, forcing anything in it's way back."

/obj/item/archivist_tool/tankminimizer
	name = "tank minimizer"
	desc = "Compresses internals tanks to the point they can be left to hang on masks easily."



/obj/item/tank/internals/minimized
	name = "minimized tank"
	desc = "A tank of gas that has been extremely compressed."
	volume = 50

/obj/item/archivist_tool/solarpowerbeacon
	name = "solar power beacon"
	desc = "A wireless energy converter and transferrer for solar energy."
	icon_state = "solarbeacon"
	var/obj/item/clothing/shoes/solarboots/linkedboots

/obj/item/archivist_tool/solarpowerbeacon/process()
	if (linkedboots)
		for (var/turf/T in view(3,src))
			if (isspaceturf(T))
				linkedboots.power = min(initial(linkedboots.power),linkedboots.power + 10)

/obj/item/archivist_tool/solarpowerbeacon/Destroy()
	SSobj.processing -= src
	return ..()

//and a beacon like stargazer that wirelessly connects for power
/obj/item/clothing/shoes/solarboots //speed boost boots that use power
	name = "solar converters"
	desc = "Boots that take energy from the sun and convert it to energy. It has a removable power beacon."
	var/power = 4000
	var/ison = FALSE
	var/setting = 1
	icon = 'icons/obj/archivist.dmi'
	icon_state = "solarboots"
	slowdown = SHOES_SLOWDOWN
	var/obj/item/archivist_tool/solarpowerbeacon/beacon
	var/beaconattached = TRUE

/obj/item/clothing/shoes/solarboots/Initialize()
	..()
	initbeacon()

/obj/item/clothing/shoes/solarboots/proc/initbeacon()
	if (!beacon)
		beacon = new /obj/item/archivist_tool/solarpowerbeacon
		beacon.linkedboots = src
		START_PROCESSING(SSobj,beacon)
		icon_state = "solarboots0"

/obj/item/clothing/shoes/solarboots/proc/turnon()
	slowdown = -1 * setting * 0.5
	ison = TRUE
	START_PROCESSING(SSobj,src)

/obj/item/clothing/shoes/solarboots/proc/turnoff()
	slowdown = SHOES_SLOWDOWN
	ison = FALSE
	STOP_PROCESSING(SSobj,src)

/obj/item/clothing/shoes/solarboots/CtrlClick(mob/user)
	if (beacon && beaconattached)
		user.put_in_hands(beacon)
		beaconattached = FALSE
		icon_state = "solarboots"

/obj/item/clothing/shoes/solarboots/attackby(obj/item/I, mob/user)
	if (istype(I,/obj/item/archivist_tool/solarpowerbeacon))
		if (!beaconattached && I == beacon)
			user.transferItemToLoc(I,src)
			beaconattached = TRUE
			icon_state = "solarboots0"

/obj/item/clothing/shoes/solarboots/AltClick(mob/user)
	if (setting != 1 && setting != 2 && setting != 3)
		setting = 1
	switch(setting)
		if (1)
			setting = 2
		if (2)
			setting = 3
		if (3)
			setting = 1
	if (ison)
		slowdown = -1 * setting * 0.5
	to_chat(user,"<span class='notice'>The boots are at a speed boost of [setting].</span>")

/obj/item/clothing/shoes/solarboots/examine(mob/user)
	..()
	to_chat(user,"<span class='notice'>The boots are at a speed boost of [setting].</span>")
	to_chat(user,"<span class='notice'>They are [round((power/initial(power))*100)]% charged.</span>")

/obj/item/clothing/shoes/solarboots/process()
	if (!ismob(loc))
		turnoff()
		return
	if (ison)
		if (power - (45 * setting) <= 0)
			turnoff()
			return
		power -= 45 * setting

/obj/item/clothing/shoes/solarboots/verb/toggle()
	set name = "Toggle Solarboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	if (ison)
		turnoff()
	else
		turnon()

/obj/item/clothing/shoes/solarboots/Destroy()
	if (ison)
		turnoff()
	SSobj.processing -= src
	return ..()

/obj/item/archivist_tool/soundbarrier
	name = "soundwave ring"
	desc = "A device that emits an extremely loud noise, deafening and stunning anyone who can hear it. Comes with earmuffs."
	//small warning "You hear a light ringing."
	//Narsie level archivist text "All you can feel is a wave of sound."

/obj/item/archivist_tool/gravityslinger
	name = "gravity slinger"
	desc = "Like the gravity cannon, but better."

/obj/item/archivist_tool/cameraglasses
	name = "camera glasses"
	desc = "The name says it all."

/obj/item/holosign_creator/archivist
	name = "archivist wall projector"
	desc = "A holographic projector that creates holographic walls only archivists can pass through."
	icon_state = "signmaker_archivist"
	icon = 'icons/obj/archivist.dmi'
	holosign_type = /obj/structure/holosign/barrier/archivist
	creation_time = 0
	max_signs = 4

/obj/structure/holosign/barrier/archivist
	name = "archivist wall"
	desc = "A wall only archivists can pass through. Also works as a holofan."
	icon_state = "holowall"
	density = FALSE
	anchored = TRUE
	alpha = 150
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/holosign/barrier/archivist/CanPass(atom/movable/mover,turf/target)
	if (isarchivist(mover))
		return TRUE

/obj/item/archivist_tool/swisstool
	name = "swiss army tool"
	desc = "A tool that has all the tools in it."
	var/list/tools = list(/*all the tools in here, create in Initialize()*/)
	var/obj/item/selected

/obj/item/archivist_tool/hologramcapture
	name = "hololight capturer"
	desc = "A device that can store and create solograms, by scanning items/people."

/obj/item/archivist_tool/hardlightbat
	name = "hardlight bat"
	desc = "A baseball bat that automatically fabricates hardlight baseballs."
	//basically a kpa but with more time and still works normally

/obj/item/archivist_tool/freezegun
	name = "time freezer"
	desc = "Freezes the target in a bluespace pocket, muting them and stopping them from doing anything."

/obj/item/archivist_tool/
	name = "archivist_tool"
	desc = "desc"
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
	var/chargecost = 1
