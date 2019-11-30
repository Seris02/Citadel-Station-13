#define EFFECT_STAFF_STUN "stun"
#define EFFECT_STAFF_REPULSE "repulse"
#define EFFECT_STAFF_ATTRACTION "attraction"
#define EFFECT_STAFF_SLEEP "sleep"
#define EFFECT_STAFF_TELEPORT "teleport"
#define EFFECT_STAFF_PEACE "peace"
#define EFFECT_STAFF_HALLUCINOGEN "hallucinogen"
#define EFFECT_STAFF_SLOW "slow"
#define EFFECT_STAFF_BLIND "blind"

#define TARGET_STAFF_SINGLE "single"
#define TARGET_STAFF_AOE "aoe"
#define TARGET_STAFF_BULKY "bulky"
#define TARGET_STAFF_REMOTE "remote"

#define WIELD_STAFF_SINGLEHAND "single"
#define WIELD_STAFF_TWOHAND "two"
#define WIELD_STAFF_SWITCHHAND "switch"
#define WIELD_STAFF_SMALLHAND "small"
#define WIELD_STAFF_THROWHAND "throw"

/obj/item/archivist_tool/archivist_staff
	name = "archivist's staff"
	desc = "The most powerful tool that an archivist can have."
	icon_state = "coderhandle"
	item_state = "singlehandle"
	lefthand_file = 'icons/mob/inhands/antag/archivist_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/archivist_righthand.dmi'
	var/handlename = "coderwielded"
	var/iswielded = FALSE
	var/poweramp = 1
	var/wieldedamp = 1
	var/canbewielded = FALSE
	var/staffeffect = WIELD_STAFF_SINGLEHAND
	var/mustbewielded = FALSE
	var/changeicon = FALSE
	var/cooldown = FALSE
	var/weightafter = WEIGHT_CLASS_BULKY
	includeinlist = FALSE //testing
	var/iscomplete = FALSE
	var/mustbeinhands = TRUE
	/*
		top: major effect eg repulse, stun, sleep
		middle: wield/onehanded/both
		base: aoe/targeted/whole bulky
	*/
	var/obj/item/archivist_tool/stafftop/top = null
	var/hasbase = TRUE
	var/obj/item/archivist_tool/staffbase/base = null
	var/obj/item/archivist_tool/staffacc/acc = null

/obj/item/archivist_tool/archivist_staff/attackby(obj/item/A, mob/user, params)
	var/addedthing = FALSE
	if (istype(A,/obj/item/archivist_tool/stafftop))
		if (!top)
			top = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
			addedthing = TRUE
	if (istype(A,/obj/item/archivist_tool/staffbase) && hasbase)
		if (!base)
			base = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
			addedthing = TRUE
	if (istype(A,/obj/item/archivist_tool/staffacc))
		if (!acc)
			acc = A
			update_icon()
			A.moveToNullspace()
			to_chat(user, "<span class='notice'>You add the [A.name] to the [src.name].</span>")
	if (addedthing)
		if (top && (base || !hasbase))
			name = "[handlename][hasbase ? " [base.staffname] " : " "][top.staffname] staff"
			desc = "The most powerful tool that an archivist can have.[(canbewielded) ? "\nAlt click to wield/unwield." : ""]"
			w_class = weightafter
			iscomplete = TRUE
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

/obj/item/archivist_tool/archivist_staff/proc/getfulleffect(mob/target,mob/user,acceffect,proximity = TRUE)
	if ((!hasbase || hasbase && base.mustbenear) && !proximity)
		return
	if (mustbeinhands)
		if (user.get_active_held_item() != src)
			return
	var/power = getpower()
	if (power == 0 || !iscomplete)
		return
	playsound(loc,'sound/weapons/staffwave.ogg',50,1,-1)
	new /obj/effect/archivist_wave(user ? (target ? get_turf(target) : get_turf(user)) : get_turf(src))
	var/cooldowns = target ? 10 : 15
	if (acc)
		var/list/k = acc.get_power_override(target,power,user,src,acceffect)
		power = k["power"]
		cooldowns = k["cooldown"]
		if (power == 0)
			return
	var/cooldownonbase = (hasbase) ? base.get_cooldown() : 1
	var/dampen = (hasbase) ? base.get_dampen() : 1
	var/list/mobs = (hasbase) ? base.get_mobs(target,user) : ((target && !isarchivist(target)) ? list(target) : list())
	for (var/G in mobs)
		top.effect_on_target(G,power*dampen,user)
	user.visible_message("<span class='danger'>[istype(user) ? "[user] slams the [src.name]" : "The [src.name] slams"] into [target ? target : "the floor"]!</span>")
	cooldown = world.time + cooldowns + cooldownonbase

