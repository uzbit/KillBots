//
//  InstructionsViewController.h
//  AiWars
//
//  Created by Ted McCormack on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class MainMenuViewController;

@interface InstructionsViewController : UIViewController 
{
	IBOutlet UIButton *backButton, *nextButton;
	IBOutlet UIImageView *image;
	IBOutlet UITextView *instructions;
	UIImage *storyImage;
	int currentPage;
	MainMenuViewController *mainMenuViewController;
}

@property ATOMICITY_RETAIN UIButton *backButton, *nextButton;
@property ATOMICITY_RETAIN UIImageView *image;
@property ATOMICITY_RETAIN UITextView *instructions;

@property ATOMICITY_NONE int currentPage;
@property ATOMICITY_ASSIGN MainMenuViewController *mainMenuViewController;

- (IBAction)back:(id)sender;
- (IBAction)next:(id)sender;
- (void)setInstructionsForCurrentPage;

@end
