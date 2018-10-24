//
//  SimulationObject.m
//  AiWars
//
//  Created by Ted McCormack on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SimulationObject.h"

#define MAX_ROUNDS_PER_SIM 50

@implementation SimulationObject

@synthesize simCount, botTypeCount1, botTypeCount2;

@synthesize controller;

-(id) init
{
	if ((self = [super init]))
	{
		simCount = 0;
		botTypeCount1 = 6;
		botTypeCount2 = 7;
		controller = [[AiWarsViewController alloc] init];
	}
	return self;
}

-(void)cycle
{
	if (botTypeCount1 == [[[controller botSelector] botTypes] count]-1)
		exit(0);
		
	[controller cycle];
	
	if ([[controller theGame] gameMode] == GAME_MODE_BATTLE_FINISHED)
	{
		/*
		NSLog(@"Round #%d", [[controller theGame] round]);
		NSLog(@"Player 1: %f, %d, %d", [[[[controller theGame] players] objectAtIndex:0] roundsWon], [[[[controller theGame] players] objectAtIndex:0] botsKilled], [[[[controller theGame] players] objectAtIndex:0] botsDestroyed]);
		NSLog(@"Player 2: %f, %d, %d", [[[[controller theGame] players] objectAtIndex:1] roundsWon], [[[[controller theGame] players] objectAtIndex:1] botsKilled], [[[[controller theGame] players] objectAtIndex:1] botsDestroyed]);
		*/
		simCount++;
		if (simCount >= MAX_ROUNDS_PER_SIM)
		{
			NSLog(@"---%s vs %s---", [[[[[controller botSelector] botTypes] objectAtIndex:botTypeCount1] name] UTF8String], [[[[[controller botSelector] botTypes] objectAtIndex:botTypeCount2] name] UTF8String]);
			NSLog(@"Player 1: %f, %d, %d", [[[[controller theGame] players] objectAtIndex:0] roundsWon], [[[[controller theGame] players] objectAtIndex:0] botsKilled], [[[[controller theGame] players] objectAtIndex:0] botsDestroyed]);
			NSLog(@"Player 2: %f, %d, %d\n", [[[[controller theGame] players] objectAtIndex:1] roundsWon], [[[[controller theGame] players] objectAtIndex:1] botsKilled], [[[[controller theGame] players] objectAtIndex:1] botsDestroyed]);
			[[[[controller theGame] players] objectAtIndex:0] setRoundsWon:0];
			[[[[controller theGame] players] objectAtIndex:0] setBotsKilled:0];
			[[[[controller theGame] players] objectAtIndex:0] setBotsDestroyed:0];
			
			[[[[controller theGame] players] objectAtIndex:1] setRoundsWon:0];
			[[[[controller theGame] players] objectAtIndex:1] setBotsKilled:0];
			[[[[controller theGame] players] objectAtIndex:1] setBotsDestroyed:0];
			simCount = 0;
			botTypeCount2++;
			if (botTypeCount2 == [[[controller botSelector] botTypes] count]-1)
			{
				botTypeCount1++; 
				botTypeCount2=botTypeCount1+1;
				NSLog(@"-----------SWITCHING BASE BOT-------------");
			}
			
		}
		
		[self setupSimulation];
	}
	
}

-(void)setupPlayers
{
	Player *player;
	player = [[Player alloc] init];
	[player setName:@"MaLord"];
	[player setColor:COLOR_GREEN];
	[[[controller theGame] players] addObject:player];
	[player release];
	
	player = [[Player alloc] init];
	[player setName:@"Uzbit"];
	[player setColor:COLOR_RED];
	[[[controller theGame] players] addObject:player];
	[player release];
}

-(void)setupBots
{
	[controller setBotsPerPlayer:3];
	
	Player *player;
	Bot *bot, *targetBot = NULL;
	for (int p = 0; p < [[[controller theGame] players] count]; p++)
	{
		player = [[[controller theGame] players] objectAtIndex:p];
		[[player bots] removeAllObjects];
		for (int i = 0; i < [controller botsPerPlayer]; i++)
		{
			
			if ( p == 0)
				bot = [[[[controller botSelector] botTypes] objectAtIndex:botTypeCount1] copy];
			else if ( p == 1)
				bot = [[[[controller botSelector] botTypes] objectAtIndex:botTypeCount2] copy];
			
			[bot setShields:SHIELDS_VAL_FOR_BOT(bot)];
			/*if (i == 1 && p == 0)
				bot = [[[[controller botSelector] botTypes] objectAtIndex:botTypeCount1] copy];
			else if (i == 1 && p == 1)
				bot = [[[[controller botSelector] botTypes] objectAtIndex:botTypeCount2] copy];
			else
				bot = [[[[controller botSelector] botTypes] objectAtIndex:BOT_TYPE_SINGLE_SHOOTER_TIER_1] copy];
			*/
			if (bot)
			{
				[bot setX:1.2f*(p==1?1:-1) Y:1.0f-2*i/6.0 Z:-1.8];
				if (p == 1)
					[bot setCurrentTargetingAngle:-45];
				[bot setColor:[player color]];
				if (targetBot)
				{
					[bot setTargetLocking:YES];
					[bot setTarget:targetBot];
				}
				[bot setController:controller];
				[bot setCurrentMovement:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY];
				[controller addBot:bot forPlayer:p];
				[bot release];
			}
		}
	}
}

-(void)setupSimulation
{
	NSMutableArray *exceptionList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:[controller theGame], nil]];
	[controller removeAllDrawableObjects:exceptionList];
	[controller removeAllUpdateableObjects:exceptionList];
	[controller removeAllTouchableObjects:exceptionList];
	[exceptionList release];
	
	
	if ([[controller updateable_objects] indexOfObject:[controller theGame]] == NSNotFound)
		[controller addUpdateableObject:[controller theGame]];
	
	[[controller theGame] setRound:[[controller theGame] round]+1];
	
	//setup bots
	[self setupBots];

	//[controller commitObjectChanges];	

	[[controller theGame] setGameType:GAME_TYPE_MULTIPLAYER];
	[[controller theGame] setGameMode:GAME_MODE_BATTLE];
	if (controller.cycleTimer == nil)
		controller.cycleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10000.0 target:self selector:@selector(cycle) userInfo:nil repeats:YES];		

}

-(void)runSimulation
{
	[self setupSimulation];
	
	controller.cycleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10000.0 target:self selector:@selector(cycle) userInfo:nil repeats:YES];		
}


@end
