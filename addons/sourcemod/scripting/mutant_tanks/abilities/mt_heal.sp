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

#define MT_HEAL_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_HEAL_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Heal Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Heal Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_HEARTBEAT "player/heartbeatloop.wav"
#else
	#if MT_HEAL_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_HEAL_SECTION "healability"
#define MT_HEAL_SECTION2 "heal ability"
#define MT_HEAL_SECTION3 "heal_ability"
#define MT_HEAL_SECTION4 "heal"

#define MT_MENU_HEAL "Heal Ability"

enum struct esHealPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealCooldown;
	int g_iHealDuration;
	int g_iHealEffect;
	int g_iHealGlow;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealRangeCooldown;
	int g_iHealSight;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esHealPlayer g_esHealPlayer[MAXPLAYERS + 1];

enum struct esHealTeammate
{
	float g_flCloseAreasOnly;
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealCooldown;
	int g_iHealDuration;
	int g_iHealEffect;
	int g_iHealGlow;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealRangeCooldown;
	int g_iHealSight;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esHealTeammate g_esHealTeammate[MAXPLAYERS + 1];

enum struct esHealAbility
{
	float g_flCloseAreasOnly;
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealCooldown;
	int g_iHealDuration;
	int g_iHealEffect;
	int g_iHealGlow;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealRangeCooldown;
	int g_iHealSight;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esHealAbility g_esHealAbility[MT_MAXTYPES + 1];

enum struct esHealSpecial
{
	float g_flCloseAreasOnly;
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealCooldown;
	int g_iHealDuration;
	int g_iHealEffect;
	int g_iHealGlow;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealRangeCooldown;
	int g_iHealSight;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esHealSpecial g_esHealSpecial[MT_MAXTYPES + 1];

enum struct esHealCache
{
	float g_flCloseAreasOnly;
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealCooldown;
	int g_iHealDuration;
	int g_iHealEffect;
	int g_iHealGlow;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealRangeCooldown;
	int g_iHealSight;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esHealCache g_esHealCache[MAXPLAYERS + 1];

ConVar g_cvMTMaxIncapCount;

#if defined MT_ABILITIES_MAIN
void vHealPluginStart()
#else
public void OnPluginStart()
#endif
{
	g_cvMTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");
#if !defined MT_ABILITIES_MAIN
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_heal", cmdHealInfo, "View information about the Heal ability.");

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
#endif
}

#if defined MT_ABILITIES_MAIN
void vHealMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_HEARTBEAT, true);

	vHealReset();
}

#if defined MT_ABILITIES_MAIN
void vHealClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnHealTakeDamage);
	vRemoveHeal(client);
}

#if defined MT_ABILITIES_MAIN
void vHealClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveHeal(client);
}

#if defined MT_ABILITIES_MAIN
void vHealMapEnd()
#else
public void OnMapEnd()
#endif
{
	vHealReset();
}

#if defined MT_ABILITIES_MAIN
void vHealPluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsInfected(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vHealResetGlow(iTank);
		}
	}
}

#if !defined MT_ABILITIES_MAIN
Action cmdHealInfo(int client, int args)
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
		case false: vHealMenu(client, MT_HEAL_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vHealMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_HEAL_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iHealMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Heal Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iHealMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHealCache[param1].g_iHealAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esHealCache[param1].g_iHumanAmmo - g_esHealPlayer[param1].g_iAmmoCount), g_esHealCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esHealCache[param1].g_iHumanAmmo - g_esHealPlayer[param1].g_iAmmoCount2), g_esHealCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3:
				{
					switch (g_esHealCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esHealCache[param1].g_iHumanAbility == 1) ? g_esHealCache[param1].g_iHumanCooldown : g_esHealCache[param1].g_iHealCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HealDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esHealCache[param1].g_iHumanAbility == 1) ? g_esHealCache[param1].g_iHumanDuration : g_esHealCache[param1].g_iHealDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHealCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 8: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esHealCache[param1].g_iHumanAbility == 1) ? g_esHealCache[param1].g_iHumanRangeCooldown : g_esHealCache[param1].g_iHealRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vHealMenu(param1, MT_HEAL_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pHeal = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "HealMenu", param1);
			pHeal.SetTitle(sMenuTitle);
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
					case 8: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vHealDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_HEAL, MT_MENU_HEAL);
}

#if defined MT_ABILITIES_MAIN
void vHealMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_HEAL, false))
	{
		vHealMenu(client, MT_HEAL_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vHealMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_HEAL, false))
	{
		FormatEx(buffer, size, "%T", "HealMenu2", client);
	}
}

