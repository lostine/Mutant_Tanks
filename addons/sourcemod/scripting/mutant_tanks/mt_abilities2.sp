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

#define MT_ABILITIES_MAIN2
#define MT_ABILITIES_GROUP2 3 // 0: NONE, 1: Only include first half (1-15), 2: Only include second half (16-31), 3: ALL
#define MT_ABILITIES_COMPILER_MESSAGE2 1 // 0: NONE, 1: Display warning messages about excluded abilities, 2: Display error messages about excluded abilities

#include <sourcemod>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Abilities Set #2",
	author = MT_AUTHOR,
	description = "Provides several abilities for Mutant Tanks.",
	version = MT_VERSION,
	url = MT_URL
};

#define MT_GAMEDATA "mutant_tanks"
#define MT_GAMEDATA_TEMP "mutant_tanks_temp"

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"
#define MODEL_CEDA "models/infected/common_male_ceda.mdl"
#define MODEL_CLOWN "models/infected/common_male_clown.mdl"
#define MODEL_FALLEN "models/infected/common_male_fallen_survivor.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_JIMMY "models/infected/common_male_jimmy.mdl"
#define MODEL_MUDMAN "models/infected/common_male_mud.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_RIOTCOP "models/infected/common_male_riot.mdl"
#define MODEL_ROADCREW "models/infected/common_male_roadcrew.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define PARTICLE_BASHED "screen_bashed"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_LIGHTNING "storm_lightning_01"
#define PARTICLE_VOMIT "boomer_vomit"

#define SOUND_CHARGE "items/suitchargeok1.wav"
#define SOUND_DRIP "ambient/water/distant_drip2.wav"
#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"
#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_FIRE "weapons/molotov/fire_ignite_1.wav"
#define SOUND_GROAN1 "ambient/random_amb_sfx/metalscrapeverb08.wav"
#define SOUND_GROAN2 "ambient/random_amb_sounds/randbridgegroan_03.wav" // Only available in L4D2
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" // Only available in L4D1
#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" // Only available in L4D2
#define SOUND_LAUNCH "player/boomer/explode/explo_medium_14.wav"
#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_RAGE "npc/infected/action/rage/female/rage_68.wav"
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2

#define SPRITE_DOT "sprites/dot.vmt"
#define SPRITE_FIRE "sprites/sprite_fire01.vmt"
#define SPRITE_GLOW "sprites/glow01.vmt"
#define SPRITE_LASER "sprites/laser.vmt"
#define SPRITE_LASERBEAM "sprites/laserbeam.vmt"

bool g_bDedicated, g_bLaggedMovementInstalled, g_bLateLoad, g_bSecondGame;

int g_iGraphicsLevel;

#undef REQUIRE_PLUGIN
#if MT_ABILITIES_GROUP2 == 1 || MT_ABILITIES_GROUP2 == 3
	#tryinclude "mutant_tanks/abilities2/mt_lag.sp"
	#tryinclude "mutant_tanks/abilities2/mt_laser.sp"
	#tryinclude "mutant_tanks/abilities2/mt_lightning.sp"
	#tryinclude "mutant_tanks/abilities2/mt_medic.sp"
	#tryinclude "mutant_tanks/abilities2/mt_meteor.sp"
	#tryinclude "mutant_tanks/abilities2/mt_minion.sp"
	#tryinclude "mutant_tanks/abilities2/mt_nullify.sp"
	#tryinclude "mutant_tanks/abilities2/mt_omni.sp"
	#tryinclude "mutant_tanks/abilities2/mt_panic.sp"
	#tryinclude "mutant_tanks/abilities2/mt_puke.sp"
	#tryinclude "mutant_tanks/abilities2/mt_pyro.sp"
	#tryinclude "mutant_tanks/abilities2/mt_quiet.sp"
	#tryinclude "mutant_tanks/abilities2/mt_recall.sp"
	#tryinclude "mutant_tanks/abilities2/mt_recoil.sp"
	#tryinclude "mutant_tanks/abilities2/mt_regen.sp"
#endif
#if MT_ABILITIES_GROUP2 == 2 || MT_ABILITIES_GROUP2 == 3
	#tryinclude "mutant_tanks/abilities2/mt_respawn.sp"
	#tryinclude "mutant_tanks/abilities2/mt_restart.sp"
	#tryinclude "mutant_tanks/abilities2/mt_rock.sp"
	#tryinclude "mutant_tanks/abilities2/mt_shield.sp"
	#tryinclude "mutant_tanks/abilities2/mt_shove.sp"
	#tryinclude "mutant_tanks/abilities2/mt_slow.sp"
	#tryinclude "mutant_tanks/abilities2/mt_smash.sp"
	#tryinclude "mutant_tanks/abilities2/mt_throw.sp"
	#tryinclude "mutant_tanks/abilities2/mt_track.sp"
	#tryinclude "mutant_tanks/abilities2/mt_ultimate.sp"
	#tryinclude "mutant_tanks/abilities2/mt_undead.sp"
	#tryinclude "mutant_tanks/abilities2/mt_vision.sp"
	#tryinclude "mutant_tanks/abilities2/mt_warp.sp"
	#tryinclude "mutant_tanks/abilities2/mt_whirl.sp"
	#tryinclude "mutant_tanks/abilities2/mt_witch.sp"
	#tryinclude "mutant_tanks/abilities2/mt_yell.sp"
#endif
#define REQUIRE_PLUGIN

#if MT_ABILITIES_COMPILER_MESSAGE2 == 1
	#if !defined MT_MENU_LAG
		#warning The "Lag" (mt_lag.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_LASER
		#warning The "Laser" (mt_laser.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_LIGHTNING
		#warning The "Lightning" (mt_lightning.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_MEDIC
		#warning The "Medic" (mt_medic.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_METEOR
		#warning The "Meteor" (mt_meteor.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_MINION
		#warning The "Minion" (mt_minion.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_NULLIFY
		#warning The "Nullify" (mt_nullify.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_OMNI
		#warning The "Omni" (mt_omni.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PANIC
		#warning The "Panic" (mt_panic.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PUKE
		#warning The "Puke" (mt_puke.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PYRO
		#warning The "Pyro" (mt_pyro.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_QUIET
		#warning The "Quiet" (mt_quiet.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RECALL
		#warning The "Recall" (mt_recall.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RECOIL
		#warning The "Recoil" (mt_recoil.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_REGEN
		#warning The "Regen" (mt_regen.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RESPAWN
		#warning The "Respawn" (mt_respawn.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RESTART
		#warning The "Restart" (mt_restart.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_ROCK
		#warning The "Rock" (mt_rock.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SHIELD
		#warning The "Shield" (mt_shield.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SHOVE
		#warning The "Shove" (mt_shove.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SLOW
		#warning The "Slow" (mt_slow.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SMASH
		#warning The "Smash" (mt_smash.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_THROW
		#warning The "Throw" (mt_throw.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_TRACK
		#warning The "Track" (mt_track.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_ULTIMATE
		#warning The "Ultimate" (mt_ultimate.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_UNDEAD
		#warning The "Undead" (mt_undead.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_VISION
		#warning The "Vision" (mt_vision.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WARP
		#warning The "Warp" (mt_warp.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WHIRL
		#warning The "Whirl" (mt_whirl.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WITCH
		#warning The "Witch" (mt_witch.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_YELL
		#warning The "Yell" (mt_yell.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
