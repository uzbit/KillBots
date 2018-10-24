//
//  RootViewController.m
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLViewController.h"
#import "Defines.h"

@implementation OpenGLViewController

@synthesize cycleNum;
@synthesize cycleTimer, everySecondTimer;
@synthesize openGLView;
@synthesize drawable_objects, acceleratable_objects, touchable_objects, updateable_objects;
@synthesize currentFrameRate;

- (void)startAnimation
{
	self.cycleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/currentFrameRate target:self selector:@selector(cycle) userInfo:nil repeats:YES];
	self.everySecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(everySecond) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	[self.cycleTimer invalidate];
    self.cycleTimer = nil;
	
	[self.everySecondTimer invalidate];
	self.everySecondTimer = nil;
}

- (void)cycle
{
	cycleNum++;
	frameCount++;
	
	int count = [updateable_objects count], i;
	
	if (count > 0)
	{
		int start = random()%count;
		
		id object;
		for (i = start; i < count; i++)
		{
			object = [updateable_objects objectAtIndex:i];
			[object update];
		}
		for (i = 0; i < start; i++)
		{
			object = [updateable_objects objectAtIndex:i];
			[object update];
		}
	}

	[self commitObjectChanges];

#if !SIMULATION
	[openGLView draw];
#endif
}

- (void)everySecond
{
#if TESTING
	NSLog(@"FPS: %f", (float)frameCount);
#endif

	frameCount = 0;
	
	/*A simple test of matrix, vector multiplication....
	GLfloat m1[16] = {1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16};
	GLfloat m2[16] = {17, 21, 25, 29, 18, 22, 26, 30, 19, 23, 27, 31, 20, 24, 28, 32};
	GLfloat v[4] = {4, 3, 2, 1};
	GLfloat result[16];
	GLfloat vResult[4];
	matrixMultiply4x4(m1, m2, result);
	matrixVectorMultiply4x1(m1, v, vResult);
	NSLog(@"Vresult = ");
	for (int i = 0; i < 4; i++)
		NSLog(@"%f", vResult[i]);
	for (int i = 0; i < 16; i++)
	{
		if (i%4 == 0)
			NSLog(@"column %d:", i/4);
		NSLog(@"%f", result[i]);	
	}*/
	
}

- (void)addDrawableObject:(id)obj
{
	[drawable_objects_addQueue addObject:obj];
}

- (void)addUpdateableObject:(id)obj
{
	[updateable_objects_addQueue addObject:obj];	
}

- (void)addAcceleratableObject:(id)obj
{
	[acceleratable_objects_addQueue addObject:obj];		
}

- (void)addTouchableObject:(id)obj
{
	[touchable_objects_addQueue addObject:obj];			
}

- (void)removeDrawableObject:(id)obj
{
	[drawable_objects_removeQueue addObject:obj];
}

- (void)removeUpdateableObject:(id)obj
{
	[updateable_objects_removeQueue addObject:obj];
}

- (void)removeAcceleratableObject:(id)obj
{
	[acceleratable_objects_removeQueue addObject:obj];
}

- (void)removeTouchableObject:(id)obj
{
	[touchable_objects_removeQueue addObject:obj];
}

- (void)removeAllDrawableObjects:(NSMutableArray *)except
{
	for (id obj in drawable_objects)
		if ([except indexOfObject:obj] == NSNotFound)
			[self removeDrawableObject:obj];
}

- (void)removeAllUpdateableObjects:(NSMutableArray *)except
{
	for (id obj in updateable_objects)
		if ([except indexOfObject:obj] == NSNotFound)
			[self removeUpdateableObject:obj];
}

- (void)removeAllAcceleratableObjects:(NSMutableArray *)except
{
	for (id obj in acceleratable_objects)
		if ([except indexOfObject:obj] == NSNotFound)
			[self removeAcceleratableObject:obj];
}

- (void)removeAllTouchableObjects:(NSMutableArray *)except
{
	for (id obj in touchable_objects)
		if ([except indexOfObject:obj] == NSNotFound)
			[self removeTouchableObject:obj];
}

