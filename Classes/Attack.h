//
//  Attack.h
//  AiWars
//
//  Created by Ted McCormack on 4/5/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Weapon.h"
#import "Defines.h"

@interface Attack : NSObject <NSCopying>
{
	AttackType attackType;
	float attackRate; //number of cycles between firing
	float attackTimer; //number of cycles since last attack
	Weapon *attackWeapon;
}

@property ATOMICITY_NONE AttackType attackType;
@property ATOMICITY_NONE float attackRate;
@property ATOMICITY_NONE float attackTimer;
@property ATOMICITY_ASSIGN Weapon *attackWeapon;

- (id)initWithType:(AttackType)t Weapon:(Weapon *)w Rate:(float)r;

@end
