#define EFFECT_STAFF_STUN "stun"
#define EFFECT_STAFF_REPULSE "repulse"
#define EFFECT_STAFF_ATTRACTION "attraction"
#define EFFECT_STAFF_SLEEP "sleep"
#define EFFECT_STAFF_TELEPORT "teleport"
#define EFFECT_STAFF_PEACE "peace"
#define EFFECT_STAFF_HALLUCINOGEN "hallucinogen"

#define TARGET_STAFF_SINGLE "single"
#define TARGET_STAFF_AOE "aoe"
#define TARGET_STAFF_SCREEN "screen"

#define WIELD_STAFF_SINGLEHAND "single"
#define WIELD_STAFF_TWOHAND "two"
#define WIELD_STAFF_SWITCHHAND "switch"

/obj/item/archivist_tool/archivist_staff
	name = "archivist's staff"
	desc = "The most powerful tool that an archivist can have."
	icon_state = "coderhandle"
	var/handlename = "coderwielded"
	var/iswielded = FALSE
	var/poweramp = 2
	var/wieldedamp = 2
	var/canbewielded = FALSE
	var/staffeffect = WIELD_STAFF_SINGLEHAND
	var/mustbewielded = FALSE
	var/changeicon = FALSE
	var/cooldown = FALSE
	includeinlist = FALSE //testing
	/*
		top: major effect eg repulse, stun, sleep
		middle: wield/onehanded/both
		base: aoe/targeted/whole screen
	*/
	var/obj/item/archivist_tool/stafftop/top = null
	var/obj/item/archivist_tool/staffbase/base = null
	var/obj/item/archivist_tool/staffacc/acc = null

/obj/item/archivist_tool/archivist_staff/attackby(obj/item/A, mob/user, params)
	if (istype(A,/obj/item/archivist_tool/stafftop))
		if (!top)
			top = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
	if (istype(A,/obj/item/archivist_tool/staffbase))
		if (!base)
			base = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
	if (istype(A,/obj/item/archivist_tool/staffacc))
		if (!acc)
			acc = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
	if (top && base)
		name = "[handlename] [base.staffname] [top.staffname] staff"
		desc = "The most powerful tool that an archivist can have.[(canbewielded) ? "\nAlt click to wield/unwield." : ""]"
		w_class = WEIGHT_CLASS_BULKY
	..()

/obj/item/archivist_tool/archivist_staff/update_icon()
	cut_overlays()
	if (top)
		var/mutable_appearance/M = top.get_staff_overlay()
		add_overlay(M)
	if (base)
		var/mutable_appearance/M = base.get_staff_overlay()
		add_overlay(M)
	if (acc)
		var/mutable_appearance/M = acc.get_staff_overlay()
		add_overlay(M)
	..()

/obj/item/archivist_tool/archivist_staff/Initialize()
	. = ..()
	update_icon()

/obj/item/archivist_tool/archivist_staff/proc/getpower()
	if (mustbewielded == FALSE || (mustbewielded == TRUE && iswielded == TRUE))
		return (canbewielded == TRUE && iswielded == TRUE) ? wieldedamp  * poweramp : poweramp
	return 0

/obj/item/archivist_tool/archivist_staff/proc/getfulleffect(mob/target,mob/user,acceffect)
	var/power = getpower()
	if (power == 0)
		return
	playsound(loc,'sound/weapons/staffwave.ogg',50,1,-1)
	if (acc)
		power = acc.get_power_override(target,power,user,src,acceffect)
		if (power == 0)
			return
	var/list/mobs = base.get_mobs(target,user)
	for (var/G in mobs)
		top.effect_on_target(G,power*base.get_dampen(),user)
	cooldown = TRUE
	addtimer(CALLBACK(src,.proc/stopcooldown),15)

/obj/item/archivist_tool/archivist_staff/proc/stopcooldown()
	cooldown = FALSE

/obj/item/archivist_tool/archivist_staff/proc/unwield(mob/living/carbon/user)
	if (!iswielded || !user) //copied, but it's edited
		return
	iswielded = FALSE
	to_chat(user,"<span class='notice'>You are now carrying [src] with one hand.</span>")
	var/obj/item/twohanded/offhand/O = user.get_inactive_held_item()
	if (O && istype(O))
		O.unwield()
	if (changeicon == TRUE)
		icon_state = initial(icon_state)
		update_icon()

