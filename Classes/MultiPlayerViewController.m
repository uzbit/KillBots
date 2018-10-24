//
//  MultiPlayerViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/29/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "MultiPlayerViewController.h"
#import "MainMenuViewController.h"

@implementation MultiPlayerViewController

@synthesize quitButton, startButton;
@synthesize decreaseRoundsButton, increaseRoundsButton, decreaseBotsButton, increaseBotsButton;
@synthesize addHumanButton, addComputerButton;
@synthesize rounds, bots;

@synthesize hasSelectedDoneOrQuit;

@synthesize tableView;

@synthesize mainMenuViewController;
@synthesize humanPlayerViewController;
@synthesize computerPlayerViewController;

- (IBAction)decreaseRounds:(id)sender
{
	RoundType roundType = [[mainMenuViewController aiWarsViewController] roundType];
	roundType--;
	if (roundType < ROUND_TYPE_1)
		roundType = ROUND_TYPE_1;
	else
		playSound(shortClickSound);
	[[mainMenuViewController aiWarsViewController] setRoundType:roundType];
	[self updateRounds];
}

- (IBAction)increaseRounds:(id)sender
{
	RoundType roundType = [[mainMenuViewController aiWarsViewController] roundType];
	roundType++;
	if (!liteVersion)
	{
		if (roundType > ROUND_TYPE_INF)
			roundType = ROUND_TYPE_INF;
		else
			playSound(shortClickSound);
	}
	else
	{
		if (roundType > ROUND_TYPE_5)
			roundType = ROUND_TYPE_5;	
		else
			playSound(shortClickSound);
	}
	[[mainMenuViewController aiWarsViewController] setRoundType:roundType];
	[self updateRounds];
}

- (void)updateRounds
{
	RoundType roundType = [[mainMenuViewController aiWarsViewController] roundType];

	[decreaseRoundsButton setEnabled:true];
	[increaseRoundsButton setEnabled:true];
	switch(roundType)
	{
		case ROUND_TYPE_1:
			[rounds setText:@"1"];
			[decreaseRoundsButton setEnabled:false];
			break;
		case ROUND_TYPE_2:
			[rounds setText:@"2"];
			break;
		case ROUND_TYPE_5:
			[rounds setText:@"5"];
			if (liteVersion)
				[increaseRoundsButton setEnabled:false];
			break;
		case ROUND_TYPE_10:
			[rounds setText:@"10"];
			break;
		case ROUND_TYPE_INF:
			[rounds setText:@"Inf"];
			[increaseRoundsButton setEnabled:false];
			break;
	}
}

- (IBAction)decreaseBots:(id)sender
{
	int botsPerPlayer = [[mainMenuViewController aiWarsViewController] botsPerPlayer];
	botsPerPlayer--;
	if (botsPerPlayer < 2)
		botsPerPlayer = 2;
	else
		playSound(shortClickSound);
	switch([[[[mainMenuViewController aiWarsViewController] theGame] players] count])
	{
		case 4:
			if (botsPerPlayer > 6)
				botsPerPlayer = 6;
			break;
		case 3:
			if (botsPerPlayer > 8)
				botsPerPlayer = 8;
			break;
	}
	[[mainMenuViewController aiWarsViewController] setBotsPerPlayer:botsPerPlayer];
	[self updateBots];
}

- (IBAction)increaseBots:(id)sender
{
	bool sound= true;
	int botsPerPlayer = [[mainMenuViewController aiWarsViewController] botsPerPlayer];
	botsPerPlayer++;
	if (botsPerPlayer > 10)
	{
		botsPerPlayer = 10;
		sound = false;
	}
	switch([[[[mainMenuViewController aiWarsViewController] theGame] players] count])
	{
		case 4:
			if (botsPerPlayer > 6)
			{
				botsPerPlayer = 6;
				sound = false;
			}
			break;
		case 3:
			if (botsPerPlayer > 8)
			{
				botsPerPlayer = 8;
				sound = false;
			}
			break;
	}
	if (sound)
		playSound(shortClickSound);
	[[mainMenuViewController aiWarsViewController] setBotsPerPlayer:botsPerPlayer];
	[self updateBots];
}

