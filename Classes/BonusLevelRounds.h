//
//  SinglePlayerRound.h
//  AiWars
//
//  Created by Ted McCormack on 5/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinglePlayerRounds.h"
#import "Player.h"
#import "Bot.h"
#import "BotSelectorViewController.h" // for bot styles
#import "Weapons.h"
#import "Types.h"
#import "Game.h"
#import "BonusLevelsViewController.h"

@class AiWarsViewController;
@class SinglePlayerRounds;

@interface BonusLevelRounds : NSObject 
{
	AiWarsViewController *aiWarsViewController;
	SinglePlayerRounds *singlePlayerRounds;
	NSMutableArray *configuration;
}

@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;
@property ATOMICITY_ASSIGN SinglePlayerRounds *singlePlayerRounds;
@property ATOMICITY_RETAIN NSMutableArray *configuration;

- (bool)setupRound:(int)round;
- (void)addBotWithX:(float)X Y:(float)Y Player:(int)player botType:(int)botType botMovement:(MovementType)botMovement shields:(bool)shields jamming:(bool)jamming;

@end
