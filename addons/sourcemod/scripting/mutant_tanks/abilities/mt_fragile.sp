/**
 * Mutant Tanks: A L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2017-2025  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_FRAGILE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_FRAGILE_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Fragile Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank takes more damage while dealing more damage and running faster.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLaggedMovementInstalled, g_bLateLoad;

/**
 * Third-party natives
 **/

// [L4D & L4D2] Lagged Movement - Plugin Conflict Resolver: https://forums.alliedmods.net/showthread.php?t=340345
native any L4D_LaggedMovement(int client, float value, bool force = false);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Fragile Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = false;
	}
}
#else
	#if MT_FRAGILE_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_FRAGILE_SECTION "fragileability"
#define MT_FRAGILE_SECTION2 "fragile ability"
#define MT_FRAGILE_SECTION3 "fragile_ability"
#define MT_FRAGILE_SECTION4 "fragile"

#define MT_MENU_FRAGILE "Fragile Ability"

enum struct esFragilePlayer
{
	bool g_bActivated;

	float g_flCloseAreasOnly;
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileHittableMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iDuration;
	int g_iFragileAbility;
	int g_iFragileCooldown;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esFragilePlayer g_esFragilePlayer[MAXPLAYERS + 1];

enum struct esFragileTeammate
{
	float g_flCloseAreasOnly;
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileHittableMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iFragileAbility;
	int g_iFragileCooldown;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esFragileTeammate g_esFragileTeammate[MAXPLAYERS + 1];

enum struct esFragileAbility
{
	float g_flCloseAreasOnly;
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileHittableMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iFragileAbility;
	int g_iFragileCooldown;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esFragileAbility g_esFragileAbility[MT_MAXTYPES + 1];

enum struct esFragileSpecial
{
	float g_flCloseAreasOnly;
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileHittableMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iFragileAbility;
	int g_iFragileCooldown;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esFragileSpecial g_esFragileSpecial[MT_MAXTYPES + 1];

enum struct esFragileCache
{
	float g_flCloseAreasOnly;
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileHittableMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iFragileAbility;
	int g_iFragileCooldown;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esFragileCache g_esFragileCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_fragile", cmdFragileInfo, "View information about the Fragile ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}
#endif

#if defined MT_ABILITIES_MAIN
void vFragileMapStart()
#else
public void OnMapStart()
#endif
{
	vFragileReset();
}

#if defined MT_ABILITIES_MAIN
void vFragileClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnFragileTakeDamage);
	vRemoveFragile(client);
}

#if defined MT_ABILITIES_MAIN
void vFragileClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveFragile(client);
}

#if defined MT_ABILITIES_MAIN
void vFragileMapEnd()
#else
public void OnMapEnd()
#endif
{
	vFragileReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdFragileInfo(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG5, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vFragileMenu(client, MT_FRAGILE_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vFragileMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_FRAGILE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iFragileMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fragile Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iFragileMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esFragileCache[param1].g_iFragileAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esFragileCache[param1].g_iHumanAmmo - g_esFragilePlayer[param1].g_iAmmoCount), g_esFragileCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3:
				{
					switch (g_esFragileCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esFragileCache[param1].g_iHumanAbility == 1) ? g_esFragileCache[param1].g_iHumanCooldown : g_esFragileCache[param1].g_iFragileCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FragileDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esFragileCache[param1].g_iHumanAbility == 1) ? g_esFragileCache[param1].g_iHumanDuration : g_esFragileCache[param1].g_iFragileDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esFragileCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vFragileMenu(param1, MT_FRAGILE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pFragile = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "FragileMenu", param1);
			pFragile.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vFragileDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_FRAGILE, MT_MENU_FRAGILE);
}

#if defined MT_ABILITIES_MAIN
void vFragileMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_FRAGILE, false))
	{
		vFragileMenu(client, MT_FRAGILE_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_FRAGILE, false))
	{
		FormatEx(buffer, size, "%T", "FragileMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN
void vFragilePlayerRunCmd(int client)
#else
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
#endif
{
	if (!MT_IsTankSupported(client) || !g_esFragilePlayer[client].g_bActivated || (bIsInfected(client, MT_CHECK_FAKECLIENT) && g_esFragileCache[client].g_iHumanMode > 0) || g_esFragilePlayer[client].g_iDuration == -1)
	{
#if defined MT_ABILITIES_MAIN
		return;
#else
		return Plugin_Continue;
#endif
	}

	int iTime = GetTime();
	if (g_esFragilePlayer[client].g_iDuration <= iTime)
	{
		if (g_esFragilePlayer[client].g_iCooldown == -1 || g_esFragilePlayer[client].g_iCooldown <= iTime)
		{
			vFragileReset3(client);
		}

		vFragileReset2(client);
	}
#if !defined MT_ABILITIES_MAIN
	return Plugin_Continue;
#endif
}

Action OnFragileTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && g_esFragilePlayer[victim].g_bActivated)
		{
			bool bSurvivor = bIsSurvivor(attacker);
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esFragileAbility[g_esFragilePlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esFragilePlayer[victim].g_iAccessFlags)) || (bSurvivor && (MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esFragilePlayer[victim].g_iTankType, g_esFragileAbility[g_esFragilePlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esFragilePlayer[attacker].g_iImmunityFlags))))
			{
				return Plugin_Continue;
			}

			bool bChanged = false;
			if (g_esFragileCache[victim].g_flFragileBulletMultiplier > 1.0 && (damagetype & DMG_BULLET))
			{
				bChanged = true;
				damage *= g_esFragileCache[victim].g_flFragileBulletMultiplier;
			}
			else if (g_esFragileCache[victim].g_flFragileExplosiveMultiplier > 1.0 && ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)))
			{
				bChanged = true;
				damage *= g_esFragileCache[victim].g_flFragileExplosiveMultiplier;
			}
			else if (g_esFragileCache[victim].g_flFragileFireMultiplier > 1.0 && ((damagetype & DMG_BURN) || (damagetype & DMG_DIRECT)))
			{
				bChanged = true;
				damage *= g_esFragileCache[victim].g_flFragileFireMultiplier;
			}
			else if (g_esFragileCache[victim].g_flFragileHittableMultiplier > 1.0 && (damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable"))
			{
				bChanged = true;
				damage *= g_esFragileCache[victim].g_flFragileHittableMultiplier;
			}
			else if (g_esFragileCache[victim].g_flFragileMeleeMultiplier > 1.0 && ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)))
			{
				bChanged = true;
				damage *= g_esFragileCache[victim].g_flFragileMeleeMultiplier;

				if (bSurvivor && MT_DoesSurvivorHaveRewardType(attacker, MT_REWARD_ATTACKBOOST) && GetRandomFloat(0.1, 100.0) <= 15.0)
				{
					float flTankOrigin[3], flSurvivorOrigin[3], flDirection[3];
					GetClientAbsOrigin(attacker, flSurvivorOrigin);
					GetClientAbsOrigin(victim, flTankOrigin);
					MakeVectorFromPoints(flSurvivorOrigin, flTankOrigin, flDirection);
					NormalizeVector(flDirection, flDirection);
					MT_ShoveBySurvivor(victim, attacker, flDirection);
					SetEntPropFloat(victim, Prop_Send, "m_flVelocityModifier", 0.4);
				}
			}

			if (bChanged)
			{
				switch (g_esFragileCache[victim].g_iFragileMode)
				{
					case 0:
					{
						float flSpeed = (MT_GetRunSpeed(victim) + g_esFragileCache[victim].g_flFragileSpeedBoost);
						SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(victim, flSpeed) : flSpeed));
					}
					case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(victim, g_esFragileCache[victim].g_flFragileSpeedBoost) : g_esFragileCache[victim].g_flFragileSpeedBoost));
				}

				return Plugin_Changed;
			}
		}
		else if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && g_esFragilePlayer[attacker].g_bActivated && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				switch (g_esFragileCache[attacker].g_iFragileMode)
				{
					case 0:
					{
						damage += g_esFragileCache[attacker].g_flFragileDamageBoost;
						damage = MT_GetScaledDamage(damage);
					}
					case 1: damage = MT_GetScaledDamage(g_esFragileCache[attacker].g_flFragileDamageBoost);
				}

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vFragilePluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_FRAGILE);
}

