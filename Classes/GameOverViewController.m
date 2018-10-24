//
//  GameOverViewController.m
//  AiWars
//
//  Created by Ted McCormack on 5/26/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "GameOverViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"
#import "Types.h"

@implementation GameOverViewController


@synthesize continueButton;
@synthesize titleLabel, successRate, finalScore, storyLabel, successRateLabel, finalScoreLabel;

@synthesize aiWarsViewController;

- (IBAction)quit:(id)sender
{
	playSound(clickSound);
	
	//[aiWarsViewController quitGame:sender];
	[aiWarsViewController hideGameOver];
	[[aiWarsViewController mainMenuViewController] destroyOpenGLView];
	if ([[aiWarsViewController theGame] gameType] == GAME_TYPE_SINGLEPLAYER)
	{	
		[[[[aiWarsViewController mainMenuViewController] singlePlayerViewController] view] setAlpha:1];
		[[[[aiWarsViewController mainMenuViewController] singlePlayerViewController] continueGameButton] setAlpha:1];
		[[aiWarsViewController mainMenuViewController] showSinglePlayerMenu];
	}
	else
	{
		[[aiWarsViewController mainMenuViewController] stopMultiPlayer];
	}
}

- (IBAction)continue:(id)sender
{
	playSound(clickSound);
	[aiWarsViewController hideGameOver];
	[[aiWarsViewController theGame] setRound:0];
	if ([[aiWarsViewController theGame] gameType] == GAME_TYPE_SINGLEPLAYER)
	{	
		[[[[aiWarsViewController mainMenuViewController] singlePlayerViewController] view] setAlpha:1];
		[[[[aiWarsViewController mainMenuViewController] singlePlayerViewController] continueGameButton] setAlpha:0];
		[[aiWarsViewController mainMenuViewController] showSinglePlayerMenu];
	}
	else
	{
		[[[[aiWarsViewController mainMenuViewController] multiPlayerMenuViewController] continueGameButton] setAlpha:0];
		[[aiWarsViewController mainMenuViewController] stopMultiPlayer];
	}
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
