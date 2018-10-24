//
//  SinglePlayerRounds.m
//  AiWars
//
//  Created by Ted McCormack on 5/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "BonusLevelRounds.h"
#import "AiWarsViewController.h"
#import "Color.h"

@implementation BonusLevelRounds

@synthesize aiWarsViewController;
@synthesize singlePlayerRounds;
@synthesize configuration;

- (id)init
{
	if ((self = [super init]))
	{
		configuration = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}

- (void)addBotWithX:(float)X Y:(float)Y Player:(int)player botType:(int)botType botMovement:(MovementType)botMovement shields:(bool)shields jamming:(bool)jamming
{
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
	
	//setup enemy
	Player *enemy = [[Player alloc] init];
	[enemy setColor:[[aiWarsViewController colors] objectAtIndex:round%COLOR_NUM]];
	[enemy setIsComputer:0];
	[enemy setName:@"Tard"];
	[players addObject:enemy];

	//remove the current background
	unloadTexture(&textureBackground);
	loadPVRTexture([[aiWarsViewController backgroundFiles] objectAtIndex:round%20], &textureBackground);

	if (round >= 1 && round <= 20)
	{
		switch (round)
		{
			case 1:
			default:
			{			
				//find the bot type of the bonus level
				int botType = round%21;
				int botCost = [[[[aiWarsViewController botSelector] botTypes] objectAtIndex:botType] cost];
				
				//set the human player funds
				[[players objectAtIndex:0] setFunds:50*ceil((1200+botCost*7*(1-(float)round/40.0))/50)];
				
				//initialize bots
				//human player
				if ([configuration count] == 0)
				{
					[singlePlayerRounds addBotWithX:-0.7 Y:0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
					[singlePlayerRounds addBotWithX:-0.7 Y:0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
					[singlePlayerRounds addBotWithX:-0.7 Y:-0.2 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
					[singlePlayerRounds addBotWithX:-0.7 Y:-0.6 Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				}
				else
				{
					for (ConfigurationObject *c in configuration)
					{
						fundsAfterBot = [[players objectAtIndex:0] funds]
						- [c cost] 
						- ([c shields]?[[aiWarsViewController botSelector] shieldsCostForBot:nil orWithIndex:[c botType]]:0)
						- ([c jamming]?[[aiWarsViewController botSelector] jammerCostForBot:nil orWithIndex:[c botType]]:0);
						if (fundsAfterBot >= 0)
						{
							[singlePlayerRounds addBotWithX:[c x] Y:[c y] Player:0 botType:[c botType] botMovement:[c movementType] shields:[c shields] jamming:[c jamming]];
							[[players objectAtIndex:0] setFunds:fundsAfterBot];
						}
						else
							[singlePlayerRounds addBotWithX:[c x] Y:[c y] Player:0 botType:BOT_TYPE_SINGLE_SHOOTER_TIER_1 botMovement:[c movementType] shields:false jamming:false];
					}
				}
				
				//enemy
				[singlePlayerRounds addBotWithX:0.7 Y:0.6 Player:1 botType:botType botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:false];
				[singlePlayerRounds addBotWithX:0.7 Y:0.2 Player:1 botType:botType botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:false];
				[singlePlayerRounds addBotWithX:0.7 Y:-0.2 Player:1 botType:botType botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:false jamming:true];
				[singlePlayerRounds addBotWithX:0.7 Y:-0.6 Player:1 botType:botType botMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY shields:true jamming:true];
				break;
			}
		}
	}
	[enemy release];
	return true;
}

- (void)dealloc 
{
	[configuration release];
    [super dealloc];
}

@end