#endif
#if MT_ABILITIES_COMPILER_MESSAGE2 == 2
	#if !defined MT_MENU_LAG
		#error The "Lag" (mt_lag.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_LASER
		#error The "Laser" (mt_laser.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_LIGHTNING
		#error The "Lightning" (mt_lightning.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_MEDIC
		#error The "Medic" (mt_medic.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_METEOR
		#error The "Meteor" (mt_meteor.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_MINION
		#error The "Minion" (mt_minion.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_NULLIFY
		#error The "Nullify" (mt_nullify.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_OMNI
		#error The "Omni" (mt_omni.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PANIC
		#error The "Panic" (mt_panic.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PUKE
		#error The "Puke" (mt_puke.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_PYRO
		#error The "Pyro" (mt_pyro.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_QUIET
		#error The "Quiet" (mt_quiet.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RECALL
		#error The "Recall" (mt_recall.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RECOIL
		#error The "Recoil" (mt_recoil.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_REGEN
		#error The "Regen" (mt_regen.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RESPAWN
		#error The "Respawn" (mt_respawn.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_RESTART
		#error The "Restart" (mt_restart.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_ROCK
		#error The "Rock" (mt_rock.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SHIELD
		#error The "Shield" (mt_shield.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SHOVE
		#error The "Shove" (mt_shove.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SLOW
		#error The "Slow" (mt_slow.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_SMASH
		#error The "Smash" (mt_smash.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_THROW
		#error The "Throw" (mt_throw.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_TRACK
		#error The "Track" (mt_track.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_ULTIMATE
		#error The "Ultimate" (mt_ultimate.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_UNDEAD
		#error The "Undead" (mt_undead.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_VISION
		#error The "Vision" (mt_vision.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WARP
		#error The "Warp" (mt_warp.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WHIRL
		#error The "Whirl" (mt_whirl.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_WITCH
		#error The "Witch" (mt_witch.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
	#if !defined MT_MENU_YELL
		#error The "Yell" (mt_yell.sp) ability is missing from the "scripting/mutant_tanks/abilities2" folder.
	#endif
#endif

/**
 * Third-party natives
 **/

// [L4D & L4D2] Lagged Movement - Plugin Conflict Resolver: https://forums.alliedmods.net/showthread.php?t=340345
native any L4D_LaggedMovement(int client, float value, bool force = false);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Abilities Set #2\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	MarkNativeAsOptional("L4D_LaggedMovement");

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

public void OnAllPluginsLoaded()
{
	GameData gdMutantTanks = new GameData(MT_GAMEDATA);
	if (gdMutantTanks == null)
	{
		LogError("%s Unable to load the \"%s\" gamedata file.", MT_TAG, MT_GAMEDATA);

		return;
	}
#if defined MT_MENU_RESTART
	vRestartAllPluginsLoaded(gdMutantTanks);
#endif
#if defined MT_MENU_WARP
	vWarpAllPluginsLoaded(gdMutantTanks);
#endif
	delete gdMutantTanks;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_ability2", cmdAbilityInfo2, "View information about each ability (L-Z).");

	vAbilitySetup(0);

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
			}
		}
#if defined MT_MENU_SHIELD
		vShieldLateLoad();
#endif
		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vAbilitySetup(1);
}

public void OnClientPutInServer(int client)
{
	vAbilityPlayer(0, client);
}

public void OnClientDisconnect(int client)
{
	vAbilityPlayer(1, client);
}

public void OnClientDisconnect_Post(int client)
{
	vAbilityPlayer(2, client);
}

public void OnMapEnd()
{
	vAbilitySetup(2);
}

public void MT_OnPluginEnd()
{
	vAbilitySetup(3);
}

public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}

public void OnEntityCreated(int entity, const char[] classname)
{
#if defined MT_MENU_METEOR
	vMeteorEntityCreated(entity, classname);
#endif
#if defined MT_MENU_SHIELD
	vShieldEntityCreated(entity, classname);
#endif
#if defined MT_MENU_SMASH
	vSmashEntityCreated(entity, classname);
#endif
}

public void OnEntityDestroyed(int entity)
{
#if defined MT_MENU_THROW
	vThrowEntityDestroyed(entity);
#endif
}

Action cmdAbilityInfo2(int client, int args)
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

	switch (args)
	{
		case 1:
		{
			switch (IsVoteInProgress())
			{
				case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
				case false:
				{
					char sName[32];
					GetCmdArg(1, sName, sizeof sName);
					vAbilityMenu(client, sName);
				}
			}
		}
		default:
		{
			char sCmd[15];
			GetCmdArg(0, sCmd, sizeof sCmd);
			MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage2", sCmd);
		}
	}

	return Plugin_Handled;
}

