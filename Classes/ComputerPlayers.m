//
//  ComputerPlayers.m
//  AiWars
//
//  Created by Ted McCormack on 6/10/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "ComputerPlayers.h"
#import "Color.h"
#import "Types.h"
#import "Bot.h"
#import "AiWarsViewController.h"
#import "BotSelectorViewController.h"
#import "Weapons.h"

@implementation ComputerPlayer1

- (id)initWithColor:(Color *)c
{
	if ((self = [super init]))
	{
		name = @"UberTard";
		description = @"This computer moves chaotically, picks random weapons that it can afford and cant figure out shields or jamming.";
		isComputer = 0;
		baseTexture = 0;
		color = c;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	ComputerPlayer1 *player = [[ComputerPlayer1 alloc] initWithColor:color];//NSCopyObject(self, 0, zone);
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
	return player;
}

- (void)autoConfigureBots //must be called AFTER bots added to players bots array.
{
	AiWarsViewController *controller = [[bots objectAtIndex:0] controller];
	//NSLog(@"UberTard funds before: %d", funds);
	int highestBotAvaliable = 0;
	for (Bot *b in bots)
	{
		for (highestBotAvaliable = 0; highestBotAvaliable < [[[controller botSelector] botTypes] count]; highestBotAvaliable++)
			if (funds < [[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable] cost])
			{
				highestBotAvaliable--;
				break;
			}
		
		if (highestBotAvaliable < 0)
			highestBotAvaliable = 0;
		if (highestBotAvaliable == [[[controller botSelector] botTypes] count])
			highestBotAvaliable --;
		
		[controller copyBot:b fromBot:[[[[controller botSelector] botTypes] objectAtIndex:random()%highestBotAvaliable] copy]]; 
		[b setCurrentMovement:MOVEMENT_TYPE_RANDOM];
		
		funds -= [b cost];
	}
	//NSLog(@"UberTard funds after: %d", funds);
}

@end

@implementation ComputerPlayer2 

- (id)initWithColor:(Color *)c
{
	if ((self = [super init]))
	{
		name = @"Tard";
		description = @"This computer chooses random movement types, picks better weapons, no shields or jamming.";
		isComputer = 1;
		baseTexture = 1;
		color = c;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	ComputerPlayer2 *player = [[ComputerPlayer2 alloc] initWithColor:color];//NSCopyObject(self, 0, zone);
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
	return player;
}

- (void)autoConfigureBots //must be called AFTER bots added to players bots array.
{
	AiWarsViewController *controller = [[bots objectAtIndex:0] controller];
	
	int highestBotAvaliable = 0;
	for (Bot *b in bots)
	{
		for (highestBotAvaliable = 0; highestBotAvaliable < [[[controller botSelector] botTypes] count]; highestBotAvaliable++)
			if (funds < [[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable] cost])
			{
				highestBotAvaliable--;
				break;
			}
	
		if (highestBotAvaliable < 0)
			highestBotAvaliable = 0;
		if (highestBotAvaliable == [[[controller botSelector] botTypes] count])
			highestBotAvaliable --;
		
		int randVal = random()%((highestBotAvaliable < 2)?1:(int)(highestBotAvaliable/2.0)); 
		[controller copyBot:b fromBot:[[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable-randVal] copy]]; 
		[b setCurrentMovement:(random()%MOVEMENT_TYPE_NUM)+1];
		
		funds -= [b cost];
	}
	//NSLog(@"Tard funds after: %d", funds);
}

@end

@implementation ComputerPlayer3

- (id)initWithColor:(Color *)c
{
	if ((self = [super init]))
	{
		name = @"Alpha";
		description = @"Attacks closest enemies, can sometimes figure out shields and jamming.";
		isComputer = 2;
		baseTexture = 0;
		color = c;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	ComputerPlayer3 *player = [[ComputerPlayer3 alloc] initWithColor:color];//NSCopyObject(self, 0, zone);
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
	return player;
}

- (void)autoConfigureBots //must be called AFTER bots added to players bots array.
{
	AiWarsViewController *controller = [[bots objectAtIndex:0] controller];
	
	//NSLog(@"Alpha funds before: %d", funds);
	
	int highestBotAvaliable = 0;
	for (Bot *b in bots)
	{
		for (highestBotAvaliable = 0; highestBotAvaliable < [[[controller botSelector] botTypes] count]; highestBotAvaliable++)
			if (funds < [[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable] cost])
			{
				highestBotAvaliable--;
				break;
			}
		
		if (highestBotAvaliable < 0)
			highestBotAvaliable = 0;
		if (highestBotAvaliable >= [[[controller botSelector] botTypes] count])
			highestBotAvaliable = [[[controller botSelector] botTypes] count]-1;
		
		int randVal = random()%((highestBotAvaliable < 2)?1:(int)(highestBotAvaliable/2.0)); 
		[controller copyBot:b fromBot:[[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable-randVal] copy]]; 
		
		if ((highestBotAvaliable-randVal) == BOT_TYPE_RAMMER_TIER_1 
			|| (highestBotAvaliable-randVal) == BOT_TYPE_KAMIKAZE_TIER_2)
			[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY];
		else
			[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY];
		
		funds -= [b cost];
		
		if (random()%3 == 0)
		{
			if (funds - [[controller botSelector] shieldsCostForBot:b orWithIndex:-1] >= 0
				&& [controller shieldsOn])
			{
				[b setShields:SHIELDS_VAL_FOR_BOT(b)];//100.0];
				funds -= [[controller botSelector] shieldsCostForBot:b orWithIndex:-1]; 
			}
			if (funds - [[controller botSelector] jammerCostForBot:b orWithIndex:-1] >= 0
				&& [controller jammingOn])
			{
				Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
				[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];
				[[b attackTypes] addObject:jammer];
				[jammer release];
				funds -= [[controller botSelector] jammerCostForBot:b orWithIndex:-1];
			}
		}
		
	}
	//NSLog(@"Alpha funds after: %d", funds);
}

@end

@implementation ComputerPlayer4

- (id)initWithColor:(Color *)c
{
	if ((self = [super init]))
	{
		name = @"Beta";
		description = @"This computer makes wiser movement choices, can figure out shields and jamming.";
		isComputer = 3;
		baseTexture = 2;
		color = c;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	ComputerPlayer4 *player = [[ComputerPlayer4 alloc] initWithColor:color];//NSCopyObject(self, 0, zone);
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
	[player setBots:[[NSMutableArray alloc] initWithCapacity:[[self bots] count]]];
	return player;
}

- (void)autoConfigureBots //must be called AFTER bots added to players bots array.
{
	AiWarsViewController *controller = [[bots objectAtIndex:0] controller];
	//NSLog(@"Beta funds before: %d", funds);

	int highestBotAvaliable = 0, highestBotAvaliableWithShields = 0;
	for (Bot *b in bots)
	{
		for (highestBotAvaliable = 0; highestBotAvaliable < [[[controller botSelector] botTypes] count]; highestBotAvaliable++)
			if (funds < [[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable] cost])
			{
				highestBotAvaliable--;
				break;
			}
		
		for (highestBotAvaliableWithShields = 0; highestBotAvaliableWithShields < [[[controller botSelector] botTypes] count]; highestBotAvaliableWithShields++)
		{	
			Bot *b = [[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliableWithShields]; 
			if (funds < ([b cost]+[[controller botSelector] shieldsCostForBot:b orWithIndex:-1]))
			{
				highestBotAvaliableWithShields--;
				break;
			}
		}
		
		if (highestBotAvaliable < 0)
			highestBotAvaliable = 0;
		if (highestBotAvaliable >= [[[controller botSelector] botTypes] count])
			highestBotAvaliable = [[[controller botSelector] botTypes] count]-1;
		
		if (highestBotAvaliableWithShields < 0)
			highestBotAvaliableWithShields = 0;
		if (highestBotAvaliableWithShields >= [[[controller botSelector] botTypes] count])
			highestBotAvaliableWithShields = [[[controller botSelector] botTypes] count]-1;
		
		if (highestBotAvaliableWithShields == BOT_TYPE_KAMIKAZE_TIER_2)
			highestBotAvaliableWithShields --;
		
		if (![controller shieldsOn])
			highestBotAvaliableWithShields = highestBotAvaliable;
		
		int choice;
		
		if (random()%3 == 0)
			choice = highestBotAvaliable - random()%((highestBotAvaliable < 2)?1:(int)(highestBotAvaliable/2.0));
		else
			choice = highestBotAvaliableWithShields - random()%((highestBotAvaliableWithShields < 2)?1:(int)(highestBotAvaliableWithShields/2.0));
		
		[controller copyBot:b fromBot:[[[[controller botSelector] botTypes] objectAtIndex:choice] copy]]; 
		
		[b setCurrentMovement:((random()%2==0)?MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY:MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY)];
		
		funds -= [b cost];
		
		if (funds - [[controller botSelector] shieldsCostForBot:b orWithIndex:-1] >= 0 
			&& choice == highestBotAvaliableWithShields 
			&& [controller shieldsOn])
		{
			[b setShields:SHIELDS_VAL_FOR_BOT(b)];
			funds -= [[controller botSelector] shieldsCostForBot:b orWithIndex:-1]; 
		}
		if (funds - [[controller botSelector] jammerCostForBot:b orWithIndex:-1] >= 0 
			&& choice < BOT_TYPE_DUAL_PLASMA_TIER_4
			&& [controller jammingOn])
		{
			Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
			[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];
			[[b attackTypes] addObject:jammer];
			[jammer release];
			funds -= [[controller botSelector] jammerCostForBot:b orWithIndex:-1];
		}
	}
	//NSLog(@"Beta funds after: %d", funds);
}


@end

@implementation ComputerPlayer5

- (id)initWithColor:(Color *)c
{
	if ((self = [super init]))
	{
		name = @"Omega";
		description = @"This computer is the omega.";
		isComputer = 4;
		baseTexture = 1;
		color = c;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	ComputerPlayer5 *player = [[ComputerPlayer5 alloc] initWithColor:color];//NSCopyObject(self, 0, zone);
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

- (void)autoConfigureBots //must be called AFTER bots added to players bots array.
{
	AiWarsViewController *controller = [[bots objectAtIndex:0] controller];
	
	//NSLog(@"Omega funds before: %d", funds);
	
	int highestBotAvaliable = 0, highestBotAvaliableWithShields = 0, count = 0;
	bool hasSuicide = false;
	for (Bot *b in bots)
	{
		count++;
		
		for (highestBotAvaliable = 0; highestBotAvaliable < [[[controller botSelector] botTypes] count]; highestBotAvaliable++)
			if (funds < [[[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliable] cost])
			{
				highestBotAvaliable --;
				break;
			}
		
		for (highestBotAvaliableWithShields = 0; highestBotAvaliableWithShields < [[[controller botSelector] botTypes] count]; highestBotAvaliableWithShields++)
		{	
			Bot *b = [[[controller botSelector] botTypes] objectAtIndex:highestBotAvaliableWithShields]; 
			if (funds < ([b cost]+[[controller botSelector] shieldsCostForBot:b orWithIndex:-1]))
			{
				highestBotAvaliableWithShields --;
				break;
			}
		}
		
		if (highestBotAvaliable < 0)
			highestBotAvaliable = 0;
		if (highestBotAvaliable >= [[[controller botSelector] botTypes] count])
			highestBotAvaliable = [[[controller botSelector] botTypes] count]-1;
		
		if (highestBotAvaliableWithShields < 0)
			highestBotAvaliableWithShields = 0;
		if (highestBotAvaliableWithShields >= [[[controller botSelector] botTypes] count])
			highestBotAvaliableWithShields = [[[controller botSelector] botTypes] count]-1;;
		
		if (![controller shieldsOn])
			highestBotAvaliableWithShields = highestBotAvaliable;
		
		int choice = 0;
		if (random()%2 == 0 || count < 3)
			choice = highestBotAvaliable - random()%((highestBotAvaliable < 2)?1:(int)(highestBotAvaliable/2.0));
		else
			choice = highestBotAvaliableWithShields - random()%((highestBotAvaliableWithShields < 2)?1:(int)(highestBotAvaliableWithShields/2.0));
		
		if (count == [bots count])
			choice = highestBotAvaliable;
		
		if ((choice == BOT_TYPE_KAMIKAZE_TIER_2 && hasSuicide) || (choice == BOT_TYPE_KAMIKAZE_TIER_2 && !hasSuicide && highestBotAvaliable < BOT_TYPE_MASS_DRIVER_TIER_2) )
			choice = ((highestBotAvaliable == BOT_TYPE_KAMIKAZE_TIER_2)?highestBotAvaliableWithShields:highestBotAvaliable);
		else if (highestBotAvaliable >= BOT_TYPE_MASS_DRIVER_TIER_2 && !hasSuicide && [bots count] >= 5)
		{
			choice = BOT_TYPE_KAMIKAZE_TIER_2;
			hasSuicide = true;
		}
		
		if (choice == BOT_TYPE_FLAMETHROWER_TIER_3)
			if (slyRandom(0, 1) < 0.7)
				choice = BOT_TYPE_ICY_TIER_3;
		
		[controller copyBot:b fromBot:[[[[controller botSelector] botTypes] objectAtIndex:choice] copy]]; 
		funds -= [b cost];

		bool hasShields = false, hasJamming = false;
		if (funds - [[controller botSelector] shieldsCostForBot:b orWithIndex:-1] >= 0
			&& [controller shieldsOn])
		{
			if ((funds - [[controller botSelector] shieldsCostForBot:b orWithIndex:-1] >= 15*[b cost] && choice == BOT_TYPE_KAMIKAZE_TIER_2) || choice != BOT_TYPE_KAMIKAZE_TIER_2)
			{
				[b setShields:SHIELDS_VAL_FOR_BOT(b)];//100.0];
				funds -= [[controller botSelector] shieldsCostForBot:b orWithIndex:-1];
				hasShields = true;
			}
		}
		if (funds - [[controller botSelector] jammerCostForBot:b orWithIndex:-1] >= 0 
			&& ([b effectiveRange] <= 2.0 || count > [bots count]-2)
			&& [controller jammingOn] 
			&& choice != BOT_TYPE_KAMIKAZE_TIER_2)
		{
			Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
			[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];
			[[b attackTypes] addObject:jammer];
			[jammer release];
			funds -= [[controller botSelector] jammerCostForBot:b orWithIndex:-1];
			hasJamming = true;
		}
		//NSLog(@"%d, %d, %d, %d",funds, choice, hasShields, hasJamming);
		switch (choice)
		{
			case BOT_TYPE_SINGLE_SHOOTER_TIER_1:
			case BOT_TYPE_DUAL_SHOOTER_TIER_1:
			case BOT_TYPE_QUICKIE_TIER_1:
			case BOT_TYPE_SHOTTIE_TIER_1:
				if (hasJamming)
					[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY];
				else
					[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND];
				break;
			case BOT_TYPE_LASER_TIER_1:
			case BOT_TYPE_DUAL_LASER_TIER_2:
			case BOT_TYPE_PLASMA_TIER_3:
				[b setCurrentMovement:((random()%3==0)?MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY:MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY)];
				break;
			case BOT_TYPE_MINE_LAYER_TIER_2:
				[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND];
				break;
			case BOT_TYPE_RAMMER_TIER_1:
			case BOT_TYPE_KAMIKAZE_TIER_2:
				[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY];
				break;
			default:
				[b setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY];				
		}
	}
	//NSLog(@"Omega funds after: %d", funds);
}
@end

@implementation ComputerPlayer6
@end

@implementation ComputerPlayer7
@end

@implementation ComputerPlayer8 
@end

@implementation ComputerPlayer9 
@end

@implementation ComputerPlayer10
@end
