//
//  Weapons.m
//  AiWars
//
//  Created by Ted McCormack on 3/26/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Weapon.h"
#import "Utilities.h"
#import "Bot.h"

@implementation Weapon

@synthesize attackType;
@synthesize maxSpeed, damage, range, splashRange, dSplashRange, alpha;
@synthesize initialX, initialY;
@synthesize player, timeToLive, updateCounter;
@synthesize texture;
@synthesize target;
@synthesize firedFrom;
@synthesize splashOnly;

- (id)init
{
	if ((self = [super init]))
	{
		target = nil;
		firedFrom = nil;
		alpha = 1.0;
		updateCounter = 0;
		splashOnly = false;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return NSCopyObject(self, 0, zone);
}

- (void)updatePosition
{
	float mag = sqrt(dx*dx+dy*dy); 
	if (mag > maxSpeed)
	{
		dx = maxSpeed*dx/mag;
		dy = maxSpeed*dy/mag;
	}
	
	[super updatePosition];
}

- (void)update
{
	splashRange += dSplashRange;
	[self applyForceWithDdx:ddx Ddy:ddy Ddz:ddz];
	[self updatePosition];
	updateCounter++;
}

- (void)draw4
{
	if (texture && (((dx != 0.0 || dy != 0.0) && maxSpeed > 0) || maxSpeed <= 0))
	{
		const GLfloat spriteVertices[] = {
			-.5,  -.5,
			-.5, .5,
			.5,  -.5,
			.5, .5,
		};
		
		// Sets up an array of values for the texture coordinates.
		const GLshort spriteTexcoords[] = {
			0, 0,
			1, 0,
			0, 1,
			1, 1,
		};
		
		if (firedFrom != nil)
			glColor4f([[firedFrom color] red], [[firedFrom color] green], [[firedFrom color] blue], alpha);
		else
			glColor4f(1.0, 1.0, 1.0, alpha);
		
		glTranslatef(x, y, z);
		glScalef(.2, .2, 1);
		glRotatef(getAngleToLookAt(x - dx, y - dy, x, y), 0, 0, -1);
		
		glBindTexture(GL_TEXTURE_2D, texture);
		
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
		glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_TEXTURE_2D);
	}
}

- (void)dealloc
{
	[super dealloc];
}

@end