public void MT_OnDisplayMenu(Menu menu)
{
#if defined MT_MENU_LAG
	vLagDisplayMenu(menu);
#endif
#if defined MT_MENU_LASER
	vLaserDisplayMenu(menu);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningDisplayMenu(menu);
#endif
#if defined MT_MENU_MEDIC
	vMedicDisplayMenu(menu);
#endif
#if defined MT_MENU_METEOR
	vMeteorDisplayMenu(menu);
#endif
#if defined MT_MENU_MINION
	vMinionDisplayMenu(menu);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyDisplayMenu(menu);
#endif
#if defined MT_MENU_OMNI
	vOmniDisplayMenu(menu);
#endif
#if defined MT_MENU_PANIC
	vPanicDisplayMenu(menu);
#endif
#if defined MT_MENU_PUKE
	vPukeDisplayMenu(menu);
#endif
#if defined MT_MENU_PYRO
	vPyroDisplayMenu(menu);
#endif
#if defined MT_MENU_QUIET
	vQuietDisplayMenu(menu);
#endif
#if defined MT_MENU_RECALL
	vRecallDisplayMenu(menu);
#endif
#if defined MT_MENU_RECOIL
	vRecoilDisplayMenu(menu);
#endif
#if defined MT_MENU_REGEN
	vRegenDisplayMenu(menu);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnDisplayMenu(menu);
#endif
#if defined MT_MENU_RESTART
	vRestartDisplayMenu(menu);
#endif
#if defined MT_MENU_ROCK
	vRockDisplayMenu(menu);
#endif
#if defined MT_MENU_SHIELD
	vShieldDisplayMenu(menu);
#endif
#if defined MT_MENU_SHOVE
	vShoveDisplayMenu(menu);
#endif
#if defined MT_MENU_SLOW
	vSlowDisplayMenu(menu);
#endif
#if defined MT_MENU_SMASH
	vSmashDisplayMenu(menu);
#endif
#if defined MT_MENU_THROW
	vThrowDisplayMenu(menu);
#endif
#if defined MT_MENU_TRACK
	vTrackDisplayMenu(menu);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateDisplayMenu(menu);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadDisplayMenu(menu);
#endif
#if defined MT_MENU_VISION
	vVisionDisplayMenu(menu);
#endif
#if defined MT_MENU_WARP
	vWarpDisplayMenu(menu);
#endif
#if defined MT_MENU_WHIRL
	vWhirlDisplayMenu(menu);
#endif
#if defined MT_MENU_WITCH
	vWitchDisplayMenu(menu);
#endif
#if defined MT_MENU_YELL
	vYellDisplayMenu(menu);
#endif
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
#if defined MT_MENU_LAG
	vLagMenuItemSelected(client, info);
#endif
#if defined MT_MENU_LASER
	vLaserMenuItemSelected(client, info);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningMenuItemSelected(client, info);
#endif
#if defined MT_MENU_MEDIC
	vMedicMenuItemSelected(client, info);
#endif
#if defined MT_MENU_METEOR
	vMeteorMenuItemSelected(client, info);
#endif
#if defined MT_MENU_MINION
	vMinionMenuItemSelected(client, info);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyMenuItemSelected(client, info);
#endif
#if defined MT_MENU_OMNI
	vOmniMenuItemSelected(client, info);
#endif
#if defined MT_MENU_PANIC
	vPanicMenuItemSelected(client, info);
#endif
#if defined MT_MENU_PUKE
	vPukeMenuItemSelected(client, info);
#endif
#if defined MT_MENU_PYRO
	vPyroMenuItemSelected(client, info);
#endif
#if defined MT_MENU_QUIET
	vQuietMenuItemSelected(client, info);
#endif
#if defined MT_MENU_RECALL
	vRecallMenuItemSelected(client, info);
#endif
#if defined MT_MENU_RECOIL
	vRecoilMenuItemSelected(client, info);
#endif
#if defined MT_MENU_REGEN
	vRegenMenuItemSelected(client, info);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnMenuItemSelected(client, info);
#endif
#if defined MT_MENU_RESTART
	vRestartMenuItemSelected(client, info);
#endif
#if defined MT_MENU_ROCK
	vRockMenuItemSelected(client, info);
#endif
#if defined MT_MENU_SHIELD
	vShieldMenuItemSelected(client, info);
#endif
#if defined MT_MENU_SHOVE
	vShoveMenuItemSelected(client, info);
#endif
#if defined MT_MENU_SLOW
	vSlowMenuItemSelected(client, info);
#endif
#if defined MT_MENU_SMASH
	vSmashMenuItemSelected(client, info);
#endif
#if defined MT_MENU_THROW
	vThrowMenuItemSelected(client, info);
#endif
#if defined MT_MENU_TRACK
	vTrackMenuItemSelected(client, info);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateMenuItemSelected(client, info);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadMenuItemSelected(client, info);
#endif
#if defined MT_MENU_VISION
	vVisionMenuItemSelected(client, info);
#endif
#if defined MT_MENU_WARP
	vWarpMenuItemSelected(client, info);
#endif
#if defined MT_MENU_WHIRL
	vWhirlMenuItemSelected(client, info);
#endif
#if defined MT_MENU_WITCH
	vWitchMenuItemSelected(client, info);
#endif
#if defined MT_MENU_YELL
	vYellMenuItemSelected(client, info);
#endif
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
#if defined MT_MENU_LAG
	vLagMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_LASER
	vLaserMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_MEDIC
	vMedicMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_METEOR
	vMeteorMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_MINION
	vMinionMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_OMNI
	vOmniMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_PANIC
	vPanicMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_PUKE
	vPukeMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_PYRO
	vPyroMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_QUIET
	vQuietMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_RECALL
	vRecallMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_RECOIL
	vRecoilMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_REGEN
	vRegenMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_RESTART
	vRestartMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_ROCK
	vRockMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_SHIELD
	vShieldMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_SHOVE
	vShoveMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_SLOW
	vSlowMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_SMASH
	vSmashMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_THROW
	vThrowMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_TRACK
	vTrackMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_VISION
	vVisionMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_WARP
	vWarpMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_WHIRL
	vWhirlMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_WITCH
	vWitchMenuItemDisplayed(client, info, buffer, size);
#endif
#if defined MT_MENU_YELL
	vYellMenuItemDisplayed(client, info, buffer, size);
#endif
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled())
	{
		return Plugin_Continue;
	}
#if defined MT_MENU_OMNI
	vOmniPlayerRunCmd(client);
#endif
#if defined MT_MENU_PYRO
	vPyroPlayerRunCmd(client);
#endif
#if defined MT_MENU_RECALL
	vRecallPlayerRunCmd(client, buttons);
#endif
#if defined MT_MENU_PYRO
	vRespawnPlayerRunCmd(client);
#endif
#if defined MT_MENU_SHIELD
	vShieldPlayerRunCmd(client);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimatePlayerRunCmd(client);
#endif
	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList list)
{
#if defined MT_MENU_LAG
	vLagPluginCheck(list);
#endif
#if defined MT_MENU_LASER
	vLaserPluginCheck(list);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningPluginCheck(list);
#endif
#if defined MT_MENU_MEDIC
	vMedicPluginCheck(list);
#endif
#if defined MT_MENU_METEOR
	vMeteorPluginCheck(list);
#endif
#if defined MT_MENU_MINION
	vMinionPluginCheck(list);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyPluginCheck(list);
#endif
#if defined MT_MENU_OMNI
	vOmniPluginCheck(list);
#endif
#if defined MT_MENU_PANIC
	vPanicPluginCheck(list);
#endif
#if defined MT_MENU_PUKE
	vPukePluginCheck(list);
#endif
#if defined MT_MENU_PYRO
	vPyroPluginCheck(list);
#endif
#if defined MT_MENU_QUIET
	vQuietPluginCheck(list);
#endif
#if defined MT_MENU_RECALL
	vRecallPluginCheck(list);
#endif
#if defined MT_MENU_RECOIL
	vRecoilPluginCheck(list);
#endif
#if defined MT_MENU_REGEN
	vRegenPluginCheck(list);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnPluginCheck(list);
#endif
#if defined MT_MENU_RESTART
	vRestartPluginCheck(list);
#endif
#if defined MT_MENU_ROCK
	vRockPluginCheck(list);
#endif
#if defined MT_MENU_SHIELD
	vShieldPluginCheck(list);
#endif
#if defined MT_MENU_SHOVE
	vShovePluginCheck(list);
#endif
#if defined MT_MENU_SLOW
	vSlowPluginCheck(list);
#endif
#if defined MT_MENU_SMASH
	vSmashPluginCheck(list);
#endif
#if defined MT_MENU_THROW
	vThrowPluginCheck(list);
#endif
#if defined MT_MENU_TRACK
	vTrackPluginCheck(list);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimatePluginCheck(list);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadPluginCheck(list);
#endif
#if defined MT_MENU_VISION
	vVisionPluginCheck(list);
#endif
#if defined MT_MENU_WARP
	vWarpPluginCheck(list);
#endif
#if defined MT_MENU_WHIRL
	vWhirlPluginCheck(list);
#endif
#if defined MT_MENU_WITCH
	vWitchPluginCheck(list);
#endif
#if defined MT_MENU_YELL
	vYellPluginCheck(list);
#endif
}

