#include <amxmodx>
#include <fun>
#include <zombie_plague_special>
#include <zpsp_xp_system>

new const up_name[] = "UPGRADE_HEALTH_NAME"
new const up_description[] = "UPGRADE_HEALTH_DESC"
const up_max_level = 5
new const up_prices[up_max_level] = { 100, 200, 300, 400, 500 }
new const up_sell_values[up_max_level] = { 50, 100, 150, 200, 250 }
new const up_vault_name[] = "zpsp_upgrade_health"

new const Float:Health_Multi[up_max_level] = { 
	1.1, // Level 1
	1.2, // Level 2
	1.3, // Level 3
	1.4, // Level 4
	1.5  // Level 5
}

new g_UpgradeId
public plugin_init() {
	register_plugin("[ZPSp] XP Upgrade: Health", "1.0", "Perf. Scrash")
	register_dictionary("zpsp_xp_upgrades.txt")

	g_UpgradeId = zp_register_upgrade(up_name, up_description, up_prices, up_sell_values, up_max_level, up_vault_name, 1);
}

public zp_player_spawn_post(id) {
	set_task(0.2, "set_hp", id)
}
public set_hp(id) {
	static level, Float:MaxHP
	level = zp_get_user_upgrade_lvl(id, g_UpgradeId)
	if(level <= 0)
		return;

	MaxHP = zp_get_user_maxhealth(id) * Health_Multi[level-1]
	set_user_health(id, floatround(MaxHP))
}