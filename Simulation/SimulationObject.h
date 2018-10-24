//
//  SimulationObject.h
//  AiWars
//
//  Created by Ted McCormack on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiWarsViewController.h"

@interface SimulationObject : NSObject 
{
	int simCount, botTypeCount1, botTypeCount2;
	AiWarsViewController *controller;
}

@property ATOMICITY_NONE int simCount, botTypeCount1, botTypeCount2;
@property ATOMICITY_RETAIN AiWarsViewController *controller;

-(void)cycle;
-(void)setupSimulation;
-(void)runSimulation;
-(void)setupPlayers;

@end
