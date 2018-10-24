//
//  MainMenuViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/6/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "MainMenuViewController.h"
#import "HumanPlayerViewController.h"
#import "SinglePlayerMenuViewController.h"
#import "SinglePlayerIntroViewController.h"
#import "InstructionsViewController.h"
#import "Player.h"
#import "Sounds.h"

@implementation MainMenuViewController

@synthesize window;
@synthesize singlePlayerButton, multiPlayerButton, instructionsButton, soundButton, unlockButton, toggleMenu;

@synthesize killbotsAnimation;
@synthesize killbotsImage, unlockedImage, pleaseWaitImage;
@synthesize killbotsMainImage;
@synthesize killbotsImages;

@synthesize soundOnImage, soundOffImage;

@synthesize aiWarsViewController;
@synthesize multiPlayerMenuViewController;
@synthesize singlePlayerViewController;
@synthesize humanPlayerViewController;
@synthesize instructionsViewController;

- (void)startKillbotsAnimation
{
	self.killbotsAnimation = [NSTimer scheduledTimerWithTimeInterval:1.0/20.0 target:self selector:@selector(nextKillbotsImage) userInfo:nil repeats:YES];
}

- (void)stopKillbotsAnimation
{
	[self.killbotsAnimation invalidate];
	self.killbotsAnimation = nil;
}

- (void)nextKillbotsImage
{
	UIImage *image;

	currentKillbotsImage--;
	if (currentKillbotsImage < 0)
		currentKillbotsImage = 150;
	//NSLog([NSString stringWithFormat:@"killbots: %i", currentKillbotsImage]);

	if (currentKillbotsImage > 13)
	{
		image = killbotsMainImage;
	}
	else
	{
		image = [killbotsImages objectAtIndex:currentKillbotsImage];
	}
	[killbotsImage setImage:image];
}

- (IBAction)toggleMenu:(id)sender
{
	if (menuShown)
	{
		[self.view setAlpha:0.2];
		menuShown = false;
	}
	else
	{
		[self.view setAlpha:1];
		menuShown = true;
	}
}

- (IBAction)singlePlayer:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	[[singlePlayerViewController view] setAlpha:1.0];
	
	stopSoundLoop(mainMenuSound);
	playSound(clickSound);

	[[aiWarsViewController theGame] setGameType:GAME_TYPE_SINGLEPLAYER];

	[aiWarsViewController restoreState];
	
	if ([[aiWarsViewController theGame] round] < 1)
		[[singlePlayerViewController continueGameButton] setAlpha:0];
	else
		[[singlePlayerViewController continueGameButton] setAlpha:1];
	
	[self showSinglePlayerMenu];
}

- (void)showSinglePlayerIntro
{
	[UIView beginAnimations:@"showSinglePlayerIntro" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[[singlePlayerViewController singlePlayerIntroViewController] view] setAlpha:1];
	[[singlePlayerViewController singlePlayerIntroViewController] setCurrentPage:0];
	[[singlePlayerViewController singlePlayerIntroViewController] setStoryLineForCurrentPage];
	
	[UIView commitAnimations];	
}

- (void)hideSinglePlayerIntro
{
	[singlePlayerViewController setHasSelected:false];
	
	[UIView beginAnimations:@"hideSinglePlayerIntro" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[[singlePlayerViewController singlePlayerIntroViewController] view] setAlpha:0];
	
	[UIView commitAnimations];	
}

- (void)startSinglePlayer
{
	[self setupOpenGLView];
	[self hideSinglePlayerMenu];
	[self hideHumanPlayer];
	
	[aiWarsViewController singlePlayer];
}

- (void)startBonusLevel
{
	[self setupOpenGLView];
	[self hideSinglePlayerMenu];
	[self hideHumanPlayer];
	
	[aiWarsViewController bonusLevel];
}

- (void)stopBonusLevel
{
	[self destroyOpenGLView];
	[self showSinglePlayerMenu];
	[aiWarsViewController hidePauseMenu];	
}

