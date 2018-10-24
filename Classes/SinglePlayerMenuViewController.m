//
//  SinglePlayerViewController.m
//  AiWars
//
//  Created by Ted McCormack on 5/13/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SinglePlayerMenuViewController.h"
#import "SinglePlayerIntroViewController.h"
#import "MainMenuViewController.h"
#import "Types.h"


@implementation SinglePlayerMenuViewController

@synthesize newGameButton, continueGameButton, quitButton, bonusButton;
@synthesize topScore;

@synthesize hasSelected;

@synthesize mainMenuViewController;
@synthesize singlePlayerIntroViewController;
@synthesize bonusLevelsViewController;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[mainMenuViewController aiWarsViewController] setDoTutorial:true];
		[[[mainMenuViewController aiWarsViewController] theGame] setRound:1];
		[[[mainMenuViewController aiWarsViewController] singlePlayerHuman] setScore:0];
		[[mainMenuViewController aiWarsViewController]  setTotalLevelAttempts:0];
		[[mainMenuViewController aiWarsViewController]  setLevelAttempts:0];
		[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_SINGLEPLAYER];
		[[mainMenuViewController aiWarsViewController] saveState];
		[mainMenuViewController showSinglePlayerIntro];
	}
	else
		hasSelected = false;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		singlePlayerIntroViewController = [[SinglePlayerIntroViewController alloc] initWithNibName:@"SinglePlayerIntro" bundle:nil];

		bonusLevelsViewController = [[BonusLevelsViewController alloc] initWithNibName:@"BonusLevels" bundle:nil];
		[bonusLevelsViewController setSinglePlayerMenuViewController:self];

		hasSelected = false;
	}
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[[singlePlayerIntroViewController view] setAlpha:0];
	[self.view addSubview:[singlePlayerIntroViewController view]];

	[[bonusLevelsViewController view] setAlpha:0];
	[self.view addSubview:[bonusLevelsViewController view]];
	
	if (liteVersion)
		[bonusButton setAlpha:0];
}

- (IBAction)newGame:(id)sender
{	
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	playSound(clickSound);

	if ([continueGameButton alpha] == 1)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];	
	}
	else
	{
		[[mainMenuViewController aiWarsViewController] setDoTutorial:true];
		[[[mainMenuViewController aiWarsViewController] theGame] setRound:1];
		[[[mainMenuViewController aiWarsViewController] singlePlayerHuman] setScore:0];
		[[mainMenuViewController aiWarsViewController] setTotalLevelAttempts:0];
		[[mainMenuViewController aiWarsViewController] setLevelAttempts:0];
		[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_SINGLEPLAYER];
		[[mainMenuViewController aiWarsViewController] saveState];
		[mainMenuViewController showSinglePlayerIntro];
	}
}

- (IBAction)continueGame:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	playSound(clickSound);
	[[mainMenuViewController aiWarsViewController] setDoTutorial:false];
	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_SINGLEPLAYER];
	[[mainMenuViewController aiWarsViewController] restoreState];
	[mainMenuViewController startSinglePlayer];
}

- (IBAction)quit:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;

	playSound(clickSound);
	[[mainMenuViewController aiWarsViewController] setDoTutorial:false];
	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_SINGLEPLAYER];
	[[mainMenuViewController aiWarsViewController] saveState];
	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_NONE];
	[mainMenuViewController showMainMenu];
}

- (IBAction)bonusLevels:(id)sender
{
	playSound(clickSound);
	[[mainMenuViewController aiWarsViewController] setDoTutorial:false];
	[self showBonusLevels];
}

- (void)showBonusLevels
{
	[UIView beginAnimations:@"showBonusLevels" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[bonusLevelsViewController.view setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hideBonusLevels
{
	[UIView beginAnimations:@"hideBonusLevels" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[bonusLevelsViewController.view setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
    [singlePlayerIntroViewController release];
	[bonusLevelsViewController release];
	[super dealloc];
	
}


@end
