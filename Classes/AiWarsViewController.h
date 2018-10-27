//
//  AiWarsViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/11/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLViewController.h"
#import "Types.h"
#import "Explosion.h"
#import "Bot.h"
#import "BotSelectorViewController.h"
#import "PlayerWonViewController.h"
#import "PauseMenuViewController.h"
#import "GameOverViewController.h"
#import "SinglePlayerWonViewController.h"
#import "Player.h"
#import "Game.h"
#import "SinglePlayerRounds.h"
#import "BonusLevelRounds.h"

#define ANIMATION_INTERVAL	20

#define LOWER_X -1.3
#define UPPER_X 1.3
#define LOWER_Y -0.55
#define UPPER_Y 0.8


@class MainMenuViewController;

@interface AiWarsViewController : OpenGLViewController <UIAlertViewDelegate>
{
	PVRTexture *pvrTexture;

	int count;
	float dx, dy, dz;
	
	//colors
	NSMutableArray *colors;

	//Comptuer players
	NSMutableArray *computerPlayers;

	//Backgrounds
	NSMutableArray *backgroundFiles;
	
	int botsPerPlayer;
	RoundType roundType;
	
	//main menu
	MainMenuViewController *mainMenuViewController;

	Game *theGame;
    Game *theGameCopy;

	//determines if we are in demo mode or not
	bool demo;
    
	//storage for single player
	Player *singlePlayerHuman;
	SinglePlayerRounds *singlePlayerRounds;
	BonusLevelRounds *bonusLevelRounds;
	bool doTutorial;
	int tutorialState;
	UIImageView *tutorialScreen1, *tutorialScreen2, *tutorialScreen3, *tutorialScreen4, *tutorialScreen5, *tutorialScreen6, *tutorialScreen7;
	
	//scoring
	int totalLevelAttempts;
	int levelAttempts;
	
	float botZ; //keep track of the depth of the bots so they are added back to front
	
	//bot selecting
	Bot *movingToBot;
	NSTimer *selectBotTimer;
	bool animating, selecting;
	BotSelectorViewController *botSelector;
	int currentPlayer; //the index of the current player that is selecting bots
	bool hasSelected; //is set to false once the player has started to select their bots
	
	bool hasSelectedDoneOrQuit;
	
	//Other controllers
	PlayerWonViewController *playerWonViewController;
	PauseMenuViewController *pauseMenuViewController;
	GameOverViewController *gameOverViewController;
	SinglePlayerWonViewController *singlePlayerWonViewController;
	
	
	//battle
	UIView *statusBar;
	UILabel *playerName, *roundLevel;
	UIButton *quitButton, *doneButton;
	UIView *frameRateView;
	UIImageView *sliderImage;
	UISlider *frameRateSlider;
	id quitButtonSender;
	int countdown;
	UIView *countdownView;
	UIImageView *countdownImage;
	
//	UIView *lifeBar1, *lifeBar2, *lifeBar3, *lifeBar4;
}


@property ATOMICITY_RETAIN NSMutableArray *colors;

@property ATOMICITY_RETAIN NSMutableArray *computerPlayers;

@property ATOMICITY_RETAIN NSMutableArray *backgroundFiles;

@property ATOMICITY_NONE int botsPerPlayer;
@property ATOMICITY_NONE RoundType roundType;

@property ATOMICITY_RETAIN Game *theGame;
@property ATOMICITY_RETAIN Game *theGameCopy;

@property ATOMICITY_RETAIN Player *singlePlayerHuman;
@property ATOMICITY_RETAIN SinglePlayerRounds *singlePlayerRounds;
@property ATOMICITY_RETAIN BonusLevelRounds *bonusLevelRounds;
@property ATOMICITY_NONE bool doTutorial;
@property ATOMICITY_NONE int tutorialState;
@property ATOMICITY_RETAIN UIImageView *tutorialScreen1, *tutorialScreen2, *tutorialScreen3, *tutorialScreen4, *tutorialScreen5, *tutorialScreen6, *tutorialScreen7;

@property ATOMICITY_NONE int totalLevelAttempts;
@property ATOMICITY_NONE int levelAttempts;

@property ATOMICITY_ASSIGN NSTimer *selectBotTimer;
@property ATOMICITY_RETAIN BotSelectorViewController *botSelector;
@property ATOMICITY_NONE int currentPlayer;
@property ATOMICITY_NONE bool hasSelected;

@property ATOMICITY_RETAIN PlayerWonViewController *playerWonViewController;
@property ATOMICITY_RETAIN PauseMenuViewController *pauseMenuViewController;
@property ATOMICITY_RETAIN GameOverViewController *gameOverViewController;
@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;
@property ATOMICITY_RETAIN SinglePlayerWonViewController *singlePlayerWonViewController;

@property ATOMICITY_ASSIGN id quitButtonSender;

@property ATOMICITY_RETAIN UIButton *quitButton, *doneButton;
@property ATOMICITY_RETAIN UIView *frameRateView;
@property ATOMICITY_RETAIN UIImageView *sliderImage;
@property ATOMICITY_RETAIN UISlider *frameRateSlider;


//@property ATOMICITY_RETAIN UIView *lifeBar1, *lifeBar2, *lifeBar3, *lifeBar4;

- (void)hideTutorial;
- (void)showTutorial:(int)screen;
- (void)frameRateSliderChange;
- (void)copyBot:(Bot *)toBot fromBot:(Bot *)fromBot;
- (void)saveState;
- (void)restoreState;
- (void)resetObjects;
- (void)explosionAtX:(float)x Y:(float)y withColor:(Color *)c withRadius:(float)r;
- (void)startDemo;
- (void)singlePlayer;
- (void)bonusLevel;
- (void)multiPlayer;
- (void)setupBotsPositions; //must be called after bots are added to theGame players list
- (void)startSinglePlayerRound;
- (void)startBonusLevelRound;
- (void)startMultiPlayerRound;
- (void)quitGame:(id)sender;
- (void)playerWon:(int)p;
- (void)tieWithPlayers:(int)p1 andP2:(int)p2;
- (void)nextRound;
- (void)replay;
- (void)showPlayerWon;
- (void)hidePlayerWon;
- (void)showButtons;
- (void)hideButtons;
- (void)showStatusBar;
- (void)hideStatusBar;
- (void)pause;
- (void)unpause;
- (void)showPauseMenu;
- (void)hidePauseMenu;
- (void)showGameOver;
- (void)hideGameOver;
- (void)showStoryLine:(float)duration;
- (void)hideStoryLine;

- (void)setViewX:(float *)x Y:(float *)y Z:(float *)z;
- (void)updateView;

//bot methods
//- (void)addRandomBot:(Bot *)bot forPlayer:(int)playerId
- (void)addBot:(Bot *)bot forPlayer:(int)playerId;
- (void)botTouched:(Bot *)bot;
- (void)moveSelectorToBot:(Bot *)bot;
- (void)moveSelectorToBot2;
- (void)startSelecting;
- (void)startSelectBot:(Bot *)bot;
- (void)stopSelectBot;
- (void)showBotSelector;
- (void)hideBotSelector;
- (void)startUnSelectBot;
- (void)stopUnSelectBot;
- (void)doneSelecting;
- (void)startBattle;
- (void)showCountdownView;
- (void)hideCountdownView;
- (void)playSound:(SoundEffect *)audioPlayer;
- (void)playSoundNotTooMuch:(SoundEffect *)audioPlayer;

- (void)vibrate;

- (bool)shieldsOn;
- (bool)jammingOn;
- (bool)showComputersOn;

@end
