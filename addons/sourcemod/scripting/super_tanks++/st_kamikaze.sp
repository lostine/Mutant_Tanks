// Super Tanks++: Kamikaze Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Kamikaze Ability",
	author = ST_AUTHOR,
	description = "The Super Tank kills itself along with a survivor victim.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sKamikazeEffect[ST_MAXTYPES + 1][4], g_sKamikazeEffect2[ST_MAXTYPES + 1][4];

float g_flKamikazeChance[ST_MAXTYPES + 1], g_flKamikazeChance2[ST_MAXTYPES + 1], g_flKamikazeRange[ST_MAXTYPES + 1], g_flKamikazeRange2[ST_MAXTYPES + 1], g_flKamikazeRangeChance[ST_MAXTYPES + 1], g_flKamikazeRangeChance2[ST_MAXTYPES + 1];

int g_iKamikazeAbility[ST_MAXTYPES + 1], g_iKamikazeAbility2[ST_MAXTYPES + 1], g_iKamikazeHit[ST_MAXTYPES + 1], g_iKamikazeHit2[ST_MAXTYPES + 1], g_iKamikazeHitMode[ST_MAXTYPES + 1], g_iKamikazeHitMode2[ST_MAXTYPES + 1], g_iKamikazeMessage[ST_MAXTYPES + 1], g_iKamikazeMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Kamikaze Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_BLOOD);

	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iKamikazeHitMode(attacker) == 0 || iKamikazeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vKamikazeHit(victim, attacker, flKamikazeChance(attacker), iKamikazeHit(attacker), 1, "1");
			}
		}
		else if ((iKamikazeHitMode(victim) == 0 || iKamikazeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vKamikazeHit(attacker, victim, flKamikazeChance(victim), iKamikazeHit(victim), 1, "2");
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iKamikazeAbility[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", 0);
				g_iKamikazeAbility[iIndex] = iClamp(g_iKamikazeAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Kamikaze Ability/Ability Effect", g_sKamikazeEffect[iIndex], sizeof(g_sKamikazeEffect[]), "123");
				g_iKamikazeMessage[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Message", 0);
				g_iKamikazeMessage[iIndex] = iClamp(g_iKamikazeMessage[iIndex], 0, 3);
				g_flKamikazeChance[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Chance", 33.3);
				g_flKamikazeChance[iIndex] = flClamp(g_flKamikazeChance[iIndex], 0.1, 100.0);
				g_iKamikazeHit[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", 0);
				g_iKamikazeHit[iIndex] = iClamp(g_iKamikazeHit[iIndex], 0, 1);
				g_iKamikazeHitMode[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", 0);
				g_iKamikazeHitMode[iIndex] = iClamp(g_iKamikazeHitMode[iIndex], 0, 2);
				g_flKamikazeRange[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", 150.0);
				g_flKamikazeRange[iIndex] = flClamp(g_flKamikazeRange[iIndex], 1.0, 9999999999.0);
				g_flKamikazeRangeChance[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range Chance", 15.0);
				g_flKamikazeRangeChance[iIndex] = flClamp(g_flKamikazeRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iKamikazeAbility2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", g_iKamikazeAbility[iIndex]);
				g_iKamikazeAbility2[iIndex] = iClamp(g_iKamikazeAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Kamikaze Ability/Ability Effect", g_sKamikazeEffect2[iIndex], sizeof(g_sKamikazeEffect2[]), g_sKamikazeEffect[iIndex]);
				g_iKamikazeMessage2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Message", g_iKamikazeMessage[iIndex]);
				g_iKamikazeMessage2[iIndex] = iClamp(g_iKamikazeMessage2[iIndex], 0, 3);
				g_flKamikazeChance2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Chance", g_flKamikazeChance[iIndex]);
				g_flKamikazeChance2[iIndex] = flClamp(g_flKamikazeChance2[iIndex], 0.1, 100.0);
				g_iKamikazeHit2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", g_iKamikazeHit[iIndex]);
				g_iKamikazeHit2[iIndex] = iClamp(g_iKamikazeHit2[iIndex], 0, 1);
				g_iKamikazeHitMode2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", g_iKamikazeHitMode[iIndex]);
				g_iKamikazeHitMode2[iIndex] = iClamp(g_iKamikazeHitMode2[iIndex], 0, 2);
				g_flKamikazeRange2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", g_flKamikazeRange[iIndex]);
				g_flKamikazeRange2[iIndex] = flClamp(g_flKamikazeRange2[iIndex], 1.0, 9999999999.0);
				g_flKamikazeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range Chance", g_flKamikazeRangeChance[iIndex]);
				g_flKamikazeRangeChance2[iIndex] = flClamp(g_flKamikazeRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					RemoveEntity(iCorpse);
				}
			}
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flKamikazeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeRange[ST_TankType(tank)] : g_flKamikazeRange2[ST_TankType(tank)],
			flKamikazeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeRangeChance[ST_TankType(tank)] : g_flKamikazeRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flKamikazeRange)
				{
					vKamikazeHit(iSurvivor, tank, flKamikazeRangeChance, iKamikazeAbility(tank), 2, "3");
				}
			}
		}
	}
}

static void vKamikazeHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	int iKamikazeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeMessage[ST_TankType(tank)] : g_iKamikazeMessage2[ST_TankType(tank)];
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		EmitSoundToAll(SOUND_SMASH, survivor);
		vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(survivor);

		EmitSoundToAll(SOUND_GROWL, tank);
		vAttachParticle(tank, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(tank);

		char sKamikazeEffect[4];
		sKamikazeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sKamikazeEffect[ST_TankType(tank)] : g_sKamikazeEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sKamikazeEffect, mode);

		if (iKamikazeMessage == message || iKamikazeMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Kamikaze", sTankName, survivor);
		}
	}
}

static float flKamikazeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeChance[ST_TankType(tank)] : g_flKamikazeChance2[ST_TankType(tank)];
}

static int iKamikazeAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeAbility[ST_TankType(tank)] : g_iKamikazeAbility2[ST_TankType(tank)];
}

static int iKamikazeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeHit[ST_TankType(tank)] : g_iKamikazeHit2[ST_TankType(tank)];
}

static int iKamikazeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeHitMode[ST_TankType(tank)] : g_iKamikazeHitMode2[ST_TankType(tank)];
}