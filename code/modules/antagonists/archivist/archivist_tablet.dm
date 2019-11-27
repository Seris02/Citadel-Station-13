/obj/item/archivist_tablet
	name = "archivist tablet"
	desc = "A tablet given to archivists by the Archivist Association to get what they need done."
	icon = 'icons/obj/archivist.dmi'
	icon_state = "tablet"
	var/list/archivist_items
	var/list/archivist_paths
	var/charges = 6

/obj/item/archivist_tablet/proc/get_items()
	archivist_items = list()
	archivist_paths = list()
	var/list/archivist_tools = subtypesof(/obj/item/archivist_tool)
	for (var/A in archivist_tools)
		var/obj/item/archivist_tool/I = new A
		if (I.includeinlist == FALSE)
			archivist_tools -= A
		qdel(I)
	archivist_tools += /obj/item/card/id/archivist
	archivist_tools += /obj/item/clothing/gloves/paralysis
	for (var/A in archivist_tools)
		var/obj/item/archivist_tool/I = new A
		archivist_items += list(list("name" = I.name, "desc" = I.desc))
		archivist_paths[I.name] = I.type
		qdel(I)

/obj/item/archivist_tablet/attack_self(mob/living/user)
	if (isarchivist(user))
		ui_interact(user)

/obj/item/archivist_tablet/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	if (!archivist_items || archivist_items.len == 0)
		get_items()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "archivist_tablet", name, 300, 600, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.set_style("archivist")
		ui.open()

/obj/item/archivist_tablet/ui_data(mob/user)
	var/list/data = list()
	data["items"] = archivist_items
	data["charges"] = charges
	return data

/obj/item/archivist_tablet/ui_act(action, params)
	switch(action)
		if("take")
			var/atom/A = archivist_paths[params["item"]]
			new A(get_turf(src))
			charges--
	return TRUE
