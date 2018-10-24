//
//  AiWarsViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/11/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "AiWarsViewController.h"
#import "MainMenuViewController.h"
#import "ComputerPlayers.h"
#include <objc/runtime.h>

NSInteger comparePlayersRoundsWon(id obj1, id obj2, void *context)
{
	if ([obj1 roundsWon] < [obj2 roundsWon])
		return NSOrderedDescending;
	if ([obj1 roundsWon] > [obj2 roundsWon])
		return NSOrderedAscending;
	if ([obj1 botsKilled] < [obj2 botsKilled])
		return NSOrderedDescending;
	if ([obj1 botsKilled] > [obj2 botsKilled])
		return NSOrderedAscending;
	return NSOrderedSame;
}


@implementation AiWarsViewController

@synthesize colors;

@synthesize computerPlayers;

@synthesize backgroundFiles;

@synthesize botsPerPlayer;
@synthesize roundType;

@synthesize theGame;

@synthesize singlePlayerHuman;
@synthesize singlePlayerRounds, bonusLevelRounds;
@synthesize doTutorial;
@synthesize tutorialState;
@synthesize tutorialScreen1, tutorialScreen2, tutorialScreen3, tutorialScreen4, tutorialScreen5, tutorialScreen6, tutorialScreen7;

@synthesize totalLevelAttempts;
@synthesize levelAttempts;

@synthesize selectBotTimer;
@synthesize botSelector;
@synthesize currentPlayer;
@synthesize hasSelected;

@synthesize playerWonViewController;
@synthesize gameOverViewController;
@synthesize pauseMenuViewController;
@synthesize mainMenuViewController;
@synthesize singlePlayerWonViewController;

@synthesize quitButtonSender;

@synthesize quitButton, doneButton;
@synthesize frameRateView;
@synthesize frameRateSlider;

//@synthesize lifeBar1, lifeBar2, lifeBar3, lifeBar4;

