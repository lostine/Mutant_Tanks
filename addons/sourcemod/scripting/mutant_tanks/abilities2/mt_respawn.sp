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

#define MT_RESPAWN_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_RESPAWN_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Respawn Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank respawns upon death and resurrects nearby special infected that die.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bSecondGame;

int g_iGraphicsLevel;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Respawn Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_CHARGE "items/suitchargeok1.wav"
#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#else
	#if MT_RESPAWN_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_RESPAWN_SECTION "respawnability"
#define MT_RESPAWN_SECTION2 "respawn ability"
#define MT_RESPAWN_SECTION3 "respawn_ability"
#define MT_RESPAWN_SECTION4 "respawn"

#define MT_MENU_RESPAWN "Respawn Ability"

enum struct esRespawnPlayer
{
	bool g_bActivated;
	bool g_bActivated2;
	bool g_bRespawning[4];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRespawnChance;
	float g_flRespawnRange;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnCooldown;
	int g_iRespawnDuration;
	int g_iRespawnFilter;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iRespawnSight;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esRespawnPlayer g_esRespawnPlayer[MAXPLAYERS + 1];

enum struct esRespawnTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRespawnChance;
	float g_flRespawnRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnCooldown;
	int g_iRespawnDuration;
	int g_iRespawnFilter;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iRespawnSight;
}

esRespawnTeammate g_esRespawnTeammate[MAXPLAYERS + 1];

enum struct esRespawnAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRespawnChance;
	float g_flRespawnRange;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnCooldown;
	int g_iRespawnDuration;
	int g_iRespawnFilter;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iRespawnSight;
}

esRespawnAbility g_esRespawnAbility[MT_MAXTYPES + 1];

enum struct esRespawnSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRespawnChance;
	float g_flRespawnRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnCooldown;
	int g_iRespawnDuration;
	int g_iRespawnFilter;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iRespawnSight;
}

esRespawnSpecial g_esRespawnSpecial[MT_MAXTYPES + 1];

enum struct esRespawnCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRespawnChance;
	float g_flRespawnRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnCooldown;
	int g_iRespawnDuration;
	int g_iRespawnFilter;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iRespawnSight;
}

esRespawnCache g_esRespawnCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_respawn", cmdRespawnInfo, "View information about the Respawn ability.");
}
#endif

#if defined MT_ABILITIES_MAIN2
void vRespawnMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_ELECTRICITY, true);

	vRespawnReset();
}

#if defined MT_ABILITIES_MAIN2
void vRespawnClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	vRemoveRespawn(client);
}

#if defined MT_ABILITIES_MAIN2
void vRespawnClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveRespawn(client);
}

#if defined MT_ABILITIES_MAIN2
void vRespawnMapEnd()
#else
public void OnMapEnd()
#endif
{
	vRespawnReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdRespawnInfo(int client, int args)
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
		case false: vRespawnMenu(client, MT_RESPAWN_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vRespawnMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_RESPAWN_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iRespawnMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Respawn Ability Information");
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

int iRespawnMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRespawnCache[param1].g_iRespawnAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esRespawnCache[param1].g_iHumanAmmo - g_esRespawnPlayer[param1].g_iAmmoCount), g_esRespawnCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esRespawnCache[param1].g_iHumanAmmo - g_esRespawnPlayer[param1].g_iAmmoCount2), g_esRespawnCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				}
				case 3:
				{
					switch (g_esRespawnCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esRespawnCache[param1].g_iHumanAbility == 1) ? g_esRespawnCache[param1].g_iHumanCooldown : g_esRespawnCache[param1].g_iRespawnCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RespawnDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esRespawnCache[param1].g_iHumanAbility == 1) ? g_esRespawnCache[param1].g_iHumanDuration : g_esRespawnCache[param1].g_iRespawnDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRespawnCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRespawnMenu(param1, MT_RESPAWN_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRespawn = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "RespawnMenu", param1);
			pRespawn.SetTitle(sMenuTitle);
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

#if defined MT_ABILITIES_MAIN2
void vRespawnDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_RESPAWN, MT_MENU_RESPAWN);
}

#if defined MT_ABILITIES_MAIN2
void vRespawnMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		vRespawnMenu(client, MT_RESPAWN_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		FormatEx(buffer, size, "%T", "RespawnMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnPlayerRunCmd(int client)
#else
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
#endif
{
	if (!MT_IsTankSupported(client) || !g_esRespawnPlayer[client].g_bActivated || (bIsInfected(client, MT_CHECK_FAKECLIENT) && g_esRespawnCache[client].g_iHumanMode > 0) || g_esRespawnPlayer[client].g_iDuration == -1)
	{
#if defined MT_ABILITIES_MAIN2
		return;
#else
		return Plugin_Continue;
#endif
	}

	int iTime = GetTime();
	if (g_esRespawnPlayer[client].g_iDuration <= iTime)
	{
		if (g_esRespawnPlayer[client].g_iCooldown == -1 || g_esRespawnPlayer[client].g_iCooldown <= iTime)
		{
			vRespawnReset2(client);
		}

		g_esRespawnPlayer[client].g_bActivated = false;
		g_esRespawnPlayer[client].g_iDuration = -1;
	}
#if !defined MT_ABILITIES_MAIN2
	return Plugin_Continue;
#endif
}

#if defined MT_ABILITIES_MAIN2
void vRespawnPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_RESPAWN);
}

