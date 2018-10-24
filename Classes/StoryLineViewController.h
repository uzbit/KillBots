//
//  StoryLineViewController.h
//  AiWars
//
//  Created by Ted McCormack on 6/1/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class AiWarsViewController;

@interface StoryLineViewController : UIViewController <UIAlertViewDelegate>
{
	IBOutlet UIButton *continueButton, *quitButton;
	IBOutlet UILabel *storyLine, *titleLabel, *roundLevel;
	IBOutlet UIImageView *progressImageView;
	
	bool hasSelected;
	
	AiWarsViewController *aiWarsViewController;
}

@property ATOMICITY_RETAIN UIButton *continueButton, *quitButton;
@property ATOMICITY_RETAIN UILabel *storyLine, *titleLabel, *roundLevel;
@property ATOMICITY_RETAIN UIImageView *progressImageView;
@property ATOMICITY_ASSIGN bool hasSelected;
@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

- (IBAction)continue:(id)sender;
- (IBAction)quit:(id)sender;


@end
