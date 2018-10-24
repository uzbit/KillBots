//
//  BonusLevelsViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 11/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "Color.h"
#import "Types.h"

#define BONUS_LEVELS_NUM	20


@class SinglePlayerMenuViewController;

@interface BonusLevelsViewController : UIViewController
{
	IBOutlet UIButton *backButton;
	
	SinglePlayerMenuViewController *singlePlayerMenuViewController;
}

@property ATOMICITY_RETAIN UIButton *backButton;

@property ATOMICITY_ASSIGN SinglePlayerMenuViewController *singlePlayerMenuViewController;

- (IBAction)back:(id)sender;
- (void)startBonusLevel:(id)sender;
- (void)roundWon:(int)round;

@end