Action OnHealTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esHealCache[attacker].g_iHealHitMode == 0 || g_esHealCache[attacker].g_iHealHitMode == 1) && bIsSurvivor(victim) && g_esHealCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esHealAbility[g_esHealPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esHealPlayer[attacker].g_iTankType, g_esHealAbility[g_esHealPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esHealPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esHealCache[attacker].g_flHealChance, g_esHealCache[attacker].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esHealCache[victim].g_iHealHitMode == 0 || g_esHealCache[victim].g_iHealHitMode == 2) && bIsSurvivor(attacker) && g_esHealCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esHealAbility[g_esHealPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esHealPlayer[victim].g_iTankType, g_esHealAbility[g_esHealPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esHealPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vHealHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esHealCache[victim].g_flHealChance, g_esHealCache[victim].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vHealPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_HEAL);
}

#if defined MT_ABILITIES_MAIN
void vHealAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_HEAL_SECTION);
	list2.PushString(MT_HEAL_SECTION2);
	list3.PushString(MT_HEAL_SECTION3);
	list4.PushString(MT_HEAL_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vHealCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility != 2)
	{
		g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_HEAL_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_HEAL_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_HEAL_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_HEAL_SECTION4);
	if (g_esHealCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_HEAL_SECTION, false) || StrEqual(sSubset[iPos], MT_HEAL_SECTION2, false) || StrEqual(sSubset[iPos], MT_HEAL_SECTION3, false) || StrEqual(sSubset[iPos], MT_HEAL_SECTION4, false))
			{
				g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esHealCache[tank].g_iHealAbility == 1 || g_esHealCache[tank].g_iHealAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vHealAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerHealCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}

						if (g_esHealCache[tank].g_iHealAbility == 2 || g_esHealCache[tank].g_iHealAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vHealAbility(tank, false, .pos = iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerHealCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esHealCache[tank].g_iHealHitMode == 0 || g_esHealCache[tank].g_iHealHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vHealHit(survivor, tank, random, flChance, g_esHealCache[tank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esHealCache[tank].g_iHealHitMode == 0 || g_esHealCache[tank].g_iHealHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vHealHit(survivor, tank, random, flChance, g_esHealCache[tank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerHealCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteString(classname);
							}
						}
					}
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealConfigsLoad(int mode)
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
				g_esHealAbility[iIndex].g_iAccessFlags = 0;
				g_esHealAbility[iIndex].g_iImmunityFlags = 0;
				g_esHealAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esHealAbility[iIndex].g_iComboAbility = 0;
				g_esHealAbility[iIndex].g_iComboPosition = -1;
				g_esHealAbility[iIndex].g_iHumanAbility = 0;
				g_esHealAbility[iIndex].g_iHumanAmmo = 5;
				g_esHealAbility[iIndex].g_iHumanCooldown = 0;
				g_esHealAbility[iIndex].g_iHumanDuration = 5;
				g_esHealAbility[iIndex].g_iHumanMode = 1;
				g_esHealAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esHealAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esHealAbility[iIndex].g_iRequiresHumans = 0;
				g_esHealAbility[iIndex].g_iHealAbility = 0;
				g_esHealAbility[iIndex].g_iHealEffect = 0;
				g_esHealAbility[iIndex].g_iHealMessage = 0;
				g_esHealAbility[iIndex].g_flHealAbsorbRange = 500.0;
				g_esHealAbility[iIndex].g_flHealBuffer = 100.0;
				g_esHealAbility[iIndex].g_flHealChance = 33.3;
				g_esHealAbility[iIndex].g_iHealCooldown = 0;
				g_esHealAbility[iIndex].g_iHealDuration = 0;
				g_esHealAbility[iIndex].g_iHealHit = 0;
				g_esHealAbility[iIndex].g_iHealHitMode = 0;
				g_esHealAbility[iIndex].g_flHealInterval = 5.0;
				g_esHealAbility[iIndex].g_flHealRange = 150.0;
				g_esHealAbility[iIndex].g_flHealRangeChance = 15.0;
				g_esHealAbility[iIndex].g_iHealRangeCooldown = 0;
				g_esHealAbility[iIndex].g_iHealSight = 0;
				g_esHealAbility[iIndex].g_iHealCommon = 50;
				g_esHealAbility[iIndex].g_iHealGlow = 1;
				g_esHealAbility[iIndex].g_iHealSpecial = 100;
				g_esHealAbility[iIndex].g_iHealTank = 500;

				g_esHealSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esHealSpecial[iIndex].g_iComboAbility = -1;
				g_esHealSpecial[iIndex].g_iHumanAbility = -1;
				g_esHealSpecial[iIndex].g_iHumanAmmo = -1;
				g_esHealSpecial[iIndex].g_iHumanCooldown = -1;
				g_esHealSpecial[iIndex].g_iHumanDuration = -1;
				g_esHealSpecial[iIndex].g_iHumanMode = -1;
				g_esHealSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esHealSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esHealSpecial[iIndex].g_iRequiresHumans = -1;
				g_esHealSpecial[iIndex].g_iHealAbility = -1;
				g_esHealSpecial[iIndex].g_iHealEffect = -1;
				g_esHealSpecial[iIndex].g_iHealMessage = -1;
				g_esHealSpecial[iIndex].g_flHealAbsorbRange = -1.0;
				g_esHealSpecial[iIndex].g_flHealBuffer = -1.0;
				g_esHealSpecial[iIndex].g_flHealChance = -1.0;
				g_esHealSpecial[iIndex].g_iHealCooldown = -1;
				g_esHealSpecial[iIndex].g_iHealDuration = -1;
				g_esHealSpecial[iIndex].g_iHealHit = -1;
				g_esHealSpecial[iIndex].g_iHealHitMode = -1;
				g_esHealSpecial[iIndex].g_flHealInterval = -1.0;
				g_esHealSpecial[iIndex].g_flHealRange = -1.0;
				g_esHealSpecial[iIndex].g_flHealRangeChance = -1.0;
				g_esHealSpecial[iIndex].g_iHealRangeCooldown = -1;
				g_esHealSpecial[iIndex].g_iHealSight = -1;
				g_esHealSpecial[iIndex].g_iHealCommon = -1;
				g_esHealSpecial[iIndex].g_iHealGlow = -1;
				g_esHealSpecial[iIndex].g_iHealSpecial = -1;
				g_esHealSpecial[iIndex].g_iHealTank = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esHealPlayer[iPlayer].g_iAccessFlags = -1;
				g_esHealPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esHealPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHealPlayer[iPlayer].g_iComboAbility = -1;
				g_esHealPlayer[iPlayer].g_iHumanAbility = -1;
				g_esHealPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esHealPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esHealPlayer[iPlayer].g_iHumanDuration = -1;
				g_esHealPlayer[iPlayer].g_iHumanMode = -1;
				g_esHealPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHealPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHealPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esHealPlayer[iPlayer].g_iHealAbility = -1;
				g_esHealPlayer[iPlayer].g_iHealEffect = -1;
				g_esHealPlayer[iPlayer].g_iHealMessage = -1;
				g_esHealPlayer[iPlayer].g_flHealAbsorbRange = -1.0;
				g_esHealPlayer[iPlayer].g_flHealBuffer = -1.0;
				g_esHealPlayer[iPlayer].g_flHealChance = -1.0;
				g_esHealPlayer[iPlayer].g_iHealCooldown = -1;
				g_esHealPlayer[iPlayer].g_iHealDuration = -1;
				g_esHealPlayer[iPlayer].g_iHealHit = -1;
				g_esHealPlayer[iPlayer].g_iHealHitMode = -1;
				g_esHealPlayer[iPlayer].g_flHealInterval = -1.0;
				g_esHealPlayer[iPlayer].g_flHealRange = -1.0;
				g_esHealPlayer[iPlayer].g_flHealRangeChance = -1.0;
				g_esHealPlayer[iPlayer].g_iHealRangeCooldown = -1;
				g_esHealPlayer[iPlayer].g_iHealSight = -1;
				g_esHealPlayer[iPlayer].g_iHealCommon = -1;
				g_esHealPlayer[iPlayer].g_iHealGlow = -1;
				g_esHealPlayer[iPlayer].g_iHealSpecial = -1;
				g_esHealPlayer[iPlayer].g_iHealTank = -1;

				g_esHealTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHealTeammate[iPlayer].g_iComboAbility = -1;
				g_esHealTeammate[iPlayer].g_iHumanAbility = -1;
				g_esHealTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esHealTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esHealTeammate[iPlayer].g_iHumanDuration = -1;
				g_esHealTeammate[iPlayer].g_iHumanMode = -1;
				g_esHealTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHealTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHealTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esHealTeammate[iPlayer].g_iHealAbility = -1;
				g_esHealTeammate[iPlayer].g_iHealEffect = -1;
				g_esHealTeammate[iPlayer].g_iHealMessage = -1;
				g_esHealTeammate[iPlayer].g_flHealAbsorbRange = -1.0;
				g_esHealTeammate[iPlayer].g_flHealBuffer = -1.0;
				g_esHealTeammate[iPlayer].g_flHealChance = -1.0;
				g_esHealTeammate[iPlayer].g_iHealCooldown = -1;
				g_esHealTeammate[iPlayer].g_iHealDuration = -1;
				g_esHealTeammate[iPlayer].g_iHealHit = -1;
				g_esHealTeammate[iPlayer].g_iHealHitMode = -1;
				g_esHealTeammate[iPlayer].g_flHealInterval = -1.0;
				g_esHealTeammate[iPlayer].g_flHealRange = -1.0;
				g_esHealTeammate[iPlayer].g_flHealRangeChance = -1.0;
				g_esHealTeammate[iPlayer].g_iHealRangeCooldown = -1;
				g_esHealTeammate[iPlayer].g_iHealSight = -1;
				g_esHealTeammate[iPlayer].g_iHealCommon = -1;
				g_esHealTeammate[iPlayer].g_iHealGlow = -1;
				g_esHealTeammate[iPlayer].g_iHealSpecial = -1;
				g_esHealTeammate[iPlayer].g_iHealTank = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esHealTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHealTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHealTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHealTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esHealTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHealTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esHealTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHealTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHealTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHealTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHealTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esHealTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esHealTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esHealTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esHealTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHealTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHealTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHealTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHealTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHealTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esHealTeammate[admin].g_iHealAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHealTeammate[admin].g_iHealAbility, value, -1, 3);
			g_esHealTeammate[admin].g_iHealEffect = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHealTeammate[admin].g_iHealEffect, value, -1, 7);
			g_esHealTeammate[admin].g_iHealMessage = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHealTeammate[admin].g_iHealMessage, value, -1, 7);
			g_esHealTeammate[admin].g_iHealSight = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHealTeammate[admin].g_iHealSight, value, -1, 5);
			g_esHealTeammate[admin].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esHealTeammate[admin].g_flHealAbsorbRange, value, -1.0, 99999.0);
			g_esHealTeammate[admin].g_flHealBuffer = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esHealTeammate[admin].g_flHealBuffer, value, -1.0, float(MT_MAXHEALTH));
			g_esHealTeammate[admin].g_flHealChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esHealTeammate[admin].g_flHealChance, value, -1.0, 100.0);
			g_esHealTeammate[admin].g_iHealCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealCooldown", "Heal Cooldown", "Heal_Cooldown", "cooldown", g_esHealTeammate[admin].g_iHealCooldown, value, -1, 99999);
			g_esHealTeammate[admin].g_iHealDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealDuration", "Heal Duration", "Heal_Duration", "duration", g_esHealTeammate[admin].g_iHealDuration, value, -1, 99999);
			g_esHealTeammate[admin].g_iHealHit = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esHealTeammate[admin].g_iHealHit, value, -1, 1);
			g_esHealTeammate[admin].g_iHealHitMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esHealTeammate[admin].g_iHealHitMode, value, -1, 2);
			g_esHealTeammate[admin].g_flHealInterval = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esHealTeammate[admin].g_flHealInterval, value, -1.0, 99999.0);
			g_esHealTeammate[admin].g_flHealRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esHealTeammate[admin].g_flHealRange, value, -1.0, 99999.0);
			g_esHealTeammate[admin].g_flHealRangeChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esHealTeammate[admin].g_flHealRangeChance, value, -1.0, 100.0);
			g_esHealTeammate[admin].g_iHealRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeCooldown", "Heal Range Cooldown", "Heal_Range_Cooldown", "rangecooldown", g_esHealTeammate[admin].g_iHealRangeCooldown, value, -1, 99999);
			g_esHealTeammate[admin].g_iHealCommon = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esHealTeammate[admin].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealTeammate[admin].g_iHealGlow = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealGlow", "Heal Glow", "Heal_Glow", "glow", g_esHealTeammate[admin].g_iHealGlow, value, -1, 1);
			g_esHealTeammate[admin].g_iHealSpecial = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esHealTeammate[admin].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealTeammate[admin].g_iHealTank = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esHealTeammate[admin].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		}
		else
		{
			g_esHealPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHealPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHealPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHealPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esHealPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHealPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esHealPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHealPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHealPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHealPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHealPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esHealPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esHealPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esHealPlayer[admin].g_iHumanMode, value, -1, 2);
			g_esHealPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHealPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHealPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHealPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHealPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHealPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esHealPlayer[admin].g_iHealAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHealPlayer[admin].g_iHealAbility, value, -1, 3);
			g_esHealPlayer[admin].g_iHealEffect = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHealPlayer[admin].g_iHealEffect, value, -1, 7);
			g_esHealPlayer[admin].g_iHealMessage = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHealPlayer[admin].g_iHealMessage, value, -1, 7);
			g_esHealPlayer[admin].g_iHealSight = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHealPlayer[admin].g_iHealSight, value, -1, 5);
			g_esHealPlayer[admin].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esHealPlayer[admin].g_flHealAbsorbRange, value, -1.0, 99999.0);
			g_esHealPlayer[admin].g_flHealBuffer = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esHealPlayer[admin].g_flHealBuffer, value, -1.0, float(MT_MAXHEALTH));
			g_esHealPlayer[admin].g_flHealChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esHealPlayer[admin].g_flHealChance, value, -1.0, 100.0);
			g_esHealPlayer[admin].g_iHealCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealCooldown", "Heal Cooldown", "Heal_Cooldown", "cooldown", g_esHealPlayer[admin].g_iHealCooldown, value, -1, 99999);
			g_esHealPlayer[admin].g_iHealDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealDuration", "Heal Duration", "Heal_Duration", "duration", g_esHealPlayer[admin].g_iHealDuration, value, -1, 99999);
			g_esHealPlayer[admin].g_iHealHit = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esHealPlayer[admin].g_iHealHit, value, -1, 1);
			g_esHealPlayer[admin].g_iHealHitMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esHealPlayer[admin].g_iHealHitMode, value, -1, 2);
			g_esHealPlayer[admin].g_flHealInterval = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esHealPlayer[admin].g_flHealInterval, value, -1.0, 99999.0);
			g_esHealPlayer[admin].g_flHealRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esHealPlayer[admin].g_flHealRange, value, -1.0, 99999.0);
			g_esHealPlayer[admin].g_flHealRangeChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esHealPlayer[admin].g_flHealRangeChance, value, -1.0, 100.0);
			g_esHealPlayer[admin].g_iHealRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeCooldown", "Heal Range Cooldown", "Heal_Range_Cooldown", "rangecooldown", g_esHealPlayer[admin].g_iHealRangeCooldown, value, -1, 99999);
			g_esHealPlayer[admin].g_iHealCommon = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esHealPlayer[admin].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealPlayer[admin].g_iHealGlow = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealGlow", "Heal Glow", "Heal_Glow", "glow", g_esHealPlayer[admin].g_iHealGlow, value, -1, 1);
			g_esHealPlayer[admin].g_iHealSpecial = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esHealPlayer[admin].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealPlayer[admin].g_iHealTank = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esHealPlayer[admin].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHealPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esHealSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHealSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHealSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHealSpecial[type].g_iComboAbility, value, -1, 1);
			g_esHealSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHealSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esHealSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHealSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esHealSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHealSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esHealSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esHealSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esHealSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esHealSpecial[type].g_iHumanMode, value, -1, 2);
			g_esHealSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHealSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHealSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHealSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHealSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHealSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esHealSpecial[type].g_iHealAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHealSpecial[type].g_iHealAbility, value, -1, 3);
			g_esHealSpecial[type].g_iHealEffect = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHealSpecial[type].g_iHealEffect, value, -1, 7);
			g_esHealSpecial[type].g_iHealMessage = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHealSpecial[type].g_iHealMessage, value, -1, 7);
			g_esHealSpecial[type].g_iHealSight = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHealSpecial[type].g_iHealSight, value, -1, 5);
			g_esHealSpecial[type].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esHealSpecial[type].g_flHealAbsorbRange, value, -1.0, 99999.0);
			g_esHealSpecial[type].g_flHealBuffer = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esHealSpecial[type].g_flHealBuffer, value, -1.0, float(MT_MAXHEALTH));
			g_esHealSpecial[type].g_flHealChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esHealSpecial[type].g_flHealChance, value, -1.0, 100.0);
			g_esHealSpecial[type].g_iHealCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealCooldown", "Heal Cooldown", "Heal_Cooldown", "cooldown", g_esHealSpecial[type].g_iHealCooldown, value, -1, 99999);
			g_esHealSpecial[type].g_iHealDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealDuration", "Heal Duration", "Heal_Duration", "duration", g_esHealSpecial[type].g_iHealDuration, value, -1, 99999);
			g_esHealSpecial[type].g_iHealHit = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esHealSpecial[type].g_iHealHit, value, -1, 1);
			g_esHealSpecial[type].g_iHealHitMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esHealSpecial[type].g_iHealHitMode, value, -1, 2);
			g_esHealSpecial[type].g_flHealInterval = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esHealSpecial[type].g_flHealInterval, value, -1.0, 99999.0);
			g_esHealSpecial[type].g_flHealRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esHealSpecial[type].g_flHealRange, value, -1.0, 99999.0);
			g_esHealSpecial[type].g_flHealRangeChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esHealSpecial[type].g_flHealRangeChance, value, -1.0, 100.0);
			g_esHealSpecial[type].g_iHealRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeCooldown", "Heal Range Cooldown", "Heal_Range_Cooldown", "rangecooldown", g_esHealSpecial[type].g_iHealRangeCooldown, value, -1, 99999);
			g_esHealSpecial[type].g_iHealCommon = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esHealSpecial[type].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealSpecial[type].g_iHealGlow = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealGlow", "Heal Glow", "Heal_Glow", "glow", g_esHealSpecial[type].g_iHealGlow, value, -1, 1);
			g_esHealSpecial[type].g_iHealSpecial = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esHealSpecial[type].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealSpecial[type].g_iHealTank = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esHealSpecial[type].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		}
		else
		{
			g_esHealAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHealAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHealAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHealAbility[type].g_iComboAbility, value, -1, 1);
			g_esHealAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHealAbility[type].g_iHumanAbility, value, -1, 2);
			g_esHealAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHealAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esHealAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHealAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esHealAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esHealAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esHealAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esHealAbility[type].g_iHumanMode, value, -1, 2);
			g_esHealAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHealAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHealAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHealAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHealAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHealAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esHealAbility[type].g_iHealAbility = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHealAbility[type].g_iHealAbility, value, -1, 3);
			g_esHealAbility[type].g_iHealEffect = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHealAbility[type].g_iHealEffect, value, -1, 7);
			g_esHealAbility[type].g_iHealMessage = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHealAbility[type].g_iHealMessage, value, -1, 7);
			g_esHealAbility[type].g_iHealSight = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHealAbility[type].g_iHealSight, value, -1, 5);
			g_esHealAbility[type].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esHealAbility[type].g_flHealAbsorbRange, value, -1.0, 99999.0);
			g_esHealAbility[type].g_flHealBuffer = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esHealAbility[type].g_flHealBuffer, value, -1.0, float(MT_MAXHEALTH));
			g_esHealAbility[type].g_flHealChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esHealAbility[type].g_flHealChance, value, -1.0, 100.0);
			g_esHealAbility[type].g_iHealCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealCooldown", "Heal Cooldown", "Heal_Cooldown", "cooldown", g_esHealAbility[type].g_iHealCooldown, value, -1, 99999);
			g_esHealAbility[type].g_iHealDuration = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealDuration", "Heal Duration", "Heal_Duration", "duration", g_esHealAbility[type].g_iHealDuration, value, -1, 99999);
			g_esHealAbility[type].g_iHealHit = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esHealAbility[type].g_iHealHit, value, -1, 1);
			g_esHealAbility[type].g_iHealHitMode = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esHealAbility[type].g_iHealHitMode, value, -1, 2);
			g_esHealAbility[type].g_flHealInterval = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esHealAbility[type].g_flHealInterval, value, -1.0, 99999.0);
			g_esHealAbility[type].g_flHealRange = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esHealAbility[type].g_flHealRange, value, -1.0, 99999.0);
			g_esHealAbility[type].g_flHealRangeChance = flGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esHealAbility[type].g_flHealRangeChance, value, -1.0, 100.0);
			g_esHealAbility[type].g_iHealRangeCooldown = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealRangeCooldown", "Heal Range Cooldown", "Heal_Range_Cooldown", "rangecooldown", g_esHealAbility[type].g_iHealRangeCooldown, value, -1, 99999);
			g_esHealAbility[type].g_iHealCommon = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esHealAbility[type].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealAbility[type].g_iHealGlow = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealGlow", "Heal Glow", "Heal_Glow", "glow", g_esHealAbility[type].g_iHealGlow, value, -1, 1);
			g_esHealAbility[type].g_iHealSpecial = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esHealAbility[type].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealAbility[type].g_iHealTank = iGetKeyValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esHealAbility[type].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esHealAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHealAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HEAL_SECTION, MT_HEAL_SECTION2, MT_HEAL_SECTION3, MT_HEAL_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esHealPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esHealPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esHealPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esHealCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flCloseAreasOnly, g_esHealPlayer[tank].g_flCloseAreasOnly, g_esHealSpecial[iType].g_flCloseAreasOnly, g_esHealAbility[iType].g_flCloseAreasOnly, 1);
		g_esHealCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iComboAbility, g_esHealPlayer[tank].g_iComboAbility, g_esHealSpecial[iType].g_iComboAbility, g_esHealAbility[iType].g_iComboAbility, 1);
		g_esHealCache[tank].g_flHealAbsorbRange = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealAbsorbRange, g_esHealPlayer[tank].g_flHealAbsorbRange, g_esHealSpecial[iType].g_flHealAbsorbRange, g_esHealAbility[iType].g_flHealAbsorbRange, 1);
		g_esHealCache[tank].g_flHealBuffer = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealBuffer, g_esHealPlayer[tank].g_flHealBuffer, g_esHealSpecial[iType].g_flHealBuffer, g_esHealAbility[iType].g_flHealBuffer, 1);
		g_esHealCache[tank].g_flHealChance = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealChance, g_esHealPlayer[tank].g_flHealChance, g_esHealSpecial[iType].g_flHealChance, g_esHealAbility[iType].g_flHealChance, 1);
		g_esHealCache[tank].g_flHealInterval = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealInterval, g_esHealPlayer[tank].g_flHealInterval, g_esHealSpecial[iType].g_flHealInterval, g_esHealAbility[iType].g_flHealInterval, 1);
		g_esHealCache[tank].g_flHealRange = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealRange, g_esHealPlayer[tank].g_flHealRange, g_esHealSpecial[iType].g_flHealRange, g_esHealAbility[iType].g_flHealRange, 1);
		g_esHealCache[tank].g_flHealRangeChance = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flHealRangeChance, g_esHealPlayer[tank].g_flHealRangeChance, g_esHealSpecial[iType].g_flHealRangeChance, g_esHealAbility[iType].g_flHealRangeChance, 1);
		g_esHealCache[tank].g_iHealAbility = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealAbility, g_esHealPlayer[tank].g_iHealAbility, g_esHealSpecial[iType].g_iHealAbility, g_esHealAbility[iType].g_iHealAbility, 1);
		g_esHealCache[tank].g_iHealCommon = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealCommon, g_esHealPlayer[tank].g_iHealCommon, g_esHealSpecial[iType].g_iHealCommon, g_esHealAbility[iType].g_iHealCommon, 2, -1);
		g_esHealCache[tank].g_iHealCooldown = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealCooldown, g_esHealPlayer[tank].g_iHealCooldown, g_esHealSpecial[iType].g_iHealCooldown, g_esHealAbility[iType].g_iHealCooldown, 1);
		g_esHealCache[tank].g_iHealDuration = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealDuration, g_esHealPlayer[tank].g_iHealDuration, g_esHealSpecial[iType].g_iHealDuration, g_esHealAbility[iType].g_iHealDuration, 1);
		g_esHealCache[tank].g_iHealEffect = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealEffect, g_esHealPlayer[tank].g_iHealEffect, g_esHealSpecial[iType].g_iHealEffect, g_esHealAbility[iType].g_iHealEffect, 1);
		g_esHealCache[tank].g_iHealGlow = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealGlow, g_esHealPlayer[tank].g_iHealGlow, g_esHealSpecial[iType].g_iHealGlow, g_esHealAbility[iType].g_iHealGlow, 1);
		g_esHealCache[tank].g_iHealHit = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealHit, g_esHealPlayer[tank].g_iHealHit, g_esHealSpecial[iType].g_iHealHit, g_esHealAbility[iType].g_iHealHit, 1);
		g_esHealCache[tank].g_iHealHitMode = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealHitMode, g_esHealPlayer[tank].g_iHealHitMode, g_esHealSpecial[iType].g_iHealHitMode, g_esHealAbility[iType].g_iHealHitMode, 1);
		g_esHealCache[tank].g_iHealMessage = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealMessage, g_esHealPlayer[tank].g_iHealMessage, g_esHealSpecial[iType].g_iHealMessage, g_esHealAbility[iType].g_iHealMessage, 1);
		g_esHealCache[tank].g_iHealRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealRangeCooldown, g_esHealPlayer[tank].g_iHealRangeCooldown, g_esHealSpecial[iType].g_iHealRangeCooldown, g_esHealAbility[iType].g_iHealRangeCooldown, 1);
		g_esHealCache[tank].g_iHealSight = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealSight, g_esHealPlayer[tank].g_iHealSight, g_esHealSpecial[iType].g_iHealSight, g_esHealAbility[iType].g_iHealSight, 1);
		g_esHealCache[tank].g_iHealSpecial = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealSpecial, g_esHealPlayer[tank].g_iHealSpecial, g_esHealSpecial[iType].g_iHealSpecial, g_esHealAbility[iType].g_iHealSpecial, 2, -1);
		g_esHealCache[tank].g_iHealTank = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHealTank, g_esHealPlayer[tank].g_iHealTank, g_esHealSpecial[iType].g_iHealTank, g_esHealAbility[iType].g_iHealTank, 2, -1);
		g_esHealCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanAbility, g_esHealPlayer[tank].g_iHumanAbility, g_esHealSpecial[iType].g_iHumanAbility, g_esHealAbility[iType].g_iHumanAbility, 1);
		g_esHealCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanAmmo, g_esHealPlayer[tank].g_iHumanAmmo, g_esHealSpecial[iType].g_iHumanAmmo, g_esHealAbility[iType].g_iHumanAmmo, 1);
		g_esHealCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanCooldown, g_esHealPlayer[tank].g_iHumanCooldown, g_esHealSpecial[iType].g_iHumanCooldown, g_esHealAbility[iType].g_iHumanCooldown, 1);
		g_esHealCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanDuration, g_esHealPlayer[tank].g_iHumanDuration, g_esHealSpecial[iType].g_iHumanDuration, g_esHealAbility[iType].g_iHumanDuration, 1);
		g_esHealCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanMode, g_esHealPlayer[tank].g_iHumanMode, g_esHealSpecial[iType].g_iHumanMode, g_esHealAbility[iType].g_iHumanMode, 1);
		g_esHealCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iHumanRangeCooldown, g_esHealPlayer[tank].g_iHumanRangeCooldown, g_esHealSpecial[iType].g_iHumanRangeCooldown, g_esHealAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHealCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_flOpenAreasOnly, g_esHealPlayer[tank].g_flOpenAreasOnly, g_esHealSpecial[iType].g_flOpenAreasOnly, g_esHealAbility[iType].g_flOpenAreasOnly, 1);
		g_esHealCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esHealTeammate[tank].g_iRequiresHumans, g_esHealPlayer[tank].g_iRequiresHumans, g_esHealSpecial[iType].g_iRequiresHumans, g_esHealAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esHealCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flCloseAreasOnly, g_esHealAbility[iType].g_flCloseAreasOnly, 1);
		g_esHealCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iComboAbility, g_esHealAbility[iType].g_iComboAbility, 1);
		g_esHealCache[tank].g_flHealAbsorbRange = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealAbsorbRange, g_esHealAbility[iType].g_flHealAbsorbRange, 1);
		g_esHealCache[tank].g_flHealBuffer = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealBuffer, g_esHealAbility[iType].g_flHealBuffer, 1);
		g_esHealCache[tank].g_flHealChance = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealChance, g_esHealAbility[iType].g_flHealChance, 1);
		g_esHealCache[tank].g_flHealInterval = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealInterval, g_esHealAbility[iType].g_flHealInterval, 1);
		g_esHealCache[tank].g_flHealRange = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealRange, g_esHealAbility[iType].g_flHealRange, 1);
		g_esHealCache[tank].g_flHealRangeChance = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flHealRangeChance, g_esHealAbility[iType].g_flHealRangeChance, 1);
		g_esHealCache[tank].g_iHealAbility = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealAbility, g_esHealAbility[iType].g_iHealAbility, 1);
		g_esHealCache[tank].g_iHealCommon = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealCommon, g_esHealAbility[iType].g_iHealCommon, 2, -1);
		g_esHealCache[tank].g_iHealCooldown = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealCooldown, g_esHealAbility[iType].g_iHealCooldown, 1);
		g_esHealCache[tank].g_iHealDuration = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealDuration, g_esHealAbility[iType].g_iHealDuration, 1);
		g_esHealCache[tank].g_iHealEffect = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealEffect, g_esHealAbility[iType].g_iHealEffect, 1);
		g_esHealCache[tank].g_iHealGlow = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealGlow, g_esHealAbility[iType].g_iHealGlow, 1);
		g_esHealCache[tank].g_iHealHit = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealHit, g_esHealAbility[iType].g_iHealHit, 1);
		g_esHealCache[tank].g_iHealHitMode = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealHitMode, g_esHealAbility[iType].g_iHealHitMode, 1);
		g_esHealCache[tank].g_iHealMessage = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealMessage, g_esHealAbility[iType].g_iHealMessage, 1);
		g_esHealCache[tank].g_iHealRangeCooldown = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealRangeCooldown, g_esHealAbility[iType].g_iHealRangeCooldown, 1);
		g_esHealCache[tank].g_iHealSight = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealSight, g_esHealAbility[iType].g_iHealSight, 1);
		g_esHealCache[tank].g_iHealSpecial = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealSpecial, g_esHealAbility[iType].g_iHealSpecial, 2, -1);
		g_esHealCache[tank].g_iHealTank = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHealTank, g_esHealAbility[iType].g_iHealTank, 2, -1);
		g_esHealCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanAbility, g_esHealAbility[iType].g_iHumanAbility, 1);
		g_esHealCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanAmmo, g_esHealAbility[iType].g_iHumanAmmo, 1);
		g_esHealCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanCooldown, g_esHealAbility[iType].g_iHumanCooldown, 1);
		g_esHealCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanDuration, g_esHealAbility[iType].g_iHumanDuration, 1);
		g_esHealCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanMode, g_esHealAbility[iType].g_iHumanMode, 1);
		g_esHealCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iHumanRangeCooldown, g_esHealAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHealCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_flOpenAreasOnly, g_esHealAbility[iType].g_flOpenAreasOnly, 1);
		g_esHealCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esHealPlayer[tank].g_iRequiresHumans, g_esHealAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vHealCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vHealCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveHeal(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vHealEventFired(Event event, const char[] name)
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
			vHealCopyStats2(iBot, iTank);
			vRemoveHeal(iBot);
		}
	}
	else if (StrEqual(name, "heal_success"))
	{
		int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor))
		{
			g_esHealPlayer[iSurvivor].g_bAffected = false;

			SetEntProp(iSurvivor, Prop_Send, "m_currentReviveCount", 0);
			SetEntProp(iSurvivor, Prop_Send, "m_isGoingToDie", 0);

			if (g_bSecondGame)
			{
				SetEntProp(iSurvivor, Prop_Send, "m_bIsOnThirdStrike", 0);
			}

			StopSound(iSurvivor, SNDCHAN_STATIC, SOUND_HEARTBEAT);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vHealReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vHealCopyStats2(iTank, iBot);
			vRemoveHeal(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_incapacitated") || StrEqual(name, "player_spawn"))
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveHeal(iPlayer);
		}
		else if (bIsSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vStopHeartbeat(iPlayer, SOUND_HEARTBEAT);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vHealHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esHealCache[iBoomer].g_flHealChance, g_esHealCache[iBoomer].g_iHealHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[tank].g_iAccessFlags)) || g_esHealCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esHealCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esHealCache[tank].g_iHealAbility > 0 && g_esHealCache[tank].g_iComboAbility == 0)
	{
		vHealAbility(tank, false);
		vHealAbility(tank, true, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vHealButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esHealCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHealCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHealPlayer[tank].g_iTankType, tank) || (g_esHealCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHealCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		int iTime = GetTime();
		if ((button & MT_MAIN_KEY) && (g_esHealCache[tank].g_iHealAbility == 2 || g_esHealCache[tank].g_iHealAbility == 3) && g_esHealCache[tank].g_iHumanAbility == 1)
		{
			bool bRecharging = g_esHealPlayer[tank].g_iCooldown != -1 && g_esHealPlayer[tank].g_iCooldown >= iTime;
			int iHumanMode = g_esHealCache[tank].g_iHumanMode;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esHealPlayer[tank].g_bActivated && !bRecharging)
					{
						vHealAbility(tank, false);
					}
					else if (g_esHealPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5", (g_esHealPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esHealPlayer[tank].g_bActivated) || (g_esHealPlayer[tank].g_iAmmoCount < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esHealPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esHealPlayer[tank].g_bActivated = true;
							g_esHealPlayer[tank].g_iAmmoCount++;

							vHeal(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esHealPlayer[tank].g_iAmmoCount, g_esHealCache[tank].g_iHumanAmmo);
						}
						else if (g_esHealPlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
								case 2:
								{
									vHealReset2(tank);
									vHealReset3(tank);
								}
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5", (g_esHealPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
					}
				}
			}
		}

		if ((button & MT_SUB_KEY) && (g_esHealCache[tank].g_iHealAbility == 1 || g_esHealCache[tank].g_iHealAbility == 3) && g_esHealCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esHealPlayer[tank].g_iRangeCooldown == -1 || g_esHealPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vHealAbility(tank, true, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman6", (g_esHealPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esHealCache[tank].g_iHumanMode == 1 && g_esHealPlayer[tank].g_bActivated && (g_esHealPlayer[tank].g_iCooldown == -1 || g_esHealPlayer[tank].g_iCooldown <= GetTime()))
		{
			vHealReset2(tank);
			vHealReset3(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHealChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveHeal(tank);
}

void vHeal(int tank, int pos = -1)
{
	int iTime = GetTime();
	if ((g_esHealPlayer[tank].g_iCooldown != -1 && g_esHealPlayer[tank].g_iCooldown >= iTime) || bIsAreaNarrow(tank, g_esHealCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHealCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHealPlayer[tank].g_iTankType, tank) || (g_esHealCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHealCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esHealCache[tank].g_flHealInterval;
	if (flInterval > 0.0)
	{
		DataPack dpHeal;
		CreateDataTimer(flInterval, tTimerHeal, dpHeal, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpHeal.WriteCell(GetClientUserId(tank));
		dpHeal.WriteCell(g_esHealPlayer[tank].g_iTankType);
		dpHeal.WriteCell(iTime);
		dpHeal.WriteCell(pos);
	}
}

void vHealAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHealCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHealCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHealPlayer[tank].g_iTankType, tank) || (g_esHealCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHealCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esHealCache[tank].g_iHealAbility == 1 || g_esHealCache[tank].g_iHealAbility == 3)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esHealPlayer[tank].g_iAmmoCount2 < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0))
				{
					g_esHealPlayer[tank].g_bFailed = false;
					g_esHealPlayer[tank].g_bNoAmmo = false;

					float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					float flSurvivorPos[3],
						flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esHealCache[tank].g_flHealRange,
						flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esHealCache[tank].g_flHealRangeChance;
					int iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esHealPlayer[tank].g_iTankType, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esHealPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esHealCache[tank].g_iHealSight, .range = flRange))
							{
								vHealHit(iSurvivor, tank, random, flChance, g_esHealCache[tank].g_iHealAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman7");
						}
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
				}
			}
		}
		case false:
		{
			if (g_esHealPlayer[tank].g_iCooldown != -1 && g_esHealPlayer[tank].g_iCooldown >= GetTime())
			{
				return;
			}

			if ((g_esHealCache[tank].g_iHealAbility == 2 || g_esHealCache[tank].g_iHealAbility == 3) && !g_esHealPlayer[tank].g_bActivated)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esHealPlayer[tank].g_iAmmoCount < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0))
				{
					g_esHealPlayer[tank].g_bActivated = true;

					vHeal(tank, pos);

					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
					{
						g_esHealPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esHealPlayer[tank].g_iAmmoCount, g_esHealCache[tank].g_iHumanAmmo);
					}

					if (g_esHealCache[tank].g_iHealMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[64];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Heal2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal2", LANG_SERVER, sTankName);
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
				}
			}
		}
	}
}

void vHealHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHealCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHealCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHealPlayer[tank].g_iTankType, tank) || (g_esHealCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHealCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esHealPlayer[tank].g_iTankType, g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esHealPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esHealPlayer[tank].g_iRangeCooldown != -1 && g_esHealPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esHealPlayer[tank].g_iCooldown2 != -1 && g_esHealPlayer[tank].g_iCooldown2 >= iTime))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor) && !bIsSurvivorDisabled(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esHealPlayer[tank].g_iAmmoCount2 < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && GetEntProp(survivor, Prop_Data, "m_iHealth") > 0 && !g_esHealPlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esHealCache[tank].g_iHealSight, .range = 100.0))
				{
					return;
				}

				g_esHealPlayer[survivor].g_bAffected = true;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esHealPlayer[tank].g_iRangeCooldown == -1 || g_esHealPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1)
					{
						g_esHealPlayer[tank].g_iAmmoCount2++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman2", g_esHealPlayer[tank].g_iAmmoCount2, g_esHealCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esHealCache[tank].g_iHealRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1 && g_esHealPlayer[tank].g_iAmmoCount2 < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0) ? g_esHealCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esHealPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esHealPlayer[tank].g_iRangeCooldown != -1 && g_esHealPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman9", (g_esHealPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esHealPlayer[tank].g_iCooldown2 == -1 || g_esHealPlayer[tank].g_iCooldown2 <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esHealCache[tank].g_iHealCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1) ? g_esHealCache[tank].g_iHumanCooldown : iCooldown;
					g_esHealPlayer[tank].g_iCooldown2 = (iTime + iCooldown);
					if (g_esHealPlayer[tank].g_iCooldown2 != -1 && g_esHealPlayer[tank].g_iCooldown2 >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman9", (g_esHealPlayer[tank].g_iCooldown2 - iTime));
					}
				}

				vSetSurvivorLastLife(survivor, g_cvMTMaxIncapCount.IntValue, true, g_esHealCache[tank].g_flHealBuffer);
				vScreenEffect(survivor, tank, g_esHealCache[tank].g_iHealEffect, flags);

				if (g_esHealCache[tank].g_iHealMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Heal", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esHealPlayer[tank].g_iRangeCooldown == -1 || g_esHealPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1 && !g_esHealPlayer[tank].g_bFailed)
				{
					g_esHealPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman3");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1 && !g_esHealPlayer[tank].g_bNoAmmo)
		{
			g_esHealPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
		}
	}
}

