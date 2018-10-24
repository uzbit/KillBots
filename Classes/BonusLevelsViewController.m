//
//  BonusLevelsViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 11/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "BonusLevelsViewController.h"
#import "SinglePlayerMenuViewController.h"
#import "MainMenuViewController.h"

@implementation BonusLevelsViewController

@synthesize backButton;

@synthesize singlePlayerMenuViewController;

- (IBAction)back:(id)sender
{
	playSound(clickSound);
	[singlePlayerMenuViewController hideBonusLevels];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)startBonusLevel:(id)sender
{
	playSound(clickSound);
	[[[[[singlePlayerMenuViewController mainMenuViewController] aiWarsViewController] bonusLevelRounds] configuration] removeAllObjects];
	[[[[singlePlayerMenuViewController mainMenuViewController] aiWarsViewController] theGame] setRound:[sender tag]];
	[[[[singlePlayerMenuViewController mainMenuViewController] aiWarsViewController] theGame] setGameType:GAME_TYPE_BONUS_LEVEL];
	[[singlePlayerMenuViewController mainMenuViewController] startBonusLevel];
}

- (void)roundWon:(int)round
{
	[(UIButton *)[self.view viewWithTag:round] setBackgroundImage:[UIImage imageNamed:@"star_small.png"] forState:UIControlStateNormal];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	int x, y;
	
	for (int level = 0; level < BONUS_LEVELS_NUM; level++)
	{
		x = (level%8)*55+22;
		y = (level/8)*55+50;
		UIButton *bonusLevelButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 46, 43)];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"bonusLevel%i", level+1]])
			[bonusLevelButton setBackgroundImage:[UIImage imageNamed:@"star_small.png"] forState:UIControlStateNormal];
		else
			[bonusLevelButton setBackgroundImage:[UIImage imageNamed:@"star_small_grey.png"] forState:UIControlStateNormal];
		[bonusLevelButton setTitleColor:UIColorFromHex(0x336699) forState:UIControlStateNormal];
		bonusLevelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
		[bonusLevelButton setTitle:[NSString stringWithFormat:@"%i", level+1] forState:UIControlStateNormal];
		[bonusLevelButton addTarget:self action:@selector(startBonusLevel:) forControlEvents:UIControlEventTouchUpInside];
		[bonusLevelButton setTag:level+1];
		[self.view addSubview:bonusLevelButton];
		[bonusLevelButton release];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}


@end
