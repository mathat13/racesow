const int DIFFREF_AUTO = 0;
const int DIFFREF_PERSONAL = 1;
const int DIFFREF_SERVER = 2;
const int DIFFREF_PLAYER = 3;
const int DIFFREF_WORLD = 4;

/**
 * Racesow_Player
 *
 * @package Racesow
 * @version 1.0.3
 */
class Racesow_Player
{
	/**
	 * Did the player respawn on his own after finishing a race?
     * Info for the respawn thinker not to respawn the player again.
	 * @var bool
	 */
	bool isSpawned;

	/**
	 * Is the player in noclip mode?
	 * @var bool
	 */
    bool inNoclip;

	/**
	 * Is the player practising? has the player completed the map in practicemode?
	 * @var bool
	 */
	bool practicing;
	bool completedInPracticemode;

	/**
	 * What state is the player in: racing, practicing, prerace?
	 * @var String
	 */
	String state;

	/**
	 * Is the player still racing in the overtime?
	 * @var bool
	 */
	bool inOvertime;

	/**
	 * Is the player allowed to join?
	 * @var bool
	 */
	bool isJoinlocked;

	/**
	 * Is the player allowed to call a vote?
	 * @var bool
	 */
	bool isVotemuted;

	/**
	 * Is the player using the chrono function?
	 * @var bool
	 */
	bool isUsingChrono;

	/**
	 * Was the player Telekilled?
	 * @var bool
	 */
	bool wasTelekilled;

    /**
     * Is the player using the quad command?
     * @var bool
     */
    bool onQuad;

	/**
	 * cEntity which stores the latest position after the telekill
	 * @var cEntity
	 */
	cEntity@ gravestone;

	/**
	 * The time when the player started the chrono
	 * @var uint
	 */
	uint chronoStartTime;

	/**
	 * The time when the player started idling
	 * @var uint
	 */
	uint idleTime;

	/**
	 * Time when the player joined (used to compute playtime)
	 * @var uint
	 */
	uint joinedTime;

	/**
	 * Should we print welcome message to the player ?
	 */
	bool printWelcomeMessage;

    /**
	 * The player's best race
	 * @var uint
	 */
    uint bestRaceTime;

    /**
     * Overall number of started races on the current map
     */
    uint overallTries;

    /**
     * Number of started races on the current map for current session
     */
    uint tries;

    /**
     * Number of started races since last race
     */
    uint triesSinceLastRace;

    /**
     * Racing time before a race is actually finished
     */
    uint racingTimeSinceLastRace;

    /**
     * Racing time
     */
    uint racingTime;

    /**
     * Distance
     */
    uint64 distance;

    /**
     * Old Position
     */
    Vec3 oldPosition;

	/**
	 * Local time of the last top command (flood protection)
	 * @var uint
	 */
    uint topLastcmd;

    /**
     * Current session speed record
     */
    int highestSpeed;

	/**
	 * Is the player waiting for the result of a command (like "top")?
	 * (this is another kind of flood protection)
	 * @var bool
	 */
	bool isWaitingForCommand;


	/**
	 * The player's best checkpoints
	 * stored across races
	 * @var uint[]
	 */
    uint[] bestCheckPoints;

	/**
	 * The player's client
	 * @var uint
	 */
	cClient @client;

	/**
	 * Player authentication and authorization
	 * @var Racesow_Player_Auth
	 */
	Racesow_Player_Auth @auth;

	/**
	 * The current race of the player
	 * @var Racesow_Player_Race
	 */
	Racesow_Player_Race @race;
	Racesow_Player_Race @lastRace;

	/**
	 * Controls the demo recording on the client
	 * @var Racesow_Player_ClientDemo
	 */
	Racesow_Player_ClientDemo @demo;

	/**
	 * The weapon which was used before the noclip command, in order to restore it
	 * @var int
	 */
	int noclipWeapon;

	/**
	 * When is he allowed to trigger again?(= leveltime + timeout)
	 * @var uint
	 */
	uint triggerTimeout;

	/**
	 * Storage for the triggerd entity
	 * @var @cEntity
	 */
	cEntity @triggerEntity;

	/**
     * Stores all spectators of the player in a list ((int)id (int)ping)
     * @var String
     */
	String challengerList;

    /**
     * Time diff reference mode
     */
    int diffRef;

    /**
     * Time diff reference player
     */
    Racesow_Player @diffPlayer;

	/**
	 * Variables for the position function
	 */
	uint positionLastcmd; //flood protection
	bool positionSaved; //is a position saved?
	Vec3 positionOrigin; //stored origin
	Vec3 positionAngles; //stored angles
    bool[] positionWeapons; //stored weapon possessions
    int[] positionAmmos; //stored ammo counts
	int positionWeapon; //stored weapon
    float positionSpeed; //stored speed

	/**
	 * Constructor
	 *
	 */
    Racesow_Player()
    {
		@this.auth = Racesow_Player_Auth();
		@this.demo = Racesow_Player_ClientDemo();

        this.positionWeapons.resize( WEAP_TOTAL );
        this.positionAmmos.resize( WEAP_TOTAL );
    }

	/**
	 * Destructor
	 *
	 */
    ~Racesow_Player()
	{
	}

	/**
	 * Reset the player, just f*ckin remove this and use the constructor...
	 * @return void
	 */
	void reset()
	{
		this.practicing = false;
		this.completedInPracticemode = false;
		this.idleTime = 0;
		this.isSpawned = true;
		this.inNoclip = false;
		this.isJoinlocked = false;
        this.inOvertime = false;
		this.isVotemuted = false;
		this.wasTelekilled = false;
		this.onQuad = false;
		this.isWaitingForCommand = false;
		this.bestRaceTime = 0;
        this.resetAuth();
		this.auth.setPlayer(@this);
		this.demo.setPlayer(@this);
		this.bestCheckPoints.resize( numCheckpoints );
		for ( int i = 0; i < numCheckpoints; i++ )
		{
			this.bestCheckPoints[i] = 0;
		}
		if(@this.gravestone != null)
			this.gravestone.freeEntity();
		this.positionSaved = false;
        this.positionSpeed = 0;
		@this.triggerEntity = null;
		this.triggerTimeout = 0;
		this.tries = 0;
		this.overallTries = 0;
		this.racingTime = 0;
		this.racingTimeSinceLastRace = 0;
		this.challengerList = "";
		this.printWelcomeMessage = false;
		this.highestSpeed = 0;
		this.state = "";
        this.diffRef = DIFFREF_AUTO;
	}

