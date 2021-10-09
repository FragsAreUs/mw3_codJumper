#include maps\mp\gametypes\_hud_util;

init()
{
	thread hook_callbacks();
	level thread onPlayerConnect();
	level thread doInfo();
	wait 1.0;
	level thread doInfo2();
	setDvar("sv_cheats", 1);
	setDvar("sv_enableBounces", 1);
	setDvar("player_sustainammo", 1);
	setDvar("jump_slowdownEnable", 0);
}

onPlayerConnect()
{
  for(;;)
  {
    level waittill( "connected", player );
    player thread onPlayerSpawned();
	player thread DoDvars();
	player VisionSetNakedForPlayer(getDvar("mapname"), 0);
  }

}

onPlayerSpawned()
{
  self endon("disconnect");
  for(;;)
  {
    self waittill("spawned_player");
	self takeAllWeapons();
	self giveWeapon("iw5_deserteagle_mp");
	self giveWeapon("rpg_mp");
	self setSpawnWeapon("iw5_deserteagle_mp");
	self freezeControls(false);
    //self iprintlnbold("^2Hello gsc");
    self thread save();
    self thread doUfo();
	self thread SpawnCrate();
	self thread PickupCrate();
	self thread watchSaveWaypointsCommand();
	self thread dosuicide();
  }

}

hook_callbacks()
{
	level waittill( "prematch_over" ); // iw4madmin waits this long for some reason...
	wait 0.05; // so we need to be one frame after it sets up its callbacks.
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;
}

onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	// if(self is_player())
	// {
	// 	self maps\mp\bots\_bot_internal::onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	// 	self maps\mp\bots\_bot_script::onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	// }
	
	//self [[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}


DoDvars()
{
	setDvar("bg_fallDamageMaxHeight", 9999 );    // No Falldamage | Because you die even with "GodMod"
	setDvar("bg_fallDamageMinHeight", 9998 );    // No Falldamage | Because you die even with "GodMod"
	self setClientDvar( "player_meleeHeight", "0");
	self setClientDvar( "player_meleeRange", "0" );
	self setClientDvar( "player_meleeWidth", "0" );
	setDvar("scr_spectatefree", 1);
	setDvar("scr_dm_timelimit", 0);
	setDvar("scr_war_timelimit", 0);
	setDvar("scr_dm_scorelimit", 0);
	setDvar("scr_war_scorelimit", 0);
	setDvar("scr_friendlyfire", 3);
	self thread maps\mp\gametypes\_hud_message::hintMessage("Welcome ^2"+self.name+"^7!");
	self thread maps\mp\gametypes\_hud_message::hintMessage("^2C^7oDJumper ^2M^7od");
	self thread maps\mp\gametypes\_hud_message::hintMessage("By ^2R4d^70^2xZz / (^2Drofder^7 (^2S^7ave/^2L^7oad Position))");

}

