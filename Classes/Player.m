//
//  Player.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/22/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Player.h"
#import "Bot.h"

@implementation Player

@synthesize name;
@synthesize description;
@synthesize color;
@synthesize baseTexture;
@synthesize bots;
@synthesize botsKilled, botsKilledThisRound, botsDestroyed, surplus;
@synthesize funds;
@synthesize roundsWon;
@synthesize isComputer;
@synthesize score;

- (void)setFunds:(int)f
{
	if (f > 1999999999 || f < 0)
		funds =  1999999999;
	else
		funds = f;
}
	
- (id)init
{
    if (self = [super init])
	{
		name = [[NSString alloc] init];
		description = [[NSString alloc] init];
		
		//setup bots
		bots = [[NSMutableArray alloc] initWithCapacity:1];
		roundsWon = 0;
		botsKilled = 0;
		botsKilledThisRound = 0;
		botsDestroyed = 0;
		isComputer = -1;
		surplus = 0;
		score = 0;
		//funds = 1000;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Player *player = [[Player alloc] init];
	[player setName:[self name]];
	[player setDescription:[self description]];
	[player setColor:[self color]];
	[player setBaseTexture:[self baseTexture]];
	[player setBotsKilled:[self botsKilled]];
	[player setBotsKilledThisRound:[self botsKilledThisRound]];
	[player setBotsDestroyed:[self botsDestroyed]];
	[player setFunds:[self funds]];
	[player setSurplus:[self surplus]];
	[player setScore:[self score]];
	[player setRoundsWon:[self roundsWon]];
	[player setIsComputer:[self isComputer]];
	
	[[player bots] release];
	[player setBots:nil];
	[player setBots:[[[NSMutableArray alloc] initWithCapacity:[[self bots] count]] retain]];
	
	for (Bot *b in [self bots])
	{
		[[player bots] addObject:[b copy]];
	}
	return player;
}


- (void)autoConfigureBots
{
	
}

- (void)dealloc
{
	[name release];
	[description release];
	[bots release];
	//[color release];
    [super dealloc];
}

@end
