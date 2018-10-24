//
//  UnlockedViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 9/10/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "UnlockedViewController.h"
#import "MainMenuViewController.h"

@implementation UnlockedViewController

@synthesize backButton;
@synthesize settingsTable;

@synthesize mainMenuViewController;

- (IBAction)back:(id)sender
{
	playSound(clickSound);
	[mainMenuViewController showMainMenu];
}

- (void) saveSettings
{
	[[NSUserDefaults standardUserDefaults] setBool:[(SlySwitch *)[self.view viewWithTag:1] isOn] forKey:@"shieldsOn"];
	[[NSUserDefaults standardUserDefaults] setBool:[(SlySwitch *)[self.view viewWithTag:2] isOn] forKey:@"jammingOn"];
	[[NSUserDefaults standardUserDefaults] setBool:[(SlySwitch *)[self.view viewWithTag:4] isOn] forKey:@"showComputersOn"];

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) updateMultiplayerStart
{
	int value = [self getMultiplayerStartValue:((UISlider *)[self.view viewWithTag:5]).value];

	UILabel *label = (UILabel *)[self.view viewWithTag:51];
	[label setText:[NSString stringWithFormat:@"$ %i", value]];

	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"multiplayerStart"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (int) getMultiplayerStartValue:(float)sliderValue
{
	int roundedSliderValue = roundf(sliderValue);
	int value;
	switch (roundedSliderValue)
	{
		case 1:
			value = 1000;
			break;
		case 2:
			value = 2000;
			break;
		case 3:
			value = 5000;
			break;
		case 4:
			value = 10000;
			break;
		case 5:
			value = 50000;
			break;
		case 6:
			value = 100000;
			break;
		case 7:
			value = 500000;
			break;
		case 8:
			value = 1000000;
			break;
	}
	return value;
}

- (float) getMultiplayerStartSliderValue
{
	float value;
	switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"multiplayerStart"])
	{
		case 1000:
			value = 1;
			break;
		case 2000:
			value = 2;
			break;
		case 5000:
			value = 3;
			break;
		case 10000:
			value = 4;
			break;
		case 50000:
			value = 5;
			break;
		case 100000:
			value = 6;
			break;
		case 500000:
			value = 7;
			break;
		case 1000000:
			value = 8;
			break;
		default:
			value = 1;
			break;
	}
	return value;
}

- (void)disableShieldsChanged:(id)sender
{
	[(SlySwitch *)[self.view viewWithTag:1] toggle];
	[self saveSettings];
}

- (void)disableJammingChanged:(id)sender
{
	[(SlySwitch *)[self.view viewWithTag:2] toggle];
	[self saveSettings];
}

- (void)extraBasesChanged:(id)sender
{
	[(SlySwitch *)[self.view viewWithTag:3] toggle];
	[self saveSettings];
}

