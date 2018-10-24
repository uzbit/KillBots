//
//  Attack.m
//  AiWars
//
//  Created by Ted McCormack on 4/5/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Attack.h"


@implementation Attack
@synthesize attackType;
@synthesize attackRate;
@synthesize attackTimer;
@synthesize attackWeapon;

- (id)initWithType:(AttackType)t Weapon:(Weapon *)w Rate:(float)r
{
	if ((self = [super init]))
	{
		attackType = t;
		attackRate = r;
		attackTimer = 0;
		attackWeapon = w;
	}
	return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return NSCopyObject(self, 0, zone);
}
@end