	/**
	 * Reset the players auth
	 * @return void
	 */
	void resetAuth()
	{
		if (@this.auth != null)
		{
			this.auth.reset();
		}
	}

    /**
     * The player appears in the game
     * @return void
     */
    void appear()
    {
        this.joinedTime = levelTime;
        racesowAdapter.playerAppear(@this);
    }

    void removeReferences()
    {
        for ( int i = 0; i < maxClients; i++ )
        {
            Racesow_Player @other = Racesow_GetPlayerByNumber( i );
            if( @other != null && other.diffRef == DIFFREF_PLAYER && @other.diffPlayer == @this )
                other.invalidateDiffPlayer();
        }
    }

	void disappear(String nickName, bool threaded)
    {
        racesowAdapter.playerDisappear(@this, nickName, threaded);
    }

    /**
     * Callback for a finished race
     * @return void
     */
    void raceCallback(uint allPoints, uint oldPoints, uint newPoints, uint oldTime, uint oldBestTime, uint newTime)
    {

        //G_PrintMsg( null, this.getName() + ": aP: "+ allPoints + ", oP: "+ oldPoints + ", nP: " + newPoints + ", oT: "+ oldTime + ", oBT: "+ oldBestTime + ", nT: " + newTime + "\n");
		uint bestTime;
        int earnedPoints;
		uint oldServerBestTime;
        bestTime = oldTime; // diff to own best
        oldServerBestTime = this.lastRace.prejumped ? map.getPrejumpHighScore().getTime() : map.getHighScore().getTime();

        //print general info to player
        this.sendAward( S_COLOR_CYAN + "Race Finished!" );

        if ( this.lastRace.checkPointsString.len() > 0 )
            this.sendMessage( this.lastRace.checkPointsString );

        if ( @this.getClient() != null)
		{
            this.distributeDiffed( -1, newTime, bestTime, oldServerBestTime, bestTime );

            this.sendMessage(S_COLOR_WHITE + "Race " + S_COLOR_ORANGE + "#"
                    + this.tries + S_COLOR_WHITE + " finished: "
                    + TimeToString( newTime)
                    + S_COLOR_ORANGE + " Speed: " + S_COLOR_WHITE + this.lastRace.stopSpeed // finish speed
                    + S_COLOR_ORANGE + " Personal: " + S_COLOR_WHITE + diffString(oldTime, newTime) // personal best
                    + S_COLOR_ORANGE + " Server: " + S_COLOR_WHITE + diffString(oldServerBestTime, newTime) // server best
                    + S_COLOR_ORANGE + " " + Capitalize(rs_networkName.string) + ": " + S_COLOR_WHITE + diffString(oldBestTime, newTime) // database best
                    + "\n");
		}

        earnedPoints = newPoints - oldPoints;
        if (earnedPoints > 0)
        {
            String pointsAward =  S_COLOR_BLUE + "You earned "+ earnedPoints
                                   + ((earnedPoints > 1)? " points!" : " point!")
                                   + "\n";
            this.sendAward( pointsAward );
            this.sendMessage( pointsAward );
        }

        //personal record
        if ( oldTime == 0 || newTime < oldTime )
        {
            this.setBestTime(newTime);
            this.setBestCheckPointsFromRace(this.lastRace);
            this.sendAward( "Personal record!" );
        }

        String prejumpRec = "";
        if ( this.lastRace.prejumped )
            prejumpRec = S_COLOR_RED + " prejump" + S_COLOR_YELLOW;

        //server record
        if ( oldServerBestTime == 0 || newTime < oldServerBestTime )
        {
            if ( this.lastRace.prejumped )
                map.getPrejumpHighScore().fromRace(this.lastRace);
            else
                map.getHighScore().fromRace(this.lastRace);
            this.sendAward( S_COLOR_GREEN + "New server record!" );
            G_PrintMsg(null, this.getName() + " "
                             + S_COLOR_YELLOW + "made a new" + prejumpRec + " server record: "
                             + TimeToString( newTime ) + "\n");

            RS_ircSendMessage( this.getName().removeColorTokens()
                               + " made a new server record: "
                               + TimeToString( newTime ) );
        }

        //world record
        if ( oldBestTime == 0 || newTime < oldBestTime )
        {
            this.sendAward( S_COLOR_GREEN + "New " + rs_networkName.string + " record!" );
            G_PrintMsg(null, this.getName() + " "
                             + S_COLOR_YELLOW + "made a new" + prejumpRec + " "
                             + S_COLOR_GREEN  + rs_networkName.string
                             + S_COLOR_YELLOW + " record: " + TimeToString( newTime ) + "\n");

            if ( !this.lastRace.prejumped )
                map.getWorldHighScore().fromRace(this.lastRace);

            if ( mysqlConnected == 1)
            {
                this.sendMessage(S_COLOR_YELLOW
                                 + "Congratulations! You can now set a "
                                 + S_COLOR_WHITE + "oneliner"
                                 + S_COLOR_YELLOW +
                                 ". Careful though, only one try.\n");
            }
        }
    }

    /**
     * Callback for account administration results
     * @return void
     */
    void accountCallback(uint code)
    {
        switch (code) {
            case 0:
                this.sendErrorMessage("You are already registered");
                break;
            case 1:
                this.sendErrorMessage("This account or email is already registered");
                break;
            case 2:
                this.sendMessage("Registration completed!\n");
                this.disappear(this.getName(), true);
                this.appear();
                break;
        }
    }

    void setLastRace(Racesow_Player_Race @race)
    {
        @this.lastRace = @race;
    }

    /**
	 * Get the player's id
	 * @return int
	 */
    int getId()
    {
        return this.auth.playerId;
    }

    /**
	 * Get the id of the current nickname
	 * @return int
	 */
    int getNickId()
    {
        return this.auth.nickId;
    }

	/**
	 * SGet the player's id
	 * @return int
	 */
    void setId(int playerId)
    {
        this.sendMessage( S_COLOR_BLUE + "Your PlayerID: "+ playerId +"\n" );
        this.auth.setPlayerId(playerId);
    }

    /**
	 * Set the id of the current nickname
	 * @return int
	 */
    void setNickId(int nickId)
    {
        this.auth.nickId=nickId;
    }

