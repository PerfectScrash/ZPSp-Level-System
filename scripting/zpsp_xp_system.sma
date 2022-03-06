/*=============================================================================================
			 [ZPSp] Addon: XP System

	-> Description:
	This plugin will be turn your zombie plague into zombie plague xp, with rank etc

	-> How to use require level for a class/item/weapon:
	When plugin enables, will be add a level line in **zpsp_zombieclasses.ini**, **zpsp_humanclasses.ini**, **zpsp_extraitems.ini**
	and **zpsp_custom_weapons.ini** and you can change minimum level require for use this item/class/weapon

	-> Changelog:
		- Alpha (06/22): First release

	-> Credits:
		Supremache: For original RankSystem
		Perfect Scrash: For this plugin
=============================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fvault>
#include <hamsandwich>
#include <amx_settings_api>
#include <zombie_plague_special>

new const ZPSP_XP_CFG_FILE[] = "zpsp_configs/zpsp_xp_system.cfg"
new const VAULT_NAME[] = "zpsp_xp_system"

enum _:eCommandSettings {
	iMenuType, 
	iCommands[32], 
	iFlags
};

enum _:mData {
	m_szRankName[32], 
	m_iRankXP
};

#define MAXLEVEL (sizeof(g_mPlayerData)-1)
new const g_mPlayerData[][mData] = {
	{ "Newbie", 0 }, 
	{ "Killer", 90 }, 
	{ "Good Killer", 180 }, 
	{ "Super Killer", 300 }, 
	{ "Mega Killer", 450 }, 
	{ "Ultra Killer", 700 }, 
	{ "Xtreme Killer", 1200 }, 
	{ "Supernova", 1800 }, 
	{ "Monster", 2800 }, 
	{ "Professional", 4100 }, 
	{ "Builder", 5200 }, 
	{ "Pro Builder", 6000 }, 
	{ "Colonel", 6800 }, 
	{ "General", 8200 }, 
	{ "Private", 10200 }, 
	{ "Specialist", 12000 }, 
	{ "Corporal", 15000 }, 
	{ "Sargeant", 17500 }, 
	{ "Staff Sargeant", 20500 }, 
	{ "Warrant Officer", 25500 }, 
	{ "Chief Warrant Officer", 29000 }, 
	{ "Second Lieutenant", 35000 }, 
	{ "First Lieutenant", 46000 }, 
	{ "Captain", 58000 }, 
	{ "Major", 71000 }, 
	{ "Silver III", 85000 }, 
	{ "Silver II", 100000 }, 
	{ "Silver I", 116000 }, 
	{ "Silver Elite Master", 133000 }, 
	{ "Gold III", 151000 }, 
	{ "Gold II", 170000 }, 
	{ "Gold I", 190000 }, 
	{ "Gold Epic Master", 211000 }, 
	{ "Legendary KiLLeR", 233000 }, 
	{ "Diamond III", 256000 }, 
	{ "Diamond II", 280000 }, 
	{ "Diamond I", 305000 }, 
	{ "Diamond Rare Killer", 331000 }, 
	{ "Master III", 358000 }, 
	{ "Master II", 386000 }, 
	{ "Master I", 415000 }, 
	{ "EpiC Master", 445000 }, 
	{ "Terminator", 476000 }, 
	{ "KinG III", 508000 }, 
	{ "KinG II", 541000 }, 
	{ "KinG I", 575000 }, 
	{ "KinG Of Builders", 610000 }, 
	{ "KinG Of Server", 646000 }, 
	{ "Commander III", 683000 }, 
	{ "Commander II", 721000 }, 
	{ "Commander I", 760000 }, 
	{ "Pro Commander", 800000 }, 
	{ "Like a Boss", 842000 }, 
	{ "Respect", 886000 }, 
	{ "Advanced", 974000 }, 
	{ "Cs-Max Master", 1020000 }, 
	{ "Cs-Max Officer", 1068000 }, 
	{ "Top", 1118000 }, 
	{ "Top Gamer", 1170000 }, 
	{ "Pro Rank", 1224000 }, 
	{ "Predator", 1280000 }, 
	{ "Ace", 1338000 }, 
	{ "Conquer", 1398000 }, 
	{ "Global III", 1460000 }, 
	{ "Global II", 1524000 }, 
	{ "Global I", 1590000 }, 
	{ "Global Builder", 1658000 }, 
	{ "ProfessorX", 1728000 }, 
	{ "Doctor Strange", 1800000 }, 
	{ "Daredevil", 1874000 }, 
	{ "Unstoppable", 1950000 }
};

new const g_iCommandSettings[][eCommandSettings] = 
{
	/*
	* Dont touch this, Commands, Cmd Flags
	*/
	{ 1, "xplist", ADMIN_ALL}, 
	{ 2, "resetdata", ADMIN_RCON }, 
	{ 3, "manage", ADMIN_RCON }
}

