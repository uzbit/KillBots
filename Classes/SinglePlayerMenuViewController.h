//
//  SinglePlayerViewController.h
//  AiWars
//
//  Created by Ted McCormack on 5/13/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "BonusLevelsViewController.h"

@class MainMenuViewController;
@class SinglePlayerIntroViewController;
@class BonusLevelsViewController;

@interface SinglePlayerMenuViewController : UIViewController <UIAlertViewDelegate>{
	IBOutlet UIButton *newGameButton, *continueGameButton, *quitButton, *bonusButton;
	IBOutlet UILabel *topScore;
	
	bool hasSelected;
	
	MainMenuViewController *mainMenuViewController;
	SinglePlayerIntroViewController *singlePlayerIntroViewController;
	BonusLevelsViewController *bonusLevelsViewController;
}

@property ATOMICITY_RETAIN UIButton *newGameButton, *continueGameButton, *quitButton, *bonusButton;
@property ATOMICITY_RETAIN UILabel *topScore;

@property ATOMICITY_ASSIGN bool hasSelected;

@property ATOMICITY_ASSIGN SinglePlayerIntroViewController *singlePlayerIntroViewController;
@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;
@property ATOMICITY_RETAIN BonusLevelsViewController *bonusLevelsViewController;


- (IBAction)newGame:(id)sender;
- (IBAction)continueGame:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)bonusLevels:(id)sender;
- (void)showBonusLevels;
- (void)hideBonusLevels;

@end