	/**
	 * Set the player's client
	 * @return void
	 */
	Racesow_Player @setClient( cClient @client )
	{
		@this.client = @client;
		return @this;
	}

	/**
	 * Get the player's client
	 * @return cClient
	 */
	cClient @getClient()
	{
		return @this.client;
	}

	/**
	 * Get the players best time
	 * @return uint
	 */
	uint getBestTime()
	{
		return this.bestRaceTime;
	}

	/**
	 * Set the players best time
	 * @return void
	 */
	void setBestTime(uint time)
	{
		this.bestRaceTime = time;
	}

	/**
	 * getName
	 * @return String
	 */
	String getName()
	{
		if (@this.client != null)
        {
            return this.client.name;
        }

        return "";
	}

	/**
	 * getAuth
	 * @return String
	 */
	Racesow_Player_Auth @getAuth()
	{
		return @this.auth;
	}

    /**
     * setDiffRef
     * @param int
     * @return void
     */
    void setDiffRef(int diffRef)
    {
        this.diffRef = diffRef;
    }

    /**
     * setDiffPlayer
     * @param Racesow_Player
     * @return void
     */
    void setDiffPlayer(Racesow_Player @diffPlayer)
    {
        @this.diffPlayer = diffPlayer;
    }

    void invalidateDiffPlayer()
    {
        this.diffRef = DIFFREF_AUTO;
        this.sendErrorMessage( "Your diffRef has been reset to AUTO as the referencing player left" );
    }

	/**
	 * getBestCheckPoint
	 * @param uint id
	 * @return uint
	 */
	uint getBestCheckPoint(uint id)
	{
		if ( id >= this.bestCheckPoints.length() )
			return 0;

		return this.bestCheckPoints[id];
	}

	/**
	 * Set player best checkpoints from a given race
	 *
	 * @param race The race from which to take the checkpoints
	 * @return true
	 */
	bool setBestCheckPointsFromRace(Racesow_Player_Race @race)
	{
	    for ( int i = 0; i < numCheckpoints; i++)
	    {
	        this.bestCheckPoints[i] = race.getCheckPoint(i);
	    }
	    return true;
	}

	/**
	 * Player spawn event
	 * @return void
	 */
	void onSpawn()
	{
	    this.isSpawned = true;

	    if ( this.demo.isStopping() )
	    	this.demo.stopNow();
	    else if ( this.demo.isRecording() )
	    	this.demo.cancel();

	    this.demo.start();
	}

	/**
	 * Check if the player is currently racing
	 * @return uint
	 */
	bool isRacing()
	{
		if (@this.race == null)
			return false;

		return this.race.inRace();
	}

	/**
	 * Get the player current speed
	 */
	int getSpeed()
	{
	    Vec3 globalSpeed = this.getClient().getEnt().velocity;
	    Vec3 horizontalSpeed = Vec3(globalSpeed.x, globalSpeed.y, 0);
	    return horizontalSpeed.length();
	}

	/**
	 * Get the state of the player;
	 * @return String
	 */
	String getState()
	{
		if ( this.practicing )
			this.state = "^5practicing";
		else if ( this.isRacing() )
			this.state = "^2racing";
		else
			this.state = "^3prerace";

		return state;
	}
	/**
	 * crossStartLine
	 * @return void
	 */
    void touchStartTimer()
    {
        if( !this.isSpawned )
            return;

		if ( this.isRacing() )
            return;

		if ( gametypeFlag == MODFLAG_FREESTYLE )
			return;

		if ( this.practicing )
			return;

		@this.race = Racesow_Player_Race();
		this.race.setPlayer(@this);
		this.race.start();
        this.tries++;
        this.triesSinceLastRace++;
        int tries = this.overallTries+this.tries;

		this.race.prejumped=RS_QueryPjState(this.getClient().playerNum);
		if (this.race.prejumped)
		{
		    this.sendAward(S_COLOR_RED + "Prejumped!");
		}
    }

	/**
	 * touchCheckPoint
	 * @param int id
	 * @return void
	 */
    void touchCheckPoint( int id )
    {
		if ( id < 0 || id >= numCheckpoints )
            return;

        if ( !this.isRacing() )
            return;

		this.race.check( id );
    }

	/**
	 * touchStopTimer
	 * @return void
	 */
    void touchStopTimer()
    {
		if ( this.practicing && !this.completedInPracticemode )
		{
			this.sendAward( S_COLOR_CYAN + "You completed the map in practicemode, no time was set" );

			this.isSpawned = false;
			this.completedInPracticemode = true;
		}

		// when the race can not be finished something is very wrong, maybe small penis playing, or practicemode is enabled.
		if ( @this.race == null || !this.race.stop() )
            return;

		this.demo.stop( this.race.getTime() );

        this.setLastRace(@this.race);

        uint record = this.race.prejumped ? map.getPrejumpHighScore().getTime(): map.getHighScore().getTime();
		switch (gametypeFlag) {
            case MODFLAG_DRACE:
                // we kill the player who lost
                if (@DRACERound.roundChallenger != null) {
                    if (@this.client == @DRACERound.roundWinner)
                        DRACERound.roundChallenger.getEnt().health = -1;
                }

                if (@DRACERound.roundWinner != null) {
                    if (@this.client == @DRACERound.roundChallenger)
                        DRACERound.roundWinner.getEnt().health = -1;
                }

                this.raceCallback(0,0,0,this.bestRaceTime,record,this.race.getTime());

                break;

            case MODFLAG_TRACE:
            case MODFLAG_DURACE:
                this.client.stats.addScore( 1 );
                //G_GetTeam( this.client.getEnt().team ).stats.setScore( this.client.stats.score );
                G_GetTeam( this.client.getEnt().team ).stats.addScore( 1 );
                this.raceCallback(0,0,0,this.bestRaceTime,record,this.race.getTime());

                break;

            case MODFLAG_RACE:
            case MODFLAG_COOPRACE:
                if ( this.bestRaceTime == 0 || this.race.getTime() < this.bestRaceTime )
                {
                    this.getClient().stats.setScore(this.race.getTime());
                }
                racesowAdapter.raceFinish(@this.race);
                break;

            default:
                break;
        }

		this.isSpawned = false;
		this.racingTime += this.race.getTime();
		this.racingTimeSinceLastRace += this.race.getTime();
		this.triesSinceLastRace = 0;
		this.racingTimeSinceLastRace = 0;
		@this.race = null;

    // set up for respawning the player with a delay
    cEntity @respawner = G_SpawnEntity( "race_respawner" );
    @respawner.think = race_respawner_think; //FIXME: Workaround because the race_respawner function isn't called
    respawner.nextThink = levelTime + 3000;
    respawner.count = client.playerNum;
    }