new const PrefixChat[] = { "XP System" };
new const g_szLevelUp[] = { "vox/doop.wav" };

// Integers	
new g_iPlayerXP[33], g_iPlayerLevel[33], szPlayerAuthid[33][33], szPlayerName[33][33], szPlayerIP[33][33], g_iPlayerMenu[33]

// Cvars
new cvar_savetype, cvar_xp_kill, cvar_xp_kill_specials, cvar_xp_infect;
new g_fUserLevelUp, g_SaveType
new Array:g_ItemLevel, Array:g_ZombieClassLevel, Array:g_HumanClassLevel, Array:g_WpnPrimaryLevel, Array:g_WpnSecondaryLevel

public plugin_init() {
	// Register Plugin
	register_plugin("[ZPSp] Addon: XP System", "1.0", "Supremache | Perf. Scrash");

	// Register Events
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)

	// Save Data Type: (1 - Authid | 2 = Name | 3 = IP)
	cvar_savetype = register_cvar("zp_xp_save_type", "1")
	
	// Register XP Kill
	cvar_xp_kill = register_cvar("zp_xp_for_kill", "20");
	cvar_xp_kill_specials = register_cvar("zp_xp_for_kill_specials", "30");
	cvar_xp_infect = register_cvar("zp_xp_infect", "20");

	// Register Client Commands
	register_clcmd("say", "CommandSay")
	register_concmd("amx_setlvl", "SetLevels", ADMIN_LEVEL_E, " <player> <quantity>");
	register_concmd("amx_givexp", "GiveEXP", ADMIN_LEVEL_E, " <player> <quantity>");
		
	// Forward
	g_fUserLevelUp = CreateMultiForward("zp_user_level_change", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
}

public plugin_cfg() {
	static cfgdir[32]; get_configsdir(cfgdir, charsmax(cfgdir)) // Get configs dir
	server_cmd("exec %s/%s", cfgdir, ZPSP_XP_CFG_FILE) // Execute .cfg config file
	g_SaveType = get_pcvar_num(cvar_savetype)

	// Load level Itens
	load_level_itens();
}

