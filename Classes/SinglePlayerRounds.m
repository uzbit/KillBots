//
//  SinglePlayerRounds.m
//  AiWars
//
//  Created by Ted McCormack on 5/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SinglePlayerRounds.h"
#import "Player.h"
#import "Bot.h"
#import "AiWarsViewController.h"
#import "BotSelectorViewController.h" // for bot styles
#import "Weapons.h"

@implementation ConfigurationObject

@synthesize shields, jamming;
@synthesize movementType, botType, cost;
@synthesize x, y, z;

- (id)initWithX:(float)X Y:(float)Y Z:(float)Z MT:(int)mt BT:(int)bt CT:(int)ct SH:(bool)sh JA:(bool)ja;
{
	if ((self = [super init]))
	{
		x = X;
		y = Y;
		z = Z;
		shields = sh;
		jamming = ja;
		movementType = mt;
		botType = bt;
		cost = ct;
	}
	return self;
}
@end


@implementation SinglePlayerRounds

@synthesize wonLastRound;

@synthesize aiWarsViewController;
@synthesize storyLineViewController;
@synthesize configuration;

- (id)init
{
	if ((self = [super init]))
	{
		storyLineViewController = [[StoryLineViewController alloc] initWithNibName:@"StoryLine" bundle:nil];
		[storyLineViewController setHasSelected:false];
		configuration = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}

- (void)addBotWithX:(float)X Y:(float)Y Player:(int)player botType:(int)botType botMovement:(MovementType)botMovement shields:(bool)shields jamming:(bool)jamming
{
	if (player >= [[[aiWarsViewController theGame] players] count])
		return; 
	
	Bot *bot = [[[[aiWarsViewController botSelector] botTypes] objectAtIndex:botType] copy];
	[bot setType:botType];
	[bot setX:X Y:Y Z:-1.8];
	[bot setColor:[[[[aiWarsViewController theGame] players] objectAtIndex:player] color]];
	[bot setBaseTexture:[[[[aiWarsViewController theGame] players] objectAtIndex:player] baseTexture]];
	[bot setController:aiWarsViewController];
	[bot setCurrentMovement:botMovement];
	if (shields)
		[bot setShields:100.0];
	if (jamming)
	{
		Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
		[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];
		[[bot attackTypes] addObject:jammer];
		[jammer release];
	}
 	[aiWarsViewController addBot:bot forPlayer:player];
	[bot release];
}

- (bool)setupRound:(int)round
{
	NSMutableArray *players = [[aiWarsViewController theGame] players];
	float fundsAfterBot;
	
	//remove all players
	[players removeAllObjects];
	
	//remove all human player bots
	[[[aiWarsViewController singlePlayerHuman] bots] removeAllObjects];
	
	//add our human player
	[players addObject:[aiWarsViewController singlePlayerHuman]];
	
	//lite version
	if (liteVersion && round > 5)
		return false;		
	
	switch (round)
	{
		case 1:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:2]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[players addObject:enemy1];
			
			//only do it like this for round 1
			for (Player *p in players)
			{
				[p setRoundsWon:0];
				[p setBotsKilled:0];
				[p setBotsKilledThisRound:0];
				[p setBotsDestroyed:0];
			}
			
			//set the human player funds
			[[players objectAtIndex:0] setSurplus:0];
			[[players objectAtIndex:0] setFunds:1000];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.5 Y:0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.5 Y:-0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.5 Y:0.5 Player:1 botType:BOT_TYPE_QUICKIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.5 Y:-0.5 Player:1 botType:BOT_TYPE_DUAL_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Death Valley"];
			[[storyLineViewController storyLine] setText:@""];
		
			[enemy1 release];
			break;
		}
		case 2:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:7]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:4500+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.6 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:0.0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:-0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.6 Y:0.4 Player:1 botType:BOT_TYPE_SHOTTIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.6 Y:0.0 Player:1 botType:BOT_TYPE_MISSILE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:true];
			[self addBotWithX:0.6 Y:-0.4 Player:1 botType:BOT_TYPE_SHOTTIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The Pacific Coast"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 3:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:9]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:9000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.7 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.7 Y:0.6 Player:1 botType:BOT_TYPE_MISSILE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.7 Y:0.2 Player:1 botType:BOT_TYPE_RAMMER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:true];
			[self addBotWithX:0.7 Y:-0.2 Player:1 botType:BOT_TYPE_RAMMER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:true];
			[self addBotWithX:0.7 Y:-0.6 Player:1 botType:BOT_TYPE_MISSILE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
		
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The North"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 4:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:11]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:18000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.7 Y:0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:-0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.0 Y:0.6 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.0 Y:0.2 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.0 Y:-0.2 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.0 Y:-0.6 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Lake Winnipeg"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 5:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:12]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:24000+[[players objectAtIndex:0] surplus]];
		
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.6 Y:0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.9 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.3 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:-0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.5 Y:0.5 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.8 Y:0.0 Player:1 botType:BOT_TYPE_BOSS_1_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:false];
			[self addBotWithX:0.5 Y:-0.5 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The Glaciers of Greenland"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}	
		case 6:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:13]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:32000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{	
				[self addBotWithX:-0.2 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.5 Y:0.5 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:-0.5 Y:-0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.5 Y:0.5 Player:1 botType:BOT_TYPE_LASER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.5 Y:-0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Transatlantic Battle of the Death"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}			
		case 7:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:6]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:40000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:0.0 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0 Y:0.7 Player:1 botType:BOT_TYPE_MASS_DRIVER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:-0.6 Y:-0.6 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:false];
			[self addBotWithX:0.6 Y:-0.6 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Aye, Scotland!"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 8:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:5]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:60000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.8 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.8 Y:0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.8 Y:0.0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.8 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:1.0 Y:0.9 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:1.0 Y:0.6 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:1.0 Y:0.3 Player:1 botType:BOT_TYPE_MASS_DRIVER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:false jamming:false];
			[self addBotWithX:1.0 Y:0.0 Player:1 botType:BOT_TYPE_MASS_DRIVER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:1.0 Y:-0.3 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:1.0 Y:-0.6 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Chernobyl"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 9:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:10]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:80000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.2 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0 Y:0.7 Player:1 botType:BOT_TYPE_FLAMETHROWER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.5 Y:0.5 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:0.5 Y:-0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:false jamming:false];
			[self addBotWithX:-0.5 Y:-0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:-0.5 Y:0.5 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:0 Y:-0.7 Player:1 botType:BOT_TYPE_FLAMETHROWER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"On the Beach in the Middle East"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 10:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:8]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Boss"];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:90000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.9 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.3 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.9 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:0.9 Y:0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.5 Y:0.0 Player:1 botType:BOT_TYPE_DUAL_MISSILE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:true];
			[self addBotWithX:0.9 Y:0.0 Player:1 botType:BOT_TYPE_BOSS_2_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY shields:true jamming:true];
			[self addBotWithX:0.9 Y:-0.5 Player:1 botType:BOT_TYPE_SEEKER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Moscow"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 11:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:15]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:125000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.7 Y:0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:-0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.4 Y:0.2 Player:1 botType:BOT_TYPE_ICY_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.0 Y:0.2 Player:1 botType:BOT_TYPE_MASS_DRIVER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:0.4 Y:0.2 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:false jamming:false];
			[self addBotWithX:-0.4 Y:-0.2 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.0 Y:-0.2 Player:1 botType:BOT_TYPE_MINE_LAYER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:false];
			[self addBotWithX:0.4 Y:-0.2 Player:1 botType:BOT_TYPE_ICY_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The Cold"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 12:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:16]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:175000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.7 Y:0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:-0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.7 Y:0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:-1.0 Y:-0.4 Player:1 botType:BOT_TYPE_FLAMETHROWER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:-0.4 Y:-0.4 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:false jamming:false];
			[self addBotWithX:0.4 Y:-0.4 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.7 Y:0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:1.0 Y:-0.4 Player:1 botType:BOT_TYPE_ICY_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The China"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 13:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:17]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:250000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.15 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.15 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0 Y:-0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.2 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.2 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.15 Y:0.6 Player:1 botType:BOT_TYPE_KAMIKAZE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.15 Y:0.6 Player:1 botType:BOT_TYPE_KAMIKAZE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:0 Y:0.4 Player:1 botType:BOT_TYPE_LIGHTNING_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:false];
			[self addBotWithX:-0.2 Y:0.9 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.2 Y:0.9 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Down Under"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 14:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:3]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:275000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.7 Y:0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.7 Y:-0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.7 Y:-0.1 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.7 Y:0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:-1.0 Y:-0.4 Player:1 botType:BOT_TYPE_FLAMETHROWER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:false jamming:false];
			[self addBotWithX:-0.4 Y:-0.4 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND shields:false jamming:false];
			[self addBotWithX:0.4 Y:-0.4 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.7 Y:0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:1.0 Y:-0.4 Player:1 botType:BOT_TYPE_ICY_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The Colder"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 15:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:8]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Boss"];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:300000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.9 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.6 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.9 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:1.2 Y:0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.5 Y:0.0 Player:1 botType:BOT_TYPE_DUAL_MISSILE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:true];
			[self addBotWithX:0.9 Y:0.0 Player:1 botType:BOT_TYPE_BOSS_3_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:1.2 Y:-0.5 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The South"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 16:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:1]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:350000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.4 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.4 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.8 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.8 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.9 Y:0.3 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.9 Y:0.3 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0 Y:0.7 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0 Y:0.0 Player:1 botType:BOT_TYPE_LIGHTNING_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:-0.8 Y:-0.7 Player:1 botType:BOT_TYPE_ICY_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.8 Y:-0.7 Player:1 botType:BOT_TYPE_FLAMETHROWER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"The Amazon"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 17:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:4]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:400000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.9 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.9 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0 Y:0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.5 Y:-0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.5 Y:-0.7 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.2 Y:0.2 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.2 Y:0.2 Player:1 botType:BOT_TYPE_LIGHTNING_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.0 Y:0.0 Player:1 botType:BOT_TYPE_DEATH_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:true];
			[self addBotWithX:-0.2 Y:-0.2 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.2 Y:-0.2 Player:1 botType:BOT_TYPE_PLASMA_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Mexican Mud"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 18:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:8]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:500000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-0.6 Y:0.8 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-0.8 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-1.0 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.6 Y:0.8 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.8 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:1.0 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.3 Y:-0.1 Player:1 botType:BOT_TYPE_DUAL_SEEKER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.3 Y:-0.1 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0 Y:-0.1 Player:1 botType:BOT_TYPE_FATMAN_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:false jamming:true];
			[self addBotWithX:-0.1 Y:0.1 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.1 Y:0.1 Player:1 botType:BOT_TYPE_DUAL_SEEKER_TIER_3 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Volcanic Remains"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 19:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:15]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:750000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:-1.2 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-1.2 Y:0.0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:-1.2 Y:-0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:1.2 Y:0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:1.2 Y:0.0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:1.2 Y:-0.4 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-0.3 Y:-0.3 Player:1 botType:BOT_TYPE_DEATH_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:0.3 Y:-0.3 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:true];
			[self addBotWithX:0 Y:0.7 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:0 Y:0.0 Player:1 botType:BOT_TYPE_FATMAN_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:0 Y:-0.7 Player:1 botType:BOT_TYPE_DUAL_LASER_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:-0.3 Y:0.3 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND shields:true jamming:true];
			[self addBotWithX:0.3 Y:0.3 Player:1 botType:BOT_TYPE_LIGHTNING_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Manhattan"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		case 20:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:17]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Boss"];
			[players addObject:enemy1];
			
			for (Player *p in players)
				[p setBotsKilledThisRound:0];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			//else
			//	[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:1000000+[[players objectAtIndex:0] surplus]];
			
			//initialize bots
			//human player
			if (wonLastRound || [configuration count] == 0)
			{
				[self addBotWithX:0.9 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.6 Y:0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.6 Y:0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.6 Y:-0.3 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[self addBotWithX:0.9 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			}
			else
				for (ConfigurationObject *c in configuration)
				{
					fundsAfterBot = [[players objectAtIndex:0] funds]
					- [c cost] 
					- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
					- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
					if (fundsAfterBot >= 0)
					{
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
						[[players objectAtIndex:0] setFunds:fundsAfterBot];
					}
					else
						[self addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
				}
			
			//computer player 1
			[self addBotWithX:-1.3 Y:0.5 Player:1 botType:BOT_TYPE_BOSS_1_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			[self addBotWithX:-0.7 Y:0.0 Player:1 botType:BOT_TYPE_KAMIKAZE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:-0.7 Y:0.5 Player:1 botType:BOT_TYPE_DUAL_PLASMA_TIER_4 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:1.2 Y:0 Player:1 botType:BOT_TYPE_KAMIKAZE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
			[self addBotWithX:-0.7 Y:-0.5 Player:1 botType:BOT_TYPE_KAMIKAZE_TIER_2 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:-1.0 Y:0.0 Player:1 botType:BOT_TYPE_BOSS_4_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:true];
			[self addBotWithX:-1.3 Y:-0.5 Player:1 botType:BOT_TYPE_BOSS_1_TIER_5 botMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY shields:true jamming:false];
			
			//set the story line
			[[storyLineViewController roundLevel] setText:[NSString stringWithFormat:@"Level %i", round]];
			[[storyLineViewController titleLabel] setText:@"Moon Base"];
			[[storyLineViewController storyLine] setText:@""];
			
			[enemy1 release];
			break;
		}
		/*case 8:
		{
			unloadTexture(&textureBackground);
			loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round-1], &textureBackground);
			
			//setup enemies
			Player *enemy1 = [[Player alloc] init];
			[enemy1 setColor:[[aiWarsViewController colors] objectAtIndex:5]];
			[enemy1 setIsComputer:0];
			[enemy1 setName:@"Tard"];
			[enemy1 setRoundsWon:0];
			[enemy1 setBotsKilled:0];
			[enemy1 setBotsKilledThisRound:0];
			[enemy1 setBotsDestroyed:0];
			[players addObject:enemy1];
			
			//initialize bots
			//human player
			[self addBotWithX:-0.5 Y:0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:-0.5 Y:0.0 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:-0.5 Y:-0.5 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//computer player 1
			[self addBotWithX:0.5 Y:0.5 Player:1 botType:BOT_TYPE_QUICKIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			[self addBotWithX:0.5 Y:0.0 Player:1 botType:BOT_TYPE_SHOTTIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
			[self addBotWithX:0.5 Y:-0.5 Player:1 botType:BOT_TYPE_QUICKIE_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
			
			//set the story line
			[[storyLineViewController titleLable] setText:@"Title"];
			[[storyLineViewController storyLine] setText:@"This is not a simple level."];
			
			//set the human player funds
			if (wonLastRound)
				[[players objectAtIndex:0] setSurplus:[[players objectAtIndex:0] funds]];
			else
				[[players objectAtIndex:0] setSurplus:0];
			
			[[players objectAtIndex:0] setFunds:2000];//+[[players objectAtIndex:0] surplus]];
			
			[enemy1 release];
			break;
			
		}*/	
						
		default:
			return false;
	}
	return true;
}

- (void)dealloc 
{
	[storyLineViewController release];
	[configuration release];
    [super dealloc];
}

@end
