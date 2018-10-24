//
//  PauseMenuViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 4/14/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "PauseMenuViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"
#import "Types.h"

@implementation PauseMenuViewController

@synthesize quitButton, continueButton;

@synthesize aiWarsViewController;

- (IBAction)quit:(id)sender
{
	[aiWarsViewController saveState];
	[aiWarsViewController quitGame:sender];
}

- (IBAction)continue:(id)sender
{
	playSound(clickSound);

	[aiWarsViewController unpause];
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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