- (id)init
{
    if (self = [super init])
	{
		currentFrameRate = CYCLES_PER_SECOND;

		//setup colors
		colors = [[NSMutableArray alloc] initWithCapacity:1];
		[colors addObject:COLOR_GREY];			//0
		[colors addObject:COLOR_DARK_GREY];		//1
		[colors addObject:COLOR_BLACK];			//2
		[colors addObject:COLOR_RED];			//3
		[colors addObject:COLOR_MAROON];		//4
		[colors addObject:COLOR_ORANGE];		//5
		[colors addObject:COLOR_YELLOW];		//6
		[colors addObject:COLOR_GOLD];			//7
		[colors addObject:COLOR_LIGHT_GREEN];	//8
		[colors addObject:COLOR_GREEN];			//9
		[colors addObject:COLOR_DARK_GREEN];	//10
		[colors addObject:COLOR_TEAL];			//11
		[colors addObject:COLOR_LIGHT_BLUE];	//12
		[colors addObject:COLOR_BLUE];			//13
		[colors addObject:COLOR_DARK_BLUE];		//14
		[colors addObject:COLOR_PURPLE];		//15
		[colors addObject:COLOR_PINK];			//16
		[colors addObject:COLOR_BROWN];			//17

		//setup computer players
		Player *computerPlayer;
		computerPlayers = [[NSMutableArray alloc] initWithCapacity:1];
		computerPlayer = [[ComputerPlayer1 alloc] initWithColor:[colors objectAtIndex:16]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		computerPlayer = [[ComputerPlayer2 alloc] initWithColor:[colors objectAtIndex:5]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		computerPlayer = [[ComputerPlayer3 alloc] initWithColor:[colors objectAtIndex:9]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		computerPlayer = [[ComputerPlayer4 alloc] initWithColor:[colors objectAtIndex:12]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		computerPlayer = [[ComputerPlayer5 alloc] initWithColor:[colors objectAtIndex:2]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		/*computerPlayer = [[ComputerPlayer6 alloc] initWithColor:[colors objectAtIndex:3]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];
		computerPlayer = [[ComputerPlayer7 alloc] initWithColor:[colors objectAtIndex:3]];
		[computerPlayers addObject:computerPlayer];
		[computerPlayer release];*/
		
		backgroundFiles = [[NSMutableArray alloc] initWithCapacity:1];
		[backgroundFiles addObject:[NSString stringWithString:@"cracked_earth_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"earth_rough2_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"grass_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"lake_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"snow2_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"water_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"paths_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"concrete_floor2_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"beach_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"concrete_floor_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"snow_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"earth_rough_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"sand_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"ice_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"grass2_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"forest_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"mud_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"cracked_earth2_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"manhattan_1024_cutout"]];
		[backgroundFiles addObject:[NSString stringWithString:@"sand2_1024_cutout"]];
		
		
		//setup the game
		botsPerPlayer = 5;
		roundType = ROUND_TYPE_1;
		
		theGame = [[Game alloc] init];
		[theGame setGameMode:GAME_MODE_SELECT];
		[theGame setController:self];
		[theGame setRound:0];
		
		
		//setup game speed slider
		sliderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_red_blue.png"]];
//		sliderImage.transform = CGAffineTransformMakeRotation(M_PI/2);
//		sliderImage.frame = CGRectMake(0, 0, 480, 320);

		frameRateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[frameRateView setBackgroundColor:[UIColor clearColor]];
		[frameRateView setAlpha:0.0];
		frameRateSlider = [[UISlider alloc] initWithFrame:CGRectMake(133, 440, 187, 40)];
		[frameRateSlider setMinimumValue:8];
		[frameRateSlider setMaximumValue:60];
		[frameRateSlider setValue:currentFrameRate];
		[frameRateSlider addTarget:self action:@selector(frameRateSliderChange) forControlEvents:UIControlEventValueChanged];
		[frameRateSlider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
		[frameRateSlider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateHighlighted];
		UIImage *stretchLeftTrack = [[UIImage imageNamed:@"slide_light_grey.png"]
									 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
		UIImage *stretchRightTrack = [[UIImage imageNamed:@"slide_light_grey.png"]
									  stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
		[frameRateSlider setMinimumTrackImage:nil forState:UIControlStateNormal];
		[frameRateSlider setMaximumTrackImage:nil forState:UIControlStateNormal];
		[frameRateView addSubview:sliderImage];
		[frameRateView addSubview:frameRateSlider];
		[openGLView addSubview:frameRateView];
		
		//create human player
		singlePlayerHuman = [[Player alloc] init];
		[singlePlayerHuman setName:@""];
		[singlePlayerHuman setColor:[colors objectAtIndex:4]];
		[singlePlayerHuman setBaseTexture:0];
		
		//setup single player rounds
		singlePlayerRounds = [[SinglePlayerRounds alloc] init];
		[singlePlayerRounds setAiWarsViewController:self];
		[[singlePlayerRounds storyLineViewController] setAiWarsViewController:self];
		[[singlePlayerRounds storyLineViewController].view setAlpha:0];
		[singlePlayerRounds storyLineViewController].view.frame = CGRectMake(-80, 80, 480, 320);
		[singlePlayerRounds storyLineViewController].view.transform = CGAffineTransformMakeRotation(M_PI/2);
		[openGLView addSubview:[[singlePlayerRounds storyLineViewController] view]];
		
		//setup bonus level rounds
		bonusLevelRounds = [[BonusLevelRounds alloc] init];
		[bonusLevelRounds setAiWarsViewController:self];
		[bonusLevelRounds setSinglePlayerRounds:singlePlayerRounds];


		//setup status bar
		statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 480)];
		[statusBar setBackgroundColor:[UIColor clearColor]];
		[statusBar setAlpha:0.0];
		[openGLView addSubview:statusBar];

		//player name
		playerName = [[UILabel alloc] initWithFrame:CGRectMake(-90, 226, 220, 28)];
		playerName.transform = CGAffineTransformMakeRotation(M_PI/2);
		[playerName setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
		[playerName setText:@"Player Name"];
		[playerName setFont:[UIFont boldSystemFontOfSize:18]];
		[playerName setTextColor:[UIColor whiteColor]];
		[playerName setTextAlignment:UITextAlignmentCenter];
		[playerName setShadowColor:[UIColor blackColor]];
		[playerName setShadowOffset:CGSizeMake(2, 2)];
		[statusBar addSubview:playerName];

		//setup quit button
		quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[quitButton setFrame:CGRectMake(-40, 50, 120, 30)];
		quitButton.transform = CGAffineTransformMakeRotation(M_PI/2);
		[quitButton setTitle:@"Quit" forState:UIControlStateNormal];
		[quitButton setFont:[UIFont boldSystemFontOfSize:14]];
		[quitButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
		[quitButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateHighlighted];
		quitButton.titleShadowOffset = CGSizeMake (1.0, 1.0);
		[quitButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
		[quitButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[quitButton setBackgroundColor:[UIColor clearColor]];
		[quitButton setBackgroundImage:[UIImage imageNamed:@"button3.png"] forState:UIControlStateNormal];
		[quitButton setBackgroundImage: [UIImage imageNamed:@"button2_down.png"] forState:UIControlStateHighlighted];
		[quitButton addTarget:self action:@selector(quitGame:) forControlEvents:UIControlEventTouchUpInside];
		[statusBar addSubview:quitButton];
		
		//setup done button
		doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[doneButton setFrame:CGRectMake(-40, 405, 120, 30)];
		doneButton.transform = CGAffineTransformMakeRotation(M_PI/2);
		[doneButton setTitle:@"Done" forState:UIControlStateNormal];
		[doneButton setFont:[UIFont boldSystemFontOfSize:14]];
		[doneButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateHighlighted];
		doneButton.titleShadowOffset = CGSizeMake (1.0, 1.0);
		[doneButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
		[doneButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[doneButton setBackgroundColor:[UIColor clearColor]];
		[doneButton setBackgroundImage:[UIImage imageNamed:@"button2.png"] forState:UIControlStateNormal];
		[doneButton setBackgroundImage: [UIImage imageNamed:@"button2_down.png"] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneSelecting) forControlEvents:UIControlEventTouchUpInside];
		[statusBar addSubview:doneButton];

		//round/level
		roundLevel = [[UILabel alloc] initWithFrame:CGRectMake(252, 50, 112, 22)];
		roundLevel.transform = CGAffineTransformMakeRotation(M_PI/2);
		[roundLevel setBackgroundColor:[UIColor clearColor]];
		[roundLevel setFont:[UIFont boldSystemFontOfSize:18]];
		[roundLevel setTextColor:[UIColor whiteColor]];
		[roundLevel setShadowColor:[UIColor blackColor]];
		[roundLevel setShadowOffset:CGSizeMake(1, 1)];
		[roundLevel setAlpha:0.0];
		[openGLView addSubview:roundLevel];
		
		//setup life bars
		/*lifeBar1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 120)];
		[lifeBar1 setBackgroundColor:[UIColor whiteColor]];
		[lifeBar1 setAlpha:0];
		[openGLView addSubview:lifeBar1];

		lifeBar2 = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 40, 120)];
		[lifeBar2 setBackgroundColor:[UIColor whiteColor]];
		[lifeBar2 setAlpha:0];
		[openGLView addSubview:lifeBar2];

		lifeBar3 = [[UIView alloc] initWithFrame:CGRectMake(0, 240, 40, 120)];
		[lifeBar3 setBackgroundColor:[UIColor whiteColor]];
		[lifeBar3 setAlpha:0];
		[openGLView addSubview:lifeBar3];

		lifeBar4 = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 40, 120)];
		[lifeBar4 setBackgroundColor:[UIColor whiteColor]];
		[lifeBar4 setAlpha:0];
		[openGLView addSubview:lifeBar4];*/

		//setup bot selecting
		movingToBot = NULL;
		selecting = NO;
		botSelector = [[BotSelectorViewController alloc] initWithNibName:@"BotSelector" bundle:nil];
		[botSelector setAiWarsViewController:self];
		[botSelector.view setAlpha:0];
		[openGLView addSubview:[botSelector view]];

		//setup player won
		playerWonViewController = [[PlayerWonViewController alloc] initWithNibName:@"PlayerWon" bundle:nil];
		[playerWonViewController setAiWarsViewController:self];
		[playerWonViewController.view setAlpha:0];
		playerWonViewController.view.frame = CGRectMake(-80, 80, 480, 320);
		playerWonViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
		[openGLView addSubview:[playerWonViewController view]];
		
		//setup single player won
		singlePlayerWonViewController = [[SinglePlayerWonViewController alloc] initWithNibName:@"SinglePlayerWon" bundle:nil];
		[singlePlayerWonViewController setAiWarsViewController:self];
		[singlePlayerWonViewController.view setAlpha:0];
		singlePlayerWonViewController.view.frame = CGRectMake(-80, 80, 480, 320);
		singlePlayerWonViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
		[openGLView addSubview:[singlePlayerWonViewController view]];
		
		//setup game over
		gameOverViewController = [[GameOverViewController alloc] initWithNibName:@"GameOver" bundle:nil];
		[gameOverViewController setAiWarsViewController:self];
		[gameOverViewController.view setAlpha:0];
		gameOverViewController.view.frame = CGRectMake(-80, 80, 480, 320);
		gameOverViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
		[openGLView addSubview:[gameOverViewController view]];
		
		//setup countdown view
		countdownView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[countdownView setBackgroundColor:[UIColor clearColor]];
		[countdownView setAlpha:0];
		[openGLView addSubview:countdownView];

		//countdown image
		countdownImage = [[UIImageView alloc] initWithFrame:CGRectMake(32, 115, 256, 256)];
		[countdownView addSubview:countdownImage];
		
		//setup pause menu
		pauseMenuViewController = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenu" bundle:nil];
		[pauseMenuViewController setAiWarsViewController:self];
		[pauseMenuViewController.view setAlpha:0];
		pauseMenuViewController.view.frame = CGRectMake(-80, 80, 480, 320);
		pauseMenuViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
		[openGLView addSubview:[pauseMenuViewController view]];		

		//tutorial
		doTutorial = false;
		tutorialState = 0;
		
		tutorialScreen1 = [[UIImageView alloc] initWithFrame:CGRectMake(164, 182, 137, 265)];
		[tutorialScreen1 setImage:[UIImage imageNamed:@"tutorial1.png"]];
		[tutorialScreen1 setAlpha:0];
		[openGLView addSubview:tutorialScreen1];
		
		tutorialScreen2 = [[UIImageView alloc] initWithFrame:CGRectMake(108, 302, 88, 153)];
		[tutorialScreen2 setImage:[UIImage imageNamed:@"tutorial2a.png"]];
		[tutorialScreen2 setAlpha:0];
		[openGLView addSubview:tutorialScreen2];

		tutorialScreen3 = [[UIImageView alloc] initWithFrame:CGRectMake(67, 172, 69, 278)];
		[tutorialScreen3 setImage:[UIImage imageNamed:@"tutorial2b.png"]];
		[tutorialScreen3 setAlpha:0];
		[openGLView addSubview:tutorialScreen3];

		tutorialScreen4 = [[UIImageView alloc] initWithFrame:CGRectMake(23, 179, 79, 218)];
		[tutorialScreen4 setImage:[UIImage imageNamed:@"tutorial2c.png"]];
		[tutorialScreen4 setAlpha:0];
		[openGLView addSubview:tutorialScreen4];

		tutorialScreen5 = [[UIImageView alloc] initWithFrame:CGRectMake(148, 175, 91, 224)];
		[tutorialScreen5 setImage:[UIImage imageNamed:@"tutorial2d.png"]];
		[tutorialScreen5 setAlpha:0];
		[openGLView addSubview:tutorialScreen5];

		tutorialScreen6 = [[UIImageView alloc] initWithFrame:CGRectMake(33, 286, 126, 180)];
		[tutorialScreen6 setImage:[UIImage imageNamed:@"tutorial2e.png"]];
		[tutorialScreen6 setAlpha:0];
		[openGLView addSubview:tutorialScreen6];
		
		tutorialScreen7 = [[UIImageView alloc] initWithFrame:CGRectMake(25, 238, 266, 211)];
		[tutorialScreen7 setImage:[UIImage imageNamed:@"tutorial3.png"]];
		[tutorialScreen7 setAlpha:0];
		[openGLView addSubview:tutorialScreen7];
		
		totalLevelAttempts = 0;
		//[self restoreState];
	}
    return self;
}

- (void)hideTutorial
{
	[UIView beginAnimations:@"hideTutorial" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];

	[tutorialScreen1 setAlpha:0];
	[tutorialScreen2 setAlpha:0];
	[tutorialScreen3 setAlpha:0];
	[tutorialScreen4 setAlpha:0];
	[tutorialScreen5 setAlpha:0];
	[tutorialScreen6 setAlpha:0];
	[tutorialScreen7 setAlpha:0];

	[UIView commitAnimations];
}

- (void)showTutorial:(int)screen
{
	[UIView beginAnimations:@"showTutorial" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	switch(screen)
	{
		case 1:
			[tutorialScreen1 setAlpha:1];
			break;
		case 2:
			[tutorialScreen2 setAlpha:1];
			break;
		case 3:
			[tutorialScreen3 setAlpha:1];
			break;
		case 4:
			[tutorialScreen4 setAlpha:1];
			break;
		case 5:
			[tutorialScreen5 setAlpha:1];
			break;
		case 6:
			[tutorialScreen6 setAlpha:1];
			break;
		case 7:
			[tutorialScreen7 setAlpha:1];
			break;
	}

	[UIView commitAnimations];
}

- (void)frameRateSliderChange
{
	[self stopAnimation];
	currentFrameRate = [frameRateSlider value];
	[self startAnimation];
}

- (int)fundsForMultiRound
{
	int initialFunds = 1500;
	if (!liteVersion)
		initialFunds = [[NSUserDefaults standardUserDefaults] integerForKey:@"multiplayerStart"];

	int funds = roundToHundreds((int)(pow(1.5, [theGame round])*initialFunds));
	
	//cap the funds at 1999999999
	if (funds > 1999999999 || funds < 0)
		return  1999999999;
	return funds;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		stopSoundLoop(preBattleSound);	
	
		if (quitButtonSender == quitButton)
		{
			[self saveState];
			[mainMenuViewController stopMultiPlayer];
			[[[[self mainMenuViewController] multiPlayerMenuViewController] continueGameButton] setAlpha:1];
			[self hideStatusBar];
		}
		
		if (quitButtonSender == [[singlePlayerRounds storyLineViewController] quitButton])
		{
			[self saveState];
			[self hideStoryLine];
			[[self mainMenuViewController] destroyOpenGLView];
			[[[[self mainMenuViewController] singlePlayerViewController] view] setAlpha:1];
			[[[[self mainMenuViewController] singlePlayerViewController] continueGameButton] setAlpha:1];
			[[self mainMenuViewController] showSinglePlayerMenu];
			[[singlePlayerRounds configuration] removeAllObjects];
		}
		
		if (quitButtonSender == [pauseMenuViewController quitButton])
		{
			[self hidePauseMenu];
			
			if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
			{
				[[self mainMenuViewController] stopMultiPlayer];
			}
			else if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
			{
				[self saveState];
				[[self mainMenuViewController] destroyOpenGLView];
				[[[[self mainMenuViewController] singlePlayerViewController] view] setAlpha:1];
				[[[[self mainMenuViewController] singlePlayerViewController] continueGameButton] setAlpha:1];
				[[self mainMenuViewController] showSinglePlayerMenu];
				[[singlePlayerRounds configuration] removeAllObjects];
			}
			else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL)
			{
				[[self mainMenuViewController] destroyOpenGLView];
				[[[[self mainMenuViewController] singlePlayerViewController] view] setAlpha:1];
				[[[[self mainMenuViewController] singlePlayerViewController] continueGameButton] setAlpha:1];
				[[self mainMenuViewController] showSinglePlayerMenu];
				[[bonusLevelRounds configuration] removeAllObjects];
			}
			
		}
		
		/*if (quitButtonSender == [gameOverViewController continueButton])
		{
			[self hideGameOver];
			[[self theGame] setRound:1];
			[[self mainMenuViewController] destroyOpenGLView];
			[[self mainMenuViewController] setupOpenGLView];
			if ([[self theGame] gameType] == GAME_TYPE_SINGLEPLAYER)
				[self singlePlayer];
			else
				[self multiPlayer];
		}*/
		
	}
	else
	{
		[[singlePlayerRounds storyLineViewController] setHasSelected:false];
	}
}

- (void)saveState
{
	[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"shouldRestore"];
	
	[[NSUserDefaults standardUserDefaults] setBool:soundIsOn forKey:@"soundIsOn"];

	if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:[theGame round] forKey:@"multiPlayerRound"];
		[[NSUserDefaults standardUserDefaults] setInteger:[[theGame players] count] forKey:@"theGamePlayersCount"];
		for (int i = 0; i < [[theGame players] count]; i++)
		{
			Player *p = [[theGame players] objectAtIndex:i];
			[[NSUserDefaults standardUserDefaults] setObject:[p name] forKey:[NSString stringWithFormat:@"playerName%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[colors indexOfObject:[p color]] forKey:[NSString stringWithFormat:@"playerColorIndex%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[p baseTexture] forKey:[NSString stringWithFormat:@"playerBaseTexture%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[p botsKilled] forKey:[NSString stringWithFormat:@"playerBotsKilled%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[p botsKilledThisRound] forKey:[NSString stringWithFormat:@"playerBotsKilledThisRound%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[p botsDestroyed] forKey:[NSString stringWithFormat:@"playerBotsDestroyed%d",i]];
			switch ([theGame gameMode])
			{
				case GAME_MODE_BATTLE_FINISHED:
					[[NSUserDefaults standardUserDefaults] setInteger:[p funds] forKey:[NSString stringWithFormat:@"playerFunds%d",i]];
					break;
				case GAME_MODE_BATTLE: 
				case GAME_MODE_SELECT:
				case GAME_MODE_NONE:
					[[NSUserDefaults standardUserDefaults] setInteger:[self fundsForMultiRound] forKey:[NSString stringWithFormat:@"playerFunds%d",i]];
					break;

			}
			[[NSUserDefaults standardUserDefaults] setFloat:[p roundsWon] forKey:[NSString stringWithFormat:@"playerRoundsWon%d",i]];
			[[NSUserDefaults standardUserDefaults] setInteger:[p isComputer] forKey:[NSString stringWithFormat:@"playerIsComputer%d",i]];
		}
	
		[[NSUserDefaults standardUserDefaults] setInteger:botsPerPlayer forKey:@"botsPerPlayer"];
		[[NSUserDefaults standardUserDefaults] setInteger:roundType forKey:@"roundType"];
	}
	else if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[singlePlayerHuman name] forKey:@"singlePlayerHumanName"];
		[[NSUserDefaults standardUserDefaults] setInteger:[colors indexOfObject:[singlePlayerHuman color]] forKey:@"singlePlayerHumanColorIndex"];
		[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman baseTexture] forKey:@"singlePlayerHumanBaseTexture"];
		[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman botsKilled] forKey:@"singlePlayerHumanBotsKilled"];
		[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman botsKilledThisRound] forKey:@"singlePlayerHumanBotsKilledThisRound"];
		[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman botsDestroyed] forKey:@"singlePlayerHumanBotsDestroyed"];
		[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman score] forKey:@"singlePlayerHumanScore"];
		[[NSUserDefaults standardUserDefaults] setFloat:[singlePlayerHuman roundsWon] forKey:@"singlePlayerHumanRoundsWon"];
		[[NSUserDefaults standardUserDefaults] setInteger:[theGame round] forKey:@"singlePlayerRound"];
		[[NSUserDefaults standardUserDefaults] setInteger:([singlePlayerRounds wonLastRound]?[singlePlayerHuman surplus]:0) forKey:@"singlePlayerSurplus"];
		[[NSUserDefaults standardUserDefaults] setBool:[singlePlayerRounds wonLastRound] forKey:@"singlePlayerWonLastRound"];
		[[NSUserDefaults standardUserDefaults] setInteger:levelAttempts forKey:@"levelAttempts"];
		[[NSUserDefaults standardUserDefaults] setInteger:totalLevelAttempts forKey:@"totalLevelAttempts"];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreState
{
	bool shouldRestore = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldRestore"];
	
	botsPerPlayer = 5;
	roundType = ROUND_TYPE_5;
	
	if (shouldRestore)
	{
		[self resetObjects];
		
		soundIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"soundIsOn"];

		if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
		{
			[theGame setRound:[[NSUserDefaults standardUserDefaults] integerForKey:@"multiPlayerRound"]];
			
			int numPlayers = [[NSUserDefaults standardUserDefaults] integerForKey:@"theGamePlayersCount"];
			
			[[theGame players] removeAllObjects];
			
			if (numPlayers)
			{
				for (int i = 0; i < numPlayers; i++)
				{
					int isComputerVal = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerIsComputer%d",i]];
					if (isComputerVal >= 0)
						[[theGame players] insertObject:[computerPlayers objectAtIndex:isComputerVal] atIndex:i];
					else
						[[theGame players] insertObject:[[Player alloc] init] atIndex:i];
					
					Player *p = [[theGame players] objectAtIndex:i];
					
					[p setName:(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"playerName%d",i]]];
					[p setColor:[colors objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerColorIndex%d",i]]]];
					[p setBaseTexture:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerBaseTexture%d",i]]];
					[p setBotsKilled:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerBotsKilled%d",i]]];
					[p setBotsKilledThisRound:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerBotsKilledThisRound%d",i]]];
					[p setBotsDestroyed:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerBotsDestroyed%d",i]]];
					[p setFunds:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"playerFunds%d",i]]];
					[p setRoundsWon:[[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"playerRoundsWon%d",i]]];
					[p setIsComputer:isComputerVal];
				}
			}
			else
			{
				
				Player *player;
				player = [[Player alloc] init];
				[player setName:@"Player 1"];
				[player setColor:[colors objectAtIndex:random()%[colors count]]];
				[player setBaseTexture:random()%(liteVersion?TEXTURE_BASE_NUM:TEXTURE_BASE_UNLOCKED_NUM)];
				[[theGame players] addObject:player];
				[player release];
					
				player = [[Player alloc] init];
				[player setName:@"Player 2"];
				do 
				{
					[player setColor:[colors objectAtIndex:random()%[colors count]]];
				}while((Color *)[player color] == (Color *)[[[theGame players] objectAtIndex:0] color]);
				[player setBaseTexture:random()%(liteVersion?TEXTURE_BASE_NUM:TEXTURE_BASE_UNLOCKED_NUM)];
				[[theGame players] addObject:player];
				[player release];
				
			}

			botsPerPlayer = [[NSUserDefaults standardUserDefaults] integerForKey:@"botsPerPlayer"];
			roundType = [[NSUserDefaults standardUserDefaults] integerForKey:@"roundType"];
		}
		else if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
		{
			[singlePlayerHuman setName:(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"singlePlayerHumanName"]];
			[singlePlayerHuman setColor:[colors objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanColorIndex"]]];
			[singlePlayerHuman setBaseTexture:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanBaseTexture"]];
			[singlePlayerHuman setBotsKilled:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanBotsKilled"]];
			[singlePlayerHuman setBotsKilledThisRound:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanBotsKilledThisRound"]];
			[singlePlayerHuman setBotsDestroyed:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanBotsDestroyed"]];
			[singlePlayerHuman setScore:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerHumanScore"]];
			[singlePlayerHuman setRoundsWon:[[NSUserDefaults standardUserDefaults] floatForKey:@"singlePlayerHumanRoundsWon"]];
			[theGame setRound:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerRound"]];
			[singlePlayerHuman setSurplus:[[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerSurplus"]];
			[singlePlayerRounds setWonLastRound:[[NSUserDefaults standardUserDefaults] boolForKey:@"singlePlayerWonLastRound"]];
			[singlePlayerHuman setFunds:[singlePlayerHuman surplus]];
			levelAttempts = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelAttempts"];
			totalLevelAttempts = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalLevelAttempts"];
//			[theGame setRound:20];
		}
	}
	
	if (botsPerPlayer == 0)
	{
		botsPerPlayer = 5;
		roundType = ROUND_TYPE_5;
	}
}

- (void)copyBot:(Bot *)toBot fromBot:(Bot *)fromBot
{
	Bot *tmpBot = [toBot copy];
	memcpy(toBot, fromBot, class_getInstanceSize([Bot class]));
	[toBot setX:[tmpBot x]];
	[toBot setY:[tmpBot y]];
	[toBot setZ:[tmpBot z]];
	[toBot setColor:[tmpBot color]];
	[toBot setCurrentMovement:[tmpBot currentMovement]];
	[toBot setBaseTexture:[tmpBot baseTexture]];
	[toBot setPlayer:[tmpBot player]];
	[toBot setComputer:[tmpBot computer]];
	[toBot setController:[tmpBot controller]];
	[tmpBot release];
}

- (void)resetObjects
{
	if ([updateable_objects indexOfObject:theGame] == NSNotFound)
		[self addUpdateableObject:theGame];
	
	NSMutableArray *exceptionList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:theGame, nil]];
	[self removeAllDrawableObjects:exceptionList];
	[self removeAllUpdateableObjects:exceptionList];
	[self removeAllTouchableObjects:exceptionList];
	[exceptionList release];
	
	[openGLView setX:0];
	[openGLView setY:0];
	[openGLView setZ:0];
	[frameRateView setAlpha:1];
}

- (void)explosionAtX:(float)x Y:(float)y withColor:(Color *)c withRadius:(float)r
{
	Explosion *explosion = [[Explosion alloc] initAtX:x Y:y Color:c Radius:r];
	[self addDrawableObject:explosion];
	[explosion release];
}

- (void)startDemo
{
	if (!demo)
	{
		[theGame setGameType:GAME_TYPE_NONE];
		unloadTexture(&textureBackground);
		loadPVRTexture([backgroundFiles objectAtIndex:random()%(int)[backgroundFiles count]], &textureBackground);
	}
	
	demo = true;

	[theGame setGameMode:GAME_MODE_SELECT];
	[self resetObjects];
	[frameRateView setAlpha:0];

	for (Player *p in [theGame players])
		[[p bots] removeAllObjects];
	
	[[theGame players] removeAllObjects];	
	
	Player *player;
	player = [[Player alloc] init];
	[player setName:@"Player 1"];
	[player setColor:[colors objectAtIndex:random()%(int)[colors count]]];
	[player setBaseTexture:random()%(liteVersion?TEXTURE_BASE_NUM:TEXTURE_BASE_UNLOCKED_NUM)];
	[[theGame players] addObject:player];
	[player release];
	
	player = [[Player alloc] init];
	[player setName:@"Player 2"];
	do 
	{
		[player setColor:[colors objectAtIndex:random()%(int)[colors count]]];
	}while((Color *)[player color] == (Color *)[[[theGame players] objectAtIndex:0] color]);
	[player setBaseTexture:random()%(liteVersion?TEXTURE_BASE_NUM:TEXTURE_BASE_UNLOCKED_NUM)];
	[[theGame players] addObject:player];
	[player release];
	
	[self setBotsPerPlayer:3];
	
	Bot *bot, *targetBot = NULL;
	for (int p = 0; p < [[theGame players] count]; p++)
	{
		player = [[theGame players] objectAtIndex:p];
		[[player bots] removeAllObjects];
		for (int i = 0; i < botsPerPlayer; i++)
		{
			bot = [[[botSelector botTypes] objectAtIndex:random()%11] copy];
			
			if (bot)
			{
				[bot setX:-.5+p+slyRandom(-0.2, 0.2) Y:0+slyRandom(-0.2, 0.2) Z:-1.8];
				[bot setColor:[player color]];
				[bot setBaseTexture:[player baseTexture]];
				if (targetBot)
				{
					[bot setTargetLocking:YES];
					[bot setTarget:targetBot];
				}
				[bot setCurrentMovement:MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY];
				[bot setController:self];
				[self addBot:bot forPlayer:p];
				[bot release];
			}
		}
	}
	
	[theGame setGameMode:GAME_MODE_BATTLE];
}


- (void)setupBotsPositions
{
	int playerCount = [[theGame players] count];
	float centersForPlayers[playerCount][2];
	int positionsForPlayers[playerCount];
	Player *player, *player2;
	Bot *bot, *bot2;
	float diffx, diffy;
	bool tooClose = false;
	for (int p = 0; p < playerCount; p++)
	{
		do
		{
			positionsForPlayers[p] = random()%6;
			tooClose = false;
			for (int i = 0; i < playerCount; i++)
			{
				if (i != p)
				{
					if (positionsForPlayers[i] == positionsForPlayers[p])
					{	
						tooClose = true;
					}
				}
			}
		}while (tooClose);
		
		switch(positionsForPlayers[p])
		{
			case 0:
				centersForPlayers[p][0] = slyRandom(LOWER_X, LOWER_X+0.2);
				centersForPlayers[p][1] = slyRandom(LOWER_Y, LOWER_Y+0.2);
				break;
			case 1:
				centersForPlayers[p][0] = slyRandom(UPPER_X-0.2, UPPER_X);
				centersForPlayers[p][1] = slyRandom(LOWER_Y, LOWER_Y+0.2);
				break;
			case 2:
				centersForPlayers[p][0] = slyRandom(LOWER_X, LOWER_X+0.2);
				centersForPlayers[p][1] = slyRandom(UPPER_Y-0.45, UPPER_Y-.25); //adjusted for the round/level
				break;
			case 3:
				centersForPlayers[p][0] = slyRandom(UPPER_X-0.25, UPPER_X-0.25); //adjusted slightly as to not be under the frame rate slider
				centersForPlayers[p][1] = slyRandom(UPPER_Y-0.2, UPPER_Y);
				break;
			case 4:
				centersForPlayers[p][0] = slyRandom(-0.2, 0.2);
				centersForPlayers[p][1] = slyRandom(LOWER_Y, LOWER_Y+0.2);
				break;
			case 5:
				centersForPlayers[p][0] = slyRandom(-0.2, 0.2);
				centersForPlayers[p][1] = slyRandom(UPPER_Y-0.2, UPPER_Y);
				break;
		};
		
		player = [[theGame players] objectAtIndex:p];
		for (int i = 0; i < [[player bots] count]; i++)
		{
			bot = [[player bots] objectAtIndex:i];
			[bot setX:centersForPlayers[p][0]+slyRandom(-0.2, 0.2) Y:centersForPlayers[p][1]+slyRandom(-0.2, 0.2) Z:-1.8];
		}
	}
	
	//reposition the bots to make sure they are not too close to each other
	for (int p = 0; p < [[theGame players] count]; p++)
	{
		player = [[theGame players] objectAtIndex:p];
		for (int i = 0; i < [[player bots] count]; i++)
		{
			bot = [[player bots] objectAtIndex:i];
			do
			{
				tooClose = false;
				for (int p2 = 0; p2 < [[theGame players] count]; p2++)
				{
					player2 = [[theGame players] objectAtIndex:p2];
					for (int i2 = 0; i2 < [[player2 bots] count]; i2++)
					{
						bot2 = [[player2 bots] objectAtIndex:i2];
						if (bot2 == bot)
							break;
						
						diffx = [bot2 x] - [bot x];
						diffy = [bot2 y] - [bot y];
						if (diffx*diffx+diffy*diffy < 0.025)
							tooClose = true;
					}
				}
				if (tooClose)
				{
					NSLog(@""); //prevents weird fucking error when you do a release compile
					[bot setX:centersForPlayers[p][0]+slyRandom(-0.3, 0.3) Y:centersForPlayers[p][1]+slyRandom(-0.3, 0.3) Z:-1.8];
				}
			} while (tooClose);
		}
	}
}


- (void)singlePlayer
{
	demo = false;
	
	[[playerWonViewController view] setAlpha:0];
	[[singlePlayerWonViewController view] setAlpha:0];
	[[pauseMenuViewController view] setAlpha:0];
	
	[quitButton setTitle:@"Back" forState:UIControlStateNormal];
	[doneButton setTitle:@"Fight!" forState:UIControlStateNormal];
	
	[self startSinglePlayerRound];
}

- (void)startSinglePlayerRound
{	
	//[self resetLifeBars];
	[self startSelecting];
	
	[doneButton setAlpha:0];
	
	[self resetObjects];
	
	[roundLevel setText:[NSString stringWithFormat:@"Level %i", [theGame round]]];

	[theGame setGameMode:GAME_MODE_SELECT];

	currentPlayer = 0;
	[playerName setText:[singlePlayerHuman name]];
	
	botZ = 0;
	
	if (![singlePlayerRounds setupRound:[theGame round]])
	{
		[self showGameOver];
		[self stopAnimation];
	}
	else
	{
		playSoundLoop(preBattleSound);
		[self showStoryLine:0.0];
	}
}

- (void)bonusLevel
{
	demo = false;
	
	[[playerWonViewController view] setAlpha:0];
//	[[singlePlayerWonViewController view] setAlpha:0];
	[[pauseMenuViewController view] setAlpha:0];
	
	[quitButton setTitle:@"Back" forState:UIControlStateNormal];
	[doneButton setTitle:@"Fight!" forState:UIControlStateNormal];
	
	[self startBonusLevelRound];
}

- (void)startBonusLevelRound
{	
	[self showStatusBar];
	[self startSelecting];
	
	[doneButton setAlpha:0];
	
	[self resetObjects];
	
	[roundLevel setText:[NSString stringWithFormat:@"Level %i", [theGame round]]];
	
	[theGame setGameMode:GAME_MODE_SELECT];
	
	currentPlayer = 0;
	if ([singlePlayerHuman name] == nil || [[singlePlayerHuman name] isEqualToString:@""])
		[singlePlayerHuman setName:@"Player 1"];
	[playerName setText:[singlePlayerHuman name]];
	
	botZ = 0;
	
	[bonusLevelRounds setupRound:[theGame round]];
	
	//for random clumpped positions like multiplayer
	[self setupBotsPositions];
	
	playSoundLoop(preBattleSound);
}

- (void)multiPlayer
{
	demo = false;
	//[theGame setRound:1];

	[[playerWonViewController view] setAlpha:0];
	[[singlePlayerWonViewController view] setAlpha:0];
	[[pauseMenuViewController view] setAlpha:0];
	
	for (int i = 0; i < [[theGame players] count]; i++)
	{
		Player *p = [[theGame players] objectAtIndex:i];
		//make a copy of the computer player only one time.
		if ([p isComputer] >= 0)
			[[theGame players] replaceObjectAtIndex:i withObject:[p copy]];
	}
	
	[quitButton setTitle:@"Quit" forState:UIControlStateNormal];
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	
	[self startMultiPlayerRound];
}

- (void)startMultiPlayerRound
{
	//		glGenTextures(1, &textureBackground);
	//		glBindTexture(GL_TEXTURE_2D, textureBackground);
/*
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	pvrTexture = [PVRTexture pvrTextureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arena1" ofType:@"pvr"]];
	[pvrTexture retain];
	if (pvrTexture == nil)
		NSLog(@"Failed to load pvr");
	else
		textureBackground = [pvrTexture name];
*/	
	/*
	 NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arena1" ofType:@"pvr"]];
	 texImage2DPVRTC(0, 4, YES, 512, 512, [data bytes]);
	 */		
	[self startSelecting];

	[doneButton setAlpha:0];
	
	unloadTexture(&textureBackground);
	loadPVRTexture([backgroundFiles objectAtIndex:random()%(int)[backgroundFiles count]], &textureBackground);
//	loadTexture([backgroundFiles objectAtIndex:random()%[backgroundFiles count]], &textureBackground);
	
	//[self resetLifeBars];
	
	//if ([theGame round] <= 5)
	//	[theGame setRound:5];
	
	[self resetObjects];
	
	[roundLevel setText:[NSString stringWithFormat:@"Round %i", [theGame round]]];

	bool isFinished = false;
	switch (roundType)
	{
		case ROUND_TYPE_1:
			if ([theGame round] > 1)
				isFinished = true;
			break;
		case ROUND_TYPE_2:
			if ([theGame round] > 2)
				isFinished = true;
			break;
		case ROUND_TYPE_5:
			if ([theGame round] > 5)
				isFinished = true;
			break;
		case ROUND_TYPE_10:
			if ([theGame round] > 10)
				isFinished = true;
			break;
		case ROUND_TYPE_INF:
			isFinished = false;
			break;
	}
	
	if (isFinished)
	{
		[self showGameOver];
		return;
	}
	else
	{
		[self showStatusBar];
	}	
	
	[theGame setGameMode:GAME_MODE_SELECT];
	
	int initialFunds = 1500;
	if (!liteVersion)
		initialFunds = [[NSUserDefaults standardUserDefaults] integerForKey:@"multiplayerStart"];
	
	currentPlayer = -1;
	for (int i = 0; i < [[theGame players] count]; i++)
	{
		//find the first human player
		if (!([[[theGame players] objectAtIndex:i] isComputer] >= 0) && currentPlayer < 0)
			currentPlayer = i;
		
#if !TESTING
		//set the funds for the first round
		if ([theGame round] == 1)
			[[[theGame players] objectAtIndex:i] setFunds:initialFunds];
#else
		if ([theGame round] == 1)
			[[[theGame players] objectAtIndex:i] setFunds:1000000000];		
#endif
	}	
	
	[playerName setText:[[[theGame players] objectAtIndex:currentPlayer] name]];
	
	//add bots to players
	Player *player;
	Bot *bot;
	int playerCount = [[theGame players] count];
	
	botZ = 0;
	for (int p = 0; p < playerCount; p++)
	{
		player = [[theGame players] objectAtIndex:p];
		[[player bots] removeAllObjects];
		
		for (int i = 0; i < botsPerPlayer; i++)
		{
			bot = [[[[self botSelector] botTypes] objectAtIndex:BOT_TYPE_SINGLE_SHOOTER_TIER_1] copy];
			
			if (bot)
			{
				[bot setX:1.2f*(p==1?1:-1) Y:1.0f-2*i/6.0 Z:-1.8];
				[bot setColor:[player color]];
				[bot setBaseTexture:[player baseTexture]];
				[bot setController:self];
				[self addBot:bot forPlayer:p];
				[bot release];
			}
		}
	}

	[self setupBotsPositions];
	
	for (int i = 0; i < [[theGame players] count]; i++)
		if (([[[theGame players] objectAtIndex:i] isComputer] >= 0))
			[[[theGame players] objectAtIndex:i] autoConfigureBots];
	
	if (!demo)
		playSoundLoop(preBattleSound);
	
	[self startSelecting];
}

- (void)quitGame:(id)sender
{
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER && sender == quitButton)
	{
		if (hasSelectedDoneOrQuit)
			return;
		else
			hasSelectedDoneOrQuit = true;
		
		playSound(clickSound);
		[self hideTutorial];
		[mainMenuViewController stopSinglePlayer];
		[self hideStatusBar];
	}
	else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL && sender == quitButton)
	{
		if (hasSelectedDoneOrQuit)
			return;
		else
			hasSelectedDoneOrQuit = true;
		
		playSound(clickSound);
		[mainMenuViewController stopBonusLevel];
		[self hideStatusBar];
	}
	else if ([theGame gameType] == GAME_TYPE_MULTIPLAYER || sender != quitButton)
	{
		playSound(clickSound);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];	
	}
	quitButtonSender = sender;
}

- (void)displayPlayerList
{
	NSMutableArray *sortedPlayers = [[NSMutableArray alloc] initWithArray:[theGame players]];
	[sortedPlayers sortUsingFunction:comparePlayersRoundsWon context:nil];
	
	bool doFloat;
	NSString *textureName;

	//player 1
	[[playerWonViewController position1Name] setText:[NSString stringWithFormat:@"%s", [[[sortedPlayers objectAtIndex:0] name] UTF8String]]];
	doFloat = ((([[sortedPlayers objectAtIndex:0] roundsWon] - floor([[sortedPlayers objectAtIndex:0] roundsWon])) > 0.2)?true:false);
	if (doFloat)
		[[playerWonViewController position1RoundsWon] setText:[NSString stringWithFormat:@"%3.1f", [[sortedPlayers objectAtIndex:0] roundsWon]]];
	else
		[[playerWonViewController position1RoundsWon] setText:[NSString stringWithFormat:@"%d", (int)[[sortedPlayers objectAtIndex:0] roundsWon]]];
	
	[[playerWonViewController position1BotsKilled] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:0] botsKilled]]];
	[[playerWonViewController position1BotsDestroyed] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:0] botsDestroyed]]];
	if ([[sortedPlayers objectAtIndex:0] isComputer] >= 0)
		textureName = @"base_bot4_noshadow.png";
	else
		textureName = [NSString stringWithFormat:@"base_bot%i_noshadow.png",([[sortedPlayers objectAtIndex:0] baseTexture]+1)];
	[[playerWonViewController position1Icon] setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:textureName] color:[[[sortedPlayers objectAtIndex:0] color] getUIColor]]];
	
	//player 2
	[[playerWonViewController position2Name] setText:[NSString stringWithFormat:@"%s", [[[sortedPlayers objectAtIndex:1] name] UTF8String]]];
	doFloat = ((([[sortedPlayers objectAtIndex:1] roundsWon] - floor([[sortedPlayers objectAtIndex:1] roundsWon])) > 0.2)?true:false);
	if (doFloat)
		[[playerWonViewController position2RoundsWon] setText:[NSString stringWithFormat:@"%3.1f", [[sortedPlayers objectAtIndex:1] roundsWon]]];
	else
		[[playerWonViewController position2RoundsWon] setText:[NSString stringWithFormat:@"%d", (int)[[sortedPlayers objectAtIndex:1] roundsWon]]];
	[[playerWonViewController position2BotsKilled] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:1] botsKilled]]];
	[[playerWonViewController position2BotsDestroyed] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:1] botsDestroyed]]];
	if ([[sortedPlayers objectAtIndex:1] isComputer] >= 0)
		textureName = @"base_bot4_noshadow.png";
	else
		textureName = [NSString stringWithFormat:@"base_bot%i_noshadow.png",([[sortedPlayers objectAtIndex:1] baseTexture]+1)];
	[[playerWonViewController position2Icon] setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:textureName] color:[[[sortedPlayers objectAtIndex:1] color] getUIColor]]];
	
	[[playerWonViewController position3Name] setText:@""];
	[[playerWonViewController position3RoundsWon] setText:@""];
	[[playerWonViewController position3BotsKilled] setText:@""];
	[[playerWonViewController position3BotsDestroyed] setText:@""];
	[[playerWonViewController position3Icon] setImage:nil];
	
	[[playerWonViewController position4Name] setText:@""];
	[[playerWonViewController position4RoundsWon] setText:@""];
	[[playerWonViewController position4BotsKilled] setText:@""];
	[[playerWonViewController position4BotsDestroyed] setText:@""];
	[[playerWonViewController position4Icon] setImage:nil];
	
	//player 3
	if ([[theGame players] count] >= 3)
	{
		[[playerWonViewController position3Name] setText:[NSString stringWithFormat:@"%s", [[[sortedPlayers objectAtIndex:2] name] UTF8String]]];
		doFloat = ((([[sortedPlayers objectAtIndex:2] roundsWon] - floor([[sortedPlayers objectAtIndex:2] roundsWon])) > 0.2)?true:false);
		if (doFloat)
			[[playerWonViewController position3RoundsWon] setText:[NSString stringWithFormat:@"%3.1f", [[sortedPlayers objectAtIndex:2] roundsWon]]];
		else
			[[playerWonViewController position3RoundsWon] setText:[NSString stringWithFormat:@"%d", (int)[[sortedPlayers objectAtIndex:2] roundsWon]]];
		[[playerWonViewController position3BotsKilled] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:2] botsKilled]]];
		[[playerWonViewController position3BotsDestroyed] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:2] botsDestroyed]]];
		if ([[sortedPlayers objectAtIndex:2] isComputer] >= 0)
			textureName = @"base_bot4_noshadow.png";
		else
			textureName = [NSString stringWithFormat:@"base_bot%i_noshadow.png",([[sortedPlayers objectAtIndex:2] baseTexture]+1)];
		[[playerWonViewController position3Icon] setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:textureName] color:[[[sortedPlayers objectAtIndex:2] color] getUIColor]]];
	}
	
	//player 4
	if ([[theGame players] count] == 4)
	{
		[[playerWonViewController position4Name] setText:[NSString stringWithFormat:@"%s", [[[sortedPlayers objectAtIndex:3] name] UTF8String]]];
		doFloat = ((([[sortedPlayers objectAtIndex:3] roundsWon] - floor([[sortedPlayers objectAtIndex:3] roundsWon])) > 0.2)?true:false);
		if (doFloat)
			[[playerWonViewController position4RoundsWon] setText:[NSString stringWithFormat:@"%3.1f", [[sortedPlayers objectAtIndex:3] roundsWon]]];
		else
			[[playerWonViewController position4RoundsWon] setText:[NSString stringWithFormat:@"%d", (int)[[sortedPlayers objectAtIndex:3] roundsWon]]];
		[[playerWonViewController position4BotsKilled] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:3] botsKilled]]];
		[[playerWonViewController position4BotsDestroyed] setText:[NSString stringWithFormat:@"%d", [[sortedPlayers objectAtIndex:3] botsDestroyed]]];
		if ([[sortedPlayers objectAtIndex:3] isComputer] >= 0)
			textureName = @"base_bot4_noshadow.png";
		else
			textureName = [NSString stringWithFormat:@"base_bot%i_noshadow.png",([[sortedPlayers objectAtIndex:3] baseTexture]+1)];
		[[playerWonViewController position4Icon] setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:textureName] color:[[[sortedPlayers objectAtIndex:3] color] getUIColor]]];
	}
	
	[sortedPlayers release];	
}

