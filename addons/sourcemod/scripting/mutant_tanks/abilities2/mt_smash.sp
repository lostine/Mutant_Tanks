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

#define MT_SMASH_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_SMASH_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Smash Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank sends survivors into space, smashes survivors to death, smites survivors, and kills itself along with a survivor victim.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

int g_iGraphicsLevel;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Smash Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_FIRE "weapons/molotov/fire_ignite_1.wav"
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" // Only available in L4D1
#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" // Only available in L4D2
#define SOUND_LAUNCH "player/boomer/explode/explo_medium_14.wav"
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2

#define SPRITE_FIRE "sprites/sprite_fire01.vmt"
#define SPRITE_GLOW "sprites/glow01.vmt"
#else
	#if MT_SMASH_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_SMASH_SECTION "smashability"
#define MT_SMASH_SECTION2 "smash ability"
#define MT_SMASH_SECTION3 "smash_ability"
#define MT_SMASH_SECTION4 "smash"

#define MT_SMASH_POUND (1 << 0) // pound
#define MT_SMASH_ROCKET (1 << 1) // rocket
#define MT_SMASH_SMITE (1 << 2) // smite

#define MT_MENU_SMASH "Smash Ability"

enum struct esSmashPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flDamage;
	float g_flOpenAreasOnly;
	float g_flSmashChance;
	float g_flSmashCountdown;
	float g_flSmashDelay;
	float g_flSmashMeter;
	float g_flSmashRange;
	float g_flSmashRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iSmashAbility;
	int g_iSmashBody;
	int g_iSmashCooldown;
	int g_iSmashEffect;
	int g_iSmashHit;
	int g_iSmashHitMode;
	int g_iSmashMessage;
	int g_iSmashMode;
	int g_iSmashRangeCooldown;
	int g_iSmashRemove;
	int g_iSmashSight;
	int g_iSmashType;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esSmashPlayer g_esSmashPlayer[MAXPLAYERS + 1];

enum struct esSmashTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flSmashChance;
	float g_flSmashCountdown;
	float g_flSmashDelay;
	float g_flSmashMeter;
	float g_flSmashRange;
	float g_flSmashRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iSmashAbility;
	int g_iSmashBody;
	int g_iSmashCooldown;
	int g_iSmashEffect;
	int g_iSmashHit;
	int g_iSmashHitMode;
	int g_iSmashMessage;
	int g_iSmashMode;
	int g_iSmashRangeCooldown;
	int g_iSmashRemove;
	int g_iSmashSight;
	int g_iSmashType;
}

esSmashTeammate g_esSmashTeammate[MAXPLAYERS + 1];

enum struct esSmashAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flSmashChance;
	float g_flSmashCountdown;
	float g_flSmashDelay;
	float g_flSmashMeter;
	float g_flSmashRange;
	float g_flSmashRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSmashAbility;
	int g_iSmashBody;
	int g_iSmashCooldown;
	int g_iSmashEffect;
	int g_iSmashHit;
	int g_iSmashHitMode;
	int g_iSmashMessage;
	int g_iSmashMode;
	int g_iSmashRangeCooldown;
	int g_iSmashRemove;
	int g_iSmashSight;
	int g_iSmashType;
}

esSmashAbility g_esSmashAbility[MT_MAXTYPES + 1];

enum struct esSmashSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flSmashChance;
	float g_flSmashCountdown;
	float g_flSmashDelay;
	float g_flSmashMeter;
	float g_flSmashRange;
	float g_flSmashRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iSmashAbility;
	int g_iSmashBody;
	int g_iSmashCooldown;
	int g_iSmashEffect;
	int g_iSmashHit;
	int g_iSmashHitMode;
	int g_iSmashMessage;
	int g_iSmashMode;
	int g_iSmashRangeCooldown;
	int g_iSmashRemove;
	int g_iSmashSight;
	int g_iSmashType;
}

esSmashSpecial g_esSmashSpecial[MT_MAXTYPES + 1];

enum struct esSmashCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flSmashChance;
	float g_flSmashCountdown;
	float g_flSmashDelay;
	float g_flSmashMeter;
	float g_flSmashRange;
	float g_flSmashRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iSmashAbility;
	int g_iSmashBody;
	int g_iSmashCooldown;
	int g_iSmashEffect;
	int g_iSmashHit;
	int g_iSmashHitMode;
	int g_iSmashMessage;
	int g_iSmashMode;
	int g_iSmashRangeCooldown;
	int g_iSmashRemove;
	int g_iSmashSight;
	int g_iSmashType;
}

esSmashCache g_esSmashCache[MAXPLAYERS + 1];

int g_iSmashDeathModelOwner = 0, g_iRocketSprite, g_iSmiteSprite = -1;

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_smash", cmdSmashInfo, "View information about the Smash ability.");

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

#if defined MT_ABILITIES_MAIN2
void vSmashMapStart()
#else
public void OnMapStart()
#endif
{
	if (g_bSecondGame)
	{
		PrecacheSound(SOUND_GROWL2, true);
		PrecacheSound(SOUND_SMASH2, true);
	}
	else
	{
		PrecacheSound(SOUND_GROWL1, true);
		PrecacheSound(SOUND_SMASH1, true);
	}

	g_iRocketSprite = PrecacheModel(SPRITE_FIRE, true);
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);

	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);

	vSmashReset();
}

#if defined MT_ABILITIES_MAIN2
void vSmashClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnSmashTakeDamage);
	vSmashReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vSmashClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vSmashReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vSmashMapEnd()
#else
public void OnMapEnd()
#endif
{
	vSmashReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdSmashInfo(int client, int args)
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
		case false: vSmashMenu(client, MT_SMASH_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vSmashMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_SMASH_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iSmashMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Smash Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iSmashMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esSmashCache[param1].g_iSmashAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esSmashCache[param1].g_iHumanAmmo - g_esSmashPlayer[param1].g_iAmmoCount), g_esSmashCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esSmashCache[param1].g_iHumanAbility == 1) ? g_esSmashCache[param1].g_iHumanCooldown : g_esSmashCache[param1].g_iSmashCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SmashDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esSmashCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esSmashCache[param1].g_iHumanAbility == 1) ? g_esSmashCache[param1].g_iHumanRangeCooldown : g_esSmashCache[param1].g_iSmashRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vSmashMenu(param1, MT_SMASH_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pSmash = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "SmashMenu", param1);
			pSmash.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vSmashDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_SMASH, MT_MENU_SMASH);
}

#if defined MT_ABILITIES_MAIN2
void vSmashMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_SMASH, false))
	{
		vSmashMenu(client, MT_SMASH_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_SMASH, false))
	{
		FormatEx(buffer, size, "%T", "SmashMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashEntityCreated(int entity, const char[] classname)
#else
public void OnEntityCreated(int entity, const char[] classname)
#endif
{
	if (bIsValidEntity(entity) && StrEqual(classname, "survivor_death_model"))
	{
		int iOwner = GetClientOfUserId(g_iSmashDeathModelOwner);
		if (bIsValidClient(iOwner))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnSmashModelSpawnPost);
		}

		g_iSmashDeathModelOwner = 0;
	}
}

void OnSmashModelSpawnPost(int model)
{
	g_iSmashDeathModelOwner = 0;

	SDKUnhook(model, SDKHook_SpawnPost, OnSmashModelSpawnPost);

	if (!bIsValidEntity(model))
	{
		return;
	}

	RemoveEntity(model);
}