- (void)showSinglePlayerMenu
{
	[singlePlayerViewController setHasSelected:false]; 
	
	[[singlePlayerViewController topScore] setText:[NSString stringWithFormat:@"Personal Best: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerTopScore"]]];
	
	[UIView beginAnimations:@"showSinglePlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//	[UIView setAnimationDidStopSelector:@selector(afterShowMainMenu)];
	[UIView setAnimationDelegate:self];
	
	[singlePlayerViewController.view setAlpha:1];
	
	[UIView commitAnimations];
	[self stopKillbotsAnimation];
	[self destroyOpenGLView];

	playSoundLoop(preBattleSound);
}

- (void)hideSinglePlayerMenu
{
	[self.view setAlpha:0];
	[UIView beginAnimations:@"hideSinglePlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[singlePlayerViewController.view setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)stopSinglePlayer
{
	[aiWarsViewController showStoryLine:0.3];
	[aiWarsViewController hidePauseMenu];	
}

- (void)showHumanPlayer
{
	 [UIView beginAnimations:@"showHumanPlayer1" context:nil];
	 [UIView setAnimationDuration:0.3f];
	 [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	 [UIView setAnimationDelegate:self];
	 
	 [[humanPlayerViewController view] setAlpha:1];
	 
	 [humanPlayerViewController setPlayerIndex:0];
	 [[humanPlayerViewController playerName] setText:[[aiWarsViewController singlePlayerHuman] name]];
	 [humanPlayerViewController setSelectedColor:[[aiWarsViewController colors] indexOfObject:[[aiWarsViewController singlePlayerHuman] color]]];
	 [[humanPlayerViewController colorTable] reloadData];
	 [[humanPlayerViewController colorTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[humanPlayerViewController selectedColor] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	 [humanPlayerViewController setSelectedBase:[[aiWarsViewController singlePlayerHuman] baseTexture]];
	 [[humanPlayerViewController baseTable] reloadData];
	 [[humanPlayerViewController baseTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[humanPlayerViewController selectedBase] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	 [[humanPlayerViewController header] setText:@"Create Player"];
	 [[humanPlayerViewController cancelButton] setTitle:@"Quit" forState:UIControlStateNormal];
	 [humanPlayerViewController updatePreview];
	 
	 [UIView commitAnimations];
	 
}

- (void)hideHumanPlayer
{
	[UIView beginAnimations:@"hideHumanPlayer1" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];

	[[humanPlayerViewController view] setAlpha:0];

	[UIView commitAnimations];
}

///////////////////////////////////////////////////////////////
///MultiPlayer
//////////////////////////////////////////////////////////////

- (IBAction)multiPlayer:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	stopSoundLoop(mainMenuSound);
	playSound(clickSound);
	
	[aiWarsViewController setDoTutorial:false];
	
	[[aiWarsViewController theGame] setGameType:GAME_TYPE_MULTIPLAYER];
	
	[aiWarsViewController restoreState];
	
	[[multiPlayerMenuViewController multiPlayerViewController] updateRounds];
	[[multiPlayerMenuViewController multiPlayerViewController] updateBots];
	
	[self showMultiPlayerMenu];
	
}

- (void)startMultiPlayer
{
	[self setupOpenGLView];
	[self hideMultiPlayerMenu];
	[aiWarsViewController multiPlayer];
}

- (void)stopMultiPlayer
{
	[self destroyOpenGLView];
	[self showMultiPlayerMenu];
	[aiWarsViewController hidePauseMenu];
}

- (void)destroyOpenGLView
{
	//remove the OpenGL view
	[aiWarsViewController stopAnimation];	
	[[aiWarsViewController openGLView] removeFromSuperview];
	[[aiWarsViewController openGLView] setAlpha:0];
}

- (void)setupOpenGLView
{
	//add the OpenGL view
	[window insertSubview:[aiWarsViewController openGLView] belowSubview:self.view];
	[[aiWarsViewController openGLView] clear];
	[aiWarsViewController startAnimation];	
	[[aiWarsViewController openGLView] setAlpha:1];
}

- (void)showMainMenu
{
	hasSelected = false;
	
	[self destroyOpenGLView];
	
	[self.view setAlpha:1];

	[UIView beginAnimations:@"showMainMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[multiPlayerMenuViewController view] setAlpha:0];
	[[singlePlayerViewController view] setAlpha:0];
	[[instructionsViewController view] setAlpha:0];
	[[unlockedViewController view] setAlpha:0];
	
	[UIView commitAnimations];	
	
	stopAllSounds();
	playSoundLoop(mainMenuSound);
	[aiWarsViewController setCurrentFrameRate:30.0];
	[[aiWarsViewController theGame] setGameType:GAME_TYPE_NONE];
	[aiWarsViewController startDemo];
	[self startKillbotsAnimation];
	[self setupOpenGLView];
}

- (void)hideMainMenu
{
	
}


- (void)showMultiPlayerMenu
{
	[multiPlayerMenuViewController setHasSelected:false];
	
	[[[multiPlayerMenuViewController multiPlayerViewController] tableView] reloadData]; 
	
	if ([[aiWarsViewController theGame] round] < 1)
		[[multiPlayerMenuViewController continueGameButton] setAlpha:0];
	else
		[[multiPlayerMenuViewController continueGameButton] setAlpha:1];
		
	[UIView beginAnimations:@"showMultiPlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(afterShowMainMenu)];
	
	[multiPlayerMenuViewController.view setAlpha:1];
	
	[UIView commitAnimations];	

	[self stopKillbotsAnimation];
	[self destroyOpenGLView];
	
	playSoundLoop(preBattleSound);
}

- (void)hideMultiPlayerMenu
{
	[self.view setAlpha:0];
	[multiPlayerMenuViewController.view setAlpha:0];
	
	[UIView beginAnimations:@"hideMultiPlayerMenu" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[[multiPlayerMenuViewController multiPlayerViewController] view] setAlpha:0];
	
	[UIView commitAnimations];	
}

- (void)afterShowMainMenu
{
	[self.view setAlpha:1];
}

- (IBAction)instructions:(id)sender
{
	if (hasSelected)
		return;
	else
		hasSelected = true;
	
	playSound(clickSound);
	[self showInstructions];
}

- (void)showInstructions
{
	[instructionsViewController setCurrentPage:0];
	[instructionsViewController setInstructionsForCurrentPage];
	
	[UIView beginAnimations:@"showInstructions" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	//[UIView setAnimationDidStopSelector:@selector(afterShowMainMenu)];
	[UIView setAnimationDelegate:self];
	
	[instructionsViewController.view setAlpha:1];
	
	[UIView commitAnimations];
	[self stopKillbotsAnimation];
	[self destroyOpenGLView];
}

- (void)showUnlocked
{
	[UIView beginAnimations:@"showUnlocked" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[unlockedViewController.view setAlpha:1];
	
	[UIView commitAnimations];
	[self stopKillbotsAnimation];
	[self destroyOpenGLView];
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		//sounds
		soundIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"soundIsOn"];
		
		soundOnImage = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:@"sounds_on.png"] CGImage]];
		soundOffImage = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:@"sounds_off.png"] CGImage]];
		
		//controller initializations
		aiWarsViewController = [[AiWarsViewController alloc] init];
		[aiWarsViewController setMainMenuViewController:self];
		[aiWarsViewController setCurrentFrameRate:CYCLES_PER_SECOND];
		[[aiWarsViewController frameRateSlider] setValue:CYCLES_PER_SECOND];
		
		multiPlayerMenuViewController = [[MultiPlayerMenuViewController alloc] initWithNibName:@"MultiPlayerMenu" bundle:nil];
		[multiPlayerMenuViewController setMainMenuViewController:self];
		
		singlePlayerViewController = [[SinglePlayerMenuViewController alloc] initWithNibName:@"SinglePlayer" bundle:nil];
		[singlePlayerViewController setMainMenuViewController:self];
		[[singlePlayerViewController singlePlayerIntroViewController] setMainMenuViewController:self];
		
		humanPlayerViewController = [[HumanPlayerViewController alloc] initWithNibName:@"HumanPlayer" bundle:nil];
		[[humanPlayerViewController quitButton] setAlpha:1.0];
		[[humanPlayerViewController startButton] setAlpha:1.0];
		[[humanPlayerViewController cancelButton] setAlpha:0.0];
		[humanPlayerViewController.view sendSubviewToBack:[humanPlayerViewController cancelButton]];
		[[humanPlayerViewController doneButton] setAlpha:0.0];
		[humanPlayerViewController.view sendSubviewToBack:[humanPlayerViewController doneButton]];
		[[humanPlayerViewController deleteButton] setAlpha:0];
		[humanPlayerViewController setMultiPlayerViewController:[multiPlayerMenuViewController multiPlayerViewController]];
		
		instructionsViewController = [[InstructionsViewController alloc] initWithNibName:@"Instructions" bundle:nil];
		[instructionsViewController setMainMenuViewController:self];
		
		unlockedViewController = [[UnlockedViewController alloc] initWithNibName:@"Unlocked" bundle:nil];
		[unlockedViewController setMainMenuViewController:self];
		
		//other initializations
		menuShown = true;
		hasSelected = false;

		//load killbots images
		killbotsMainImage = [[UIImage imageNamed:@"killbots.png"] retain];
		killbotsImages = [[NSMutableArray alloc] initWithCapacity:14];
		for (int i = 0; i < 14; i++)
		{
			//NSLog([NSString stringWithFormat:@"killbots: %i", i]);
			[killbotsImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"killbots%i.png", i]]];
		}
		currentKillbotsImage = 50;
	}
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

/*
 
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

	[soundButton setImage:(soundIsOn?soundOnImage:soundOffImage) forState:UIControlStateNormal];
	
	[unlockButton setImage:[UIImage imageNamed:(liteVersion?@"locked.png":@"unlocked.png")] forState:UIControlStateNormal];
	
	[pleaseWaitImage setAlpha:0];

//	if (!liteVersion)
		[unlockedImage setAlpha:0];
}

- (void)addViews
{
	playSoundLoop(mainMenuSound);
	[self startKillbotsAnimation];
	[aiWarsViewController startDemo];
	[self setupOpenGLView];

	//add the multi player view with alpha 0
	[[multiPlayerMenuViewController view] setAlpha:0];
	[window addSubview:[multiPlayerMenuViewController view]];
	
	[[singlePlayerViewController view] setAlpha:0];
	[window addSubview:[singlePlayerViewController view]];
		
	[[humanPlayerViewController view] setAlpha:0];
	[window addSubview:[humanPlayerViewController view]];

	[[instructionsViewController view] setAlpha:0];
	[window addSubview:[instructionsViewController view]];

	[[unlockedViewController view] setAlpha:0];
	[window addSubview:[unlockedViewController view]];
}

- (IBAction)toggleSound:(id)sender
{
	soundIsOn = !soundIsOn;
	if (soundIsOn)
	{
		playSoundLoop(mainMenuSound);
		[soundButton setImage:soundOnImage forState:UIControlStateNormal];
	}
	else
	{
		stopAllSounds();
		[soundButton setImage:soundOffImage forState:UIControlStateNormal];		
	}
	[[NSUserDefaults standardUserDefaults] setBool:soundIsOn forKey:@"soundIsOn"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
#if TESTING
		[self unlockApp];
#else
		[pleaseWaitImage setAlpha:1];
		NSLog(@"payment");
		if ([SKPaymentQueue canMakePayments])
		{
			NSLog(@"payments are enabled");
			SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"unlocked"];
			NSLog(@"payment created");
			[[SKPaymentQueue defaultQueue] addPayment:payment];
			NSLog(@"payment added");
		}
		else
		{
			NSLog(@"payments are disabled");
		}
#endif
	}
}

- (void)doneWithPurchase
{
	[pleaseWaitImage setAlpha:0];
}

- (void)unlockApp
{
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"liteVersion"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	liteVersion = false;
	[unlockButton setImage:[UIImage imageNamed:@"unlocked.png"] forState:UIControlStateNormal];
	[unlockedImage setAlpha:0];
	[[singlePlayerViewController bonusButton] setAlpha:1];
}

- (IBAction)unlock:(id)sender
{
	playSound(clickSound);

	if (!liteVersion)
	{
		[self showUnlocked];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KillBots is Locked" message:@"Do you wish to unlock for $0.99?\n\nYou will get dozens of bonus levels, additional bot bases, control over resources, and more!" delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:@"No, Thanks", nil];
		[alert show];
		[alert release];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	[self stopKillbotsAnimation];

	[aiWarsViewController release];
	[multiPlayerMenuViewController release];
	[singlePlayerViewController release];
	[humanPlayerViewController release];
    [instructionsViewController release];
	[soundOnImage release];
	[soundOffImage release];
	[killbotsMainImage release];
	[killbotsImages release];
	
	[super dealloc];
}


@end