- (void)playerWon:(int)p
{
	
	if (demo)
	{
		[self startDemo];
		return;
	}

	stopAllSounds();

//	[self removeUpdateableObject:theGame];
	[[self theGame] setGameMode:GAME_MODE_BATTLE_FINISHED];

	Player *player = [[theGame players] objectAtIndex:p];
	[[playerWonViewController round] setText:[NSString stringWithFormat:@"Round %i", [theGame round]]];
	[player setRoundsWon:[player roundsWon]+1];
	
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
	{
		int botsAlive = 0;
		for (Bot *b in [singlePlayerHuman bots])
			if ([b life] > 0)
				botsAlive++;
		
		int levelScore = (int)((1000*botsAlive + [singlePlayerHuman funds])/(pow(2, levelAttempts-1)));
		
		[[singlePlayerWonViewController level] setText:[NSString stringWithFormat:@"Level %d", [theGame round]]];
		[[singlePlayerWonViewController totalLevelAttempts] setText:[NSString stringWithFormat:@"%3.1f%%", ([theGame round]/(totalLevelAttempts+0.0)*100)]];
//		[[singlePlayerWonViewController totalLevelAttempts] setText:[NSString stringWithFormat:@"%d", totalLevelAttempts]];
		[[singlePlayerWonViewController unusedResources] setText:[NSString stringWithFormat:@"1 x $%d", [singlePlayerHuman funds]]];
		[[singlePlayerWonViewController botsRemaining] setText:[NSString stringWithFormat:@"1000 x %d", botsAlive]];
		[[singlePlayerWonViewController attemptMultiplyer] setText:[NSString stringWithFormat:@"(%d %s) %1.2f", levelAttempts,  (((levelAttempts)==1)?"attempt":"attempts"), 1.0/pow(2, levelAttempts-1)]];
		[[singlePlayerWonViewController subtotal] setText:[NSString stringWithFormat:@"%d", (int)(1000*botsAlive + [singlePlayerHuman funds])]];
		[[singlePlayerWonViewController levelScore] setText:[NSString stringWithFormat:@"%d", levelScore]];
		
		if (player != singlePlayerHuman)
		{
			playSound(lostRoundSound);
		
			//set a random quote
			NSArray *quote = [[singlePlayerWonViewController quotes] objectAtIndex:random()%[[singlePlayerWonViewController quotes] count]];
			[[singlePlayerWonViewController quoteLabel] setText:[quote objectAtIndex:0]];
			[[singlePlayerWonViewController personLabel] setText:[NSString stringWithFormat:@"- %@", [quote objectAtIndex:1], nil]];
			
			//hide the scores, show the quote
			[[singlePlayerWonViewController scoreView] setAlpha:0];
			[[singlePlayerWonViewController quoteView] setAlpha:1];
			
			//update the interface
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"You Lost!"]];
			[[singlePlayerWonViewController totalScore] setText:[NSString stringWithFormat:@"%d", [singlePlayerHuman score]]];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateNormal];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateHighlighted];

			[singlePlayerRounds setWonLastRound:false];
		}
		else
		{
			playSound(playerWonSound);
			
			//show the scores, hide the quote
			[[singlePlayerWonViewController scoreView] setAlpha:1];
			[[singlePlayerWonViewController quoteView] setAlpha:0];
			
			//update the interface
			[singlePlayerHuman setScore:[singlePlayerHuman score]+levelScore];
			[[singlePlayerWonViewController totalScore] setText:[NSString stringWithFormat:@"%d", [singlePlayerHuman score]]];
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"%s is Victorious!", [[singlePlayerHuman name] UTF8String]]];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Next Level" forState:UIControlStateNormal];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Next Level" forState:UIControlStateHighlighted];

			[theGame setRound:[theGame round]+1];
			[singlePlayerRounds setWonLastRound:true];
			levelAttempts = 0;
		}
		
		if ([singlePlayerHuman score] > [[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerTopScore"])
		{
			[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman score] forKey:@"singlePlayerTopScore"];
			[[[mainMenuViewController singlePlayerViewController] topScore] setText:[NSString stringWithFormat:@"Top Score: %d", [singlePlayerHuman score]]];
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"New Top Score!"]];
		}
	}
	else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL)
	{
		[[singlePlayerWonViewController level] setText:[NSString stringWithFormat:@"Level %d", [theGame round]]];
		if (player != singlePlayerHuman)
		{
			playSound(lostRoundSound);
			
			//set a random quote
			NSArray *quote = [[singlePlayerWonViewController quotes] objectAtIndex:random()%[[singlePlayerWonViewController quotes] count]];
			[[singlePlayerWonViewController quoteLabel] setText:[quote objectAtIndex:0]];
			[[singlePlayerWonViewController personLabel] setText:[NSString stringWithFormat:@"- %@", [quote objectAtIndex:1], nil]];
			
			//hide the scores, show the quote
			[[singlePlayerWonViewController scoreView] setAlpha:0];
			[[singlePlayerWonViewController quoteView] setAlpha:1];
			
			//update the interface
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"You Lost!"]];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateNormal];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateHighlighted];
			[singlePlayerRounds setWonLastRound:false];
		}
		else
		{
			playSound(playerWonSound);
			
			//show the scores, hide the quote
			[[singlePlayerWonViewController scoreView] setAlpha:0];
			[[singlePlayerWonViewController quoteView] setAlpha:0];
			
			//update the interface
			[[singlePlayerWonViewController totalScore] setText:@""];
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"%s is Victorious!", [[singlePlayerHuman name] UTF8String]]];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Return" forState:UIControlStateNormal];
			[[singlePlayerWonViewController nextRoundButton] setTitle:@"Return" forState:UIControlStateHighlighted];
			
			[singlePlayerRounds setWonLastRound:true];
			
			[[[mainMenuViewController singlePlayerViewController] bonusLevelsViewController] roundWon:[theGame round]];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"bonusLevel%i", [theGame round]]];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
	else if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
	{
		playSound(playerWonSound);
		[[playerWonViewController header] setText:[NSString stringWithFormat:@"%s is Victorious!", [[player name] UTF8String]]];
		[theGame setRound:[theGame round]+1];
		for (Player *p in [theGame players])
			[p setFunds:[self fundsForMultiRound]+[p funds]];
		
		[self displayPlayerList];
	}

	//NSLog(@"Score: %d, levelAttempts %d, totlevatt %d", [singlePlayerHuman score], levelAttempts, totalLevelAttempts);
	//[self hideLifeBars];
	[self showPlayerWon];
	[self startSelecting];
}

