//
//  SinglePlayerIntroViewController.m
//  AiWars
//
//  Created by Ted McCormack on 6/30/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SinglePlayerIntroViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"

#define NUM_STORY_PAGES		3

@implementation SinglePlayerIntroViewController


@synthesize backButton, nextButton;
@synthesize storyLine;
@synthesize storyImage;
@synthesize currentPage;
@synthesize mainMenuViewController;


- (IBAction)back:(id)sender
{
	playSound(clickSound);

	currentPage--;
	if (currentPage < 0)
		[mainMenuViewController hideSinglePlayerIntro];
	else
		[self setStoryLineForCurrentPage];
}

- (IBAction)next:(id)sender
{
	playSound(clickSound);

	currentPage++;
	if (currentPage < NUM_STORY_PAGES)
		[self setStoryLineForCurrentPage];
	else
	{
		[mainMenuViewController hideSinglePlayerIntro];
		[mainMenuViewController showHumanPlayer];
	}
	
}

- (void)setStoryLineForCurrentPage
{
	switch (currentPage)
	{
		case 0:
			[storyLine setText:@"The KillBot was the latest and greatest revolutionary advancement in artificial intelligence, helping humans stay at peace with each other throughout the world. The entire population of KillBots were connected to a global network in order to work together more efficiently. Everything was going to plan until one day..."];
			[storyImage setImage:[UIImage imageNamed:@"singleplayer_story1.png"]];
			break;
		case 1:
			[storyLine setText:@"The network of KillBots turned against the humans!\n\nBefore much damage was done, the humans quickly deployed a virus to disable 99% of the KillBot population. Unfortunately, a number of remote groups were unaffected by the virus and continued to roam the planet looking for trouble."];
			[storyImage setImage:[UIImage imageNamed:@"singleplayer_story2.png"]];
			break;
		case 2:
			[storyLine setText:@"A small army of KillBots have been reprogrammed to attack the rogue populations. It is your mission to command and enhance this army to destroy all enemy KillBots!\n\nGood luck!"];
			[storyImage setImage:[UIImage imageNamed:@"singleplayer_story3.png"]];
			break;
		default:
			[storyLine setText:@""];
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