#if defined MT_ABILITIES_MAIN2
void vRespawnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_RESPAWN_SECTION);
	list2.PushString(MT_RESPAWN_SECTION2);
	list3.PushString(MT_RESPAWN_SECTION3);
	list4.PushString(MT_RESPAWN_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vRespawnCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility != 2)
	{
		g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_RESPAWN_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_RESPAWN_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_RESPAWN_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_RESPAWN_SECTION4);
	if (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_UPONDEATH && g_esRespawnCache[tank].g_iRespawnAbility > 0 && g_esRespawnCache[tank].g_iComboAbility == 1)
		{
			char sAbilities[320], sSubset[10][32];
			strcopy(sAbilities, sizeof sAbilities, combo);
			ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

			float flDelay = 0.0;
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_RESPAWN_SECTION, false) || StrEqual(sSubset[iPos], MT_RESPAWN_SECTION2, false) || StrEqual(sSubset[iPos], MT_RESPAWN_SECTION3, false) || StrEqual(sSubset[iPos], MT_RESPAWN_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						flDelay = MT_GetCombinationSetting(tank, 4, iPos);

						switch (flDelay)
						{
							case 0.0: vRespawn2(tank, true);
							default: CreateTimer(flDelay, tTimerRespawnCombo, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}
					}

					break;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnConfigsLoad(int mode)
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
				g_esRespawnAbility[iIndex].g_iAccessFlags = 0;
				g_esRespawnAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esRespawnAbility[iIndex].g_iComboAbility = 0;
				g_esRespawnAbility[iIndex].g_iComboPosition = -1;
				g_esRespawnAbility[iIndex].g_iHumanAbility = 0;
				g_esRespawnAbility[iIndex].g_iHumanAmmo = 5;
				g_esRespawnAbility[iIndex].g_iHumanCooldown = 0;
				g_esRespawnAbility[iIndex].g_iHumanDuration = 5;
				g_esRespawnAbility[iIndex].g_iHumanMode = 1;
				g_esRespawnAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esRespawnAbility[iIndex].g_iRequiresHumans = 0;
				g_esRespawnAbility[iIndex].g_iRespawnAbility = 0;
				g_esRespawnAbility[iIndex].g_iRespawnMessage = 0;
				g_esRespawnAbility[iIndex].g_iRespawnAmount = 1;
				g_esRespawnAbility[iIndex].g_flRespawnChance = 33.3;
				g_esRespawnAbility[iIndex].g_iRespawnCooldown = 0;
				g_esRespawnAbility[iIndex].g_iRespawnDuration = 0;
				g_esRespawnAbility[iIndex].g_iRespawnFilter = 0;
				g_esRespawnAbility[iIndex].g_iRespawnMaxType = 0;
				g_esRespawnAbility[iIndex].g_iRespawnMinType = 0;
				g_esRespawnAbility[iIndex].g_flRespawnRange = 500.0;
				g_esRespawnAbility[iIndex].g_iRespawnSight = 0;

				g_esRespawnSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esRespawnSpecial[iIndex].g_iComboAbility = -1;
				g_esRespawnSpecial[iIndex].g_iHumanAbility = -1;
				g_esRespawnSpecial[iIndex].g_iHumanAmmo = -1;
				g_esRespawnSpecial[iIndex].g_iHumanCooldown = -1;
				g_esRespawnSpecial[iIndex].g_iHumanDuration = -1;
				g_esRespawnSpecial[iIndex].g_iHumanMode = -1;
				g_esRespawnSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esRespawnSpecial[iIndex].g_iRequiresHumans = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnAbility = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnMessage = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnAmount = -1;
				g_esRespawnSpecial[iIndex].g_flRespawnChance = -1.0;
				g_esRespawnSpecial[iIndex].g_iRespawnCooldown = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnDuration = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnFilter = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnMaxType = -1;
				g_esRespawnSpecial[iIndex].g_iRespawnMinType = -1;
				g_esRespawnSpecial[iIndex].g_flRespawnRange = -1.0;
				g_esRespawnSpecial[iIndex].g_iRespawnSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esRespawnPlayer[iPlayer].g_iAccessFlags = -1;
				g_esRespawnPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRespawnPlayer[iPlayer].g_iComboAbility = -1;
				g_esRespawnPlayer[iPlayer].g_iHumanAbility = -1;
				g_esRespawnPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esRespawnPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esRespawnPlayer[iPlayer].g_iHumanDuration = -1;
				g_esRespawnPlayer[iPlayer].g_iHumanMode = -1;
				g_esRespawnPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRespawnPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnAbility = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnMessage = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnAmount = -1;
				g_esRespawnPlayer[iPlayer].g_flRespawnChance = -1.0;
				g_esRespawnPlayer[iPlayer].g_iRespawnCooldown = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnDuration = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnFilter = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnMaxType = -1;
				g_esRespawnPlayer[iPlayer].g_iRespawnMinType = -1;
				g_esRespawnPlayer[iPlayer].g_flRespawnRange = -1.0;
				g_esRespawnPlayer[iPlayer].g_iRespawnSight = -1;

				g_esRespawnTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRespawnTeammate[iPlayer].g_iComboAbility = -1;
				g_esRespawnTeammate[iPlayer].g_iHumanAbility = -1;
				g_esRespawnTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esRespawnTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esRespawnTeammate[iPlayer].g_iHumanDuration = -1;
				g_esRespawnTeammate[iPlayer].g_iHumanMode = -1;
				g_esRespawnTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRespawnTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnAbility = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnMessage = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnAmount = -1;
				g_esRespawnTeammate[iPlayer].g_flRespawnChance = -1.0;
				g_esRespawnTeammate[iPlayer].g_iRespawnCooldown = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnDuration = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnFilter = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnMaxType = -1;
				g_esRespawnTeammate[iPlayer].g_iRespawnMinType = -1;
				g_esRespawnTeammate[iPlayer].g_flRespawnRange = -1.0;
				g_esRespawnTeammate[iPlayer].g_iRespawnSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esRespawnTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRespawnTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRespawnTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRespawnTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esRespawnTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRespawnTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esRespawnTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRespawnTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRespawnTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRespawnTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRespawnTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRespawnTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esRespawnTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRespawnTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esRespawnTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRespawnTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRespawnTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRespawnTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esRespawnTeammate[admin].g_iRespawnAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRespawnTeammate[admin].g_iRespawnAbility, value, -1, 3);
			g_esRespawnTeammate[admin].g_iRespawnMessage = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRespawnTeammate[admin].g_iRespawnMessage, value, -1, 1);
			g_esRespawnTeammate[admin].g_iRespawnSight = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRespawnTeammate[admin].g_iRespawnSight, value, -1, 5);
			g_esRespawnTeammate[admin].g_iRespawnAmount = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esRespawnTeammate[admin].g_iRespawnAmount, value, -1, 99999);
			g_esRespawnTeammate[admin].g_flRespawnChance = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esRespawnTeammate[admin].g_flRespawnChance, value, -1.0, 100.0);
			g_esRespawnTeammate[admin].g_iRespawnCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnCooldown", "Respawn Cooldown", "Respawn_Cooldown", "cooldown", g_esRespawnTeammate[admin].g_iRespawnCooldown, value, -1, 99999);
			g_esRespawnTeammate[admin].g_iRespawnDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnDuration", "Respawn Duration", "Respawn_Duration", "duration", g_esRespawnTeammate[admin].g_iRespawnDuration, value, -1, 99999);
			g_esRespawnTeammate[admin].g_iRespawnFilter = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnFilter", "Respawn Filter", "Respawn_Filter", "filter", g_esRespawnTeammate[admin].g_iRespawnFilter, value, -1, 127);
			g_esRespawnTeammate[admin].g_flRespawnRange = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnRange", "Respawn Range", "Respawn_Range", "range", g_esRespawnTeammate[admin].g_flRespawnRange, value, -1.0, 99999.0);
		}
		else
		{
			g_esRespawnPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRespawnPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRespawnPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRespawnPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esRespawnPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRespawnPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esRespawnPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRespawnPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRespawnPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRespawnPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRespawnPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRespawnPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esRespawnPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRespawnPlayer[admin].g_iHumanMode, value, -1, 2);
			g_esRespawnPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRespawnPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRespawnPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRespawnPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esRespawnPlayer[admin].g_iRespawnAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRespawnPlayer[admin].g_iRespawnAbility, value, -1, 3);
			g_esRespawnPlayer[admin].g_iRespawnMessage = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRespawnPlayer[admin].g_iRespawnMessage, value, -1, 1);
			g_esRespawnPlayer[admin].g_iRespawnSight = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRespawnPlayer[admin].g_iRespawnSight, value, -1, 5);
			g_esRespawnPlayer[admin].g_iRespawnAmount = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esRespawnPlayer[admin].g_iRespawnAmount, value, -1, 99999);
			g_esRespawnPlayer[admin].g_flRespawnChance = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esRespawnPlayer[admin].g_flRespawnChance, value, -1.0, 100.0);
			g_esRespawnPlayer[admin].g_iRespawnCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnCooldown", "Respawn Cooldown", "Respawn_Cooldown", "cooldown", g_esRespawnPlayer[admin].g_iRespawnCooldown, value, -1, 99999);
			g_esRespawnPlayer[admin].g_iRespawnDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnDuration", "Respawn Duration", "Respawn_Duration", "duration", g_esRespawnPlayer[admin].g_iRespawnDuration, value, -1, 99999);
			g_esRespawnPlayer[admin].g_iRespawnFilter = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnFilter", "Respawn Filter", "Respawn_Filter", "filter", g_esRespawnPlayer[admin].g_iRespawnFilter, value, -1, 127);
			g_esRespawnPlayer[admin].g_flRespawnRange = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnRange", "Respawn Range", "Respawn_Range", "range", g_esRespawnPlayer[admin].g_flRespawnRange, value, -1.0, 99999.0);
			g_esRespawnPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}

		if (StrEqual(subsection, MT_RESPAWN_SECTION, false) || StrEqual(subsection, MT_RESPAWN_SECTION2, false) || StrEqual(subsection, MT_RESPAWN_SECTION3, false) || StrEqual(subsection, MT_RESPAWN_SECTION4, false))
		{
			if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				char sValue[10], sRange[2][5];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

				if (special && specsection[0] != '\0')
				{
					g_esRespawnTeammate[admin].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esRespawnTeammate[admin].g_iRespawnMinType;
					g_esRespawnTeammate[admin].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esRespawnTeammate[admin].g_iRespawnMaxType;
				}
				else
				{
					g_esRespawnPlayer[admin].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esRespawnPlayer[admin].g_iRespawnMinType;
					g_esRespawnPlayer[admin].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esRespawnPlayer[admin].g_iRespawnMaxType;
				}
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esRespawnSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRespawnSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRespawnSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRespawnSpecial[type].g_iComboAbility, value, -1, 1);
			g_esRespawnSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRespawnSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esRespawnSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRespawnSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esRespawnSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRespawnSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esRespawnSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRespawnSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esRespawnSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRespawnSpecial[type].g_iHumanMode, value, -1, 2);
			g_esRespawnSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRespawnSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRespawnSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRespawnSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esRespawnSpecial[type].g_iRespawnAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRespawnSpecial[type].g_iRespawnAbility, value, -1, 3);
			g_esRespawnSpecial[type].g_iRespawnMessage = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRespawnSpecial[type].g_iRespawnMessage, value, -1, 1);
			g_esRespawnSpecial[type].g_iRespawnSight = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRespawnSpecial[type].g_iRespawnSight, value, -1, 5);
			g_esRespawnSpecial[type].g_iRespawnAmount = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esRespawnSpecial[type].g_iRespawnAmount, value, -1, 99999);
			g_esRespawnSpecial[type].g_flRespawnChance = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esRespawnSpecial[type].g_flRespawnChance, value, -1.0, 100.0);
			g_esRespawnSpecial[type].g_iRespawnCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnCooldown", "Respawn Cooldown", "Respawn_Cooldown", "cooldown", g_esRespawnSpecial[type].g_iRespawnCooldown, value, -1, 99999);
			g_esRespawnSpecial[type].g_iRespawnDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnDuration", "Respawn Duration", "Respawn_Duration", "duration", g_esRespawnSpecial[type].g_iRespawnDuration, value, -1, 99999);
			g_esRespawnSpecial[type].g_iRespawnFilter = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnFilter", "Respawn Filter", "Respawn_Filter", "filter", g_esRespawnSpecial[type].g_iRespawnFilter, value, -1, 127);
			g_esRespawnSpecial[type].g_flRespawnRange = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnRange", "Respawn Range", "Respawn_Range", "range", g_esRespawnSpecial[type].g_flRespawnRange, value, -1.0, 99999.0);
		}
		else
		{
			g_esRespawnAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRespawnAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRespawnAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRespawnAbility[type].g_iComboAbility, value, -1, 1);
			g_esRespawnAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRespawnAbility[type].g_iHumanAbility, value, -1, 2);
			g_esRespawnAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRespawnAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esRespawnAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRespawnAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esRespawnAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRespawnAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esRespawnAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRespawnAbility[type].g_iHumanMode, value, -1, 2);
			g_esRespawnAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRespawnAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRespawnAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRespawnAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esRespawnAbility[type].g_iRespawnAbility = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRespawnAbility[type].g_iRespawnAbility, value, -1, 3);
			g_esRespawnAbility[type].g_iRespawnMessage = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRespawnAbility[type].g_iRespawnMessage, value, -1, 1);
			g_esRespawnAbility[type].g_iRespawnSight = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRespawnAbility[type].g_iRespawnSight, value, -1, 5);
			g_esRespawnAbility[type].g_iRespawnAmount = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esRespawnAbility[type].g_iRespawnAmount, value, -1, 99999);
			g_esRespawnAbility[type].g_flRespawnChance = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esRespawnAbility[type].g_flRespawnChance, value, -1.0, 100.0);
			g_esRespawnAbility[type].g_iRespawnCooldown = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnCooldown", "Respawn Cooldown", "Respawn_Cooldown", "cooldown", g_esRespawnAbility[type].g_iRespawnCooldown, value, -1, 99999);
			g_esRespawnAbility[type].g_iRespawnDuration = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnDuration", "Respawn Duration", "Respawn_Duration", "duration", g_esRespawnAbility[type].g_iRespawnDuration, value, -1, 99999);
			g_esRespawnAbility[type].g_iRespawnFilter = iGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnFilter", "Respawn Filter", "Respawn_Filter", "filter", g_esRespawnAbility[type].g_iRespawnFilter, value, -1, 127);
			g_esRespawnAbility[type].g_flRespawnRange = flGetKeyValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "RespawnRange", "Respawn Range", "Respawn_Range", "range", g_esRespawnAbility[type].g_flRespawnRange, value, -1.0, 99999.0);
			g_esRespawnAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_RESPAWN_SECTION, MT_RESPAWN_SECTION2, MT_RESPAWN_SECTION3, MT_RESPAWN_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}

		if (StrEqual(subsection, MT_RESPAWN_SECTION, false) || StrEqual(subsection, MT_RESPAWN_SECTION2, false) || StrEqual(subsection, MT_RESPAWN_SECTION3, false) || StrEqual(subsection, MT_RESPAWN_SECTION4, false))
		{
			if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				char sValue[10], sRange[2][5];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

				if (special && specsection[0] != '\0')
				{
					g_esRespawnSpecial[type].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esRespawnSpecial[type].g_iRespawnMinType;
					g_esRespawnSpecial[type].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esRespawnSpecial[type].g_iRespawnMaxType;
				}
				else
				{
					g_esRespawnAbility[type].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esRespawnAbility[type].g_iRespawnMinType;
					g_esRespawnAbility[type].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esRespawnAbility[type].g_iRespawnMaxType;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esRespawnPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esRespawnPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esRespawnPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esRespawnCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_flCloseAreasOnly, g_esRespawnPlayer[tank].g_flCloseAreasOnly, g_esRespawnSpecial[iType].g_flCloseAreasOnly, g_esRespawnAbility[iType].g_flCloseAreasOnly, 1);
		g_esRespawnCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iComboAbility, g_esRespawnPlayer[tank].g_iComboAbility, g_esRespawnSpecial[iType].g_iComboAbility, g_esRespawnAbility[iType].g_iComboAbility, 1);
		g_esRespawnCache[tank].g_flRespawnChance = flGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_flRespawnChance, g_esRespawnPlayer[tank].g_flRespawnChance, g_esRespawnSpecial[iType].g_flRespawnChance, g_esRespawnAbility[iType].g_flRespawnChance, 1);
		g_esRespawnCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iHumanAbility, g_esRespawnPlayer[tank].g_iHumanAbility, g_esRespawnSpecial[iType].g_iHumanAbility, g_esRespawnAbility[iType].g_iHumanAbility, 1);
		g_esRespawnCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iHumanAmmo, g_esRespawnPlayer[tank].g_iHumanAmmo, g_esRespawnSpecial[iType].g_iHumanAmmo, g_esRespawnAbility[iType].g_iHumanAmmo, 1);
		g_esRespawnCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iHumanCooldown, g_esRespawnPlayer[tank].g_iHumanCooldown, g_esRespawnSpecial[iType].g_iHumanCooldown, g_esRespawnAbility[iType].g_iHumanCooldown, 1);
		g_esRespawnCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iHumanDuration, g_esRespawnPlayer[tank].g_iHumanDuration, g_esRespawnSpecial[iType].g_iHumanDuration, g_esRespawnAbility[iType].g_iHumanDuration, 1);
		g_esRespawnCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iHumanMode, g_esRespawnPlayer[tank].g_iHumanMode, g_esRespawnSpecial[iType].g_iHumanMode, g_esRespawnAbility[iType].g_iHumanMode, 1);
		g_esRespawnCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_flOpenAreasOnly, g_esRespawnPlayer[tank].g_flOpenAreasOnly, g_esRespawnSpecial[iType].g_flOpenAreasOnly, g_esRespawnAbility[iType].g_flOpenAreasOnly, 1);
		g_esRespawnCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRequiresHumans, g_esRespawnPlayer[tank].g_iRequiresHumans, g_esRespawnSpecial[iType].g_iRequiresHumans, g_esRespawnAbility[iType].g_iRequiresHumans, 1);
		g_esRespawnCache[tank].g_iRespawnAbility = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnAbility, g_esRespawnPlayer[tank].g_iRespawnAbility, g_esRespawnSpecial[iType].g_iRespawnAbility, g_esRespawnAbility[iType].g_iRespawnAbility, 1);
		g_esRespawnCache[tank].g_iRespawnAmount = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnAmount, g_esRespawnPlayer[tank].g_iRespawnAmount, g_esRespawnSpecial[iType].g_iRespawnAmount, g_esRespawnAbility[iType].g_iRespawnAmount, 1);
		g_esRespawnCache[tank].g_iRespawnCooldown = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnCooldown, g_esRespawnPlayer[tank].g_iRespawnCooldown, g_esRespawnSpecial[iType].g_iRespawnCooldown, g_esRespawnAbility[iType].g_iRespawnCooldown, 1);
		g_esRespawnCache[tank].g_iRespawnDuration = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnDuration, g_esRespawnPlayer[tank].g_iRespawnDuration, g_esRespawnSpecial[iType].g_iRespawnDuration, g_esRespawnAbility[iType].g_iRespawnDuration, 1);
		g_esRespawnCache[tank].g_iRespawnFilter = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnFilter, g_esRespawnPlayer[tank].g_iRespawnFilter, g_esRespawnSpecial[iType].g_iRespawnFilter, g_esRespawnAbility[iType].g_iRespawnFilter, 1);
		g_esRespawnCache[tank].g_iRespawnMaxType = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnMaxType, g_esRespawnPlayer[tank].g_iRespawnMaxType, g_esRespawnSpecial[iType].g_iRespawnMaxType, g_esRespawnAbility[iType].g_iRespawnMaxType, 1);
		g_esRespawnCache[tank].g_iRespawnMinType = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnMinType, g_esRespawnPlayer[tank].g_iRespawnMinType, g_esRespawnSpecial[iType].g_iRespawnMinType, g_esRespawnAbility[iType].g_iRespawnMinType, 1);
		g_esRespawnCache[tank].g_iRespawnMessage = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnMessage, g_esRespawnPlayer[tank].g_iRespawnMessage, g_esRespawnSpecial[iType].g_iRespawnMessage, g_esRespawnAbility[iType].g_iRespawnMessage, 1);
		g_esRespawnCache[tank].g_iRespawnSight = iGetSubSettingValue(apply, bHuman, g_esRespawnTeammate[tank].g_iRespawnSight, g_esRespawnPlayer[tank].g_iRespawnSight, g_esRespawnSpecial[iType].g_iRespawnSight, g_esRespawnAbility[iType].g_iRespawnSight, 1);
	}
	else
	{
		g_esRespawnCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_flCloseAreasOnly, g_esRespawnAbility[iType].g_flCloseAreasOnly, 1);
		g_esRespawnCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iComboAbility, g_esRespawnAbility[iType].g_iComboAbility, 1);
		g_esRespawnCache[tank].g_flRespawnChance = flGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_flRespawnChance, g_esRespawnAbility[iType].g_flRespawnChance, 1);
		g_esRespawnCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iHumanAbility, g_esRespawnAbility[iType].g_iHumanAbility, 1);
		g_esRespawnCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iHumanAmmo, g_esRespawnAbility[iType].g_iHumanAmmo, 1);
		g_esRespawnCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iHumanCooldown, g_esRespawnAbility[iType].g_iHumanCooldown, 1);
		g_esRespawnCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iHumanDuration, g_esRespawnAbility[iType].g_iHumanDuration, 1);
		g_esRespawnCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iHumanMode, g_esRespawnAbility[iType].g_iHumanMode, 1);
		g_esRespawnCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_flOpenAreasOnly, g_esRespawnAbility[iType].g_flOpenAreasOnly, 1);
		g_esRespawnCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRequiresHumans, g_esRespawnAbility[iType].g_iRequiresHumans, 1);
		g_esRespawnCache[tank].g_iRespawnAbility = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnAbility, g_esRespawnAbility[iType].g_iRespawnAbility, 1);
		g_esRespawnCache[tank].g_iRespawnAmount = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnAmount, g_esRespawnAbility[iType].g_iRespawnAmount, 1);
		g_esRespawnCache[tank].g_iRespawnCooldown = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnCooldown, g_esRespawnAbility[iType].g_iRespawnCooldown, 1);
		g_esRespawnCache[tank].g_iRespawnDuration = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnDuration, g_esRespawnAbility[iType].g_iRespawnDuration, 1);
		g_esRespawnCache[tank].g_iRespawnFilter = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnFilter, g_esRespawnAbility[iType].g_iRespawnFilter, 1);
		g_esRespawnCache[tank].g_iRespawnMaxType = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnMaxType, g_esRespawnAbility[iType].g_iRespawnMaxType, 1);
		g_esRespawnCache[tank].g_iRespawnMinType = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnMinType, g_esRespawnAbility[iType].g_iRespawnMinType, 1);
		g_esRespawnCache[tank].g_iRespawnMessage = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnMessage, g_esRespawnAbility[iType].g_iRespawnMessage, 1);
		g_esRespawnCache[tank].g_iRespawnSight = iGetSettingValue(apply, bHuman, g_esRespawnPlayer[tank].g_iRespawnSight, g_esRespawnAbility[iType].g_iRespawnSight, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vRespawnCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRespawn(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vRespawnEventFired(Event event, const char[] name)
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
			vRespawnCopyStats2(iBot, iTank);
			vRemoveRespawn(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vRespawnReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vRespawnCopyStats2(iTank, iBot);
			vRemoveRespawn(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRespawn(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnPlayerEventKilled(int victim)
#else
public void MT_OnPlayerEventKilled(int victim, int attacker)
#endif
{
	if (bIsSpecialInfected(victim, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		bool bRandom = false;
		float flInfectedPos[3], flTankPos[3], flRange = 0.0;
		int iPos = -1, iClass = 0, iFilter = 0, iTime = GetTime();
		GetClientAbsOrigin(victim, flInfectedPos);
		for (int iTank = 1; iTank <= MaxClients; iTank++)
		{
			if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && g_esRespawnPlayer[iTank].g_bActivated2 && iTank != victim)
			{
				if ((g_esRespawnPlayer[iTank].g_iCooldown != -1 && g_esRespawnPlayer[iTank].g_iCooldown >= iTime) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRespawnAbility[g_esRespawnPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[iTank].g_iAccessFlags)))
				{
					continue;
				}

				iPos = g_esRespawnAbility[g_esRespawnPlayer[iTank].g_iTankTypeRecorded].g_iComboPosition;
				bRandom = (iPos != -1) ? true : GetRandomFloat(0.1, 100.0) <= g_esRespawnCache[iTank].g_flRespawnChance;
				if ((g_esRespawnCache[iTank].g_iRespawnAbility == 1 || g_esRespawnCache[iTank].g_iRespawnAbility == 3) && bRandom)
				{
					flRange = (iPos != -1) ? MT_GetCombinationSetting(iTank, 9, iPos) : g_esRespawnCache[iTank].g_flRespawnRange;
					GetClientAbsOrigin(iTank, flTankPos);
					if (GetVectorDistance(flInfectedPos, flTankPos) <= flRange && bIsVisibleToPlayer(iTank, victim, g_esRespawnCache[iTank].g_iRespawnSight, .range = flRange))
					{
						iClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
						iFilter = g_esRespawnCache[iTank].g_iRespawnFilter;
						if (iFilter == 0 || (iFilter & (1 << (iClass - 1))))
						{
							switch (iClass)
							{
								case 1: vRespawn(iTank, flInfectedPos, "smoker");
								case 2: vRespawn(iTank, flInfectedPos, "boomer");
								case 3: vRespawn(iTank, flInfectedPos, "hunter");
								case 4: vRespawn(iTank, flInfectedPos, (g_bSecondGame ? "spitter" : "boomer"));
								case 5: vRespawn(iTank, flInfectedPos, (g_bSecondGame ? "jockey" : "hunter"));
								case 6: vRespawn(iTank, flInfectedPos, (g_bSecondGame ? "charger" : "smoker"));
							}
						}
					}
				}

				break;
			}
		}
	}
	else if (MT_IsTankSupported(victim, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(victim) && (g_esRespawnCache[victim].g_iRespawnAbility == 2 || g_esRespawnCache[victim].g_iRespawnAbility == 3) && g_esRespawnCache[victim].g_iComboAbility == 0 && GetRandomFloat(0.1, 100.0) <= g_esRespawnCache[victim].g_flRespawnChance)
	{
		vRespawn2(victim, false);
	}
}

#if defined MT_ABILITIES_MAIN2
Action aRespawnRewardSurvivor(int tank, int priority, bool apply)
#else
public Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply)
#endif
{
	if (apply && bIsValidClient(tank, MT_CHECK_INDEX) && g_esRespawnPlayer[tank].g_bRespawning[priority])
	{
		g_esRespawnPlayer[tank].g_bRespawning[priority] = false;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vRespawnAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[tank].g_iAccessFlags)) || g_esRespawnCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esRespawnCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && (g_esRespawnCache[tank].g_iRespawnAbility == 1 || g_esRespawnCache[tank].g_iRespawnAbility == 3) && g_esRespawnCache[tank].g_iComboAbility == 0 && !g_esRespawnPlayer[tank].g_bActivated2)
	{
		vRespawnAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esRespawnCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRespawnCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRespawnPlayer[tank].g_iTankType, tank) || (g_esRespawnCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRespawnCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && (g_esRespawnCache[tank].g_iRespawnAbility == 1 || g_esRespawnCache[tank].g_iRespawnAbility == 3) && g_esRespawnCache[tank].g_iHumanAbility == 1)
		{
			int iHumanMode = g_esRespawnCache[tank].g_iHumanMode, iTime = GetTime();
			bool bRecharging = g_esRespawnPlayer[tank].g_iCooldown != -1 && g_esRespawnPlayer[tank].g_iCooldown >= iTime;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esRespawnPlayer[tank].g_bActivated && !bRecharging)
					{
						vRespawnAbility(tank);
					}
					else if (g_esRespawnPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman4", (g_esRespawnPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esRespawnPlayer[tank].g_bActivated) || (g_esRespawnPlayer[tank].g_iAmmoCount < g_esRespawnCache[tank].g_iHumanAmmo && g_esRespawnCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esRespawnPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esRespawnPlayer[tank].g_bActivated = true;
							g_esRespawnPlayer[tank].g_iAmmoCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman", g_esRespawnPlayer[tank].g_iAmmoCount, g_esRespawnCache[tank].g_iHumanAmmo);
						}
						else if (g_esRespawnPlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman3");
								case 2: vRespawnReset2(tank);
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman4", (g_esRespawnPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
					}
				}
			}
		}

		if ((button & MT_SPECIAL_KEY2) && (g_esRespawnCache[tank].g_iRespawnAbility == 2 || g_esRespawnCache[tank].g_iRespawnAbility == 3) && g_esRespawnCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esRespawnPlayer[tank].g_bActivated2)
			{
				case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman7");
				case false:
				{
					switch (g_esRespawnPlayer[tank].g_iAmmoCount2 < g_esRespawnCache[tank].g_iHumanAmmo && g_esRespawnCache[tank].g_iHumanAmmo > 0)
					{
						case true:
						{
							g_esRespawnPlayer[tank].g_bActivated2 = true;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman6");
						}
						case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo2");
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esRespawnCache[tank].g_iHumanMode == 1 && g_esRespawnPlayer[tank].g_bActivated && (g_esRespawnPlayer[tank].g_iCooldown == -1 || g_esRespawnPlayer[tank].g_iCooldown <= GetTime()))
		{
			vRespawnReset2(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRespawnChangeType(int tank, int oldType, bool revert)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveRespawn(tank, revert);
}

void vRespawn(int tank, float pos[3], const char[] type)
{
	if (bIsAreaNarrow(tank, g_esRespawnCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRespawnCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRespawnPlayer[tank].g_iTankType, tank) || (g_esRespawnCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRespawnCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	bool[] bExists = new bool[MaxClients + 1];
	for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
	{
		bExists[iSpecial] = false;
		if (bIsSpecialInfected(iSpecial, MT_CHECK_INGAME))
		{
			bExists[iSpecial] = true;
		}
	}

	vCheatCommand(tank, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), type);

	int iInfected = 0;
	for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
	{
		if (bIsSpecialInfected(iSpecial, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bExists[iSpecial])
		{
			iInfected = iSpecial;

			break;
		}
	}

	if (bIsSpecialInfected(iInfected))
	{
		TeleportEntity(iInfected, pos);
		EmitSoundToAll(SOUND_ELECTRICITY, iInfected);

		if (g_iGraphicsLevel > 2)
		{
			vAttachParticle(iInfected, PARTICLE_ELECTRICITY, 1.0);
		}

		if (g_esRespawnCache[tank].g_iRespawnMessage == 1)
		{
			char sTankName[64];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Respawn2", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Respawn2", LANG_SERVER, sTankName);
		}
	}
}

void vRespawn2(int tank, bool both)
{
	if (both)
	{
		g_esRespawnPlayer[tank].g_bActivated = true;
	}

	if (bIsAreaNarrow(tank, g_esRespawnCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRespawnCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRespawnPlayer[tank].g_iTankType, tank) || (g_esRespawnCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRespawnCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1 && !g_esRespawnPlayer[tank].g_bActivated2)
	{
		g_esRespawnPlayer[tank].g_bActivated2 = false;
		g_esRespawnPlayer[tank].g_iCount = 0;

		return;
	}

	if (g_esRespawnPlayer[tank].g_iCount < g_esRespawnCache[tank].g_iRespawnAmount && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRespawnPlayer[tank].g_iAmmoCount2 < g_esRespawnCache[tank].g_iHumanAmmo && g_esRespawnCache[tank].g_iHumanAmmo > 0)))
	{
		g_esRespawnPlayer[tank].g_bActivated2 = false;
		g_esRespawnPlayer[tank].g_bRespawning[0] = true;
		g_esRespawnPlayer[tank].g_bRespawning[1] = true;
		g_esRespawnPlayer[tank].g_bRespawning[2] = true;
		g_esRespawnPlayer[tank].g_bRespawning[3] = true;
		g_esRespawnPlayer[tank].g_iCount++;

		if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
		{
			g_esRespawnPlayer[tank].g_iAmmoCount2++;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman8", g_esRespawnPlayer[tank].g_iAmmoCount2, g_esRespawnCache[tank].g_iHumanAmmo);
		}

		bool[] bExists = new bool[MaxClients + 1];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			bExists[iPlayer] = false;
			if (bIsInfected(iPlayer, MT_CHECK_INGAME))
			{
				bExists[iPlayer] = true;
			}
		}

		switch (g_esRespawnCache[tank].g_iRespawnMinType == 0 || g_esRespawnCache[tank].g_iRespawnMaxType == 0)
		{
			case true: vRespawn3(tank);
			case false: vRespawn3(tank, g_esRespawnCache[tank].g_iRespawnMinType, g_esRespawnCache[tank].g_iRespawnMaxType);
		}

		int iTank = 0;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bExists[iPlayer] && iPlayer != tank)
			{
				iTank = iPlayer;
				g_esRespawnPlayer[iTank].g_bActivated2 = false;
				g_esRespawnPlayer[iTank].g_iAmmoCount2 = g_esRespawnPlayer[tank].g_iAmmoCount2;
				g_esRespawnPlayer[iTank].g_iCount = g_esRespawnPlayer[tank].g_iCount;

				vRemoveRespawn(tank);

				break;
			}
		}

		if (bIsInfected(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			float flPos[3], flAngles[3];
			GetClientAbsOrigin(tank, flPos);
			GetClientEyeAngles(tank, flAngles);
			TeleportEntity(iTank, flPos, flAngles);

			if (g_esRespawnCache[tank].g_iRespawnMessage == 1)
			{
				char sTankName[64];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Respawn", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Respawn", LANG_SERVER, sTankName);
			}
		}
		else
		{
			vRemoveRespawn(tank);
		}
	}
	else
	{
		vRemoveRespawn(tank);

		if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo2");
		}
	}
}