- (void)tieWithPlayers:(int)p1 andP2:(int)p2
{
	if (demo)
	{
		[self startDemo];
		return;
	}
		
	stopAllSounds();

	if (p1 >= 0 && p2 >= 0)
	{	
		Player *player;
		player = [[theGame players] objectAtIndex:p1];
		[player setRoundsWon:[player roundsWon]+0.5];
		player = [[theGame players] objectAtIndex:p2];
		[player setRoundsWon:[player roundsWon]+0.5];
	}
	
	[[self theGame] setGameMode:GAME_MODE_BATTLE_FINISHED];
	
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
	{
		Player *player = singlePlayerHuman;
		int botsAlive = 0;
		
		int levelScore = (int)((1000*botsAlive + [player funds])/(pow(2, levelAttempts-1)));
		
		[[singlePlayerWonViewController level] setText:[NSString stringWithFormat:@"Level %d", [theGame round]]];
		[[singlePlayerWonViewController totalLevelAttempts] setText:[NSString stringWithFormat:@"%3.1f%%", ([theGame round]/(totalLevelAttempts+0.0)*100)]];
//		[[singlePlayerWonViewController totalLevelAttempts] setText:[NSString stringWithFormat:@"%d", totalLevelAttempts]];
		[[singlePlayerWonViewController unusedResources] setText:[NSString stringWithFormat:@"1 x $%d", [singlePlayerHuman funds]]];
		[[singlePlayerWonViewController botsRemaining] setText:[NSString stringWithFormat:@"1000 x %d", botsAlive]];
		[[singlePlayerWonViewController attemptMultiplyer] setText:[NSString stringWithFormat:@"(%d %s) %1.2f", levelAttempts,  (((levelAttempts)==1)?"attempt":"attempts"), 1.0/pow(2, levelAttempts-1)]];
		[[singlePlayerWonViewController subtotal] setText:[NSString stringWithFormat:@"%d", (int)(1000*botsAlive + [player funds])]];
		[[singlePlayerWonViewController levelScore] setText:[NSString stringWithFormat:@"%d", levelScore]];
		[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"Tie!"]];
		
		[singlePlayerRounds setWonLastRound:true];
		[singlePlayerHuman setScore:(int)([singlePlayerHuman score] 
										  + ([[[theGame players] objectAtIndex:0] funds])/(pow(2, levelAttempts-1)))];
		
		[[singlePlayerWonViewController totalScore] setText:[NSString stringWithFormat:@"%d", [singlePlayerHuman score]]];
	
		if ([singlePlayerHuman score] > [[NSUserDefaults standardUserDefaults] integerForKey:@"singlePlayerTopScore"])
		{
			[[NSUserDefaults standardUserDefaults] setInteger:[singlePlayerHuman score] forKey:@"singlePlayerTopScore"];
			[[[mainMenuViewController singlePlayerViewController] topScore] setText:[NSString stringWithFormat:@"Top Score: %d", [singlePlayerHuman score]]];
			[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"New Top Score!"]];
		}
	}
	else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL)
	{
		Player *player = singlePlayerHuman;
		int botsAlive = 0;
				
		[[singlePlayerWonViewController level] setText:[NSString stringWithFormat:@"Level %d", [theGame round]]];
		[[singlePlayerWonViewController header] setText:[NSString stringWithFormat:@"Tie!"]];
		
		[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateNormal];
		[[singlePlayerWonViewController nextRoundButton] setTitle:@"Try Again" forState:UIControlStateHighlighted];

		[singlePlayerRounds setWonLastRound:false];
	}
	else if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
	{
		[[playerWonViewController round] setText:[NSString stringWithFormat:@"Round %i", [theGame round]]];
		[[playerWonViewController header] setText:[NSString stringWithFormat:@"Tie!"]];
	
		[self displayPlayerList];	
	}
	
	[self showPlayerWon];
	[self startSelecting];
	[theGame setRound:[theGame round]+1];
	levelAttempts = 0;	
}

