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

#define MT_CAR_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_CAR_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Car Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates car showers.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Car Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"
#else
	#if MT_CAR_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_CAR_SECTION "carability"
#define MT_CAR_SECTION2 "car ability"
#define MT_CAR_SECTION3 "car_ability"
#define MT_CAR_SECTION4 "car"

#define MT_MENU_CAR "Car Ability"

enum struct esCarGeneral
{
	int g_iCar[2048];
	int g_iCarOwner[2048];
}

esCarGeneral g_esCarGeneral;

enum struct esCarPlayer
{
	bool g_bActivated;

	float g_flCarChance;
	float g_flCarDamage;
	float g_flCarInterval;
	float g_flCarLifetime;
	float g_flCarRadius[2];
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iCarAbility;
	int g_iCarCooldown;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCarOwner;
	int g_iCooldown;
	int g_iComboAbility;
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

esCarPlayer g_esCarPlayer[MAXPLAYERS + 1];

enum struct esCarTeammate
{
	float g_flCarChance;
	float g_flCarDamage;
	float g_flCarInterval;
	float g_flCarLifetime;
	float g_flCarRadius[2];
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iCarAbility;
	int g_iCarCooldown;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCarOwner;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCarTeammate g_esCarTeammate[MAXPLAYERS + 1];

enum struct esCarAbility
{
	float g_flCarChance;
	float g_flCarDamage;
	float g_flCarInterval;
	float g_flCarLifetime;
	float g_flCarRadius[2];
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iCarAbility;
	int g_iCarCooldown;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCarOwner;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esCarAbility g_esCarAbility[MT_MAXTYPES + 1];

enum struct esCarSpecial
{
	float g_flCarChance;
	float g_flCarDamage;
	float g_flCarInterval;
	float g_flCarLifetime;
	float g_flCarRadius[2];
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iCarAbility;
	int g_iCarCooldown;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCarOwner;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCarSpecial g_esCarSpecial[MT_MAXTYPES + 1];

enum struct esCarCache
{
	float g_flCarChance;
	float g_flCarDamage;
	float g_flCarInterval;
	float g_flCarLifetime;
	float g_flCarRadius[2];
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iCarAbility;
	int g_iCarCooldown;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCarOwner;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCarCache g_esCarCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_car", cmdCarInfo, "View information about the Car ability.");
}
#endif

#if defined MT_ABILITIES_MAIN
void vCarMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);

	vCarReset();
}

#if defined MT_ABILITIES_MAIN
void vCarClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnCarTakeDamage);
	vRemoveCar(client);
}

#if defined MT_ABILITIES_MAIN
void vCarClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveCar(client);
}

#if defined MT_ABILITIES_MAIN
void vCarMapEnd()
#else
public void OnMapEnd()
#endif
{
	vCarReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdCarInfo(int client, int args)
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
		case false: vCarMenu(client, MT_CAR_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vCarMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_CAR_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iCarMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Car Ability Information");
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

int iCarMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esCarCache[param1].g_iCarAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esCarCache[param1].g_iHumanAmmo - g_esCarPlayer[param1].g_iAmmoCount), g_esCarCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3:
				{
					switch (g_esCarCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esCarCache[param1].g_iHumanAbility == 1) ? g_esCarCache[param1].g_iHumanCooldown : g_esCarCache[param1].g_iCarCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "CarDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esCarCache[param1].g_iHumanAbility == 1) ? g_esCarCache[param1].g_iHumanDuration : g_esCarCache[param1].g_iCarDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esCarCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vCarMenu(param1, MT_CAR_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pCar = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "CarMenu", param1);
			pCar.SetTitle(sMenuTitle);
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
void vCarDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_CAR, MT_MENU_CAR);
}