/obj/item/archivist_tool/archivist_staff/proc/wield(mob/living/carbon/user)
	if (iswielded || !canbewielded)
		return
	if (user.get_inactive_held_item())
		to_chat(user,"<span class='warning'>You need your other hand to be empty!</span>")
		return
	if (user.get_num_arms() < 2)
		to_chat(user,"<span class='warning'>You don't have enough intact hands.</span>")
	iswielded = TRUE
	var/obj/item/twohanded/offhand/O = new(user)
	O.name = "[name] - offhand"
	O.desc = "Your second grip on [src]."
	O.wielded = TRUE
	user.put_in_inactive_hand(O)
	if (changeicon == TRUE)
		icon_state = "[icon_state]0"
		update_icon()

/obj/item/archivist_tool/archivist_staff/dropped(mob/user)
	. = ..()
	if (!iswielded)
		return
	unwield(user)

/obj/item/archivist_tool/archivist_staff/equipped(mob/user)
	..()
	if (!user.is_holding(src) && iswielded)
		unwield(user)

/obj/item/archivist_tool/archivist_staff/AltClick(mob/user)
	..()
	if (!iswielded)
		wield(user)
		return
	if (iswielded)
		unwield(user)
		return

/obj/item/archivist_tool/archivist_staff/CtrlClick(mob/user)
	..()
	if (acc)
		acc.specialaction()

/obj/item/archivist_tool/archivist_staff/attack_self(mob/user)
	getfulleffect(null,user,0)

/obj/item/archivist_tool/archivist_staff/attack(mob/living/carbon/M,mob/living/carbon/user)
	if (!cooldown)
		getfulleffect(M,user,0)


//PARTS

/obj/item/archivist_tool/stafftop
	name = "normal staff top"
	icon_state = "codertop"
	var/staffname = "coder"
	desc = "error 404 top not found"
	var/staffeffect = null
	includeinlist = FALSE //testing

/obj/item/archivist_tool/stafftop/proc/get_staff_overlay()
	return mutable_appearance('icons/obj/archivist.dmi', "[staffname]top")

/obj/item/archivist_tool/stafftop/proc/effect_on_target(mob/target, power,mob/user)
	return

/obj/item/archivist_tool/staffbase
	name = "normal staff base"
	icon_state = "coderbase"
	var/staffname = "coder"
	desc = "error 404 base not found"
	var/staffeffect = TARGET_STAFF_SINGLE
	includeinlist = FALSE //testing

/obj/item/archivist_tool/staffbase/proc/get_dampen()
	return 1

/obj/item/archivist_tool/staffbase/proc/get_staff_overlay()
	return mutable_appearance('icons/obj/archivist.dmi', "[staffname]base")

/obj/item/archivist_tool/staffbase/proc/get_mobs(mob/target,mob/user)
	return

/obj/item/archivist_tool/staffacc
	name = "normal staff addition"
	desc = "error 404 addon not found"
	icon_state = "coderacc"
	var/staffname = "coder"
	var/poweroverride = 1
	var/mob/user
	var/mob/target

/obj/item/archivist_tool/staffacc/proc/get_staff_overlay()
	return mutable_appearance('icons/obj/archivist.dmi', "[staffname]acc0")

/obj/item/archivist_tool/staffacc/proc/get_power_override(mob/target,power,mob/user,var/obj/item/archivist_tool/archivist_staff/staff,acceffect)
	return power

/obj/item/archivist_tool/staffacc/proc/specialaction()
	return



/*TODOD:



*/
//PARTS

/obj/item/archivist_tool/stafftop/stun
	name = "stun staff top"
	icon_state = "stuntop"
	staffname = "stun"
	desc = "A top for stunning use on an archivist's staff."
	staffeffect = EFFECT_STAFF_STUN
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/stun/effect_on_target(mob/target,power,mob/user)
	if (ishuman(target))
		var/mob/living/carbon/human/T = target
		T.Knockdown(round((10 SECONDS) * power))
		T.adjustStaminaLoss(round((10 SECONDS) * power)*0.1)

