#if defined _zpsp_xp_system_included
	#endinput
#endif
#define _zpsp_xp_system_included

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
 * Called when the client's level changes.
 *
 * @param id	 		Client index.
 * @param level 		New level.
 * @param levelup		True if the client gained a level or  xp, false if he lost one.
 * @noreturn
 */
forward zp_user_level_change(id, level, xp)


	