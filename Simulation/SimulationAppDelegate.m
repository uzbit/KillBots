//
//  SimulationAppDelegate.m
//  AiWars
//
//  Created by Ted McCormack on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SimulationAppDelegate.h"


@implementation SimulationAppDelegate

@synthesize obj;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	srandom(time(NULL));
	NSLog(@"Simulation launched");
	obj = [[SimulationObject alloc] init];
	
	//setup players
	[obj setupPlayers];
	
	//run simulation
	[obj runSimulation];
	
}


@end