public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
{
#if defined MT_MENU_LAG
	vLagAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_LASER
	vLaserAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_MEDIC
	vMedicAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_METEOR
	vMeteorAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_MINION
	vMinionAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_OMNI
	vOmniAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_PANIC
	vPanicAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_PUKE
	vPukeAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_PYRO
	vPyroAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_QUIET
	vQuietAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_RECALL
	vRecallAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_RECOIL
	vRecoilAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_REGEN
	vRegenAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_RESTART
	vRestartAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_ROCK
	vRockAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_SHIELD
	vShieldAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_SHOVE
	vShoveAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_SLOW
	vSlowAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_SMASH
	vSmashAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_THROW
	vThrowAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_TRACK
	vTrackAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_VISION
	vVisionAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_WARP
	vWarpAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_WHIRL
	vWhirlAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_WITCH
	vWitchAbilityCheck(list, list2, list3, list4);
#endif
#if defined MT_MENU_YELL
	vYellAbilityCheck(list, list2, list3, list4);
#endif
}

public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
#if defined MT_MENU_LAG
	vLagCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_LASER
	vLaserCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_MEDIC
	vMedicCombineAbilities(tank, type, random, combo, weapon);
#endif
#if defined MT_MENU_METEOR
	vMeteorCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_MINION
	vMinionCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_OMNI
	vOmniCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_PANIC
	vPanicCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_PUKE
	vPukeCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_PYRO
	vPyroCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_QUIET
	vQuietCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_RECOIL
	vRecoilCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_REGEN
	vRegenCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_RESTART
	vRestartCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_ROCK
	vRockCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_SHIELD
	vShieldCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_SHOVE
	vShoveCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_SLOW
	vSlowCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_SMASH
	vSmashCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_THROW
	vThrowCombineAbilities(tank, type, random, combo, weapon);
#endif
#if defined MT_MENU_TRACK
	vTrackCombineAbilities(tank, type, random, combo, weapon);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_VISION
	vVisionCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_WARP
	vWarpCombineAbilities(tank, type, random, combo, survivor, weapon, classname);
#endif
#if defined MT_MENU_WHIRL
	vWhirlCombineAbilities(tank, type, random, combo, survivor, classname);
#endif
#if defined MT_MENU_WITCH
	vWitchCombineAbilities(tank, type, random, combo);
#endif
#if defined MT_MENU_YELL
	vYellCombineAbilities(tank, type, random, combo);
#endif
}