- (void)showComputersChanged:(id)sender
{
	[(SlySwitch *)[self.view viewWithTag:4] toggle];
	[self saveSettings];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel *label;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	bool addUIElement = false;
	if (cell == nil)
	{
		addUIElement = true;

        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
    	label = [[UILabel alloc] initWithFrame:CGRectMake(16, 1, 300, 34)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]];
		[label setFont:[UIFont boldSystemFontOfSize:17]];
		[label setTag:222];
		[cell addSubview:label];
		[label release];
	}

	label = (UILabel *)[cell viewWithTag:222];

	switch(indexPath.row)
	{
		case 0:;
			[label setText:@"Shields (multiplayer)"];
			if (addUIElement)
			{
				SlySwitch *aSwitch = [[SlySwitch alloc] initWithFrame:CGRectMake(370, 6, 60, 30)];
				[aSwitch setup];
				[aSwitch setTag:1];
				[aSwitch addTarget:self action:@selector(disableShieldsChanged:) forControlEvents:UIControlEventTouchUpInside];
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shieldsOn"])
					[aSwitch setOn:YES animated:NO];
				else
					[aSwitch setOn:NO animated:NO];
				[cell addSubview:aSwitch];
				[aSwitch release];
			}
			break;
		case 1:;
			[label setText:@"Jamming (multiplayer)"];
			if (addUIElement)
			{
				SlySwitch *aSwitch = [[SlySwitch alloc] initWithFrame:CGRectMake(370, 6, 60, 30)];
				[aSwitch setup];
				[aSwitch setTag:2];
				[aSwitch addTarget:self action:@selector(disableJammingChanged:) forControlEvents:UIControlEventTouchUpInside];
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jammingOn"])
					[aSwitch setOn:YES animated:NO];
				else
					[aSwitch setOn:NO animated:NO];
				[cell addSubview:aSwitch];
				[aSwitch release];
			}
			break;
		case 2:;
			[label setText:@"Show Computer Weapons"];
			if (addUIElement)
			{
				SlySwitch *aSwitch = [[SlySwitch alloc] initWithFrame:CGRectMake(370, 6, 60, 30)];
				[aSwitch setup];
				[aSwitch setTag:4];
				[aSwitch addTarget:self action:@selector(showComputersChanged:) forControlEvents:UIControlEventTouchUpInside];
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showComputersOn"])
					[aSwitch setOn:YES animated:NO];
				else
					[aSwitch setOn:NO animated:NO];
				[cell addSubview:aSwitch];
				[aSwitch release];
			}
			break;			
		case 3:;
			[label setText:@"Initial Resources (multiplayer)"];

			//resources label
			label = [[UILabel alloc] initWithFrame:CGRectMake(270, 1, 120, 34)];
			[label setBackgroundColor:[UIColor clearColor]];
			[label setTextColor:[UIColor colorWithRed:0 green:.6 blue:0 alpha:1]];
			[label setFont:[UIFont boldSystemFontOfSize:17]];
			[label setTag:51];
			[cell addSubview:label];

			//resources slider
			UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(370, 0, 100, 38)];
			[aSlider setTag:5];
			[aSlider setMinimumValue:1];
			[aSlider setMaximumValue:8];
			[aSlider addTarget:nil action:@selector(updateMultiplayerStart) forControlEvents:UIControlEventValueChanged];
			[aSlider setValue:[self getMultiplayerStartSliderValue]];
			[cell addSubview:aSlider];

			int value = [self getMultiplayerStartValue:aSlider.value];
			[label setText:[NSString stringWithFormat:@"$ %i", value]];
			
			[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"multiplayerStart"];
			[[NSUserDefaults standardUserDefaults] synchronize];

			[label release];
			[aSlider release];
			break;
	}
/*
	switch(indexPath.section)
	{
			//section 0: settings
		case 0:
		{	
			switch(indexPath.row)
			{
				case 0:
					;
					cell = [tableView cellForRowAtIndexPath:indexPath];
					if (cell == nil)
					{
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
						cell.text = @"Sounds:";
						[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
						UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(190, (cell.bounds.size.height - 30)/2, 100, cell.bounds.size.height-10)];
						[aSwitch setTag:1];
						[aSwitch addTarget:nil action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
						if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundsSwitch"])
							aSwitch.on = YES;
						else
							aSwitch.on = NO;
						[cell addSubview:aSwitch];
						[aSwitch release];
					}
					break;
				case 1:
					;
					cell = [tableView cellForRowAtIndexPath:indexPath];
					if (cell == nil)
					{
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
						cell.text = @"Egg Dragging:";
						[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
						UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(190, (cell.bounds.size.height - 30)/2, 100, cell.bounds.size.height-10)];
						[aSwitch setTag:2];
						[aSwitch addTarget:nil action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
						if ([[NSUserDefaults standardUserDefaults] boolForKey:@"eggDraggingSwitch"])
							aSwitch.on = YES;
						else
							aSwitch.on = NO;
						[cell addSubview:aSwitch];
						[aSwitch release];
					}
					break;
				case 2:
					;
					cell = [tableView cellForRowAtIndexPath:indexPath];
					if (cell == nil)
					{
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
						cell.text = @"Eggs Speed:";
						[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
						UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(190, (cell.bounds.size.height - 30)/2, 100, cell.bounds.size.height-10)];
						[aSlider setTag:3];
						[aSlider setMinimumValue:0];
						[aSlider setMaximumValue:10];
						
						[aSlider addTarget:nil action:@selector(saveSettings) forControlEvents:UIControlEventValueChanged];
						[aSlider setValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"eggSpeedSlider"]];
						[cell addSubview:aSlider];
						[aSlider release];
					}
					break;	
			}
		}
		default:
			break;
	}
 */
	
	return cell;
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
