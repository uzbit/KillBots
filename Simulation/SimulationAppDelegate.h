//
//  SimulationAppDelegate.h
//  AiWars
//
//  Created by Ted McCormack on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimulationObject.h"

@interface SimulationAppDelegate : NSObject <UIApplicationDelegate>
{
	SimulationObject *obj;
}

@property ATOMICITY_RETAIN SimulationObject *obj;

@end
