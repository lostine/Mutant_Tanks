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

public Plugin myinfo =
{
	name = "[MT] Bury Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank buries survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Bury Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_BURY "Bury Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flBuryChance;
	float g_flBuryDuration;
	float g_flBuryHeight;
	float g_flBuryRange;
	float g_flBuryRangeChance;

	int g_iAccessFlags;
	int g_iBuryAbility;
	int g_iBuryEffect;
	int g_iBuryHit;
	int g_iBuryHitMode;
	int g_iBuryMessage;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flBuryChance;
	float g_flBuryDuration;
	float g_flBuryHeight;
	float g_flBuryRange;
	float g_flBuryRangeChance;

	int g_iAccessFlags;
	int g_iBuryAbility;
	int g_iBuryEffect;
	int g_iBuryHit;
	int g_iBuryHitMode;
	int g_iBuryMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flBuryChance;
	float g_flBuryDuration;
	float g_flBuryHeight;
	float g_flBuryRange;
	float g_flBuryRangeChance;

	int g_iBuryAbility;
	int g_iBuryEffect;
	int g_iBuryHit;
	int g_iBuryHitMode;
	int g_iBuryMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_bury", cmdBuryInfo, "View information about the Bury ability.");

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

	vReset2(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdBuryInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vBuryMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBuryMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBuryMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Bury Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBuryMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iBuryAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "BuryDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flBuryDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vBuryMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "BuryMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];

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
	menu.AddItem(MT_MENU_BURY, MT_MENU_BURY);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_BURY, false))
	{
		vBuryMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iBuryHitMode == 0 || g_esCache[attacker].g_iBuryHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBuryHit(victim, attacker, g_esCache[attacker].g_flBuryChance, g_esCache[attacker].g_iBuryHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iBuryHitMode == 0 || g_esCache[victim].g_iBuryHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBuryHit(attacker, victim, g_esCache[victim].g_flBuryChance, g_esCache[victim].g_iBuryHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("buryability");
	list2.PushString("bury ability");
	list3.PushString("bury_ability");
	list4.PushString("bury");
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
				g_esAbility[iIndex].g_iBuryAbility = 0;
				g_esAbility[iIndex].g_iBuryEffect = 0;
				g_esAbility[iIndex].g_iBuryMessage = 0;
				g_esAbility[iIndex].g_flBuryChance = 33.3;
				g_esAbility[iIndex].g_flBuryDuration = 5.0;
				g_esAbility[iIndex].g_flBuryHeight = 50.0;
				g_esAbility[iIndex].g_iBuryHit = 0;
				g_esAbility[iIndex].g_iBuryHitMode = 0;
				g_esAbility[iIndex].g_flBuryRange = 150.0;
				g_esAbility[iIndex].g_flBuryRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iBuryAbility = 0;
					g_esPlayer[iPlayer].g_iBuryEffect = 0;
					g_esPlayer[iPlayer].g_iBuryMessage = 0;
					g_esPlayer[iPlayer].g_flBuryChance = 0.0;
					g_esPlayer[iPlayer].g_flBuryDuration = 0.0;
					g_esPlayer[iPlayer].g_flBuryHeight = 0.0;
					g_esPlayer[iPlayer].g_iBuryHit = 0;
					g_esPlayer[iPlayer].g_iBuryHitMode = 0;
					g_esPlayer[iPlayer].g_flBuryRange = 0.0;
					g_esPlayer[iPlayer].g_flBuryRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iBuryAbility = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iBuryAbility, value, 0, 1);
		g_esPlayer[admin].g_iBuryEffect = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iBuryEffect, value, 0, 7);
		g_esPlayer[admin].g_iBuryMessage = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iBuryMessage, value, 0, 3);
		g_esPlayer[admin].g_flBuryChance = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryChance", "Bury Chance", "Bury_Chance", "chance", g_esPlayer[admin].g_flBuryChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flBuryDuration = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryDuration", "Bury Duration", "Bury_Duration", "duration", g_esPlayer[admin].g_flBuryDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flBuryHeight = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHeight", "Bury Height", "Bury_Height", "height", g_esPlayer[admin].g_flBuryHeight, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iBuryHit = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHit", "Bury Hit", "Bury_Hit", "hit", g_esPlayer[admin].g_iBuryHit, value, 0, 1);
		g_esPlayer[admin].g_iBuryHitMode = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHitMode", "Bury Hit Mode", "Bury_Hit_Mode", "hitmode", g_esPlayer[admin].g_iBuryHitMode, value, 0, 2);
		g_esPlayer[admin].g_flBuryRange = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRange", "Bury Range", "Bury_Range", "range", g_esPlayer[admin].g_flBuryRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flBuryRangeChance = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRangeChance", "Bury Range Chance", "Bury_Range_Chance", "rangechance", g_esPlayer[admin].g_flBuryRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "buryability", false) || StrEqual(subsection, "bury ability", false) || StrEqual(subsection, "bury_ability", false) || StrEqual(subsection, "bury", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iBuryAbility = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iBuryAbility, value, 0, 1);
		g_esAbility[type].g_iBuryEffect = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iBuryEffect, value, 0, 7);
		g_esAbility[type].g_iBuryMessage = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iBuryMessage, value, 0, 3);
		g_esAbility[type].g_flBuryChance = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryChance", "Bury Chance", "Bury_Chance", "chance", g_esAbility[type].g_flBuryChance, value, 0.0, 100.0);
		g_esAbility[type].g_flBuryDuration = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryDuration", "Bury Duration", "Bury_Duration", "duration", g_esAbility[type].g_flBuryDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_flBuryHeight = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHeight", "Bury Height", "Bury_Height", "height", g_esAbility[type].g_flBuryHeight, value, 0.1, 999999.0);
		g_esAbility[type].g_iBuryHit = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHit", "Bury Hit", "Bury_Hit", "hit", g_esAbility[type].g_iBuryHit, value, 0, 1);
		g_esAbility[type].g_iBuryHitMode = iGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHitMode", "Bury Hit Mode", "Bury_Hit_Mode", "hitmode", g_esAbility[type].g_iBuryHitMode, value, 0, 2);
		g_esAbility[type].g_flBuryRange = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRange", "Bury Range", "Bury_Range", "range", g_esAbility[type].g_flBuryRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flBuryRangeChance = flGetKeyValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRangeChance", "Bury Range Chance", "Bury_Range_Chance", "rangechance", g_esAbility[type].g_flBuryRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "buryability", false) || StrEqual(subsection, "bury ability", false) || StrEqual(subsection, "bury_ability", false) || StrEqual(subsection, "bury", false))
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
	g_esCache[tank].g_flBuryChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBuryChance, g_esAbility[type].g_flBuryChance);
	g_esCache[tank].g_flBuryDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBuryDuration, g_esAbility[type].g_flBuryDuration);
	g_esCache[tank].g_flBuryHeight = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBuryHeight, g_esAbility[type].g_flBuryHeight);
	g_esCache[tank].g_flBuryRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBuryRange, g_esAbility[type].g_flBuryRange);
	g_esCache[tank].g_flBuryRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBuryRangeChance, g_esAbility[type].g_flBuryRangeChance);
	g_esCache[tank].g_iBuryAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBuryAbility, g_esAbility[type].g_iBuryAbility);
	g_esCache[tank].g_iBuryEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBuryEffect, g_esAbility[type].g_iBuryEffect);
	g_esCache[tank].g_iBuryHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBuryHit, g_esAbility[type].g_iBuryHit);
	g_esCache[tank].g_iBuryHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBuryHitMode, g_esAbility[type].g_iBuryHitMode);
	g_esCache[tank].g_iBuryMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBuryMessage, g_esAbility[type].g_iBuryMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			vRemoveBury(iTank);
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
			vRemoveBury(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBuryAbility == 1)
	{
		vBuryAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iBuryAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vBuryAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	if (MT_IsTankSupported(tank))
	{
		vRemoveBury(tank);
	}
}