void vHealCopyStats2(int oldTank, int newTank)
{
	g_esHealPlayer[newTank].g_iAmmoCount = g_esHealPlayer[oldTank].g_iAmmoCount;
	g_esHealPlayer[newTank].g_iAmmoCount2 = g_esHealPlayer[oldTank].g_iAmmoCount2;
	g_esHealPlayer[newTank].g_iCooldown = g_esHealPlayer[oldTank].g_iCooldown;
	g_esHealPlayer[newTank].g_iCooldown2 = g_esHealPlayer[oldTank].g_iCooldown2;
	g_esHealPlayer[newTank].g_iRangeCooldown = g_esHealPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveHeal(int tank)
{
	vHealResetGlow(tank);

	g_esHealPlayer[tank].g_bActivated = false;
	g_esHealPlayer[tank].g_bAffected = false;
	g_esHealPlayer[tank].g_bFailed = false;
	g_esHealPlayer[tank].g_bNoAmmo = false;
	g_esHealPlayer[tank].g_iAmmoCount = 0;
	g_esHealPlayer[tank].g_iAmmoCount2 = 0;
	g_esHealPlayer[tank].g_iCooldown = -1;
	g_esHealPlayer[tank].g_iCooldown2 = -1;
	g_esHealPlayer[tank].g_iRangeCooldown = -1;
}

void vHealReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

void vHealReset2(int tank)
{
	g_esHealPlayer[tank].g_bActivated = false;

	if (g_esHealCache[tank].g_iHealMessage & MT_MESSAGE_SPECIAL)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Heal3", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal3", LANG_SERVER, sTankName);
	}
}

