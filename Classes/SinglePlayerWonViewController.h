//
//  SinglePlayerWonViewController.h
//  AiWars
//
//  Created by Ted McCormack on 8/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class AiWarsViewController;

@interface SinglePlayerWonViewController : UIViewController 
{
	IBOutlet UIView *scoreView, *quoteView;

	IBOutlet UILabel *level;
	IBOutlet UILabel *header;
	IBOutlet UILabel *totalLevelAttempts;
	IBOutlet UILabel *unusedResources;
	IBOutlet UILabel *botsRemaining;
	IBOutlet UILabel *currentLevelAttempts;
	IBOutlet UILabel *subtotal;
	IBOutlet UILabel *attemptMultiplyer;
	IBOutlet UILabel *levelScore;
	IBOutlet UILabel *totalScore;
	
	IBOutlet UILabel *quoteLabel, *personLabel;
	
	IBOutlet UIButton *nextRoundButton;
	
	AiWarsViewController *aiWarsViewController;

	NSMutableArray *quotes;
}

@property ATOMICITY_RETAIN UIView *scoreView, *quoteView;

@property ATOMICITY_RETAIN UILabel *level;
@property ATOMICITY_RETAIN UILabel *header;
@property ATOMICITY_RETAIN UILabel *totalLevelAttempts;
@property ATOMICITY_RETAIN UILabel *unusedResources;
@property ATOMICITY_RETAIN UILabel *botsRemaining;
@property ATOMICITY_RETAIN UILabel *currentLevelAttempts;
@property ATOMICITY_RETAIN UILabel *subtotal;
@property ATOMICITY_RETAIN UILabel *attemptMultiplyer;
@property ATOMICITY_RETAIN UILabel *levelScore;
@property ATOMICITY_RETAIN UILabel *totalScore;

@property ATOMICITY_RETAIN UILabel *quoteLabel, *personLabel;

@property ATOMICITY_RETAIN UIButton *nextRoundButton;
@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

@property ATOMICITY_RETAIN NSMutableArray *quotes;

- (IBAction)nextRound:(id)sender;
- (void)setupQuotes;

@end
