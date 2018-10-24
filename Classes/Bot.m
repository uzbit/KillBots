//
//  Bot.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/6/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Bot.h"
#import "Weapons.h"
#import "Rates.h"
#import "Player.h"
#import "AiWarsViewController.h"

#define LEAD_BOTS 1

static inline float distanceBetweenBots(Bot *b1, Bot *b2)
{
	float distX = [b1 x] - [b2 x];
	float distY = [b1 y] - [b2 y];
	return sqrt(distX*distX + distY*distY);
}

@implementation Bot

//bot type
@synthesize name, description;
@synthesize type;
@synthesize cost;

//attack
@synthesize attackTypes, attacksFired;
@synthesize effectiveRange;

//defense
@synthesize missileResistant;
@synthesize laserResistant;
@synthesize regeneration;

//targeting
@synthesize targetingSpeed;
@synthesize targetingTimer;
@synthesize targetLocking;
@synthesize currentTargetingAngle, initialTargetingAngle, finalTargetingAngle, currentTurnRate;
@synthesize target;
@synthesize targeting;

//movement
@synthesize currentMovement;
@synthesize followingFriend;
@synthesize maxSpeed;
@synthesize botToFollow;
@synthesize scaleMovement, scaleEvade, scaleToward;


@synthesize jammedTimer;
@synthesize icyTimer, fireTimer;

//texture
@synthesize texture, baseTexture;
@synthesize shieldsTexture;
@synthesize icyTexture;

/* current state */	
@synthesize life;
@synthesize lifeBarTimer;
@synthesize shields;
@synthesize shieldsTimer;
@synthesize path;
@synthesize color;

/* permanant states */
@synthesize player;
@synthesize computer;
@synthesize selfIndex;	
@synthesize cycleCount;
@synthesize tierLevel;

//boss bot
@synthesize isBoss;
@synthesize isFatManBoss;
@synthesize spawnRate;
@synthesize spawnTimer;
@synthesize spawnType;

//controller
@synthesize controller;

- (id)init
{
	if ((self = [super init]))
	{
		name = [[NSString alloc] initWithString:@"Normal Bot"];
		description = [[NSString alloc] initWithString:@"Description"];
		computer = false;
		life = 100;
		currentMovement = MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY;
		currentTargetingAngle = 45;
		targetLocking = NO;
		target = NULL;
		targeting = NULL;
		targetingTimer = 10; //defaults so that initial target can be found
		attacksFired = NULL;
		attackTypes = NULL;
		followingFriend = false;
		botToFollow = NULL;
		jammedTimer = MAX_JAMMED_TIME;
		icyTimer = MAX_ICY_TIME;
		fireTimer = MAX_FIRE_TIME;
		lifeBarTimer = 0;
		shieldsTimer = 0;
		tierLevel = 0;
		isBoss = false;
		isFatManBoss = false;
		spawnRate = 0;
		spawnTimer = 0;
		spawnType = 0;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Bot *bot = [[Bot alloc] init];
	[bot setX:[self x]];
	[bot setY:[self y]];
	[bot setZ:[self z]];
	[bot setMass:[self mass]];
	[bot setColor:[self color]];
	[bot setBaseTexture:[self baseTexture]];
	
	[bot setName:[self name]];
	[bot setType:[self type]];
	[bot setMissileResistant:[self missileResistant]];
	[bot setLaserResistant:[self laserResistant]];
	[bot setRegeneration:[self regeneration]];
	[bot setTargetLocking:[self targetLocking]];
	[bot setTarget:[self target]];
	[bot setTargeting:[self targeting]];
	[bot setCurrentMovement:[self currentMovement]];
	[bot setMaxSpeed:[self maxSpeed]];
	[bot setTexture:[self texture]];
	[bot setShieldsTexture:[self shieldsTexture]];
	[bot setIcyTexture:[self icyTexture]];
	[bot setLife:[self life]];
	[bot setShields:[self shields]];
	[bot setPlayer:[self player]];
	[bot setComputer:[self computer]];
	[bot setSelfIndex:[self selfIndex]];
	[bot setCycleCount:[self cycleCount]];
	[bot setCost:[self cost]];
	[bot setEffectiveRange:[self effectiveRange]];
	[bot setTierLevel:[self tierLevel]];
	[bot setScaleMovement:[self scaleMovement]];
	[bot setScaleEvade:[self scaleEvade]];
	[bot setScaleToward:[self scaleToward]];
	[bot setIsBoss:[self isBoss]];
	[bot setIsFatManBoss:[self isFatManBoss]];
	[bot setSpawnRate:[self spawnRate]];
	[bot setSpawnTimer:[self spawnTimer]];
	[bot setSpawnType:[self spawnType]];
	
	
	[bot setController:[self controller]];
	
	//allocate attackTypes and attacksFired
	[[bot attackTypes] release];
	[bot setAttackTypes:nil];
	[bot setAttackTypes:[[NSMutableArray alloc] initWithCapacity:[attackTypes count]]];
	[[bot attacksFired] release];
	[bot setAttacksFired:nil];
	[bot setAttacksFired:[[NSMutableArray alloc] initWithCapacity:1]];

	for (Attack *a in [self attackTypes])
	{
		Attack *tmp = [[Attack alloc] init];
		[tmp setAttackType:[a attackType]];
		[tmp setAttackRate:[a attackRate]];
		[tmp setAttackTimer:slyRandom(0, [a attackRate])];
		[tmp setAttackWeapon:[a attackWeapon]];
		[[bot attackTypes] addObject:[tmp copy]];
		[tmp release];
	}
	return bot;
}

- (float)findSmallestAngleDiffBetween:(float)start andFinish:(float)finish
{
	if (finish - start > 180)
		return (finish - start - 360);
	if (finish - start < -180)
		return (finish - start + 360);
	return finish - start;
}

- (float)wrapAngle:(float)angle
{
	if (angle > 360)
		angle -= 360;
	else if (angle < -360)
		angle += 360;	
	return angle;
}

- (Bot *)findClosest:(bool)enemy exclude:(NSMutableArray*)list
{
	int count = [[[controller theGame] players] count];
	float bestScore = 1.0e9;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	for (int p = 0; p < count; p++)
	{
		if (enemy && p == player)
			continue;
		if (!enemy && p != player)
			continue;
		
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0 || ([list indexOfObject:b] != NSNotFound && list != nil))
				continue;
			tmpScore = distanceBetweenBots(self, b);
			if (tmpScore <= bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
		}
	}
	return retBot;
}

- (Bot *)findHighestLife:(bool)enemy exclude:(NSMutableArray*)list
{
	int count = [[[controller theGame] players] count];
	float bestScore = -1.0;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	for (int p = 0; p < count; p++)
	{
		if (enemy && p == player)
			continue;
		if (!enemy && p != player)
			continue;
		
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			
			if ([b life] <= 0 || ([list indexOfObject:b] != NSNotFound && list != nil))
				continue;
			tmpScore = [b life];
			if (tmpScore > bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
		}
	}
	return retBot;
}

- (Bot *)findLowestLife:(bool)enemy exclude:(NSMutableArray*)list
{
	int count = [[[controller theGame] players] count];
	float bestScore = 1.0e9;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	for (int p = 0; p < count; p++)
	{
		if (enemy && p == player)
			continue;
		if (!enemy && p != player)
			continue;
		
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0  || [list indexOfObject:b] != NSNotFound)
				continue;
			tmpScore = [b shields]+[b life];
			if (tmpScore < bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
		}
	}
	return retBot;
}

- (Bot *)findHighestCost:(bool)enemy exclude:(NSMutableArray*)list
{
	int count = [[[controller theGame] players] count];
	float bestScore = -1.0;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	bool hasJamming = false;
	for (int p = 0; p < count; p++)
	{
		if (enemy && p == player)
			continue;
		if (!enemy && p != player)
			continue;
		
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0 || [list indexOfObject:b] != NSNotFound)
				continue;
			
			hasJamming = false;
			for (Attack *a in [b attackTypes])
				if ([a attackType] == ATTACK_TYPE_JAMMER)
				{
					hasJamming = true;
					break;
				}
			
			tmpScore = [b cost] 
					+ (([b shields]/SHIELDS_VAL_FOR_BOT(b))*[[controller botSelector] shieldsCostForBot:b orWithIndex:-1]);
					+ (hasJamming?[[controller botSelector] jammerCostForBot:b orWithIndex:-1]:0);
			
			if (tmpScore > bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
			else if (tmpScore == bestScore)
			{
				if (distanceBetweenBots(self, b) < distanceBetweenBots(self, retBot))
					retBot = b;
			}
		}
	}
	return retBot;
}

- (Bot *)findLowestCost:(bool)enemy exclude:(NSMutableArray*)list
{
	int count = [[[controller theGame] players] count];
	float bestScore = 1.0e9;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	for (int p = 0; p < count; p++)
	{
		if (enemy && p == player)
			continue;
		if (!enemy && p != player)
			continue;
		
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0  || [list indexOfObject:b] != NSNotFound)
				continue;
			tmpScore = [b cost];
			if (tmpScore <= bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
		}
	}
	return retBot;
}