void vRespawn3(int tank, int min = 0, int max = 0)
{
	int iMin = (min > 0) ? min : MT_GetMinType(),
		iMax = (max > 0) ? max : MT_GetMaxType(),
		iSpecType = iGetInfectedType(tank),
		iTypeCount = 0, iTankTypes[MT_MAXTYPES + 1];

	for (int iIndex = iMin; iIndex <= iMax; iIndex++)
	{
		if (!MT_IsTypeEnabled(iIndex, tank) || !MT_CanTypeSpawn(iIndex, iSpecType) || MT_DoesTypeRequireHumans(iIndex, tank))
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	int iType = (iTypeCount > 0) ? iTankTypes[MT_GetRandomInt(1, iTypeCount)] : g_esRespawnPlayer[tank].g_iTankType;
	MT_SpawnTank(tank, iType, iSpecType);
	EmitSoundToAll(SOUND_CHARGE, tank);
}

void vRespawnAbility(int tank)
{
	int iTime = GetTime();
	if ((g_esRespawnPlayer[tank].g_iCooldown != -1 && g_esRespawnPlayer[tank].g_iCooldown >= iTime) || bIsAreaNarrow(tank, g_esRespawnCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRespawnCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRespawnPlayer[tank].g_iTankType, tank) || (g_esRespawnCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRespawnCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRespawnPlayer[tank].g_iAmmoCount < g_esRespawnCache[tank].g_iHumanAmmo && g_esRespawnCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esRespawnCache[tank].g_flRespawnChance)
		{
			g_esRespawnPlayer[tank].g_bActivated = true;

			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
			{
				int iPos = g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 5, iPos)) : g_esRespawnCache[tank].g_iRespawnDuration;
				iDuration = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1) ? g_esRespawnCache[tank].g_iHumanDuration : iDuration;
				g_esRespawnPlayer[tank].g_iAmmoCount++;
				g_esRespawnPlayer[tank].g_iDuration = (iTime + iDuration);

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman", g_esRespawnPlayer[tank].g_iAmmoCount, g_esRespawnCache[tank].g_iHumanAmmo);
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman2");
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
	}
}