/obj/item/archivist_tool/archivist_staff/proc/unwield(mob/living/carbon/user)
	if (!iswielded || !user|| !iscomplete) //copied, but it's edited
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
	if (iswielded || !canbewielded || !iscomplete)
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
		acc.specialaction() //no cooldown stopping this

/obj/item/archivist_tool/archivist_staff/attack(mob/target,mob/user)
	if (cooldown < world.time)
		return ..()

/obj/item/archivist_tool/archivist_staff/attack_self(mob/user)
	if (cooldown < world.time)
		getfulleffect(null,user,0)

/obj/item/archivist_tool/archivist_staff/afterattack(atom/target, mob/user, proximity_flag)
	if(cooldown < world.time && isliving(target))
		getfulleffect(target,user,FALSE,proximity = (proximity_flag == TRUE) ? TRUE : FALSE)

/obj/item/archivist_tool/archivist_staff/worn_overlays(isinhands,icon_file)
	. = ..()
	if (isinhands && iscomplete)
		var/hand
		message_admins("[isinhands] and [loc]")
		if (ishuman(loc))
			var/mob/living/carbon/human/H = loc
			hand = H.get_item_for_held_index(1) == src ? "left" : "right"
			if ((base && hasbase) || !hasbase)
				. += base.get_worn_staff_overlay(hand)
			if (top)
				. += top.get_worn_staff_overlay(hand)
		else
			return


//PARTS

/obj/effect/archivist_wave
	name = "wave"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	icon_state = "archivist_wave"
	light_power = 1.3
	light_color = LIGHT_COLOR_CYAN
	light_range = 3

/obj/effect/archivist_wave/Initialize()
	. = ..()
	QDEL_IN(src, 5)

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

/obj/item/archivist_tool/stafftop/proc/get_worn_staff_overlay(hand)
	if (hand == "left")
		return mutable_appearance('icons/mob/inhands/antag/archivist_lefthand.dmi', "[staffname]top")
	if (hand == "right")
		return mutable_appearance('icons/mob/inhands/antag/archivist_righthand.dmi', "[staffname]top")

/obj/item/archivist_tool/staffbase
	name = "normal staff base"
	icon_state = "coderbase"
	var/staffname = "coder"
	desc = "error 404 base not found"
	var/staffeffect = TARGET_STAFF_SINGLE
	includeinlist = FALSE //testing
	var/mustbenear = TRUE

/obj/item/archivist_tool/staffbase/proc/get_dampen()
	return 1

/obj/item/archivist_tool/staffbase/proc/get_staff_overlay()
	return mutable_appearance('icons/obj/archivist.dmi', "[staffname]base")

/obj/item/archivist_tool/staffbase/proc/get_mobs(mob/target,mob/user)
	return

/obj/item/archivist_tool/staffbase/proc/get_cooldown()
	return 0

/obj/item/archivist_tool/staffbase/proc/get_worn_staff_overlay(hand)
	if (hand == "left")
		return mutable_appearance('icons/mob/inhands/antag/archivist_lefthand.dmi', "[staffname]base")
	if (hand == "right")
		return mutable_appearance('icons/mob/inhands/antag/archivist_righthand.dmi', "[staffname]base")

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
	return list("power" = power, "cooldown" = target ? 10 : 15)

/obj/item/archivist_tool/staffacc/proc/specialaction()
	return