#if defined MT_ABILITIES_MAIN
void vCarMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_CAR, false))
	{
		vCarMenu(client, MT_CAR_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vCarMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_CAR, false))
	{
		FormatEx(buffer, size, "%T", "CarMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN
void vCarEntityDestroyed(int entity)
#else
public void OnEntityDestroyed(int entity)
#endif
{
	if (bIsValidEntity(entity))
	{
		g_esCarGeneral.g_iCar[entity] = INVALID_ENT_REFERENCE;
		g_esCarGeneral.g_iCarOwner[entity] = -1;
	}
}

Action OnCarTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsSurvivor(victim) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		int iCar = EntRefToEntIndex(g_esCarGeneral.g_iCar[inflictor]);
		if (iCar > MaxClients && iCar == inflictor)
		{
			int iTank = g_esCarGeneral.g_iCarOwner[iCar];
			if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank))
			{
				if ((!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esCarAbility[g_esCarPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[iTank].g_iAccessFlags)) || MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esCarPlayer[iTank].g_iTankType, g_esCarAbility[g_esCarPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esCarPlayer[victim].g_iImmunityFlags))
				{
					return Plugin_Handled;
				}

				int iPos = g_esCarAbility[g_esCarPlayer[iTank].g_iTankTypeRecorded].g_iComboPosition;
				float flDamage = (iPos != -1) ? MT_GetCombinationSetting(iTank, 3, iPos) : g_esCarCache[iTank].g_flCarDamage;
				damage = MT_GetScaledDamage(flDamage);

				return (damage > 0.0) ? Plugin_Changed : Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

Action OnCarStartTouch(int car, int other)
{
	if (bIsValidEntity(car) && bIsValidEntity(other))
	{
		TeleportEntity(car, .velocity = view_as<float>({0.0, 0.0, 0.0}));
		SDKUnhook(car, SDKHook_StartTouch, OnCarStartTouch);
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vCarPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_CAR);
}

#if defined MT_ABILITIES_MAIN
void vCarAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_CAR_SECTION);
	list2.PushString(MT_CAR_SECTION2);
	list3.PushString(MT_CAR_SECTION3);
	list4.PushString(MT_CAR_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vCarCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility != 2)
	{
		g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_CAR_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_CAR_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_CAR_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_CAR_SECTION4);
	if (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCarCache[tank].g_iCarAbility == 1 && g_esCarCache[tank].g_iComboAbility == 1 && !g_esCarPlayer[tank].g_bActivated)
		{
			char sAbilities[320], sSubset[10][32];
			strcopy(sAbilities, sizeof sAbilities, combo);
			ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

			float flDelay = 0.0;
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CAR_SECTION, false) || StrEqual(sSubset[iPos], MT_CAR_SECTION2, false) || StrEqual(sSubset[iPos], MT_CAR_SECTION3, false) || StrEqual(sSubset[iPos], MT_CAR_SECTION4, false))
				{
					g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;

					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						flDelay = MT_GetCombinationSetting(tank, 4, iPos);

						switch (flDelay)
						{
							case 0.0: vCar(tank);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCarCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
void vCarConfigsLoad(int mode)
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
				g_esCarAbility[iIndex].g_iAccessFlags = 0;
				g_esCarAbility[iIndex].g_iImmunityFlags = 0;
				g_esCarAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esCarAbility[iIndex].g_iComboAbility = 0;
				g_esCarAbility[iIndex].g_iComboPosition = -1;
				g_esCarAbility[iIndex].g_iHumanAbility = 0;
				g_esCarAbility[iIndex].g_iHumanAmmo = 5;
				g_esCarAbility[iIndex].g_iHumanCooldown = 0;
				g_esCarAbility[iIndex].g_iHumanDuration = 5;
				g_esCarAbility[iIndex].g_iHumanMode = 1;
				g_esCarAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esCarAbility[iIndex].g_iRequiresHumans = 1;
				g_esCarAbility[iIndex].g_iCarAbility = 0;
				g_esCarAbility[iIndex].g_iCarMessage = 0;
				g_esCarAbility[iIndex].g_flCarChance = 33.3;
				g_esCarAbility[iIndex].g_iCarCooldown = 0;
				g_esCarAbility[iIndex].g_iCarDuration = 5;
				g_esCarAbility[iIndex].g_iCarOptions = 0;
				g_esCarAbility[iIndex].g_iCarOwner = 1;
				g_esCarAbility[iIndex].g_flCarDamage = 5.0;
				g_esCarAbility[iIndex].g_flCarInterval = 0.6;
				g_esCarAbility[iIndex].g_flCarLifetime = 30.0;
				g_esCarAbility[iIndex].g_flCarRadius[0] = -180.0;
				g_esCarAbility[iIndex].g_flCarRadius[1] = 180.0;

				g_esCarSpecial[iIndex].g_iComboAbility = -1;
				g_esCarSpecial[iIndex].g_iHumanAbility = -1;
				g_esCarSpecial[iIndex].g_iHumanAmmo = -1;
				g_esCarSpecial[iIndex].g_iHumanCooldown = -1;
				g_esCarSpecial[iIndex].g_iHumanDuration = -1;
				g_esCarSpecial[iIndex].g_iHumanMode = -1;
				g_esCarSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esCarSpecial[iIndex].g_iRequiresHumans = -1;
				g_esCarSpecial[iIndex].g_iCarAbility = -1;
				g_esCarSpecial[iIndex].g_iCarMessage = -1;
				g_esCarSpecial[iIndex].g_flCarChance = -1.0;
				g_esCarSpecial[iIndex].g_iCarCooldown = -1;
				g_esCarSpecial[iIndex].g_iCarDuration = -1;
				g_esCarSpecial[iIndex].g_iCarOptions = -1;
				g_esCarSpecial[iIndex].g_iCarOwner = -1;
				g_esCarSpecial[iIndex].g_flCarDamage = -1.0;
				g_esCarSpecial[iIndex].g_flCarInterval = -1.0;
				g_esCarSpecial[iIndex].g_flCarLifetime = -1.0;
				g_esCarSpecial[iIndex].g_flCarRadius[0] = 1.0;
				g_esCarSpecial[iIndex].g_flCarRadius[1] = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esCarPlayer[iPlayer].g_iAccessFlags = -1;
				g_esCarPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esCarPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esCarPlayer[iPlayer].g_iComboAbility = -1;
				g_esCarPlayer[iPlayer].g_iHumanAbility = -1;
				g_esCarPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esCarPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esCarPlayer[iPlayer].g_iHumanDuration = -1;
				g_esCarPlayer[iPlayer].g_iHumanMode = -1;
				g_esCarPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esCarPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esCarPlayer[iPlayer].g_iCarAbility = -1;
				g_esCarPlayer[iPlayer].g_iCarMessage = -1;
				g_esCarPlayer[iPlayer].g_flCarChance = -1.0;
				g_esCarPlayer[iPlayer].g_iCarCooldown = -1;
				g_esCarPlayer[iPlayer].g_iCarDuration = -1;
				g_esCarPlayer[iPlayer].g_iCarOptions = -1;
				g_esCarPlayer[iPlayer].g_iCarOwner = -1;
				g_esCarPlayer[iPlayer].g_flCarDamage = -1.0;
				g_esCarPlayer[iPlayer].g_flCarInterval = -1.0;
				g_esCarPlayer[iPlayer].g_flCarLifetime = -1.0;
				g_esCarPlayer[iPlayer].g_flCarRadius[0] = 1.0;
				g_esCarPlayer[iPlayer].g_flCarRadius[1] = -1.0;

				g_esCarTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esCarTeammate[iPlayer].g_iComboAbility = -1;
				g_esCarTeammate[iPlayer].g_iHumanAbility = -1;
				g_esCarTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esCarTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esCarTeammate[iPlayer].g_iHumanDuration = -1;
				g_esCarTeammate[iPlayer].g_iHumanMode = -1;
				g_esCarTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esCarTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esCarTeammate[iPlayer].g_iCarAbility = -1;
				g_esCarTeammate[iPlayer].g_iCarMessage = -1;
				g_esCarTeammate[iPlayer].g_flCarChance = -1.0;
				g_esCarTeammate[iPlayer].g_iCarCooldown = -1;
				g_esCarTeammate[iPlayer].g_iCarDuration = -1;
				g_esCarTeammate[iPlayer].g_iCarOptions = -1;
				g_esCarTeammate[iPlayer].g_iCarOwner = -1;
				g_esCarTeammate[iPlayer].g_flCarDamage = -1.0;
				g_esCarTeammate[iPlayer].g_flCarInterval = -1.0;
				g_esCarTeammate[iPlayer].g_flCarLifetime = -1.0;
				g_esCarTeammate[iPlayer].g_flCarRadius[0] = 1.0;
				g_esCarTeammate[iPlayer].g_flCarRadius[1] = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vCarConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esCarTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esCarTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esCarTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esCarTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esCarTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esCarTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esCarTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esCarTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esCarTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esCarTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esCarTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esCarTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esCarTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esCarTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esCarTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esCarTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esCarTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esCarTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esCarTeammate[admin].g_iCarAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esCarTeammate[admin].g_iCarAbility, value, -1, 1);
			g_esCarTeammate[admin].g_iCarMessage = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esCarTeammate[admin].g_iCarMessage, value, -1, 1);
			g_esCarTeammate[admin].g_flCarChance = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esCarTeammate[admin].g_flCarChance, value, -1.0, 100.0);
			g_esCarTeammate[admin].g_iCarCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarCooldown", "Car Cooldown", "Car_Cooldown", "cooldown", g_esCarTeammate[admin].g_iCarCooldown, value, -1, 99999);
			g_esCarTeammate[admin].g_flCarDamage = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDamage", "Car Damage", "Car_Damage", "damage", g_esCarTeammate[admin].g_flCarDamage, value, -1.0, 99999.0);
			g_esCarTeammate[admin].g_iCarDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esCarTeammate[admin].g_iCarDuration, value, -1, 99999);
			g_esCarTeammate[admin].g_flCarInterval = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esCarTeammate[admin].g_flCarInterval, value, -1.0, 1.0);
			g_esCarTeammate[admin].g_flCarLifetime = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarLifetime", "Car Lifetime", "Car_Lifetime", "lifetime", g_esCarTeammate[admin].g_flCarLifetime, value, -1.0, 99999.0);
			g_esCarTeammate[admin].g_iCarOptions = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOptions", "Car Options", "Car_Options", "options", g_esCarTeammate[admin].g_iCarOptions, value, -1, 7);
			g_esCarTeammate[admin].g_iCarOwner = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOwner", "Car Owner", "Car_Owner", "owner", g_esCarTeammate[admin].g_iCarOwner, value, -1, 1);
		}
		else
		{
			g_esCarPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esCarPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esCarPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esCarPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esCarPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esCarPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esCarPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esCarPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esCarPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esCarPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esCarPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esCarPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esCarPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esCarPlayer[admin].g_iHumanMode, value, -1, 2);
			g_esCarPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esCarPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esCarPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esCarPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esCarPlayer[admin].g_iCarAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esCarPlayer[admin].g_iCarAbility, value, -1, 1);
			g_esCarPlayer[admin].g_iCarMessage = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esCarPlayer[admin].g_iCarMessage, value, -1, 1);
			g_esCarPlayer[admin].g_flCarChance = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esCarPlayer[admin].g_flCarChance, value, -1.0, 100.0);
			g_esCarPlayer[admin].g_iCarCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarCooldown", "Car Cooldown", "Car_Cooldown", "cooldown", g_esCarPlayer[admin].g_iCarCooldown, value, -1, 99999);
			g_esCarPlayer[admin].g_flCarDamage = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDamage", "Car Damage", "Car_Damage", "damage", g_esCarPlayer[admin].g_flCarDamage, value, -1.0, 99999.0);
			g_esCarPlayer[admin].g_iCarDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esCarPlayer[admin].g_iCarDuration, value, -1, 99999);
			g_esCarPlayer[admin].g_flCarInterval = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esCarPlayer[admin].g_flCarInterval, value, -1.0, 1.0);
			g_esCarPlayer[admin].g_flCarLifetime = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarLifetime", "Car Lifetime", "Car_Lifetime", "lifetime", g_esCarPlayer[admin].g_flCarLifetime, value, -1.0, 99999.0);
			g_esCarPlayer[admin].g_iCarOptions = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOptions", "Car Options", "Car_Options", "options", g_esCarPlayer[admin].g_iCarOptions, value, -1, 7);
			g_esCarPlayer[admin].g_iCarOwner = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOwner", "Car Owner", "Car_Owner", "owner", g_esCarPlayer[admin].g_iCarOwner, value, -1, 1);
			g_esCarPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esCarPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}

		if (StrEqual(subsection, MT_CAR_SECTION, false) || StrEqual(subsection, MT_CAR_SECTION2, false) || StrEqual(subsection, MT_CAR_SECTION3, false) || StrEqual(subsection, MT_CAR_SECTION4, false))
		{
			if (StrEqual(key, "CarRadius", false) || StrEqual(key, "Car Radius", false) || StrEqual(key, "Car_Radius", false) || StrEqual(key, "radius", false))
			{
				char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);

				if (special && specsection[0] != '\0')
				{
					g_esCarTeammate[admin].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 1.0) : g_esCarTeammate[admin].g_flCarRadius[0];
					g_esCarTeammate[admin].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), -1.0, 200.0) : g_esCarTeammate[admin].g_flCarRadius[1];
				}
				else
				{
					g_esCarPlayer[admin].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 1.0) : g_esCarPlayer[admin].g_flCarRadius[0];
					g_esCarPlayer[admin].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), -1.0, 200.0) : g_esCarPlayer[admin].g_flCarRadius[1];
				}
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esCarSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esCarSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esCarSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esCarSpecial[type].g_iComboAbility, value, -1, 1);
			g_esCarSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esCarSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esCarSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esCarSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esCarSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esCarSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esCarSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esCarSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esCarSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esCarSpecial[type].g_iHumanMode, value, -1, 2);
			g_esCarSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esCarSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esCarSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esCarSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esCarSpecial[type].g_iCarAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esCarSpecial[type].g_iCarAbility, value, -1, 1);
			g_esCarSpecial[type].g_iCarMessage = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esCarSpecial[type].g_iCarMessage, value, -1, 1);
			g_esCarSpecial[type].g_flCarChance = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esCarSpecial[type].g_flCarChance, value, -1.0, 100.0);
			g_esCarSpecial[type].g_iCarCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarCooldown", "Car Cooldown", "Car_Cooldown", "cooldown", g_esCarSpecial[type].g_iCarCooldown, value, -1, 99999);
			g_esCarSpecial[type].g_flCarDamage = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDamage", "Car Damage", "Car_Damage", "damage", g_esCarSpecial[type].g_flCarDamage, value, -1.0, 99999.0);
			g_esCarSpecial[type].g_iCarDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esCarSpecial[type].g_iCarDuration, value, -1, 99999);
			g_esCarSpecial[type].g_flCarInterval = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esCarSpecial[type].g_flCarInterval, value, -1.0, 1.0);
			g_esCarSpecial[type].g_flCarLifetime = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarLifetime", "Car Lifetime", "Car_Lifetime", "lifetime", g_esCarSpecial[type].g_flCarLifetime, value, -1.0, 99999.0);
			g_esCarSpecial[type].g_iCarOptions = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOptions", "Car Options", "Car_Options", "options", g_esCarSpecial[type].g_iCarOptions, value, -1, 7);
			g_esCarSpecial[type].g_iCarOwner = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOwner", "Car Owner", "Car_Owner", "owner", g_esCarSpecial[type].g_iCarOwner, value, -1, 1);
		}
		else
		{
			g_esCarAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esCarAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esCarAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esCarAbility[type].g_iComboAbility, value, -1, 1);
			g_esCarAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esCarAbility[type].g_iHumanAbility, value, -1, 2);
			g_esCarAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esCarAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esCarAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esCarAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esCarAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esCarAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esCarAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esCarAbility[type].g_iHumanMode, value, -1, 2);
			g_esCarAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esCarAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esCarAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esCarAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esCarAbility[type].g_iCarAbility = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esCarAbility[type].g_iCarAbility, value, -1, 1);
			g_esCarAbility[type].g_iCarMessage = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esCarAbility[type].g_iCarMessage, value, -1, 1);
			g_esCarAbility[type].g_flCarChance = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esCarAbility[type].g_flCarChance, value, -1.0, 100.0);
			g_esCarAbility[type].g_iCarCooldown = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarCooldown", "Car Cooldown", "Car_Cooldown", "cooldown", g_esCarAbility[type].g_iCarCooldown, value, -1, 99999);
			g_esCarAbility[type].g_flCarDamage = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDamage", "Car Damage", "Car_Damage", "damage", g_esCarAbility[type].g_flCarDamage, value, -1.0, 99999.0);
			g_esCarAbility[type].g_iCarDuration = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esCarAbility[type].g_iCarDuration, value, -1, 99999);
			g_esCarAbility[type].g_flCarInterval = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esCarAbility[type].g_flCarInterval, value, -1.0, 1.0);
			g_esCarAbility[type].g_flCarLifetime = flGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarLifetime", "Car Lifetime", "Car_Lifetime", "lifetime", g_esCarAbility[type].g_flCarLifetime, value, -1.0, 99999.0);
			g_esCarAbility[type].g_iCarOptions = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOptions", "Car Options", "Car_Options", "options", g_esCarAbility[type].g_iCarOptions, value, -1, 7);
			g_esCarAbility[type].g_iCarOwner = iGetKeyValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "CarOwner", "Car Owner", "Car_Owner", "owner", g_esCarAbility[type].g_iCarOwner, value, -1, 1);
			g_esCarAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esCarAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_CAR_SECTION, MT_CAR_SECTION2, MT_CAR_SECTION3, MT_CAR_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}

		if (StrEqual(subsection, MT_CAR_SECTION, false) || StrEqual(subsection, MT_CAR_SECTION2, false) || StrEqual(subsection, MT_CAR_SECTION3, false) || StrEqual(subsection, MT_CAR_SECTION4, false))
		{
			if (StrEqual(key, "CarRadius", false) || StrEqual(key, "Car Radius", false) || StrEqual(key, "Car_Radius", false) || StrEqual(key, "radius", false))
			{
				char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);

				if (special && specsection[0] != '\0')
				{
					g_esCarSpecial[type].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 1.0) : g_esCarSpecial[type].g_flCarRadius[0];
					g_esCarSpecial[type].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), -1.0, 200.0) : g_esCarSpecial[type].g_flCarRadius[1];
				}
				else
				{
					g_esCarAbility[type].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 1.0) : g_esCarAbility[type].g_flCarRadius[0];
					g_esCarAbility[type].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), -1.0, 200.0) : g_esCarAbility[type].g_flCarRadius[1];
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vCarSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esCarPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esCarPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esCarPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esCarCache[tank].g_flCarChance = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarChance, g_esCarPlayer[tank].g_flCarChance, g_esCarSpecial[iType].g_flCarChance, g_esCarAbility[iType].g_flCarChance, 1);
		g_esCarCache[tank].g_flCarDamage = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarDamage, g_esCarPlayer[tank].g_flCarDamage, g_esCarSpecial[iType].g_flCarDamage, g_esCarAbility[iType].g_flCarDamage, 1);
		g_esCarCache[tank].g_flCarInterval = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarInterval, g_esCarPlayer[tank].g_flCarInterval, g_esCarSpecial[iType].g_flCarInterval, g_esCarAbility[iType].g_flCarInterval, 1);
		g_esCarCache[tank].g_flCarLifetime = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarLifetime, g_esCarPlayer[tank].g_flCarLifetime, g_esCarSpecial[iType].g_flCarLifetime, g_esCarAbility[iType].g_flCarLifetime, 1);
		g_esCarCache[tank].g_flCarRadius[0] = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarRadius[0], g_esCarPlayer[tank].g_flCarRadius[0], g_esCarSpecial[iType].g_flCarRadius[0], g_esCarAbility[iType].g_flCarRadius[0], 2, 1.0);
		g_esCarCache[tank].g_flCarRadius[1] = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCarRadius[1], g_esCarPlayer[tank].g_flCarRadius[1], g_esCarSpecial[iType].g_flCarRadius[1], g_esCarAbility[iType].g_flCarRadius[1], 2, -1.0);
		g_esCarCache[tank].g_iCarAbility = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarAbility, g_esCarPlayer[tank].g_iCarAbility, g_esCarSpecial[iType].g_iCarAbility, g_esCarAbility[iType].g_iCarAbility, 1);
		g_esCarCache[tank].g_iCarCooldown = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarCooldown, g_esCarPlayer[tank].g_iCarCooldown, g_esCarSpecial[iType].g_iCarCooldown, g_esCarAbility[iType].g_iCarCooldown, 1);
		g_esCarCache[tank].g_iCarDuration = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarDuration, g_esCarPlayer[tank].g_iCarDuration, g_esCarSpecial[iType].g_iCarDuration, g_esCarAbility[iType].g_iCarDuration, 1);
		g_esCarCache[tank].g_iCarMessage = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarMessage, g_esCarPlayer[tank].g_iCarMessage, g_esCarSpecial[iType].g_iCarMessage, g_esCarAbility[iType].g_iCarMessage, 1);
		g_esCarCache[tank].g_iCarOptions = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarOptions, g_esCarPlayer[tank].g_iCarOptions, g_esCarSpecial[iType].g_iCarOptions, g_esCarAbility[iType].g_iCarOptions, 1);
		g_esCarCache[tank].g_iCarOwner = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iCarOwner, g_esCarPlayer[tank].g_iCarOwner, g_esCarSpecial[iType].g_iCarOwner, g_esCarAbility[iType].g_iCarOwner, 1);
		g_esCarCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flCloseAreasOnly, g_esCarPlayer[tank].g_flCloseAreasOnly, g_esCarSpecial[iType].g_flCloseAreasOnly, g_esCarAbility[iType].g_flCloseAreasOnly, 1);
		g_esCarCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iComboAbility, g_esCarPlayer[tank].g_iComboAbility, g_esCarSpecial[iType].g_iComboAbility, g_esCarAbility[iType].g_iComboAbility, 1);
		g_esCarCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iHumanAbility, g_esCarPlayer[tank].g_iHumanAbility, g_esCarSpecial[iType].g_iHumanAbility, g_esCarAbility[iType].g_iHumanAbility, 1);
		g_esCarCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iHumanAmmo, g_esCarPlayer[tank].g_iHumanAmmo, g_esCarSpecial[iType].g_iHumanAmmo, g_esCarAbility[iType].g_iHumanAmmo, 1);
		g_esCarCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iHumanCooldown, g_esCarPlayer[tank].g_iHumanCooldown, g_esCarSpecial[iType].g_iHumanCooldown, g_esCarAbility[iType].g_iHumanCooldown, 1);
		g_esCarCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iHumanDuration, g_esCarPlayer[tank].g_iHumanDuration, g_esCarSpecial[iType].g_iHumanDuration, g_esCarAbility[iType].g_iHumanDuration, 1);
		g_esCarCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iHumanMode, g_esCarPlayer[tank].g_iHumanMode, g_esCarSpecial[iType].g_iHumanMode, g_esCarAbility[iType].g_iHumanMode, 1);
		g_esCarCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_flOpenAreasOnly, g_esCarPlayer[tank].g_flOpenAreasOnly, g_esCarSpecial[iType].g_flOpenAreasOnly, g_esCarAbility[iType].g_flOpenAreasOnly, 1);
		g_esCarCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esCarTeammate[tank].g_iRequiresHumans, g_esCarPlayer[tank].g_iRequiresHumans, g_esCarSpecial[iType].g_iRequiresHumans, g_esCarAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esCarCache[tank].g_flCarChance = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarChance, g_esCarAbility[iType].g_flCarChance, 1);
		g_esCarCache[tank].g_flCarDamage = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarDamage, g_esCarAbility[iType].g_flCarDamage, 1);
		g_esCarCache[tank].g_flCarInterval = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarInterval, g_esCarAbility[iType].g_flCarInterval, 1);
		g_esCarCache[tank].g_flCarLifetime = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarLifetime, g_esCarAbility[iType].g_flCarLifetime, 1);
		g_esCarCache[tank].g_flCarRadius[0] = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarRadius[0], g_esCarAbility[iType].g_flCarRadius[0], 2, 1.0);
		g_esCarCache[tank].g_flCarRadius[1] = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCarRadius[1], g_esCarAbility[iType].g_flCarRadius[1], 2, -1.0);
		g_esCarCache[tank].g_iCarAbility = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarAbility, g_esCarAbility[iType].g_iCarAbility, 1);
		g_esCarCache[tank].g_iCarCooldown = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarCooldown, g_esCarAbility[iType].g_iCarCooldown, 1);
		g_esCarCache[tank].g_iCarDuration = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarDuration, g_esCarAbility[iType].g_iCarDuration, 1);
		g_esCarCache[tank].g_iCarMessage = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarMessage, g_esCarAbility[iType].g_iCarMessage, 1);
		g_esCarCache[tank].g_iCarOptions = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarOptions, g_esCarAbility[iType].g_iCarOptions, 1);
		g_esCarCache[tank].g_iCarOwner = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iCarOwner, g_esCarAbility[iType].g_iCarOwner, 1);
		g_esCarCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flCloseAreasOnly, g_esCarAbility[iType].g_flCloseAreasOnly, 1);
		g_esCarCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iComboAbility, g_esCarAbility[iType].g_iComboAbility, 1);
		g_esCarCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iHumanAbility, g_esCarAbility[iType].g_iHumanAbility, 1);
		g_esCarCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iHumanAmmo, g_esCarAbility[iType].g_iHumanAmmo, 1);
		g_esCarCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iHumanCooldown, g_esCarAbility[iType].g_iHumanCooldown, 1);
		g_esCarCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iHumanDuration, g_esCarAbility[iType].g_iHumanDuration, 1);
		g_esCarCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iHumanMode, g_esCarAbility[iType].g_iHumanMode, 1);
		g_esCarCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_flOpenAreasOnly, g_esCarAbility[iType].g_flOpenAreasOnly, 1);
		g_esCarCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esCarPlayer[tank].g_iRequiresHumans, g_esCarAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vCarCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vCarCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveCar(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vCarEventFired(Event event, const char[] name)
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
			vCarCopyStats2(iBot, iTank);
			vRemoveCar(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vCarReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vCarCopyStats2(iTank, iBot);
			vRemoveCar(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveCar(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vCarAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[tank].g_iAccessFlags)) || g_esCarCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esCarCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCarCache[tank].g_iCarAbility == 1 && g_esCarCache[tank].g_iComboAbility == 0 && !g_esCarPlayer[tank].g_bActivated)
	{
		vCarAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN
void vCarButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCarCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esCarCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esCarPlayer[tank].g_iTankType, tank) || (g_esCarCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCarCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && g_esCarCache[tank].g_iCarAbility == 1 && g_esCarCache[tank].g_iHumanAbility == 1)
		{
			int iHumanMode = g_esCarCache[tank].g_iHumanMode, iTime = GetTime();
			bool bRecharging = g_esCarPlayer[tank].g_iCooldown != -1 && g_esCarPlayer[tank].g_iCooldown >= iTime;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esCarPlayer[tank].g_bActivated && !bRecharging)
					{
						vCarAbility(tank);
					}
					else if (g_esCarPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman4", (g_esCarPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esCarPlayer[tank].g_bActivated) || (g_esCarPlayer[tank].g_iAmmoCount < g_esCarCache[tank].g_iHumanAmmo && g_esCarCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esCarPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esCarPlayer[tank].g_bActivated = true;
							g_esCarPlayer[tank].g_iAmmoCount++;

							vCar2(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_esCarPlayer[tank].g_iAmmoCount, g_esCarCache[tank].g_iHumanAmmo);
						}
						else if (g_esCarPlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman3");
								case 2:
								{
									vCarReset2(tank);
									vCarReset3(tank);
								}
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman4", (g_esCarPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vCarButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esCarCache[tank].g_iHumanMode == 1 && g_esCarPlayer[tank].g_bActivated && (g_esCarPlayer[tank].g_iCooldown == -1 || g_esCarPlayer[tank].g_iCooldown <= GetTime()))
		{
			vCarReset2(tank);
			vCarReset3(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vCarChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveCar(tank);
}

void vCar(int tank, int pos = -1)
{
	if (g_esCarPlayer[tank].g_iCooldown != -1 && g_esCarPlayer[tank].g_iCooldown >= GetTime())
	{
		return;
	}

	g_esCarPlayer[tank].g_bActivated = true;

	vCar2(tank, pos);

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility == 1)
	{
		g_esCarPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_esCarPlayer[tank].g_iAmmoCount, g_esCarCache[tank].g_iHumanAmmo);
	}

	if (g_esCarCache[tank].g_iCarMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Car", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Car", LANG_SERVER, sTankName);
	}
}

