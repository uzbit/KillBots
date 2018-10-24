//
//  RootViewController.h
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
#import "Rates.h"
#import "Defines.h"

@interface OpenGLViewController : UIViewController <UIAccelerometerDelegate>
{    
	CGPoint touchPoint;

	int frameCount, cycleNum;
	NSTimer *cycleTimer, *everySecondTimer;
	
	OpenGLView *openGLView;
	
	NSMutableArray *drawable_objects, *updateable_objects, *acceleratable_objects, *touchable_objects;
	NSMutableArray *drawable_objects_addQueue, *updateable_objects_addQueue, *acceleratable_objects_addQueue, *touchable_objects_addQueue;
	NSMutableArray *drawable_objects_removeQueue, *updateable_objects_removeQueue, *acceleratable_objects_removeQueue, *touchable_objects_removeQueue;

	float currentFrameRate;
}

@property ATOMICITY_NONE int cycleNum;
@property ATOMICITY_ASSIGN NSTimer *cycleTimer, *everySecondTimer;
@property ATOMICITY_RETAIN OpenGLView *openGLView;
@property ATOMICITY_RETAIN NSMutableArray *drawable_objects, *updateable_objects, *acceleratable_objects, *touchable_objects;

@property ATOMICITY_NONE float currentFrameRate;

- (void)startAnimation;
- (void)stopAnimation;
- (void)cycle;
- (void)everySecond;

- (void)addDrawableObject:(id)obj;
- (void)addUpdateableObject:(id)obj;
- (void)addAcceleratableObject:(id)obj;
- (void)addTouchableObject:(id)obj;

- (void)removeDrawableObject:(id)obj;
- (void)removeUpdateableObject:(id)obj;
- (void)removeAcceleratableObject:(id)obj;
- (void)removeTouchableObject:(id)obj;

- (void)removeAllDrawableObjects:(NSMutableArray *)except;
- (void)removeAllUpdateableObjects:(NSMutableArray *)except;
- (void)removeAllAcceleratableObjects:(NSMutableArray *)except;
- (void)removeAllTouchableObjects:(NSMutableArray *)except;

- (void)commitObjectChanges;

@end
