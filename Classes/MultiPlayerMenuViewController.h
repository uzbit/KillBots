//
//  MultiPlayerMenuViewController.h
//  AiWars
//
//  Created by Ted McCormack on 8/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class MainMenuViewController;
@class MultiPlayerViewController;

@interface MultiPlayerMenuViewController : UIViewController 
{
	IBOutlet UIButton *newGameButton, *continueGameButton, *quitButton;

	bool hasSelected;
	
	MainMenuViewController *mainMenuViewController;
	MultiPlayerViewController *multiPlayerViewController;
}

@property ATOMICITY_RETAIN UIButton *newGameButton, *continueGameButton, *quitButton;

@property ATOMICITY_ASSIGN bool hasSelected;

@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;
@property ATOMICITY_RETAIN MultiPlayerViewController *multiPlayerViewController;

- (IBAction)newGame:(id)sender;
- (IBAction)continueGame:(id)sender;
- (IBAction)quit:(id)sender;


@end