public load_level_itens() {
	// Create Arrays
	g_ItemLevel = ArrayCreate(1, 1)
	g_ZombieClassLevel = ArrayCreate(1, 1)
	g_HumanClassLevel = ArrayCreate(1, 1)
	g_WpnPrimaryLevel = ArrayCreate(1, 1)
	g_WpnSecondaryLevel = ArrayCreate(1, 1)

	static index, count, real_name[32], level

	// Zombie Class Level
	count = zp_get_zclass_count()
	for (index = 0; index < count; index++) {
		zp_get_zombie_class_realname(index, real_name, charsmax(real_name))
		
		level = 0
		if(!amx_load_setting_int(ZP_ZOMBIECLASSES_FILE, real_name, "LEVEL", level))
			amx_save_setting_int(ZP_ZOMBIECLASSES_FILE, real_name, "LEVEL", level)

		ArrayPushCell(g_ZombieClassLevel, level)
	}

	// Human Class Level
	count = zp_get_hclass_count()
	for (index = 0; index < count; index++) {
		zp_get_human_class_realname(index, real_name, charsmax(real_name))
		
		level = 0
		if(!amx_load_setting_int(ZP_HUMANCLASSES_FILE, real_name, "LEVEL", level))
			amx_save_setting_int(ZP_HUMANCLASSES_FILE, real_name, "LEVEL", level)

		ArrayPushCell(g_HumanClassLevel, level)
	}

	// Extra Item (Include Main Plugin Extra Itens)
	count = zp_get_extra_item_count()
	for (index = 0; index < count; index++) {
		zp_get_extra_item_realname(index, real_name, charsmax(real_name))
		
		level = 0		
		if (!amx_load_setting_int(ZP_EXTRAITEMS_FILE, real_name, "LEVEL", level))
			amx_save_setting_int(ZP_EXTRAITEMS_FILE, real_name, "LEVEL", level)
		
		ArrayPushCell(g_ItemLevel, level)
	}
	
	// Player Primary Weapons (Include Main Plugin Player Weapons)
	static start
	count = zp_weapon_count(WPN_PRIMARY, 0)
	start = zp_weapon_count(WPN_PRIMARY, 2)
	for (index = 0; index < count; index++) {
		zp_get_weapon_realname(WPN_PRIMARY, index, real_name, charsmax(real_name))
		
		if(index >= start)
			format(real_name, charsmax(real_name), "Pri:%s", real_name)

		level = 0
		if (!amx_load_setting_int(ZP_WEAPONS_FILE, real_name, "LEVEL", level))
			amx_save_setting_int(ZP_WEAPONS_FILE, real_name, "LEVEL", level)
		
		ArrayPushCell(g_WpnPrimaryLevel, level)
	}
	
	// Player Secondary Weapons (Include Main Plugin Player Weapons)
	count = zp_weapon_count(WPN_SECONDARY, 0)
	start = zp_weapon_count(WPN_SECONDARY, 2)
	for (index = 0; index < count; index++) {
		zp_get_weapon_realname(WPN_SECONDARY, index, real_name, charsmax(real_name))

		if(index >= start)
			format(real_name, charsmax(real_name), "Sec:%s", real_name)
		
		level = 0		
		if (!amx_load_setting_int(ZP_WEAPONS_FILE, real_name, "LEVEL", level))
			amx_save_setting_int(ZP_WEAPONS_FILE, real_name, "LEVEL", level)
		
		ArrayPushCell(g_WpnSecondaryLevel, level)
	}
}

public client_authorized(id) {
	get_user_name(id, szPlayerName[id], charsmax(szPlayerName[]));
	get_user_authid(id, szPlayerAuthid[id], charsmax(szPlayerAuthid[]));
	get_user_ip(id, szPlayerIP[id], charsmax(szPlayerIP[]), 1)

	if(!is_user_hltv(id) && !is_user_bot(id))
		LoadData(id);
}

public client_disconnected(id) {
	if(!is_user_hltv(id) && !is_user_bot(id))
		SaveData(id);
}

public plugin_precache() {
	precache_sound(g_szLevelUp)
}

public client_infochanged(id) {
	if(!is_user_connected(id)) 
		return PLUGIN_CONTINUE;

	get_user_info(id, "name", szPlayerName[id], charsmax(szPlayerName[]));
	
	return PLUGIN_CONTINUE;
}

