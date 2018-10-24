//
//  OpenGLObject.h
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLUtilities.h"
#import "Defines.h"

@class OpenGLViewController;

@interface OpenGLObject : NSObject
{
	float x, y, z;
	float dx, dy, dz;
	float ddx, ddy, ddz;
	float mass;
	
	CGPoint touch;
	bool isTouching;
}

@property ATOMICITY_NONE float x, y, z;
@property ATOMICITY_NONE float dx, dy, dz;
@property ATOMICITY_NONE float ddx, ddy, ddz;
@property ATOMICITY_NONE float mass;

@property ATOMICITY_NONE CGPoint touch;
@property ATOMICITY_NONE bool isTouching;

- (id)init;
- (void)setX:(float)nX Y:(float)nY Z:(float)nZ; //convenience function for setting the coordinates
- (void)setDx:(float)Dx Dy:(float)Dy Dz:(float)Dz; //convenience function for setting the velocity
- (void)setDdx:(float)Ddx Ddy:(float)Ddy Ddz:(float)Ddz; //convenience function for setting the accelerations
- (void)update; //should be subclassed to update the status of the object
- (void)applyForceWithDdx:(float)Ddx Ddy:(float)Ddy Ddz:(float)Ddz; //applies an acceleration vector to the object
- (void)updatePosition; //adds the velocity to the position
- (void)touchStart:(CGPoint)position; //should be called when a touch is invoked
- (void)touchMove:(CGPoint)position; //should be called when a touch is moved
- (void)touchEnd; //should be called when a touch has ended
- (void)draw1; //draw to layer 1
- (void)draw2; //draw to layer 2
- (void)draw3; //draw to layer 3
- (void)draw4; //draw to layer 4


@end
