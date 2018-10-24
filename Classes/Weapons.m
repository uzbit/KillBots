//
//  Weapons.m
//  AiWars
//
//  Created by Ted McCormack on 4/7/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Weapons.h"
#import "Rates.h"
#import "Bot.h"



@implementation NormalWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_NORMAL;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 0.85;
		splashRange = 0;
		dSplashRange = 0;
		maxSpeed = NORMAL_WEAPON_SPEED;
		damage = 1;
		texture = t;
		alpha = 1.0;
	}
	return self;
}

@end

@implementation MissileWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_MISSILE;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 1.9;
		splashRange = 0.15;
		dSplashRange = 0;
		maxSpeed = MISSILE_WEAPON_SPEED;
		damage = 35;
		texture = t;
		alpha = 1.0;
	}
	return self;
}

- (void)draw4
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
	
	float red = slyRandom(.5, 1);
	glColor4f(red, red - slyRandom(0, red/2), 0, 1);
	glPushMatrix();

	float angle = getAngleToLookAt(x - dx, y - dy, x, y);
	glTranslatef(x-.15*sin(radians(angle)), y-.15*cos(radians(angle)), z);
	glScalef(.2, .2, 1);
	glRotatef(angle, 0, 0, -1);

	glBindTexture(GL_TEXTURE_2D, textureFlame);
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	glPopMatrix();
	
	[super draw4];
}

@end

@implementation LaserWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_LASER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 5;
		splashRange = 0;
		dSplashRange = 0;
		maxSpeed = LASER_WEAPON_SPEED;
		damage = 20;
		texture = t;
		alpha = 1.0;
	}
	return self;
}

@end

@implementation SuicideWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_SUICIDE;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 0.2;
		splashRange = 0.5;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 190;
		texture = t;
		alpha = 1.0;
		splashOnly = true;
	}
	return self;
}

@end

@implementation RammerWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_RAMMER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 0.01;
		splashRange = 0;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 3;
		texture = t;
		alpha = 1.0;
	}
	return self;
}

@end

@implementation JammerWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_JAMMER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 0.9;
		splashRange = 0;
		dSplashRange = 0.02;
		maxSpeed = 0;
		damage = 0;
		texture = t;
		alpha = 1.0;
		splashOnly = true;
	}
	return self;
}

- (void)draw4
{
	if (texture)
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
		
		glColor4f(1.0, 1.0, 1.0, alpha);
		
		glTranslatef(x, y, z);
		glScalef(2.5*splashRange, 2.5*splashRange, 1);
		//glRotatef(getAngleToLookAt(x - dx, y - dy, x, y), 0, 0, -1);
		
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

@end


@implementation IcyWeapon

@synthesize currentParticleNum;

- (id)init
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_ICY;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = .7;
		splashRange = .7;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 0.75;
		timeToLive = 2*CYCLES_PER_SECOND;
		alpha = 1.0;
		splashOnly = true;
		updateCounter = 0;
		
		currentParticleNum = 0;
		for (int i = 0; i < MAX_PARTICLE_NUM; i++)
			particles[i] = nil;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    IcyWeapon *weapon = [[IcyWeapon alloc] init];//NSCopyObject(self, 0, zone);
	
	[weapon setAttackType:[self attackType]];
	[weapon setMaxSpeed:[self maxSpeed]];
	[weapon setDamage:[self damage]];
	[weapon setRange:[self range]];
	[weapon setSplashRange:[self splashRange]];
	[weapon setDSplashRange:[self dSplashRange]];
	[weapon setAlpha:[self alpha]];
	[weapon setInitialX:[self initialX]];
	[weapon setInitialY:[self initialY]];
	[weapon setPlayer:[self player]];
	[weapon setTimeToLive:[self timeToLive]];
	[weapon setUpdateCounter:[self updateCounter]];
	[weapon setTexture:[self texture]];
	[weapon setTarget:[self target]];
	[weapon setFiredFrom:[self firedFrom]];
	
	return weapon;
}

- (void)addParticleX:(float)particleX Y:(float)particleY dX:(float)particleDx dY:(float)particleDy
{
	if (currentParticleNum+1 < MAX_PARTICLE_NUM)
	{
		int i = 0;
		while(particles[i] != nil && i < MAX_PARTICLE_NUM)
			i++;
		particles[i] = [[OpenGLObject alloc] init];
		[particles[i] setX:particleX Y:particleY Z:0];
		[particles[i] setDx:particleDx Dy:particleDy Dz:0];
		currentParticleNum++;
	}
}