- (Bot *)findClosestTargetingEnemy
{
	int count = [[[controller theGame] players] count];
	float bestScore = 1.0e9;
	float tmpScore;
	NSMutableArray *bots;
	Bot *retBot = NULL;
	for (int p = 0; p < count; p++)
	{
		if (p == player)
			continue;
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0 || [b target] != self)
				continue;
			tmpScore = distanceBetweenBots(self, b);
			if (tmpScore <= bestScore)
			{
				bestScore = tmpScore;
				retBot = b;
			}
		}
	}
	return retBot;
}

- (NSMutableArray *)findEnemysInRange:(float)testRange ofX:(float)X andY:(float)Y
{
	int count = [[[controller theGame] players] count];
	NSMutableArray *enemysInRange = [[NSMutableArray alloc] initWithCapacity:1];
	NSMutableArray *bots;
	float diffX, diffY;
	for (int p = 0; p < count; p++)
	{
		if (p == player)
			continue;
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (Bot *b in bots)
		{
			if ([b life] <= 0)
				continue;
			diffX = [b x] - X;
			diffY = [b y] - Y;
			
			if ((diffX*diffX+diffY*diffY)  <= testRange*testRange)
				[enemysInRange addObject:b];
		}
	}
	return enemysInRange;
}

- (float)findExpectedDamageToBot:(Bot *)bot
{
	float distance = distanceBetweenBots(self, bot);
	float retVal = 0;
	for (Attack *a in attackTypes)
	{
		if ([[a attackWeapon] range] >= distance)
			retVal += [[a attackWeapon] damage];
		else if (distance > 0.01)
			retVal += [[a attackWeapon] damage]*([[a attackWeapon] range]/distance);
	}
	return retVal;
}

#define LIFE_FITNESS_WEIGHT		2.0
#define COST_FITNESS_WEIGHT		0.05
#define MOVEMENT_FITNESS_WEIGHT	0.5

- (void)findCurrentTarget
{
	targetingTimer+=INCREMENT_PER_CYCLE;
	
	if (jammedTimer < MAX_JAMMED_TIME)
		return;
	
	if (icyTimer < MAX_ICY_TIME)
		return;
	
	if (target)
		if (([target life] > 0) && (targetingTimer+slyRandom(-5*INCREMENT_PER_CYCLE, 10*INCREMENT_PER_CYCLE)) < TARGET_CHANGE_DELAY)
			return;
	
	NSMutableArray *enemysInRange = [self findEnemysInRange:((effectiveRange<0.2)?3.0:effectiveRange) ofX:[self x] andY:[self y]];
	if ([enemysInRange count])
	{
		NSMutableArray *exclude = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:self]];
		Bot *botToTarget = nil;
		if (currentMovement == MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY)
			botToTarget = [self findClosest:true exclude:exclude];
		
		if (currentMovement == MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY)
			botToTarget = [self findHighestCost:true exclude:exclude];
		
		if (currentMovement == MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY)
			botToTarget = [self findLowestLife:true exclude:exclude];
		
		float expectedDamage, expectedLife;
		float bestScore = -1.0e9, fitness, lifeFitness, costFitness, movementFitness = 0;
		float bestMinimumLife = 1.0e9;
		for (Bot *b in enemysInRange)
		{
			expectedDamage = [self findExpectedDamageToBot:b];
			if ([b shields] > 0)
				expectedLife = [b shields] - expectedDamage;
			else
				expectedLife = [b life] - expectedDamage;
			
			costFitness = [b cost];
			movementFitness = fabs(DEGREES_TO_RADIANS([self findSmallestAngleDiffBetween:currentTargetingAngle andFinish:getAngleToLookAt([self x], [self y], [b x], [b y])]));
			movementFitness += distanceBetweenBots(self, b);
			if (expectedLife < bestMinimumLife)
			{
				bestMinimumLife = expectedLife;
				if (bestMinimumLife <= 0)
					lifeFitness = 1.0;//expf(-bestMinimumLife*bestMinimumLife*0.01);
				else
					lifeFitness = expf(-bestMinimumLife*bestMinimumLife*0.0005);
			}
			else
			{
				if (expectedLife <= 0)
					lifeFitness = 1.0;//expf(-expectedLife*expectedLife*0.01);
				else
					lifeFitness = expf(-expectedLife*expectedLife*0.0005);
			}
			
			fitness = LIFE_FITNESS_WEIGHT*lifeFitness + COST_FITNESS_WEIGHT*costFitness - MOVEMENT_FITNESS_WEIGHT*movementFitness;
			
			//NSLog(@"bot = %x, life = %f, cost = %f, movement = %f", b, LIFE_FITNESS_WEIGHT*lifeFitness, COST_FITNESS_WEIGHT*costFitness, MOVEMENT_FITNESS_WEIGHT*movementFitness);
			
			if (b == botToTarget)
			{
				target = b;
				break;
			}
			
			if (fitness >= bestScore)
			{
				target = b;
				bestScore = fitness;
			}
		}
		[exclude release];
	}
	else
	{
		NSMutableArray *exclude = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:self]];
		target = [self findClosest:true exclude:exclude];
		[exclude release];
	}
	[enemysInRange release];
	
	targetingTimer = 0;
}

- (void)findCurrentMovement
{
	
	if (botToFollow == NULL || [botToFollow life] <= 0)
	{
		NSMutableArray *exclude = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:self]];
		switch (currentMovement)
		{
			case MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND:
			{	
				botToFollow = [self findClosest:false exclude:exclude];
				while([botToFollow followingFriend])//[bot currentMovement] == MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND )
				{
					[exclude addObject:botToFollow];
					botToFollow = [self findClosest:false exclude:exclude];
					if (botToFollow == NULL)
						break;
				}
				if (botToFollow)
				{
					if (![botToFollow followingFriend])
						followingFriend = true;
					else
						followingFriend = false;
				}
				else
					botToFollow = target;
				break;
			}
	/*
			case MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_FRIEND:
			{	
				botToFollow = [self findLowestLife:false exclude:exclude];
				while([botToFollow followingFriend])//[botToFollow currentMovement] == MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_FRIEND)
				{
					[exclude addObject:botToFollow];
					botToFollow = [self findLowestLife:false exclude:exclude];
					if (botToFollow == NULL)
						break;
				}
				if (![botToFollow followingFriend] && botToFollow)
					followingFriend = true;
				else
					followingFriend = false;
				break;
			}
			case MOVEMENT_TYPE_FOLLOW_HIGHEST_LIFE_FRIEND:
			{	
				botToFollow = [self findHighestLife:false exclude:exclude];
				while([botToFollow followingFriend])//[botToFollow currentMovement] == MOVEMENT_TYPE_FOLLOW_HIGHEST_LIFE_FRIEND)
				{
					[exclude addObject:botToFollow];
					botToFollow = [self findHighestLife:false exclude:exclude];
					if (botToFollow == NULL)
						break;
				}
				if (![botToFollow followingFriend] && botToFollow)
					followingFriend = true;
				else
					followingFriend = false;
				break;
			}
			case MOVEMENT_TYPE_FOLLOW_LOWEST_COST_FRIEND:
			{	
				botToFollow = [self findLowestCost:false exclude:exclude];
				while([botToFollow followingFriend])//[botToFollow currentMovement] == MOVEMENT_TYPE_FOLLOW_LOWEST_COST_FRIEND)
				{
					[exclude addObject:botToFollow];
					botToFollow = [self findLowestCost:false exclude:exclude];
					if (botToFollow == NULL)
						break;
				}
				if (![botToFollow followingFriend])
					followingFriend = true;
				break;
			}
	 */
			case MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND:
			{	
				botToFollow = [self findHighestCost:false exclude:exclude];
				while([botToFollow followingFriend])//[botToFollow currentMovement] == MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND)
				{
					[exclude addObject:botToFollow];
					botToFollow = [self findHighestCost:false exclude:exclude];
					if (botToFollow == NULL)
						break;
				}
				if (botToFollow)
				{
					if (![botToFollow followingFriend])
						followingFriend = true;
					else
						followingFriend = false;
				}
				else
					botToFollow = target;
				break;
			}
			case MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY:
			{	
				botToFollow = [self findClosest:true exclude:exclude];
				break;
			}
			case MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY:
			{	
				botToFollow = [self findLowestLife:true exclude:exclude];
				break;
			}
	/*
			case MOVEMENT_TYPE_FOLLOW_HIGHEST_LIFE_ENEMY:
			{	
				botToFollow = [self findHighestLife:true exclude:exclude];
				break;
			}
			case MOVEMENT_TYPE_FOLLOW_LOWEST_COST_ENEMY:
			{	
				botToFollow = [self findLowestCost:true exclude:exclude];
				break;
			}
	*/
			case MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY:
			{	
				botToFollow = [self findHighestCost:true exclude:exclude];
				break;
			}
			case MOVEMENT_TYPE_RANDOM:
			{
				botToFollow = nil;
				break;
			}
			default:
				break;
		}
		[exclude release];
	}
	
}

