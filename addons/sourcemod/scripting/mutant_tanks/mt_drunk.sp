/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

#file "Drunk Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Drunk Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank makes survivors drunk.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Drunk Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_DRUNK "Drunk Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flDrunkChance;
	float g_flDrunkRange;
	float g_flDrunkRangeChance;
	float g_flDrunkSpeedInterval;
	float g_flDrunkTurnInterval;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDrunkAbility;
	int g_iDrunkDuration;
	int g_iDrunkEffect;
	int g_iDrunkHit;
	int g_iDrunkHitMode;
	int g_iDrunkMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flDrunkChance;
	float g_flDrunkRange;
	float g_flDrunkRangeChance;
	float g_flDrunkSpeedInterval;
	float g_flDrunkTurnInterval;

	int g_iAccessFlags;
	int g_iDrunkAbility;
	int g_iDrunkDuration;
	int g_iDrunkEffect;
	int g_iDrunkHit;
	int g_iDrunkHitMode;
	int g_iDrunkMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flDrunkChance;
	float g_flDrunkRange;
	float g_flDrunkRangeChance;
	float g_flDrunkSpeedInterval;
	float g_flDrunkTurnInterval;

	int g_iDrunkAbility;
	int g_iDrunkDuration;
	int g_iDrunkEffect;
	int g_iDrunkHit;
	int g_iDrunkHitMode;
	int g_iDrunkMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_drunk", cmdDrunkInfo, "View information about the Drunk ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset3(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdDrunkInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vDrunkMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vDrunkMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iDrunkMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Drunk Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iDrunkMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iDrunkAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "DrunkDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iDrunkDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vDrunkMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "DrunkMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_DRUNK, MT_MENU_DRUNK);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_DRUNK, false))
	{
		vDrunkMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_DRUNK, false))
	{
		FormatEx(buffer, size, "%T", "DrunkMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iDrunkHitMode == 0 || g_esCache[attacker].g_iDrunkHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrunkHit(victim, attacker, g_esCache[attacker].g_flDrunkChance, g_esCache[attacker].g_iDrunkHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iDrunkHitMode == 0 || g_esCache[victim].g_iDrunkHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrunkHit(attacker, victim, g_esCache[victim].g_flDrunkChance, g_esCache[victim].g_iDrunkHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("drunkability");
	list2.PushString("drunk ability");
	list3.PushString("drunk_ability");
	list4.PushString("drunk");
}

public void MT_OnConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iDrunkAbility = 0;
				g_esAbility[iIndex].g_iDrunkEffect = 0;
				g_esAbility[iIndex].g_iDrunkMessage = 0;
				g_esAbility[iIndex].g_flDrunkChance = 33.3;
				g_esAbility[iIndex].g_iDrunkDuration = 5;
				g_esAbility[iIndex].g_iDrunkHit = 0;
				g_esAbility[iIndex].g_iDrunkHitMode = 0;
				g_esAbility[iIndex].g_flDrunkRange = 150.0;
				g_esAbility[iIndex].g_flDrunkRangeChance = 15.0;
				g_esAbility[iIndex].g_flDrunkSpeedInterval = 1.5;
				g_esAbility[iIndex].g_flDrunkTurnInterval = 0.5;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iDrunkAbility = 0;
					g_esPlayer[iPlayer].g_iDrunkEffect = 0;
					g_esPlayer[iPlayer].g_iDrunkMessage = 0;
					g_esPlayer[iPlayer].g_flDrunkChance = 0.0;
					g_esPlayer[iPlayer].g_iDrunkDuration = 0;
					g_esPlayer[iPlayer].g_iDrunkHit = 0;
					g_esPlayer[iPlayer].g_iDrunkHitMode = 0;
					g_esPlayer[iPlayer].g_flDrunkRange = 0.0;
					g_esPlayer[iPlayer].g_flDrunkRangeChance = 0.0;
					g_esPlayer[iPlayer].g_flDrunkSpeedInterval = 0.0;
					g_esPlayer[iPlayer].g_flDrunkTurnInterval = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iDrunkAbility = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iDrunkAbility, value, 0, 1);
		g_esPlayer[admin].g_iDrunkEffect = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iDrunkEffect, value, 0, 7);
		g_esPlayer[admin].g_iDrunkMessage = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iDrunkMessage, value, 0, 3);
		g_esPlayer[admin].g_flDrunkChance = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkChance", "Drunk Chance", "Drunk_Chance", "chance", g_esPlayer[admin].g_flDrunkChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iDrunkDuration = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkDuration", "Drunk Duration", "Drunk_Duration", "duration", g_esPlayer[admin].g_iDrunkDuration, value, 1, 999999);
		g_esPlayer[admin].g_iDrunkHit = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkHit", "Drunk Hit", "Drunk_Hit", "hit", g_esPlayer[admin].g_iDrunkHit, value, 0, 1);
		g_esPlayer[admin].g_iDrunkHitMode = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkHitMode", "Drunk Hit Mode", "Drunk_Hit_Mode", "hitmode", g_esPlayer[admin].g_iDrunkHitMode, value, 0, 2);
		g_esPlayer[admin].g_flDrunkRange = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkRange", "Drunk Range", "Drunk_Range", "range", g_esPlayer[admin].g_flDrunkRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flDrunkRangeChance = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkRangeChance", "Drunk Range Chance", "Drunk_Range_Chance", "rangechance", g_esPlayer[admin].g_flDrunkRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flDrunkSpeedInterval = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkSpeedInterval", "Drunk Speed Interval", "Drunk_Speed_Interval", "speedinterval", g_esPlayer[admin].g_flDrunkSpeedInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flDrunkTurnInterval = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkTurnInterval", "Drunk Turn Interval", "Drunk_Turn_Interval", "turninterval", g_esPlayer[admin].g_flDrunkTurnInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "drunkability", false) || StrEqual(subsection, "drunk ability", false) || StrEqual(subsection, "drunk_ability", false) || StrEqual(subsection, "drunk", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iDrunkAbility = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iDrunkAbility, value, 0, 1);
		g_esAbility[type].g_iDrunkEffect = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iDrunkEffect, value, 0, 7);
		g_esAbility[type].g_iDrunkMessage = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iDrunkMessage, value, 0, 3);
		g_esAbility[type].g_flDrunkChance = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkChance", "Drunk Chance", "Drunk_Chance", "chance", g_esAbility[type].g_flDrunkChance, value, 0.0, 100.0);
		g_esAbility[type].g_iDrunkDuration = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkDuration", "Drunk Duration", "Drunk_Duration", "duration", g_esAbility[type].g_iDrunkDuration, value, 1, 999999);
		g_esAbility[type].g_iDrunkHit = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkHit", "Drunk Hit", "Drunk_Hit", "hit", g_esAbility[type].g_iDrunkHit, value, 0, 1);
		g_esAbility[type].g_iDrunkHitMode = iGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkHitMode", "Drunk Hit Mode", "Drunk_Hit_Mode", "hitmode", g_esAbility[type].g_iDrunkHitMode, value, 0, 2);
		g_esAbility[type].g_flDrunkRange = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkRange", "Drunk Range", "Drunk_Range", "range", g_esAbility[type].g_flDrunkRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flDrunkRangeChance = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkRangeChance", "Drunk Range Chance", "Drunk_Range_Chance", "rangechance", g_esAbility[type].g_flDrunkRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flDrunkSpeedInterval = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkSpeedInterval", "Drunk Speed Interval", "Drunk_Speed_Interval", "speedinterval", g_esAbility[type].g_flDrunkSpeedInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flDrunkTurnInterval = flGetKeyValue(subsection, "drunkability", "drunk ability", "drunk_ability", "drunk", key, "DrunkTurnInterval", "Drunk Turn Interval", "Drunk_Turn_Interval", "turninterval", g_esAbility[type].g_flDrunkTurnInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "drunkability", false) || StrEqual(subsection, "drunk ability", false) || StrEqual(subsection, "drunk_ability", false) || StrEqual(subsection, "drunk", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flDrunkChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrunkChance, g_esAbility[type].g_flDrunkChance);
	g_esCache[tank].g_flDrunkRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrunkRange, g_esAbility[type].g_flDrunkRange);
	g_esCache[tank].g_flDrunkRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrunkRangeChance, g_esAbility[type].g_flDrunkRangeChance);
	g_esCache[tank].g_flDrunkSpeedInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrunkSpeedInterval, g_esAbility[type].g_flDrunkSpeedInterval);
	g_esCache[tank].g_flDrunkTurnInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrunkTurnInterval, g_esAbility[type].g_flDrunkTurnInterval);
	g_esCache[tank].g_iDrunkAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkAbility, g_esAbility[type].g_iDrunkAbility);
	g_esCache[tank].g_iDrunkDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkDuration, g_esAbility[type].g_iDrunkDuration);
	g_esCache[tank].g_iDrunkEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkEffect, g_esAbility[type].g_iDrunkEffect);
	g_esCache[tank].g_iDrunkHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkHit, g_esAbility[type].g_iDrunkHit);
	g_esCache[tank].g_iDrunkHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkHitMode, g_esAbility[type].g_iDrunkHitMode);
	g_esCache[tank].g_iDrunkMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrunkMessage, g_esAbility[type].g_iDrunkMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected)
		{
			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveDrunk(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iDrunkAbility == 1)
	{
		vDrunkAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iDrunkAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vDrunkAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveDrunk(tank);
}

static void vDrunkAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flDrunkRange)
				{
					vDrunkHit(iSurvivor, tank, g_esCache[tank].g_flDrunkRangeChance, g_esCache[tank].g_iDrunkAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkAmmo");
	}
}