save()
{
	self endon("death");
	self endon("killed_player");
	self endon("joined_spectators");
	self endon("disconnect");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			x = false;
			for(i = 0;i < 0.5;i += 0.05)
			{
				if(!self isMantling() && !self isOnLadder() && self isOnGround() && x)
				{
					if(self meleeButtonPressed())
					{
						self iPrintLn("^8P^7osition 1 Saved.");
						self.save1pos = self.origin;
						self.save1ang = self.angles;

						wait 0.75;

						break;
					}

					else if(self attackButtonPressed())
					{
						self iPrintLn("^8P^7osition 2 Saved.");
						self.save2pos = self.origin;
						self.save2ang = self.angles;

						wait 0.75;

						break;
					}
				}

				else if(!self meleeButtonPressed() && !x)
					x = true;

				wait 0.05;
			}
		}

		else if(self useButtonPressed())
		{
			x = false;
			for(i = 0;i < 0.5;i += 0.05)
			{
				if(!self isMantling() && x)
				{
					if(self useButtonPressed())
					{
						if(isDefined(self.save1pos))
						{
							self iPrintLn("^8P^7osition 1 Loaded.");
							self setOrigin(self.save1pos);
							self setPlayerAngles(self.save1ang);

							self freezeControls(true);
							wait 0.1;
							self freezeControls(false);
						}

						else self iPrintLn("^8P^7osition 1 Undefined.");

						wait 0.75;

						break;
					}

					else if(self attackButtonPressed())
					{
						if(isDefined(self.save2pos))
						{
							self iPrintLn("^8P^7osition 2 Loaded.");
							self setOrigin(self.save2pos);
							self setPlayerAngles(self.save2ang);

							self freezeControls(true);
							wait 0.1;
							self freezeControls(false);
						}

						else self iPrintLn("^8P^7osition 2 Undefined.");

						wait 0.75;

						break;
					}
				}

				else if(!self useButtonPressed() && !x)
					x = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

doInfo()
{
        self endon("disconnect");
        displayText = self createServerFontString( "objective", 1.5 );
        i = 0;
        for( ;; )
        {
                if(i == -1300) 
		{
                        i = 1300;
                }

                displayText setPoint( "BOTTOM", undefined, i, 0);
                displayText setText("^2Infos: ^1P^7ress ^22x ^7-^2[{+melee}]^7- to Save your Position and ^22x ^7-^2[{+activate}]^7- to Load your Position. ^1P^7ress -^2[{+smoke}]^7- & -^2[{+actionslot 4}]^7- to Spawn a Crate.  ^1P^7ress -^2[{+actionslot 5}]^7- to Move and drop a Crate.");
                wait .03;
                i--;
        }
}

doInfo2()
{
        self endon("disconnect");
        displayText = self createServerFontString( "objective", 1.5 );
        i = 0;
        for( ;; )
        {
                if(i == -1020) 
		{
                        i = 1020;
                }

                displayText setPoint( "TOP", undefined, i, 0);
                displayText setText("^2CoDJumper Mod ^7Version 1.31!   ^2Infos: ^1P^7ress -^2[{+actionslot 3}]^7- to activate UFO. ^1P^7ress -^2[{+actionslot 6}]^7- For Suicide.");
                wait .03;
                i--;
        }
}


doUfo()
{
        self endon ( "disconnect" );
        self endon ( "death" );
        self notifyOnPlayerCommand("as3", "+actionslot 3");
        maps\mp\gametypes\_spectating::setSpectatePermissions();
        for(;;)
        {
                self waittill("as3");          
                self allowSpectateTeam( "freelook", true );
                self.sessionstate = "spectator";
                self waittill("as3");
                self.sessionstate = "playing";
                self allowSpectateTeam( "freelook", false );
        }
}

SpawnCrate()
{
	self endon("death");
	self notifyOnPlayerCommand("smoke", "+smoke");
        self notifyOnPlayerCommand( "4", "+actionslot 4" );
	for(;;)
	{
		self waittill( "smoke" );
                self waittill( "4" );
		{
			vec = anglestoforward(self getPlayerAngles());
			end = (vec[0] * 200, vec[1] * 200, vec[2] * 200);
			Location = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+end, 0, self )[ "position" ];
			crate = spawn("script_model", Location+(0,0,20));
			crate CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
			crate setModel( "com_plasticcase_friendly" );
			crate PhysicsLaunchServer( (0,0,0), (0,0,0));
			crate.angles = self.angles+(0,90,0);
		}
	}
}

PickupCrate()
{
	self endon("death");
	self notifyOnPlayerCommand( "5", "+actionslot 5" );
	for(;;)
	{
		self waittill( "5" );
		vec = anglestoforward(self getPlayerAngles());
		end = (vec[0] * 100, vec[1] * 100, vec[2] * 100);
		entity = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+(vec[0] * 100, vec[1] * 100, vec[2] * 100), 0, self )[ "entity" ];

		if( isdefined(entity.model) )
		{
			self thread moveCrate( entity );
			self waittill( "5" );
			{
				self.moveSpeedScaler = 1;
				self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
			}		
		}
	}
}

moveCrate( entity )
{
	self endon("5");
	for(;;)
	{
		entity.angles = self.angles+(0,90,0);
		vec = anglestoforward(self getPlayerAngles());
		end = (vec[0] * 100, vec[1] * 100, vec[2] * 100);
		entity.origin = (self gettagorigin("tag_eye")+end);
		self.moveSpeedScaler = 0.5;
		self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
		wait 0.05;
	}

}


watchSaveWaypointsCommand()
{
	self endon("death");
	self endon("disconnect");
	
	self notifyOnPlayerCommand("[{+actionslot 1}]", "+actionslot 1");
	for(;;)
	{
		self waittill("[{+actionslot 1}]");
		print(self.origin);
	}
}

dosuicide()     //--- button to suicide
{
        self endon("disconnect");
        self endon("death");

		 self notifyOnPlayerCommand("as6", "+actionslot 6");
        for(;;) 
        {
			self waittill("as6"); 
            self suicide();

        }
}