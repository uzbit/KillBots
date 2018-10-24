//
//  Game.h
//  AiWars
//
//  Created by Ted McCormack on 4/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLObject.h"
#import "Types.h"
#import "Defines.h"

@class AiWarsViewController;

@interface Game : OpenGLObject
{
	GameMode gameMode;
	GameType gameType;
	
	int round;

	//players
	NSMutableArray *players;

	//controller
	AiWarsViewController *controller;
}

@property ATOMICITY_NONE GameMode gameMode;
@property ATOMICITY_NONE GameType gameType;

@property ATOMICITY_NONE int round;

@property ATOMICITY_RETAIN NSMutableArray *players;

//controller
@property ATOMICITY_ASSIGN AiWarsViewController *controller;

@end
