//
//  SinglePlayerRound.h
//  AiWars
//
//  Created by Ted McCormack on 5/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Game.h"
#import "StoryLineViewController.h"

@interface ConfigurationObject : NSObject
{
	bool shields, jamming;
	int movementType, botType, cost;
	float x, y, z;
}
@property (nonatomic) bool shields, jamming;
@property (nonatomic) int movementType, botType, cost;
@property (nonatomic) float x, y, z;
- (id)initWithX:(float)X Y:(float)Y Z:(float)Z MT:(int)mt BT:(int)bt CT:(int)ct SH:(bool)sh JA:(bool)ja;
@end

@class AiWarsViewController;

@interface SinglePlayerRounds : NSObject 
{
	bool wonLastRound;
	AiWarsViewController *aiWarsViewController;
	StoryLineViewController *storyLineViewController;
	NSMutableArray *configuration;
}

@property ATOMICITY_NONE bool wonLastRound;

@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;
@property ATOMICITY_RETAIN StoryLineViewController *storyLineViewController;
@property ATOMICITY_RETAIN NSMutableArray *configuration;

- (bool)setupRound:(int)round;
- (void)addBotWithX:(float)X Y:(float)Y Player:(int)player botType:(int)botType botMovement:(MovementType)botMovement shields:(bool)shields jamming:(bool)jamming;

@end
