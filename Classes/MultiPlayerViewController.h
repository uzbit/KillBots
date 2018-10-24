//
//  MultiPlayerViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/29/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Types.h"
#import "AiWarsViewController.h"
#import "HumanPlayerViewController.h"
#import "ComputerPlayerViewController.h"


@class MainMenuViewController;

@interface MultiPlayerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UIButton *quitButton, *startButton;
	IBOutlet UIButton *decreaseRoundsButton, *increaseRoundsButton, *decreaseBotsButton, *increaseBotsButton;
	IBOutlet UIButton *addHumanButton, *addComputerButton;
	IBOutlet UILabel *rounds, *bots;
	
	IBOutlet UITableView *tableView;
	
	bool hasSelectedDoneOrQuit;
	
	MainMenuViewController *mainMenuViewController;
	HumanPlayerViewController *humanPlayerViewController;
	ComputerPlayerViewController *computerPlayerViewController;
}

@property ATOMICITY_RETAIN UIButton *quitButton, *startButton;
@property ATOMICITY_RETAIN UIButton *decreaseRoundsButton, *increaseRoundsButton, *decreaseBotsButton, *increaseBotsButton;
@property ATOMICITY_RETAIN UIButton *addHumanButton, *addComputerButton;
@property ATOMICITY_RETAIN UILabel *rounds, *bots;

@property ATOMICITY_RETAIN UITableView *tableView;

@property ATOMICITY_ASSIGN bool hasSelectedDoneOrQuit;

@property ATOMICITY_RETAIN MainMenuViewController *mainMenuViewController;
@property ATOMICITY_RETAIN HumanPlayerViewController *humanPlayerViewController;
@property ATOMICITY_RETAIN ComputerPlayerViewController *computerPlayerViewController;

- (IBAction)decreaseRounds:(id)sender;
- (IBAction)increaseRounds:(id)sender;
- (void)updateRounds;
- (IBAction)decreaseBots:(id)sender;
- (IBAction)increaseBots:(id)sender;
- (void)updateBots;
- (IBAction)addHuman:(id)sender;
- (void)showHumanPlayer;
- (void)hideHumanPlayer;
- (void)showComputerPlayer;
- (void)hideComputerPlayer;
- (IBAction)addComputer:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)start:(id)sender;
//- (IBAction)movementTypeChanged:(id)sender;

@end