Action OnSmashTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esSmashAbility[g_esSmashPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esSmashPlayer[attacker].g_iTankType, g_esSmashAbility[g_esSmashPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (g_esSmashCache[attacker].g_flSmashMeter > 0.0 && g_esSmashPlayer[attacker].g_flDamage < g_esSmashCache[attacker].g_flSmashMeter)
			{
				g_esSmashPlayer[attacker].g_flDamage += damage;
			}

			if ((g_esSmashCache[attacker].g_iSmashHitMode == 0 || g_esSmashCache[attacker].g_iSmashHitMode == 1) && g_esSmashCache[attacker].g_iComboAbility == 0)
			{
				bool bCaught = bIsSurvivorCaught(victim);
				if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
				{
					vSmashHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esSmashCache[attacker].g_flSmashChance, g_esSmashCache[attacker].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
				}
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esSmashCache[victim].g_iSmashHitMode == 0 || g_esSmashCache[victim].g_iSmashHitMode == 2) && bIsSurvivor(attacker) && g_esSmashCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esSmashAbility[g_esSmashPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esSmashPlayer[victim].g_iTankType, g_esSmashAbility[g_esSmashPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vSmashHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esSmashCache[victim].g_flSmashChance, g_esSmashCache[victim].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vSmashPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_SMASH);
}

#if defined MT_ABILITIES_MAIN2
void vSmashAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_SMASH_SECTION);
	list2.PushString(MT_SMASH_SECTION2);
	list3.PushString(MT_SMASH_SECTION3);
	list4.PushString(MT_SMASH_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vSmashCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_SMASH_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_SMASH_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_SMASH_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_SMASH_SECTION4);
	if (g_esSmashCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_SMASH_SECTION, false) || StrEqual(sSubset[iPos], MT_SMASH_SECTION2, false) || StrEqual(sSubset[iPos], MT_SMASH_SECTION3, false) || StrEqual(sSubset[iPos], MT_SMASH_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esSmashCache[tank].g_iSmashAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vSmashAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerSmashCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
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
								if ((g_esSmashCache[tank].g_iSmashHitMode == 0 || g_esSmashCache[tank].g_iSmashHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vSmashHit(survivor, tank, random, flChance, g_esSmashCache[tank].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esSmashCache[tank].g_iSmashHitMode == 0 || g_esSmashCache[tank].g_iSmashHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vSmashHit(survivor, tank, random, flChance, g_esSmashCache[tank].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerSmashCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
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

#if defined MT_ABILITIES_MAIN2
void vSmashConfigsLoad(int mode)
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
				g_esSmashAbility[iIndex].g_iAccessFlags = 0;
				g_esSmashAbility[iIndex].g_iImmunityFlags = 0;
				g_esSmashAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esSmashAbility[iIndex].g_iComboAbility = 0;
				g_esSmashAbility[iIndex].g_iHumanAbility = 0;
				g_esSmashAbility[iIndex].g_iHumanAmmo = 5;
				g_esSmashAbility[iIndex].g_iHumanCooldown = 0;
				g_esSmashAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esSmashAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esSmashAbility[iIndex].g_iRequiresHumans = 0;
				g_esSmashAbility[iIndex].g_iSmashAbility = 0;
				g_esSmashAbility[iIndex].g_iSmashEffect = 0;
				g_esSmashAbility[iIndex].g_iSmashMessage = 0;
				g_esSmashAbility[iIndex].g_iSmashBody = 1;
				g_esSmashAbility[iIndex].g_flSmashChance = 33.3;
				g_esSmashAbility[iIndex].g_iSmashCooldown = 0;
				g_esSmashAbility[iIndex].g_flSmashCountdown = 0.0;
				g_esSmashAbility[iIndex].g_flSmashDelay = 1.0;
				g_esSmashAbility[iIndex].g_iSmashHit = 0;
				g_esSmashAbility[iIndex].g_iSmashHitMode = 0;
				g_esSmashAbility[iIndex].g_flSmashMeter = 0.0;
				g_esSmashAbility[iIndex].g_iSmashMode = 0;
				g_esSmashAbility[iIndex].g_flSmashRange = 150.0;
				g_esSmashAbility[iIndex].g_flSmashRangeChance = 15.0;
				g_esSmashAbility[iIndex].g_iSmashRangeCooldown = 0;
				g_esSmashAbility[iIndex].g_iSmashRemove = 0;
				g_esSmashAbility[iIndex].g_iSmashSight = 0;
				g_esSmashAbility[iIndex].g_iSmashType = 1;

				g_esSmashSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esSmashSpecial[iIndex].g_iComboAbility = -1;
				g_esSmashSpecial[iIndex].g_iHumanAbility = -1;
				g_esSmashSpecial[iIndex].g_iHumanAmmo = -1;
				g_esSmashSpecial[iIndex].g_iHumanCooldown = -1;
				g_esSmashSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esSmashSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esSmashSpecial[iIndex].g_iRequiresHumans = -1;
				g_esSmashSpecial[iIndex].g_iSmashAbility = -1;
				g_esSmashSpecial[iIndex].g_iSmashEffect = -1;
				g_esSmashSpecial[iIndex].g_iSmashMessage = -1;
				g_esSmashSpecial[iIndex].g_iSmashBody = -1;
				g_esSmashSpecial[iIndex].g_flSmashChance = -1.0;
				g_esSmashSpecial[iIndex].g_iSmashCooldown = -1;
				g_esSmashSpecial[iIndex].g_flSmashCountdown = 0.0;
				g_esSmashSpecial[iIndex].g_flSmashDelay = -1.0;
				g_esSmashSpecial[iIndex].g_iSmashHit = -1;
				g_esSmashSpecial[iIndex].g_iSmashHitMode = -1;
				g_esSmashSpecial[iIndex].g_flSmashMeter = -1.0;
				g_esSmashSpecial[iIndex].g_iSmashMode = -1;
				g_esSmashSpecial[iIndex].g_flSmashRange = -1.0;
				g_esSmashSpecial[iIndex].g_flSmashRangeChance = -1.0;
				g_esSmashSpecial[iIndex].g_iSmashRangeCooldown = -1;
				g_esSmashSpecial[iIndex].g_iSmashRemove = -1;
				g_esSmashSpecial[iIndex].g_iSmashSight = -1;
				g_esSmashSpecial[iIndex].g_iSmashType = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esSmashPlayer[iPlayer].g_iAccessFlags = -1;
				g_esSmashPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esSmashPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esSmashPlayer[iPlayer].g_iComboAbility = -1;
				g_esSmashPlayer[iPlayer].g_iHumanAbility = -1;
				g_esSmashPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esSmashPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esSmashPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esSmashPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esSmashPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esSmashPlayer[iPlayer].g_iSmashAbility = -1;
				g_esSmashPlayer[iPlayer].g_iSmashEffect = -1;
				g_esSmashPlayer[iPlayer].g_iSmashMessage = -1;
				g_esSmashPlayer[iPlayer].g_iSmashBody = -1;
				g_esSmashPlayer[iPlayer].g_flSmashChance = -1.0;
				g_esSmashPlayer[iPlayer].g_iSmashCooldown = -1;
				g_esSmashPlayer[iPlayer].g_flSmashCountdown = 0.0;
				g_esSmashPlayer[iPlayer].g_flSmashDelay = -1.0;
				g_esSmashPlayer[iPlayer].g_iSmashHit = -1;
				g_esSmashPlayer[iPlayer].g_iSmashHitMode = -1;
				g_esSmashPlayer[iPlayer].g_flSmashMeter = -1.0;
				g_esSmashPlayer[iPlayer].g_iSmashMode = -1;
				g_esSmashPlayer[iPlayer].g_flSmashRange = -1.0;
				g_esSmashPlayer[iPlayer].g_flSmashRangeChance = -1.0;
				g_esSmashPlayer[iPlayer].g_iSmashRangeCooldown = -1;
				g_esSmashPlayer[iPlayer].g_iSmashRemove = -1;
				g_esSmashPlayer[iPlayer].g_iSmashSight = -1;
				g_esSmashPlayer[iPlayer].g_iSmashType = -1;

				g_esSmashTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esSmashTeammate[iPlayer].g_iComboAbility = -1;
				g_esSmashTeammate[iPlayer].g_iHumanAbility = -1;
				g_esSmashTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esSmashTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esSmashTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esSmashTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esSmashTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esSmashTeammate[iPlayer].g_iSmashAbility = -1;
				g_esSmashTeammate[iPlayer].g_iSmashEffect = -1;
				g_esSmashTeammate[iPlayer].g_iSmashMessage = -1;
				g_esSmashTeammate[iPlayer].g_iSmashBody = -1;
				g_esSmashTeammate[iPlayer].g_flSmashChance = -1.0;
				g_esSmashTeammate[iPlayer].g_iSmashCooldown = -1;
				g_esSmashTeammate[iPlayer].g_flSmashCountdown = 0.0;
				g_esSmashTeammate[iPlayer].g_flSmashDelay = -1.0;
				g_esSmashTeammate[iPlayer].g_iSmashHit = -1;
				g_esSmashTeammate[iPlayer].g_iSmashHitMode = -1;
				g_esSmashTeammate[iPlayer].g_flSmashMeter = -1.0;
				g_esSmashTeammate[iPlayer].g_iSmashMode = -1;
				g_esSmashTeammate[iPlayer].g_flSmashRange = -1.0;
				g_esSmashTeammate[iPlayer].g_flSmashRangeChance = -1.0;
				g_esSmashTeammate[iPlayer].g_iSmashRangeCooldown = -1;
				g_esSmashTeammate[iPlayer].g_iSmashRemove = -1;
				g_esSmashTeammate[iPlayer].g_iSmashSight = -1;
				g_esSmashTeammate[iPlayer].g_iSmashType = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esSmashTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esSmashTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmashTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esSmashTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmashTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esSmashTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmashTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esSmashTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmashTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esSmashTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esSmashTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esSmashTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmashTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmashTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esSmashTeammate[admin].g_iSmashAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmashTeammate[admin].g_iSmashAbility, value, -1, 1);
			g_esSmashTeammate[admin].g_iSmashEffect = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmashTeammate[admin].g_iSmashEffect, value, -1, 7);
			g_esSmashTeammate[admin].g_iSmashMessage = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmashTeammate[admin].g_iSmashMessage, value, -1, 3);
			g_esSmashTeammate[admin].g_iSmashSight = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esSmashTeammate[admin].g_iSmashSight, value, -1, 5);
			g_esSmashTeammate[admin].g_iSmashBody = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashBody", "Smash Body", "Smash_Body", "body", g_esSmashTeammate[admin].g_iSmashBody, value, -1, 1);
			g_esSmashTeammate[admin].g_flSmashChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashChance", "Smash Chance", "Smash_Chance", "chance", g_esSmashTeammate[admin].g_flSmashChance, value, -1.0, 100.0);
			g_esSmashTeammate[admin].g_iSmashCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCooldown", "Smash Cooldown", "Smash_Cooldown", "cooldown", g_esSmashTeammate[admin].g_iSmashCooldown, value, -1, 99999);
			g_esSmashTeammate[admin].g_flSmashCountdown = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCountdown", "Smash Countdown", "Smash_Countdown", "countdown", g_esSmashTeammate[admin].g_flSmashCountdown, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_flSmashDelay = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashDelay", "Smash Delay", "Smash_Delay", "delay", g_esSmashTeammate[admin].g_flSmashDelay, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_iSmashHit = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHit", "Smash Hit", "Smash_Hit", "hit", g_esSmashTeammate[admin].g_iSmashHit, value, -1, 1);
			g_esSmashTeammate[admin].g_iSmashHitMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHitMode", "Smash Hit Mode", "Smash_Hit_Mode", "hitmode", g_esSmashTeammate[admin].g_iSmashHitMode, value, -1, 2);
			g_esSmashTeammate[admin].g_flSmashMeter = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMeter", "Smash Meter", "Smash_Meter", "meter", g_esSmashTeammate[admin].g_flSmashMeter, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_iSmashMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMode", "Smash Mode", "Smash_Mode", "mode", g_esSmashTeammate[admin].g_iSmashMode, value, -1, 7);
			g_esSmashTeammate[admin].g_flSmashRange = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRange", "Smash Range", "Smash_Range", "range", g_esSmashTeammate[admin].g_flSmashRange, value, -1.0, 99999.0);
			g_esSmashTeammate[admin].g_flSmashRangeChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeChance", "Smash Range Chance", "Smash_Range_Chance", "rangechance", g_esSmashTeammate[admin].g_flSmashRangeChance, value, -1.0, 100.0);
			g_esSmashTeammate[admin].g_iSmashRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeCooldown", "Smash Range Cooldown", "Smash_Range_Cooldown", "rangecooldown", g_esSmashTeammate[admin].g_iSmashRangeCooldown, value, -1, 99999);
			g_esSmashTeammate[admin].g_iSmashRemove = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRemove", "Smash Remove", "Smash_Remove", "remove", g_esSmashTeammate[admin].g_iSmashRemove, value, -1, 1);
			g_esSmashTeammate[admin].g_iSmashType = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashType", "Smash Type", "Smash_Type", "type", g_esSmashTeammate[admin].g_iSmashType, value, -1, 3);
		}
		else
		{
			g_esSmashPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esSmashPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmashPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esSmashPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmashPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esSmashPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmashPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esSmashPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmashPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esSmashPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esSmashPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esSmashPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmashPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmashPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esSmashPlayer[admin].g_iSmashAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmashPlayer[admin].g_iSmashAbility, value, -1, 1);
			g_esSmashPlayer[admin].g_iSmashEffect = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmashPlayer[admin].g_iSmashEffect, value, -1, 7);
			g_esSmashPlayer[admin].g_iSmashMessage = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmashPlayer[admin].g_iSmashMessage, value, -1, 3);
			g_esSmashPlayer[admin].g_iSmashSight = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esSmashPlayer[admin].g_iSmashSight, value, -1, 5);
			g_esSmashPlayer[admin].g_iSmashBody = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashBody", "Smash Body", "Smash_Body", "body", g_esSmashPlayer[admin].g_iSmashBody, value, -1, 1);
			g_esSmashPlayer[admin].g_flSmashChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashChance", "Smash Chance", "Smash_Chance", "chance", g_esSmashPlayer[admin].g_flSmashChance, value, -1.0, 100.0);
			g_esSmashPlayer[admin].g_iSmashCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCooldown", "Smash Cooldown", "Smash_Cooldown", "cooldown", g_esSmashPlayer[admin].g_iSmashCooldown, value, -1, 99999);
			g_esSmashPlayer[admin].g_flSmashCountdown = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCountdown", "Smash Countdown", "Smash_Countdown", "countdown", g_esSmashPlayer[admin].g_flSmashCountdown, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_flSmashDelay = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashDelay", "Smash Delay", "Smash_Delay", "delay", g_esSmashPlayer[admin].g_flSmashDelay, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_iSmashHit = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHit", "Smash Hit", "Smash_Hit", "hit", g_esSmashPlayer[admin].g_iSmashHit, value, -1, 1);
			g_esSmashPlayer[admin].g_iSmashHitMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHitMode", "Smash Hit Mode", "Smash_Hit_Mode", "hitmode", g_esSmashPlayer[admin].g_iSmashHitMode, value, -1, 2);
			g_esSmashPlayer[admin].g_flSmashMeter = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMeter", "Smash Meter", "Smash_Meter", "meter", g_esSmashPlayer[admin].g_flSmashMeter, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_iSmashMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMode", "Smash Mode", "Smash_Mode", "mode", g_esSmashPlayer[admin].g_iSmashMode, value, -1, 7);
			g_esSmashPlayer[admin].g_flSmashRange = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRange", "Smash Range", "Smash_Range", "range", g_esSmashPlayer[admin].g_flSmashRange, value, -1.0, 99999.0);
			g_esSmashPlayer[admin].g_flSmashRangeChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeChance", "Smash Range Chance", "Smash_Range_Chance", "rangechance", g_esSmashPlayer[admin].g_flSmashRangeChance, value, -1.0, 100.0);
			g_esSmashPlayer[admin].g_iSmashRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeCooldown", "Smash Range Cooldown", "Smash_Range_Cooldown", "rangecooldown", g_esSmashPlayer[admin].g_iSmashRangeCooldown, value, -1, 99999);
			g_esSmashPlayer[admin].g_iSmashRemove = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRemove", "Smash Remove", "Smash_Remove", "remove", g_esSmashPlayer[admin].g_iSmashRemove, value, -1, 1);
			g_esSmashPlayer[admin].g_iSmashType = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashType", "Smash Type", "Smash_Type", "type", g_esSmashPlayer[admin].g_iSmashType, value, -1, 3);
			g_esSmashPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esSmashPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esSmashSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esSmashSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmashSpecial[type].g_iComboAbility, value, -1, 1);
			g_esSmashSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmashSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esSmashSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmashSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esSmashSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmashSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esSmashSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esSmashSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esSmashSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmashSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmashSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esSmashSpecial[type].g_iSmashAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmashSpecial[type].g_iSmashAbility, value, -1, 1);
			g_esSmashSpecial[type].g_iSmashEffect = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmashSpecial[type].g_iSmashEffect, value, -1, 7);
			g_esSmashSpecial[type].g_iSmashMessage = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmashSpecial[type].g_iSmashMessage, value, -1, 3);
			g_esSmashSpecial[type].g_iSmashSight = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esSmashSpecial[type].g_iSmashSight, value, -1, 5);
			g_esSmashSpecial[type].g_iSmashBody = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashBody", "Smash Body", "Smash_Body", "body", g_esSmashSpecial[type].g_iSmashBody, value, -1, 1);
			g_esSmashSpecial[type].g_flSmashChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashChance", "Smash Chance", "Smash_Chance", "chance", g_esSmashSpecial[type].g_flSmashChance, value, -1.0, 100.0);
			g_esSmashSpecial[type].g_iSmashCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCooldown", "Smash Cooldown", "Smash_Cooldown", "cooldown", g_esSmashSpecial[type].g_iSmashCooldown, value, -1, 99999);
			g_esSmashSpecial[type].g_flSmashCountdown = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCountdown", "Smash Countdown", "Smash_Countdown", "countdown", g_esSmashSpecial[type].g_flSmashCountdown, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_flSmashDelay = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashDelay", "Smash Delay", "Smash_Delay", "delay", g_esSmashSpecial[type].g_flSmashDelay, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_iSmashHit = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHit", "Smash Hit", "Smash_Hit", "hit", g_esSmashSpecial[type].g_iSmashHit, value, -1, 1);
			g_esSmashSpecial[type].g_iSmashHitMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHitMode", "Smash Hit Mode", "Smash_Hit_Mode", "hitmode", g_esSmashSpecial[type].g_iSmashHitMode, value, -1, 2);
			g_esSmashSpecial[type].g_flSmashMeter = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMeter", "Smash Meter", "Smash_Meter", "meter", g_esSmashSpecial[type].g_flSmashMeter, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_iSmashMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMode", "Smash Mode", "Smash_Mode", "mode", g_esSmashSpecial[type].g_iSmashMode, value, -1, 7);
			g_esSmashSpecial[type].g_flSmashRange = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRange", "Smash Range", "Smash_Range", "range", g_esSmashSpecial[type].g_flSmashRange, value, -1.0, 99999.0);
			g_esSmashSpecial[type].g_flSmashRangeChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeChance", "Smash Range Chance", "Smash_Range_Chance", "rangechance", g_esSmashSpecial[type].g_flSmashRangeChance, value, -1.0, 100.0);
			g_esSmashSpecial[type].g_iSmashRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeCooldown", "Smash Range Cooldown", "Smash_Range_Cooldown", "rangecooldown", g_esSmashSpecial[type].g_iSmashRangeCooldown, value, -1, 99999);
			g_esSmashSpecial[type].g_iSmashRemove = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRemove", "Smash Remove", "Smash_Remove", "remove", g_esSmashSpecial[type].g_iSmashRemove, value, -1, 1);
			g_esSmashSpecial[type].g_iSmashType = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashType", "Smash Type", "Smash_Type", "type", g_esSmashSpecial[type].g_iSmashType, value, -1, 3);
		}
		else
		{
			g_esSmashAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esSmashAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmashAbility[type].g_iComboAbility, value, -1, 1);
			g_esSmashAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmashAbility[type].g_iHumanAbility, value, -1, 2);
			g_esSmashAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmashAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esSmashAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmashAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esSmashAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esSmashAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esSmashAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmashAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmashAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esSmashAbility[type].g_iSmashAbility = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmashAbility[type].g_iSmashAbility, value, -1, 1);
			g_esSmashAbility[type].g_iSmashEffect = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmashAbility[type].g_iSmashEffect, value, -1, 7);
			g_esSmashAbility[type].g_iSmashMessage = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmashAbility[type].g_iSmashMessage, value, -1, 3);
			g_esSmashAbility[type].g_iSmashSight = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esSmashAbility[type].g_iSmashSight, value, -1, 5);
			g_esSmashAbility[type].g_iSmashBody = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashBody", "Smash Body", "Smash_Body", "body", g_esSmashAbility[type].g_iSmashBody, value, -1, 1);
			g_esSmashAbility[type].g_flSmashChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashChance", "Smash Chance", "Smash_Chance", "chance", g_esSmashAbility[type].g_flSmashChance, value, -1.0, 100.0);
			g_esSmashAbility[type].g_iSmashCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCooldown", "Smash Cooldown", "Smash_Cooldown", "cooldown", g_esSmashAbility[type].g_iSmashCooldown, value, -1, 99999);
			g_esSmashAbility[type].g_flSmashCountdown = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashCountdown", "Smash Countdown", "Smash_Countdown", "countdown", g_esSmashAbility[type].g_flSmashCountdown, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_flSmashDelay = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashDelay", "Smash Delay", "Smash_Delay", "delay", g_esSmashAbility[type].g_flSmashDelay, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_iSmashHit = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHit", "Smash Hit", "Smash_Hit", "hit", g_esSmashAbility[type].g_iSmashHit, value, -1, 1);
			g_esSmashAbility[type].g_iSmashHitMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashHitMode", "Smash Hit Mode", "Smash_Hit_Mode", "hitmode", g_esSmashAbility[type].g_iSmashHitMode, value, -1, 2);
			g_esSmashAbility[type].g_flSmashMeter = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMeter", "Smash Meter", "Smash_Meter", "meter", g_esSmashAbility[type].g_flSmashMeter, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_iSmashMode = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashMode", "Smash Mode", "Smash_Mode", "mode", g_esSmashAbility[type].g_iSmashMode, value, -1, 7);
			g_esSmashAbility[type].g_flSmashRange = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRange", "Smash Range", "Smash_Range", "range", g_esSmashAbility[type].g_flSmashRange, value, -1.0, 99999.0);
			g_esSmashAbility[type].g_flSmashRangeChance = flGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeChance", "Smash Range Chance", "Smash_Range_Chance", "rangechance", g_esSmashAbility[type].g_flSmashRangeChance, value, -1.0, 100.0);
			g_esSmashAbility[type].g_iSmashRangeCooldown = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRangeCooldown", "Smash Range Cooldown", "Smash_Range_Cooldown", "rangecooldown", g_esSmashAbility[type].g_iSmashRangeCooldown, value, -1, 99999);
			g_esSmashAbility[type].g_iSmashRemove = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashRemove", "Smash Remove", "Smash_Remove", "remove", g_esSmashAbility[type].g_iSmashRemove, value, -1, 1);
			g_esSmashAbility[type].g_iSmashType = iGetKeyValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "SmashType", "Smash Type", "Smash_Type", "type", g_esSmashAbility[type].g_iSmashType, value, -1, 3);
			g_esSmashAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esSmashAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_SMASH_SECTION, MT_SMASH_SECTION2, MT_SMASH_SECTION3, MT_SMASH_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esSmashPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esSmashPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esSmashPlayer[tank].g_iTankTypeRecorded;