	/**
	 * restartRace
	 * @return void
	 * for raceRestart and practicing mode.
	 */
	void restartRace()
	{
		if ( @this.client != null )
    {
      if ( gametypeFlag == MODFLAG_DURACE )
      {
        this.cancelRace();
        this.client.respawn( false );
      }
      else
      {
        this.client.team = TEAM_PLAYERS;
        this.client.respawn( false );
      }
    }
	}

	/**
	 * restartingRace
	 * @return void
	 */
    void restartingRace()
    {
  		this.isSpawned = true;
        this.completedInPracticemode = false;

        if( this.client.getEnt().team == TEAM_SPECTATOR )
            this.inNoclip = false;

  		if ( this.practicing && this.positionSaved )
  		{
  			this.teleport( this.positionOrigin, this.positionAngles, false, false, false );
            for( int i = WEAP_NONE + 1; i < WEAP_TOTAL; i++ )
            {
                if( this.positionWeapons[i] )
                    client.inventoryGiveItem( i );
                cItem @item = G_GetItem( i );
                client.inventorySetCount( item.ammoTag, this.positionAmmos[i] );
            }
  			this.client.selectWeapon( this.positionWeapon );
            cEntity@ ent = @this.client.getEnt();
            if( @ent != null )
            {
                Vec3 a, b, c;
                this.positionAngles.angleVectors(a, b, c);
                a.z = 0;
                a.normalize();
                a *= this.positionSpeed;
                if( ent.moveType != MOVETYPE_NOCLIP && !this.inNoclip )
                    ent.set_velocity(a);
            }
  		}
        else if ( this.isRacing() )
  		{
  			this.racingTime += this.race.getCurrentTime();
  			this.racingTimeSinceLastRace += this.race.getCurrentTime();
  			this.sendMessage( this.race.checkPointsString );
  		}

        if( this.practicing && this.inNoclip && this.client.getEnt().moveType != MOVETYPE_NOCLIP )
            this.noclip();

  		@this.race = null;
  		//remove all projectiles.
  		if( @this.client.getEnt() != null )
  			removeProjectiles( this.client.getEnt() );
  		if ( !this.practicing )
  			RS_ResetPjState(this.getClient().playerNum);
    }

	/**
	 * cancelRace
	 * @return void
	 */
    void cancelRace()
    {
		@this.race = null;
    }

	/**
	 * Player has just started idling (triggered in overtime)
	 * @return void
	 */
	void startIdling()
	{
		this.idleTime = levelTime;
	}

	/**
	 * stopIdling
	 * @return void
	 */
	void stopIdling()
	{
		this.idleTime = 0;
	}

	/**
	 * getIdleTime
	 * @return uint
	 */
	uint getIdleTime()
	{
		if ( !this.startedIdling() )
			return 0;

		return levelTime - this.idleTime;
	}

	/**
	 * startedIdling
	 * @return bool
	 */
	bool startedIdling()
	{
		return this.idleTime != 0;
	}

    /**
	 * startOvertime
	 * @return void
	 */
	void startOvertime()
	{
		this.inOvertime = true;
		this.sendMessage( S_COLOR_RED + "Please hurry up, the other players are waiting for you to finish...\n" );
	}

	/**
	 * resetOvertime
	 * @return void
	 */
	void cancelOvertime()
	{
		this.inOvertime = false;
	}

	/**
	 * advanceDistance, this must be called once per frame
	 * @return void
	 */
	void advanceDistance()
	{
        Vec3 position = this.getClient().getEnt().origin;
        position.z = 0;
        this.distance += ( position.distance( this.oldPosition ) * 1000 );
        this.oldPosition = position;
	}

	/**
	 * set Trigger Timout for map entitys
	 * @return void
	 */
	void setTriggerTimeout(uint timeout)
	{
		this.triggerTimeout = timeout;
	}

	/**
	 * get the Trigger Timout
	 * @return uint
    */
	uint getTriggerTimeout()
	{
		return this.triggerTimeout;
	}

	/**
	 * set the Triggered map Entity
	 * @return void
	 */
	void setTriggerEntity( cEntity @ent )
	{
		@this.triggerEntity = @ent;
	}

	/**
	 * setupTelekilled
	 * @return void
	 */
	void setupTelekilled( cEntity @gravestone)
	{
		@this.gravestone = @gravestone;
		this.wasTelekilled = true;
	}

	/**
	 * resetTelekilled
	 * @return void
	 */
	void resetTelekilled()
	{
		this.gravestone.freeEntity();
		this.wasTelekilled = false;
	}

	/**
	 * noclip Command
	 * @return bool
	 */
	bool noclip()
	{
	    cEntity@ ent = this.client.getEnt();
		if( ent.moveType == MOVETYPE_NOCLIP )
		{
		    Vec3 mins, maxs;
		    client.getEnt().getSize( mins, maxs );
		    cTrace tr;
            uint contentMask;
            if( ent.client.pmoveFeatures & PMFEAT_GHOSTMOVE == 0 ) // assuming all players either have ghostmove or not
                contentMask = MASK_PLAYERSOLID;
            else
                contentMask = MASK_DEADSOLID;
            if( tr.doTrace( this.client.getEnt().origin, mins, maxs,
                    this.client.getEnt().origin, 0, contentMask ))
            {
                //don't allow players to end noclip inside others or the world
                this.sendMessage( S_COLOR_WHITE + "WARNING: can't switch noclip back when being in something solid.\n" );
                return false;
            }
			ent.moveType = MOVETYPE_PLAYER;
			ent.solid = SOLID_YES;
			this.client.selectWeapon( this.noclipWeapon );
            this.inNoclip = false;
		}
		else
		{
			ent.moveType = MOVETYPE_NOCLIP;
            ent.solid = SOLID_NOT;//don't get hit by projectiles/splash damage; don't block
			this.noclipWeapon = client.weapon;
            this.inNoclip = true;
		}

		return true;
	}

   /**
     * quad Command
     * @return bool
     */
    bool quad()
    {
        if( this.onQuad )
        {
            this.client.inventorySetCount( POWERUP_QUAD, 0 );
            this.onQuad = false;
        }
        else
        {
            this.onQuad = true;
        }

        return true;
    }