/obj/item/archivist_tool/stafftop/repulse
	name = "repulse staff top"
	icon_state = "repulsetop"
	staffname = "repulse"
	desc = "A top for repulsion forces on an archivist's staff."
	staffeffect = EFFECT_STAFF_REPULSE
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/repulse/effect_on_target(mob/target,power,mob/user)
	var/atom/F = get_edge_target_turf(target,get_dir(user,get_step_away(target,user)))
	target.throw_at(F,round(10*power),1)

/obj/item/archivist_tool/stafftop/attract
	name = "attraction staff top"
	icon_state = "attractiontop"
	staffname = "attraction"
	desc = "A top for attraction forces on an archivist's staff."
	staffeffect = EFFECT_STAFF_ATTRACTION
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/attract/effect_on_target(mob/target,power,mob/user)
	var/atom/F = get_edge_target_turf(target,get_dir(user,get_step_away(user,target)))
	target.throw_at(F,min(round(10*power),get_dist(user,target) - 1),1)

/obj/item/archivist_tool/stafftop/sleep
	name = "sleep staff top"
	icon_state = "sleeptop"
	staffname = "sleep"
	desc = "A top for putting targets to sleep on an archivist's staff."
	staffeffect = EFFECT_STAFF_SLEEP
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/sleep/effect_on_target(mob/target,power,mob/user)
	if (isliving(target))
		var/mob/living/T = target
		T.Sleeping(round((7 SECONDS) * power))

/obj/item/archivist_tool/stafftop/tele
	name = "tele staff top"
	icon_state = "teletop"
	staffname = "tele"
	desc = "A top for teleporting targets on an archivists's staff."
	staffeffect = EFFECT_STAFF_TELEPORT
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/tele/effect_on_target(mob/target,power,mob/user)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3,1,get_turf(src))
	s.start()
	do_teleport(target,locate(target.x + rand(round(10*power),round(15*power)),target.y + rand(round(10*power),round(15*power)),target.z), channel=null)

/obj/item/archivist_tool/stafftop/peace
	name = "peace staff top"
	icon_state = "peacetop"
	staffname = "peace"
	desc = "A top for forcing pacifism in targets on an archivists's staff."
	staffeffect = EFFECT_STAFF_PEACE
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/peace/effect_on_target(mob/target,power,mob/user)
	target.reagents.add_reagent("pax",(10*power))

/obj/item/archivist_tool/stafftop/hallucination
	name = "hallucinogenic staff top"
	icon_state = "hallucinogenictop"
	staffname = "hallucinogenic"
	desc = "A top for forcing hallucinations in targets on an archivists's staff."
	staffeffect = EFFECT_STAFF_HALLUCINOGEN
	includeinlist = TRUE //testing
	var/hallucinations = list(/datum/hallucination/stray_bullet,/datum/hallucination/fire,/datum/hallucination/oh_yeah,/datum/hallucination/shock,/datum/hallucination/death)

/obj/item/archivist_tool/stafftop/hallucination/effect_on_target(mob/target,power,mob/user)
	//new /datum/hallucination/oh_yeah(target)
	var/index = round(4*power) + 1
	var/low = index - 2
	if (low < 1)
		low = 1
	if (index < 1)
		index = 1
	if (index > 5)
		index = 5
	var/H = hallucinations[rand(low,index)]
	new H(target)

/obj/item/archivist_tool/archivist_staff/single
	name = "single-handed staff handle"
	desc = "A single-handed staff handle for the archivist's staff."
	icon_state = "singlehandle"
	handlename = "single-handed"
	poweramp = 1.5
	canbewielded = FALSE
	staffeffect = WIELD_STAFF_SINGLEHAND
	includeinlist = TRUE

/obj/item/archivist_tool/archivist_staff/single/AltClick(mob/user)
	return

/obj/item/archivist_tool/archivist_staff/switch
	name = "switch staff handle"
	desc = "A single or double-handed staff handle for the archivist's staff."
	icon_state = "switchhandle"
	handlename = "switch-handed"
	changeicon = TRUE
	poweramp = 1
	wieldedamp = 2
	canbewielded = TRUE
	staffeffect = WIELD_STAFF_SWITCHHAND
	includeinlist = TRUE

/obj/item/archivist_tool/archivist_staff/twohanded
	name = "double-handed staff handle"
	desc = "A double-handed staff handle for the archivist's staff."
	icon_state = "doublehandle"
	handlename = "double-handed"
	poweramp = 1
	wieldedamp = 3
	canbewielded = TRUE
	mustbewielded = TRUE
	staffeffect = WIELD_STAFF_TWOHAND
	includeinlist = TRUE