- (void)computeBotMovement
{
	NSMutableArray *bots;
	static float d, distX, distY;
	const int playerCount = [[[controller theGame] players] count];
	int botsCount;
	float e[2] = {0, 0}, t[2] = {0, 0}, ei[2] = {0, 0}, m[2] = {0, 0};
	
	for (int p = 0; p < playerCount; p++)
	{
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		botsCount = [bots count];
		
		Bot *bot;
		for (int botIndex = 0; botIndex < [bots count]; botIndex++)
		{
			bot = [bots objectAtIndex:botIndex];
			if (bot == self || [bot life] <= 0)
				continue;
			
			distX = [bot x] - x;
			distY = [bot y] - y;
			d = (distX*distX + distY*distY);
			
			// check bot collision
			float radius2 = ((isBoss || [bot isBoss])?BOSS_BOT_RADIUS_2:BOT_RADIUS_2); 
			if (d < radius2)
			{
				//move to boundary
				if (d > 0.01) 
				{
					[self setX:-(distX)*sqrt(radius2/d)+[bot x]];
					[self setY:-(distY)*sqrt(radius2/d)+[bot y]];
				}
				else
				{
					[self setX:-SIGN(distX)*sqrt(radius2)+[bot x]];
					[self setY:-SIGN(distY)*sqrt(radius2)+[bot y]];
				}
				
				//force away from boundary
				[self applyForceWithDdx:-(distX)*0.02 Ddy:-(distY)*0.02 Ddz:0];
				[bot applyForceWithDdx:(distX)*0.02 Ddy:(distY)*0.02 Ddz:0];
			}
			
			// do bot movement
			else if (p != player && d > 0.01)
			{
				ei[0] = ([bot x]-x)*FORCE_CONSTANT;
				ei[1] = ([bot y]-y)*FORCE_CONSTANT;
				if (d < effectiveRange*effectiveRange)
				{	
					e[0] -= ei[0]/d;
					e[1] -= ei[1]/d;
				}
				else
				{
					t[0] += ei[0]/d;
					t[1] += ei[1]/d;
				}
			}
		}
	}

	if (jammedTimer < MAX_JAMMED_TIME)
	{
		jammedTimer += INCREMENT_PER_CYCLE;
		[self applyForceWithDdx:FORCE_CONSTANT*slyRandom(-10.0, 10.0) Ddy:FORCE_CONSTANT*slyRandom(-10.0, 10.0) Ddz:0];
		/*if (fabs(dx) < 0.001)
			ddx = 0;
		if (fabs(dy) < 0.001)
			ddy = 0;*/
		return;
	}
	
	if (fireTimer < MAX_FIRE_TIME)
	{
		fireTimer += INCREMENT_PER_CYCLE;
		icyTimer = MAX_ICY_TIME;
	}

	if (icyTimer < MAX_ICY_TIME)
	{
		icyTimer += INCREMENT_PER_CYCLE;
		return;
	}
	
	if (botToFollow != nil)
	{
		m[0] = ([botToFollow x]-x)*FORCE_CONSTANT;
		m[1] = ([botToFollow y]-y)*FORCE_CONSTANT;
	
		//ensure that rammer and suicide bots dont accel too fast
		if (scaleEvade < 0.001 && scaleToward < 0.001)
		{
			if (sqrt(dx*dx+dy*dy) < (1.0/CYCLES_PER_SECOND))
			{
				float mag = sqrt(m[0]*m[0] + m[1]*m[1]); 
				m[0] *= 0.0007/mag;
				m[1] *= 0.0007/mag;
			}
			else
			{
				m[0] = 0;
				m[1] = 0;
			}
		}

		[self applyForceWithDdx:scaleMovement*m[0]+scaleEvade*e[0]+scaleToward*t[0] Ddy:scaleMovement*m[1]+scaleEvade*e[1]+scaleToward*t[1] Ddz:0];
	}
	else //this should be random movement only
	{
		[self applyForceWithDdx:FORCE_CONSTANT*slyRandom(-10.0, 10.0) Ddy:FORCE_CONSTANT*slyRandom(-10.0, 10.0) Ddz:0];
	}
}

