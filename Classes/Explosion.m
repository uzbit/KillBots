//
//  Explosion.m
//  AiWars
//
//  Created by Jeremiah Gage on 6/8/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Explosion.h"


@implementation Explosion

- (id)initAtX:(float)initX Y:(float)initY Color:(Color *)c Radius:(float)r
{
    if (self = [super init])
	{
		x = initX;
		y = initY;
		color = c;
		radius = r;
		counter = 0;
		particles = [[NSMutableArray alloc] initWithCapacity:EXPLOSION_PARTICLE_NUM];

		OpenGLObject *p;
		for (int i = 1; i <= EXPLOSION_PARTICLE_NUM; i++)
		{
			p = [[OpenGLObject alloc] init];
			[p setX:initX Y:initY Z:0];
			[p setDx:slyRandom(-EXPLOSION_PARTICLE_SPEED, EXPLOSION_PARTICLE_SPEED) Dy:slyRandom(-EXPLOSION_PARTICLE_SPEED, EXPLOSION_PARTICLE_SPEED) Dz:0];
			[particles addObject:p];
			[p release];
		}
	}
	return self;
}

- (void)draw3
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

	counter++;
	
	if (counter > EXPLOSION_LENGTH)
		return;

	glTranslatef(0, 0, -1.7);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
	
	NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
	
	for (OpenGLObject *p in particles)
	{
		[p updatePosition];

		float diffX = [p x]-x, diffY = [p y]-y;
		float d = diffX*diffX+diffY*diffY;
		
		if (d <= radius)
		{
			float alpha1 = 1-counter/EXPLOSION_LENGTH;
			float alpha2 = 1-d/radius;
			float alpha;
			if (alpha1 < alpha2)
				alpha = alpha1;
			else
				alpha = alpha2;
			glColor4f([color red], [color green], [color blue], alpha);
			glPushMatrix();
			glTranslatef([p x], [p y], 0);
			glScalef(0.05+slyRandom(-0.03, 0.03), 0.05+slyRandom(-0.03, 0.03), 0);
			glRotatef(slyRandom(0, 360), 0, 0, -1);

			glBindTexture(GL_TEXTURE_2D, textureExplosions[random()%TEXTURE_EXPLOSION_NUM]);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

			glPopMatrix();
		}
		else
		{
			[removeObjects addObject:p];
		}
	}
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	[particles removeObjectsInArray:removeObjects];
	[removeObjects release];
}

- (void)dealloc
{
	[particles release];
	//[color release];
	[super dealloc];
}

@end
