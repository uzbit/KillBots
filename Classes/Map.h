//
//  Map.h
//  AiWars
//
//  Created by Ted McCormack on 3/8/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLUtilities.h"
#import "OpenGLObject.h"


@interface Map : OpenGLObject
{
	short **grid;//[GRID_BOUNDS_X][GRID_BOUNDS_Y];
	GLuint	backgroundId;
}

- (Map *)initWithBackground:(NSString *)bFile andGrid:(NSString *)gFile;
- (void)draw2;

@end