- (void)fireWeapons:(float)targetDistance
{
	if (jammedTimer < MAX_JAMMED_TIME)
		return;
	
	if (icyTimer < MAX_ICY_TIME)
		return;
	
	if (isBoss)
	{
		spawnTimer += INCREMENT_PER_CYCLE;
		if (spawnTimer >= (spawnRate + slyRandom(-20*INCREMENT_PER_CYCLE, 10*INCREMENT_PER_CYCLE)))
		{
			Bot *closest = [self findClosest:true exclude:nil];
			float sx = ([closest x] - x);
			float sy = ([closest y] - y);
			float mag = sqrt(sx*sx+sy*sy);
			float angleToLookAt = getAngleToLookAt(x, y, [closest x], [closest y]);
			if (mag > 0.0001)
			{
				sx *= 0.03/mag;
				sy *= 0.03/mag;
			}
			else
			{
				sx = SIGN(sx)*0.03;
				sy = SIGN(sy)*0.03;
			}
			if (player < [[[controller theGame] players] count])
			{
				[[controller singlePlayerRounds] addBotWithX:x+BOSS_BOT_RADIUS*sin(DEGREES_TO_RADIANS(angleToLookAt)) Y:y+BOSS_BOT_RADIUS*cos(DEGREES_TO_RADIANS(angleToLookAt)) Player:player botType:spawnType botMovement:currentMovement shields:false jamming:false];
				Bot *addedBot = (Bot *)[[[[[controller theGame] players] objectAtIndex:player] bots] lastObject];
				[addedBot setDx:sx];
				[addedBot setDy:sy];
				spawnTimer = 0;
				[controller playSound:spawnBotSound];
			}
		}
		
		//do jamming
		for (Attack *a in attackTypes)
		{
			[a setAttackTimer:[a attackTimer]+INCREMENT_PER_CYCLE];
			// check to fire weapons
			if ([a attackTimer] >= [a attackRate] && [a attackType] == ATTACK_TYPE_JAMMER)
			{	
				JammerWeapon *fired = [[a attackWeapon] copy]; 
				[fired setPlayer:player];
				[fired setInitialX:x];
				[fired setInitialY:y];
				[fired setX:x Y:y Z:z+0.002];
				[attacksFired addObject:fired];
				[controller addUpdateableObject:fired];
				[controller addDrawableObject:fired];
				[a setAttackTimer:0];
				[fired release];
				[controller playSound:jammerSound];
				break;
			}
		}
	}
	else
	{
		if (!target)
			return;
		
		for (Attack *a in attackTypes)
		{
			[a setAttackTimer:[a attackTimer]+INCREMENT_PER_CYCLE];
			// check to fire weapons
			if ([a attackTimer] >= [a attackRate])
			{
				float angleDif = fabs([self findSmallestAngleDiffBetween:currentTargetingAngle andFinish:finalTargetingAngle]);
#if LEAD_BOTS
				float diffX = leadTargetX-x;
				float diffY = leadTargetY-y;
#else
				float diffX = [target x]-x;
				float diffY = [target y]-y;
#endif				
				float mag = sqrt(diffX*diffX+diffY*diffY);
				
				if (mag < 0.01)
					mag = 0.01;
				
				switch ([a attackType])
				{
					case ATTACK_TYPE_NORMAL:
					{
						NormalWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//[fired setFiredFrom:self];
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:NORMAL_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:NORMAL_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:normalWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_NORMAL_DOUBLE:
					{
						NormalWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle-5.0))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle-5.0))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:NORMAL_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:NORMAL_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							fired = nil;
							
							//second normal
							fired = [[a attackWeapon] copy];
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle+5.0))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle+5.0))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:NORMAL_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:NORMAL_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							
							[a setAttackTimer:0];
							[controller playSound:normalWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_SHOTTIE:
					{
						bool shotFired = false;
						for (int i = 0; i < 6; i++)
						{	
							NormalWeapon *fired = [[a attackWeapon] copy]; 
							if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
							{
								shotFired = true;
								[fired setPlayer:player];
								[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
								[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
								[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
								[fired setDx:NORMAL_WEAPON_SPEED*diffX/mag+slyRandom(-0.2*NORMAL_WEAPON_SPEED, 0.2*NORMAL_WEAPON_SPEED)]; 
								[fired setDy:NORMAL_WEAPON_SPEED*diffY/mag+slyRandom(-0.2*NORMAL_WEAPON_SPEED, 0.2*NORMAL_WEAPON_SPEED)];
								[attacksFired addObject:fired];
								[controller addUpdateableObject:fired];
								[controller addDrawableObject:fired];
								[a setAttackTimer:0];
							}
							[fired release];
						}
						if (shotFired)
							[controller playSoundNotTooMuch:shottieWeaponSound];
						break;
					}
					case ATTACK_TYPE_MISSILE:
					{
						MissileWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							//[fired setDx:dx Dy:dy Dz:0];
							[fired setDdx:MISSILE_WEAPON_SPEED*0.05*diffX/mag Ddy:MISSILE_WEAPON_SPEED*0.05*diffY/mag Ddz:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:missileWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_LASER:
					{
						LaserWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:LASER_WEAPON_SPEED*diffX/mag];
							[fired setDy:LASER_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:laserWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_MASS_DRIVER:
					{
						MassDriverWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							[fired setPlayer:player];
							[fired setInitialX:x];//+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y];//+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:MASS_DRIVER_WEAPON_SPEED*diffX/mag Dy:MASS_DRIVER_WEAPON_SPEED*diffY/mag Dz:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:massDriverWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_MINE_LAYER:
					{
						MineLayerWeapon *fired = [(MineLayerWeapon *)[a attackWeapon] copy];
						[fired setFiredFrom:self];
						[fired setPlayer:player];
						[fired setInitialX:x];
						[fired setInitialY:y];
						[fired setX:[fired initialX] Y:[fired initialY] Z:z-0.00001];
						[fired setDdx:0 Ddy:0 Ddz:0];
						[fired setDx:0 Dy:0 Dz:0];
						[attacksFired addObject:fired];
						[controller addUpdateableObject:fired];
						[controller addDrawableObject:fired];
						[a setAttackTimer:0];
						[fired release];
						break;
					}
					case ATTACK_TYPE_SUICIDE:
					{
						SuicideWeapon *fired = [[a attackWeapon] copy];
						[fired setPlayer:player];
						[fired setX:x Y:y Z:z+0.002];
						[fired setInitialX:x];
						[fired setInitialY:y];
						[attacksFired addObject:fired];
						[controller addUpdateableObject:fired];
						[a setAttackTimer:0];
						[fired release];
						break;
					}
					case ATTACK_TYPE_JAMMER:
					{
						JammerWeapon *fired = [[a attackWeapon] copy]; 
						[fired setPlayer:player];
						[fired setInitialX:x];
						[fired setInitialY:y];
						[fired setX:x Y:y Z:z+0.002];
						[attacksFired addObject:fired];
						[controller addUpdateableObject:fired];
						[controller addDrawableObject:fired];
						[a setAttackTimer:0];
						[fired release];
						[controller playSound:jammerSound];
						break;
					}
					case ATTACK_TYPE_RAMMER:
					{
						RammerWeapon *fired = [[a attackWeapon] copy]; 
						[fired setPlayer:player];
						[fired setInitialX:x];
						[fired setInitialY:y];
						[fired setX:x Y:y Z:z+0.002];
						[attacksFired addObject:fired];
						[controller addUpdateableObject:fired];
						[a setAttackTimer:0];
						[fired release];
						break;
					}
					case ATTACK_TYPE_PLASMA_CANNON:
					{
						PlasmaCannonWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:PLASMA_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:PLASMA_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							[a setAttackTimer:0];
							[controller playSound:plasmaWeaponSound];
						}
						break;
					}
					case ATTACK_TYPE_ICY:
					{
						IcyWeapon *fired = [(IcyWeapon *)[a attackWeapon] copy]; 
						if (targetDistance < [fired range])
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:0]; 
							[fired setDy:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:icyWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_FLAMETHROWER:
					{
						FlamethrowerWeapon *fired = [(FlamethrowerWeapon *)[a attackWeapon] copy]; 
						if (targetDistance < [fired range])
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:0]; 
							[fired setDy:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:flamethrowerWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_LIGHTNING:
					{
						LightningWeapon *fired = [(LightningWeapon *)[a attackWeapon] copy]; 
						if (targetDistance < [fired range])
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:0]; 
							[fired setDy:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:lightningWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_MISSILE_DOUBLE:
					{
						MissileWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							
							//[fired setDx:dx Dy:dy Dz:0];
							//[fired setDx:MISSILE_WEAPON_SPEED*diffX/mag]; 
							//[fired setDy:MISSILE_WEAPON_SPEED*diffY/mag];
							[fired setDdx:MISSILE_WEAPON_SPEED*0.05*diffX/mag Ddy:MISSILE_WEAPON_SPEED*0.05*diffY/mag Ddz:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							fired = nil;
							
							//second normal
							fired = [[a attackWeapon] copy];
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							//[fired setDx:dx Dy:dy Dz:0];
							//[fired setDx:MISSILE_WEAPON_SPEED*diffX/mag]; 
							//[fired setDy:MISSILE_WEAPON_SPEED*diffY/mag];
							[fired setDdx:MISSILE_WEAPON_SPEED*0.05*diffX/mag Ddy:MISSILE_WEAPON_SPEED*0.05*diffY/mag Ddz:0];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							
							[a setAttackTimer:0];
							[controller playSound:missileWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_SEEKING_MISSILE:
					{
						SeekingMissileWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < 3*ANGLE_TO_FIRE)
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setTarget:target];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:missileWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_LASER_DOUBLE:
					{
						LaserWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:LASER_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:LASER_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							fired = nil;
							
							//second normal
							fired = [[a attackWeapon] copy];
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:LASER_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:LASER_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							
							[a setAttackTimer:0];
							[controller playSound:laserWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_SEEKING_MISSILE_DOUBLE:
					{
						SeekingMissileWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < 3*ANGLE_TO_FIRE)
						{
							Bot *target1, *target2;
							float w1[2], w2[2];
							bool botToFollowIsTarget = false;
							
							switch (currentMovement)
							{
								case MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY:
								case MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY:
								case MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY:
									if (botToFollow == target)
										botToFollowIsTarget = true;
									break;
								default:
									break;
							}
							
							w1[0] = x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle+10));
							w1[1] = y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle+10));
							
							w2[0] = x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle-10));
							w2[1] = y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle-10));
							
							
							if ([target cost] >= 0.5*[self cost] || botToFollowIsTarget)
							{
								target1 = target;
								target2 = target;
							}
							else
							{
								NSMutableArray *exclude = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:target]];
								Bot *nextTarget = [target findClosest:false exclude:exclude];
								[exclude release];
								
								if (nextTarget != nil)
								{
									float nextTargetAngle = getAngleToLookAt([self x], [self y], [nextTarget x], [nextTarget y]);	
									if (fabs([self findSmallestAngleDiffBetween:currentTargetingAngle andFinish:nextTargetAngle]) > 20)
										nextTarget = nil;
								}
								
								if (nextTarget != nil)
								{
									if ((w1[0] < w2[0] && [target x] < [nextTarget x])
									|| (w1[1] < w2[1] && [target y] < [nextTarget y])
									|| (w1[0] > w2[0] && [target x] > [nextTarget x])
									|| (w1[1] > w2[1] && [target y] > [nextTarget y]))
									{
										target1 = target;
										target2 = nextTarget;
									}
									else
									{
										target1 = nextTarget;
										target2 = target;
									}
								}
								else
								{
									target1 = target;
									target2 = target;
								}
							}
							
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:w1[0]];
							[fired setInitialY:w1[1]];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setTarget:target1];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							fired = nil;
							
							//second normal
							fired = [[a attackWeapon] copy];
							[fired setPlayer:player];
							[fired setInitialX:w2[0]];
							[fired setInitialY:w2[1]];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setTarget:target2];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							
							[a setAttackTimer:0];
							[controller playSound:missileWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_PLASMA_CANNON_DOUBLE:
					{
						PlasmaCannonWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range] && angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle+10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:PLASMA_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:PLASMA_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							fired = nil;
							
							//second normal
							fired = [[a attackWeapon] copy];
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle-10))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.004];
							[fired setDx:PLASMA_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:PLASMA_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							
							[a setAttackTimer:0];
							[controller playSound:plasmaWeaponSound];
						}
						break;
					}
					case ATTACK_TYPE_DEATH_RAY:
					{
						DeathRayWeapon *fired = [[a attackWeapon] copy]; 
						if (targetDistance < [fired range])
						{
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:0];
							[fired setDy:0];
							[fired setTarget:target];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[a setAttackTimer:0];
							[controller playSound:deathRayWeaponSound];
						}
						[fired release];
						break;
					}
					case ATTACK_TYPE_FATMAN:
					{
						FatManWeapon *fired = [[a attackWeapon] copy]; 
						if (angleDif < ANGLE_TO_FIRE)
						{
							//first normal
							[fired setPlayer:player];
							[fired setInitialX:x+BOT_RADIUS*sin(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setInitialY:y+BOT_RADIUS*cos(DEGREES_TO_RADIANS(currentTargetingAngle))];
							[fired setX:[fired initialX] Y:[fired initialY] Z:z+0.002];
							[fired setDx:FATMAN_WEAPON_SPEED*diffX/mag]; 
							[fired setDy:FATMAN_WEAPON_SPEED*diffY/mag];
							[attacksFired addObject:fired];
							[controller addUpdateableObject:fired];
							[controller addDrawableObject:fired];
							[fired release];
							[a setAttackTimer:0];
							[controller playSound:normalWeaponSound];
						}
						break;
					}
						
					default:
						break;
				}
			}
		}
	}
}

