//
//  HumanPlayerViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "HumanPlayerViewController.h"
#import "MultiPlayerViewController.h"
#import "AiWarsViewController.h"
#import "MainMenuViewController.h"

@implementation HumanPlayerViewController

@synthesize header;
@synthesize playerName;
@synthesize colorTable, baseTable;
@synthesize previewImage;
@synthesize cancelButton, deleteButton, doneButton, quitButton, startButton;

@synthesize selectedColor, selectedBase;
@synthesize playerIndex;

@synthesize multiPlayerViewController;
//@synthesize aiWarsViewController;
//@synthesize mainMenuViewController;

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] removeObjectAtIndex:playerIndex];
		[[multiPlayerViewController tableView] reloadData];
		[multiPlayerViewController hideHumanPlayer];
		[multiPlayerViewController updateBots];
	}
}

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor
{
#if !SIMULATION
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(-baseImage.size.width/2, -baseImage.size.height/2, baseImage.size.width, baseImage.size.height);
    
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, area.size.width/2, -area.size.height/2);
	
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
    CGContextScaleCTM(ctx, .98, .98);
	CGContextClipToMask(ctx, area, baseImage.CGImage);

    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    [theColor set];
    CGContextFillRect(ctx, area);
#endif	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (IBAction)cancel:(id)sender
{
	playSound(clickSound);

	[multiPlayerViewController hideHumanPlayer];
}

- (IBAction)delete:(id)sender
{
	playSound(clickSound);

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[alert show];
	[alert release];	
}

- (IBAction)done:(id)sender
{
	playSound(clickSound);

	if ([[playerName text] length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a player name." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		if (playerIndex >= 0)
		{
			Player *player = [[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] objectAtIndex:playerIndex];
			[player setName:[playerName text]];
			[player setColor:[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] objectAtIndex:selectedColor]];
			[player setBaseTexture:selectedBase];
		}
		else
		{
			Player *player = [[Player alloc] init];
			[player setName:[playerName text]];
			[player setColor:[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] objectAtIndex:selectedColor]];
			[player setBaseTexture:selectedBase];
			[[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] theGame] players] addObject:player];
			[player release];
		}

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

		[multiPlayerViewController hideHumanPlayer];
	}
}

- (IBAction)start:(id)sender
{
	playSound(clickSound);

	if ([[playerName text] length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a player name." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		Player *player = [[[multiPlayerViewController mainMenuViewController] aiWarsViewController] singlePlayerHuman];
		[player setName:[playerName text]];
		[player setColor:[[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] objectAtIndex:selectedColor]];
		[player setBaseTexture:selectedBase];
		[[multiPlayerViewController mainMenuViewController] startSinglePlayer];
	}			
}

- (IBAction)quit:(id)sender
{
	playSound(clickSound);

	[[multiPlayerViewController mainMenuViewController] hideHumanPlayer];
	[[multiPlayerViewController mainMenuViewController] showSinglePlayerMenu];
}

- (void)updatePreview
{
	Color *color = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] objectAtIndex:selectedColor];
	[previewImage setImage:[HumanPlayerViewController colorizeImage:[UIImage imageNamed:[NSString stringWithFormat:@"base_bot%i_noshadow.png",(selectedBase+1)]] color:[UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:1]]];
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
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
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
	if (tableView == colorTable)
		return 30;
	else if (tableView == baseTable)
		return 48;
	return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == colorTable)
		return [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] count];
	else if (tableView == baseTable)
		return (liteVersion?TEXTURE_BASE_NUM:TEXTURE_BASE_UNLOCKED_NUM-1);
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		if (tableView == baseTable)
		{
			//background color
			UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
			bg.backgroundColor = [UIColor clearColor];
			cell.backgroundView = bg;
			[bg release];

			//image
			UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
			[image setTag:12];
			[cell addSubview:image];
			[image release];
		}
	}
	
	if (tableView == colorTable)
	{
		Color *color = [[[[multiPlayerViewController mainMenuViewController] aiWarsViewController] colors] objectAtIndex:indexPath.row];
		
		//background color
		UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
		bg.backgroundColor = [UIColor colorWithRed:[color red] green:[color green] blue:[color blue] alpha:[color alpha]];
		cell.backgroundView = bg;
		[bg release];

		//checkmark
		if (indexPath.row == selectedColor)
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];  
		else
			[cell setAccessoryType:UITableViewCellAccessoryNone];  
	}
	else if (tableView == baseTable)
	{
		[[cell viewWithTag:12] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"base_bot%i.png",(indexPath.row+1)]]];

		//checkmark
		if (indexPath.row == selectedBase)
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];  
		else
			[cell setAccessoryType:UITableViewCellAccessoryNone];  
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	playSound(shortClickSound);
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	if (tableView == colorTable)
	{
		selectedColor = indexPath.row;
	}
	else if (tableView == baseTable)
	{
		selectedBase = indexPath.row;
	}

	for (UITableViewCell *cell in [tableView visibleCells])
		[cell setAccessoryType:UITableViewCellAccessoryNone];  

	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];  
	
	[self updatePreview];
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
    [super dealloc];
}


@end

