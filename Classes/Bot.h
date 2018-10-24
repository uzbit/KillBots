//
//  Bot.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/6/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLObject.h"
#import "OpenGLUtilities.h"
#import "Pathfind.h"
#import "Weapon.h"
#import "Types.h"
#import "Attack.h"
#import "Color.h"
#import "Defines.h"

#define BOT_VISCOSITY			0.98
#define ANGLE_TO_FIRE			5

#define BOT_RADIUS				0.14
#define BOT_RADIUS_2			BOT_RADIUS*BOT_RADIUS

#define BOSS_BOT_RADIUS				0.25
#define BOSS_BOT_RADIUS_2			BOSS_BOT_RADIUS*BOSS_BOT_RADIUS

/*
attack: rate of fire (0-10), missile speed (0-10), missile strength (0-10), laser strength (0-10), suicide bomber (0,1), shock wave (0,1), jammer (0,1), landmines (0,1)
defense: shield strength (0-100), missile/laser resistance (0,1), regeneration (0,1)
targeting: speed (0-10), locking (0,1)
movement: speed (0-10), missile avoidance (0, 1), keep a distance from enemy (0, 1), teleport when almost dead (0, 1)
*/

@class AiWarsViewController;


@interface Bot : OpenGLObject <NSCopying>
{
	/* bot parameters */
	
	//bot type
	NSString *name, *description;
	int type; //stores the index of the botTypes array for which type this bot is
	int cost; //the cost of the bot

	//attack
	NSMutableArray *attackTypes, *attacksFired;
	float effectiveRange; 
	
	//defense
	bool missileResistant; //reduces missile damage
	bool laserResistant; //reduces laser damage
	bool regeneration; //slowly regenerates life (could potentially cause a round to not finish)
	
	//targeting
	float targetingSpeed; //number of degrees the bot can turn in one cycle
	float targetingTimer; //number of cycles the bot has had a target (for changing targets too quickly)
	bool targetLocking; //if set, then the bot targets the same bot until it is dead
	float currentTargetingAngle, initialTargetingAngle, finalTargetingAngle, currentTurnRate;
	Bot *target; //the bot that is currently being targeted
	Bot *targeting; //the bot that is targeting this bot
	float leadTargetX, leadTargetY;
	
	//movement
	MovementType currentMovement;
	bool followingFriend;
	float maxSpeed; //number of units the bot can move in one cycle
	Bot *botToFollow;
	float scaleMovement, scaleEvade, scaleToward;
	
	//textures
	GLuint texture; //stores the texture name
	GLuint shieldsTexture;
	GLuint icyTexture;
	
	/* current state */	
	float life; //starts at 100, 0 is you're dead
	float lifeBarTimer;
	float shields; //shields take damage before the bot
	float shieldsTimer;
	NSMutableArray *path;
	Color *color; //current color of the bot
	int baseTexture; //the index of the base texture
	
	/* permanant states */
	int player; //current player number
	bool computer; //if set, then the player is controlled by the computer
	int selfIndex;	
	int cycleCount;
	int tierLevel; //this value is the section #. the tier # = section #+1
	
	//boss bot
	bool isBoss;
	bool isFatManBoss;
	float spawnRate;
	float spawnTimer;
	int spawnType;
	
	//enhancements?
	float jammedTimer;
	float icyTimer, fireTimer;
	
	//controller
	AiWarsViewController *controller;
}

//bot type
@property ATOMICITY_RETAIN NSString *name, *description;
@property ATOMICITY_NONE int type;
@property ATOMICITY_NONE int cost;

//attack
@property ATOMICITY_RETAIN NSMutableArray *attackTypes, *attacksFired;
@property ATOMICITY_NONE float effectiveRange;

//defense
@property ATOMICITY_NONE bool missileResistant;
@property ATOMICITY_NONE bool laserResistant;
@property ATOMICITY_NONE bool regeneration;

//targeting
@property ATOMICITY_NONE float targetingSpeed;
@property ATOMICITY_NONE float targetingTimer;
@property ATOMICITY_NONE bool targetLocking;
@property ATOMICITY_NONE float currentTargetingAngle, initialTargetingAngle, finalTargetingAngle, currentTurnRate;
@property ATOMICITY_ASSIGN Bot *target;
@property ATOMICITY_ASSIGN Bot *targeting;


//movement
@property ATOMICITY_NONE MovementType currentMovement;
@property ATOMICITY_NONE bool followingFriend;
@property ATOMICITY_NONE float maxSpeed;
@property ATOMICITY_ASSIGN Bot *botToFollow;
@property ATOMICITY_NONE float scaleMovement, scaleEvade, scaleToward;

//enhancements
@property ATOMICITY_NONE float jammedTimer;
@property ATOMICITY_NONE float icyTimer, fireTimer;

//texture
@property ATOMICITY_NONE GLuint texture;
@property ATOMICITY_NONE GLuint shieldsTexture;
@property (nonatomic) GLuint icyTexture;

/* current state */	
@property ATOMICITY_NONE float life;
@property ATOMICITY_NONE float lifeBarTimer;
@property ATOMICITY_NONE float shields;
@property ATOMICITY_NONE float shieldsTimer;
@property ATOMICITY_NONE int tierLevel;

@property ATOMICITY_RETAIN NSMutableArray *path;
@property ATOMICITY_ASSIGN Color *color;
@property ATOMICITY_NONE int baseTexture;

//boss bot
@property ATOMICITY_NONE bool isBoss;
@property ATOMICITY_NONE bool isFatManBoss;
@property ATOMICITY_NONE float spawnRate;
@property ATOMICITY_NONE float spawnTimer;
@property ATOMICITY_NONE int spawnType;


/* permanant states */
@property ATOMICITY_NONE int player;
@property ATOMICITY_NONE bool computer;
@property ATOMICITY_NONE int selfIndex;	
@property ATOMICITY_NONE int cycleCount;

//controller
@property ATOMICITY_ASSIGN AiWarsViewController *controller;

@end
