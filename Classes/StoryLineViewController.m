//
//  StoryLineViewController.m
//  AiWars
//
//  Created by Ted McCormack on 6/1/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "StoryLineViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"

@implementation StoryLineViewController

@synthesize continueButton, quitButton;
@synthesize storyLine, titleLabel, roundLevel;
@synthesize progressImageView;
@synthesize hasSelected;
@synthesize aiWarsViewController;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[aiWarsViewController setDoTutorial:true];
		[aiWarsViewController setTutorialState:1];
		[aiWarsViewController showTutorial:1];
	}
	else
	{
		[aiWarsViewController setDoTutorial:false];
	}
}

- (IBAction)continue:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	playSound(clickSound);

	if ([[aiWarsViewController theGame] gameMode] == GAME_MODE_BATTLE)
	{
		[aiWarsViewController startSelecting];
		playSoundLoop(preBattleSound);
		[aiWarsViewController hideStoryLine];
		[[aiWarsViewController openGLView] clear];
		[aiWarsViewController startAnimation];
	}
	else
	{
		[aiWarsViewController showStatusBar];
		[aiWarsViewController hideStoryLine];
		if ([aiWarsViewController doTutorial] && [[aiWarsViewController theGame] round] == 1)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Would you like the tutorial on?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
			[alert show];
			[alert release];	
		}
	}
}

- (IBAction)quit:(id)sender
{
	if (hasSelected)
		return;
	else 
		hasSelected = true;
	
	playSound(clickSound);

	[aiWarsViewController quitGame:sender];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
	}
    return self;
}*/

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

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
    [super dealloc];
}


@end