- (void)explode
{
	[controller playSound:botExplosionSound];
	[controller vibrate];

	//create a visual explosion
	[controller explosionAtX:x Y:y withColor:[self color] withRadius:.3];

	//apply a force to close bots
	Bot *bot;
	NSMutableArray *bots;
	static float d, distX, distY;
	const int playerCount = [[[controller theGame] players] count];
	
	for (int p = 0; p < playerCount; p++)
	{
		bots = [[[[controller theGame] players] objectAtIndex:p] bots];
		for (int i = 0; i < [bots count]; i++)
		{
			bot = [bots objectAtIndex:i];
			if (bot == self || [bot life] <= 0)
				continue;
			
			distX = [bot x] - x;
			distY = [bot y] - y;
			d = distX*distX + distY*distY;
			
			//apply force
			if (d > 0.01)
				[bot applyForceWithDdx:(distX)/(d*300) Ddy:(distY)/(d*300) Ddz:0];
		}
	}
}

- (void)damageBot:(Bot *)bot withDamage:(float)damage
{
	if ([bot shields] > 0)
	{
		if (([bot shields] - damage) > 0)
		{
			[bot setShields:[bot shields] - damage];
			[bot setShieldsTimer:1.0];
		}
		else
		{
			[bot setLife:[bot life] + ([bot shields] - damage)];	
			[bot setShields:0];
			[bot setShieldsTimer:1.0];
			[bot setLifeBarTimer:1.0];
		}
	}
	else
	{
		[bot setLife:[bot life] - damage];
		[bot setLifeBarTimer:1.0];
	}
	
	//bot died
	if ([bot life] <= 0)
	{
		Player *enemyPlayer = [[[controller theGame] players] objectAtIndex:[bot player]];
		Player *selfPlayer = [[[controller theGame] players] objectAtIndex:player];
		[selfPlayer setBotsKilled:[selfPlayer botsKilled]+1];
		[selfPlayer setBotsKilledThisRound:[selfPlayer botsKilledThisRound]+1];
		[enemyPlayer setBotsDestroyed:[enemyPlayer botsDestroyed]+1];
		
		[bot explode];
	}
}


- (void)removeWeapon:(Weapon *)w fromAttacksFired:(NSMutableArray *)removeArray
{
	[removeArray addObject:w];
	[controller removeUpdateableObject:w];
	[controller removeDrawableObject:w];
}