/obj/item/archivist_tool/staffbase/targeted
	name = "targeted staff base"
	icon_state = "targetedbase"
	staffname = "targeted"
	desc = "A base for an archivist's staff which targets a single person."
	staffeffect = TARGET_STAFF_SINGLE
	includeinlist = TRUE //testing

/obj/item/archivist_tool/staffbase/targeted/get_dampen()
	return 1

/obj/item/archivist_tool/staffbase/targeted/get_mobs(mob/target,mob/user)
	if (target && !isarchivist(target))
		return list(target)
	return list()

/obj/item/archivist_tool/staffbase/radial
	name = "radial staff base"
	icon_state = "radialbase"
	staffname = "radial"
	desc = "A base for an archivist's staff which targets all creatures in a small radius."
	staffeffect = TARGET_STAFF_AOE
	includeinlist = TRUE //testing
	var/radius = 3

/obj/item/archivist_tool/staffbase/radial/get_dampen()
	return min(1,(1/radius)*1.5)

/obj/item/archivist_tool/staffbase/radial/get_mobs(mob/target,mob/user)
	var/list/L = list()
	var/mob/focus
	if (target)
		L += target
		focus = target
	else
		focus = user
	for (var/mob/M in orange(radius,focus))
		if (istype(M) && !isarchivist(M))
			L += M
	return L

/obj/item/archivist_tool/staffbase/radial/AltClick(mob/user)
	..()
	var/rad = input(user,"Radius of AoE", text("Input")) as num|null
	radius = min(6,rad)

/obj/item/archivist_tool/staffbase/screen
	name = "bulky staff base"
	icon_state = "screenbase"
	staffname = "screen"
	desc = "A base for an archivist's staff which targets all creatures in a large radius."
	staffeffect = TARGET_STAFF_SCREEN
	includeinlist = TRUE

/obj/item/archivist_tool/staffbase/screen/get_dampen()
	return 0.25

/obj/item/archivist_tool/staffbase/screen/get_mobs(mob/target,mob/user)
	var/list/L = list()
	var/mob/focus
	if (target)
		L += target
		focus = target
	else
		focus = user
	for (var/mob/M in get_hearers_in_view(10,focus))
		if (istype(M) && !isarchivist(M))
			L += M
	return L

/obj/item/archivist_tool/staffacc/delay
	name = "delaying staff addition"
	desc = "Adds a delay to any effects of the archivist's staff."
	icon_state = "delayacc"
	staffname = "delay"
	var/delay = 5 SECONDS

/obj/item/archivist_tool/staffacc/delay/specialaction()
	var/delays = input(user,"Delay of effect", text("Input")) as num|null
	delay = min(20 SECONDS,round(delays*20))

/obj/item/archivist_tool/staffacc/delay/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	if (acceffect == FALSE)
		addtimer(CALLBACK(staff,/obj/item/archivist_tool/archivist_staff/proc/getfulleffect,target,user,TRUE),delay)
		return 0
	return power

/obj/item/archivist_tool/staffacc/repeated
	name = "repeating staff addition"
	desc = "Adds a repeating to any effects of the archivist's staff."
	icon_state = "repeatacc"
	staffname = "repeat"

/obj/item/archivist_tool/staffacc/repeated/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	if (acceffect >= 0.4)
		addtimer(CALLBACK(staff,/obj/item/archivist_tool/archivist_staff/proc/getfulleffect,target,user,acceffect*0.75),2 SECONDS)
		return power*0.5
	return 0

/obj/item/archivist_tool/staffacc/cdelay
	name = "controlled staff addition"
	desc = "Adds a controlled delay to any effects of the archivist's staff."
	icon_state = "cdelayacc"
	staffname = "cdelay"
	var/dtarget = null
	var/duser = null
	var/obj/item/archivist_tool/archivist_staff/dstaff = null

/obj/item/archivist_tool/staffacc/cdelay/specialaction()
	if (dstaff && user)
		dstaff.getfulleffect(dtarget,duser,TRUE)
		dstaff = null
		user = null

/obj/item/archivist_tool/staffacc/cdelay/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	if (acceffect == FALSE)
		duser = user
		dtarget = target
		dstaff = staff
		return 0
	return power*0.6