- (void)nextRound
{
	[self hidePlayerWon];
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
		[self startSinglePlayerRound];
	else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL)
	{
		if ([singlePlayerRounds wonLastRound])
			[mainMenuViewController stopBonusLevel];
		else
			[self startBonusLevelRound];
	}
	else if ([theGame gameType] == GAME_TYPE_MULTIPLAYER)
		[self startMultiPlayerRound];
}

- (void)showPlayerWon
{
	[self stopAnimation];
	
	[UIView beginAnimations:@"showPlayerWon" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER || [theGame gameType] == GAME_TYPE_BONUS_LEVEL)
		[[singlePlayerWonViewController view] setAlpha:1];
	else
		[[playerWonViewController view] setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hidePlayerWon
{
	[self startAnimation];
	
	[UIView beginAnimations:@"hidePlayerWon" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER || [theGame gameType] == GAME_TYPE_BONUS_LEVEL)
		[[singlePlayerWonViewController view] setAlpha:0];
	else
		[[playerWonViewController view] setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)showButtons
{	
	[UIView beginAnimations:@"showButtons" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[quitButton setAlpha:1];
	[doneButton setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hideButtons
{	
	[UIView beginAnimations:@"hideButtons" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[quitButton setAlpha:0];
	[doneButton setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)showGameOver
{
	CGRect frame = [[gameOverViewController titleLabel] frame];
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
	{
		frame.origin.y = 20;
		float numLevels = (liteVersion?5.0:20.0);
		[[gameOverViewController titleLabel] setFrame:frame];
		[[gameOverViewController titleLabel] setText:@"Congratulations!"];
		[[gameOverViewController successRate] setText:[NSString stringWithFormat:@"%3.1f%%", (numLevels/(totalLevelAttempts+0.0)*100)]];
		[[gameOverViewController finalScore] setText:[NSString stringWithFormat:@"%d", [singlePlayerHuman score]]];
		[[gameOverViewController successRateLabel] setAlpha:1];
		[[gameOverViewController finalScoreLabel] setAlpha:1];
		[[gameOverViewController storyLabel] setAlpha:1];
	}
	else
	{
		frame.origin.y = 115;
		[[gameOverViewController titleLabel] setFrame:frame];
		[[gameOverViewController titleLabel] setText:@"GAME OVER"];
		[[gameOverViewController successRate] setText:@""];
		[[gameOverViewController finalScore] setText:@""];
		[[gameOverViewController successRateLabel] setAlpha:0];
		[[gameOverViewController finalScoreLabel] setAlpha:0];
		[[gameOverViewController storyLabel] setAlpha:0];
	}
	
	[UIView beginAnimations:@"showGameOver" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[gameOverViewController view] setAlpha:1.0];
	
	[UIView commitAnimations];
}

- (void)hideGameOver
{
	[UIView beginAnimations:@"hideGameOver" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[gameOverViewController view] setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)showStoryLine:(float)duration
{
	[[singlePlayerRounds storyLineViewController] setHasSelected:false];
	[[[singlePlayerRounds storyLineViewController] progressImageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.png", [theGame round]]]];

	if (duration > 0)
	{
		[UIView beginAnimations:@"showStoryLine" context:nil];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
	}
	[[[singlePlayerRounds storyLineViewController] view] setAlpha:1.0];
	
	if (duration > 0)
		[UIView commitAnimations];
		
}

- (void)hideStoryLine
{
	
	[UIView beginAnimations:@"hideStoryLine" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[[singlePlayerRounds storyLineViewController] view] setAlpha:0];
	
	[UIView commitAnimations];	

}

/*
- (void)resetLifeBars
{	
	CGRect frame;
	Color *color;
	
	frame = [lifeBar1 frame];
	frame.size.width = 40;
	[lifeBar1 setFrame:frame];
	color = [[[theGame players] objectAtIndex:0] color];
	[lifeBar1 setBackgroundColor:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:1]];

	frame = [lifeBar2 frame];
	frame.size.width = 40;
	[lifeBar2 setFrame:frame];
	color = [[[theGame players] objectAtIndex:1] color];
	[lifeBar2 setBackgroundColor:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:1]];

	frame = [lifeBar3 frame];
	if ([[theGame players] count] >= 3)
	{
		frame.size.width = 40;
		color = [[[theGame players] objectAtIndex:2] color];
		[lifeBar3 setBackgroundColor:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:1]];
	}
	else
	{
		frame.size.width = 0;
	}
	[lifeBar3 setFrame:frame];

	frame = [lifeBar4 frame];
	if ([[theGame players] count] >= 4)
	{
		frame.size.width = 40;
		color = [[[theGame players] objectAtIndex:3] color];
		[lifeBar4 setBackgroundColor:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:[color alpha]]];
	}
	else
	{
		frame.size.width = 0;
	}
	[lifeBar4 setFrame:frame];
}

- (void)showLifeBars
{	
	[UIView beginAnimations:@"showLifeBars" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];

	[lifeBar1 setAlpha:.5];
	[lifeBar2 setAlpha:.5];
	[lifeBar3 setAlpha:.5];
	[lifeBar4 setAlpha:.5];

	[UIView commitAnimations];
}

- (void)hideLifeBars
{	
	[lifeBar1 setAlpha:0];
	[lifeBar2 setAlpha:0];
	[lifeBar3 setAlpha:0];
	[lifeBar4 setAlpha:0];
}*/

- (void)showStatusBar
{	
	hasSelectedDoneOrQuit = false;
	
	CGRect frame = [statusBar frame];
	frame.origin.x = -40;
	[statusBar setFrame:frame];
	
	[UIView beginAnimations:@"showStatusBar" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	frame.origin.x = 0;
	[statusBar setFrame:frame];
	[statusBar setAlpha:1.0];
	
	[roundLevel setAlpha:1.0];
	
	[UIView commitAnimations];
}

- (void)hideStatusBar
{
	CGRect frame = [statusBar frame];
	frame.origin.x = 0;
	[statusBar setFrame:frame];
	
	[UIView beginAnimations:@"hideStatusBar" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	frame.origin.x = -40;
	[statusBar setFrame:frame];
	[statusBar setAlpha:0.0];
	
	[roundLevel setAlpha:0.0];

	[UIView commitAnimations];
}

- (void)pause
{
	stopAllSounds();
	[self stopAnimation];
	[self showPauseMenu];
}

- (void)unpause
{
	[self startAnimation];
	[self hidePauseMenu];
}

- (void)showPauseMenu
{
	[UIView beginAnimations:@"showPauseMenu" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[pauseMenuViewController view] setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hidePauseMenu
{
	[UIView beginAnimations:@"hidePauseMenu" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[pauseMenuViewController view] setAlpha:0];
	
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([theGame gameMode] == GAME_MODE_BATTLE)
	{
		[self pause];
	}

	[super touchesBegan:touches withEvent:event];
}

- (void)botTouched:(Bot *)bot
{
	if ([theGame gameMode] == GAME_MODE_SELECT 
		&& !selecting && !animating 
		&& [bot player] == currentPlayer
		&& [[[singlePlayerRounds storyLineViewController] view] alpha] == 0.0
		&& [[gameOverViewController view] alpha] == 0.0)
	{
		[self startSelectBot: bot];
	}
}

- (void)setViewX:(float *)x Y:(float *)y Z:(float *)z
{
	dx = (*x - [openGLView x])/7;
	dy = (*y - [openGLView y])/7;
	dz = (*z - [openGLView z])/7;
	[self updateView];
}

- (void)updateView
{
	float x = [openGLView x];
	x += dx;
	[openGLView setX:x];
	
	float y = [openGLView y];
	y += dy;
	[openGLView setY:y];
	
	float z = [openGLView z];
	z += dz;
	[openGLView setZ:z];
	
	//[openGLView fixBounds];
}

- (void)addBot:(Bot *)bot forPlayer:(int)playerId
{
	Player *player = [[theGame players] objectAtIndex:playerId];
	if (player)
	{
		[bot setPlayer:playerId];
		[bot setZ:[bot z] + botZ];
		if ([player isComputer] >= 0)
			[bot setComputer:true];
		[[player bots] addObject:bot];
		[self addDrawableObject:bot];
		[self addUpdateableObject:bot];
		[self addTouchableObject:bot];
	}
}

- (void)selectBot
{
	[self updateView];
	
	count++;
	if (count >= ANIMATION_INTERVAL)
	{
		[self stopSelectBot];
	}
}

- (void)moveSelectorToBot:(Bot *)bot
{
	if (animating)
		return;

	movingToBot = bot;
	
	animating = YES;

	count = 0;
	
	dx = -([openGLView x]-1.5-[bot x])/ANIMATION_INTERVAL;
	dy = -([openGLView y]+.85-[bot y])/ANIMATION_INTERVAL;
	dz = -([openGLView z]-1)/ANIMATION_INTERVAL;
/*
	dx = -([openGLView x]-3)/ANIMATION_INTERVAL;
	dy = -([openGLView y]+1.7)/ANIMATION_INTERVAL;
	dz = -([openGLView z]-3)/ANIMATION_INTERVAL;
*/	
	[botSelector selectBot:bot];

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	self.selectBotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/CYCLES_PER_SECOND target:self selector:@selector(unSelectBot) userInfo:nil repeats:YES];

	playSound(switchBotSound);
}

- (void)moveSelectorToBot2
{
	animating = YES;

	count = 0;
	
	dx = (.228+[movingToBot x] - [openGLView x])/ANIMATION_INTERVAL;
	dy = (-.13+[movingToBot y] - [openGLView y])/ANIMATION_INTERVAL;
	dz = (.38+[movingToBot z] - [openGLView z])/ANIMATION_INTERVAL;
	movingToBot = NULL;

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	self.selectBotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/CYCLES_PER_SECOND target:self selector:@selector(selectBot) userInfo:nil repeats:YES];

//	playSound(jumpIncreaseSound);
}

- (void)startSelecting
{
	hasSelected = false;
//	[openGLView setNeedsBotIdentifier:true];
}

- (void)startSelectBot:(Bot *)bot
{
	if (animating)
		return;
	
	hasSelected = true;
	animating = YES;
	count = 0;
	
	dx = (.228+[bot x] - [openGLView x])/ANIMATION_INTERVAL;
	dy = (-.13+[bot y] - [openGLView y])/ANIMATION_INTERVAL;
	dz = (.38+[bot z] - [openGLView z])/ANIMATION_INTERVAL;
	[botSelector selectBot:bot];

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	self.selectBotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/CYCLES_PER_SECOND target:self selector:@selector(selectBot) userInfo:nil repeats:YES];

	[self hideStatusBar];
	[self showBotSelector];

	stopSoundLoop(preBattleSound);
	playSound(jumpIncreaseSound);
}

- (void)stopSelectBot
{
	selecting = YES;
	animating = NO;
	[self.selectBotTimer invalidate];
    self.selectBotTimer = nil;
}

- (void)afterShowBotSelector
{
	[cycleTimer invalidate];
	self.cycleTimer = nil;
	self.cycleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/CYCLES_PER_SECOND target:self selector:@selector(cycle) userInfo:nil repeats:YES];
	
	if ([theGame round] == 1 && doTutorial)
	{
		if (tutorialState == 1)
			tutorialState = 2;
		[self showTutorial:tutorialState];
	}

	playSoundLoop(botSelectorSound);
}

- (void)showBotSelector
{
	if ([theGame round] == 1 && doTutorial)
	{
		[self hideTutorial];
	}
	
	CGPoint center = [botSelector.view center];
	center.y = 480*1.5;
	[[botSelector view] setCenter:center];

	[botSelector.view setAlpha:1];

	[UIView beginAnimations:@"showBotSelector" context:nil];
	[UIView setAnimationDuration:(float)ANIMATION_INTERVAL/CYCLES_PER_SECOND];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDidStopSelector:@selector(afterShowBotSelector)];
	[UIView setAnimationDelegate:self];
	
	center.y = 480*.5;
	[[botSelector view] setCenter:center];

	[UIView commitAnimations];
}

- (void)afterHideBotSelector
{
	[self stopAnimation];
	[self startAnimation];
	
	if ([theGame round] == 1 && doTutorial && currentPlayer >= 0)
	{
		[self hideTutorial];
		[self showTutorial:7];
	}
	playSoundLoop(preBattleSound);
}

- (void)hideBotSelector
{
	if ([theGame round] == 1 && doTutorial)
	{
		[self hideTutorial];
	}
	
	CGPoint center = [botSelector.view center];
	center.y = 480*.5;
	[[botSelector view] setCenter:center];
	
	[UIView beginAnimations:@"hideBotSelector" context:nil];
	[UIView setAnimationDuration:(float)ANIMATION_INTERVAL/CYCLES_PER_SECOND];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(afterHideBotSelector)];
	
	center.y = 480*1.5;
	[[botSelector view] setCenter:center];

	[UIView commitAnimations];
}

- (void)unSelectBot
{
	[self updateView];
	
	count++;
	if (count >= ANIMATION_INTERVAL)
	{
		[self stopUnSelectBot];
	}
}

- (void)startUnSelectBot
{
	if (animating)
		return;

	playSound(clickSound);
	stopSoundLoop(botSelectorSound);
	playSound(jumpDecreaseSound);

	[doneButton setAlpha:1];

	animating = YES;

	count = 0;
	
	dx = -([openGLView x])/ANIMATION_INTERVAL;
	dy = -([openGLView y])/ANIMATION_INTERVAL;
	dz = -([openGLView z])/ANIMATION_INTERVAL;

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

	self.selectBotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5/CYCLES_PER_SECOND target:self selector:@selector(unSelectBot) userInfo:nil repeats:YES];
	
	[self showStatusBar];
	[self hideBotSelector];
}

- (void)stopUnSelectBot
{		
	selecting = NO;
	animating = NO;
	[self.selectBotTimer invalidate];
    self.selectBotTimer = nil;

	if (movingToBot)
		[self moveSelectorToBot2];
}

- (void)doneSelecting
{
	if (hasSelectedDoneOrQuit)
		return;
	
	if (selecting)
		return;

	[doneButton setAlpha:0];
	
	if ([theGame gameType] == GAME_TYPE_SINGLEPLAYER)
	{
		[self hideTutorial];
	
		playSound(clickSound);
		[playerName setText:@""];
		countdown = 3;
		currentPlayer = -1;
		levelAttempts++;
		totalLevelAttempts++;
		stopSoundLoop(preBattleSound);
		playSound(countdownSound);
		[self showCountdownView];
		[self hideStatusBar];
		hasSelectedDoneOrQuit = true;

		[[singlePlayerRounds configuration] removeAllObjects];
		for (Bot *b in [[[theGame players] objectAtIndex:0] bots])
		{
			id theJammer = nil;
			for (Attack *a in [b attackTypes])
				if ([a attackType] == ATTACK_TYPE_JAMMER)
					theJammer = a;
			ConfigurationObject *cfgObject = [[ConfigurationObject alloc] initWithX:[b x] Y:[b y] Z:[b z] MT:[b currentMovement] BT:[b type] CT:[b cost] SH:([b shields] > 0) JA:(theJammer!=nil)];
			[[singlePlayerRounds configuration] addObject:cfgObject];
		}
	}
	else if ([theGame gameType] == GAME_TYPE_BONUS_LEVEL)
	{
		playSound(clickSound);
		[playerName setText:@""];
		countdown = 3;
		currentPlayer = -1;
		levelAttempts++;
		totalLevelAttempts++;
		stopSoundLoop(preBattleSound);
		playSound(countdownSound);
		[self showCountdownView];
		[self hideStatusBar];
		hasSelectedDoneOrQuit = true;
		
		[[bonusLevelRounds configuration] removeAllObjects];

		for (Bot *b in [[[theGame players] objectAtIndex:0] bots])
		{
			id theJammer = nil;
			for (Attack *a in [b attackTypes])
				if ([a attackType] == ATTACK_TYPE_JAMMER)
					theJammer = a;
			ConfigurationObject *cfgObject = [[ConfigurationObject alloc] initWithX:[b x] Y:[b y] Z:[b z] MT:[b currentMovement] BT:[b type] CT:[b cost] SH:([b shields] > 0) JA:(theJammer!=nil)];
			[[bonusLevelRounds configuration] addObject:cfgObject];
		}
	}
	else
	{
		if (currentPlayer == ([[theGame players] count]-1))
		{
			playSound(clickSound);
			countdown = 3;
			[playerName setText:@""];
			currentPlayer = -1;
			stopSoundLoop(preBattleSound);
			playSound(countdownSound);
			[self showCountdownView];
			[self hideStatusBar];
			//[self showLifeBars];
		}
		else
		{
			if ([[[theGame players] objectAtIndex:currentPlayer+1] isComputer] >= 0)
			{
				currentPlayer++;
				[self doneSelecting];
			}
			else
			{
				playSound(clickSound);
				currentPlayer++;
				[playerName setText:[[[theGame players] objectAtIndex:currentPlayer] name]];
				[self startSelecting];
			}
		}	
	}
		
}

- (void)startBattle
{
	[theGame setGameMode:GAME_MODE_BATTLE];		
}

- (void)showCountdownView
{
/*
	if (countdown == -1)
	{
		[self startBattle];
		return;
	}
*/	
	if (countdown == 0)
	{
		playSound(roundStartSound);
		[self startBattle];
		return;
	}
	else
	{
		[countdownImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"countdown_%i.png", countdown]]];
	}

	[UIView beginAnimations:@"showCountdownView" context:nil];
	[UIView setAnimationDuration:0.1f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideCountdownView)];
	
	[countdownView setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hideCountdownView
{
	[UIView beginAnimations:@"hideCountdownView" context:nil];
	[UIView setAnimationDuration:0.9f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showCountdownView)];
	
	[countdownView setAlpha:0];
	
	[UIView commitAnimations];
	countdown--;
}

- (void)playSound:(SoundEffect *)audioPlayer
{
	if (!demo)
		playSound(audioPlayer);
}

- (void)playSoundNotTooMuch:(SoundEffect *)audioPlayer;
{
//	if ([audioPlayer playing])
//		return;
	
	[self playSound:audioPlayer];
}

- (void)vibrate
{
	if (!demo)
		vibrate();
}

 - (bool)shieldsOn
{
	if ([theGame gameType] == GAME_TYPE_MULTIPLAYER && !liteVersion)
		return [[NSUserDefaults standardUserDefaults] boolForKey:@"shieldsOn"];
	return true;
}
 
 - (bool)jammingOn
{
	if ([theGame gameType] == GAME_TYPE_MULTIPLAYER && !liteVersion)
		return [[NSUserDefaults standardUserDefaults] boolForKey:@"jammingOn"];
	return true;
}
 
 - (bool)showComputersOn
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"showComputersOn"];
}
	 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	//[pvrTexture release];
	//glDeleteTextures(1, &textureBackground);

	unloadTexture(&textureBackground);
	
	[colors release];
	[computerPlayers release];
	[theGame release];
	[botSelector release];
	[backgroundFiles release];
	[playerWonViewController release];
	[pauseMenuViewController release];
	[gameOverViewController release];
	[singlePlayerHuman release];
	[singlePlayerRounds release];
	[tutorialScreen1 release];
	[tutorialScreen2 release];
	[tutorialScreen3 release];
	[tutorialScreen4 release];
	[tutorialScreen5 release];
	[tutorialScreen6 release];
	[tutorialScreen7 release];
	
	[playerName release];
	[quitButton release];
	[doneButton release];
	[statusBar release];
	[roundLevel release];
	[frameRateView release];
	[sliderImage release];
	[frameRateSlider release];
	
	[countdownView release];
	[countdownImage release];
	
    [super dealloc];
}


@end
