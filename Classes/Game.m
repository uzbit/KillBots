//
//  Game.m
//  AiWars
//
//  Created by Ted McCormack on 4/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Game.h"
#import "Bot.h"
#import "Player.h"
#import "AiWarsViewController.h"


@implementation Game

@synthesize gameMode;
@synthesize gameType;

@synthesize round;

@synthesize players;

@synthesize controller;

-(id)init
{
	if ((self = [super init]))
	{
		gameMode = GAME_MODE_NONE;
		round = 1;
		players = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}

- (id)copyWithZone:(NSZone*)zone{
    NSData *buffer;
    buffer = [NSKeyedArchiver archivedDataWithRootObject:self];
    Game *copy = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
    return copy;
}

-(void)update
{
	if (gameMode == GAME_MODE_BATTLE)
	{
		NSMutableArray *bots;
		float life, totalLife;
		const int playerCount = [players count];
		int numPlayersLeft = 0;
		bool alive;
		bool playersAlive[playerCount];
		static int lastTwoPlayers[2] = {-1, -1};
		static int i = 0;
		float minX = 1000, minY = 1000, maxX = -1000, maxY = -1000;
		
		for (i = 0; i < playerCount; i++)
			playersAlive[i] = false;

		//find the number of alive players
		//also set the life bar
		i = 0;
		for (Player *p in players)
		{
			totalLife = 0;
			alive = false;
			bots = [p bots];
			for (Bot *b in bots)
			{
				life = [b life];
				if (life > 0)
				{
					totalLife += life;
					alive = true;

					if ([b x] < minX) minX = [b x];
					if ([b y] < minY) minY = [b y];
					if ([b x] > maxX) maxX = [b x];
					if ([b y] > maxY) maxY = [b y];
				}
			}
			if (alive)
			{
				numPlayersLeft++;
				playersAlive[i] = true;
			}
			i++;
			
			//set the height of the life bar
/*			UIView *lifeBar;
			switch([players indexOfObject:p])
			{
				case 0:
					lifeBar = [controller lifeBar1];
					break;
				case 1:
					lifeBar = [controller lifeBar2];
					break;
				case 2:
					lifeBar = [controller lifeBar3];
					break;
				case 3:
					lifeBar = [controller lifeBar4];
					break;
			}
			CGRect frame = [lifeBar frame];
			frame.size.width = 40*totalLife/(100*[[p bots] count]);
			//[lifeBar setFrame:frame];
 */	
		}
	
		//update the view
		if (numPlayersLeft > 0)
		{
			float vx = (minX+maxX)/2;
			float vy = (minY+maxY)/2;
			float vz1 = (maxX-minX)/2.2-1.4;
			float vz2 = (maxY-minY)/1.3-1.4;
			float vz;
			if (vz1 > vz2)
				vz = vz1;
			else
				vz = vz2;

			[controller setViewX:&vx Y:&vy Z:&vz];
		}
/*		
		if (vz < -.5)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		else
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
*/
		//store the last two players in the event of a tie
		if (numPlayersLeft == 2 && lastTwoPlayers[0] < 0 && lastTwoPlayers[1] < 0)
		{
			int j = 0;
			for (i = 0; i < playerCount; i++)
				if (playersAlive[i] && j < 2)
					lastTwoPlayers[j++] = i;
		}
		
		//if there is a winner, then tell the controller
		if (numPlayersLeft == 1)
		{
			for (i = 0; i < playerCount; i++)
			{
				if (playersAlive[i])
				{
					[controller playerWon:i];
					lastTwoPlayers[0] = -1;
					lastTwoPlayers[1] = -1;
				}
			}
		}
		else if (numPlayersLeft == 0)
		{
			[controller tieWithPlayers:lastTwoPlayers[0] andP2:lastTwoPlayers[1]];
			lastTwoPlayers[0] = -1;
			lastTwoPlayers[1] = -1;
		}
	}
}

-(void)dealloc
{
	[players release];
	[super dealloc];
}
@end