static void vDrunkHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static int iSurvivorId, iTankId, iType;
				iSurvivorId = GetClientUserId(survivor);
				iTankId = GetClientUserId(tank);
				iType = g_esPlayer[tank].g_iTankType;

				DataPack dpDrunkSpeed;
				CreateDataTimer(g_esCache[tank].g_flDrunkSpeedInterval, tTimerDrunkSpeed, dpDrunkSpeed, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpDrunkSpeed.WriteCell(iSurvivorId);
				dpDrunkSpeed.WriteCell(iTankId);
				dpDrunkSpeed.WriteCell(iType);
				dpDrunkSpeed.WriteCell(enabled);
				dpDrunkSpeed.WriteCell(iTime);

				DataPack dpDrunkTurn;
				CreateDataTimer(g_esCache[tank].g_flDrunkTurnInterval, tTimerDrunkTurn, dpDrunkTurn, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpDrunkTurn.WriteCell(iSurvivorId);
				dpDrunkTurn.WriteCell(iTankId);
				dpDrunkTurn.WriteCell(iType);
				dpDrunkTurn.WriteCell(messages);
				dpDrunkTurn.WriteCell(enabled);
				dpDrunkTurn.WriteCell(iTime);

				vEffect(survivor, tank, g_esCache[tank].g_iDrunkEffect, flags);

				if (g_esCache[tank].g_iDrunkMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Drunk", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrunkAmmo");
		}
	}
}