	/**
	 * teleport the player
	 * @return bool
	 */
	bool teleport( Vec3 origin, Vec3 angles, bool keepVelocity, bool kill, bool effects )
	{
		cEntity@ ent = @this.client.getEnt();
		if( @ent == null )
			return false;
		if( ent.team != TEAM_SPECTATOR )
		{
			Vec3 mins, maxs;
			ent.getSize(mins, maxs);
			cTrace tr;
			if(	gametypeFlag == MODFLAG_FREESTYLE && tr.doTrace( origin, mins, maxs, origin, 0, MASK_PLAYERSOLID ))
			{
				cEntity @other = @G_GetEntity(tr.entNum);
				if(@other == @ent)
				{
					//do nothing
				}
				else if(!kill) // we aren't allowed to kill :(
					return false;
				else // kill! >:D
				{
					if(@other != null && other.type == ET_PLAYER )
					{
						other.sustainDamage( @other, null, Vec3(0,0,0), 9999, 0, 0, MOD_TELEFRAG );
						//spawn a gravestone to store the postition
						cEntity @gravestone = @G_SpawnEntity( "gravestone" );
						// copy client position
						gravestone.origin = other.origin + Vec3( 0.0f, 0.0f, 50.0f );
						Racesow_GetPlayerByClient( other.client ).setupTelekilled( @gravestone );
					}

				}
			}
		}
		if( effects && ent.team != TEAM_SPECTATOR )
            ent.teleportEffect( true );
		if(!keepVelocity)
			ent.velocity = Vec3(0,0,0);
		ent.origin = origin;
		ent.angles = angles;
		if( effects && ent.team != TEAM_SPECTATOR )
			ent.teleportEffect( false );
		return true;
	}

	/**
	 * position Command
	 * @return bool
	 */
	bool position( String argsString )
	{
		String action = argsString.getToken( 0 );

		if( action == "save" )
		{
			this.positionSaved = true;
			cEntity@ ent = @this.client.getEnt();
			if( @ent == null )
				return false;
			this.positionOrigin = ent.origin;
			this.positionAngles = ent.angles;
            for( int i = WEAP_NONE + 1; i < WEAP_TOTAL; i++ )
            {
                this.positionWeapons[i] = client.canSelectWeapon( i );
                cItem @item = G_GetItem( i );
                this.positionAmmos[i] = client.inventoryCount( item.ammoTag );
            }
			if ( ent.moveType == MOVETYPE_NOCLIP )
				this.positionWeapon = this.noclipWeapon;
			else
                this.positionWeapon = client.weapon;
		}
        else if( action == "speed" && argsString.getToken( 1 ) != "" )
        {
            String speed = argsString.getToken( 1 );
            if( speed.locate( "+", 0 ) == 0 )
                this.positionSpeed = this.getSpeed() + speed.substr( 1 ).toFloat();
            else if( speed.locate( "-", 0 ) == 0 )
                this.positionSpeed = this.getSpeed() - speed.substr( 1 ).toFloat();
            else
                this.positionSpeed = speed.toFloat();
        }
		else if( action == "load" )
		{
			if(!this.positionSaved)
				return false;

            if( this.positionLastcmd + 500 > realTime )
                return false;
            this.positionLastcmd = realTime;

			if( this.teleport( this.positionOrigin, this.positionAngles, false, false, false ) )
            {
                for( int i = WEAP_NONE + 1; i < WEAP_TOTAL; i++ )
                {
                    if( this.positionWeapons[i] )
                        client.inventoryGiveItem( i );
                    cItem @item = G_GetItem( i );
                    client.inventorySetCount( item.ammoTag, this.positionAmmos[i] );
                }
				this.client.selectWeapon( this.positionWeapon );
                Vec3 a, b, c;
                this.positionAngles.angleVectors(a, b, c);
                a.z = 0;
                a.normalize();
                a *= this.positionSpeed;
                cEntity@ ent = @this.client.getEnt();
                if( @ent == null )
                    return false;
                if( ent.moveType != MOVETYPE_NOCLIP )
                    ent.set_velocity(a);
            }
			return true;
		}
        else if( action == "player" && argsString.getToken( 1 ) != "" )
        {
            if( this.positionLastcmd + 10000 > realTime )
            {
                this.sendErrorMessage( "Position player is spam protected, please wait 10 seconds." );
                return true;
            }
            this.positionLastcmd = realTime;

            int index = argsString.getToken( 1 ).toInt();
            Racesow_Player @other = Racesow_GetPlayerByNumber( index );
            if( @other != null && @other.getClient() != null )
                return this.teleport( other.getClient().getEnt().origin, other.getClient().getEnt().angles, false, false, false );
            return false;
        }
        else if( action == "cp" && argsString.getToken( 1 ) != "" )
        {
            int index = argsString.getToken( 1 ).toInt();
            for( int i = 0; i <= numEntities; i++ )
            {
                cEntity @ent = @G_GetEntity( i );
                if( @ent != null && ent.count == index - 1 && ent.get_classname() == "target_checkpoint" )
                    return this.teleport( ent.origin, this.client.getEnt().angles, false, false, false );
            }
            this.sendMessage( "Undefined checkpoint: " + index + "\n" );
            return true;
        }
		else if( action == "set" && argsString.getToken( 5 ) != "" )
		{
			Vec3 origin, angles;

			origin.x = argsString.getToken( 1 ).toFloat();
			origin.y = argsString.getToken( 2 ).toFloat();
			origin.z = argsString.getToken( 3 ).toFloat();
			angles.x = argsString.getToken( 4 ).toFloat();
			angles.y = argsString.getToken( 5 ).toFloat();

			return this.teleport( origin, angles, false, false, false );
		}
		else if( action == "store" && argsString.getToken( 2 ) != "" )
		{
			Vec3 position = client.getEnt().origin;
			Vec3 angles = client.getEnt().angles;
			//position set <x> <y> <z> <pitch> <yaw>
			this.client.execGameCommand("cmd seta storedposition_" + argsString.getToken(1)
					+ " \"" +  argsString.getToken(2) + " "
					+ position.x + " " + position.y + " " + position.z + " "
					+ angles.x + " " + angles.y + "\";writeconfig config.cfg");
		}
		else if( action == "restore" && argsString.getToken( 1 ) != "" )
		{
			G_CmdExecute( "cvarcheck " + this.client.playerNum
					+ " storedposition_" + argsString.getToken(1) );
		}
		else if( action == "storedlist" && argsString.getToken( 1 ) != "" )
		{
			if( argsString.getToken(1).toInt() > 50 )
			{
				this.sendMessage( S_COLOR_WHITE + "You can only list the 50 the most\n" );
				return false;
			}
			this.sendMessage( S_COLOR_WHITE + "###\n#List of stored positions\n###\n" );
			int i;
			for( i = 0; i < argsString.getToken(1).toInt(); i++ )
			{
				this.client.execGameCommand("cmd  echo ~~~;echo id#" + i
						+ ";storedposition_" + i +";echo ~~~;" );
			}
		}
		else
		{
			cEntity@ ent = @this.client.getEnt();
			if( @ent == null )
				return false;
			String msg;
			msg = "Usage:\nposition save - Save current position\n";
            msg += "position speed <speed> - Set saved position speed\n";
			msg += "position load - Teleport to saved position\n";
			msg += "position player <id> - Teleport to a player\n";
			msg += "position cp <id> - Teleport to a checkpoint (id order may vary)\n";
			msg += "position set <x> <y> <z> <pitch> <yaw> - Teleport to specified position\n";
			msg += "position store <id> <name> - Store a position for another session\n";
			msg += "position restore <id> - Restore a stored position from another session\n";
			msg += "position storedlist <limit> - Sends you a list of your stored positions\n";
			msg += "Current position: " + " " + ent.origin.x + " " + ent.origin.y + " " +
		ent.origin.z + " " + ent.angles.x + " " + ent.angles.y + "\n";
			this.sendMessage( msg );
		}

		return true;
	}