void vHealReset3(int tank)
{
	vHealResetGlow(tank);

	int iTime = GetTime(), iPos = g_esHealAbility[g_esHealPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esHealCache[tank].g_iHealCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHealCache[tank].g_iHumanAbility == 1 && g_esHealCache[tank].g_iHumanMode == 0 && g_esHealPlayer[tank].g_iAmmoCount < g_esHealCache[tank].g_iHumanAmmo && g_esHealCache[tank].g_iHumanAmmo > 0) ? g_esHealCache[tank].g_iHumanCooldown : iCooldown;
	g_esHealPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esHealPlayer[tank].g_iCooldown != -1 && g_esHealPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman8", (g_esHealPlayer[tank].g_iCooldown - iTime));
	}
}

void vHealResetGlow(int tank)
{
	if (!g_bSecondGame || !bIsValidClient(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
	{
		return;
	}

	switch (MT_IsGlowEnabled(tank))
	{
		case true:
		{
			int iGlowColor[4];
			MT_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
			vSetHealGlow(tank, iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]), MT_IsGlowFlashing(tank), MT_GetGlowRange(tank, false), MT_GetGlowRange(tank, true), ((MT_GetGlowType(tank) == 1) ? 3 : 2));
		}
		case false: vSetHealGlow(tank, 0, false, 0, 0, 0);
	}
}

