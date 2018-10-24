//
//  OpenGLObject.m
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLObject.h"


@implementation OpenGLObject

@synthesize x, y, z;
@synthesize dx, dy, dz;
@synthesize ddx, ddy, ddz;
@synthesize mass;

@synthesize touch;
@synthesize isTouching;

- (id)init
{
	if ((self = [super init]))
	{
		x = y = z = 0;
		dx = dy = dz = 0;
		ddx = ddy = ddz = 0;
		mass = 1.0;
	}
	return self;
}

- (void)setX:(float)nX Y:(float)nY Z:(float)nZ
{
	x = nX;
	y = nY;
	z = nZ;
}

- (void)setDx:(float)Dx Dy:(float)Dy Dz:(float)Dz
{
	dx = Dx;
	dy = Dy;
	dz = Dz;
}

- (void)setDdx:(float)Ddx Ddy:(float)Ddy Ddz:(float)Ddz
{
	ddx = Ddx;
	ddy = Ddy;
	ddz = Ddz;
}

- (void)update
{
}

- (void)applyForceWithDdx:(float)Ddx Ddy:(float)Ddy Ddz:(float)Ddz
{
	dx += Ddx/mass;
	dy += Ddy/mass;
	dz += Ddz/mass;
}

- (void)updatePosition
{
	x += dx;
	y += dy;
	z += dz;
}


- (void)touchStart:(CGPoint)position
{
	touch.x = position.x;
	touch.y = position.y;
	isTouching = YES;
}

- (void)touchMove:(CGPoint)position;
{
	touch.x = position.x;
	touch.y = position.y;
}

- (void)touchEnd
{
	isTouching = NO;
}

- (void)draw1
{
}

- (void)draw2
{
}

- (void)draw3
{
}

- (void)draw4
{
}

-(void)dealloc
{
	[super dealloc];
}

@end