- (void)updateBots
{
	int botsPerPlayer = [[mainMenuViewController aiWarsViewController] botsPerPlayer];
	[bots setText:[NSString stringWithFormat:@"%i", botsPerPlayer]];
	
	[decreaseBotsButton setEnabled:true];
	[increaseBotsButton setEnabled:true];
	if (botsPerPlayer == 2)
	{
		[decreaseBotsButton setEnabled:false];
	}
	else if (botsPerPlayer == 10)
	{
		[increaseBotsButton setEnabled:false];
	}	
	else
	{
		switch([[[[mainMenuViewController aiWarsViewController] theGame] players] count])
		{
			case 4:
				if (botsPerPlayer == 6)
					[increaseBotsButton setEnabled:false];
				break;
			case 3:
				if (botsPerPlayer == 8)
					[increaseBotsButton setEnabled:false];
				break;
		}
	}
}

- (IBAction)addHuman:(id)sender
{
	playSound(clickSound);

	if ([[[[mainMenuViewController aiWarsViewController] theGame] players] count] == 4)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Only 4 players are allowed." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		[humanPlayerViewController setPlayerIndex:-1];
		[[humanPlayerViewController playerName] setText:@""];
		[humanPlayerViewController setSelectedColor:0];
		[[humanPlayerViewController colorTable] reloadData];
		[[humanPlayerViewController colorTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		[humanPlayerViewController setSelectedBase:0];
		[[humanPlayerViewController baseTable] reloadData];
		[[humanPlayerViewController baseTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		[[humanPlayerViewController header] setText:@"Add Human Player"];
		[[humanPlayerViewController deleteButton] setAlpha:0];
		[humanPlayerViewController updatePreview];
		[self showHumanPlayer];
	}
}

- (IBAction)addComputer:(id)sender
{
	playSound(clickSound);

	if ([[[[mainMenuViewController aiWarsViewController] theGame] players] count] == 4)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Only 4 players are allowed." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		[computerPlayerViewController setPlayerIndex:-1];
		[computerPlayerViewController setSelectedType:0];
		[[computerPlayerViewController header] setText:@"Add Computer Player"];
		[[computerPlayerViewController deleteButton] setAlpha:0];
		[[computerPlayerViewController botTable] reloadData];
		[computerPlayerViewController updatePreview];
		[[computerPlayerViewController descriptionField] setText:[[[[mainMenuViewController aiWarsViewController] computerPlayers] objectAtIndex:0] description]];
		[self showComputerPlayer];
	}
}

- (IBAction)quit:(id)sender
{
	if (hasSelectedDoneOrQuit)
		return;
	else
		hasSelectedDoneOrQuit = true;
	
	playSound(clickSound);

	[[[mainMenuViewController aiWarsViewController] theGame] setGameType:GAME_TYPE_MULTIPLAYER];
	[[mainMenuViewController aiWarsViewController] saveState];
	
	[mainMenuViewController showMultiPlayerMenu];
	[self.view setAlpha:0];
}

- (IBAction)start:(id)sender
{
	
	if (hasSelectedDoneOrQuit)
		return;
	else
		hasSelectedDoneOrQuit = true;
	
	playSound(clickSound);

	bool foundHuman = false;
	for (Player *p in [[[mainMenuViewController aiWarsViewController] theGame] players])
		if ([p isComputer] < 0)
			foundHuman = true;
	
	if (!foundHuman)
	{	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Must be at least one human player." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if ([[[[mainMenuViewController aiWarsViewController] theGame] players] count] < 2)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please add at least 2 players." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		[mainMenuViewController startMultiPlayer];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		humanPlayerViewController = [[HumanPlayerViewController alloc] initWithNibName:@"HumanPlayer" bundle:nil];
		[[humanPlayerViewController cancelButton] setAlpha:1.0];
		[[humanPlayerViewController doneButton] setAlpha:1.0];		
		[[humanPlayerViewController quitButton] setAlpha:0.0];
		[humanPlayerViewController.view sendSubviewToBack:[humanPlayerViewController quitButton]];
		[[humanPlayerViewController startButton] setAlpha:0.0];
		[humanPlayerViewController.view sendSubviewToBack:[humanPlayerViewController startButton]];
		[humanPlayerViewController setMultiPlayerViewController:self];

		computerPlayerViewController = [[ComputerPlayerViewController alloc] initWithNibName:@"ComputerPlayer" bundle:nil];
		[computerPlayerViewController setSelectedType:-1];
		[computerPlayerViewController setPlayerIndex:-1];
		[computerPlayerViewController setMultiPlayerViewController:self];
		[[computerPlayerViewController descriptionField] setText:@""];
    
		hasSelectedDoneOrQuit = false;
	}
    return self;
}

- (void)viewDidLoad
{
//	self.view.frame = CGRectMake(-80, 80, 480, 320);
//	self.view.transform = CGAffineTransformMakeRotation(M_PI/2);

	[[humanPlayerViewController view] setAlpha:0];
	[self.view addSubview:[humanPlayerViewController view]];

	[[computerPlayerViewController view] setAlpha:0];
	[self.view addSubview:[computerPlayerViewController view]];
}

- (void)showHumanPlayer
{
	[UIView beginAnimations:@"showHumanPlayer" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[humanPlayerViewController view] setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hideHumanPlayer
{
	hasSelectedDoneOrQuit = false;
	
	[UIView beginAnimations:@"hideHumanPlayer" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[humanPlayerViewController view] setAlpha:0];
	
	[UIView commitAnimations];	
}

- (void)showComputerPlayer
{
	[UIView beginAnimations:@"showComputerPlayer" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[computerPlayerViewController view] setAlpha:1];
	
	[UIView commitAnimations];
}

- (void)hideComputerPlayer
{
	hasSelectedDoneOrQuit = false;
	
	[UIView beginAnimations:@"hideComputerPlayer" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	
	[[computerPlayerViewController view] setAlpha:0];
	
	[UIView commitAnimations];	
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/
/*
- (void)loadView
{
}
*/

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
*/

/*
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[mainMenuViewController aiWarsViewController] theGame] players] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
	Player *player = [[[[mainMenuViewController aiWarsViewController] theGame] players] objectAtIndex:indexPath.row];

	UILabel *label;
	UIImageView *icon;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
		bg.backgroundColor = [UIColor clearColor];
		cell.backgroundView = bg;
		[bg release];
		
    	label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 192, 30)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont boldSystemFontOfSize:14]];
		[label setTextColor:[UIColor whiteColor]];
		[label setTag:222];
		[cell addSubview:label];
		[label release];
		
		icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
		[icon setTag:224];
		[cell addSubview:icon];
		[icon release];
	}
	
	//player name
	label = (UILabel *)[cell viewWithTag:222];
	[label setText:[player name]];

	//icon
	icon = (UIImageView *)[cell viewWithTag:224];
	NSString *textureName;
	if ([player isComputer] >= 0)
		textureName = @"base_bot4_noshadow.png";
	else
		textureName = [NSString stringWithFormat:@"base_bot%i_noshadow.png",([player baseTexture]+1)];
	[icon setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:textureName] color:[UIColor colorWithRed:[[player color] red] green:[[player color] green] blue:[[player color] blue] alpha:1]]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	playSound(clickSound);

	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	Player *player = [[[[mainMenuViewController aiWarsViewController] theGame] players] objectAtIndex:indexPath.row];

	if ([player isComputer] < 0)
	{
		[humanPlayerViewController setPlayerIndex:indexPath.row];
		[[humanPlayerViewController playerName] setText:[player name]];
		[humanPlayerViewController setSelectedColor:[[[mainMenuViewController aiWarsViewController] colors] indexOfObject:[player color]]];
		[[humanPlayerViewController colorTable] reloadData];
		/*[[humanPlayerViewController colorTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[humanPlayerViewController selectedColor] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];*/
		[humanPlayerViewController setSelectedBase:[player baseTexture]];
		[[humanPlayerViewController baseTable] reloadData];
		/*[[humanPlayerViewController baseTable] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[humanPlayerViewController selectedBase] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];*/
		[[humanPlayerViewController header] setText:@"Edit Human Player"];
		[[humanPlayerViewController deleteButton] setAlpha:1];
		[humanPlayerViewController updatePreview];
		[self showHumanPlayer];
	}
	else
	{
		Player *p;
		for (p in [[mainMenuViewController aiWarsViewController] computerPlayers])
			if ([[p name] compare:[player name]] == NSOrderedSame)
				break;
	
		[computerPlayerViewController setSelectedType:[[[mainMenuViewController aiWarsViewController] computerPlayers] indexOfObject:p]];
		[computerPlayerViewController setPlayerIndex:indexPath.row];
		[[computerPlayerViewController header] setText:@"Edit Computer Player"];
		[[computerPlayerViewController deleteButton] setAlpha:1];
		[computerPlayerViewController updatePreview];
		[[computerPlayerViewController descriptionField] setText:[p description]];
		[[computerPlayerViewController botTable] reloadData];
		[computerPlayerViewController updatePreview];
		[self showComputerPlayer];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc
{
	[humanPlayerViewController release];
	[computerPlayerViewController release];
    [super dealloc];
}


@end