	/**
	 * Send a message to console of the player
	 * @param String message
	 * @return void
	 */
	void sendMessage( String message )
	{
		if (@this.client == null)
            return;

        // just send to original func
		G_PrintMsg( this.client.getEnt(), message );

		// maybe log messages for some reason to figure out ;)
	}

	/**
	 * Send a message to the center of the screen of the player
	 * @param String message
	 * @return void
	 */
    void sendCenteredMessage( String message )
    {
        if (@this.client == null)
            return;
        G_CenterPrintMsg( this.client.getEnt(), message );
        //print the finish times to specs too
        cTeam @spectators = @G_GetTeam( TEAM_SPECTATOR );
        cEntity @other;
        for ( int i = 0; @spectators.ent( i ) != null; i++ )
        {
            @other = @spectators.ent( i );
            if ( @other.client != null && other.client.chaseActive )
            {
                if( other.client.chaseTarget == this.client.playerNum + 1 )
                {
                    G_CenterPrintMsg( other, message );
                }
            }
        }
    }

	/**
     * Send the appropriate diff time to the center of the screen of the player
     * @param int id
	 * @param uint newTime
	 * @param uint personalBestTime
	 * @param uint serverBestTime
	 * @param uint def
	 * @return void
	 */
    void sendDiffed( int id, uint newTime, uint personalBestTime, uint serverBestTime, uint def )
    {
        if (@this.client == null)
            return;

        uint ref = def;
        if( this.diffRef == DIFFREF_PERSONAL )
        {
            ref = personalBestTime;
        }
        else if( this.diffRef == DIFFREF_SERVER )
        {
            ref = serverBestTime;
        }
        else if( this.diffRef == DIFFREF_PLAYER )
        {
            if( id < 0 )
                ref = this.diffPlayer.getBestTime();
            else
                ref = this.diffPlayer.getBestCheckPoint( id );
        }
        else if( this.diffRef == DIFFREF_WORLD )
        {
            if( id < 0 )
                ref = map.getWorldHighScore().getTime();
            else
                ref = map.getWorldHighScore().getCheckPoint( id );
        }

        G_CenterPrintMsg( this.client.getEnt(), ( id < 0 ? "Time" : "Current" ) + ": " + TimeToString( newTime )
			+ ( ref == 0 ? "" : ("\n" + diffString( ref, newTime ) )) );
    }

	/**
     * Send the appropriate diff time to the center of the screen of the player
     * and his spectators
     * @param int id
	 * @param uint newTime
	 * @param uint personalBestTime
	 * @param uint serverBestTime
	 * @param uint def
	 * @return void
	 */
    void distributeDiffed( int id, uint newTime, uint personalBestTime, uint serverBestTime, uint def )
    {
        if (@this.client == null)
            return;

        sendDiffed( id, newTime, personalBestTime, serverBestTime, def );
        cTeam @spectators = @G_GetTeam( TEAM_SPECTATOR );
        cEntity @other;
        for ( int i = 0; @spectators.ent( i ) != null; i++ )
        {
            @other = @spectators.ent( i );
            if ( @other.client != null && other.client.chaseActive )
            {
                if( other.client.chaseTarget == this.client.playerNum + 1 )
                    Racesow_GetPlayerByClient( other.client ).sendDiffed( id, newTime, personalBestTime, serverBestTime, def );
            }
        }
    }

   /**
     * Send an unlogged award to the player
     * @param String message
     * @return void
     */
    void sendAward( String message )
    {
        if (@this.client == null)
            return;
        this.client.execGameCommand( "aw \"" + message + "\"" );
        //print the checkpoint times to specs too
        cTeam @spectators = @G_GetTeam( TEAM_SPECTATOR );
        cEntity @other;
        for ( int i = 0; @spectators.ent( i ) != null; i++ )
        {
            @other = @spectators.ent( i );
            if ( @other.client != null && other.client.chaseActive )
            {
                if( other.client.chaseTarget == this.client.playerNum + 1 )
                {
                    other.client.execGameCommand( "aw \"" + message + "\"" );
                }
            }
        }
    }

    /**
     * Send a message to console of the player
     * when the message is too long, split it in several parts
     * to avoid print buffer overflow
     * @param String message
     * @return void
     */
    void sendLongMessage( String message )
    {
        if (@this.client == null)
            return;

        const uint maxsize = 1000;
        uint partsNumber = message.length()/maxsize;

        if ( partsNumber*maxsize < message.length() )//compute the ceil instead of floor
            partsNumber++;

        for ( uint i = 0; i < partsNumber; i++ )
        {
            G_PrintMsg( this.client.getEnt(), message.substr(i*maxsize,maxsize) );
        }

        // maybe log messages for some reason to figure out ;)
    }

