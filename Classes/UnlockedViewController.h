//
//  UnlockedViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 9/10/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class MainMenuViewController;

@interface UnlockedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UIButton *backButton;
	IBOutlet UITableView *settingsTable;

	MainMenuViewController *mainMenuViewController;
}

@property ATOMICITY_RETAIN UIButton *backButton;
@property ATOMICITY_RETAIN UITableView *settingsTable;

@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;

- (IBAction)back:(id)sender;
- (void) saveSettings;
- (void) updateMultiplayerStart;
- (int) getMultiplayerStartValue:(float)sliderValue;
- (float) getMultiplayerStartSliderValue;

- (void)disableShieldsChanged:(id)sender;
- (void)disableJammingChanged:(id)sender;
- (void)showComputersChanged:(id)sender;

@end