#if !defined MT_ABILITIES_MAIN2
	g_iGraphicsLevel = MT_GetGraphicsLevel();
#endif
	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esSmashCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flCloseAreasOnly, g_esSmashPlayer[tank].g_flCloseAreasOnly, g_esSmashSpecial[iType].g_flCloseAreasOnly, g_esSmashAbility[iType].g_flCloseAreasOnly, 1);
		g_esSmashCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iComboAbility, g_esSmashPlayer[tank].g_iComboAbility, g_esSmashSpecial[iType].g_iComboAbility, g_esSmashAbility[iType].g_iComboAbility, 1);
		g_esSmashCache[tank].g_flSmashChance = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashChance, g_esSmashPlayer[tank].g_flSmashChance, g_esSmashSpecial[iType].g_flSmashChance, g_esSmashAbility[iType].g_flSmashChance, 1);
		g_esSmashCache[tank].g_flSmashCountdown = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashCountdown, g_esSmashPlayer[tank].g_flSmashCountdown, g_esSmashSpecial[iType].g_flSmashCountdown, g_esSmashAbility[iType].g_flSmashCountdown, 1);
		g_esSmashCache[tank].g_flSmashDelay = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashDelay, g_esSmashPlayer[tank].g_flSmashDelay, g_esSmashSpecial[iType].g_flSmashDelay, g_esSmashAbility[iType].g_flSmashDelay, 1);
		g_esSmashCache[tank].g_flSmashMeter = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashMeter, g_esSmashPlayer[tank].g_flSmashMeter, g_esSmashSpecial[iType].g_flSmashMeter, g_esSmashAbility[iType].g_flSmashMeter, 1);
		g_esSmashCache[tank].g_flSmashRange = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashRange, g_esSmashPlayer[tank].g_flSmashRange, g_esSmashSpecial[iType].g_flSmashRange, g_esSmashAbility[iType].g_flSmashRange, 1);
		g_esSmashCache[tank].g_flSmashRangeChance = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flSmashRangeChance, g_esSmashPlayer[tank].g_flSmashRangeChance, g_esSmashSpecial[iType].g_flSmashRangeChance, g_esSmashAbility[iType].g_flSmashRangeChance, 1);
		g_esSmashCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iHumanAbility, g_esSmashPlayer[tank].g_iHumanAbility, g_esSmashSpecial[iType].g_iHumanAbility, g_esSmashAbility[iType].g_iHumanAbility, 1);
		g_esSmashCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iHumanAmmo, g_esSmashPlayer[tank].g_iHumanAmmo, g_esSmashSpecial[iType].g_iHumanAmmo, g_esSmashAbility[iType].g_iHumanAmmo, 1);
		g_esSmashCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iHumanCooldown, g_esSmashPlayer[tank].g_iHumanCooldown, g_esSmashSpecial[iType].g_iHumanCooldown, g_esSmashAbility[iType].g_iHumanCooldown, 1);
		g_esSmashCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iHumanRangeCooldown, g_esSmashPlayer[tank].g_iHumanRangeCooldown, g_esSmashSpecial[iType].g_iHumanRangeCooldown, g_esSmashAbility[iType].g_iHumanRangeCooldown, 1);
		g_esSmashCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_flOpenAreasOnly, g_esSmashPlayer[tank].g_flOpenAreasOnly, g_esSmashSpecial[iType].g_flOpenAreasOnly, g_esSmashAbility[iType].g_flOpenAreasOnly, 1);
		g_esSmashCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iRequiresHumans, g_esSmashPlayer[tank].g_iRequiresHumans, g_esSmashSpecial[iType].g_iRequiresHumans, g_esSmashAbility[iType].g_iRequiresHumans, 1);
		g_esSmashCache[tank].g_iSmashAbility = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashAbility, g_esSmashPlayer[tank].g_iSmashAbility, g_esSmashSpecial[iType].g_iSmashAbility, g_esSmashAbility[iType].g_iSmashAbility, 1);
		g_esSmashCache[tank].g_iSmashBody = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashBody, g_esSmashPlayer[tank].g_iSmashBody, g_esSmashSpecial[iType].g_iSmashBody, g_esSmashAbility[iType].g_iSmashBody, 1);
		g_esSmashCache[tank].g_iSmashCooldown = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashCooldown, g_esSmashPlayer[tank].g_iSmashCooldown, g_esSmashSpecial[iType].g_iSmashCooldown, g_esSmashAbility[iType].g_iSmashCooldown, 1);
		g_esSmashCache[tank].g_iSmashEffect = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashEffect, g_esSmashPlayer[tank].g_iSmashEffect, g_esSmashSpecial[iType].g_iSmashEffect, g_esSmashAbility[iType].g_iSmashEffect, 1);
		g_esSmashCache[tank].g_iSmashHit = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashHit, g_esSmashPlayer[tank].g_iSmashHit, g_esSmashSpecial[iType].g_iSmashHit, g_esSmashAbility[iType].g_iSmashHit, 1);
		g_esSmashCache[tank].g_iSmashHitMode = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashHitMode, g_esSmashPlayer[tank].g_iSmashHitMode, g_esSmashSpecial[iType].g_iSmashHitMode, g_esSmashAbility[iType].g_iSmashHitMode, 1);
		g_esSmashCache[tank].g_iSmashMessage = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashMessage, g_esSmashPlayer[tank].g_iSmashMessage, g_esSmashSpecial[iType].g_iSmashMessage, g_esSmashAbility[iType].g_iSmashMessage, 1);
		g_esSmashCache[tank].g_iSmashMode = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashMode, g_esSmashPlayer[tank].g_iSmashMode, g_esSmashSpecial[iType].g_iSmashMode, g_esSmashAbility[iType].g_iSmashMode, 1);
		g_esSmashCache[tank].g_iSmashRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashRangeCooldown, g_esSmashPlayer[tank].g_iSmashRangeCooldown, g_esSmashSpecial[iType].g_iSmashRangeCooldown, g_esSmashAbility[iType].g_iSmashRangeCooldown, 1);
		g_esSmashCache[tank].g_iSmashRemove = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashRemove, g_esSmashPlayer[tank].g_iSmashRemove, g_esSmashSpecial[iType].g_iSmashRemove, g_esSmashAbility[iType].g_iSmashRemove, 1);
		g_esSmashCache[tank].g_iSmashSight = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashSight, g_esSmashPlayer[tank].g_iSmashSight, g_esSmashSpecial[iType].g_iSmashSight, g_esSmashAbility[iType].g_iSmashSight, 1);
		g_esSmashCache[tank].g_iSmashType = iGetSubSettingValue(apply, bHuman, g_esSmashTeammate[tank].g_iSmashType, g_esSmashPlayer[tank].g_iSmashType, g_esSmashSpecial[iType].g_iSmashType, g_esSmashAbility[iType].g_iSmashType, 1);
	}
	else
	{
		g_esSmashCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flCloseAreasOnly, g_esSmashAbility[iType].g_flCloseAreasOnly, 1);
		g_esSmashCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iComboAbility, g_esSmashAbility[iType].g_iComboAbility, 1);
		g_esSmashCache[tank].g_flSmashChance = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashChance, g_esSmashAbility[iType].g_flSmashChance, 1);
		g_esSmashCache[tank].g_flSmashCountdown = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashCountdown, g_esSmashAbility[iType].g_flSmashCountdown, 1);
		g_esSmashCache[tank].g_flSmashDelay = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashDelay, g_esSmashAbility[iType].g_flSmashDelay, 1);
		g_esSmashCache[tank].g_flSmashMeter = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashMeter, g_esSmashAbility[iType].g_flSmashMeter, 1);
		g_esSmashCache[tank].g_flSmashRange = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashRange, g_esSmashAbility[iType].g_flSmashRange, 1);
		g_esSmashCache[tank].g_flSmashRangeChance = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flSmashRangeChance, g_esSmashAbility[iType].g_flSmashRangeChance, 1);
		g_esSmashCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iHumanAbility, g_esSmashAbility[iType].g_iHumanAbility, 1);
		g_esSmashCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iHumanAmmo, g_esSmashAbility[iType].g_iHumanAmmo, 1);
		g_esSmashCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iHumanCooldown, g_esSmashAbility[iType].g_iHumanCooldown, 1);
		g_esSmashCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iHumanRangeCooldown, g_esSmashAbility[iType].g_iHumanRangeCooldown, 1);
		g_esSmashCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_flOpenAreasOnly, g_esSmashAbility[iType].g_flOpenAreasOnly, 1);
		g_esSmashCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iRequiresHumans, g_esSmashAbility[iType].g_iRequiresHumans, 1);
		g_esSmashCache[tank].g_iSmashAbility = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashAbility, g_esSmashAbility[iType].g_iSmashAbility, 1);
		g_esSmashCache[tank].g_iSmashBody = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashBody, g_esSmashAbility[iType].g_iSmashBody, 1);
		g_esSmashCache[tank].g_iSmashCooldown = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashCooldown, g_esSmashAbility[iType].g_iSmashCooldown, 1);
		g_esSmashCache[tank].g_iSmashEffect = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashEffect, g_esSmashAbility[iType].g_iSmashEffect, 1);
		g_esSmashCache[tank].g_iSmashHit = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashHit, g_esSmashAbility[iType].g_iSmashHit, 1);
		g_esSmashCache[tank].g_iSmashHitMode = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashHitMode, g_esSmashAbility[iType].g_iSmashHitMode, 1);
		g_esSmashCache[tank].g_iSmashMessage = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashMessage, g_esSmashAbility[iType].g_iSmashMessage, 1);
		g_esSmashCache[tank].g_iSmashMode = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashMode, g_esSmashAbility[iType].g_iSmashMode, 1);
		g_esSmashCache[tank].g_iSmashRangeCooldown = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashRangeCooldown, g_esSmashAbility[iType].g_iSmashRangeCooldown, 1);
		g_esSmashCache[tank].g_iSmashRemove = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashRemove, g_esSmashAbility[iType].g_iSmashRemove, 1);
		g_esSmashCache[tank].g_iSmashSight = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashSight, g_esSmashAbility[iType].g_iSmashSight, 1);
		g_esSmashCache[tank].g_iSmashType = iGetSettingValue(apply, bHuman, g_esSmashPlayer[tank].g_iSmashType, g_esSmashAbility[iType].g_iSmashType, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vSmashCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveSmash(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vSmashPluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esSmashPlayer[iSurvivor].g_bAffected)
		{
			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashEventFired(Event event, const char[] name)
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
			vSmashCopyStats2(iBot, iTank);
			vRemoveSmash(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vSmashReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vSmashCopyStats2(iTank, iBot);
			vRemoveSmash(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveSmash(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vSmashHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esSmashCache[iBoomer].g_flSmashChance, g_esSmashCache[iBoomer].g_iSmashHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashPlayerEventKilled(int victim, int attacker)
#else
public void MT_OnPlayerEventKilled(int victim, int attacker)
#endif
{
	if (bIsSurvivor(victim, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsTankSupported(attacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(attacker) && g_esSmashCache[attacker].g_iSmashAbility == 1 && g_esSmashCache[attacker].g_iSmashBody == 1)
	{
		g_iSmashDeathModelOwner = GetClientUserId(victim);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[tank].g_iAccessFlags)) || g_esSmashCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esSmashCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esSmashCache[tank].g_iSmashAbility == 1 && g_esSmashCache[tank].g_iComboAbility == 0)
	{
		vSmashAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esSmashCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esSmashCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[tank].g_iTankType, tank) || (g_esSmashCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esSmashCache[tank].g_iSmashAbility == 1 && g_esSmashCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esSmashPlayer[tank].g_iRangeCooldown == -1 || g_esSmashPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vSmashAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman3", (g_esSmashPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSmashChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveSmash(tank);
}

void vSmash(int tank, int survivor)
{
	switch (g_esSmashCache[tank].g_iSmashType)
	{
		case 0, 3:
		{
			switch (MT_GetRandomInt(1, 2))
			{
				case 1:
				{
					SetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1);
					SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", 1.0);
					vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")), "128");
				}
				case 2: vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")), "128");
			}
		}
		case 1:
		{
			SetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1);
			SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", 1.0);
			vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")), "128");
		}
		case 2: vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")), "128");
	}
}

void vSmashRocket(int tank, int survivor, int enabled, int messages, int pos = -1)
{
	float flDelay = (pos != -1) ? 0.1 : g_esSmashCache[tank].g_flSmashDelay;
	if (flDelay > 0.0)
	{
		DataPack dpSmashLaunch;
		CreateDataTimer(flDelay, tTimerSmashLaunch, dpSmashLaunch, TIMER_FLAG_NO_MAPCHANGE);
		dpSmashLaunch.WriteCell(GetClientUserId(survivor));
		dpSmashLaunch.WriteCell(GetClientUserId(tank));
		dpSmashLaunch.WriteCell(g_esSmashPlayer[tank].g_iTankType);
		dpSmashLaunch.WriteCell(enabled);

		DataPack dpSmashDetonate;
		CreateDataTimer((flDelay + 1.5), tTimerSmashDetonate, dpSmashDetonate, TIMER_FLAG_NO_MAPCHANGE);
		dpSmashDetonate.WriteCell(GetClientUserId(survivor));
		dpSmashDetonate.WriteCell(GetClientUserId(tank));
		dpSmashDetonate.WriteCell(g_esSmashPlayer[tank].g_iTankType);
		dpSmashDetonate.WriteCell(enabled);
		dpSmashDetonate.WriteCell(messages);
	}
}

void vSmashSmite(int tank, int survivor, int messages, int flags)
{
	vSmashSmite2(survivor);
	vScreenEffect(survivor, tank, g_esSmashCache[tank].g_iSmashEffect, flags);
	vSmash(tank, survivor);

	if (g_esSmashCache[tank].g_iSmashMessage & messages)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Smash4", sTankName, survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smash4", LANG_SERVER, sTankName, survivor);
	}
}

void vSmashSmite2(int survivor)
{
	float flPos[3], flStartPos[3];
	int iColor[4] = {255, 255, 255, 255};

	GetClientAbsOrigin(survivor, flPos);
	flPos[2] -= 26.0;
	flStartPos[0] = (flPos[0] + MT_GetRandomFloat(-500.0, 500.0));
	flStartPos[1] = (flPos[1] + MT_GetRandomFloat(-500.0, 500.0));
	flStartPos[2] = (flPos[2] + 800.0);

	if (g_iGraphicsLevel > 2)
	{
		TE_SetupBeamPoints(flStartPos, flPos, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();

		TE_SetupSparks(flPos, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
		TE_SendToAll();

		TE_SetupEnergySplash(flPos, view_as<float>({0.0, 0.0, 0.0}), false);
		TE_SendToAll();
	}

	EmitAmbientSound(SOUND_EXPLOSION, flStartPos, survivor, SNDLEVEL_RAIDSIREN);
}

void vSmashAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esSmashCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esSmashCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[tank].g_iTankType, tank) || (g_esSmashCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esSmashPlayer[tank].g_iAmmoCount < g_esSmashCache[tank].g_iHumanAmmo && g_esSmashCache[tank].g_iHumanAmmo > 0))
	{
		g_esSmashPlayer[tank].g_bFailed = false;
		g_esSmashPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esSmashCache[tank].g_flSmashRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esSmashCache[tank].g_flSmashRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esSmashPlayer[tank].g_iTankType, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esSmashCache[tank].g_iSmashSight, .range = flRange))
				{
					vSmashHit(iSurvivor, tank, random, flChance, g_esSmashCache[tank].g_iSmashAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashAmmo");
	}
}

void vSmashHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esSmashCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esSmashCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[tank].g_iTankType, tank) || (g_esSmashCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esSmashPlayer[tank].g_iTankType, g_esSmashAbility[g_esSmashPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esSmashPlayer[tank].g_iRangeCooldown != -1 && g_esSmashPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esSmashPlayer[tank].g_iCooldown != -1 && g_esSmashPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esSmashPlayer[tank].g_iAmmoCount < g_esSmashCache[tank].g_iHumanAmmo && g_esSmashCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esSmashCache[tank].g_iSmashSight, .range = 100.0))
				{
					return;
				}

				if (g_esSmashCache[tank].g_flSmashMeter <= 0.0 || (0.0 < g_esSmashCache[tank].g_flSmashMeter <= g_esSmashPlayer[tank].g_flDamage))
				{
					int iCooldown = -1;
					if ((flags & MT_ATTACK_RANGE) && (g_esSmashPlayer[tank].g_iRangeCooldown == -1 || g_esSmashPlayer[tank].g_iRangeCooldown <= iTime))
					{
						if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1)
						{
							g_esSmashPlayer[tank].g_iAmmoCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman", g_esSmashPlayer[tank].g_iAmmoCount, g_esSmashCache[tank].g_iHumanAmmo);
						}

						iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esSmashCache[tank].g_iSmashRangeCooldown;
						iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1 && g_esSmashPlayer[tank].g_iAmmoCount < g_esSmashCache[tank].g_iHumanAmmo && g_esSmashCache[tank].g_iHumanAmmo > 0) ? g_esSmashCache[tank].g_iHumanRangeCooldown : iCooldown;
						g_esSmashPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
						if (g_esSmashPlayer[tank].g_iRangeCooldown != -1 && g_esSmashPlayer[tank].g_iRangeCooldown >= iTime)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman5", (g_esSmashPlayer[tank].g_iRangeCooldown - iTime));
						}
					}
					else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esSmashPlayer[tank].g_iCooldown == -1 || g_esSmashPlayer[tank].g_iCooldown <= iTime))
					{
						iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esSmashCache[tank].g_iSmashCooldown;
						iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1) ? g_esSmashCache[tank].g_iHumanCooldown : iCooldown;
						g_esSmashPlayer[tank].g_iCooldown = (iTime + iCooldown);
						if (g_esSmashPlayer[tank].g_iCooldown != -1 && g_esSmashPlayer[tank].g_iCooldown >= iTime)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman5", (g_esSmashPlayer[tank].g_iCooldown - iTime));
						}
					}

					if (g_esSmashCache[tank].g_iSmashMode & MT_SMASH_POUND)
					{
						if (g_iGraphicsLevel > 2)
						{
							vAttachParticle(survivor, PARTICLE_BLOOD, 0.1);
							vAttachParticle(tank, PARTICLE_BLOOD, 0.1);
						}

						switch (g_bSecondGame)
						{
							case true:
							{
								EmitSoundToAll(SOUND_SMASH2, survivor);
								EmitSoundToAll(SOUND_GROWL2, tank);
							}
							case false:
							{
								EmitSoundToAll(SOUND_SMASH1, survivor);
								EmitSoundToAll(SOUND_GROWL1, tank);
							}
						}

						vSmash(tank, survivor);
					}

					if (g_esSmashCache[tank].g_iSmashMode & MT_SMASH_ROCKET)
					{
						int iFlame = CreateEntityByName("env_steam");
						if (bIsValidEntity(iFlame))
						{
							float flPos[3], flAngles[3];
							GetEntPropVector(survivor, Prop_Data, "m_vecOrigin", flPos);
							flPos[2] += 30.0;
							flAngles[0] = 90.0;
							flAngles[1] = 0.0;
							flAngles[2] = 0.0;

							DispatchKeyValueInt(iFlame, "spawnflags", 1);
							DispatchKeyValueInt(iFlame, "Type", 0);
							DispatchKeyValueInt(iFlame, "InitialState", 1);
							DispatchKeyValueInt(iFlame, "Spreadspeed", 10);
							DispatchKeyValueInt(iFlame, "Speed", 800);
							DispatchKeyValueInt(iFlame, "Startsize", 10);
							DispatchKeyValueInt(iFlame, "EndSize", 250);
							DispatchKeyValueInt(iFlame, "Rate", 15);
							DispatchKeyValueInt(iFlame, "JetLength", 400);

							SetEntityRenderColor(iFlame, 180, 70, 10, 180);
							TeleportEntity(iFlame, flPos, flAngles);
							DispatchSpawn(iFlame);
							vSetEntityParent(iFlame, survivor);

							iFlame = EntIndexToEntRef(iFlame);
							vDeleteEntity(iFlame, (3.0 + g_esSmashCache[tank].g_flSmashCountdown));

							vScreenEffect(survivor, tank, g_esSmashCache[tank].g_iSmashEffect, flags);
							EmitSoundToAll(SOUND_FIRE, survivor);

							switch (g_esSmashCache[tank].g_flSmashCountdown > 0.0)
							{
								case true:
								{
									DataPack dpSmash;
									CreateDataTimer(g_esSmashCache[tank].g_flSmashCountdown, tTimerSmash, dpSmash, TIMER_FLAG_NO_MAPCHANGE);
									dpSmash.WriteCell(GetClientUserId(survivor));
									dpSmash.WriteCell(GetClientUserId(tank));
									dpSmash.WriteCell(enabled);
									dpSmash.WriteCell(messages);
									dpSmash.WriteCell(pos);
								}
								case false: vSmashRocket(tank, survivor, enabled, messages, pos);
							}
						}
					}

					if (g_esSmashCache[tank].g_iSmashMode & MT_SMASH_SMITE)
					{
						if (g_esSmashCache[tank].g_flSmashCountdown > 0.0)
						{
							g_esSmashPlayer[survivor].g_bAffected = true;
							g_esSmashPlayer[survivor].g_iOwner = tank;

							DataPack dpSmash;
							CreateDataTimer(g_esSmashCache[tank].g_flSmashCountdown, tTimerSmash2, dpSmash, TIMER_FLAG_NO_MAPCHANGE);
							dpSmash.WriteCell(GetClientUserId(survivor));
							dpSmash.WriteCell(GetClientUserId(tank));
							dpSmash.WriteCell(messages);
							dpSmash.WriteCell(flags);
						}
						else
						{
							vSmashSmite(tank, survivor, messages, flags);
						}
					}

					if (g_esSmashCache[tank].g_iSmashRemove == 1)
					{
						SDKHooks_TakeDamage(tank, survivor, survivor, float(GetEntProp(tank, Prop_Data, "m_iHealth")), DMG_CLUB);
					}

					vScreenEffect(survivor, tank, g_esSmashCache[tank].g_iSmashEffect, flags);

					if (g_esSmashCache[tank].g_iSmashMessage & messages)
					{
						char sTankName[64];
						MT_GetTankName(tank, sTankName);

						switch (!!g_esSmashCache[tank].g_iSmashRemove)
						{
							case true:
							{
								MT_PrintToChatAll("%s %t", MT_TAG2, "Smash2", sTankName, survivor);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smash2", LANG_SERVER, sTankName, survivor);
							}
							case false:
							{
								MT_PrintToChatAll("%s %t", MT_TAG2, "Smash", sTankName, survivor);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smash", LANG_SERVER, sTankName, survivor);
							}
						}
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esSmashPlayer[tank].g_iRangeCooldown == -1 || g_esSmashPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1 && !g_esSmashPlayer[tank].g_bFailed)
				{
					g_esSmashPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esSmashCache[tank].g_iHumanAbility == 1 && !g_esSmashPlayer[tank].g_bNoAmmo)
		{
			g_esSmashPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmashAmmo");
		}
	}
}

