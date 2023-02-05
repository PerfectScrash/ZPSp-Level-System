#if defined _zpsp_xp_system_included
	#endinput
#endif
#define _zpsp_xp_system_included

#define ZPSP_XP_INC_VERSION 2

/**
 * Returns a users Experience.
 *
 * @param id		Player index.
 * @return		Returns current Experience
 */
native zp_get_user_xp(id);

/**
 * Sets a users Experience to the desired amount.
 *
 * @param id		Player index.
 * @param Experience	Credit amount.
 * @return		Returns current Experience
 */
native zp_set_user_xp(id, amount);

/**
 * Returns a users Level.
 *
 * @param id		Player index.
 * @return		Returns current Level
 */
native zp_get_user_level(id);

/**
 * Sets a users Level to the desired amount.
 *
 * @param id		Player index.
 * @param level 	Credit amount.
 * @return		Returns current Level
 */
native zp_set_user_level(id, amount);

/**
 * Returns a users Level by Experience.
 *
 * @param id		Player index.
 * @return		Returns current Level by Experience
 */
native zp_get_user_max_xp(id);

/**
 * Returns the client's current rank.
 *
 * @param id		 	Client index.
 * @param buffer	 	Buffer to store the rank name in.
 * @param len 			Maximum buffer length.
 * @noreturn
 */
native zp_get_user_rank(id, buffer[], maxchars);

/**
 * Returns the client's current rank.
 *
 * @param id		 	Client index.
 * @param buffer	 	Buffer to store the next rank name in.
 * @param len 			Maximum buffer length.
 * @noreturn
 */
native zp_get_user_next_rank(id, buffer[], maxchars);

/**
 * Returns the number of available levels.
 *
 * @return				Number of available levels.
 */
native zp_get_max_levels();

/**
 * Registers a upgrade which will be added to the upgrades menu of XP System.
 *

 *
 * @param name				Upgrade Name
 * @param description		Upgrade Description
 * @param price				(Vector) Upgrade Price
 * @param sell_value		(Vector) Upgrade Sell Value
 * @param MaxLevel			Upgrade Max Level
 * @param vaultname 		Save Vault File Name
 * @param UseLang 			Use lang in Upgrade Name/Description?
 * @return 					An internal Upgrade Index, or -1 on failure.
 */
native zp_register_upgrade(const name[], const description[], const price[], const sell_value[], MaxLevel, const vaultname[], UseLang = 0);

/**
 * Returns the user upgrade current level.
 *
 *
 * @param index				Player Index
 * @param upgrade_index		Upgrade Index
 * @return 					Current User Upgrade Level
 */
native zp_get_user_upgrade_lvl(index, upgrade_index);

/**
 * Set user Current Upgrade Level
 *
 *
 * @param index				Player Index
 * @param upgrade_index		Upgrade Index
 * @param level				User Upgrade New Level
 * @return 					1 - if sucess, 0 - otherwise
 */
native zp_set_user_upgrade_lvl(index, upgrade_index, level);

/**
 * Returns the upgrade max level.
 *
 *
 * @param upgrade_index		Upgrade Index
 * @return 					Current Upgrade Max Level
 */
native zp_get_upgrade_max_lvl(upgrade_index);

/**
 * Add Text On Upgrades menu
 *
 * @param text		Text to display on the upgrade name.
 * @return			True if sucess, false if not sucess.
 */
native zp_upgrade_add_text(const text[]);

/**
 * Add Note On Upgrades menu
 *
 * @param note		Text to display on the upgrade item X menu.
 * @return			True if sucess, false if not sucess.
 */
native zp_upgrade_menu_add_note(const note[]);

/**
 * Called when the client's level changes.
 *
 * @param id	 		Client index.
 * @param level 		New level.
 * @param levelup		True if the client gained a level or  xp, false if he lost one.
 * @noreturn
 */
forward zp_user_level_change(id, level, xp);

/**
 * Called before the client buy upgrade.
 * @note Use the ZP_PLUGIN_HANDLED for block option
 * @note Use 'zp_upgrade_add_text' for add a small text in a upgrade menu
 *
 * @param id	 			Client index.
 * @param upgrade_index 	Upgrade Index.
 * @noreturn
 */
forward zp_upgrade_buy_pre(id, upgrade_index);

/**
 * Called after the client buy upgrade.
 *
 * @param id	 			Client index.
 * @param upgrade_index 	Upgrade Index.
 * @noreturn
 */
forward zp_upgrade_buy_post(id, upgrade_index);

/**
 * Called before the client sell upgrade.
 * @note Use the ZP_PLUGIN_HANDLED for block option
 * @note Use 'zp_upgrade_add_text' for add a small text in a upgrade menu
 *
 * @param id	 			Client index.
 * @param upgrade_index 	Upgrade Index.
 * @noreturn
 */
forward zp_upgrade_sell_pre(id, upgrade_index);

/**
 * Called after the client sell upgrade.
 *
 * @param id	 			Client index.
 * @param upgrade_index 	Upgrade Index.
 * @noreturn
 */
forward zp_upgrade_sell_post(id, upgrade_index);

/**
 * Called when user open a upgrade item X menu.
 * @note Use the ZP_PLUGIN_HANDLED for block option
 * @note Use 'zp_upgrade_menu_add_note' for add a big description in a upgrade menu
 *
 * @param id	 			Client index.
 * @param upgrade_index 	Upgrade Index.
 * @noreturn
 */
forward zp_upgrade_menu_open(id, upgrade_index);