- (void)checkWeaponsCollision
{
	NSMutableArray *bots;
	static float d, distX, distY;
	const int playerCount = [[[controller theGame] players] count];
	
	// check weapons collision
	NSMutableArray *removeArray = [[NSMutableArray alloc] initWithCapacity:1];
	
	for (Weapon *w in attacksFired)
	{
		distX = [w initialX] - [w x];
		distY = [w initialY] - [w y];
		d = (distX*distX + distY*distY);
		
		if (fabs([w x]) > 2.0 || fabs([w y]) > 1.5 || d > [w range]*[w range])
		{
			[self removeWeapon:w fromAttacksFired:removeArray];
			continue;
		}
		
		if ([w splashOnly])
		{
			switch ([w attackType])
			{
				case ATTACK_TYPE_JAMMER:
				{
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
					for (Bot *e in enemysInSplashRange)
					{
						if ([e jammedTimer] >= MAX_JAMMED_TIME)
						{
							[e setJammedTimer:0];
							[e setCurrentTurnRate:SIGN(slyRandom(-1, 1))*slyRandom(5, 25)];
							[e setTarget:NULL];
						}
					}
					if ([w splashRange] >= [w range])
						[self removeWeapon:w fromAttacksFired:removeArray];
					else
						[w setAlpha:1.0 - (0.9*[w splashRange]*[w splashRange]/([w range]*[w range]))];
					[enemysInSplashRange release];
					break;
				}
				case ATTACK_TYPE_MINE_LAYER:
				{ 
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
					NSMutableArray *mineEnemiesInRange = [self findEnemysInRange:[w range] ofX:[w x] andY:[w y]];
					if ([mineEnemiesInRange count])
					{
						for (Bot *e in enemysInSplashRange)
						{
							distX = [e x] - [w x];
							distY = [e y] - [w y];
							d = (distX*distX + distY*distY);
							[self damageBot:e withDamage:([w damage]*(1.0 - sqrt(d)/[w splashRange]))];
							[e applyForceWithDdx:(distX)/(d*500) Ddy:(distY)/(d*500) Ddz:0];
						}
						[controller playSound:mineExplodeSound];
						[controller explosionAtX:[w x] Y:[w y] withColor:[[controller colors] objectAtIndex:6] withRadius:[w splashRange]];
						[self removeWeapon:w fromAttacksFired:removeArray];
					}
					[mineEnemiesInRange release];
					[enemysInSplashRange release];
					break;
				}	
				case ATTACK_TYPE_SUICIDE:
				{
					NSMutableArray *enemysInRange = [self findEnemysInRange:([target isBoss]?0.8*BOT_RADIUS:0)+[w range] ofX:[w x] andY:[w y]];
					
					bool doesContainTarget = false;
					if (currentMovement == MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND 
						||currentMovement == MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND)
						doesContainTarget = true;
					else	
						for (Bot *e in enemysInRange)
							if (e == target || e == botToFollow)
								doesContainTarget = true;
					
					if (doesContainTarget || [enemysInRange count] >= 2)
					{
						NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
						for (Bot *e in enemysInSplashRange)
						{
							distX = [e x] - [w x];
							distY = [e y] - [w y];
							[self damageBot:e withDamage:([w damage]*(1.0 - sqrt(distX*distX + distY*distY)/[w splashRange]))];
						}
						Player *selfPlayer = [[[controller theGame] players] objectAtIndex:player];
						[selfPlayer setBotsDestroyed:[selfPlayer botsDestroyed]+1];
						[controller playSound:suicideExplosionSound];
						[self explode];
						[controller explosionAtX:x Y:y withColor:[self color] withRadius:1];
						life = 0;
						[enemysInSplashRange release];
					}
					[self removeWeapon:w fromAttacksFired:removeArray];
					[enemysInRange release];
					
					break;
				}
				case ATTACK_TYPE_ICY:
				{
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
					const float maxSpreadAngle = 8;
					float R1dotR2, magR1, magR2, spreadAngle;
					float sinCTA = sin(DEGREES_TO_RADIANS(currentTargetingAngle)), cosCTA = cos(DEGREES_TO_RADIANS(currentTargetingAngle));
					
					[w setX:x Y:y Z:[w z]];
					
					//add the particles
					if ([w updateCounter] < [w timeToLive])
						for (int i = 0; i < ICY_PARTICLE_NUM; i++)
							[(IcyWeapon *)w addParticleX:x+BOT_RADIUS*sinCTA Y:y+BOT_RADIUS*cosCTA dX:sinCTA/20.0f+slyRandom(-.01, .01) dY:cosCTA/20.0f+slyRandom(-.01, .01)];
					
					if ([w updateCounter] > 5)
					{
						//damage the enemies
						for (Bot *e in enemysInSplashRange)
						{
							if ([e fireTimer] < MAX_FIRE_TIME)
								continue;
							/*
							R1 = (BOT_RADIUS+[w range])*sin(DEGREES_TO_RADIANS(currentTargetingAngle))
								 (BOT_RADIUS+[w range])*cos(DEGREES_TO_RADIANS(currentTargetingAngle))
							R2 = [e x] - x
								 [e y] - y
							*/
							R1dotR2 = (BOT_RADIUS+[w range])*sinCTA*([e x] - x)
									+ (BOT_RADIUS+[w range])*cosCTA*([e y] - y);
							magR1 = sqrt((BOT_RADIUS+[w range])*sinCTA*(BOT_RADIUS+[w range])*sinCTA
										 + (BOT_RADIUS+[w range])*cosCTA*(BOT_RADIUS+[w range])*cosCTA);
							magR2 = sqrt(([e x] - x)*([e x] - x) + ([e y] - y)*([e y] - y));
							
							spreadAngle = fabs(RADIANS_TO_DEGREES(acos(R1dotR2/(magR1*magR2))));
							
							if (spreadAngle < 90.0 && magR2 <= magR1 && magR2*(sin(DEGREES_TO_RADIANS(spreadAngle))) < magR1*tan(DEGREES_TO_RADIANS(maxSpreadAngle)))
							{
								[e setIcyTimer:0];
								[e setDdx:0];
								[e setDdy:0];
								[e setDx:0];
								[e setDy:0];
								[e setCurrentTurnRate:0];
								[e setTarget:NULL];
								[self damageBot:e withDamage:([w damage]*(1.0 - magR2*(sin(DEGREES_TO_RADIANS(spreadAngle)))/(magR1*tan(DEGREES_TO_RADIANS(maxSpreadAngle)))))];
							}
						}
					
						if ([w updateCounter] > ([w timeToLive]+0.1*CYCLES_PER_SECOND) || life <= 0 || jammedTimer < MAX_JAMMED_TIME || icyTimer < MAX_ICY_TIME)
							[self removeWeapon:w fromAttacksFired:removeArray];
					}
					
					[enemysInSplashRange release];
					break;
				}	
				case ATTACK_TYPE_FLAMETHROWER:
				{
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
					const float maxSpreadAngle = 8;
					float R1dotR2, magR1, magR2, spreadAngle;
					float sinCTA = sin(DEGREES_TO_RADIANS(currentTargetingAngle)), cosCTA = cos(DEGREES_TO_RADIANS(currentTargetingAngle));
					
					[w setX:x Y:y Z:[w z]];
					
					//add the particles
					if ([w updateCounter] < [w timeToLive])
						for (int i = 0; i < FLAMETHROWER_PARTICLE_NUM; i++)
							[(FlamethrowerWeapon *)w addParticleX:x+BOT_RADIUS*sinCTA Y:y+BOT_RADIUS*cosCTA dX:sinCTA/20.0f+slyRandom(-.01, .01) dY:cosCTA/20.0f+slyRandom(-.01, .01)];
					
					if ([w updateCounter] > 5)
					{
						//damage the enemies
						for (Bot *e in enemysInSplashRange)
						{
							/*
							 R1 = (BOT_RADIUS+[w range])*sin(DEGREES_TO_RADIANS(currentTargetingAngle))
								  (BOT_RADIUS+[w range])*cos(DEGREES_TO_RADIANS(currentTargetingAngle))
							 R2 = [e x] - x
								  [e y] - y
							*/
							R1dotR2 = (BOT_RADIUS+[w range])*sinCTA*([e x] - x)
									+ (BOT_RADIUS+[w range])*cosCTA*([e y] - y);
							magR1 = sqrt((BOT_RADIUS+[w range])*sinCTA*(BOT_RADIUS+[w range])*sinCTA
										 + (BOT_RADIUS+[w range])*cosCTA*(BOT_RADIUS+[w range])*cosCTA);
							magR2 = sqrt(([e x] - x)*([e x] - x) + ([e y] - y)*([e y] - y));
							
							spreadAngle = fabs(RADIANS_TO_DEGREES(acos(R1dotR2/(magR1*magR2))));
							
							if (spreadAngle < 90.0 && magR2 <= magR1 && magR2*(sin(DEGREES_TO_RADIANS(spreadAngle))) < magR1*tan(DEGREES_TO_RADIANS(maxSpreadAngle)))
							{
								float damage = ([w damage]*(1.0 - magR2*(sin(DEGREES_TO_RADIANS(spreadAngle)))/(magR1*tan(DEGREES_TO_RADIANS(maxSpreadAngle)))));
								[e setFireTimer:[e fireTimer]-(int)damage];
								if ([e fireTimer] < 0)
									[e setFireTimer:0];
								[self damageBot:e withDamage:damage];
							}
						}
						
						if ([w updateCounter] > ([w timeToLive]+0.1*CYCLES_PER_SECOND)  || life <= 0 || jammedTimer < MAX_JAMMED_TIME || icyTimer < MAX_ICY_TIME)
							[self removeWeapon:w fromAttacksFired:removeArray];
						
					}
					
					[enemysInSplashRange release];
					break;
				}
				default:
				{
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
					for (Bot *e in enemysInSplashRange)
					{
						distX = [e x] - [w x];
						distY = [e y] - [w y];
						[self damageBot:e withDamage:([w damage]*(1.0 - sqrt(distX*distX + distY*distY)/[w splashRange]))];
					}
					[self removeWeapon:w fromAttacksFired:removeArray];
					[enemysInSplashRange release];
					break;
				}
			}
		}
		else
		{
			[w setAlpha:1.0 - (0.6*d/([w range]*[w range]))];
			
			switch ([w attackType])
			{
				case ATTACK_TYPE_RAMMER:
				{
					NSMutableArray *enemysInRange = [self findEnemysInRange:BOSS_BOT_RADIUS+[w range] ofX:[w x] andY:[w y]];
					float relativeSpeed;
					for (Bot *e in enemysInRange)
					{
						if ([e isBoss] || (  ([e x]-[w x])*([e x]-[w x]) + ([e y]-[w y])*([e y]-[w y]) <= (BOT_RADIUS+[w range])*(BOT_RADIUS+[w range]) ))
						{	
							relativeSpeed = fabs(([e dx]*[e dx] + [e dy]*[e dy]) - (dx*dx+dy*dy));
							[self damageBot:e withDamage:((relativeSpeed < 0.0001)?[w damage]:10000*(relativeSpeed - 0.0001))];
						}
					}
					[self removeWeapon:w fromAttacksFired:removeArray];
					[enemysInRange release];
					break;
				}
				case ATTACK_TYPE_LIGHTNING:
				{
					[w setX:x Y:y Z:[w z]];
					NSMutableArray *enemysInRange = [self findEnemysInRange:[w range] ofX:[w x] andY:[w y]];
					for (int i = 0; i < 4 && i < [enemysInRange count]; i++)//Bot *e in enemysInRange)
					{
						Bot *e = [enemysInRange objectAtIndex:i];
						[self damageBot:e withDamage:[w damage]];
						[(LightningWeapon *)w addStrikeX:[e x] Y:[e y]];
					}
					
					if ([w updateCounter] >= [w timeToLive] || jammedTimer < MAX_JAMMED_TIME || icyTimer < MAX_ICY_TIME || life <= 0)
						[self removeWeapon:w fromAttacksFired:removeArray];
					[enemysInRange release];
					break;
				}
				case ATTACK_TYPE_DEATH_RAY:
				{
					if ([[w target] life] > 0)
					{
						[w setX:x Y:y Z:[w z]];
						[self damageBot:[w target] withDamage:[w damage]];
					}
					/*if ([[w target] life] <= 0)
					{
						NSMutableArray *exclude = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:[w target]]];
						Bot *nextTarget = [[w target] findClosest:false exclude:exclude];
						[exclude release];
						[w setTarget:nextTarget];
					}*/
					if ([w updateCounter] >= [w timeToLive] || [[w target] life] <= 0 || [self life] <= 0 || jammedTimer < MAX_JAMMED_TIME || icyTimer < MAX_ICY_TIME)
						[self removeWeapon:w fromAttacksFired:removeArray];
					break;
				}
				case ATTACK_TYPE_FATMAN:
				{
					if ([w alpha] < 0.7)
						if (![(FatManWeapon *)w exploded])
						{
							[controller playSound:fatManExplosionSound];
							[(FatManWeapon *)w explode];
						}
						
					if ([w updateCounter] < 0.05*[w timeToLive])
						break;
					
					NSMutableArray *enemysInSplashRange = [self findEnemysInRange:0.5*[w splashRange] ofX:[w x] andY:[w y]];
					
					if ([enemysInSplashRange count])
					{
						NSMutableArray *enemysInSplashRangeProper = [self findEnemysInRange:[w splashRange] ofX:[w x] andY:[w y]];
						if (![(FatManWeapon *)w exploded])
						{
							[controller playSound:fatManExplosionSound];
							[(FatManWeapon *)w explode];
						}
						
						float damage;
						for (Bot *e in enemysInSplashRangeProper)
						{
							distX = [e x] - [w x];
							distY = [e y] - [w y];
							d = distX*distX + distY*distY;
							if (d < 0.01) d = 0.01;
							damage = ([w damage]*([(FatManWeapon *)w explosionTimer]/FATMAN_EXPLOSION_TIME)*(1.0 - sqrt(d)/([w splashRange])));
							[self damageBot:e withDamage:damage];
							if (damage < 10.0)
								[e applyForceWithDdx:(distX)/(d*500) Ddy:(distY)/(d*500) Ddz:0];
							else
								[e applyForceWithDdx:(log10f(damage)*distX)/(d*1000) Ddy:(log10f(damage)*distY)/(d*1000) Ddz:0];
							
						}
						[enemysInSplashRangeProper release];
					}
					
					[enemysInSplashRange release];
					
					if (([(FatManWeapon *)w exploded] && [(FatManWeapon *)w explosionTimer] <= 0))
						[self removeWeapon:w fromAttacksFired:removeArray];
					
					break;
				}
				case ATTACK_TYPE_MASS_DRIVER:
				case ATTACK_TYPE_SEEKING_MISSILE:
				{
					if ([w timeToLive] <= 0)
						[self removeWeapon:w fromAttacksFired:removeArray];
				}//continue to default
				default:
				{
					bool breakOut = false;
					Bot *bot;
					for (int i = 0; i < playerCount; i++)
					{
						if (i == player)
							continue;
						
						bots = [[[[controller theGame] players] objectAtIndex:i] bots];
						int botsCount = [bots count];
						for (int i = 0; i < botsCount; i++)
						{
							bot = [bots objectAtIndex:i];
							if ([bot life] <= 0)
								continue;
							
							distX = [bot x] - [w x];
							distY = [bot y] - [w y];
							d = distX*distX + distY*distY;

							float radius2 = (([bot isBoss])?BOSS_BOT_RADIUS_2:BOT_RADIUS_2); 
							if (d < radius2)
							{
								if ([w splashRange] > 0.0)
								{
									float sqrtRadius2 = sqrt(radius2);
									NSMutableArray *enemysInRange = [self findEnemysInRange:([w splashRange]+sqrtRadius2) ofX:[w x] andY:[w y]];
									float damage;
									for (Bot *e in enemysInRange)
									{
										distX = [e x] - [w x];
										distY = [e y] - [w y];
										d = distX*distX + distY*distY;
										if (d < 0.001) d = 0.001;
										damage = ([w damage]*(1.0 - sqrt(d)/([w splashRange]+sqrtRadius2)));
										[self damageBot:e withDamage:damage];
										if (damage < 10.0)
											[e applyForceWithDdx:(distX)/(d*500) Ddy:(distY)/(d*500) Ddz:0];
										else
											[e applyForceWithDdx:(log10f(damage)*distX)/(d*1000) Ddy:(log10f(damage)*distY)/(d*1000) Ddz:0];
										
									}
									[enemysInRange release];
								}
								else
								{
									[self damageBot:bot withDamage:[w damage]];
								}
								if ([w attackType] == ATTACK_TYPE_MASS_DRIVER)
								{
									[controller playSoundNotTooMuch:massDriverHitSound];
								}
								else
								{
									[self removeWeapon:w fromAttacksFired:removeArray];
								}
								breakOut = true;
								break;
							}
						}
						if (breakOut)
						{
							switch ([w attackType])
							{
								case ATTACK_TYPE_SEEKING_MISSILE:
								case ATTACK_TYPE_MISSILE:
									[controller playSound:missileExplodeSound];
									[controller explosionAtX:[w x] Y:[w y] withColor:[[controller colors] objectAtIndex:5] withRadius:.05];
									break;
								case ATTACK_TYPE_PLASMA_CANNON:
									[controller playSound:plasmaExplosionSound];
									[controller explosionAtX:[w x] Y:[w y] withColor:[[controller colors] objectAtIndex:12] withRadius:.05];
									break;
							}
							break;
						}
					}
					break;
				}
			}
		}
	}
	[attacksFired removeObjectsInArray:removeArray];
	[removeArray release];

}

