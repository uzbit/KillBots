//
//  Pathfind.m
//  AiWars
//
//  Created by Ted McCormack on 3/9/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Pathfind.h"

//static bool theGrid[GRID_BOUNDS_X][GRID_BOUNDS_Y];

static short **theGrid;

void registerGrid(short **grid)
{
	theGrid = grid;
}

void mapOglToGrid(GLfloat x, GLfloat y, PathNode *node)
{
	float xpos = x*(APP_WIDTH/3.0) + APP_WIDTH/2.0;
	float ypos = -y*(APP_HEIGHT/2.0) + APP_HEIGHT/2.0;
	
	node->x = (int)(xpos/GRID_PIXEL_SIZE);
	node->y = (int)(ypos/GRID_PIXEL_SIZE);
}

static PathNode* nodeWithLowestF(NSMutableArray *nodes)
{
	float lowest = 1.0e9;
	PathNode *pl;
	for (PathNode *pn in nodes)
		if ([pn fScore] < lowest)
		{
			lowest = [pn fScore];
			pl = pn;
		}
	return pl;
}

static NSMutableArray *reconstructPath(PathNode *currentNode, NSMutableArray *path)
{
	if (currentNode.cameFrom != nil)
	{
		reconstructPath(currentNode.cameFrom, path);
		[path addObject:currentNode];
		return path;
	}
	else
		return nil;
}

static NSMutableArray *neighborNodes(PathNode *currentNode)
{
	int x = [currentNode x];
	int y = [currentNode y];
	NSMutableArray *neighbors = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:nil]];
	if (x - 1 >= 0 && y - 1 >= 0)
		if (theGrid[x-1][y-1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x-1 Y:y-1]];
	if (y - 1 >= 0)
		if (theGrid[x][y-1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x Y:y-1]];
	if (x + 1 < GRID_BOUNDS_X && y - 1 >= 0)
		if (theGrid[x+1][y-1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x+1 Y:y-1]];
	if (x + 1 < GRID_BOUNDS_X)
		if (theGrid[x+1][y] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x+1 Y:y]];
	if (x + 1 < GRID_BOUNDS_X && y + 1 < GRID_BOUNDS_Y)
		if (theGrid[x+1][y+1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x+1 Y:y+1]];
	if (y + 1 < GRID_BOUNDS_Y)
		if (theGrid[x][y+1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x Y:y+1]];
	if (x - 1 >= 0 && y + 1 < GRID_BOUNDS_Y)
		if (theGrid[x-1][y+1] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x-1 Y:y+1]];
	if (x - 1 >= 0)
		if (theGrid[x-1][y] == MAP_ALLOW_ALL)
			[neighbors addObject:[PathNode initWithX:x-1 Y:y]];
	return neighbors;
}

static bool compareNodes(PathNode *a, PathNode *b)
{
	if ([a x] == [b x] && [a y] == [b y])
		return true;
	return false;
}

static bool nodeIsInSet(PathNode *node, NSMutableArray* set)
{
	for (PathNode *cs in set)
		if (compareNodes(node, cs))
		{
			return true;
		}
	return false;
}

static bool findStraightPath(PathNode *start, PathNode *goal, NSMutableArray *path)
{
	float xdif = [goal x] - [start x];
	if (xdif != 0)
	{
		float slope = ([goal y] - [start y])/xdif;
		float x = [start x], y;
		float signX = SIGN(xdif);
		int fX, fY, fXDif = (int)fabs(xdif);
		[path removeAllObjects];
		for (int i = 0; i < fXDif; i++)
		{
			x += signX;
			y = (x*slope) + [start y];
			fX = (int)fabs(x); fY = (int)fabs(y);
			//NSLog(@"Checking %d, %d",fX, fY);
			if (theGrid[fX][fY] == MAP_ALLOW_ALL)
			{	
				[path addObject:[PathNode initWithX:fX Y:fY]];
			}
			else
			{
				for (int j = 0; j < 1 && [path count]; j++)
					[path removeLastObject];
				break;
			}
		}
	}
	else
	{
		float ydif = [goal y] - [start y]; 
		int fYdif = (int)fabs(ydif);
		int fY = [start y], signY = SIGN(ydif);
		int fX = [start x];
		[path removeAllObjects];
		for (int i = 0; i < fYdif; i++)
		{
			fY += signY;
			if (theGrid[fX][fY] == MAP_ALLOW_ALL)
			{	
				[path addObject:[PathNode initWithX:fX Y:fY]];
			}
			else
			{
				for (int j = 0; j < 1 && [path count]; j++)
					[path removeLastObject];
				break;
			}
		}
	}
	//NSLog(@"New path count %d", [path count]);
	return ([path count] != 0);
		
}

bool findPath(PathNode *start, PathNode *goal, NSMutableArray *path)
{
	if (!findStraightPath(start, goal, path))
	{
		return findAStarPath(start, goal, path);
	}
	return true;
}

bool findAStarPath(PathNode *start, PathNode *goal, NSMutableArray *path)
{
	float firstEstimate = distanceBetweenNodes(start, goal);
	start.fScore = firstEstimate;
	NSMutableArray *closedSet = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:nil]];
	NSMutableArray *openSet = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:start]];
	
	int counter = 0;
	PathNode *x;
	while ([openSet count] && counter < 100) //perhaps add timer so as to not get stuck.
	{
		//x = nodeWithLowestF(openSet);
		x = nodeWithLowestF(openSet);
		if (compareNodes(x, goal))
		{
			[closedSet release];
			[openSet release];
			[path removeAllObjects];
			reconstructPath(x, path);
			return true;
		}
		[openSet removeObject:x];
		[closedSet addObject:x];
		NSMutableArray *neighbors = neighborNodes(x); 
		for (PathNode *y in neighbors)
		{
			if (nodeIsInSet(y, closedSet))
				continue;
			
			float tGscore = x.gScore + distanceBetweenNodes(x, y);
			bool tIsBetter = false;
			if (!nodeIsInSet(y, openSet))
			{
				y.hScore = distanceBetweenNodes(y, goal);
				[openSet addObject:y];
				tIsBetter = true;
			}
			else if (tGscore < y.gScore)
				tIsBetter = true;
			if (tIsBetter)
			{
				y.cameFrom = x;
				y.gScore = tGscore;
				y.fScore = y.gScore + y.hScore;
			}
		}
		[neighbors release];
		counter++;
	}
	[path removeAllObjects];
	reconstructPath(x, path);
	[closedSet release];
	[openSet release];
	return false;
}

/*
void computeForceVector(PathNode *current, NSMutableArray *path, Vector3D *force)
{
	if ([path count])
	{
		float shortestDist = 1.0e9;
		PathNode *closest = nil;
		for (PathNode *pn in path)
		{
			float distance = distanceBetweenNodes(current, pn);
			if (shortestDist > distance)
			{
				shortestDist = distance;
				closest = pn;
			}
			else
				break;
		}
		if (closest != nil)
		{
			int index = [path indexOfObject:closest];
			if (index + 2 < [path count]) // increment (2) should be determined by speed or firing range
			{	
				PathNode *next = [path objectAtIndex:index+2];
				if (next)
				{
					[force setX:FORCE_CONSTANT*([current x] - [next x]) Y:FORCE_CONSTANT*([current y] - [next y]) Z:0];
					return;
				}
			}
		}
	}
	[force setX:0 Y:0 Z:0];
}*/
