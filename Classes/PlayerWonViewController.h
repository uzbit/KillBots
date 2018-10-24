//
//  PlayerWonViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 4/13/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class AiWarsViewController;

@interface PlayerWonViewController : UIViewController
{
	IBOutlet UILabel *round, *header;
	IBOutlet UILabel *position1Name, *position2Name, *position3Name, *position4Name;
	IBOutlet UILabel *position1RoundsWon, *position2RoundsWon, *position3RoundsWon, *position4RoundsWon;
	IBOutlet UILabel *position1BotsKilled, *position2BotsKilled, *position3BotsKilled, *position4BotsKilled;
	IBOutlet UILabel *position1BotsDestroyed, *position2BotsDestroyed, *position3BotsDestroyed, *position4BotsDestroyed;
	IBOutlet UIImageView *position1Icon, *position2Icon, *position3Icon, *position4Icon;
	IBOutlet UIButton *nextRoundButton;

	AiWarsViewController *aiWarsViewController;
}

@property ATOMICITY_RETAIN UILabel *round, *header;
@property ATOMICITY_RETAIN UILabel *position1Name, *position2Name, *position3Name, *position4Name;
@property ATOMICITY_RETAIN UILabel *position1RoundsWon, *position2RoundsWon, *position3RoundsWon, *position4RoundsWon;
@property ATOMICITY_RETAIN UILabel *position1BotsKilled, *position2BotsKilled, *position3BotsKilled, *position4BotsKilled;
@property ATOMICITY_RETAIN UILabel *position1BotsDestroyed, *position2BotsDestroyed, *position3BotsDestroyed, *position4BotsDestroyed;
@property ATOMICITY_RETAIN UIImageView *position1Icon, *position2Icon, *position3Icon, *position4Icon;
@property ATOMICITY_RETAIN UIButton *nextRoundButton;
@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

- (IBAction)nextRound:(id)sender;

@end