#if defined MT_ABILITIES_MAIN
void vFragileAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_FRAGILE_SECTION);
	list2.PushString(MT_FRAGILE_SECTION2);
	list3.PushString(MT_FRAGILE_SECTION3);
	list4.PushString(MT_FRAGILE_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vFragileCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility != 2)
	{
		g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_FRAGILE_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_FRAGILE_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_FRAGILE_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_FRAGILE_SECTION4);
	if (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esFragileCache[tank].g_iFragileAbility == 1 && g_esFragileCache[tank].g_iComboAbility == 1 && !g_esFragilePlayer[tank].g_bActivated)
		{
			char sAbilities[320], sSubset[10][32];
			strcopy(sAbilities, sizeof sAbilities, combo);
			ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

			float flDelay = 0.0;
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_FRAGILE_SECTION, false) || StrEqual(sSubset[iPos], MT_FRAGILE_SECTION2, false) || StrEqual(sSubset[iPos], MT_FRAGILE_SECTION3, false) || StrEqual(sSubset[iPos], MT_FRAGILE_SECTION4, false))
				{
					g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;

					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						flDelay = MT_GetCombinationSetting(tank, 4, iPos);

						switch (flDelay)
						{
							case 0.0: vFragile(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerFragileCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
						}
					}

					break;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esFragileAbility[iIndex].g_iAccessFlags = 0;
				g_esFragileAbility[iIndex].g_iImmunityFlags = 0;
				g_esFragileAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esFragileAbility[iIndex].g_iComboAbility = 0;
				g_esFragileAbility[iIndex].g_iComboPosition = -1;
				g_esFragileAbility[iIndex].g_iHumanAbility = 0;
				g_esFragileAbility[iIndex].g_iHumanAmmo = 5;
				g_esFragileAbility[iIndex].g_iHumanCooldown = 0;
				g_esFragileAbility[iIndex].g_iHumanDuration = 5;
				g_esFragileAbility[iIndex].g_iHumanMode = 1;
				g_esFragileAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esFragileAbility[iIndex].g_iRequiresHumans = 0;
				g_esFragileAbility[iIndex].g_iFragileAbility = 0;
				g_esFragileAbility[iIndex].g_iFragileMessage = 0;
				g_esFragileAbility[iIndex].g_flFragileBulletMultiplier = 5.0;
				g_esFragileAbility[iIndex].g_flFragileChance = 33.3;
				g_esFragileAbility[iIndex].g_iFragileCooldown = 0;
				g_esFragileAbility[iIndex].g_flFragileDamageBoost = 5.0;
				g_esFragileAbility[iIndex].g_iFragileDuration = 5;
				g_esFragileAbility[iIndex].g_flFragileExplosiveMultiplier = 5.0;
				g_esFragileAbility[iIndex].g_flFragileFireMultiplier = 3.0;
				g_esFragileAbility[iIndex].g_flFragileHittableMultiplier = 1.5;
				g_esFragileAbility[iIndex].g_flFragileMeleeMultiplier = 1.5;
				g_esFragileAbility[iIndex].g_iFragileMode = 0;
				g_esFragileAbility[iIndex].g_flFragileSpeedBoost = 1.0;

				g_esFragileSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esFragileSpecial[iIndex].g_iComboAbility = -1;
				g_esFragileSpecial[iIndex].g_iHumanAbility = -1;
				g_esFragileSpecial[iIndex].g_iHumanAmmo = -1;
				g_esFragileSpecial[iIndex].g_iHumanCooldown = -1;
				g_esFragileSpecial[iIndex].g_iHumanDuration = -1;
				g_esFragileSpecial[iIndex].g_iHumanMode = -1;
				g_esFragileSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esFragileSpecial[iIndex].g_iRequiresHumans = -1;
				g_esFragileSpecial[iIndex].g_iFragileAbility = -1;
				g_esFragileSpecial[iIndex].g_iFragileMessage = -1;
				g_esFragileSpecial[iIndex].g_flFragileBulletMultiplier = -1.0;
				g_esFragileSpecial[iIndex].g_flFragileChance = -1.0;
				g_esFragileSpecial[iIndex].g_iFragileCooldown = -1;
				g_esFragileSpecial[iIndex].g_flFragileDamageBoost = -1.0;
				g_esFragileSpecial[iIndex].g_iFragileDuration = -1;
				g_esFragileSpecial[iIndex].g_flFragileExplosiveMultiplier = -1.0;
				g_esFragileSpecial[iIndex].g_flFragileFireMultiplier = -1.0;
				g_esFragileSpecial[iIndex].g_flFragileHittableMultiplier = -1.0;
				g_esFragileSpecial[iIndex].g_flFragileMeleeMultiplier = -1.0;
				g_esFragileSpecial[iIndex].g_iFragileMode = -1;
				g_esFragileSpecial[iIndex].g_flFragileSpeedBoost = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esFragilePlayer[iPlayer].g_iAccessFlags = -1;
				g_esFragilePlayer[iPlayer].g_iImmunityFlags = -1;
				g_esFragilePlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esFragilePlayer[iPlayer].g_iComboAbility = -1;
				g_esFragilePlayer[iPlayer].g_iHumanAbility = -1;
				g_esFragilePlayer[iPlayer].g_iHumanAmmo = -1;
				g_esFragilePlayer[iPlayer].g_iHumanCooldown = -1;
				g_esFragilePlayer[iPlayer].g_iHumanDuration = -1;
				g_esFragilePlayer[iPlayer].g_iHumanMode = -1;
				g_esFragilePlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esFragilePlayer[iPlayer].g_iRequiresHumans = -1;
				g_esFragilePlayer[iPlayer].g_iFragileAbility = -1;
				g_esFragilePlayer[iPlayer].g_iFragileMessage = -1;
				g_esFragilePlayer[iPlayer].g_flFragileBulletMultiplier = -1.0;
				g_esFragilePlayer[iPlayer].g_flFragileChance = -1.0;
				g_esFragilePlayer[iPlayer].g_iFragileCooldown = -1;
				g_esFragilePlayer[iPlayer].g_flFragileDamageBoost = -1.0;
				g_esFragilePlayer[iPlayer].g_iFragileDuration = -1;
				g_esFragilePlayer[iPlayer].g_flFragileExplosiveMultiplier = -1.0;
				g_esFragilePlayer[iPlayer].g_flFragileFireMultiplier = -1.0;
				g_esFragilePlayer[iPlayer].g_flFragileHittableMultiplier = -1.0;
				g_esFragilePlayer[iPlayer].g_flFragileMeleeMultiplier = -1.0;
				g_esFragilePlayer[iPlayer].g_iFragileMode = -1;
				g_esFragilePlayer[iPlayer].g_flFragileSpeedBoost = -1.0;

				g_esFragileTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esFragileTeammate[iPlayer].g_iComboAbility = -1;
				g_esFragileTeammate[iPlayer].g_iHumanAbility = -1;
				g_esFragileTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esFragileTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esFragileTeammate[iPlayer].g_iHumanDuration = -1;
				g_esFragileTeammate[iPlayer].g_iHumanMode = -1;
				g_esFragileTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esFragileTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esFragileTeammate[iPlayer].g_iFragileAbility = -1;
				g_esFragileTeammate[iPlayer].g_iFragileMessage = -1;
				g_esFragileTeammate[iPlayer].g_flFragileBulletMultiplier = -1.0;
				g_esFragileTeammate[iPlayer].g_flFragileChance = -1.0;
				g_esFragileTeammate[iPlayer].g_iFragileCooldown = -1;
				g_esFragileTeammate[iPlayer].g_flFragileDamageBoost = -1.0;
				g_esFragileTeammate[iPlayer].g_iFragileDuration = -1;
				g_esFragileTeammate[iPlayer].g_flFragileExplosiveMultiplier = -1.0;
				g_esFragileTeammate[iPlayer].g_flFragileFireMultiplier = -1.0;
				g_esFragileTeammate[iPlayer].g_flFragileHittableMultiplier = -1.0;
				g_esFragileTeammate[iPlayer].g_flFragileMeleeMultiplier = -1.0;
				g_esFragileTeammate[iPlayer].g_iFragileMode = -1;
				g_esFragileTeammate[iPlayer].g_flFragileSpeedBoost = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esFragileTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esFragileTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFragileTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esFragileTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFragileTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esFragileTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFragileTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esFragileTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFragileTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esFragileTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esFragileTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esFragileTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFragileTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esFragileTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFragileTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFragileTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esFragileTeammate[admin].g_iFragileAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFragileTeammate[admin].g_iFragileAbility, value, -1, 1);
			g_esFragileTeammate[admin].g_iFragileMessage = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFragileTeammate[admin].g_iFragileMessage, value, -1, 1);
			g_esFragileTeammate[admin].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esFragileTeammate[admin].g_flFragileBulletMultiplier, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_flFragileChance = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esFragileTeammate[admin].g_flFragileChance, value, -1.0, 100.0);
			g_esFragileTeammate[admin].g_iFragileCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileCooldown", "Fragile Cooldown", "Fragile_Cooldown", "cooldown", g_esFragileTeammate[admin].g_iFragileCooldown, value, -1, 99999);
			g_esFragileTeammate[admin].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esFragileTeammate[admin].g_flFragileDamageBoost, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_iFragileDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esFragileTeammate[admin].g_iFragileDuration, value, -1, 99999);
			g_esFragileTeammate[admin].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esFragileTeammate[admin].g_flFragileExplosiveMultiplier, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esFragileTeammate[admin].g_flFragileFireMultiplier, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_flFragileHittableMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileHittableMultiplier", "Fragile Hittable Multiplier", "Fragile_Hittable_Multiplier", "hittable", g_esFragileTeammate[admin].g_flFragileHittableMultiplier, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esFragileTeammate[admin].g_flFragileMeleeMultiplier, value, -1.0, 99999.0);
			g_esFragileTeammate[admin].g_iFragileMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esFragileTeammate[admin].g_iFragileMode, value, -1, 1);
			g_esFragileTeammate[admin].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esFragileTeammate[admin].g_flFragileSpeedBoost, value, -1.0, 3.0);
		}
		else
		{
			g_esFragilePlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esFragilePlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFragilePlayer[admin].g_iComboAbility, value, -1, 1);
			g_esFragilePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFragilePlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esFragilePlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFragilePlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esFragilePlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFragilePlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esFragilePlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esFragilePlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esFragilePlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFragilePlayer[admin].g_iHumanMode, value, -1, 2);
			g_esFragilePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFragilePlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFragilePlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esFragilePlayer[admin].g_iFragileAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFragilePlayer[admin].g_iFragileAbility, value, -1, 1);
			g_esFragilePlayer[admin].g_iFragileMessage = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFragilePlayer[admin].g_iFragileMessage, value, -1, 1);
			g_esFragilePlayer[admin].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esFragilePlayer[admin].g_flFragileBulletMultiplier, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_flFragileChance = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esFragilePlayer[admin].g_flFragileChance, value, -1.0, 100.0);
			g_esFragilePlayer[admin].g_iFragileCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileCooldown", "Fragile Cooldown", "Fragile_Cooldown", "cooldown", g_esFragilePlayer[admin].g_iFragileCooldown, value, -1, 99999);
			g_esFragilePlayer[admin].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esFragilePlayer[admin].g_flFragileDamageBoost, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_iFragileDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esFragilePlayer[admin].g_iFragileDuration, value, -1, 99999);
			g_esFragilePlayer[admin].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esFragilePlayer[admin].g_flFragileExplosiveMultiplier, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esFragilePlayer[admin].g_flFragileFireMultiplier, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_flFragileHittableMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileHittableMultiplier", "Fragile Hittable Multiplier", "Fragile_Hittable_Multiplier", "hittable", g_esFragilePlayer[admin].g_flFragileHittableMultiplier, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esFragilePlayer[admin].g_flFragileMeleeMultiplier, value, -1.0, 99999.0);
			g_esFragilePlayer[admin].g_iFragileMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esFragilePlayer[admin].g_iFragileMode, value, -1, 1);
			g_esFragilePlayer[admin].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esFragilePlayer[admin].g_flFragileSpeedBoost, value, -1.0, 3.0);
			g_esFragilePlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esFragilePlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esFragileSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esFragileSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFragileSpecial[type].g_iComboAbility, value, -1, 1);
			g_esFragileSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFragileSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esFragileSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFragileSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esFragileSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFragileSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esFragileSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esFragileSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esFragileSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFragileSpecial[type].g_iHumanMode, value, -1, 2);
			g_esFragileSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFragileSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFragileSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esFragileSpecial[type].g_iFragileAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFragileSpecial[type].g_iFragileAbility, value, -1, 1);
			g_esFragileSpecial[type].g_iFragileMessage = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFragileSpecial[type].g_iFragileMessage, value, -1, 1);
			g_esFragileSpecial[type].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esFragileSpecial[type].g_flFragileBulletMultiplier, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_flFragileChance = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esFragileSpecial[type].g_flFragileChance, value, -1.0, 100.0);
			g_esFragileSpecial[type].g_iFragileCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileCooldown", "Fragile Cooldown", "Fragile_Cooldown", "cooldown", g_esFragileSpecial[type].g_iFragileCooldown, value, -1, 99999);
			g_esFragileSpecial[type].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esFragileSpecial[type].g_flFragileDamageBoost, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_iFragileDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esFragileSpecial[type].g_iFragileDuration, value, -1, 99999);
			g_esFragileSpecial[type].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esFragileSpecial[type].g_flFragileExplosiveMultiplier, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esFragileSpecial[type].g_flFragileFireMultiplier, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_flFragileHittableMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileHittableMultiplier", "Fragile Hittable Multiplier", "Fragile_Hittable_Multiplier", "hittable", g_esFragileSpecial[type].g_flFragileHittableMultiplier, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esFragileSpecial[type].g_flFragileMeleeMultiplier, value, -1.0, 99999.0);
			g_esFragileSpecial[type].g_iFragileMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esFragileSpecial[type].g_iFragileMode, value, -1, 1);
			g_esFragileSpecial[type].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esFragileSpecial[type].g_flFragileSpeedBoost, value, -1.0, 3.0);
		}
		else
		{
			g_esFragileAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esFragileAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFragileAbility[type].g_iComboAbility, value, -1, 1);
			g_esFragileAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFragileAbility[type].g_iHumanAbility, value, -1, 2);
			g_esFragileAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFragileAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esFragileAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFragileAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esFragileAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esFragileAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esFragileAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFragileAbility[type].g_iHumanMode, value, -1, 2);
			g_esFragileAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFragileAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFragileAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esFragileAbility[type].g_iFragileAbility = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFragileAbility[type].g_iFragileAbility, value, -1, 1);
			g_esFragileAbility[type].g_iFragileMessage = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFragileAbility[type].g_iFragileMessage, value, -1, 1);
			g_esFragileAbility[type].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esFragileAbility[type].g_flFragileBulletMultiplier, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_flFragileChance = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esFragileAbility[type].g_flFragileChance, value, -1.0, 100.0);
			g_esFragileAbility[type].g_iFragileCooldown = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileCooldown", "Fragile Cooldown", "Fragile_Cooldown", "cooldown", g_esFragileAbility[type].g_iFragileCooldown, value, -1, 99999);
			g_esFragileAbility[type].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esFragileAbility[type].g_flFragileDamageBoost, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_iFragileDuration = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esFragileAbility[type].g_iFragileDuration, value, -1, 99999);
			g_esFragileAbility[type].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esFragileAbility[type].g_flFragileExplosiveMultiplier, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esFragileAbility[type].g_flFragileFireMultiplier, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_flFragileHittableMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileHittableMultiplier", "Fragile Hittable Multiplier", "Fragile_Hittable_Multiplier", "hittable", g_esFragileAbility[type].g_flFragileHittableMultiplier, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esFragileAbility[type].g_flFragileMeleeMultiplier, value, -1.0, 99999.0);
			g_esFragileAbility[type].g_iFragileMode = iGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esFragileAbility[type].g_iFragileMode, value, -1, 1);
			g_esFragileAbility[type].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esFragileAbility[type].g_flFragileSpeedBoost, value, -1.0, 3.0);
			g_esFragileAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esFragileAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_FRAGILE_SECTION, MT_FRAGILE_SECTION2, MT_FRAGILE_SECTION3, MT_FRAGILE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esFragilePlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esFragilePlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esFragilePlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esFragileCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flCloseAreasOnly, g_esFragilePlayer[tank].g_flCloseAreasOnly, g_esFragileSpecial[iType].g_flCloseAreasOnly, g_esFragileAbility[iType].g_flCloseAreasOnly, 1);
		g_esFragileCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iComboAbility, g_esFragilePlayer[tank].g_iComboAbility, g_esFragileSpecial[iType].g_iComboAbility, g_esFragileAbility[iType].g_iComboAbility, 1);
		g_esFragileCache[tank].g_flFragileBulletMultiplier = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileBulletMultiplier, g_esFragilePlayer[tank].g_flFragileBulletMultiplier, g_esFragileSpecial[iType].g_flFragileBulletMultiplier, g_esFragileAbility[iType].g_flFragileBulletMultiplier, 1);
		g_esFragileCache[tank].g_flFragileChance = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileChance, g_esFragilePlayer[tank].g_flFragileChance, g_esFragileSpecial[iType].g_flFragileChance, g_esFragileAbility[iType].g_flFragileChance, 1);
		g_esFragileCache[tank].g_flFragileDamageBoost = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileDamageBoost, g_esFragilePlayer[tank].g_flFragileDamageBoost, g_esFragileSpecial[iType].g_flFragileDamageBoost, g_esFragileAbility[iType].g_flFragileDamageBoost, 1);
		g_esFragileCache[tank].g_flFragileExplosiveMultiplier = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileExplosiveMultiplier, g_esFragilePlayer[tank].g_flFragileExplosiveMultiplier, g_esFragileSpecial[iType].g_flFragileExplosiveMultiplier, g_esFragileAbility[iType].g_flFragileExplosiveMultiplier, 1);
		g_esFragileCache[tank].g_flFragileFireMultiplier = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileFireMultiplier, g_esFragilePlayer[tank].g_flFragileFireMultiplier, g_esFragileSpecial[iType].g_flFragileFireMultiplier, g_esFragileAbility[iType].g_flFragileFireMultiplier, 1);
		g_esFragileCache[tank].g_flFragileHittableMultiplier = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileHittableMultiplier, g_esFragilePlayer[tank].g_flFragileHittableMultiplier, g_esFragileSpecial[iType].g_flFragileHittableMultiplier, g_esFragileAbility[iType].g_flFragileHittableMultiplier, 1);
		g_esFragileCache[tank].g_flFragileMeleeMultiplier = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileMeleeMultiplier, g_esFragilePlayer[tank].g_flFragileMeleeMultiplier, g_esFragileSpecial[iType].g_flFragileMeleeMultiplier, g_esFragileAbility[iType].g_flFragileMeleeMultiplier, 1);
		g_esFragileCache[tank].g_flFragileSpeedBoost = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flFragileSpeedBoost, g_esFragilePlayer[tank].g_flFragileSpeedBoost, g_esFragileSpecial[iType].g_flFragileSpeedBoost, g_esFragileAbility[iType].g_flFragileSpeedBoost, 1);
		g_esFragileCache[tank].g_iFragileAbility = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iFragileAbility, g_esFragilePlayer[tank].g_iFragileAbility, g_esFragileSpecial[iType].g_iFragileAbility, g_esFragileAbility[iType].g_iFragileAbility, 1);
		g_esFragileCache[tank].g_iFragileCooldown = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iFragileCooldown, g_esFragilePlayer[tank].g_iFragileCooldown, g_esFragileSpecial[iType].g_iFragileCooldown, g_esFragileAbility[iType].g_iFragileCooldown, 1);
		g_esFragileCache[tank].g_iFragileDuration = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iFragileDuration, g_esFragilePlayer[tank].g_iFragileDuration, g_esFragileSpecial[iType].g_iFragileDuration, g_esFragileAbility[iType].g_iFragileDuration, 1);
		g_esFragileCache[tank].g_iFragileMessage = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iFragileMessage, g_esFragilePlayer[tank].g_iFragileMessage, g_esFragileSpecial[iType].g_iFragileMessage, g_esFragileAbility[iType].g_iFragileMessage, 1);
		g_esFragileCache[tank].g_iFragileMode = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iFragileMode, g_esFragilePlayer[tank].g_iFragileMode, g_esFragileSpecial[iType].g_iFragileMode, g_esFragileAbility[iType].g_iFragileMode, 1);
		g_esFragileCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iHumanAbility, g_esFragilePlayer[tank].g_iHumanAbility, g_esFragileSpecial[iType].g_iHumanAbility, g_esFragileAbility[iType].g_iHumanAbility, 1);
		g_esFragileCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iHumanAmmo, g_esFragilePlayer[tank].g_iHumanAmmo, g_esFragileSpecial[iType].g_iHumanAmmo, g_esFragileAbility[iType].g_iHumanAmmo, 1);
		g_esFragileCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iHumanCooldown, g_esFragilePlayer[tank].g_iHumanCooldown, g_esFragileSpecial[iType].g_iHumanCooldown, g_esFragileAbility[iType].g_iHumanCooldown, 1);
		g_esFragileCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iHumanDuration, g_esFragilePlayer[tank].g_iHumanDuration, g_esFragileSpecial[iType].g_iHumanDuration, g_esFragileAbility[iType].g_iHumanDuration, 1);
		g_esFragileCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iHumanMode, g_esFragilePlayer[tank].g_iHumanMode, g_esFragileSpecial[iType].g_iHumanMode, g_esFragileAbility[iType].g_iHumanMode, 1);
		g_esFragileCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_flOpenAreasOnly, g_esFragilePlayer[tank].g_flOpenAreasOnly, g_esFragileSpecial[iType].g_flOpenAreasOnly, g_esFragileAbility[iType].g_flOpenAreasOnly, 1);
		g_esFragileCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esFragileTeammate[tank].g_iRequiresHumans, g_esFragilePlayer[tank].g_iRequiresHumans, g_esFragileSpecial[iType].g_iRequiresHumans, g_esFragileAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esFragileCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flCloseAreasOnly, g_esFragileAbility[iType].g_flCloseAreasOnly, 1);
		g_esFragileCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iComboAbility, g_esFragileAbility[iType].g_iComboAbility, 1);
		g_esFragileCache[tank].g_flFragileBulletMultiplier = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileBulletMultiplier, g_esFragileAbility[iType].g_flFragileBulletMultiplier, 1);
		g_esFragileCache[tank].g_flFragileChance = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileChance, g_esFragileAbility[iType].g_flFragileChance, 1);
		g_esFragileCache[tank].g_flFragileDamageBoost = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileDamageBoost, g_esFragileAbility[iType].g_flFragileDamageBoost, 1);
		g_esFragileCache[tank].g_flFragileExplosiveMultiplier = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileExplosiveMultiplier, g_esFragileAbility[iType].g_flFragileExplosiveMultiplier, 1);
		g_esFragileCache[tank].g_flFragileFireMultiplier = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileFireMultiplier, g_esFragileAbility[iType].g_flFragileFireMultiplier, 1);
		g_esFragileCache[tank].g_flFragileHittableMultiplier = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileHittableMultiplier, g_esFragileAbility[iType].g_flFragileHittableMultiplier, 1);
		g_esFragileCache[tank].g_flFragileMeleeMultiplier = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileMeleeMultiplier, g_esFragileAbility[iType].g_flFragileMeleeMultiplier, 1);
		g_esFragileCache[tank].g_flFragileSpeedBoost = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flFragileSpeedBoost, g_esFragileAbility[iType].g_flFragileSpeedBoost, 1);
		g_esFragileCache[tank].g_iFragileAbility = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iFragileAbility, g_esFragileAbility[iType].g_iFragileAbility, 1);
		g_esFragileCache[tank].g_iFragileCooldown = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iFragileCooldown, g_esFragileAbility[iType].g_iFragileCooldown, 1);
		g_esFragileCache[tank].g_iFragileDuration = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iFragileDuration, g_esFragileAbility[iType].g_iFragileDuration, 1);
		g_esFragileCache[tank].g_iFragileMessage = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iFragileMessage, g_esFragileAbility[iType].g_iFragileMessage, 1);
		g_esFragileCache[tank].g_iFragileMode = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iFragileMode, g_esFragileAbility[iType].g_iFragileMode, 1);
		g_esFragileCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iHumanAbility, g_esFragileAbility[iType].g_iHumanAbility, 1);
		g_esFragileCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iHumanAmmo, g_esFragileAbility[iType].g_iHumanAmmo, 1);
		g_esFragileCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iHumanCooldown, g_esFragileAbility[iType].g_iHumanCooldown, 1);
		g_esFragileCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iHumanDuration, g_esFragileAbility[iType].g_iHumanDuration, 1);
		g_esFragileCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iHumanMode, g_esFragileAbility[iType].g_iHumanMode, 1);
		g_esFragileCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_flOpenAreasOnly, g_esFragileAbility[iType].g_flOpenAreasOnly, 1);
		g_esFragileCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esFragilePlayer[tank].g_iRequiresHumans, g_esFragileAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vFragileCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveFragile(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vFragilePluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsInfected(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esFragilePlayer[iTank].g_bActivated)
		{
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(iTank, 1.0, true) : 1.0));
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsInfected(iTank))
		{
			vFragileCopyStats2(iBot, iTank);
			vRemoveFragile(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vFragileReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vFragileCopyStats2(iTank, iBot);
			vRemoveFragile(iTank);
		}
	}
	else if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveFragile(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esFragilePlayer[tank].g_iAccessFlags)) || g_esFragileCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esFragileCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esFragileCache[tank].g_iFragileAbility == 1 && g_esFragileCache[tank].g_iComboAbility == 0 && !g_esFragilePlayer[tank].g_bActivated)
	{
		vFragileAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esFragileCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esFragileCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esFragilePlayer[tank].g_iTankType, tank) || (g_esFragileCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esFragileCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esFragilePlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && g_esFragileCache[tank].g_iFragileAbility == 1 && g_esFragileCache[tank].g_iHumanAbility == 1)
		{
			int iHumanMode = g_esFragileCache[tank].g_iHumanMode, iTime = GetTime();
			bool bRecharging = g_esFragilePlayer[tank].g_iCooldown != -1 && g_esFragilePlayer[tank].g_iCooldown >= iTime;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esFragilePlayer[tank].g_bActivated && !bRecharging)
					{
						vFragileAbility(tank);
					}
					else if (g_esFragilePlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman4", (g_esFragilePlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esFragilePlayer[tank].g_bActivated) || (g_esFragilePlayer[tank].g_iAmmoCount < g_esFragileCache[tank].g_iHumanAmmo && g_esFragileCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esFragilePlayer[tank].g_bActivated && !bRecharging)
						{
							g_esFragilePlayer[tank].g_bActivated = true;
							g_esFragilePlayer[tank].g_iAmmoCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman", g_esFragilePlayer[tank].g_iAmmoCount, g_esFragileCache[tank].g_iHumanAmmo);
						}
						else if (g_esFragilePlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman3");
								case 2:
								{
									vFragileReset2(tank);
									vFragileReset3(tank);
								}
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman4", (g_esFragilePlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileAmmo");
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esFragileCache[tank].g_iHumanMode == 1 && g_esFragilePlayer[tank].g_bActivated && (g_esFragilePlayer[tank].g_iCooldown == -1 || g_esFragilePlayer[tank].g_iCooldown <= GetTime()))
		{
			vFragileReset2(tank);
			vFragileReset3(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vFragileChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveFragile(tank);
}

void vFragile(int tank, int pos = -1)
{
	int iTime = GetTime();
	if (g_esFragilePlayer[tank].g_iCooldown != -1 && g_esFragilePlayer[tank].g_iCooldown >= iTime)
	{
		return;
	}

	int iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 5, pos)) : g_esFragileCache[tank].g_iFragileDuration;
	iDuration = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1) ? g_esFragileCache[tank].g_iHumanDuration : iDuration;
	g_esFragilePlayer[tank].g_bActivated = true;
	g_esFragilePlayer[tank].g_iDuration = (iTime + iDuration);

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1)
	{
		g_esFragilePlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman", g_esFragilePlayer[tank].g_iAmmoCount, g_esFragileCache[tank].g_iHumanAmmo);
	}

	if (g_esFragileCache[tank].g_iFragileMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fragile", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fragile", LANG_SERVER, sTankName);
	}
}

