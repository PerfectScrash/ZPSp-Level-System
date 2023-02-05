/*============================================
		[ZPSp] XP Upgrade: Armor

		* Description:
			- Give User Armor Protection

		* Changelog:
			- 1.0: First Release

=============================================*/

#include <amxmodx>
#include <fun>
#include <zombie_plague_special>
#include <zpsp_xp_system>
#include <amx_settings_api>

new const up_name[] = "UPGRADE_ARMOR_NAME"
new const up_description[] = "UPGRADE_ARMOR_DESC"
const up_max_level = 5
new const up_prices[up_max_level] = { 100, 200, 300, 400, 500 }
new const up_sell_values[up_max_level] = { 50, 100, 150, 200, 250 }
new const up_vault_name[] = "zpsp_upgrade_armor"

new const Give_Armor_Amt[up_max_level] = { 
	10,	// Level 1
	20,	// Level 2
	30,	// Level 3
	40,	// Level 4
	50	// Level 5
}

new g_UpgradeId, cvar_vip_armor, cvar_free_armor, class_count, Array:g_HumanClassArmor
public plugin_init() {
	register_plugin("[ZPSp] XP Upgrade: Armor", "1.0", "Perf. Scrash")
	register_dictionary("zpsp_xp_upgrades.txt")

	// ZP Special Vip System support
	cvar_vip_armor = get_cvar_pointer("zp_vip_armor")
	cvar_free_armor = get_cvar_pointer("zp_user_free_armor")

	class_count = zp_get_hclass_count()
	if(class_count > 0) {
		g_HumanClassArmor = ArrayCreate(1, 1)
		static real_name[32], index, armor
		for (index = 0; index < class_count; index++) {
			zp_get_human_class_realname(index, real_name, charsmax(real_name))
			
			armor = 0
			if(amx_load_setting_int(ZP_HUMANCLASSES_FILE, real_name, "ARMOR", armor))
				ArrayPushCell(g_HumanClassArmor, armor)
			else 	
				ArrayPushCell(g_HumanClassArmor, 0)
		}
	}

	g_UpgradeId = zp_register_upgrade(up_name, up_description, up_prices, up_sell_values, up_max_level, up_vault_name, 1);
}

public zp_player_spawn_post(id) {
	remove_task(id)
	set_task(0.8, "give_armor", id);
}
public zp_user_humanized_post(id) {
	remove_task(id)
	set_task(0.8, "give_armor", id);
}

public give_armor(id) {
	if(!is_user_alive(id))
		return;

	if(zp_get_user_zombie(id) || zp_get_human_special_class(id))
		return;

	static armor_give, level, cur_class
	level = zp_get_user_upgrade_lvl(id, g_UpgradeId)
	if(!level)
		return;

	armor_give = Give_Armor_Amt[level-1]

	// ZP Special Vip System support
	if(cvar_vip_armor && (get_user_flags(id) & ADMIN_RESERVATION))
		armor_give += get_pcvar_num(cvar_vip_armor)
	else if(cvar_free_armor)
		armor_give += get_pcvar_num(cvar_free_armor)

	// Human Classes support
	if(class_count > 0) {
		cur_class = zp_get_user_human_class(id)
		if(cur_class != -1)
			armor_give += ArrayGetCell(g_HumanClassArmor, cur_class)
	}

	if(get_user_armor(id) < armor_give)
		set_user_armor(id, armor_give)
}


public zp_upgrade_menu_open(id, Up_id) {
	static level
	if(Up_id == g_UpgradeId) {
		level = zp_get_user_upgrade_lvl(id, Up_id)
		if(level)
			zp_upgrade_menu_add_note(fmt("%L", id, "UPGRADE_ARMOR_NOTE", Give_Armor_Amt[level-1]))
	}	
}
