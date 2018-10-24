//
//  MultiPlayerMenuViewController.m
//  AiWars
//
//  Created by Ted McCormack on 8/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "MultiPlayerMenuViewController.h"
#import "MainMenuViewController.h"
#import "Types.h"


@implementation MultiPlayerMenuViewController

@synthesize newGameButton, continueGameButton, quitButton;

@synthesize hasSelected;

@synthesize mainMenuViewController;
@synthesize multiPlayerViewController;

- (void)showMultiPlayerView
{
	[multiPlayerViewController setHasSelectedDoneOrQuit:false];
	[[multiPlayerViewController tableView] reloadData]; 
	
	[UIView beginAnimations:@"showMultiPlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(afterShowMainMenu)];
	
	[multiPlayerViewController.view setAlpha:1];
	
	[UIView commitAnimations];	
	
	[mainMenuViewController destroyOpenGLView];
}

- (void)hideMultiPlayerView
{
	[self.view setAlpha:0];
	[UIView beginAnimations:@"hideMultiPlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[multiPlayerViewController.view setAlpha:0];
	
	[UIView commitAnimations];	
}

- (void)afterShowMainMenu
{
	[self.view setAlpha:1];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[[mainMenuViewController aiWarsViewController] theGame] setRound:1];
		for (Player *p in [[[mainMenuViewController aiWarsViewController] theGame] players])
		{
			[p setRoundsWon:0];
			[p setSurplus:0];
			[p setBotsDestroyed:0];
			[p setBotsKilled:0];
			[p setBotsKilledThisRound:0];
			[p setScore:0];
		}
		[self showMultiPlayerView];
	}
	else
		hasSelected = false;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		multiPlayerViewController = [[MultiPlayerViewController alloc] initWithNibName:@"MultiPlayer" bundle:nil];
		hasSelected = false;
	}
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[multiPlayerViewController setMainMenuViewController:mainMenuViewController];
	[[multiPlayerViewController view] setAlpha:0];
	[self.view addSubview:[multiPlayerViewController view]];
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
		[[[mainMenuViewController aiWarsViewController] theGame] setRound:1];
		for (Player *p in [[[mainMenuViewController aiWarsViewController] theGame] players])
		{
			[p setRoundsWon:0];
			[p setSurplus:0];
			[p setBotsDestroyed:0];
			[p setBotsKilled:0];
			[p setBotsKilledThisRound:0];
			[p setScore:0];
		}
		[self showMultiPlayerView];
	}
}

- (IBAction)continueGame:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	playSound(clickSound);
	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_MULTIPLAYER];
	[[mainMenuViewController aiWarsViewController] restoreState];
	[mainMenuViewController startMultiPlayer];
}

- (IBAction)quit:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
		
	playSound(clickSound);
	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_MULTIPLAYER];
	[[mainMenuViewController aiWarsViewController] saveState];
	[mainMenuViewController showMainMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
   [super dealloc];
	
}


@end
