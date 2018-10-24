//
//  ComputerPlayerViewController.m
//  AiWars
//
//  Created by Ted McCormack on 6/10/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "ComputerPlayerViewController.h"
#import "HumanPlayerViewController.h"
#import "Player.h"
#import "MultiPlayerViewController.h"
#import "MainMenuViewController.h"


@implementation ComputerPlayerViewController

@synthesize header;
@synthesize botTable;
@synthesize previewImage;
@synthesize cancelButton, deleteButton, doneButton;
@synthesize descriptionField;

@synthesize selectedType;
@synthesize playerIndex;

@synthesize multiPlayerViewController;

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] removeObjectAtIndex:playerIndex];
		[[multiPlayerViewController tableView] reloadData];
		[multiPlayerViewController hideComputerPlayer];
		[multiPlayerViewController updateBots];
	}
}

- (IBAction)cancel:(id)sender
{
	playSound(clickSound);

	[multiPlayerViewController hideComputerPlayer];
}

- (IBAction)delete:(id)sender
{
	playSound(clickSound);

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	//[alert setNumberOfRows:1];
	[alert show];
	[alert release];	
}

- (IBAction)done:(id)sender
{
	playSound(clickSound);

	if (selectedType >= 0)
	{
		Player *player = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] computerPlayers] objectAtIndex:selectedType];
		if (playerIndex < 0 && [[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] count] < 4)
			[[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] addObject:player];
		else
			[[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] replaceObjectAtIndex:playerIndex withObject:player];
		
		int botsPerPlayer = [[[multiPlayerViewController mainMenuViewController] aiWarsViewController] botsPerPlayer];
		switch([[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] count])
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
		[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] setBotsPerPlayer:botsPerPlayer];
		[multiPlayerViewController updateBots];
		
		[[multiPlayerViewController tableView] reloadData];
	}	
	[multiPlayerViewController hideComputerPlayer];
}

- (void)updatePreview
{
	if (selectedType >= 0)
	{
		Player *player = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] computerPlayers] objectAtIndex:selectedType];
		Color *color = [player color];
		[previewImage setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:@"base_bot4_noshadow.png"] color:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:1]]];
	}
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
	return [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] computerPlayers] count];;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	UILabel *label;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
		UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
		bg.backgroundColor = [UIColor clearColor];
		cell.backgroundView = bg;
		[bg release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 192, 30)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont boldSystemFontOfSize:14]];
		[label setTextColor:[UIColor whiteColor]];
		[label setTag:224];
		[cell addSubview:label];
		[label release];

		label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
		[label setTag:225];
		[cell addSubview:label];
		[label release];
	}
	
	if (indexPath.row == selectedType)
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];  
	else
		[cell setAccessoryType:UITableViewCellAccessoryNone];  
	
	Player *player = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] computerPlayers] objectAtIndex:indexPath.row];
	
	//name
	label = (UILabel *)[cell viewWithTag:224];
	[label setText:[player name]];
	
	//color
	label = (UILabel *)[cell viewWithTag:225];
	[label setBackgroundColor:[UIColor colorWithRed:[[player color] red] green:[[player color] green] blue:[[player color] blue] alpha:[[player color] alpha]]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	playSound(shortClickSound);

	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	selectedType = indexPath.row;
	
	for (UITableViewCell *cell in [tableView visibleCells])
		[cell setAccessoryType:UITableViewCellAccessoryNone];  
	
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];  
	
	Player *player = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] computerPlayers] objectAtIndex:indexPath.row];
	
	[descriptionField setText:[player description]];
	
	[self updatePreview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