- (void)draw4
{
	glTranslatef(0, 0, z);
	glEnableClientState(GL_VERTEX_ARRAY);
	
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
	
	
	for (int i = 0; i < MAX_PARTICLE_NUM; i++)
	{
		OpenGLObject *p = particles[i];
		if (p == nil)
			continue;
		
		float diffX = [p x]-x, diffY = [p y]-y;
		float d = sqrt(diffX*diffX+diffY*diffY);
		
		if (d <= splashRange)
		{
			alpha = (1-d/splashRange);
			
//			glColor4f(.8*alpha+(1-alpha), .8*alpha+(1-alpha), 1.0, alpha);
			glColor4f(1, 1, 1, alpha);
			glPushMatrix();
			glTranslatef([p x], [p y], 0);
			glScalef(ICY_PARTICLE_SIZE*(1+3*d/splashRange), ICY_PARTICLE_SIZE*(1+3*d/splashRange), 1);
			glRotatef(slyRandom(0, 360), 0, 0, -1);
			
			glBindTexture(GL_TEXTURE_2D, textureSnowFlakes[i%SNOWFLAKE_NUM]);
			
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
			glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisable(GL_TEXTURE_2D);
			
//			glVertexPointer(2, GL_FLOAT, 0, vertices);
//			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glPopMatrix();
			
			[p updatePosition];
			
			if (alpha < 0.2)
			{
				[particles[i] release];
				particles[i] = nil;
				currentParticleNum--;
			}
		}
	}
	glDisableClientState(GL_VERTEX_ARRAY);
		
}

- (void)dealloc
{
	for (int i = 0; i < MAX_PARTICLE_NUM; i++)
		if (particles[i] != nil)
			[particles[i] release];
	
	[super dealloc];
}

@end

@implementation FlamethrowerWeapon

@synthesize currentParticleNum;

- (id)init
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_FLAMETHROWER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = .7;
		splashRange = .7;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 2.5;
		timeToLive = 2*CYCLES_PER_SECOND;
		alpha = 1.0;
		splashOnly = true;
		updateCounter = 0;
		
		currentParticleNum = 0;
		for (int i = 0; i < MAX_PARTICLE_NUM; i++)
			particles[i] = nil;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    FlamethrowerWeapon *weapon = [[FlamethrowerWeapon alloc] init];//NSCopyObject(self, 0, zone);
	
	[weapon setAttackType:[self attackType]];
	[weapon setMaxSpeed:[self maxSpeed]];
	[weapon setDamage:[self damage]];
	[weapon setRange:[self range]];
	[weapon setSplashRange:[self splashRange]];
	[weapon setDSplashRange:[self dSplashRange]];
	[weapon setAlpha:[self alpha]];
	[weapon setInitialX:[self initialX]];
	[weapon setInitialY:[self initialY]];
	[weapon setPlayer:[self player]];
	[weapon setTimeToLive:[self timeToLive]];
	[weapon setUpdateCounter:[self updateCounter]];
	[weapon setTexture:[self texture]];
	[weapon setTarget:[self target]];
	[weapon setFiredFrom:[self firedFrom]];
	
	return weapon;
}

- (void)addParticleX:(float)particleX Y:(float)particleY dX:(float)particleDx dY:(float)particleDy
{
	if (currentParticleNum+1 < MAX_PARTICLE_NUM)
	{
		int i = 0;
		while(particles[i] != nil && i < MAX_PARTICLE_NUM)
			i++;
		particles[i] = [[OpenGLObject alloc] init];
		[particles[i] setX:particleX Y:particleY Z:0];
		[particles[i] setDx:particleDx Dy:particleDy Dz:0];
		currentParticleNum++;
	}
}