void vSmashCopyStats2(int oldTank, int newTank)
{
	g_esSmashPlayer[newTank].g_flDamage = g_esSmashPlayer[oldTank].g_flDamage;
	g_esSmashPlayer[newTank].g_iAmmoCount = g_esSmashPlayer[oldTank].g_iAmmoCount;
	g_esSmashPlayer[newTank].g_iCooldown = g_esSmashPlayer[oldTank].g_iCooldown;
	g_esSmashPlayer[newTank].g_iRangeCooldown = g_esSmashPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveSmash(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME) && g_esSmashPlayer[iSurvivor].g_bAffected && g_esSmashPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esSmashPlayer[iSurvivor].g_bAffected = false;
			g_esSmashPlayer[iSurvivor].g_iOwner = -1;
		}
	}

	vSmashReset3(tank);
}

void vSmashReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vSmashReset3(iPlayer);

			g_esSmashPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vSmashReset2(int survivor)
{
	g_esSmashPlayer[survivor].g_bAffected = false;
	g_esSmashPlayer[survivor].g_iOwner = -1;

	SetEntityGravity(survivor, 1.0);
}

void vSmashReset3(int tank)
{
	g_esSmashPlayer[tank].g_bAffected = false;
	g_esSmashPlayer[tank].g_bFailed = false;
	g_esSmashPlayer[tank].g_bNoAmmo = false;
	g_esSmashPlayer[tank].g_flDamage = 0.0;
	g_esSmashPlayer[tank].g_iAmmoCount = 0;
	g_esSmashPlayer[tank].g_iCooldown = -1;
	g_esSmashPlayer[tank].g_iRangeCooldown = -1;
}