static void vBuryAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
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
				if (flDistance <= g_esCache[tank].g_flBuryRange)
				{
					vBuryHit(iSurvivor, tank, g_esCache[tank].g_flBuryRangeChance, g_esCache[tank].g_iBuryAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryAmmo");
	}
}

static void vBuryHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && bIsEntityGrounded(survivor))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static float flOrigin[3], flPos[3];
				GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
				flOrigin[2] -= g_esCache[tank].g_flBuryHeight;
				SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

				if (!bIsPlayerIncapacitated(survivor))
				{
					SetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1);
					SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);
				}

				GetClientEyePosition(survivor, flPos);

				if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
				{
					SetEntityMoveType(survivor, MOVETYPE_NONE);
				}

				DataPack dpStopBury;
				CreateDataTimer(g_esCache[tank].g_flBuryDuration, tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
				dpStopBury.WriteCell(GetClientUserId(survivor));
				dpStopBury.WriteCell(GetClientUserId(tank));
				dpStopBury.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iBuryEffect, flags);

				if (g_esCache[tank].g_iBuryMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Bury", sTankName, survivor, flOrigin);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "BuryAmmo");
		}
	}
}

static void vRemoveBury(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			vStopBury(iSurvivor, tank);
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vStopBury(int survivor, int tank)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	float flOrigin[3], flCurrentOrigin[3];
	GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
	flOrigin[2] += g_esCache[tank].g_flBuryHeight;
	SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

	SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !g_esPlayer[iPlayer].g_bAffected && iPlayer != survivor)
		{
			GetClientAbsOrigin(iPlayer, flCurrentOrigin);
			TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

			break;
		}
	}

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vStopBury(iSurvivor, iTank);

		return Plugin_Stop;
	}

	vStopBury(iSurvivor, iTank);

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iBuryMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Bury2", iSurvivor);
	}

	return Plugin_Continue;
}