- (void)draw4
{
	glTranslatef(0, 0, z);
	glEnableClientState(GL_VERTEX_ARRAY);
		
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
	
	for (int i = 0; i < MAX_PARTICLE_NUM; i++)
	{
		OpenGLObject *p = particles[i];
		if (p == nil)
			continue;
		
		float diffX = [p x]-x, diffY = [p y]-y;
		float d = sqrt(diffX*diffX+diffY*diffY);

		if (d <= splashRange)
		{
			alpha = 1-d/splashRange;
			if (alpha > 0.25)
				alpha = 0.25;
			
//			glColor4f(.97*alpha+(1-alpha)*.87, .87*alpha+(1-alpha)*.38, 0, alpha);
			glColor4f(1, 1, 1, alpha);
			glPushMatrix();
			glTranslatef([p x], [p y], 0);
			glScalef(FLAMETHROWER_PARTICLE_SIZE*(0.5+5*d/splashRange), FLAMETHROWER_PARTICLE_SIZE*(0.5+5*d/splashRange), 1);
			glRotatef(slyRandom(0, 360), 0, 0, -1);
					
			glBindTexture(GL_TEXTURE_2D, fireParticles[i%FIRE_PARTICLE_NUM]);
			
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
			glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisable(GL_TEXTURE_2D);
			
			
//			glVertexPointer(2, GL_FLOAT, 0, vertices);
//			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glPopMatrix();
			
			[p updatePosition];

			if (alpha < 0.15)
			{
				[particles[i] release];
				particles[i] = nil;
				currentParticleNum--;
			}
			
		}
	}
	glDisableClientState(GL_VERTEX_ARRAY);
		
}

- (void)dealloc
{
	for (int i = 0; i < MAX_PARTICLE_NUM; i++)
		if (particles[i] != nil)
			[particles[i] release];

	[super dealloc];
}

@end


@implementation LightningWeapon

@synthesize strikes;

- (id)init
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_LIGHTNING;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 2.0;
		splashRange = 0;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 1.5;
		timeToLive = 1*CYCLES_PER_SECOND;
		alpha = 1.0;
		
		strikes = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LightningWeapon *weapon = [[LightningWeapon alloc] init];
	
	[weapon setAttackType:[self attackType]];
	[weapon setMaxSpeed:[self maxSpeed]];
	[weapon setDamage:[self damage]];
	[weapon setRange:[self range]];
	[weapon setSplashRange:[self splashRange]];
	[weapon setDSplashRange:[self dSplashRange]];
	[weapon setAlpha:[self alpha]];
	[weapon setInitialX:[self initialX]];
	[weapon setInitialY:[self initialY]];
	[weapon setPlayer:[self player]];
	[weapon setTimeToLive:[self timeToLive]];
	[weapon setUpdateCounter:[self updateCounter]];
	[weapon setTexture:[self texture]];
	[weapon setTarget:[self target]];
	[weapon setFiredFrom:[self firedFrom]];
	
	//[[weapon strikes] release];
	[weapon setStrikes:nil];
	[weapon setStrikes:[[[NSMutableArray alloc] initWithCapacity:1] retain]];
	return weapon;
}

- (void)addStrikeX:(float)strikeX Y:(float)strikeY
{
	Vector3D *v = [[Vector3D alloc] initWithX:strikeX Y:strikeY Z:0];
	[strikes addObject:v];
	[v release];
}

- (void)draw4
{
	float antiBlue = slyRandom(0, .5);
	glColor4f(.9-antiBlue/2, .9-antiBlue, .9, alpha);
	glLineWidth(random()%3+1);
	glTranslatef(0, 0, z);
	glEnableClientState(GL_VERTEX_ARRAY);

	for (Vector3D *v in strikes)
	{
		float diffX = v->vector.x-x, diffY = v->vector.y-y;
		
		if (sqrt(diffX*diffX + diffY*diffY) < 1)
		{
			GLfloat vertices[] = {
				x,  y,
				x+diffX/3+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE), y+diffY/3+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE),
				x+2*diffX/3+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE), y+2*diffY/3+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE),
				v->vector.x,  v->vector.y
			};
			
			glVertexPointer(2, GL_FLOAT, 0, vertices);
			glDrawArrays(GL_LINE_STRIP, 0, 4);
		}
		else
		{
			GLfloat vertices[] = {
				x,  y,
				x+diffX/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE), y+diffY/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE),
				x+2*diffX/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE), y+2*diffY/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE),
				x+3*diffX/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE), y+3*diffY/4+slyRandom(-LIGHTNING_DIVERGENCE, LIGHTNING_DIVERGENCE),
				v->vector.x,  v->vector.y
			};
			
			glVertexPointer(2, GL_FLOAT, 0, vertices);
			glDrawArrays(GL_LINE_STRIP, 0, 5);
		}
	}
	glDisableClientState(GL_VERTEX_ARRAY);
	
	[strikes removeAllObjects];
}