Action tTimerSmash(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esSmashPlayer[iSurvivor].g_bAffected = false;
		g_esSmashPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iSmashEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esSmashCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esSmashCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[iTank].g_iTankType, iTank) || (g_esSmashCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmashPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esSmashPlayer[iTank].g_iTankType, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[iSurvivor].g_iImmunityFlags) || iSmashEnabled == 0 || !g_esSmashPlayer[iSurvivor].g_bAffected || MT_DoesSurvivorHaveRewardType(iSurvivor, MT_REWARD_GODMODE))
	{
		vSmashReset2(iSurvivor);

		return Plugin_Stop;
	}

	int iMessage = pack.ReadCell(), iPos = pack.ReadCell();
	vSmashRocket(iTank, iSurvivor, iSmashEnabled, iMessage, iPos);

	return Plugin_Continue;
}

Action tTimerSmash2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esSmashPlayer[iSurvivor].g_bAffected = false;
		g_esSmashPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !MT_IsCustomTankSupported(iTank))
	{
		g_esSmashPlayer[iSurvivor].g_bAffected = false;
		g_esSmashPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iMessage = pack.ReadCell(), iFlags = pack.ReadCell();
	g_esSmashPlayer[iSurvivor].g_bAffected = false;
	g_esSmashPlayer[iSurvivor].g_iOwner = -1;

	vSmashSmite(iTank, iSurvivor, iMessage, iFlags);

	return Plugin_Continue;
}

