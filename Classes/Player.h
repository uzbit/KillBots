//
//  Player.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/22/09.
//  Copyright 2009 Slyco. All rights reserved.
//

//#import "BotSelectorViewController.h"

#import "Color.h"
#import "Defines.h"

@interface Player : NSObject
{
	NSString *name;
	NSString *description;
	Color *color;
	int baseTexture; //the index of the base texture
	NSMutableArray *bots;
	int botsKilled, botsKilledThisRound, botsDestroyed, funds, surplus;
	float roundsWon;
	int isComputer; // -1 is not computer >= 0 is computer of index isComputer
	int score;
}

@property ATOMICITY_RETAIN NSString *name;
@property ATOMICITY_RETAIN NSString *description;
@property ATOMICITY_ASSIGN Color *color;
@property ATOMICITY_NONE int baseTexture;
@property ATOMICITY_RETAIN NSMutableArray *bots;
@property ATOMICITY_NONE int botsKilled,  botsKilledThisRound, botsDestroyed, surplus;
@property (nonatomic, setter=setFunds:) int funds;
@property ATOMICITY_NONE float roundsWon;
@property ATOMICITY_NONE int isComputer;
@property ATOMICITY_NONE int score;

//- (UIColor *)UIColor;

- (void)setFunds:(int)f;
- (void)autoConfigureBots;

@end
