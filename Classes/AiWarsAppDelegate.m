//
//  AiWarsAppDelegate.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/6/09.
//  Copyright Slyco 2009. All rights reserved.
//

#import "AiWarsAppDelegate.h"

@implementation AiWarsAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	//REGISTER DEFAULTS
	NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], @"shouldRestore",
								 [NSNumber numberWithBool:YES], @"liteVersion",
								 [NSNumber numberWithBool:YES], @"soundIsOn",
								 [NSNumber numberWithBool:YES], @"shieldsOn",
								 [NSNumber numberWithBool:NO], @"showComputersOn",
								 [NSNumber numberWithBool:YES], @"jammingOn", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[appDefaults release]; 
	
	//lite version
#if LITE
	liteVersion = [[NSUserDefaults standardUserDefaults] boolForKey:@"liteVersion"];
#else
	liteVersion = NO;
#endif

	//seed the random generator
	srandom(time(NULL));
	
	//prevent the phone from turning off
	[UIApplication sharedApplication].idleTimerDisabled = YES;

    
	//initialize the sounds
	loadSounds();
	
	//rotate the main window
	//window.frame = CGRectMake(-80, 80, 480, 320);
	//window.transform = CGAffineTransformMakeRotation(M_PI/2);

	//add the main menu to the window
	mainMenuViewController = [[MainMenuViewController alloc] initWithNibName:@"MainMenu" bundle:nil];
	[mainMenuViewController setWindow:window];
	//[window addSubview:mainMenuViewController.view];
    [window setRootViewController:mainMenuViewController];
	//[mainMenuViewController.view setAlpha:0];
	
    //create a store observer for in-app purchases
    storeObserver = [[MyStoreObserver alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:storeObserver];
	[storeObserver setMainMenuViewController:mainMenuViewController];

	//show the window
    [window makeKeyAndVisible];
    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];

	//add the other views to the window
	[mainMenuViewController addViews];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[mainMenuViewController aiWarsViewController] saveState];
	unloadSounds();
}

- (void)dealloc
{
	[mainMenuViewController release];
    [window release];
    [super dealloc];
}


@end