/*TODOD:

chemical warfare staff top?


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
	var/dirtogo = get_turf(user) == get_turf(target) ? pick(GLOB.alldirs) : get_dir(user,get_step_away(target,user))
	var/atom/F = get_edge_target_turf(target,dirtogo)
	target.throw_at(F,round(10*power),1)

/obj/item/archivist_tool/stafftop/attract
	name = "attraction staff top"
	icon_state = "attractiontop"
	staffname = "attraction"
	desc = "A top for attraction forces on an archivist's staff."
	staffeffect = EFFECT_STAFF_ATTRACTION
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/attract/effect_on_target(mob/target,power,mob/user)
	var/dirtogo = get_turf(user) == get_turf(target) ? pick(GLOB.alldirs) : get_dir(user,get_step_away(user,target))
	var/atom/F = get_edge_target_turf(target,dirtogo)
	target.throw_at(F,min(round(10*power),max(get_dist(user,target) - 1,0)),1)

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
	target.flash_lighting_fx(3, 3, rand(0,1) ? LIGHT_COLOR_ORANGE : LIGHT_COLOR_CYAN)
	do_teleport(target,locate(target.x + rand(round(-5*power),round(5*power)),target.y + rand(round(-5*power),round(5*power)),target.z), channel=null)

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
	var/hallucinations = list(/datum/hallucination/delusion,/datum/hallucination/stray_bullet,/datum/hallucination/fire,/datum/hallucination/oh_yeah,/datum/hallucination/xeno_attack,/datum/hallucination/shock,/datum/hallucination/death)

/obj/item/archivist_tool/stafftop/hallucination/effect_on_target(mob/target,power,mob/user)
	var/index = round(power)
	var/low = index - 2
	if (low < 1)
		low = 1
	if (index < 1)
		index = 3
	if (index > 7)
		index = 7
	if (low > 7)
		low = 5
	var/H = hallucinations[rand(low,index)]
	new H(target)

/obj/item/archivist_tool/stafftop/slowing
	name = "slowing staff top"
	icon_state = "slowingtop"
	staffname = "slowing"
	desc = "A top for forcing pacifism in targets on an archivists's staff."
	staffeffect = EFFECT_STAFF_SLOW
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/slowing/effect_on_target(mob/target,power,mob/user)
	target.add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = 5*power)
	addtimer(CALLBACK(target,/mob/proc/add_movespeed_modifier,MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED,1),5 SECONDS)

/obj/item/archivist_tool/stafftop/blinding
	name = "blinding staff top"
	icon_state = "blindingtop"
	staffname = "blinding"
	desc = "A top for blurring the sight targets on an archivists's staff."
	staffeffect = EFFECT_STAFF_BLIND
	includeinlist = TRUE //testing

/obj/item/archivist_tool/stafftop/blinding/effect_on_target(mob/target,power,mob/user)
	if (power > 1)
		target.adjust_blindness(10*power)
	else
		target.adjust_blurriness(5*power)
	addtimer(CALLBACK(src,.proc/unblind,target,power),max((7 SECONDS)*power,3 SECONDS))

/obj/item/archivist_tool/stafftop/blinding/proc/unblind(mob/target,power)
	if (power > 1)
		target.adjust_blindness(-(10*power))
	else
		target.adjust_blurriness(-(5*power))

/obj/item/archivist_tool/archivist_staff/single
	name = "single-handed staff handle"
	desc = "A single-handed staff handle for the archivist's staff."
	icon_state = "singlehandle"
	handlename = "single-handed"
	poweramp = 1.25
	canbewielded = FALSE
	staffeffect = WIELD_STAFF_SINGLEHAND
	includeinlist = TRUE
	weightafter = WEIGHT_CLASS_NORMAL

/obj/item/archivist_tool/archivist_staff/switch
	name = "switch staff handle"
	desc = "A single or double-handed staff handle for the archivist's staff."
	icon_state = "switchhandle"
	handlename = "switch-handed"
	item_state = "switchhandle"
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
	item_state = "doublehandle"
	poweramp = 1
	wieldedamp = 3
	canbewielded = TRUE
	mustbewielded = TRUE
	staffeffect = WIELD_STAFF_TWOHAND
	includeinlist = TRUE
	weightafter = WEIGHT_CLASS_HUGE

/obj/item/archivist_tool/archivist_staff/short
	name = "short staff handle"
	desc = "A short staff handle for the archivist's staff."
	icon_state = "shorthandle"
	handlename = "short"
	item_state = "shorthandle"
	poweramp = 0.5
	hasbase = FALSE
	canbewielded = FALSE
	staffeffect = WIELD_STAFF_SMALLHAND
	includeinlist = TRUE
	weightafter = WEIGHT_CLASS_SMALL

/obj/item/archivist_tool/archivist_staff/throw
	name = "throwing staff handle"
	desc = "A staff handle for throwing the archivist's staff. Use it inhand to link it to yourself."
	icon_state = "throwhandle"
	handlename = "throwing"
	item_state = "throwhandle"
	poweramp = 0.2
	hasbase = FALSE
	canbewielded = FALSE
	staffeffect = WIELD_STAFF_THROWHAND
	includeinlist = TRUE
	weightafter = WEIGHT_CLASS_TINY
	mustbeinhands = FALSE
	var/mob/linkedperson = null
	var/obj/effect/proc_holder/spell/targeted/archivistrecall/recallspell = null

/obj/item/archivist_tool/archivist_staff/throw/attack_self(mob/user)
	// no ..() because it's so small... how would you even stamp it against the floor
	if (isarchivist(user) && !linkedperson && isliving(user))
		for (var/spell in user.mind.spell_list)
			if (istype(spell,/obj/effect/proc_holder/spell/targeted/archivistrecall))
				return
		linkedperson = user
		recallspell = new /obj/effect/proc_holder/spell/targeted/archivistrecall()
		recallspell.staff = src
		user.mind.AddSpell(recallspell)
		recallspell.action.button_icon = 'icons/mob/actions/backgrounds.dmi'
		recallspell.action.background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
		update_icon()

/obj/item/archivist_tool/archivist_staff/throw/update_icon()
	..()
	if (recallspell)
		var/old_layer = layer
		var/old_plane = plane
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE
		recallspell.action.button.cut_overlays()
		recallspell.action.button.add_overlay(src)
		layer = old_layer
		plane = old_plane

/obj/item/archivist_tool/archivist_staff/throw/throw_impact(atom/hit)
	..()
	if (isliving(hit))
		getfulleffect(hit,get_turf(src),FALSE)

/obj/effect/proc_holder/spell/targeted/archivistrecall
	name = "Recall Staff"
	desc = "Recalls the archivist staff linked to you."
	charge_max = 100
	clothes_req = 0
	range = -1
	level_max = 0
	cooldown_min = 100
	include_user = 1
	var/obj/staff = null

/obj/effect/proc_holder/spell/targeted/archivistrecall/cast(list/targets,mob/user = usr)
	if (staff)
		for (var/mob/living/L in targets)
			if (!L.put_in_hands(staff) && L)
				staff.forceMove(get_turf(L.drop_location()))
				return
	else
		user.RemoveSpell(src)

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
	if (target && !isarchivist(target) && isliving(target))
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

/obj/item/archivist_tool/staffbase/radial/get_cooldown()
	return 2^radius

/obj/item/archivist_tool/staffbase/radial/get_dampen()
	return min(1,(1/radius)*1.2)

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
	radius = radius < 1 ? 1 : radius

/obj/item/archivist_tool/staffbase/bulky
	name = "bulky staff base"
	icon_state = "bulkybase"
	staffname = "bulky"
	desc = "A base for an archivist's staff which targets all creatures in a large radius."
	staffeffect = TARGET_STAFF_BULKY
	includeinlist = TRUE

/obj/item/archivist_tool/staffbase/bulky/get_dampen()
	return 0.15

/obj/item/archivist_tool/staffbase/bulky/get_cooldown()
	return 60

/obj/item/archivist_tool/staffbase/bulky/get_mobs(mob/target,mob/user)
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


/obj/item/archivist_tool/staffbase/remote
	name = "remote staff base"
	icon_state = "remotebase"
	staffname = "remote"
	desc = "A base for an archivist's staff which targets the creature you aim at."
	staffeffect = TARGET_STAFF_REMOTE
	includeinlist = TRUE
	mustbenear = FALSE

/obj/item/archivist_tool/staffbase/remote/get_dampen()
	return 0.3

/obj/item/archivist_tool/staffbase/remote/get_cooldown()
	return 40

/obj/item/archivist_tool/staffbase/remote/get_mobs(mob/target,mob/user)
	if (target && !isarchivist(target) && isliving(target))
		return list(target)
	return list()

/obj/item/archivist_tool/staffacc/delay
	name = "delaying staff addition"
	desc = "Adds a delay to any effects of the archivist's staff."
	icon_state = "delayacc"
	staffname = "delay"
	var/delay = 2 SECONDS

/obj/item/archivist_tool/staffacc/delay/specialaction()
	var/delays = input(user,"Delay of effect in seconds", text("Input")) as num|null
	delay = min(5 SECONDS,round(delays*20))

/obj/item/archivist_tool/staffacc/delay/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	if (acceffect == FALSE)
		addtimer(CALLBACK(staff,/obj/item/archivist_tool/archivist_staff/proc/getfulleffect,target,user,TRUE),delay)
		return list("power" = 0, "cooldown" = target ? 10 : 15)
	return list("power" = power*0.5, "cooldown" = target ? 10 : 15)

/obj/item/archivist_tool/staffacc/repeated
	name = "repeating staff addition"
	desc = "Adds a repeating to any effects of the archivist's staff."
	icon_state = "repeatacc"
	staffname = "repeat"

/obj/item/archivist_tool/staffacc/repeated/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	if (acceffect <= 0.2)
		addtimer(CALLBACK(staff,/obj/item/archivist_tool/archivist_staff/proc/getfulleffect,target,user,(acceffect+0.1)),1 SECONDS)
		return list("power" = power*0.5, "cooldown" = target ? 10 : 15)
	return list("power" = 0, "cooldown" = target ? 10 : 15)


/obj/item/archivist_tool/staffacc/overcharged
	name = "overcharged staff addition"
	desc = "Adds a significant power increase to any effects of the archivist's staff in exchange for significant cooldown increase."
	icon_state = "overchargedacc"
	staffname = "overcharged"

/obj/item/archivist_tool/staffacc/overcharged/get_power_override(mob/target,power,mob/user,obj/item/archivist_tool/archivist_staff/staff,acceffect)
	return list("power" = power*3, "cooldown" = target ? 100 : 120)