void vCar2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCarCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esCarCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esCarPlayer[tank].g_iTankType, tank) || (g_esCarCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCarCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esCarCache[tank].g_flCarInterval;
	if (flInterval > 0.0)
	{
		DataPack dpCar;
		CreateDataTimer(flInterval, tTimerCar, dpCar, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpCar.WriteCell(GetClientUserId(tank));
		dpCar.WriteCell(g_esCarPlayer[tank].g_iTankType);
		dpCar.WriteCell(GetTime());
		dpCar.WriteCell(pos);
	}
}

void vCarAbility(int tank)
{
	if ((g_esCarPlayer[tank].g_iCooldown != -1 && g_esCarPlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esCarCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esCarCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esCarPlayer[tank].g_iTankType, tank) || (g_esCarCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCarCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esCarPlayer[tank].g_iAmmoCount < g_esCarCache[tank].g_iHumanAmmo && g_esCarCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCarCache[tank].g_flCarChance)
		{
			vCar(tank);
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman2");
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
	}
}

void vCarCopyStats2(int oldTank, int newTank)
{
	g_esCarPlayer[newTank].g_iAmmoCount = g_esCarPlayer[oldTank].g_iAmmoCount;
	g_esCarPlayer[newTank].g_iCooldown = g_esCarPlayer[oldTank].g_iCooldown;
}

void vRemoveCar(int tank)
{
	g_esCarPlayer[tank].g_bActivated = false;
	g_esCarPlayer[tank].g_iAmmoCount = 0;
	g_esCarPlayer[tank].g_iCooldown = -1;
}

void vCarReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveCar(iPlayer);
		}
	}
}