- (void)computeCurrentTargetingAngle
{
	if (!target)
	{
		currentTargetingAngle += currentTurnRate;
		return;
	}	

#if LEAD_BOTS //see also fireWeapons
	float dist = distanceBetweenBots(self, target);
	float dt = dist/LASER_WEAPON_SPEED;
	float newTargetX = [target x] + [target dx]*dt + 0.5*[target ddx]*dt*dt;
	float newTargetY = [target y] + [target dy]*dt + 0.5*[target ddy]*dt*dt;
	
	dist = sqrt(([self x]-newTargetX)*([self x]-newTargetX) + ([self y]-newTargetY)*([self y]-newTargetY));
	dt = dist/LASER_WEAPON_SPEED;
	leadTargetX = [target x] + [target dx]*dt + 0.5*[target ddx]*dt*dt;
	leadTargetY = [target y] + [target dy]*dt + 0.5*[target ddy]*dt*dt;
	
	finalTargetingAngle = getAngleToLookAt([self x], [self y], leadTargetX, leadTargetY);	
#else
	finalTargetingAngle = getAngleToLookAt([self x], [self y], [target x], [target y]);	
#endif	
	

	float angleDif = [self findSmallestAngleDiffBetween:currentTargetingAngle andFinish:finalTargetingAngle];
	
	if (fabs(angleDif) < 1)
	{
		initialTargetingAngle = currentTargetingAngle;
		currentTurnRate = 0;
		return;
	}
	
	currentTurnRate = angleDif/5.0;
	
	if (fabs(currentTurnRate) > MAX_TURN_RATE)
		currentTurnRate = SIGN(angleDif)*MAX_TURN_RATE;
	
	currentTargetingAngle += currentTurnRate;
	currentTargetingAngle = [self wrapAngle:currentTargetingAngle];
	
}

- (void)update
{
	if ([[controller theGame] gameMode] != GAME_MODE_BATTLE)
		return;

	if (life > 0)
	{
		float distX, distY, targetDistance = 1.0e9;
		if (target)
		{
			distX = [target x] - x;
			distY = [target y] - y;
			targetDistance = sqrt(distX*distX + distY*distY);
		}

		[self findCurrentTarget];
		
		[self findCurrentMovement];
		
		[self computeBotMovement];
		
		dx *= BOT_VISCOSITY;
		dy *= BOT_VISCOSITY;
		dz = 0;
		
		[self updatePosition];
		
		//edge of screen
		if (fabs(x) > 1.5)
		{
			x = SIGN(x)*1.5;
			dx *= -.3;
		}
		if (fabs(y) > 1)
		{
			y = SIGN(y)*1;
			dy *= -.3;
		}
		
		[self computeCurrentTargetingAngle];
				
		[self fireWeapons:targetDistance];
		
	}//if life > 0
			
	[self checkWeaponsCollision];
}

- (void)touchStart:(CGPoint)position
{
	[super touchStart:position];
	GLfloat obj[3] = {x, y, z};
	GLfloat win[3];
	slyGluProject(obj, win);
	/*NSLog(@"Bot %x", self);
	NSLog(@"Touch Position TRUE: (%f, %f)", position.x, position.y);
    NSLog(@"Bot GL position: (%f, %f, %f)", x, y, z);
	NSLog(@"Bot window position: (%f, %f, %f)", win[0], win[1], win[2]);*/
	if (fabs(position.x - win[0]) < 18 && fabs(position.y - win[1]) < 18)
	{
		[controller botTouched:self];
	}
	
	/*PathNode *aNode = [PathNode alloc];
	mapOglToGrid(x, y, aNode);
	if (fabs(position.x - win[0]) < 10 && fabs(position.y - win[1]) < 10)
		NSLog(@"in (i, j) = %d, %d", [aNode x], [aNode y]);
	[aNode release];*/
}

- (void)touchEnd
{
	[super touchEnd];
}

- (void)draw1
{
	glTranslatef(x, y, z);
	if (isBoss)
		glScalef(.4, .4, 1);
	else
		glScalef(.2, .2, 1);
	
	//draw the background when selecting
	if ([[controller theGame] gameMode] == GAME_MODE_SELECT)
	{	
		if ([controller currentPlayer] == player)
		{
			glPushMatrix();
			if (isBoss)
				glScalef(0.5, 0.5, 1);
            
            glEnable(GL_DEPTH_TEST);

			glColor4f([color red], [color green], [color blue], 0.6+0.15*sin([controller cycleNum]/4.0));
			GLDrawCircle(20, 1.1, true);

			glDisable(GL_DEPTH_TEST);
			
			glPopMatrix();
		}
	}
}

- (void)draw2
{
	if (life <= 0)
		return;

	glTranslatef(x, y, z);
	if (isBoss)
		glScalef(.4, .4, 1);
	else
		glScalef(.2, .2, 1);
	
	glPushMatrix();
	
	//draw the border when selecting
	if ([[controller theGame] gameMode] == GAME_MODE_SELECT)
	{	
		if ([controller currentPlayer] == player)
		{
			glPushMatrix();
			//glTranslatef(0, 0, -0.0011); //move the textures slightly behind so the depth buffer will mask them

			if (isBoss)
				glScalef(0.5, 0.5, 1);

			const GLfloat spriteVertices[] = {
				-.5,  -.5,
				-.5, .5,
				.5,  -.5,
				.5, .5,
			};
			
			// Sets up an array of values for the texture coordinates.
			const GLshort spriteTexcoords[] = {
				0, 0,
				1, 0,
				0, 1,
				1, 1,
			};
			
			glScalef(2.8, 2.8, 1);
			glColor4f(1, 1, 1, 1);
			
			glEnable(GL_DEPTH_TEST);
			glDepthMask(false);
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
			glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
			glBindTexture(GL_TEXTURE_2D, textureBotIdentifier);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisable(GL_TEXTURE_2D);
			glDepthMask(true);
			glDisable(GL_DEPTH_TEST);
/*
			glScalef(1.1, 1.1, 1);
			glColor4f([color red], [color green], [color blue], 0.6+0.15*sin([controller cycleNum]/4.0));
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
			glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
			glBindTexture(GL_TEXTURE_2D, textureBotIdentifierBg);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisable(GL_TEXTURE_2D);
*/			
			glPopMatrix();
		}
	}

	//angle
	glRotatef(currentTargetingAngle+45, 0, 0, -1);
	
	//drawing
	if (texture)
	{
		const GLfloat spriteVertices[] = {
			-.5,  -.5,
			-.5, .5,
			.5,  -.5,
			.5, .5,
		};
		
		// Sets up an array of values for the texture coordinates.
		const GLshort spriteTexcoords[] = {
			0, 0,
			1, 0,
			0, 1,
			1, 1,
		};
		
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
		glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
		
		float alpha = 1;
		if ([[controller botSelector] selectedBot] && [[controller botSelector] selectedBot] != self)
			alpha = .3;
		
		glColor4f([color red], [color green], [color blue], alpha);

		//texture the bot according to game mode, which player and type of bot
		if ([[controller theGame] gameMode] == GAME_MODE_BATTLE 
			|| [[controller theGame] gameMode] == GAME_MODE_BATTLE_FINISHED
			|| [[NSUserDefaults standardUserDefaults] boolForKey:@"showComputersOn"])
		{
			if (!isFatManBoss)
			{
				//base
				if (computer)
					glBindTexture(GL_TEXTURE_2D, textureBases[TEXTURE_BASE_COMPUTER]);
				else
					glBindTexture(GL_TEXTURE_2D, textureBases[baseTexture]);
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			}
		}
		else if ([[controller theGame] gameMode] == GAME_MODE_SELECT)
		{	
			
			//base
			if ([controller currentPlayer] != player)
			{
				if (isBoss)
					glScalef(0.5, 0.5, 1);
				
				glColor4f([color red], [color green], [color blue], 1.0/*0.4*/);
			}
			
			if (!isFatManBoss || [controller currentPlayer] != player)
			{
				if (computer)
					glBindTexture(GL_TEXTURE_2D, textureBases[TEXTURE_BASE_COMPUTER]);
				else
					glBindTexture(GL_TEXTURE_2D, textureBases[baseTexture]);
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			}
		}
		
		//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_TEXTURE_2D);
	}
	
	glPopMatrix();
}