public void MT_OnConfigsLoad(int mode)
{
#if defined MT_MENU_LAG
	vLagConfigsLoad(mode);
#endif
#if defined MT_MENU_LASER
	vLaserConfigsLoad(mode);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningConfigsLoad(mode);
#endif
#if defined MT_MENU_MEDIC
	vMedicConfigsLoad(mode);
#endif
#if defined MT_MENU_METEOR
	vMeteorConfigsLoad(mode);
#endif
#if defined MT_MENU_MINION
	vMinionConfigsLoad(mode);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyConfigsLoad(mode);
#endif
#if defined MT_MENU_OMNI
	vOmniConfigsLoad(mode);
#endif
#if defined MT_MENU_PANIC
	vPanicConfigsLoad(mode);
#endif
#if defined MT_MENU_PUKE
	vPukeConfigsLoad(mode);
#endif
#if defined MT_MENU_PYRO
	vPyroConfigsLoad(mode);
#endif
#if defined MT_MENU_QUIET
	vQuietConfigsLoad(mode);
#endif
#if defined MT_MENU_RECALL
	vRecallConfigsLoad(mode);
#endif
#if defined MT_MENU_RECOIL
	vRecoilConfigsLoad(mode);
#endif
#if defined MT_MENU_REGEN
	vRegenConfigsLoad(mode);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnConfigsLoad(mode);
#endif
#if defined MT_MENU_RESTART
	vRestartConfigsLoad(mode);
#endif
#if defined MT_MENU_ROCK
	vRockConfigsLoad(mode);
#endif
#if defined MT_MENU_SHIELD
	vShieldConfigsLoad(mode);
#endif
#if defined MT_MENU_SHOVE
	vShoveConfigsLoad(mode);
#endif
#if defined MT_MENU_SLOW
	vSlowConfigsLoad(mode);
#endif
#if defined MT_MENU_SMASH
	vSmashConfigsLoad(mode);
#endif
#if defined MT_MENU_THROW
	vThrowConfigsLoad(mode);
#endif
#if defined MT_MENU_TRACK
	vTrackConfigsLoad(mode);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateConfigsLoad(mode);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadConfigsLoad(mode);
#endif
#if defined MT_MENU_VISION
	vVisionConfigsLoad(mode);
#endif
#if defined MT_MENU_WARP
	vWarpConfigsLoad(mode);
#endif
#if defined MT_MENU_WHIRL
	vWhirlConfigsLoad(mode);
#endif
#if defined MT_MENU_WITCH
	vWitchConfigsLoad(mode);
#endif
#if defined MT_MENU_YELL
	vYellConfigsLoad(mode);
#endif
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
{
#if defined MT_MENU_LAG
	vLagConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_LASER
	vLaserConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_MEDIC
	vMedicConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_METEOR
	vMeteorConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_MINION
	vMinionConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_OMNI
	vOmniConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_PANIC
	vPanicConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_PUKE
	vPukeConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_PYRO
	vPyroConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_QUIET
	vQuietConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_RECALL
	vRecallConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_RECOIL
	vRecoilConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_REGEN
	vRegenConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_RESTART
	vRestartConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_ROCK
	vRockConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_SHIELD
	vShieldConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_SHOVE
	vShoveConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_SLOW
	vSlowConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_SMASH
	vSmashConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_THROW
	vThrowConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_TRACK
	vTrackConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_VISION
	vVisionConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_WARP
	vWarpConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_WHIRL
	vWhirlConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_WITCH
	vWitchConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
#if defined MT_MENU_YELL
	vYellConfigsLoaded(subsection, key, value, type, admin, mode, special, specsection);
#endif
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	g_iGraphicsLevel = MT_GetGraphicsLevel();
#if defined MT_MENU_LAG
	vLagSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_LASER
	vLaserSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_MEDIC
	vMedicSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_METEOR
	vMeteorSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_MINION
	vMinionSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_NULLIFY
	vNullifySettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_OMNI
	vOmniSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_PANIC
	vPanicSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_PUKE
	vPukeSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_PYRO
	vPyroSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_QUIET
	vQuietSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_RECALL
	vRecallSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_RECOIL
	vRecoilSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_REGEN
	vRegenSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_RESTART
	vRestartSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_ROCK
	vRockSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_SHIELD
	vShieldSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_SHOVE
	vShoveSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_SLOW
	vSlowSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_SMASH
	vSmashSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_THROW
	vThrowSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_TRACK
	vTrackSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_VISION
	vVisionSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_WARP
	vWarpSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_WHIRL
	vWhirlSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_WITCH
	vWitchSettingsCached(tank, apply, type);
#endif
#if defined MT_MENU_YELL
	vYellSettingsCached(tank, apply, type);
#endif
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
#if defined MT_MENU_LAG
	vLagCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_LASER
	vLaserCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_MEDIC
	vMedicCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_METEOR
	vMeteorCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_MINION
	vMinionCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_OMNI
	vOmniCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_PANIC
	vPanicCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_PUKE
	vPukeCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_PYRO
	vPyroCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_QUIET
	vQuietCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_RECALL
	vRecallCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_RECOIL
	vRecoilCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_REGEN
	vRegenCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_RESTART
	vRestartCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_ROCK
	vRockCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_SHIELD
	vShieldCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_SHOVE
	vShoveCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_SLOW
	vSlowCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_SMASH
	vSmashCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_THROW
	vThrowCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_TRACK
	vTrackCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_VISION
	vVisionCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_WARP
	vWarpCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_WHIRL
	vWhirlCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_WITCH
	vWitchCopyStats(oldTank, newTank);
#endif
#if defined MT_MENU_YELL
	vYellCopyStats(oldTank, newTank);
#endif
}

public void MT_OnHookEvent(bool hooked)
{
#if defined MT_MENU_RECOIL
	vRecoilHookEvent(hooked);
#endif
#if defined MT_MENU_RESTART
	vRestartHookEvent(hooked);
#endif
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
#if defined MT_MENU_LAG
	vLagEventFired(event, name);
#endif
#if defined MT_MENU_LASER
	vLaserEventFired(event, name);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningEventFired(event, name);
#endif
#if defined MT_MENU_MEDIC
	vMedicEventFired(event, name);
#endif
#if defined MT_MENU_METEOR
	vMeteorEventFired(event, name);
#endif
#if defined MT_MENU_MINION
	vMinionEventFired(event, name);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyEventFired(event, name);
#endif
#if defined MT_MENU_OMNI
	vOmniEventFired(event, name);
#endif
#if defined MT_MENU_PANIC
	vPanicEventFired(event, name);
#endif
#if defined MT_MENU_PUKE
	vPukeEventFired(event, name);
#endif
#if defined MT_MENU_PYRO
	vPyroEventFired(event, name);
#endif
#if defined MT_MENU_QUIET
	vQuietEventFired(event, name);
#endif
#if defined MT_MENU_RECALL
	vRecallEventFired(event, name);
#endif
#if defined MT_MENU_RECOIL
	vRecoilEventFired(event, name);
#endif
#if defined MT_MENU_REGEN
	vRegenEventFired(event, name);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnEventFired(event, name);
#endif
#if defined MT_MENU_RESTART
	vRestartEventFired(event, name);
#endif
#if defined MT_MENU_ROCK
	vRockEventFired(event, name);
#endif
#if defined MT_MENU_SHIELD
	vShieldEventFired(event, name);
#endif
#if defined MT_MENU_SHOVE
	vShoveEventFired(event, name);
#endif
#if defined MT_MENU_SLOW
	vSlowEventFired(event, name);
#endif
#if defined MT_MENU_SMASH
	vSmashEventFired(event, name);
#endif
#if defined MT_MENU_THROW
	vThrowEventFired(event, name);
#endif
#if defined MT_MENU_TRACK
	vTrackEventFired(event, name);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateEventFired(event, name);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadEventFired(event, name);
#endif
#if defined MT_MENU_VISION
	vVisionEventFired(event, name);
#endif
#if defined MT_MENU_WARP
	vWarpEventFired(event, name);
#endif
#if defined MT_MENU_WHIRL
	vWhirlEventFired(event, name);
#endif
#if defined MT_MENU_WITCH
	vWitchEventFired(event, name);
#endif
#if defined MT_MENU_YELL
	vYellEventFired(event, name);
#endif
}

public void MT_OnAbilityActivated(int tank)
{
	vAbilityPlayer(3, tank);
}

public void MT_OnButtonPressed(int tank, int button)
{
#if defined MT_MENU_LAG
	vLagButtonPressed(tank, button);
#endif
#if defined MT_MENU_LASER
	vLaserButtonPressed(tank, button);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningButtonPressed(tank, button);
#endif
#if defined MT_MENU_MEDIC
	vMedicButtonPressed(tank, button);
#endif
#if defined MT_MENU_METEOR
	vMeteorButtonPressed(tank, button);
#endif
#if defined MT_MENU_MINION
	vMinionButtonPressed(tank, button);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyButtonPressed(tank, button);
#endif
#if defined MT_MENU_OMNI
	vOmniButtonPressed(tank, button);
#endif
#if defined MT_MENU_PANIC
	vPanicButtonPressed(tank, button);
#endif
#if defined MT_MENU_PUKE
	vPukeButtonPressed(tank, button);
#endif
#if defined MT_MENU_PYRO
	vPyroButtonPressed(tank, button);
#endif
#if defined MT_MENU_QUIET
	vQuietButtonPressed(tank, button);
#endif
#if defined MT_MENU_RECALL
	vRecallButtonPressed(tank, button);
#endif
#if defined MT_MENU_RECOIL
	vRecoilButtonPressed(tank, button);
#endif
#if defined MT_MENU_REGEN
	vRegenButtonPressed(tank, button);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnButtonPressed(tank, button);
#endif
#if defined MT_MENU_RESTART
	vRestartButtonPressed(tank, button);
#endif
#if defined MT_MENU_ROCK
	vRockButtonPressed(tank, button);
#endif
#if defined MT_MENU_SHIELD
	vShieldButtonPressed(tank, button);
#endif
#if defined MT_MENU_SHOVE
	vShoveButtonPressed(tank, button);
#endif
#if defined MT_MENU_SLOW
	vSlowButtonPressed(tank, button);
#endif
#if defined MT_MENU_SMASH
	vSmashButtonPressed(tank, button);
#endif
#if defined MT_MENU_THROW
	vThrowButtonPressed(tank, button);
#endif
#if defined MT_MENU_TRACK
	vTrackButtonPressed(tank, button);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateButtonPressed(tank, button);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadButtonPressed(tank, button);
#endif
#if defined MT_MENU_VISION
	vVisionButtonPressed(tank, button);
#endif
#if defined MT_MENU_WARP
	vWarpButtonPressed(tank, button);
#endif
#if defined MT_MENU_WHIRL
	vWhirlButtonPressed(tank, button);
#endif
#if defined MT_MENU_WITCH
	vWitchButtonPressed(tank, button);
#endif
#if defined MT_MENU_YELL
	vYellButtonPressed(tank, button);
#endif
}

public void MT_OnButtonReleased(int tank, int button)
{
#if defined MT_MENU_LASER
	vLaserButtonReleased(tank, button);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningButtonReleased(tank, button);
#endif
#if defined MT_MENU_MEDIC
	vMedicButtonReleased(tank, button);
#endif
#if defined MT_MENU_METEOR
	vMeteorButtonReleased(tank, button);
#endif
#if defined MT_MENU_OMNI
	vOmniButtonReleased(tank, button);
#endif
#if defined MT_MENU_PANIC
	vPanicButtonReleased(tank, button);
#endif
#if defined MT_MENU_PYRO
	vPyroButtonReleased(tank, button);
#endif
#if defined MT_MENU_REGEN
	vRegenButtonReleased(tank, button);
#endif
#if defined MT_MENU_PANIC
	vRespawnButtonReleased(tank, button);
#endif
#if defined MT_MENU_ROCK
	vRockButtonReleased(tank, button);
#endif
#if defined MT_MENU_SHIELD
	vShieldButtonReleased(tank, button);
#endif
#if defined MT_MENU_WARP
	vWarpButtonReleased(tank, button);
#endif
#if defined MT_MENU_YELL
	vYellButtonReleased(tank, button);
#endif
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
#if defined MT_MENU_LAG
	vLagChangeType(tank, oldType);
#endif
#if defined MT_MENU_LASER
	vLaserChangeType(tank, oldType);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningChangeType(tank, oldType);
#endif
#if defined MT_MENU_MEDIC
	vMedicChangeType(tank, oldType);
#endif
#if defined MT_MENU_METEOR
	vMeteorChangeType(tank, oldType);
#endif
#if defined MT_MENU_MINION
	vMinionChangeType(tank, oldType);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyChangeType(tank, oldType);
#endif
#if defined MT_MENU_PANIC
	vPanicChangeType(tank, oldType);
#endif
#if defined MT_MENU_PUKE
	vPukeChangeType(tank, oldType);
#endif
#if defined MT_MENU_PYRO
	vPyroChangeType(tank, oldType);
#endif
#if defined MT_MENU_QUIET
	vQuietChangeType(tank, oldType);
#endif
#if defined MT_MENU_RECALL
	vRecallChangeType(tank, oldType);
#endif
#if defined MT_MENU_RECOIL
	vRecoilChangeType(tank, oldType);
#endif
#if defined MT_MENU_REGEN
	vRegenChangeType(tank, oldType);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnChangeType(tank, oldType, revert);
#endif
#if defined MT_MENU_RESTART
	vRestartChangeType(tank, oldType);
#endif
#if defined MT_MENU_ROCK
	vRockChangeType(tank, oldType);
#endif
#if defined MT_MENU_SHIELD
	vShieldChangeType(tank, oldType);
#endif
#if defined MT_MENU_SHOVE
	vShoveChangeType(tank, oldType);
#endif
#if defined MT_MENU_SLOW
	vSlowChangeType(tank, oldType);
#endif
#if defined MT_MENU_SMASH
	vSmashChangeType(tank, oldType);
#endif
#if defined MT_MENU_THROW
	vThrowChangeType(tank, oldType);
#endif
#if defined MT_MENU_TRACK
	vTrackChangeType(tank, oldType);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateChangeType(tank, oldType);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadChangeType(tank, oldType);
#endif
#if defined MT_MENU_VISION
	vVisionChangeType(tank, oldType);
#endif
#if defined MT_MENU_WARP
	vWarpChangeType(tank, oldType);
#endif
#if defined MT_MENU_WHIRL
	vWhirlChangeType(tank, oldType);
#endif
#if defined MT_MENU_WITCH
	vWitchChangeType(tank, oldType);
#endif
#if defined MT_MENU_YELL
	vYellChangeType(tank, oldType);
#endif
}

public void MT_OnPostTankSpawn(int tank)
{
	vAbilityPlayer(4, tank);
}

public Action MT_OnFatalFalling(int survivor)
{
#if defined MT_MENU_RECALL
	vRecallFatalFalling(survivor);
#endif
	return Plugin_Continue;
}

public void MT_OnPlayerEventKilled(int victim, int attacker)
{
#if defined MT_MENU_RECALL
	vRecallPlayerEventKilled(victim);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnPlayerEventKilled(victim);
#endif
#if defined MT_MENU_SMASH
	vSmashPlayerEventKilled(victim, attacker);
#endif
#if defined MT_MENU_WARP
	vWarpPlayerEventKilled(victim);
#endif
}

public Action MT_OnPlayerHitByVomitJar(int player, int thrower)
{
	Action aReturn = Plugin_Continue;
#if defined MT_MENU_SHIELD
	Action aResult = aShieldPlayerHitByVomitJar(player, thrower);
	if (aResult != Plugin_Continue)
	{
		aReturn = aResult;
	}
#endif
	return aReturn;
}

public Action MT_OnPlayerShovedBySurvivor(int player, int survivor, const float direction[3])
{
	Action aReturn = Plugin_Continue;
#if defined MT_MENU_SHIELD
	Action aResult = aShieldPlayerShovedBySurvivor(player, survivor);
	if (aResult != Plugin_Continue)
	{
		aReturn = aResult;
	}
#endif
	return aReturn;
}

public Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply)
{
#if defined MT_MENU_RECALL
	vRecallRewardSurvivor(survivor, type, apply);
#endif
	Action aReturn = Plugin_Continue;
#if defined MT_MENU_RESPAWN
	Action aResult = aRespawnRewardSurvivor(tank, priority, apply);
	if (aResult != Plugin_Continue)
	{
		aReturn = aResult;
	}
#endif
#if defined MT_MENU_SLOW
	vSlowRewardSurvivor(survivor, type, apply);
#endif
	return aReturn;
}