- (void)commitObjectChanges
{
	if ([updateable_objects_addQueue count])
	{
		[updateable_objects addObjectsFromArray:updateable_objects_addQueue];
		[updateable_objects_addQueue removeAllObjects];
	}
	if ([drawable_objects_addQueue count])
	{
		[drawable_objects addObjectsFromArray:drawable_objects_addQueue];
		[drawable_objects_addQueue removeAllObjects];
	}	
	if ([acceleratable_objects_addQueue count])
	{
		[acceleratable_objects addObjectsFromArray:acceleratable_objects_addQueue];
		[acceleratable_objects_addQueue removeAllObjects];
	}
	if ([touchable_objects_addQueue count])
	{
		[touchable_objects addObjectsFromArray:touchable_objects_addQueue];
		[touchable_objects_addQueue removeAllObjects];
	}
	
	if ([updateable_objects_removeQueue count])
	{
		[updateable_objects removeObjectsInArray:updateable_objects_removeQueue];
		[updateable_objects_removeQueue removeAllObjects];
	}
	if ([drawable_objects_removeQueue count])
	{
		[drawable_objects removeObjectsInArray:drawable_objects_removeQueue];
		[drawable_objects_removeQueue removeAllObjects];
	}
	if ([acceleratable_objects_removeQueue count])
	{
		[acceleratable_objects removeObjectsInArray:acceleratable_objects_removeQueue];
		[acceleratable_objects_removeQueue removeAllObjects];
	}
	if ([touchable_objects_removeQueue count])
	{
		[touchable_objects removeObjectsInArray:touchable_objects_removeQueue];
		[touchable_objects_removeQueue removeAllObjects];
	}	
}
/*
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float accel_x = [acceleration x];
	float accel_y = [acceleration y];
	float accel_z = [acceleration z];
	
	//update the objects
	id object;
	for (int i = 0; i < [acceleratable_objects count]; i++)
	{
		object = [acceleratable_objects objectAtIndex:i];
		[object applyForceWithDdx:accel_x Ddy:accel_y Ddz:accel_z];
	}
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *allTouches = [event allTouches];
	
	UITouch *touch;
//	for (int i = 0; i < count([allTouches allObjects]))
	{		
		touch = [[allTouches allObjects] objectAtIndex:0];
		touchPoint = [touch locationInView:openGLView];
        touchPoint.y = [openGLView bounds].size.height - touchPoint.y;
	}
    /*NSLog(@"Touch x: %f", (float)touchPoint.x);
    NSLog(@"Touch y: %f", (float)touchPoint.y);*/

	//set the touches
	id object;
	for (int i = 0; i < [touchable_objects count]; i++)
	{
		object = [touchable_objects objectAtIndex:i];
		[object touchStart:touchPoint];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//set the touches
	id object;
	for (int i = 0; i < [touchable_objects count]; i++)
	{
		object = [touchable_objects objectAtIndex:i];
		[object touchEnd];
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *allTouches = [event allTouches];
	
	UITouch *touch;
	//	for (int i = 0; i < count([allTouches allObjects]))
	{		
		touch = [[allTouches allObjects] objectAtIndex:0];
		touchPoint = [touch locationInView:openGLView];
		touchPoint.y = [openGLView bounds].size.height - touchPoint.y;
	}
	
	//set the touches
	id object;
	for (int i = 0; i < [touchable_objects count]; i++)
	{
		object = [touchable_objects objectAtIndex:i];
		[object touchMove:touchPoint];
	}
}

- (id)init
{
    if (self = [super init])
	{
		frameCount = cycleNum = 0;

		drawable_objects = [[NSMutableArray alloc] initWithCapacity:1];
		acceleratable_objects = [[NSMutableArray alloc] initWithCapacity:1];
		touchable_objects = [[NSMutableArray alloc] initWithCapacity:1];
		updateable_objects = [[NSMutableArray alloc] initWithCapacity:1];
		drawable_objects_addQueue = [[NSMutableArray alloc] initWithCapacity:1];
		acceleratable_objects_addQueue = [[NSMutableArray alloc] initWithCapacity:1];
		touchable_objects_addQueue = [[NSMutableArray alloc] initWithCapacity:1];
		updateable_objects_addQueue = [[NSMutableArray alloc] initWithCapacity:1];
		drawable_objects_removeQueue = [[NSMutableArray alloc] initWithCapacity:1];
		acceleratable_objects_removeQueue = [[NSMutableArray alloc] initWithCapacity:1];
		touchable_objects_removeQueue = [[NSMutableArray alloc] initWithCapacity:1];
		updateable_objects_removeQueue = [[NSMutableArray alloc] initWithCapacity:1];
		
		openGLView = [[OpenGLView alloc] initWithFrame:CGRectMake(80, -80, APP_WIDTH, APP_HEIGHT)];
		openGLView.transform = CGAffineTransformMakeRotation(-M_PI/2);
		[openGLView setObjects:drawable_objects];
		[openGLView setController:self];
    }
    return self;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	/*
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT)];
	self.view.opaque = NO;
	[self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
	[self.view setAlpha:0];

	openGLView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT)];
	[openGLView setObjects:drawable_objects];
	[self.view addSubview:openGLView];
	 */
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	[self stopAnimation];

	[drawable_objects release];
	[acceleratable_objects release];
	[touchable_objects release];
	[updateable_objects release];
	[drawable_objects_addQueue release];
	[acceleratable_objects_addQueue release];
	[touchable_objects_addQueue release];
	[updateable_objects_addQueue release];
	[drawable_objects_removeQueue release];
	[acceleratable_objects_removeQueue release];
	[touchable_objects_removeQueue release];
	[updateable_objects_removeQueue release];
	
	[openGLView release];
	
    [super dealloc];
}


@end