    /**
     * Send an error message with red warning.
     * @param String message
     * @return void
     */
    void sendErrorMessage( String message )
    {
        if (@this.client == null)
            return;

        G_PrintMsg( this.client.getEnt(), S_COLOR_RED + "Error: " + S_COLOR_WHITE
                    + message +"\n");
    }

	/**
	* Send a message to another player's console
	* @param String message, cClient @client
	* @return void
	*/
	void sendMessage( String message, cClient @client )
	{
		G_PrintMsg( client.getEnt(), message );
	}


	/**
	 * Send a message to another player
	 * @param String argString, cClient @client
	 * @return bool
	 */
	bool privSay( String message, cClient @target )
	{
	    this.sendMessage( target.name + S_COLOR_RED + " >>> " + S_COLOR_WHITE + message + "\n");
	    sendMessage( client.name + S_COLOR_RED + " <<< " + S_COLOR_WHITE + message + "\n", @target );
		return true;
	}

	/**
	 * Kick the player and leave a message for everyone
	 * @param String message
	 * @return void
	 */
	void kick( String message )
	{
        if( @this.client == null )
            return;
        int playerNum = this.client.playerNum;
        if( message.length() > 0)
            G_PrintMsg( null, S_COLOR_RED + "Kicked " + S_COLOR_WHITE + this.getName() + S_COLOR_RED + " Reason: " + message + "\n" );
        this.reset();
        G_CmdExecute( "kick " + playerNum );
	}

	/**
	 * Remove the player and leave a message for everyone
	 * @param String message
	 * @return void
	 */
	void remove( String message )
	{
		if( message.length() > 0)
			G_PrintMsg( null, S_COLOR_RED + message + "\n" );
		this.client.team = TEAM_SPECTATOR;
		this.client.respawn( true ); // true means ghost
	}

   /**
     * Ban the player
     * @param String message
     * @return void
     */
    void kickban( String message )
    {
        String ip = this.client.getUserInfoKey( "ip" );
        this.reset();
        G_CmdExecute( "addip " + ip + " 15;kick " + this.client.playerNum );
    }

    /**
     * Move the player to spec and leave a message to him
     * @param String message
     * @return void
     */
    void moveToSpec( String message )
    {
        this.client.team = TEAM_SPECTATOR;
        this.client.respawn( true ); // true means ghost
        this.sendMessage( message );
    }
	/**
	 * Switch player ammo between strong/weak
	 * @param cClient @client
	 * @return bool
	 */
	bool ammoSwitch(  )
	{
		if ( gametypeFlag == MODFLAG_FREESTYLE || g_allowammoswitch.boolean )
		{
			if ( @this.client.getEnt() == null )
			{
				return false;
			}
			cItem @item;
		    cItem @weakItem;
		    cItem @strongItem;
		    @item = @G_GetItem( this.client.getEnt().weapon );
		    if(@item == null || this.client.getEnt().weapon == 1 )
		    	return false;
		    @weakItem = @G_GetItem( item.weakAmmoTag );
		    @strongItem = @G_GetItem( item.ammoTag );
			uint strong_ammo = this.client.pendingWeapon + 9;
			uint weak_ammo = this.client.pendingWeapon + 18;

			if ( this.client.inventoryCount( item.ammoTag ) > 0 )
			{
				this.client.inventorySetCount( item.weakAmmoTag, weakItem.inventoryMax );
				this.client.inventorySetCount( item.ammoTag, 0 );
			}
			else
			{
				this.client.inventorySetCount( item.ammoTag, strongItem.inventoryMax );
			}
		}
		else
		{
			sendMessage( S_COLOR_RED + "Ammoswitch is disabled.\n", @this.client );
		}
		return true;
	}

	/**
	 * Chrono time
	 * @return uint
	 */
	uint chronoTime()
	{
		return this.chronoStartTime;
	}


    /**
     * Execute an admin command
     * @param String &cmdString
     * @return bool
     */
    bool adminCommand( String &cmdString )
    {
        bool showNotification = false;
        String command = cmdString.getToken( 0 );

        //Commented out for release - Per server admin/authmasks will be finished when the new http DB-Interaction is done
        // add command - adds a new admin (sets all permissions except RACESOW_AUTH_SETPERMISSION)
        // delete command - deletes admin rights for the given player
        /*if ( command == "add" || command == "delete" )
        {
            if( !this.auth.allow( RACESOW_AUTH_ADMIN | RACESOW_AUTH_SETPERMISSION ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the commmand 'admin "+ cmdString);
                return false;
            }

            if( cmdString.getToken( 1 ) == "" )
            {
                this.client.execGameCommand("cmd players");
                showNotification = false;
                return false;
            }

            Racesow_Player @player = @Racesow_GetPlayerByNumber( cmdString.getToken( 1 ).toInt() );
            if (@player == null )
                return false;

            //Set authmask
            if( command == "add" )
                this.sendErrorMessage("added");
                //player.setAuthmask( RACESOW_AUTH_ADMIN );
            else
                this.sendErrorMessage("deleted");
                //player.setAuthmask( RACESOW_AUTH_REGISTERED );
        }

        // setpermission command - sets/unsets the given permission for the given player
        else if( command == "setpermission" )
        {
            uint permission;
            if( !this.auth.allow( RACESOW_AUTH_ADMIN | RACESOW_AUTH_SETPERMISSION ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the commmand 'admin "+ cmdString);
                return false;
            }

            if( cmdString.getToken( 1 ) == "" )
            {
                this.sendErrorMessage( "Usage: admin setpermission <playernum> <permission> <enable/disable>" );
                this.client.execGameCommand("cmd players");
                showNotification = false;
                return false;
            }

            if( cmdString.getToken( 2 ) == "" )
            {
                //show list of permissions: map, mute, kick, timelimit, restart, setpermission
                this.sendErrorMessage( "No permission specified. Available permissions:\n map, mute, kick, timelimit, restart, setpermission" );
                return false;
            }

            if( cmdString.getToken( 3 ) == "" || cmdString.getToken( 3 ).toInt() > 1 )
            {
                //show: 1 to enable 0 to disable current: <enabled/disabled>
                this.sendErrorMessage( "1 to enable permission 0 to disable permission" );
                return false;
            }

            if( cmdString.getToken( 2 ) == "map" )
                permission = RACESOW_AUTH_MAP;
            else if( cmdString.getToken( 2 ) == "mute" )
                permission = RACESOW_AUTH_MUTE;
            else if( cmdString.getToken( 2 ) == "kick" )
                permission = RACESOW_AUTH_KICK;
            else if( cmdString.getToken( 2 ) == "timelimit" )
                permission = RACESOW_AUTH_TIMELIMIT;
            else if( cmdString.getToken( 2 ) == "restart" )
                permission = RACESOW_AUTH_RESTART;
            else if( cmdString.getToken( 2 ) == "setpermission" )
                permission = RACESOW_AUTH_SETPERMISSION;
            else
                return false;

            Racesow_Player @player = @Racesow_GetPlayerByNumber( cmdString.getToken( 1 ).toInt() );
            if (@player == null )
                return false;

            if( cmdString.getToken( 3 ).toInt() == 1 )
                this.sendErrorMessage( cmdString.getToken( 2 ) + "enabled" );
                //player.setAuthmask( player.authmask | permission );
            else
                this.sendErrorMessage( cmdString.getToken( 2 ) + "disabled" );
                //player.setAuthmask( player.authmask & ~permission );
        }*/

        // map command
        if ( command == "map" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_MAP ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString);
                return false;
            }