/*--------------------------------*
* Class/Item/Weapon Level *
*--------------------------------*/
public zp_zombie_class_choosed_pre(id, classid) { // Zombie Class Level
	return check_class_item_level(id, classid, g_ZombieClassLevel);
}
public zp_human_class_choosed_pre(id, classid) { // Human Class Level
	return check_class_item_level(id, classid, g_HumanClassLevel);
}
public zp_extra_item_selected_pre(id, itemid) { // Extra Item Level
	return check_class_item_level(id, itemid, g_ItemLevel);
}
public zp_weapon_selected_pre(id, wpn_type, wpn_id) { // Player Weapon Level
	return check_class_item_level(id, wpn_id, (wpn_type == WPN_PRIMARY) ? g_WpnPrimaryLevel : g_WpnSecondaryLevel);
}
// Check Class/Item/Weapon Level
stock check_class_item_level(id, itemid, Array:Arr_Level) {
	// Prevent log error
	if(itemid < 0 || itemid >= ArraySize(Arr_Level))
		return PLUGIN_CONTINUE;
	
	static level
	level = ArrayGetCell(Arr_Level, itemid)
	if(g_iPlayerLevel[id] < level) {
		zp_menu_textadd(fmt("\r[Level %d]", level))
		return ZP_PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

/*---------------*
* Hud *
*----------------*/
public zp_player_show_hud(id, target, SpHudType:hudtype) {	
	static xpnext
	if(target) {
		if(g_iPlayerLevel[target] >= MAXLEVEL)
			xpnext = g_mPlayerData[g_iPlayerLevel[target]][m_iRankXP] 
		else 
			xpnext = g_mPlayerData[g_iPlayerLevel[target]+1][m_iRankXP] 

		zp_add_hud_text(fmt("^nRank: %s - XP: %i / %i - Level: %i / %i", g_mPlayerData[g_iPlayerLevel[target]][m_szRankName], g_iPlayerXP[target], xpnext, g_iPlayerLevel[target], MAXLEVEL))
		return;
	}

	if(g_iPlayerLevel[id] >= MAXLEVEL)
		xpnext = g_mPlayerData[g_iPlayerLevel[id]][m_iRankXP] 
	else 
		xpnext = g_mPlayerData[g_iPlayerLevel[id]+1][m_iRankXP] 

	if(hudtype == HUD_DEFAULT || hudtype == HUD_CENTER || hudtype == HUD_UNDER_RADAR)
		zp_add_hud_text(fmt("^n[Rank: %s]^n[XP: %i / %i]^n[Level: %i / %i]", g_mPlayerData[g_iPlayerLevel[id]][m_szRankName], g_iPlayerXP[id], xpnext, g_iPlayerLevel[id], MAXLEVEL))
	else if(hudtype == HUD_ANTRAX_STYLE || hudtype == HUD_CENTER_ANTRAX)
		zp_add_hud_text(fmt("^n[XP] [%i / %i] - [Level] [%i / %i]^n[Rank] [%s]", g_iPlayerXP[id], xpnext, g_iPlayerLevel[id], MAXLEVEL, g_mPlayerData[g_iPlayerLevel[id]][m_szRankName]))
	else if(hudtype == HUD_CLASSIC)
		zp_add_hud_text(fmt("- Rank: %s - XP: %i/%i - Level: %i/%i", g_mPlayerData[g_iPlayerLevel[id]][m_szRankName], g_iPlayerXP[id], xpnext, g_iPlayerLevel[id], MAXLEVEL))
}

/*---------------*
* Custom Menu *
*----------------*/
public CommandSay(id) {
	new szArgs[192]
	
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	trim(szArgs)

	new szCmd[35]
	parse(szArgs, szCmd, charsmax(szCmd))
	trim(szCmd)
	
	if(szCmd[0] != '/')
		return PLUGIN_CONTINUE
	
	new iMenu = -1
	
	for(new i = 0; i <= charsmax(g_iCommandSettings); i++) {
		if(equali(szCmd[1], g_iCommandSettings[i][iCommands])) 
			continue;

		iMenu = g_iCommandSettings[i][iMenuType]
		
		if(iMenu == -1)
			return PLUGIN_CONTINUE
		
		g_iPlayerMenu[id] = iMenu
		PlayerRank(id, g_iCommandSettings[i][iFlags])
		break;
		
	}

	return PLUGIN_HANDLED
}

public PlayerRank(id, iFlag) {
	if(!access(id, iFlag)) {
		client_print_color(id, print_team_default, "^4[%s]^1 You dont have access.", PrefixChat);
		return PLUGIN_HANDLED
	}
			
	new iPlayers[32], iPnum, szUserID[32], szTitle[128], iMenu 
	
	switch (g_iPlayerMenu[id]) {
		case 2: 
			formatex(szTitle, charsmax(szTitle), "\y%s: \rReset Data", PrefixChat)
		case 3: 
			formatex(szTitle, charsmax(szTitle), "\y%s: \rManage Players", PrefixChat)
		default: 
			formatex(szTitle, charsmax(szTitle), "\y%s: \rXP List", PrefixChat)
	}
	
	iMenu = menu_create(szTitle, "Handler")
	get_players(iPlayers, iPnum, "ch"); SortCustom1D(iPlayers, iPnum, "sort_players_by_xp")
	
	for(new szItem[1024], iPlayer, i; i < iPnum; i++) {
		iPlayer = iPlayers[i]
		formatex(szItem, charsmax(szItem), "\d[%i XP] \w%s \r[\yLevel %i: %s\r]", g_iPlayerXP[iPlayer], szPlayerName[iPlayer], g_iPlayerLevel[iPlayer], g_mPlayerData[g_iPlayerLevel[iPlayer]][m_szRankName]);
		formatex(szUserID, charsmax(szUserID), "%d", get_user_userid(iPlayer))
		menu_additem(iMenu, szItem, szUserID)
	}
	
	menu_setprop(iMenu, MPROP_BACKNAME, "Previous page")
	menu_setprop(iMenu, MPROP_NEXTNAME, "Next page")
	menu_setprop(iMenu, MPROP_EXITNAME, "\rClose")

	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public sort_players_by_xp(id1, id2) {
	return g_iPlayerXP[id2] - g_iPlayerXP[id1]
}

public Handler(id, iMenu, iItem) {
	if(iItem != MENU_EXIT) {
		new iAccess, iCallback, iData[6], iName[64];
		menu_item_getinfo(iMenu, iItem, iAccess, iData, charsmax(iData), iName, charsmax(iName), iCallback);
	
		new iPlayer = str_to_num(iData);
		
		switch (g_iPlayerMenu[id]) {
			case 2: 
				ResetPlayerRank(id, iPlayer);
			case 3: 
				ManagePlayerRank(id, iPlayer);
		}
	}
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

public ResetPlayerRank(id, iPlayer) {
	if(!iPlayer)
		return PLUGIN_HANDLED;
	
	g_iPlayerXP[iPlayer] = 0
	g_iPlayerLevel[iPlayer] = 0
	
	console_print(id, "[ADMIN] %s: reset rank data of %s", szPlayerName[id], szPlayerName[iPlayer]);
	Log("[ADMIN] %s <%s> reset rank data of %s <%s>", szPlayerName[id], szPlayerAuthid[id], szPlayerName[iPlayer], szPlayerAuthid[iPlayer]);
		
	client_print_color(0, print_team_default, "^1[ADMIN]^4 %s^1: reset rank data of^4 %s^1", szPlayerName[id], szPlayerName[iPlayer]);
	
	SaveData(iPlayer);
	return PLUGIN_CONTINUE;
}

public ManagePlayerRank(id, iPlayer) {
	new szTitle[128], szUserID[32], iMenu;
	formatex(szTitle, charsmax(szTitle), "\yRank System: \rManage Players")
	
	iMenu = menu_create(szTitle, "Rank_Handler");
	
	for(new i = 0; i <= charsmax(g_mPlayerData); i++) {
		formatex(szUserID, charsmax(szUserID), "%d", get_user_userid(iPlayer))
		menu_additem(iMenu, g_mPlayerData[i][m_szRankName], szUserID);
	}	
	menu_display(id, iMenu);
}

public Rank_Handler(id, iMenu, iItem) {
	if(iItem != MENU_EXIT) {
		new iAccess, iCallback, iData[6], iName[64];
		menu_item_getinfo(iMenu, iItem, iAccess, iData, charsmax(iData), iName, charsmax(iName), iCallback);
	
		new iPlayer = str_to_num(iData);
	
		g_iPlayerXP[iPlayer] = g_mPlayerData[iItem][m_iRankXP];
		g_iPlayerLevel[iPlayer] = iItem;
	
		Log("[ADMIN] %s <%s> changed %s <%s> rank to %s", szPlayerName[id], szPlayerAuthid[id], szPlayerName[iPlayer], szPlayerAuthid[iPlayer], g_mPlayerData[g_iPlayerLevel[iPlayer]][m_szRankName]);
		client_print_color(iPlayer, print_team_default, "^1[ADMIN]^4 %s^1: changed^4 %s^1 rank to^4 %s^1 (^4Lv. %d^1)", 
		szPlayerName[id], 
		szPlayerName[iPlayer], 
		g_mPlayerData[g_iPlayerLevel[iPlayer]][m_szRankName], 
		g_iPlayerLevel[iPlayer]);
	}
	menu_destroy(iMenu)
}	

/*---------------*
* Give XP *
*----------------*/
public GiveEXP(id, nLevel, nCid) {
	if(!cmd_access(id, nLevel, nCid, 1)) 
		return PLUGIN_HANDLED
	
	static cTarget[32], cXP[6], iTarget, iXP
	
	read_argv(1, cTarget, charsmax(cTarget));
	read_argv(2, cXP, charsmax(cXP));
	
	iXP = str_to_num(cXP);
	
	iTarget = cmd_target(id, cTarget, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);

	if(!cTarget[0] || !cXP[0]) {
		console_print(id, "Usage: amx_givexp <player name> <quantity>");
		return PLUGIN_HANDLED
	}
	
	if(!iTarget) {
		console_print(id, "[%s] Invalid player or matching multiple targets!", PrefixChat);
		return PLUGIN_HANDLED
	}
	
	if(g_iPlayerLevel[iTarget] >= MAXLEVEL) {
		console_print(id, "[%s] You can't give this player more xp, because he reached max level %d.", PrefixChat, MAXLEVEL);
		client_print_color(id, print_team_default, "^4[%s]^1 You can't give this player more xp, because he reached max level (^4%d^1).", PrefixChat, MAXLEVEL);
		return PLUGIN_HANDLED
	}
	
	g_iPlayerXP[iTarget] += iXP
	CheckLevel(iTarget)
		
	console_print(id, "[ADMIN] %s gave %d xp to %s", szPlayerName[id], iXP, szPlayerName[iTarget]);
	Log("[ADMIN] %s <%s> gave %d xp for %s <%s>", szPlayerName[id], szPlayerAuthid[id], iXP, szPlayerName[iTarget], szPlayerAuthid[iTarget]);
	
	client_print_color(0, print_team_default, "^1[ADMIN]^4 %s^1: gave^4 %d^1 exp for^4 %s^1", szPlayerName[id], iXP, szPlayerName[iTarget]);
	client_print_color(iTarget, print_team_default, "^4[%s]^1 You have reached: XP.^4%d^1/^4%d^1. ", PrefixChat, g_iPlayerXP[iTarget], g_mPlayerData[g_iPlayerLevel[iTarget]+ 1][m_iRankXP]);
		
	return PLUGIN_HANDLED
}

/*---------------*
* Give Levels *
*----------------*/
public SetLevels(id, nLevel, nCid) {
	if(!cmd_access(id, nLevel, nCid, 1))
		return PLUGIN_HANDLED
	
	static cTarget[32], cLevel[6], iTarget, iLevel
	
	read_argv(1, cTarget, charsmax(cTarget));
	read_argv(2, cLevel, charsmax(cLevel));
	
	iLevel = str_to_num(cLevel);
	
	iTarget = cmd_target(id, cTarget, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);

	if(!cTarget[0] || !cLevel[0]) {
		console_print(id, "Usage: amx_givelvl <player Name> <quantity>");
		return PLUGIN_HANDLED
	}
	
	if(!iTarget) 
	{
		console_print(id, "[%s] Invalid player or matching multiple targets!", PrefixChat);
		return PLUGIN_HANDLED
	}
	
	if(iLevel > MAXLEVEL)
		iLevel = MAXLEVEL

	if(iLevel < 0)
		iLevel = 0
	
	g_iPlayerLevel[iTarget] = iLevel
	g_iPlayerXP[iTarget] = g_mPlayerData[g_iPlayerLevel[iTarget]][m_iRankXP] 
	client_cmd(iTarget, "spk %s", g_szLevelUp)
	SaveData(iTarget)
	
	console_print(id, "[ADMIN] %s set %d level to %s", szPlayerName[id], iLevel, szPlayerName[iTarget]);
	Log("[ADMIN] %s <%s> set %d levels for %s <%s>", szPlayerName[id], szPlayerAuthid[id], iLevel, szPlayerName[iTarget], szPlayerAuthid[iTarget]);
	
	client_print_color(0, print_team_default, "^1[ADMIN]^4 %s^1: set^4 %d^1 levels for^4 %s^1", szPlayerName[id], iLevel, szPlayerName[iTarget]);
	client_print_color(iTarget, print_team_default, "^4[%s]^1 You have reached: Rank.^4%s^1, Lv.^4%d^1.", PrefixChat, g_mPlayerData[g_iPlayerLevel[iTarget]][m_szRankName], g_iPlayerLevel[iTarget]);
		
	return PLUGIN_HANDLED
		
}

/*---------------*
* Kill XP Amount *
*----------------*/
public fw_PlayerKilled_Post(victim, attacker) {
	static XPAmount
	if(attacker == victim || !is_user_connected(attacker) || !is_user_connected(victim))
		return HAM_IGNORED;
	
	if(zp_get_human_special_class(victim) || zp_get_zombie_special_class(victim))
		XPAmount = get_pcvar_num(cvar_xp_kill_specials);
	else
		XPAmount = get_pcvar_num(cvar_xp_kill);
	
	g_iPlayerXP[attacker] += XPAmount;
	CheckLevel(attacker);
	return HAM_IGNORED;
}
public zp_user_infected_post(victim, infector) {
	if(infector == victim || !is_user_connected(infector) || !is_user_connected(victim))
		return;

	g_iPlayerXP[infector] += get_pcvar_num(cvar_xp_infect);
	CheckLevel(infector);
}

public zp_user_humanized_post(victim, classid, attacker) {
	if(attacker == victim || !is_user_connected(attacker) || !is_user_connected(victim))
		return;

	g_iPlayerXP[attacker] += get_pcvar_num(cvar_xp_infect);
	CheckLevel(attacker);
}

/*---------------*
* Check Levels *
*----------------*/
public CheckLevel(iPlayer) {
	if(g_iPlayerLevel[iPlayer] >= MAXLEVEL) {
		SaveData(iPlayer)
		return;
	}
	
	while(g_iPlayerXP[iPlayer] >= g_mPlayerData[g_iPlayerLevel[iPlayer]+1][m_iRankXP]) {
		g_iPlayerLevel[iPlayer]++;
		client_cmd(iPlayer, "spk %s", g_szLevelUp)
		new iReturn
		ExecuteForward(g_fUserLevelUp, iReturn, iPlayer, g_iPlayerLevel[iPlayer], g_iPlayerXP[iPlayer])
		client_print_color(0, print_team_default, "^4[%s]^1 Player^4 %s^1 have been promoted to^4 %s^1 (^4Lv. %d^1)", 
		PrefixChat, 
		szPlayerName[iPlayer], 
		g_mPlayerData[g_iPlayerLevel[iPlayer]][m_szRankName], 
		g_iPlayerLevel[iPlayer]);
	}
	SaveData(iPlayer)
}
			
/*---------------*
* SAVE/LOAD Data *
*----------------*/
stock SaveData(id) {
	new szKey[64], szData[256];

	switch(g_SaveType) {
		case 2: 
			formatex(szKey, charsmax(szKey), "%s-NAME", szPlayerName[id])
		case 3: 
			formatex(szKey, charsmax(szKey), "%s-IP", szPlayerIP[id])
		default: 
			formatex(szKey, charsmax(szKey), "%s-ID", szPlayerAuthid[id])
	}
	
	formatex(szData, charsmax(szData), "%i#%i#", g_iPlayerLevel[id], g_iPlayerXP[id])
	fvault_set_data(VAULT_NAME, szKey, szData)
}

stock LoadData(id) {
	new szKey[64], szData[256], szXP[32], szLevel[32];
	
	switch(g_SaveType) {
		case 2: 
			formatex(szKey, charsmax(szKey), "%s-NAME", szPlayerName[id]);
		case 3: 
			formatex(szKey, charsmax(szKey), "%s-IP", szPlayerIP[id]);
		default: 
			formatex(szKey, charsmax(szKey), "%s-ID", szPlayerAuthid[id]);
	}
	
	formatex(szData, charsmax(szData), "%i#%i#", g_iPlayerLevel[id], g_iPlayerXP[id])
	fvault_get_data(VAULT_NAME, szKey, szData, charsmax(szData))
		
	replace_string(szData, charsmax(szData), "#", " ")
	parse(szData, szLevel, charsmax(szLevel), szXP, charsmax(szXP))
	g_iPlayerLevel[id] = str_to_num(szLevel)
	g_iPlayerXP[id] = str_to_num(szXP)
}

/*--------------*
* STOCKS *
*---------------*/
stock Log(const message_fmt[], any:...) {
	static message[256];
	vformat(message, charsmax(message), message_fmt, 2);
	
	static filename[96], log_file[64];
	static dir[64];
	if(!dir[0]) {
		get_basedir(dir, charsmax(dir));
		add(dir, charsmax(dir), "/logs");
	}
	
	format_time(filename, charsmax(filename), "%m-%d-%Y");
	formatex(log_file, charsmax(log_file), "%s/zpsp_xp_system_%s.log", dir, filename); /* Much faster than what format() can do */
	log_to_file(log_file, "%s", message);
}

/*--------------*
* NATIVES *
*---------------*/
public plugin_natives() {
	register_native("zp_get_user_xp", "_get_user_xp")
	register_native("zp_set_user_xp", "_set_user_xp")
	register_native("zp_get_user_max_xp", "_get_user_max_xp")
	register_native("zp_get_max_levels", "_get_max_levels")
	register_native("zp_get_user_level", "_get_user_level")
	register_native("zp_set_user_level", "_set_user_level")
	register_native("zp_get_user_rank", "_get_user_rank")
	register_native("zp_get_user_next_rank", "_get_user_next_rank")
}

// Native: zp_get_user_xp
public _get_user_xp(iPlugin, iParams)
	return g_iPlayerXP[get_param(1)];

// Native: zp_set_user_xp
public _set_user_xp(iPlugin, iParams) {
	g_iPlayerXP[get_param(1)] = get_param(2);
	SaveData(get_param(1));
	CheckLevel(get_param(1));
}

// Native: zp_get_user_level
public _get_user_level(iPlugin, iParams)
	return g_iPlayerLevel[get_param(1)];

// Native: zp_set_user_level
public _set_user_level(iPlugin, iParams) {
	g_iPlayerLevel[get_param(1)] = get_param(2);
	
	SaveData(get_param(1));
	CheckLevel(get_param(1));
}

// Native: zp_get_user_max_xp
public _get_user_max_xp(iPlugin, iParams) {
	new iMaxLevel
	
	if(g_iPlayerLevel[get_param(1)] >= MAXLEVEL) 
		iMaxLevel = MAXLEVEL
	else
		iMaxLevel = g_mPlayerData[g_iPlayerLevel[get_param(1)] + 1][m_iRankXP]
	
	return iMaxLevel;
}

public _get_user_rank(iPlugin, iParams)
	set_string(2, g_mPlayerData[g_iPlayerLevel[get_param(1)]][m_szRankName], get_param(3));

public _get_user_next_rank(iPlugin, iParams)
	set_string(2, g_mPlayerData[g_iPlayerLevel[get_param(1)] +1][m_szRankName], get_param(3));

public _get_max_levels(iPlugin, iParams)
	return MAXLEVEL;