- (void)draw3
{
	if (life <= 0)
		return;
	
	glTranslatef(x, y, z);
	
	if (isBoss)
		glScalef(.4, .4, 1);
	else
		glScalef(.2, .2, 1);
	
	//glScalef(.2, .2, 1);
	
	glPushMatrix();
	
	//angle
	glRotatef(currentTargetingAngle+45, 0, 0, -1);
	
	//drawing
	const GLfloat spriteVertices[] = {
		-.5,  -.5,
		-.5, .5,
		.5,  -.5,
		.5, .5,
	};
	
	// Sets up an array of values for the texture coordinates.
	const GLshort spriteTexcoords[] = {
		0, 0,
		1, 0,
		0, 1,
		1, 1,
	};
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
	
	//texture the bot according to game mode, which player and type of bot
	if ([[controller theGame] gameMode] == GAME_MODE_BATTLE 
		|| [[controller theGame] gameMode] == GAME_MODE_BATTLE_FINISHED
		|| [[NSUserDefaults standardUserDefaults] boolForKey:@"showComputersOn"])
	{
		//top
		glColor4f(1.0, 1.0, 1.0, 1.0);
		if (fireTimer < MAX_FIRE_TIME)
			glColor4f(1.0, .5+.4*fireTimer/MAX_FIRE_TIME, .5+.4*fireTimer/MAX_FIRE_TIME, 1.0);
		glTranslatef(0, 0, .001);
		if (isFatManBoss)
		{
			glColor4f([color red], [color green], [color blue], 1.0);
			if (computer)
			{
				glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot4);
			}
			else
			{
				switch(baseTexture)
				{
					case 0:
						glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot1);
						break;
					case 1:
						glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot2);
						break;
					case 2:
						glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot3);
						break;
				}
			}
		}
		else
		{
			glBindTexture(GL_TEXTURE_2D, texture);
		}
	}
	else if ([[controller theGame] gameMode] == GAME_MODE_SELECT)
	{	
		float alpha = 1;
		if ([[controller botSelector] selectedBot] && [[controller botSelector] selectedBot] != self)
			alpha = .3;

		//top
		glTranslatef(0, 0, .001);
		if ([controller currentPlayer] != player)
		{
			if (isBoss)
				glScalef(0.5, 0.5, 1);
			glColor4f(1.0, 1.0, 1.0, alpha);
			glBindTexture(GL_TEXTURE_2D, textureNormalBot);
		}
		else
		{
			if (isFatManBoss)
			{
				glColor4f([color red], [color green], [color blue], alpha);
				if (computer)
				{
					glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot4);
				}
				else
				{
					switch(baseTexture)
					{
						case 0:
							glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot1);
							break;
						case 1:
							glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot2);
							break;
						case 2:
							glBindTexture(GL_TEXTURE_2D, textureFatManMasterBot3);
							break;
					}
				}
			}
			else
			{
				glColor4f(1.0, 1.0, 1.0, alpha);
				glBindTexture(GL_TEXTURE_2D, texture);
			}
		}
	}
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	glPopMatrix();
	
	lifeBarTimer -= 0.02;
	shieldsTimer -= 0.04;
}

- (void)draw4
{
	if (life <= 0)
		return;
	
	glTranslatef(x, y, z);
	if (isBoss)
		glScalef(.4, .4, 1);
	else
		glScalef(.2, .2, 1);


	const GLfloat spriteVertices[] = {
		-.5,  -.5,
		-.5, .5,
		.5,  -.5,
		.5, .5,
	};
	
	// Sets up an array of values for the texture coordinates.
	const GLshort spriteTexcoords[] = {
		0, 0,
		1, 0,
		0, 1,
		1, 1,
	};
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
    
   
	//jamming indicator
	if ([[controller theGame] gameMode] == GAME_MODE_SELECT && [controller currentPlayer] == player)
	{
        float alpha = 1.0;
        if ([[controller botSelector] selectedBot] && [[controller botSelector] selectedBot] != self)
            alpha = .3;
        
        bool jamming = false;
		for (Attack *a in attackTypes)
		{
			if ([a attackType] == ATTACK_TYPE_JAMMER)
			{
				jamming = true;
				break;
			}
		}
		
		if (jamming)
		{
			glColor4f(1.0, 1.0, 1.0, alpha);
			glPushMatrix();
			glScalef(2.5, 2.5, 0.7);
			
			glBindTexture(GL_TEXTURE_2D, textureJammerWeapon);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glPopMatrix();
		}
	}
	
	//shields
	if (shields > 0)
	{	
		float shieldsAlpha = shields/SHIELDS_VAL_FOR_BOT((Bot *)self)+0.5;
        if (shieldsAlpha > 1) shieldsAlpha = 1;
        
        if ([[controller theGame] gameMode] == GAME_MODE_SELECT && [controller currentPlayer] == player)
        {
            float alpha = 1.0;
            if ([[controller botSelector] selectedBot] && [[controller botSelector] selectedBot] != self)
                alpha = .3;
            glColor4f(1.0, 1.0, 1.0, alpha);
        }
		else
			glColor4f(1.0, 1.0, 1.0, shieldsTimer*shieldsAlpha);
		
		glPushMatrix();
		glTranslatef(0, 0, .001);
		glScalef(1.3, 1.3, 1);
		glBindTexture(GL_TEXTURE_2D, shieldsTexture);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
	
	if (icyTimer < MAX_ICY_TIME)
	{	
		glColor4f(1.0, 1.0, 1.0, .7*(1-icyTimer/MAX_ICY_TIME));
		glPushMatrix();
		glTranslatef(0, 0, .01);
		glScalef(1.3, 1.3, 1);
		glBindTexture(GL_TEXTURE_2D, icyTexture);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}

	//draw the life bar
	if (life > 50)
		glColor4f(0.7*(100-life)/50.0f, 0.7, 0, lifeBarTimer);
	else
		glColor4f(0.7, 0.7*life/50.0f, 0, lifeBarTimer);
	
	glPushMatrix();
	glTranslatef(0, -0.6, 0);
	
	if (life >= 50)
	{
		glScalef(life/100.0f, 1, 1);
		glBindTexture(GL_TEXTURE_2D, textureLifeBar);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		glColor4f(1, 1, 1, lifeBarTimer/4);
		glScalef(.9, .5, 1);
		glTranslatef(0, 0.03, 0);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	else
	{
		glScalef(0.5+0.5*2*life/100.0f, 1, 1);
		glBindTexture(GL_TEXTURE_2D, textureLifeBarShort);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		glColor4f(1, 1, 1, lifeBarTimer/4);
		glScalef(.9, .5, 1);
		glTranslatef(0, 0.03, 0);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	glPopMatrix();

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);	
}

- (void)dealloc
{
	[name release];
	[path release];
	[attacksFired release];
	[attackTypes release];
	[super dealloc];
}

@end


//TJs update code
/*
PathNode *aNode = [PathNode alloc];
PathNode *bNode = [PathNode alloc];

//find target based on bots qualaties..

//  always our node.
mapOglToGrid(self.x, self.y, aNode);
// update path if necessary
if (cycleCount % 10 == selfIndex) //2 replaced with number of bots
{
	mapOglToGrid(target.x, target.y, bNode);
	findPath(aNode, bNode, path);
}
// update direction
computeForceVector(aNode, path, force);

if (sqrt(force->vector.x*force->vector.x+force->vector.y*force->vector.y) > MAX_ACCELERATION)
{
	Vector3D *norm = [Vector3D normalizeWithX:force->vector.x Y:force->vector.y Z:0];
	force->vector.x = norm->vector.x*MAX_ACCELERATION;
	force->vector.y = norm->vector.y*MAX_ACCELERATION;
	[norm release];
}

dx += -force->vector.x; 
dy += force->vector.y;

float maxS = 0.0001*maxSpeed;
 if (sqrt(dx*dx+dy*dy) > maxS)
 {
 Vector3D *norm = [Vector3D normalizeWithX:dx Y:dy Z:0];
 dx = norm->vector.x*maxS;
 dy = norm->vector.y*maxS;
 [norm release];
 }
 //if (fabs(dx) > 0.001*maxSpeed)
// dx = SIGN(dx)*0.001*maxSpeed;
// if (fabs(dy) > 0.001*maxSpeed)
// dy = SIGN(dy)*0.001*maxSpeed;

dx *= 0.99;
dy *= 0.99;


self.x += dx;
self.y += dy;

//NSLog(@"dx, dy  = %f, %f", dx, dy);
cycleCount++;
[aNode release];
[bNode release];
*/