public void MT_OnRockThrow(int tank, int rock)
{
#if defined MT_MENU_SHIELD
	vShieldRockThrow(tank, rock);
#endif
#if defined MT_MENU_THROW
	vThrowRockThrow(tank, rock);
#endif
#if defined MT_MENU_TRACK
	vTrackRockThrow(tank, rock);
#endif
}

public void MT_OnRockBreak(int tank, int rock)
{
#if defined MT_MENU_MEDIC
	vMedicRockBreak(tank, rock);
#endif
#if defined MT_MENU_TRACK
	vTrackRockBreak(rock);
#endif
#if defined MT_MENU_WARP
	vWarpRockBreak(tank, rock);
#endif
}

void vAbilityMenu(int client, const char[] name)
{
#if defined MT_MENU_LAG
	vLagMenu(client, name, 0);
#endif
#if defined MT_MENU_LASER
	vLaserMenu(client, name, 0);
#endif
#if defined MT_MENU_LIGHTNING
	vLightningMenu(client, name, 0);
#endif
#if defined MT_MENU_MEDIC
	vMedicMenu(client, name, 0);
#endif
#if defined MT_MENU_METEOR
	vMeteorMenu(client, name, 0);
#endif
#if defined MT_MENU_MINION
	vMinionMenu(client, name, 0);
#endif
#if defined MT_MENU_NULLIFY
	vNullifyMenu(client, name, 0);
#endif
#if defined MT_MENU_OMNI
	vOmniMenu(client, name, 0);
#endif
#if defined MT_MENU_PANIC
	vPanicMenu(client, name, 0);
#endif
#if defined MT_MENU_PUKE
	vPukeMenu(client, name, 0);
#endif
#if defined MT_MENU_PYRO
	vPyroMenu(client, name, 0);
#endif
#if defined MT_MENU_QUIET
	vQuietMenu(client, name, 0);
#endif
#if defined MT_MENU_RECALL
	vRecallMenu(client, name, 0);
#endif
#if defined MT_MENU_RECOIL
	vRecoilMenu(client, name, 0);
#endif
#if defined MT_MENU_REGEN
	vRegenMenu(client, name, 0);
#endif
#if defined MT_MENU_RESPAWN
	vRespawnMenu(client, name, 0);
#endif
#if defined MT_MENU_RESTART
	vRestartMenu(client, name, 0);
#endif
#if defined MT_MENU_ROCK
	vRockMenu(client, name, 0);
#endif
#if defined MT_MENU_SHIELD
	vShieldMenu(client, name, 0);
#endif
#if defined MT_MENU_SHOVE
	vShoveMenu(client, name, 0);
#endif
#if defined MT_MENU_SLOW
	vSlowMenu(client, name, 0);
#endif
#if defined MT_MENU_SMASH
	vSmashMenu(client, name, 0);
#endif
#if defined MT_MENU_THROW
	vThrowMenu(client, name, 0);
#endif
#if defined MT_MENU_TRACK
	vTrackMenu(client, name, 0);
#endif
#if defined MT_MENU_ULTIMATE
	vUltimateMenu(client, name, 0);
#endif
#if defined MT_MENU_UNDEAD
	vUndeadMenu(client, name, 0);
#endif
#if defined MT_MENU_VISION
	vVisionMenu(client, name, 0);
#endif
#if defined MT_MENU_WARP
	vWarpMenu(client, name, 0);
#endif
#if defined MT_MENU_WHIRL
	vWhirlMenu(client, name, 0);
#endif
#if defined MT_MENU_WITCH
	vWitchMenu(client, name, 0);
#endif
#if defined MT_MENU_YELL
	vYellMenu(client, name, 0);
#endif
	bool bLog = false;
	if (bLog)
	{
		MT_LogMessage(-1, "%s Ability Menu (%i, %s) - This should never fire.", MT_TAG, client, name);
	}
}

