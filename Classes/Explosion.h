//
//  Explosion.h
//  AiWars
//
//  Created by Jeremiah Gage on 6/8/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLObject.h"
#import "Color.h"
#import "Rates.h"

#define EXPLOSION_PARTICLE_NUM		30
#define EXPLOSION_PARTICLE_SPEED	.03
#define EXPLOSION_LENGTH			(3*CYCLES_PER_SECOND)
#define TEXTURE_EXPLOSION_NUM		5

GLuint textureExplosions[TEXTURE_EXPLOSION_NUM];

@interface Explosion : OpenGLObject
{
	NSMutableArray *particles;
	float counter;
	Color *color;
	float radius;
}

- (id)initAtX:(float)initX Y:(float)initY Color:(Color *)c Radius:(float)r;

@end
