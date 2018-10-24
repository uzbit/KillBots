//
//  Pathfind.h
//  AiWars
//
//  Created by Ted McCormack on 3/9/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLUtilities.h"
#import "Utilities.h"


void registerGrid(short **grid);

void mapOglToGrid(GLfloat x, GLfloat y, PathNode *node);

bool findPath(PathNode *start, PathNode *goal, NSMutableArray *path);

bool findAStarPath(PathNode *start, PathNode *goal, NSMutableArray *path);

void computeForceVector(PathNode *current, NSMutableArray *path, Vector3D *force);
