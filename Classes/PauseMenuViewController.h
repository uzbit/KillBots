//
//  PauseMenuViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 4/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class AiWarsViewController;

@interface PauseMenuViewController : UIViewController
{
	IBOutlet UIButton *quitButton, *continueButton;
	
	AiWarsViewController *aiWarsViewController;
}

@property ATOMICITY_RETAIN UIButton *quitButton, *continueButton;
@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

- (IBAction)quit:(id)sender;
- (IBAction)continue:(id)sender;

@end