void vCarReset2(int tank)
{
	g_esCarPlayer[tank].g_bActivated = false;

	if (g_esCarCache[tank].g_iCarMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Car2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Car2", LANG_SERVER, sTankName);
	}
}

void vCarReset3(int tank)
{
	int iTime = GetTime(), iPos = g_esCarAbility[g_esCarPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esCarCache[tank].g_iCarCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esCarCache[tank].g_iHumanAbility == 1 && g_esCarCache[tank].g_iHumanMode == 0 && g_esCarPlayer[tank].g_iAmmoCount < g_esCarCache[tank].g_iHumanAmmo && g_esCarCache[tank].g_iHumanAmmo > 0) ? g_esCarCache[tank].g_iHumanCooldown : iCooldown;
	g_esCarPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esCarPlayer[tank].g_iCooldown != -1 && g_esCarPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman5", (g_esCarPlayer[tank].g_iCooldown - iTime));
	}
}

Action tTimerCar(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esCarAbility[g_esCarPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esCarPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esCarPlayer[iTank].g_iTankType || !g_esCarPlayer[iTank].g_bActivated)
	{
		g_esCarPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	if (g_esCarCache[iTank].g_iCarAbility == 0 || bIsAreaNarrow(iTank, g_esCarCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esCarCache[iTank].g_flCloseAreasOnly))
	{
		vCarReset2(iTank);

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esCarCache[iTank].g_iCarDuration;
	iDuration = (bHuman && g_esCarCache[iTank].g_iHumanAbility == 1) ? g_esCarCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esCarCache[iTank].g_iHumanAbility == 1 && g_esCarCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime)
	{
		vCarReset2(iTank);
		vCarReset3(iTank);

		return Plugin_Stop;
	}

	float flPos[3], flAngles[3];
	GetClientEyePosition(iTank, flPos);
	flAngles[0] = MT_GetRandomFloat(-20.0, 20.0);
	flAngles[1] = MT_GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;
	GetVectorAngles(flAngles, flAngles);

	float flMinRadius = (iPos != -1) ? MT_GetCombinationSetting(iTank, 7, iPos) : g_esCarCache[iTank].g_flCarRadius[0],
		flMaxRadius = (iPos != -1) ? MT_GetCombinationSetting(iTank, 8, iPos) : g_esCarCache[iTank].g_flCarRadius[1];

	float flHitpos[3];
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);
	float flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, (flDistance - 40.0));
	AddVectors(flPos, flVector, flHitpos);
	if (flDistance > 100.0)
	{
		int iCar = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iCar))
		{
			int iOptionCount = 0, iOptions[3], iFlag = 0;
			for (int iBit = 0; iBit < (sizeof iOptions); iBit++)
			{
				iFlag = (1 << iBit);
				if (!(g_esCarCache[iTank].g_iCarOptions & iFlag))
				{
					continue;
				}

				iOptions[iOptionCount] = iFlag;
				iOptionCount++;
			}

			switch (iOptionCount > 0)
			{
				case true:
				{
					switch (iOptions[MT_GetRandomInt(0, (iOptionCount - 1))])
					{
						case 1: SetEntityModel(iCar, MODEL_CAR);
						case 2: SetEntityModel(iCar, MODEL_CAR2);
						case 4: SetEntityModel(iCar, MODEL_CAR3);
						default:
						{
							switch (MT_GetRandomInt(1, (sizeof iOptions)))
							{
								case 1: SetEntityModel(iCar, MODEL_CAR);
								case 2: SetEntityModel(iCar, MODEL_CAR2);
								case 3: SetEntityModel(iCar, MODEL_CAR3);
							}
						}
					}
				}
				case false:
				{
					switch (MT_GetRandomInt(1, (sizeof iOptions)))
					{
						case 1: SetEntityModel(iCar, MODEL_CAR);
						case 2: SetEntityModel(iCar, MODEL_CAR2);
						case 3: SetEntityModel(iCar, MODEL_CAR3);
					}
				}
			}

			float flAngles2[3];
			int iCarColor[3];
			for (int iIndex = 0; iIndex < (sizeof iCarColor); iIndex++)
			{
				iCarColor[iIndex] = MT_GetRandomInt(0, 255);
				flAngles2[iIndex] = MT_GetRandomFloat(flMinRadius, flMaxRadius);
			}

			SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

			if (g_esCarCache[iTank].g_iCarOwner == 1)
			{
				SetEntPropEnt(iCar, Prop_Data, "m_hOwnerEntity", iTank);
			}

			float flVelocity[3];
			flVelocity[0] = MT_GetRandomFloat(0.0, 350.0);
			flVelocity[1] = MT_GetRandomFloat(0.0, 350.0);
			flVelocity[2] = MT_GetRandomFloat(0.0, 30.0);

			TeleportEntity(iCar, flHitpos, flAngles2);
			DispatchSpawn(iCar);
			TeleportEntity(iCar, .velocity = flVelocity);

			SDKHook(iCar, SDKHook_StartTouch, OnCarStartTouch);
			g_esCarGeneral.g_iCar[iCar] = EntIndexToEntRef(iCar);
			g_esCarGeneral.g_iCarOwner[iCar] = GetClientUserId(iTank);
			iCar = EntIndexToEntRef(iCar);
			vDeleteEntity(iCar, g_esCarCache[iTank].g_flCarLifetime);
		}
	}

	return Plugin_Continue;
}

Action tTimerCarCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esCarAbility[g_esCarPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esCarPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esCarPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esCarCache[iTank].g_iCarAbility == 0 || g_esCarPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vCar(iTank, iPos);

	return Plugin_Continue;
}