- (void)dealloc
{
	//[strikes release];
	[super dealloc];
}
@end


@implementation SeekingMissileWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_SEEKING_MISSILE;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 2.0;
		splashRange = 0.15;
		dSplashRange = 0;
		maxSpeed = MISSILE_WEAPON_SPEED;
		damage = 40;
		texture = t;
		timeToLive = 4*CYCLES_PER_SECOND;
		alpha = 1.0;
	}
	return self;
}

- (void)update
{
	if (target == nil)
		return;
	if ([target life] > 0)
	{
		float diffX = [target x]-x;
		float diffY = [target y]-y;
		float mag = sqrt(diffX*diffX+diffY*diffY);
		[self setDdx:MISSILE_WEAPON_SPEED*0.075*diffX/mag Ddy:MISSILE_WEAPON_SPEED*0.075*diffY/mag Ddz:0];
	}
	timeToLive--;
	[super update];
}

@end

@implementation PlasmaCannonWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_PLASMA_CANNON;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 2.5;
		splashRange = 0.3;
		dSplashRange = 0;
		maxSpeed = PLASMA_WEAPON_SPEED;
		damage = 50;
		texture = t;
		timeToLive = 4*CYCLES_PER_SECOND;
		alpha = 1.0;
	}
	return self;
}

@end

@implementation MassDriverWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_MASS_DRIVER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 5;
		splashRange = 0.15;
		dSplashRange = 0;
		maxSpeed = MASS_DRIVER_WEAPON_SPEED;
		damage = 14;
		texture = t;
		timeToLive = 10*CYCLES_PER_SECOND;
		alpha = 1.0;
	}
	return self;
}

@end

@implementation MineLayerWeapon

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_MINE_LAYER;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 0.15;
		splashRange = 0.6;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 150;//115;
		texture = t;
		alpha = 1.0;
		splashOnly = true;
	}
	return self;
}

- (void)draw4
{
}

- (void)draw1
{
	[super draw4];
}


@end

@implementation DeathRayWeapon

- (id)init
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_DEATH_RAY;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 1.5;
		splashRange = 0;
		dSplashRange = 0;
		maxSpeed = 0;
		damage = 3.3;
		timeToLive = 1.1*CYCLES_PER_SECOND;
		alpha = 1.0;
	}
	return self;
}

- (void)draw4
{
	float dist = sqrt(([target x]-x)*([target x]-x)+([target y]-y)*([target y]-y));
	float r = .04;

	glTranslatef(x, y, z);
	
	for (int i = 0; i < dist/r; i++)
	{
		glPushMatrix();
		float color = -((float)(updateCounter%10)/9)+(float)i/6;
		while (color > 1) color--;
		while (color < 0) color++;
		glColor4f(.7*color, 0, 0, .6);
		glTranslatef(i*r*([target x]-x)/dist, i*r*([target y]-y)/dist, (float)i/1000);
		glLineWidth(3);
		GLDrawCircle(10, r*color, true);
		glPopMatrix();
	}
}

@end

@implementation FatManWeapon

@synthesize exploded;
@synthesize explosionTimer;

- (id)initWithTexture:(GLuint)t
{
	if ((self = [super init]))
	{
		attackType = ATTACK_TYPE_FATMAN;
		ddx = 0;
		ddy = 0;
		dx = 0;
		dy = 0;
		range = 3.0;
		splashRange = 0.7;
		dSplashRange = 0;
		maxSpeed = FATMAN_WEAPON_SPEED;
		damage = 1500;
		texture = t;
		timeToLive = 4*CYCLES_PER_SECOND;
		alpha = 1.0;
		
		exploded = false;
		explosionTimer = 0;
	}
	return self;
}

- (void)explode
{
	explosionTimer = FATMAN_EXPLOSION_TIME;
	exploded = true;
	dx = dy = 0;
}

- (void)update
{
	if (exploded && explosionTimer > 0)
		explosionTimer--;
	
	timeToLive--;
	[super update];
}

- (void)draw4
{
	if (exploded)
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
		
		glColor4f(1.0, 1.0, 1.0, .8*explosionTimer/FATMAN_EXPLOSION_TIME);
		
		glTranslatef(x, y, z+.05);
		glScalef(1.5, 1.5, 1);
		
		glBindTexture(GL_TEXTURE_2D, textureFatManExplosion);
		
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
	else
	{
		[super draw4];
	}
}


@end





