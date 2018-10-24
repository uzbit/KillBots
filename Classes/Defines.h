//
//  Defines.h
//  AiWars
//
//  Created by Ted McCormack on 6/22/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sounds.h"

#define LITE		0
#define TESTING		0
#define SIMULATION	0

#define ATOMICITY_RETAIN	(retain)
#define ATOMICITY_ASSIGN	(assign)
#define ATOMICITY_NONE		(nonatomic)


#define SHIELDS_VAL_FOR_BOT(b)		(([b cost] <= 10000 || [b cost] >= 200000)?100:roundToTens((int)sqrt([b cost])))


bool liteVersion;
