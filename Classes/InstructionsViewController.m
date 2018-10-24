//
//  InstructionsViewController.m
//  AiWars
//
//  Created by Ted McCormack on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "InstructionsViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"

#define NUM_INSTRUCTIONS_PAGES		5

@implementation InstructionsViewController

@synthesize backButton, nextButton;
@synthesize image;
@synthesize instructions;

@synthesize currentPage;
@synthesize mainMenuViewController;


- (IBAction)back:(id)sender
{
	playSound(clickSound);

	currentPage--;
	if (currentPage < 0)
		[mainMenuViewController showMainMenu];
	else
		[self setInstructionsForCurrentPage];
}

- (IBAction)next:(id)sender
{
	playSound(clickSound);

	currentPage++;
	if (currentPage < NUM_INSTRUCTIONS_PAGES)
		[self setInstructionsForCurrentPage];
	else
		[mainMenuViewController showMainMenu];
}

- (void)setInstructionsForCurrentPage
{
	//UIView
	switch (currentPage)
	{
		case 0:
			[image setFrame:CGRectMake(20, 52, 300, 200)];
			[image setImage:[UIImage imageNamed:@"instructions1.png"]];
			[instructions setFrame:CGRectMake(328, 52, 132, 200)];
			[instructions setText:@"Before a battle starts, you must select your army of bots.\n\nAll bots in your army are highlighted, and you may touch any bot to start."];
			break;
		case 1:
			[image setFrame:CGRectMake(20, 52, 300, 200)];
			[image setImage:[UIImage imageNamed:@"instructions2.png"]];
			[instructions setFrame:CGRectMake(328, 52, 132, 200)];
			[instructions setText:@"The command center allows you to select the bot's weapon, shields, jamming, and mobilization."];
			break;
		case 2:
			[image setFrame:CGRectMake(20, 52, 300, 200)];
			[image setImage:[UIImage imageNamed:@"instructions3.png"]];
			[instructions setFrame:CGRectMake(328, 52, 132, 200)];
			[instructions setText:@"When you are finished selecting your bots, touch the \"Done\" button. The bots will take care of the rest."];
			break;
		case 3:
			[image setFrame:CGRectMake(0, 0, 0, 0)];
			[instructions setFrame:CGRectMake(0, 50, 480, 200)];
			[instructions setText:@"SINGLE PLAYER\n\nSingle player mode consists of 20 rounds with bosses at the 5th, 10th, 15th, and 20th rounds. Each round you will receive a certain amount of resources to build your army. You must complete each round before continuing to the next, and any resources you did not use will rollover to the next round."];
			break;
		case 4:
			[image setFrame:CGRectMake(0, 0, 0, 0)];
			[instructions setFrame:CGRectMake(0, 50, 480, 200)];
			[instructions setText:@"MULTI PLAYER\n\nIn each multi player round, every player receives the same amount of resources. After a round is finished, the next round will consist of double the resources as the previous. Unused resources will rollover to the next round."];
			break;
		default:
			[instructions setText:@""];
			break;			
	}
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		currentPage = 0;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