void vRespawnCopyStats2(int oldTank, int newTank)
{
	g_esRespawnPlayer[newTank].g_bActivated2 = g_esRespawnPlayer[oldTank].g_bActivated2;
	g_esRespawnPlayer[newTank].g_iAmmoCount = g_esRespawnPlayer[oldTank].g_iAmmoCount;
	g_esRespawnPlayer[newTank].g_iAmmoCount2 = g_esRespawnPlayer[oldTank].g_iAmmoCount2;
	g_esRespawnPlayer[newTank].g_iCooldown = g_esRespawnPlayer[oldTank].g_iCooldown;
	g_esRespawnPlayer[newTank].g_iCount = g_esRespawnPlayer[oldTank].g_iCount;
}

void vRemoveRespawn(int tank, bool revert = true)
{
	g_esRespawnPlayer[tank].g_bActivated = false;
	g_esRespawnPlayer[tank].g_bActivated2 = false;
	g_esRespawnPlayer[tank].g_iAmmoCount = 0;
	g_esRespawnPlayer[tank].g_iCooldown = -1;
	g_esRespawnPlayer[tank].g_iDuration = -1;

	if (revert)
	{
		g_esRespawnPlayer[tank].g_iAmmoCount2 = 0;
		g_esRespawnPlayer[tank].g_iCount = 0;
	}
}

void vRespawnReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRespawn(iPlayer);
		}
	}
}

void vRespawnReset2(int tank)
{
	g_esRespawnPlayer[tank].g_bActivated = false;

	int iTime = GetTime(), iPos = g_esRespawnAbility[g_esRespawnPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esRespawnCache[tank].g_iRespawnCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRespawnCache[tank].g_iHumanAbility == 1 && g_esRespawnCache[tank].g_iHumanMode == 0 && g_esRespawnPlayer[tank].g_iAmmoCount < g_esRespawnCache[tank].g_iHumanAmmo && g_esRespawnCache[tank].g_iHumanAmmo > 0) ? g_esRespawnCache[tank].g_iHumanCooldown : iCooldown;
	g_esRespawnPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esRespawnPlayer[tank].g_iCooldown != -1 && g_esRespawnPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman5", (g_esRespawnPlayer[tank].g_iCooldown - iTime));
	}
}

Action tTimerRespawnCombo(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRespawnAbility[g_esRespawnPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRespawnPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRespawnPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esRespawnCache[iTank].g_iRespawnAbility == 0)
	{
		return Plugin_Stop;
	}

	vRespawn2(iTank, true);

	return Plugin_Continue;
}