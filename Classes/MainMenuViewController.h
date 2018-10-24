//
//  MainMenuViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/6/09.
//  Copyright 2009 Slyco. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AiWarsViewController.h"
#import "Bot.h"
#import "Map.h"
#import "MultiPlayerMenuViewController.h"
#import "MultiPlayerViewController.h"
#import "SinglePlayerMenuViewController.h"
#import "HumanPlayerViewController.h"
#import "InstructionsViewController.h"
#import "UnlockedViewController.h"

@interface MainMenuViewController : UIViewController
{
    UIWindow *window;
	IBOutlet UIButton *singlePlayerButton, *multiPlayerButton, *instructionsButton, *soundButton, *unlockButton, *toggleMenu;
	
	NSTimer *killbotsAnimation;
	int currentKillbotsImage;
	IBOutlet UIImageView *killbotsImage, *unlockedImage, *pleaseWaitImage;
	UIImage *killbotsMainImage;
	NSMutableArray *killbotsImages;
	
	bool menuShown;
	bool hasSelected;
	
	UIImage *soundOnImage, *soundOffImage;
	
	AiWarsViewController *aiWarsViewController;
	MultiPlayerMenuViewController *multiPlayerMenuViewController;
	SinglePlayerMenuViewController *singlePlayerViewController;
	HumanPlayerViewController *humanPlayerViewController;
	InstructionsViewController *instructionsViewController;
	UnlockedViewController *unlockedViewController;
}

@property ATOMICITY_RETAIN UIWindow *window;
@property ATOMICITY_RETAIN UIButton *singlePlayerButton, *multiPlayerButton, *instructionsButton, *soundButton, *unlockButton, *toggleMenu;

@property ATOMICITY_ASSIGN NSTimer *killbotsAnimation;
@property ATOMICITY_RETAIN UIImageView *killbotsImage, *unlockedImage, *pleaseWaitImage;
@property ATOMICITY_RETAIN UIImage *killbotsMainImage;
@property ATOMICITY_RETAIN NSMutableArray *killbotsImages;

@property ATOMICITY_RETAIN UIImage *soundOnImage, *soundOffImage; 

@property ATOMICITY_RETAIN AiWarsViewController *aiWarsViewController;
@property ATOMICITY_RETAIN MultiPlayerMenuViewController *multiPlayerMenuViewController;
@property ATOMICITY_RETAIN SinglePlayerMenuViewController *singlePlayerViewController;
@property ATOMICITY_RETAIN HumanPlayerViewController *humanPlayerViewController;
@property ATOMICITY_RETAIN InstructionsViewController *instructionsViewController;
@property ATOMICITY_RETAIN UnlockedViewController *unlockedViewController;

- (void)startKillbotsAnimation;
- (void)stopKillbotsAnimation;
- (void)nextKillbotsImage;

- (void)addViews;

- (IBAction)toggleMenu:(id)sender;

- (IBAction)singlePlayer:(id)sender;
- (void)showSinglePlayerIntro;
- (void)hideSinglePlayerIntro;
//- (void)quitSinglePlayer;
- (void)startSinglePlayer;
- (void)startBonusLevel;
- (void)stopBonusLevel;
- (void)stopSinglePlayer;
- (void)hideSinglePlayerMenu;
- (void)showSinglePlayerMenu;
- (void)showHumanPlayer;
- (void)hideHumanPlayer;


- (IBAction)multiPlayer:(id)sender;
- (void)startMultiPlayer;
- (void)stopMultiPlayer;
- (void)hideMultiPlayerMenu;
- (void)showMultiPlayerMenu;

- (void)setupOpenGLView;
- (void)destroyOpenGLView;
- (void)hideMainMenu;
- (void)showMainMenu;
- (void)afterShowMainMenu;

- (IBAction)instructions:(id)sender;
- (void)showInstructions;
- (void)hideInstructions;

- (IBAction)toggleSound:(id)sender;
- (void)doneWithPurchase;
- (void)unlockApp;
- (IBAction)unlock:(id)sender;

@end