Action tTimerSmashCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmashPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esSmashCache[iTank].g_iSmashAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vSmashAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

Action tTimerSmashCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmashPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esSmashCache[iTank].g_iSmashHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esSmashCache[iTank].g_iSmashHitMode == 0 || g_esSmashCache[iTank].g_iSmashHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vSmashHit(iSurvivor, iTank, flRandom, flChance, g_esSmashCache[iTank].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esSmashCache[iTank].g_iSmashHitMode == 0 || g_esSmashCache[iTank].g_iSmashHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vSmashHit(iSurvivor, iTank, flRandom, flChance, g_esSmashCache[iTank].g_iSmashHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}

	return Plugin_Continue;
}

Action tTimerSmashLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esSmashPlayer[iSurvivor].g_bAffected = false;
		g_esSmashPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iSmashEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esSmashCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esSmashCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[iTank].g_iTankType, iTank) || (g_esSmashCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmashPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esSmashPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esSmashPlayer[iTank].g_iTankType, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[iSurvivor].g_iImmunityFlags) || iSmashEnabled == 0 || !g_esSmashPlayer[iSurvivor].g_bAffected || MT_DoesSurvivorHaveRewardType(iSurvivor, MT_REWARD_GODMODE))
	{
		vSmashReset2(iSurvivor);

		return Plugin_Stop;
	}

	float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = 800.0;

	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor);

	TeleportEntity(iSurvivor, .velocity = flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	return Plugin_Continue;
}

