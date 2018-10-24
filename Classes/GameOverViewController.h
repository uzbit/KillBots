//
//  GameOverViewController.h
//  AiWars
//
//  Created by Ted McCormack on 5/26/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class AiWarsViewController;

@interface GameOverViewController : UIViewController 
{
	IBOutlet UIButton *continueButton;
	IBOutlet UILabel *titleLabel, *successRate, *finalScore, *storyLabel, *successRateLabel, *finalScoreLabel;
	
	AiWarsViewController *aiWarsViewController;
}

@property ATOMICITY_RETAIN UIButton *continueButton;
@property ATOMICITY_RETAIN UILabel *titleLabel, *successRate, *finalScore, *storyLabel, *successRateLabel, *finalScoreLabel;
@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

- (IBAction)continue:(id)sender;

@end
