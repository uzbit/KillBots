//
//  Utilities.m
//  EasterEgg
//
//  Created by Ted McCormack on 2/11/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Utilities.h"

@implementation PathNode
@synthesize x, y;
@synthesize fScore, hScore, gScore;
@synthesize cameFrom;
+ (PathNode *)initWithX:(int)X Y:(int)Y
{
	PathNode *aNode = [PathNode alloc];
	aNode.x = X;
	aNode.y = Y;
	aNode.fScore = aNode.hScore = aNode.gScore = 0;
	aNode.cameFrom = nil;
	return aNode;
}
-(void)dealloc
{
	[super dealloc];
}
@end

@implementation Vector3D

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}

- (id)initWithX:(float)x Y:(float)y Z:(float)z
{
	if (self = [super init])
	{
		vector.x = x;
		vector.y = y;
		vector.z = z;
	}
	return self;
}

- (void)setX:(float)x Y:(float)y Z:(float)z
{
	vector.x = x;
	vector.y = y;
	vector.z = z;
}

- (float) magnitude
{
	return sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z);	
}

+ (Vector3D *) normalizeWithX:(float)X Y:(float)Y Z:(float)Z
{
	float mag = sqrt(X*X+Y*Y+Z*Z);
	Vector3D *ret = [[Vector3D alloc] initWithX:(X/mag) Y:(Y/mag) Z:(Z/mag)];	
	return ret;
}

- (Vector3D *) normalize
{
	float mag = [self magnitude];
	Vector3D *ret = [[Vector3D alloc] initWithX:(vector.x/mag) Y:(vector.y/mag) Z:(vector.z/mag)];	
	return ret;
}

- (float)dotProduct:(Vector3D *)vec
{
	return (vector.x*vec->vector.x + vector.y*vec->vector.y + vector.z*vec->vector.z);
}

- (float)getAngleBetween:(Vector3D *)vec
{
	return RADIANS_TO_DEGREES(acos([self dotProduct:vec]/([self magnitude]*[vec magnitude])));
}

+ (Vector3D *) getAvgVec:(NSMutableArray *)vectors
{	
	Vector3D *ret = nil;
	float retVec[3] = {0, 0, 0};
	float count = (float)[vectors count];
	if (count > 0)
	{	
		for (Vector3D *v in vectors)
		{
			retVec[0] += v->vector.x;
			retVec[1] += v->vector.y;
			retVec[2] += v->vector.z;
		}
		ret = [[Vector3D alloc] initWithX:(retVec[0]/count) Y:(retVec[1]/count) Z:(retVec[2]/count)];	
	}
	return ret;
}

+ (Vector3D *) getVarianceVec:(NSMutableArray *)vectors
{	
	Vector3D *ret = nil;
	float avgVec[3] = {0, 0, 0};
	float retVec[3] = {0, 0, 0};
	float count = (float)[vectors count];
	if (count > 0)
	{	
		for (Vector3D *v in vectors)
		{
			avgVec[0] += v->vector.x;
			avgVec[1] += v->vector.y;
			avgVec[2] += v->vector.z;
		}
		avgVec[0] /= count;
		avgVec[1] /= count;
		avgVec[2] /= count;
		
		float tmp = 0;
		for (Vector3D *v in vectors)
		{
			tmp = (v->vector.x - avgVec[0]);
			retVec[0] += tmp*tmp;
			tmp = (v->vector.y - avgVec[1]);
			retVec[1] += tmp*tmp;
			tmp = (v->vector.z - avgVec[2]);
			retVec[2] += tmp*tmp;
		}
		
		ret = [[Vector3D alloc] initWithX:(retVec[0]/count) Y:(retVec[1]/count) Z:(retVec[2]/count)];	
	}
	return ret;
}


- (void)dealloc
{
	[super dealloc];
}

@end

/*float mapTo0_1(float inVal, float target, float low, float high)
{
	float ratio = fabs((inVal - target)/(high - low));
	if (ratio > 1.0) return 0;
	return (1.0 - ratio);
}*/

float distanceBetweenNodes(PathNode *start, PathNode *goal)
{
	float xdif = [goal x] - [start x];
	float ydif = [goal y] - [start y];
	return sqrt(xdif*xdif + ydif*ydif);
}

float getAngleToLookAt(float fromX, float fromY, float toX, float toY)
{
	return 90-RADIANS_TO_DEGREES(atan2(toY-fromY, toX-fromX)); 
}

float slyRandom(float min, float max)
{
	float r = (float)(random()%100000)/100000.0;
	return min+(max-min)*r;
}

int roundToHundreds(int num)
{
	int high = (int)(num/100.0);
	return (high*100+(((num - high*100) >= 50)?100:0));
}

int roundToTens(int num)
{
	int high = (int)(num/10.0);
	return (high*10+(((num - high*10) >= 5)?10:0));
}