static void vRemoveDrunk(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset3(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	if (g_esCache[tank].g_iDrunkMessage & messages)
	{
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Drunk2", survivor);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

public Action tTimerDrunkSpeed(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		return Plugin_Stop;
	}

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
	{
		return Plugin_Stop;
	}

	static int iDrunkEnabled, iTime;
	iDrunkEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iDrunkEnabled == 0 || (iTime + g_esCache[iTank].g_iDrunkDuration < GetTime()))
	{
		return Plugin_Stop;
	}

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", GetRandomFloat(1.5, 3.0));
	CreateTimer(GetRandomFloat(1.0, 3.0), tTimerStopDrunkSpeed, GetClientUserId(iSurvivor), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action tTimerDrunkTurn(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iDrunkEnabled, iTime;
	iDrunkEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iDrunkEnabled == 0 || (iTime + g_esCache[iTank].g_iDrunkDuration < GetTime()))
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static float flAngle, flPunchAngles[3], flEyeAngles[3];
	flAngle = GetRandomFloat(-360.0, 360.0);
	flPunchAngles[0] = 0.0;
	flPunchAngles[1] = 0.0;
	flPunchAngles[2] = 0.0;
	GetClientEyeAngles(iSurvivor, flEyeAngles);

	flEyeAngles[1] -= flAngle;
	flPunchAngles[1] += flAngle;

	TeleportEntity(iSurvivor, NULL_VECTOR, flEyeAngles, NULL_VECTOR);
	SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flPunchAngles);

	return Plugin_Continue;
}

public Action tTimerStopDrunkSpeed(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

	return Plugin_Continue;
}