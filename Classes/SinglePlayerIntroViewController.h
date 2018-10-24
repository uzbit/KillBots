//
//  SinglePlayerIntroViewController.h
//  AiWars
//
//  Created by Ted McCormack on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class MainMenuViewController;

@interface SinglePlayerIntroViewController : UIViewController 
{
	IBOutlet UIButton *backButton, *nextButton;
	IBOutlet UILabel *storyLine;
	IBOutlet UIImageView *storyImage;
	int currentPage;
	MainMenuViewController *mainMenuViewController;
}

@property ATOMICITY_RETAIN UIButton *backButton, *nextButton;
@property ATOMICITY_RETAIN UILabel *storyLine;
@property ATOMICITY_RETAIN UIImageView *storyImage;

@property ATOMICITY_NONE int currentPage;
@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;

- (IBAction)back:(id)sender;
- (IBAction)next:(id)sender;
- (void)setStoryLineForCurrentPage;

@end
