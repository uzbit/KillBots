//
//  SinglePlayerWonViewController.m
//  AiWars
//
//  Created by Ted McCormack on 8/2/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SinglePlayerWonViewController.h"
#import "AiWarsViewController.h"

@implementation SinglePlayerWonViewController

@synthesize scoreView, quoteView;

@synthesize level;
@synthesize header;
@synthesize totalLevelAttempts;
@synthesize unusedResources;
@synthesize botsRemaining;
@synthesize currentLevelAttempts;
@synthesize levelScore;
@synthesize subtotal;
@synthesize attemptMultiplyer;
@synthesize totalScore;

@synthesize quoteLabel, personLabel;

@synthesize nextRoundButton;
@synthesize aiWarsViewController;

@synthesize quotes;

- (IBAction)nextRound:(id)sender
{
	playSound(clickSound);
	
	[aiWarsViewController nextRound];
}

- (void)setupQuotes
{
	quotes = [[NSMutableArray alloc] initWithCapacity:40];

	[quotes addObject:[NSArray arrayWithObjects:@"Every failure brings with it the seed of an equivalent success.", @"Napoleon Hill", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"We learn wisdom from failure much more than success. We often discover what we will do, by finding out what we will not do.", @"Samuel Smiles", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"I was never afraid of failure, for I would sooner fail than not be among the best.", @"John Keats", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Never let the fear of striking out get in your way.", @"Babe Ruth", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"One who fears failure limits his activities. Failure is only the opportunity to more intelligently begin again.", @"Henry Ford", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Little minds are tamed and subdued by misfortunes; but great minds rise above them.", @"Washington Irving", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"What would life be if we had no courage to attempt anything?", @"Vincent van Gogh", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The greatest men sometimes overshoot themselves, but then their very mistakes are so many lessons of instruction.", @"Tom Browne", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Experience teaches slowly, and at the cost of mistakes.", @"James A. Froude", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"He who fears being conquered is sure of defeat.", @"Napoleon Bonaparte", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Failure teaches success.", @"Japanese Saying", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Take calculated risks. That is quite different from being rash.", @"George S. Patton", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Keep steadily before you the fact that all true success depends at last upon yourself.", @"Theodore T. Hunger", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Success is the sum of small efforts, repeated day in and day out.", @"Robert Collier", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"A failure is a man who has blundered, but is not able to cash in on the experience.", @"Elbert Hubbard", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The difference between a successful person and others is not a lack of strength, not a lack of knowledge, but rather a lack in will.", @"Vince Lombardi", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Nothing can stop the man with the right mental attitude from achieving his goal; nothing on earth can help the man with the wrong mental attitude.", @"Thomas Jefferson", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Success does not consist in never making blunders, but in never making the same one a second time.", @"Josh Billings", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Success is the good fortune that comes from aspiration, desperation, perspiration and inspiration.", @"Evan Esar", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Impatience never commanded success.", @"Edwin H. Chapin", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"If at first you don't succeed, try, try again. Then quit. There's no use being a damn fool about it.", @"W.C. Fields", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The power of imagination makes us infinite.", @"John Muir", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Winning isn't everything, but wanting to win is.", @"Vince Lombardi", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The significance of a man is not in what he attains but in what he longs to attain.", @"Kahlil Gibran", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Who aims at excellence will be above mediocrity; who aims at mediocrity will be far short of it.", @"Burmese Saying", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Effort only fully releases its reward after a person refuses to quit.", @"Napoleon Hill", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Shallow men believe in luck, strong men believe in cause and effect.", @"Ralph Waldo Emerson", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Commitment leads to action. Action brings your dream closer.", @"Marcia Wieder", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"It's to be expected that you make mistakes when you're breaking new ground.", @"Jerry Greenfield", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"I didn't fail the test, I just found 100 ways to do it wrong.", @"Benjamin Franklin", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Why did I want to win? because I didn't want to lose!", @"Max Schmelling ", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Everyone is trying to accomplish something big, not realizing that life is made up of little things.", @"Frank A. Clark ", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"I believe the greater the handicap, the greater the triumph.", @"John H. Johnson", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Always bear in mind that your own resolution to succeed is more important than any other one thing.", @"Abraham Lincoln", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"There are no gains without pains.", @"Benjamin Franklin", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The difference between the impossible and the possible lies in a person's determination.", @"Tommy Lasorda", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"The will to conquer is the first condition of victory.", @"Ferdinand Foch", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Most of the important things in the world have been accomplished by people who have kept on trying when there seemed to be no help at all.", @"Dale Carnegie", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Success is not final, failure is not fatal: it is the courage to continue that counts.", @"Winston Churchill", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"For a righteous man falls seven times, and rises again.", @"[Proverbs 24:16] Bible", nil]];
	[quotes addObject:[NSArray arrayWithObjects:@"Discipline is the soul of an army. It makes small numbers formidable, procures success to the weak, and esteem to all.", @"George Washington", nil]];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		[self setupQuotes];
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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
	[quotes release];
    [super dealloc];
}


@end