void vFragileAbility(int tank)
{
	if ((g_esFragilePlayer[tank].g_iCooldown != -1 && g_esFragilePlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esFragileCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esFragileCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esFragilePlayer[tank].g_iTankType, tank) || (g_esFragileCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esFragileCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esFragilePlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esFragilePlayer[tank].g_iAmmoCount < g_esFragileCache[tank].g_iHumanAmmo && g_esFragileCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esFragileCache[tank].g_flFragileChance)
		{
			vFragile(tank);
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman2");
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileAmmo");
	}
}

void vFragileCopyStats2(int oldTank, int newTank)
{
	g_esFragilePlayer[newTank].g_iAmmoCount = g_esFragilePlayer[oldTank].g_iAmmoCount;
	g_esFragilePlayer[newTank].g_iCooldown = g_esFragilePlayer[oldTank].g_iCooldown;
}

void vRemoveFragile(int tank)
{
	g_esFragilePlayer[tank].g_bActivated = false;
	g_esFragilePlayer[tank].g_iAmmoCount = 0;
	g_esFragilePlayer[tank].g_iCooldown = -1;
	g_esFragilePlayer[tank].g_iDuration = -1;
}

void vFragileReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveFragile(iPlayer);
		}
	}
}

void vFragileReset2(int tank)
{
	g_esFragilePlayer[tank].g_bActivated = false;
	g_esFragilePlayer[tank].g_iDuration = -1;

	float flSpeed = MT_GetRunSpeed(tank);
	SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(tank, flSpeed) : flSpeed));

	if (g_esFragileCache[tank].g_iFragileMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fragile2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fragile2", LANG_SERVER, sTankName);
	}
}

void vFragileReset3(int tank)
{
	int iTime = GetTime(), iPos = g_esFragileAbility[g_esFragilePlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esFragileCache[tank].g_iFragileCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esFragileCache[tank].g_iHumanAbility == 1 && g_esFragileCache[tank].g_iHumanMode == 0 && g_esFragilePlayer[tank].g_iAmmoCount < g_esFragileCache[tank].g_iHumanAmmo && g_esFragileCache[tank].g_iHumanAmmo > 0) ? g_esFragileCache[tank].g_iHumanCooldown : iCooldown;
	g_esFragilePlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esFragilePlayer[tank].g_iCooldown != -1 && g_esFragilePlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman5", (g_esFragilePlayer[tank].g_iCooldown - iTime));
	}
}

Action tTimerFragileCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esFragileAbility[g_esFragilePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esFragilePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esFragilePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esFragileCache[iTank].g_iFragileAbility == 0 || g_esFragilePlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vFragile(iTank, iPos);

	return Plugin_Continue;
}