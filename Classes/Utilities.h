//
//  Utilities.h
//  EasterEgg
//
//  Created by Ted McCormack on 2/11/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define	RADIANS_TO_DEGREES(x)	((x)*180.0/M_PI)
#define	DEGREES_TO_RADIANS(x)	((x)*M_PI/180.0)

#define SIGN(x) ((x < 0.0f)?-1.0f:1.0f)

#define GRID_PIXEL_SIZE		10
#define GRID_BOUNDS_X APP_WIDTH/GRID_PIXEL_SIZE
#define GRID_BOUNDS_Y APP_HEIGHT/GRID_PIXEL_SIZE

#define MAP_ALLOW_NONE		0
#define MAP_ALLOW_FLIGHT	1
#define MAP_ALLOW_ALL		2

#define MAX_ACCELERATION	0.0001


@class PathNode;

@interface PathNode : NSObject
{
@public
	int x, y;
@private
	float fScore, gScore, hScore;
	PathNode *cameFrom;
}
+ (PathNode *)initWithX:(int)X Y:(int)Y;

@property (readwrite) int x, y;
@property (readwrite) float fScore, gScore, hScore;
@property (assign) PathNode *cameFrom;
@end


@interface Vector3D : NSObject 
{
@public
	struct
	{
		float x, y, z;
	} vector;
}

- (id)initWithX:(float)x Y:(float)y Z:(float)z;
- (void)setX:(float)x Y:(float)y Z:(float)z;

- (float)magnitude;
- (Vector3D *)normalize;
+ (Vector3D *) normalizeWithX:(float)X Y:(float)Y Z:(float)Z;
- (float)dotProduct:(Vector3D *)vec;
- (float)getAngleBetween:(Vector3D *)vec;	//returns angle between self and vec in degrees

+ (Vector3D *)getAvgVec:(NSMutableArray *)vecs;
+ (Vector3D *)getVarianceVec:(NSMutableArray *)vecs;

@end

float getAngleToLookAt(float fromX, float fromY, float toX, float toY);

//float mapTo0_1(float inVal, float target, float low, float high);
float distanceBetweenNodes(PathNode *start, PathNode *goal);

float slyRandom(float min, float max);

int roundToHundreds(int num);
int roundToTens(int num);
