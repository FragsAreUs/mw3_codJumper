#include maps\mp\gametypes\_hud_util;

init()
{
	thread hook_callbacks();
	level thread onPlayerConnect();
	level thread doInfo();
	wait 1.0;
	level thread doInfo2();
	setDvar("sv_cheats", 0);
	setDvar("sv_enableBounces", 1);
	setDvar("player_sustainammo", 1);
	setDvar("jump_slowdownEnable", 0);
	setDvar( "g_playerCollision", 2);
	setDvar( "g_playerEjection", 2);
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
    self waittill("spawned_player", player);
	self takeAllWeapons();
	self giveWeapon("iw5_deserteagle_mp");
	self giveWeapon("rpg_mp");
	self setSpawnWeapon("iw5_deserteagle_mp");
	self freezeControls(false);
    self thread save();
    self thread doUfo();
	self thread dosuicide();
	self thread initVelo();
	self thread onMapEnd();
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
	self thread maps\mp\gametypes\_hud_message::hintMessage("^4TO ^2I^7nhouse ^2C^7od  ^2J^7umper");

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
						self.save1ang = self getPlayerAngles();

						wait 0.75;

						break;
					}

					else if(self attackButtonPressed())
					{
						self iPrintLn("^8P^7osition 2 Saved.");
						self.save2pos = self.origin;
						self.save2ang = self getPlayerAngles();

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
        displayText setPoint( "BOTTOM");
         displayText setText("^2Infos: ^1P^7ress ^22x ^7-^2[{+melee}]^7- to Save your Position and ^22x ^7-^2[{+activate}]^7- to Load your Position.");
}

doInfo2()
{
    self endon("disconnect");
    displayText = self createServerFontString( "objective", 1.5 );
    displayText setPoint( "TOP");
    displayText setText("Welcome to ^1inhouse ^6Cod ^3Jumper  ^2Infos:^1P^7ress -^2[{+actionslot 6}]^7- For Suicide ");  
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

onMapEnd()
{
	self endon( "disconnect" );
	level waittill("game_ended");
	
	if (isDefined(self.hud_velo))
		self.hud_velo destroy();
	
	if (isDefined(self.hud_maxvelo))
		self.hud_maxvelo destroy();
}

initVelo()
{
    self endon( "disconnect" );
	level endon( "game_ended" );
	
	self.maxspeed = 0;
	
	if (isDefined(self.hud_velo))
		self.hud_velo destroy();

	self.hud_velo = addTextHud( self, 0, -15, 1, "center", "bottom", 1.5 );
	self.hud_velo.horzAlign = "center";
    self.hud_velo.vertAlign = "bottom";
	self.hud_velo.hidewheninmenu = true;
	
	if (isDefined(self.hud_maxvelo))
		self.hud_maxvelo destroy();

	self.hud_maxvelo = addTextHud( self, 0, -30, 1, "center", "bottom", 1.5 );
	self.hud_maxvelo.horzAlign = "center";
    self.hud_maxvelo.vertAlign = "bottom";
	self.hud_maxvelo.hidewheninmenu = true;
	self.hud_maxvelo.label = &"^3(&&1)";
	
	self.hud_maxvelo setValue( 0 );
	self.hud_velo setValue( 0 );
	
	wait 0.5;
	
	while(1)
	{
		wait 0.01;
		
		velocity = self getPlayerSpeed();
		
		if (velocity > self.maxspeed)
			self.maxspeed = velocity;
		
		self.hud_velo setValue(velocity);
		self.hud_maxvelo setValue(self.maxspeed);
	}
}

getPlayerSpeed() {
    velocity = self getVelocity();
    return int( sqrt( ( velocity[0] * velocity[0] ) + ( velocity[1] * velocity[1] ) ) );
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}