void vAbilityPlayer(int type, int client)
{
#if defined MT_MENU_LAG
	switch (type)
	{
		case 0: vLagClientPutInServer(client);
		case 2: vLagClientDisconnect_Post(client);
		case 3: vLagAbilityActivated(client);
	}
#endif
#if defined MT_MENU_LASER
	switch (type)
	{
		case 0: vLaserClientPutInServer(client);
		case 2: vLaserClientDisconnect_Post(client);
		case 3: vLaserAbilityActivated(client);
	}
#endif
#if defined MT_MENU_LIGHTNING
	switch (type)
	{
		case 0: vLightningClientPutInServer(client);
		case 2: vLightningClientDisconnect_Post(client);
		case 3: vLightningAbilityActivated(client);
	}
#endif
#if defined MT_MENU_MEDIC
	switch (type)
	{
		case 0: vMedicClientPutInServer(client);
		case 2: vMedicClientDisconnect_Post(client);
		case 3: vMedicAbilityActivated(client);
	}
#endif
#if defined MT_MENU_METEOR
	switch (type)
	{
		case 0: vMeteorClientPutInServer(client);
		case 2: vMeteorClientDisconnect_Post(client);
		case 3: vMeteorAbilityActivated(client);
	}
#endif
#if defined MT_MENU_MINION
	switch (type)
	{
		case 0: vMinionClientPutInServer(client);
		case 1: vMinionClientDisconnect(client);
		case 2: vMinionClientDisconnect_Post(client);
		case 3: vMinionAbilityActivated(client);
	}
#endif
#if defined MT_MENU_NULLIFY
	switch (type)
	{
		case 0: vNullifyClientPutInServer(client);
		case 2: vNullifyClientDisconnect_Post(client);
		case 3: vNullifyAbilityActivated(client);
	}
#endif
#if defined MT_MENU_OMNI
	switch (type)
	{
		case 0: vOmniClientPutInServer(client);
		case 2: vOmniClientDisconnect_Post(client);
		case 3: vOmniAbilityActivated(client);
		case 4: vOmniPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_PANIC
	switch (type)
	{
		case 0: vPanicClientPutInServer(client);
		case 2: vPanicClientDisconnect_Post(client);
		case 3: vPanicAbilityActivated(client);
		case 4: vPanicPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_PUKE
	switch (type)
	{
		case 0: vPukeClientPutInServer(client);
		case 2: vPukeClientDisconnect_Post(client);
		case 3: vPukeAbilityActivated(client);
		case 4: vPukePostTankSpawn(client);
	}
#endif
#if defined MT_MENU_PYRO
	switch (type)
	{
		case 0: vPyroClientPutInServer(client);
		case 2: vPyroClientDisconnect_Post(client);
		case 3: vPyroAbilityActivated(client);
	}
#endif
#if defined MT_MENU_QUIET
	switch (type)
	{
		case 0: vQuietClientPutInServer(client);
		case 2: vQuietClientDisconnect_Post(client);
		case 3: vQuietAbilityActivated(client);
	}
#endif
#if defined MT_MENU_RECALL
	switch (type)
	{
		case 0: vRecallClientPutInServer(client);
		case 2: vRecallClientDisconnect_Post(client);
		case 3: vRecallAbilityActivated(client);
		case 4: vRecallPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_RECOIL
	switch (type)
	{
		case 0: vRecoilClientPutInServer(client);
		case 2: vRecoilClientDisconnect_Post(client);
		case 3: vRecoilAbilityActivated(client);
	}
#endif
#if defined MT_MENU_REGEN
	switch (type)
	{
		case 0: vRegenClientPutInServer(client);
		case 2: vRegenClientDisconnect_Post(client);
		case 3: vRegenAbilityActivated(client);
	}
#endif
#if defined MT_MENU_RESPAWN
	switch (type)
	{
		case 0: vRespawnClientPutInServer(client);
		case 2: vRespawnClientDisconnect_Post(client);
		case 3: vRespawnAbilityActivated(client);
	}
#endif
#if defined MT_MENU_RESTART
	switch (type)
	{
		case 0: vRestartClientPutInServer(client);
		case 2: vRestartClientDisconnect_Post(client);
		case 3: vRestartAbilityActivated(client);
	}
#endif
#if defined MT_MENU_ROCK
	switch (type)
	{
		case 0: vRockClientPutInServer(client);
		case 2: vRockClientDisconnect_Post(client);
		case 3: vRockAbilityActivated(client);
	}
#endif
#if defined MT_MENU_SHIELD
	switch (type)
	{
		case 0: vShieldClientPutInServer(client);
		case 2: vShieldClientDisconnect_Post(client);
		case 3: vShieldAbilityActivated(client);
	}
#endif
#if defined MT_MENU_SHOVE
	switch (type)
	{
		case 0: vShoveClientPutInServer(client);
		case 2: vShoveClientDisconnect_Post(client);
		case 3: vShoveAbilityActivated(client);
		case 4: vShovePostTankSpawn(client);
	}
#endif
#if defined MT_MENU_SLOW
	switch (type)
	{
		case 0: vSlowClientPutInServer(client);
		case 2: vSlowClientDisconnect_Post(client);
		case 3: vSlowAbilityActivated(client);
	}
#endif
#if defined MT_MENU_SMASH
	switch (type)
	{
		case 0: vSmashClientPutInServer(client);
		case 2: vSmashClientDisconnect_Post(client);
		case 3: vSmashAbilityActivated(client);
	}
#endif
#if defined MT_MENU_THROW
	switch (type)
	{
		case 0: vThrowClientPutInServer(client);
		case 2: vThrowClientDisconnect_Post(client);
	}
#endif
#if defined MT_MENU_TRACK
	switch (type)
	{
		case 0: vTrackClientPutInServer(client);
		case 2: vTrackClientDisconnect_Post(client);
	}
#endif
#if defined MT_MENU_ULTIMATE
	switch (type)
	{
		case 0: vUltimateClientPutInServer(client);
		case 2: vUltimateClientDisconnect_Post(client);
		case 3: vUltimateAbilityActivated(client);
	}
#endif
#if defined MT_MENU_UNDEAD
	switch (type)
	{
		case 0: vUndeadClientPutInServer(client);
		case 2: vUndeadClientDisconnect_Post(client);
		case 3: vUndeadAbilityActivated(client);
	}
#endif
#if defined MT_MENU_VISION
	switch (type)
	{
		case 0: vVisionClientPutInServer(client);
		case 2: vVisionClientDisconnect_Post(client);
		case 3: vVisionAbilityActivated(client);
		case 4: vVisionPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_WARP
	switch (type)
	{
		case 0: vWarpClientPutInServer(client);
		case 2: vWarpClientDisconnect_Post(client);
		case 3: vWarpAbilityActivated(client);
		case 4: vWarpPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_WHIRL
	switch (type)
	{
		case 0: vWhirlClientPutInServer(client);
		case 2: vWhirlClientDisconnect_Post(client);
		case 3: vWhirlAbilityActivated(client);
	}
#endif
#if defined MT_MENU_WITCH
	switch (type)
	{
		case 0: vWitchClientPutInServer(client);
		case 2: vWitchClientDisconnect_Post(client);
		case 3: vWitchAbilityActivated(client);
		case 4: vWitchPostTankSpawn(client);
	}
#endif
#if defined MT_MENU_YELL
	switch (type)
	{
		case 0: vYellClientPutInServer(client);
		case 2: vYellClientDisconnect_Post(client);
		case 3: vYellAbilityActivated(client);
	}
#endif
	bool bLog = false;
	if (bLog)
	{
		MT_LogMessage(-1, "%s Ability Player (%i, %i) - This should never fire.", MT_TAG, type, client);
	}
}

void vAbilitySetup(int type)
{
#if defined MT_MENU_LAG
	switch (type)
	{
		case 1: vLagMapStart();
		case 2: vLagMapEnd();
	}
#endif
#if defined MT_MENU_LASER
	switch (type)
	{
		case 1: vLaserMapStart();
		case 2: vLaserMapEnd();
	}
#endif
#if defined MT_MENU_LIGHTNING
	switch (type)
	{
		case 1: vLightningMapStart();
		case 2: vLightningMapEnd();
	}
#endif
#if defined MT_MENU_MEDIC
	switch (type)
	{
		case 1: vMedicMapStart();
		case 2: vMedicMapEnd();
	}
#endif
#if defined MT_MENU_METEOR
	switch (type)
	{
		case 1: vMeteorMapStart();
		case 2: vMeteorMapEnd();
	}
#endif
#if defined MT_MENU_MINION
	switch (type)
	{
		case 1: vMinionMapStart();
		case 2: vMinionMapEnd();
		case 3: vMinionPluginEnd();
	}
#endif
#if defined MT_MENU_NULLIFY
	switch (type)
	{
		case 1: vNullifyMapStart();
		case 2: vNullifyMapEnd();
	}
#endif
#if defined MT_MENU_OMNI
	switch (type)
	{
		case 1: vOmniMapStart();
		case 2: vOmniMapEnd();
	}
#endif
#if defined MT_MENU_PANIC
	switch (type)
	{
		case 1: vPanicMapStart();
		case 2: vPanicMapEnd();
	}
#endif
#if defined MT_MENU_PUKE
	switch (type)
	{
		case 1: vPukeMapStart();
		case 2: vPukeMapEnd();
	}
#endif
#if defined MT_MENU_PYRO
	switch (type)
	{
		case 1: vPyroMapStart();
		case 2: vPyroMapEnd();
		case 3: vPyroPluginEnd();
	}
#endif
#if defined MT_MENU_QUIET
	switch (type)
	{
		case 1: vQuietMapStart();
		case 2: vQuietMapEnd();
	}
#endif
#if defined MT_MENU_RECALL
	switch (type)
	{
		case 1: vRecallMapStart();
		case 2: vRecallMapEnd();
	}
#endif
#if defined MT_MENU_RECOIL
	switch (type)
	{
		case 1: vRecoilMapStart();
		case 2: vRecoilMapEnd();
	}
#endif
#if defined MT_MENU_REGEN
	switch (type)
	{
		case 1: vRegenMapStart();
		case 2: vRegenMapEnd();
	}
#endif
#if defined MT_MENU_RESPAWN
	switch (type)
	{
		case 1: vRespawnMapStart();
		case 2: vRespawnMapEnd();
	}
#endif
#if defined MT_MENU_RESTART
	switch (type)
	{
		case 1: vRestartMapStart();
		case 2: vRestartMapEnd();
	}
#endif
#if defined MT_MENU_ROCK
	switch (type)
	{
		case 1: vRockMapStart();
		case 2: vRockMapEnd();
	}
#endif
#if defined MT_MENU_SHIELD
	switch (type)
	{
		case 0: vShieldPluginStart();
		case 1: vShieldMapStart();
		case 2: vShieldMapEnd();
		case 3: vShieldPluginEnd();
	}
#endif
#if defined MT_MENU_SHOVE
	switch (type)
	{
		case 1: vShoveMapStart();
		case 2: vShoveMapEnd();
	}
#endif
#if defined MT_MENU_SLOW
	switch (type)
	{
		case 1: vSlowMapStart();
		case 2: vSlowMapEnd();
		case 3: vSlowPluginEnd();
	}
#endif
#if defined MT_MENU_SMASH
	switch (type)
	{
		case 1: vSmashMapStart();
		case 2: vSmashMapEnd();
		case 3: vSmashPluginEnd();
	}
#endif
#if defined MT_MENU_THROW
	switch (type)
	{
		case 0: vThrowPluginStart();
		case 1: vThrowMapStart();
		case 2: vThrowMapEnd();
		case 3: vThrowPluginEnd();
	}
#endif
#if defined MT_MENU_TRACK
	switch (type)
	{
		case 1: vTrackMapStart();
		case 2: vTrackMapEnd();
	}
#endif
#if defined MT_MENU_ULTIMATE
	switch (type)
	{
		case 1: vUltimateMapStart();
		case 2: vUltimateMapEnd();
		case 3: vUltimatePluginEnd();
	}
#endif
#if defined MT_MENU_UNDEAD
	switch (type)
	{
		case 1: vUndeadMapStart();
		case 2: vUndeadMapEnd();
	}
#endif
#if defined MT_MENU_VISION
	switch (type)
	{
		case 0: vVisionPluginStart();
		case 1: vVisionMapStart();
		case 2: vVisionMapEnd();
		case 3: vVisionPluginEnd();
	}
#endif
#if defined MT_MENU_WARP
	switch (type)
	{
		case 1: vWarpMapStart();
		case 2: vWarpMapEnd();
	}
#endif
#if defined MT_MENU_WHIRL
	switch (type)
	{
		case 1: vWhirlMapStart();
		case 2: vWhirlMapEnd();
		case 3: vWhirlPluginEnd();
	}
#endif
#if defined MT_MENU_WITCH
	switch (type)
	{
		case 1: vWitchMapStart();
		case 2: vWitchMapEnd();
	}
#endif
#if defined MT_MENU_YELL
	switch (type)
	{
		case 1: vYellMapStart();
		case 2: vYellMapEnd();
	}
#endif
	bool bLog = false;
	if (bLog)
	{
		MT_LogMessage(-1, "%s Ability Setup (%i) - This should never fire.", MT_TAG, type);
	}
}