void vSetHealGlow(int tank, int color, bool flashing, int min, int max, int type)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", color);
	SetEntProp(tank, Prop_Send, "m_bFlashing", flashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", min);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", max);
	SetEntProp(tank, Prop_Send, "m_iGlowType", type);
}

Action tTimerHealCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHealAbility[g_esHealPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHealPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHealCache[iTank].g_iHealAbility == 0 || g_esHealCache[iTank].g_iHealAbility == 2)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vHealAbility(iTank, true, flRandom, iPos);

	return Plugin_Continue;
}

Action tTimerHealCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHealAbility[g_esHealPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHealPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHealCache[iTank].g_iHealAbility == 0 || g_esHealCache[iTank].g_iHealAbility == 1)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vHealAbility(iTank, false, .pos = iPos);

	return Plugin_Continue;
}

Action tTimerHealCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esHealPlayer[iSurvivor].g_bAffected)
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHealAbility[g_esHealPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHealPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHealCache[iTank].g_iHealHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esHealCache[iTank].g_iHealHitMode == 0 || g_esHealCache[iTank].g_iHealHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vHealHit(iSurvivor, iTank, flRandom, flChance, g_esHealCache[iTank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esHealCache[iTank].g_iHealHitMode == 0 || g_esHealCache[iTank].g_iHealHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vHealHit(iSurvivor, iTank, flRandom, flChance, g_esHealCache[iTank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}

Action tTimerHeal(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsPlayerIncapacitated(iTank) || bIsAreaNarrow(iTank, g_esHealCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esHealCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHealPlayer[iTank].g_iTankType, iTank) || (g_esHealCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHealCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHealAbility[g_esHealPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHealPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHealPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esHealPlayer[iTank].g_iTankType || (g_esHealCache[iTank].g_iHealAbility != 2 && g_esHealCache[iTank].g_iHealAbility != 3) || !g_esHealPlayer[iTank].g_bActivated)
	{
		vHealReset2(iTank);

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esHealCache[iTank].g_iHealDuration;
	iDuration = (bHuman && g_esHealCache[iTank].g_iHumanAbility == 1) ? g_esHealCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esHealCache[iTank].g_iHumanAbility == 1 && g_esHealCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime && (g_esHealPlayer[iTank].g_iCooldown == -1 || g_esHealPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vHealReset2(iTank);
		vHealReset3(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3], flInfectedPos[3];
	GetClientAbsOrigin(iTank, flTankPos);
	int iCommon = -1, iCommonHealth, iExtraHealth, iExtraHealth2, iGreen = 0, iHealth, iLeftover = 0,
		iMaxHealth = MT_TankMaxHealth(iTank, 1), iRealHealth, iSpecialHealth, iTankHealth, iTotalHealth = 0;
	while ((iCommon = FindEntityByClassname(iCommon, "infected")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropVector(iCommon, Prop_Data, "m_vecOrigin", flInfectedPos);
		if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esHealCache[iTank].g_flHealAbsorbRange)
		{
			iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
			if (iHealth >= 500)
			{
				iCommonHealth = (iHealth + g_esHealCache[iTank].g_iHealCommon);
				iLeftover = (iCommonHealth > MT_MAXHEALTH) ? (iCommonHealth - MT_MAXHEALTH) : iCommonHealth;
				iExtraHealth = (iCommonHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iCommonHealth;
				iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth;
				iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
				iGreen = 185;
				iTotalHealth += (iCommonHealth > MT_MAXHEALTH) ? iLeftover : g_esHealCache[iTank].g_iHealCommon;
				SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esHealCache[iTank].g_flHealAbsorbRange)
			{
				iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
				if (iHealth >= 500)
				{
					iSpecialHealth = (iHealth + g_esHealCache[iTank].g_iHealSpecial);
					iLeftover = (iSpecialHealth > MT_MAXHEALTH) ? (iSpecialHealth - MT_MAXHEALTH) : iSpecialHealth;
					iExtraHealth = (iSpecialHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iSpecialHealth;
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth;
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
					iGreen = 220;
					iTotalHealth += (iSpecialHealth > MT_MAXHEALTH) ? iLeftover : g_esHealCache[iTank].g_iHealSpecial;
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);
				}
			}
		}
		else if (MT_IsTankSupported(iInfected) && iInfected != iTank)
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esHealCache[iTank].g_flHealAbsorbRange)
			{
				iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
				if (iHealth >= 500)
				{
					iTankHealth = (iHealth + g_esHealCache[iTank].g_iHealTank);
					iLeftover = (iTankHealth > MT_MAXHEALTH) ? (iTankHealth - MT_MAXHEALTH) : iTankHealth;
					iExtraHealth = (iTankHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iTankHealth;
					iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth;
					iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
					iGreen = 255;
					iTotalHealth += (iTankHealth > MT_MAXHEALTH) ? iLeftover : g_esHealCache[iTank].g_iHealTank;
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);
				}
			}
		}
	}

	switch (iGreen == 0 || g_esHealCache[iTank].g_iHealGlow == 0)
	{
		case true: vHealResetGlow(iTank);
		case false:
		{
			int iColor[4];
			MT_GetTankColors(iTank, 2, iColor[0], iColor[1], iColor[2], iColor[3]);
			if (!(iColor[0] == -2 && iColor[1] == -2 && iColor[2] == -2))
			{
				MT_TankMaxHealth(iTank, 3, (iMaxHealth + iTotalHealth));
				vSetHealGlow(iTank, iGetRGBColor(0, iGreen, 0), MT_IsGlowFlashing(iTank), MT_GetGlowRange(iTank, false), MT_GetGlowRange(iTank, true), ((MT_GetGlowType(iTank) == 1) ? 3 : 2));
			}
		}
	}

	return Plugin_Continue;
}