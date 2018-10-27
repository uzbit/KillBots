//
//  PlayerWonViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 4/13/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "PlayerWonViewController.h"
#import "AiWarsViewController.h"

@implementation PlayerWonViewController

@synthesize round, header;
@synthesize position1Name, position2Name, position3Name, position4Name;
@synthesize position1RoundsWon, position2RoundsWon, position3RoundsWon, position4RoundsWon;
@synthesize position1BotsKilled, position2BotsKilled, position3BotsKilled, position4BotsKilled;
@synthesize position1BotsDestroyed, position2BotsDestroyed, position3BotsDestroyed, position4BotsDestroyed;
@synthesize position1Icon, position2Icon, position3Icon, position4Icon;
@synthesize nextRoundButton;
@synthesize replayButton;
@synthesize aiWarsViewController;

- (IBAction)nextRound:(id)sender
{
	playSound(clickSound);

	[aiWarsViewController nextRound];
}

- (IBAction)replay:(id)sender
{
    playSound(clickSound);
    
    [aiWarsViewController replay];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[position1Name setText:@""];
	[position2Name setText:@""];
	[position3Name setText:@""];
	[position4Name setText:@""];
	
	[position1RoundsWon setText:@""];
	[position2RoundsWon setText:@""];
	[position3RoundsWon setText:@""];
	[position4RoundsWon setText:@""];
	
	[position1BotsKilled setText:@""];
	[position2BotsKilled setText:@""];
	[position3BotsKilled setText:@""];
	[position4BotsKilled setText:@""];

	[position1BotsDestroyed setText:@""];
	[position2BotsDestroyed setText:@""];
	[position3BotsDestroyed setText:@""];
	[position4BotsDestroyed setText:@""];
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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
    [super dealloc];
}


@end
