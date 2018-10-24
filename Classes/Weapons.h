//
//  Weapons.h
//  AiWars
//
//  Created by Ted McCormack on 4/7/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weapon.h"
#import "Defines.h"
#import "Rates.h"

#define LIGHTNING_DIVERGENCE				.2

#define FLAMETHROWER_PARTICLE_SIZE			.06
#define FLAMETHROWER_PARTICLE_NUM			5

#define ICY_PARTICLE_SIZE			.03
#define ICY_PARTICLE_NUM			8

#define MAX_PARTICLE_NUM			500

@interface NormalWeapon : Weapon 

@end

GLuint textureFlame;

@interface MissileWeapon : Weapon

@end

@interface LaserWeapon : Weapon 

@end

@interface SuicideWeapon : Weapon 

@end

@interface JammerWeapon : Weapon 

@end

@interface RammerWeapon : Weapon 

@end

#define SNOWFLAKE_NUM		4
GLuint textureSnowFlakes[SNOWFLAKE_NUM];

@interface IcyWeapon : Weapon
{
	int currentParticleNum;
	OpenGLObject *particles[MAX_PARTICLE_NUM];
}

@property ATOMICITY_NONE int currentParticleNum;

- (void)addParticleX:(float)particleX Y:(float)particleY dX:(float)particleDx dY:(float)particleDy;

@end

#define FIRE_PARTICLE_NUM		1
GLuint fireParticles[FIRE_PARTICLE_NUM];

@interface FlamethrowerWeapon : Weapon
{
	int currentParticleNum;
	OpenGLObject *particles[MAX_PARTICLE_NUM];
}

@property ATOMICITY_NONE int currentParticleNum;

- (void)addParticleX:(float)particleX Y:(float)particleY dX:(float)particleDx dY:(float)particleDy;

@end

@interface LightningWeapon : Weapon
{
	NSMutableArray *strikes;
}

@property ATOMICITY_RETAIN NSMutableArray *strikes;

- (void)addStrikeX:(float)x Y:(float)y;

@end

@interface SeekingMissileWeapon : MissileWeapon

@end

@interface PlasmaCannonWeapon : Weapon

@end

@interface MassDriverWeapon : Weapon

@end

@interface MineLayerWeapon : Weapon

@end

@interface DeathRayWeapon : Weapon
{
}

@end

GLuint textureFatManExplosion;

@interface FatManWeapon : Weapon
{
	bool exploded;
	float explosionTimer;
}

@property ATOMICITY_NONE bool exploded;
@property ATOMICITY_NONE float explosionTimer;

- (void)explode;

@end



