/proc/isarchivist(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/archivist)

/datum/game_mode/archivist
	name = "archivist"
	config_tag = "archivist"
	antag_flag = ROLE_ARCHIVIST
	false_report_weight = 15
	restricted_jobs = list("Cyborg","AI") //An AI can't steal shit
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Quartermaster")	//citadel change - adds HoP, CE, CMO, and RD to ling role blacklist
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0
	var/const/archivists_possible = 4
	round_ends_with_antag_death = 0
	announce_span = "danger"
	announce_text = "There are Archivists hidden among you!\n\
	<span class='danger'>Archivists</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let them steal your research!"
	var/list/archivists = list()
	var/num_modifier = 0
	var/archivists_required = TRUE //gottem


/datum/game_mode/archivist/pre_setup() //shamelessly copied from tator/ling

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_archivists = 1

	var/tsc = CONFIG_GET(number/archivist_scaling_coeff)
	if(tsc)
		num_archivists = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_archivists = max(1, min(num_players(), archivists_possible))

	for(var/j = 0, j < num_archivists, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/archivist = antag_pick(antag_candidates)
		archivists += archivist
		archivist.special_role = ROLE_ARCHIVIST
		archivist.restricted_roles = restricted_jobs
		log_game("[key_name(archivist)] has been selected as an [ROLE_ARCHIVIST]")
		antag_candidates.Remove(archivist)

	var/enough_archivists = !archivists_required || archivists.len > 0

	if(!enough_archivists)
		setup_error = "Not enough archivist candidates"
		return FALSE
	else
		return TRUE

/datum/game_mode/archivist/post_setup()
	for(var/datum/mind/archivist in archivists)
		log_game("[key_name(archivist)] has been selected as an archivist")
		var/datum/antagonist/archivist/new_antag = new()
		archivist.add_antag_datum(new_antag)
	..()

/datum/game_mode/archivist/make_antag_chance(mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/asc = CONFIG_GET(number/archivist_scaling_coeff)
	var/archivistcap = min(round(GLOB.joined_player_list.len / (asc * 2)) + 2 + num_modifier, round(GLOB.joined_player_list.len / asc) + num_modifier)
	if(archivists.len >= archivistcap) //Upper cap for number of latejoin antagonists
		return
	if(archivists.len <= (archivistcap - 2) || prob(100 / (asc * 2)))
		if(antag_flag in character.client.prefs.be_special)
			if(!jobban_isbanned(character, ROLE_ARCHIVIST) && !QDELETED(character) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_Archivist()
						archivists += character.mind