Action tTimerSmashDetonate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esSmashPlayer[iSurvivor].g_bAffected = false;
		g_esSmashPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iSmashEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esSmashCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esSmashCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esSmashPlayer[iTank].g_iTankType, iTank) || (g_esSmashCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmashCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esSmashPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmashPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esSmashPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esSmashPlayer[iTank].g_iTankType, g_esSmashAbility[g_esSmashPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esSmashPlayer[iSurvivor].g_iImmunityFlags) || iSmashEnabled == 0 || !g_esSmashPlayer[iSurvivor].g_bAffected || MT_DoesSurvivorHaveRewardType(iSurvivor, MT_REWARD_GODMODE))
	{
		vSmashReset2(iSurvivor);

		return Plugin_Stop;
	}

	g_esSmashPlayer[iSurvivor].g_bAffected = false;
	g_esSmashPlayer[iSurvivor].g_iOwner = -1;

	SetEntityGravity(iSurvivor, 1.0);

	if (g_iGraphicsLevel > 2)
	{
		float flPos[3];
		GetClientAbsOrigin(iSurvivor, flPos);
		TE_SetupExplosion(flPos, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
		TE_SendToAll();
	}

	if (g_esSmashCache[iTank].g_flSmashCountdown <= 0.0 || !bIsAreaNarrow(iSurvivor))
	{
		vSmash(iTank, iSurvivor);

		int iMessage = pack.ReadCell();
		if (g_esSmashCache[iTank].g_iSmashMessage & iMessage)
		{
			char sTankName[64];
			MT_GetTankName(iTank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Smash3", sTankName, iSurvivor);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smash3", LANG_SERVER, sTankName, iSurvivor);
		}
	}

	return Plugin_Continue;
}