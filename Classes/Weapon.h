//
//  Weapons.h
//  AiWars
//
//  Created by Ted McCormack on 3/26/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLObject.h"
#import "Types.h"
#import "Defines.h"

@class Bot;

@interface Weapon : OpenGLObject <NSCopying> 
{
	AttackType attackType;
	float maxSpeed, damage, range, splashRange, dSplashRange, alpha;
	float initialX, initialY;
	int player, timeToLive, updateCounter;
	GLuint texture;
	Bot *target;
	Bot *firedFrom;
	bool splashOnly;
}

@property ATOMICITY_NONE AttackType attackType;
@property ATOMICITY_NONE float maxSpeed, damage, range, splashRange, dSplashRange, alpha;
@property ATOMICITY_NONE float initialX, initialY;
@property ATOMICITY_NONE int player, timeToLive, updateCounter;
@property ATOMICITY_NONE GLuint texture;
@property ATOMICITY_ASSIGN Bot *target;
@property ATOMICITY_ASSIGN Bot *firedFrom;
@property ATOMICITY_NONE bool splashOnly;



- (id)initWithTexture:(GLuint)t andSoundFile:(NSString *)s;
- (id)initWithTexture:(GLuint)t;

@end