            String mapName = cmdString.getToken( 1 );
            if ( mapName == "" )
            {
                this.sendErrorMessage( "No map name given" );
                return false;
            }

            G_CmdExecute( "gamemap " + mapName + "\n" );
            showNotification = true;
        }

        // update maplist
        else if ( command == "updateml" )
        {
            if ( !this.auth.allow(RACESOW_AUTH_ADMIN) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString);
                return false;
            }
            RS_UpdateMapList( this.client.playerNum );
            showNotification = true;
        }

        // restart command
        else if ( command == "restart" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_MAP ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString);
                return false;
            }
            G_CmdExecute("match restart\n");
            showNotification = true;
        }

        // extend_time command
        else if ( command == "extend_time" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_MAP ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString);
                return false;
            }
            if( g_timelimit.integer <= 0 )
            {
                this.sendErrorMessage( "This command is only available for timelimits.\n");
                return false;
            }
            g_timelimit.set(g_timelimit.integer + g_extendtime.integer);

            map.cancelOvertime();
            for ( int i = 0; i < maxClients; i++ )
            {
                players[i].cancelOvertime();
            }
            showNotification = true;
        }

        // votemute, mute commands (RACESOW_AUTH_MUTE)
        else if ( command == "mute" || command == "unmute" || command == "vmute" ||
                  command == "vunmute" || command == "votemute" || command == "unvotemute" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_MUTE ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString );
                return false;
            }
            if( cmdString.getToken( 1 ) == "" )
            {
                this.client.execGameCommand("cmd players");
                showNotification = false;
                return false;
            }
            Racesow_Player @player = @Racesow_GetPlayerByNumber( cmdString.getToken( 1 ).toInt() );
            if (@player == null )
                return false;

            if( command == "votemute" )
                player.isVotemuted = true;
            else if( command == "unvotemute" )
                player.isVotemuted = false;
            else if( command == "mute" )
                player.client.muted |= 1;
            else if( command == "unmute" )
                player.client.muted &= ~1;
            else if( command == "vmute" )
                player.client.muted |= 2;
            else if( command == "vunmute" )
                player.client.muted &= ~2;
            showNotification = true;
        }

        // kick, remove, joinlock  commands (RACESOW_AUTH_KICK)
        else if ( command == "remove"|| command == "kick" || command == "joinlock" || command == "joinunlock" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_KICK ) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString );
                return false;
            }
            if( cmdString.getToken( 1 ) == "" )
            {
                this.client.execGameCommand("cmd players");
                showNotification = false;
                return false;
            }
            Racesow_Player @player = @Racesow_GetPlayerByNumber( cmdString.getToken( 1 ).toInt() );
            if (@player == null )
                return false;

            if( command == "kick" )
                player.kick("");
            else if( command == "remove" )
                player.remove("");
            else if( command == "joinlock" )
                player.isJoinlocked = true;
            else if( command == "joinunlock" )
                player.isJoinlocked = false;
            showNotification = true;
        }

        // cancelvote command
        else if ( command == "cancelvote" )
        {
            if ( !this.auth.allow( RACESOW_AUTH_MAP ) )
            {
                this.sendErrorMessage("You are not permitted to execute the command 'admin "+ cmdString);
                return false;
            }
            RS_cancelvote();
            showNotification = true;
        }


        // ban
        else if ( command == "kickban" )
        {
            if ( !this.auth.allow(RACESOW_AUTH_ADMIN) )
            {
                this.sendErrorMessage( "You are not permitted to execute the command 'admin "+ cmdString );
                return false;
            }
            if( cmdString.getToken( 1 ) == "" )
            {
                this.client.execGameCommand("cmd players");
                showNotification = false;
                return false;
            }
            Racesow_Player @player = @Racesow_GetPlayerByNumber( cmdString.getToken( 1 ).toInt() );
            if (@player != null )
                player.kickban("");
        }

        else
        {
            this.sendErrorMessage("The command 'admin " + cmdString + "' does not exist" );
            return false;
        }

        if ( showNotification )
        {
            G_PrintMsg( null, S_COLOR_WHITE + this.getName() + S_COLOR_GREEN
                        + " executed command '"+ cmdString + "'\n" );
        }
        return true;
    }

	/**
	 * execute a Racesow_Command
	 * @param command Command to execute
	 * @param argsString Arguments passed to the command
	 * @param argc Number of arguments
	 * @return Success boolean
	 */
	bool executeCommand(Racesow_Command@ command, String &argsString, int argc)
	{
	    if(command.validate(@this, argsString, argc))
	    {
	        if(command.execute(@this, argsString, argc))
	            return true;
	        else
	        {
	            this.sendMessage(command.getUsage());
	            return false;
	        }
	    }

		if ( command.practiceEnabled && gametypeFlag != MODFLAG_FREESTYLE )
		{
			// if a practiceEnabled command fails to validate, send this message instead of the cmd.getUsage().
			// i guess we'll have a better solution to this when the new command system is up.
			this.sendErrorMessage( "The " + command.name + " command is only available in practice mode." );
			return true;
		}
	    this.sendMessage(command.getUsage());
	    return true;
	}
}
