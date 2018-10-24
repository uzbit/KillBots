//
//  BotSelectorViewController.m
//  AiWars
//
//  Created by Jeremiah Gage on 3/16/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "BotSelectorViewController.h"
#import "Weapons.h"
#import "Rates.h"
#import "Player.h"
#import "AiWarsViewController.h"

@implementation BotSelectorViewController

@synthesize selectedBot;
@synthesize botTypes;
@synthesize jammerSwitchWasOn, shieldsSwitchWasOn;

@synthesize doneButton, previousBotButton, nextBotButton, shieldsInfoButton, jammerInfoButton, previousMovementButton, nextMovementButton;
@synthesize mesaVista;
@synthesize botNumberLabel, movementTypeLabel, fundsLabel;
//@synthesize movementTypeSlider;
@synthesize movementTypes;
@synthesize shieldsSwitch, jammerSwitch;

@synthesize aiWarsViewController;

- (void)setPlayer:(Player *)player fundsTo:(int)newVal
{
	if (newVal < [self jammerCostForBot:selectedBot orWithIndex:-1] && ![jammerSwitch isOn])
		[jammerSwitch setEnabled:NO];
	else
		[jammerSwitch setEnabled:(YES && [aiWarsViewController jammingOn])];
	
	if (newVal <= [self shieldsCostForBot:selectedBot orWithIndex:-1] && ![shieldsSwitch isOn])
		[shieldsSwitch setEnabled:NO];
	else
		[shieldsSwitch setEnabled:(YES &&[aiWarsViewController shieldsOn])];
	
	[player setFunds:newVal];
	[fundsLabel setText:[NSString stringWithFormat:@"%i", [player funds]]];
}

- (Bot *)makeBotWithName:(NSString *)n description:(NSString *)d texture:(GLuint)tx maxSpeed:(float)ms effectiveRange:(float)er defaultMovement:(MovementType)dm cost:(int)co tier:(int)ti attacks:(NSMutableArray *)at scaleMovement:(float)sm scaleEvade:(float)se scaleToward:(float)st
{
	Bot *bot = [[Bot alloc] init];
	[bot setName:n];
	[bot setDescription:d];
	[bot setTexture:tx];
	[bot setMaxSpeed:ms];
	[bot setCurrentMovement:dm];
	[bot setCost:co];
	[bot setTierLevel:ti];
	[bot setAttackTypes:at];
	[bot setEffectiveRange:er];
	[bot setShieldsTexture:textureShields];
	[bot setIcyTexture:textureIcy];
	[bot setScaleMovement:sm];
	[bot setScaleEvade:se];
	[bot setScaleToward:st];
	return bot;
}

- (void)registerBot:(Bot *)bot
{
	[botTypes addObject:bot];
	[bot setType:[botTypes indexOfObject:bot]];
}

- (void)selectBot:(Bot *)bot
{
	selectedBot = bot;
	
	for (int i = 0; i < [movementTypes count]; i++)
	{
		NSArray *movementType = [movementTypes objectAtIndex:i];
		if ([bot currentMovement] == [[movementType objectAtIndex:0] intValue])
		{
			movementTypeIndex = i;
			break;
		}
	}
	//set the bot type in the table
	int count = 0;
	for (int i = 0; i < [bot tierLevel]; i++)
		count += [mesaVista numberOfRowsInSection:i];
	
	[mesaVista reloadData];
	[mesaVista scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[bot type]-count inSection:[bot tierLevel]] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	
	//set the movement type slider value
	//oldMovementTypeValue = [bot currentMovement];
	[movementTypeLabel setText:[[movementTypes objectAtIndex:movementTypeIndex] objectAtIndex:1]];
	//[self movementTypeChanged:nil];

	//check if the jammer and shields switches should be set.
	id theJammer = nil;
	for (Attack *a in [selectedBot attackTypes])
		if ([a attackType] == ATTACK_TYPE_JAMMER)
			theJammer = a;
	
	[jammerSwitch setOn:(theJammer!=nil) animated:NO];
	jammerSwitchWasOn = (theJammer!=nil);
	if ([jammerSwitch isOn])
		[jammerSwitch setEnabled:(YES && [aiWarsViewController jammingOn])];
	
	[shieldsSwitch setOn:((([selectedBot shields]-99.0) < 0)?NO:YES) animated:NO];
	shieldsSwitchWasOn = ((([selectedBot shields]-99.0) < 0)?NO:YES);
	if ([shieldsSwitch isOn])
		[shieldsSwitch setEnabled:(YES && [aiWarsViewController shieldsOn])];
	
	//set the funds text
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[bot player]];
	[self setPlayer:player fundsTo:[player funds]];
	
	//set the bot number
	[botNumberLabel setText:[NSString stringWithFormat:@"Bot %i", [[player bots] indexOfObject:bot]+1]];
}

- (IBAction)done:(id)sender
{
	selectedBot = nil;
	[aiWarsViewController startUnSelectBot];
	[jammerSwitch setOn:NO animated:YES];
	[shieldsSwitch setOn:NO animated:YES];
}

- (void)jammerChanged:(id)sender
{
	playSound(shortClickSound);

	[jammerSwitch toggle];

	//int currentCost = [selectedBot cost] + ([shieldsSwitch isOn]?SHIELDS_COST:0) + ([jammerSwitch isOn]?JAMMER_COST:0);
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];

	if ([jammerSwitch isOn] && !jammerSwitchWasOn)
	{
		Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
		[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];
		[[selectedBot attackTypes] addObject:jammer];
		[jammer release];
		[self setPlayer:player fundsTo:[player funds] - [self jammerCostForBot:selectedBot orWithIndex:-1]];
		jammerSwitchWasOn = true;
	}
	else if (![jammerSwitch isOn] && jammerSwitchWasOn)
	{
		id theJammer = nil;
		for (Attack *a in [selectedBot attackTypes])
		{
			if ([a attackType] == ATTACK_TYPE_JAMMER)
				theJammer = a;
		}
		if (theJammer != nil)
		{
			[[selectedBot attackTypes] removeObject:theJammer];
			[self setPlayer:player fundsTo:[player funds] + [self jammerCostForBot:selectedBot orWithIndex:-1]];
		}
		jammerSwitchWasOn = false;
	}
	[mesaVista reloadData];

	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial] && [jammerSwitch isOn])
	{
		if ([aiWarsViewController tutorialState] == 3)
			[aiWarsViewController setTutorialState:4];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (void)shieldsChanged:(id)sender
{
	playSound(shortClickSound);

	[shieldsSwitch toggle];
	
	//int currentCost = [selectedBot cost] + ([shieldsSwitch isOn]?SHIELDS_COST:0) + ([jammerSwitch isOn]?JAMMER_COST:0);
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];
	
	if ([shieldsSwitch isOn] && !shieldsSwitchWasOn)
	{
		[selectedBot setShields:SHIELDS_VAL_FOR_BOT(selectedBot)];//100.0];
		[self setPlayer:player fundsTo:[player funds] - [self shieldsCostForBot:selectedBot orWithIndex:-1]];
		shieldsSwitchWasOn = true;
		//NSLog(@"shields = %d", SHIELDS_VAL_FOR_BOT(selectedBot));
	}
	else if (![shieldsSwitch isOn] && shieldsSwitchWasOn)
	{
		[selectedBot setShields:0.0];
		[self setPlayer:player fundsTo:[player funds] + [self shieldsCostForBot:selectedBot orWithIndex:-1]];
		shieldsSwitchWasOn = false;
	}
	
	[mesaVista reloadData];
	
	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial] && [shieldsSwitch isOn])
	{
		if ([aiWarsViewController tutorialState] == 3)
			[aiWarsViewController setTutorialState:4];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (IBAction)previousBot:(id)sender
{
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];
	int i = [[player bots] indexOfObject:selectedBot]-1;
	if (i == -1)
		i = [[player bots] count]-1;
	[aiWarsViewController moveSelectorToBot:[[player bots] objectAtIndex:i]];

	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial])
	{
		if ([aiWarsViewController tutorialState] == 5)
			[aiWarsViewController setTutorialState:6];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (IBAction)nextBot:(id)sender
{
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];
	int i = [[player bots] indexOfObject:selectedBot]+1;
	if (i == [[player bots] count])
		i = 0;
	[aiWarsViewController moveSelectorToBot:[[player bots] objectAtIndex:i]];

	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial])
	{
		if ([aiWarsViewController tutorialState] == 5)
			[aiWarsViewController setTutorialState:6];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (IBAction)previousMovement:(id)sender;
{
	playSound(shortClickSound);

	movementTypeIndex--;
	if (movementTypeIndex < 0)
		movementTypeIndex = [movementTypes count] - 1;
	
	NSArray *movementType = [movementTypes objectAtIndex:movementTypeIndex];
	
	[movementTypeLabel setText:[movementType objectAtIndex:1]];
	[selectedBot setCurrentMovement:[[movementType objectAtIndex:0] intValue]];

	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial])
	{
		if ([aiWarsViewController tutorialState] == 4)
			[aiWarsViewController setTutorialState:5];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (IBAction)nextMovement:(id)sender
{
	playSound(shortClickSound);

	movementTypeIndex++;
	if (movementTypeIndex >= [movementTypes count])
		movementTypeIndex = 0;
		
	NSArray *movementType = [movementTypes objectAtIndex:movementTypeIndex];
	
	[movementTypeLabel setText:[movementType objectAtIndex:1]];
	[selectedBot setCurrentMovement:[[movementType objectAtIndex:0] intValue]];	

	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial])
	{
		if ([aiWarsViewController tutorialState] == 4)
			[aiWarsViewController setTutorialState:5];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.view addSubview:shieldsSwitch];
	[self.view addSubview:jammerSwitch];
	
	//rotate the view
	self.view.frame = CGRectMake(-80, 80, 480, 320);
	self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
	
	//set the background
	[self.view setImage:[UIImage imageNamed:@"bot_selector.png"]];

	//set the movement type slider settings
	//[movementTypeSlider setMinimumValue: 1];
	/*[movementTypeSlider setMaximumValue: MOVEMENT_TYPE_NUM];
	[movementTypeSlider setThumbImage:[UIImage imageNamed:@"button1_green.png"] forState:UIControlStateNormal];
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"slide_light_grey.png"]
								stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"slide_light_grey.png"]
								 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	[movementTypeSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[movementTypeSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];*/
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		jammerSwitchWasOn = false;
		shieldsSwitchWasOn = false;
	
		//set the bot types
		botTypes = [[NSMutableArray alloc] initWithCapacity:1];
		Attack *attack;
		Bot *bot;
				
		//set movement types
		movementTypes = [[NSMutableArray alloc] initWithCapacity:MOVEMENT_TYPE_NUM];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND], @"Follow Closest Friend", nil]];
		//	[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_LOWEST_COST_FRIEND], @"Follow Lowest Cost Friend", nil]];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_FRIEND], @"Follow Highest Cost Friend", nil]];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY], @"Attack Closest Enemy", nil]];
		//	[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_LOWEST_COST_ENEMY], @"Attack Lowest Cost Enemy", nil]];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_HIGHEST_COST_ENEMY], @"Attack Highest Cost Enemy", nil]];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_LOWEST_LIFE_ENEMY], @"Attack Lowest Life Enemy", nil]];
		//	[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_FOLLOW_HIGHEST_LIFE_ENEMY], @"Attack Highest Life Enemy", nil]];
		[movementTypes addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:MOVEMENT_TYPE_RANDOM], @"Chaotic Movement", nil]];
		
		loadTexture(@"bot_identifier.png", &textureBotIdentifier);
		loadTexture(@"bot_identifier_bg.png", &textureBotIdentifierBg);
		loadTexture(@"life_bar.png", &textureLifeBar);
		loadTexture(@"life_bar_short.png", &textureLifeBarShort);
		loadTexture(@"shields.png", &textureShields);
		loadTexture(@"icy.png", &textureIcy);
		
		//setup base textures
		for (int i = 0; i < TEXTURE_BASE_UNLOCKED_NUM; i++)
			loadTexture([NSString stringWithFormat:@"base_bot%i.png", i+1], &textureBases[i]);
		
		//explosion particles
		loadTexture(@"explosion1.png", &textureExplosions[0]);
		loadTexture(@"explosion2.png", &textureExplosions[1]);
		loadTexture(@"explosion3.png", &textureExplosions[2]);
		loadTexture(@"explosion4.png", &textureExplosions[3]);
		loadTexture(@"explosion5.png", &textureExplosions[4]);
		
		loadTexture(@"jammer_weapon.png", &textureJammerWeapon);
		
		loadTexture(@"normal_bot.png", &textureNormalBot);
		loadTexture(@"normal_weapon.png", &textureNormalWeapon);
		loadTexture(@"double_bot.png", &textureNormalDoubleBot);
		loadTexture(@"quickie_bot.png", &textureQuickieBot);
		loadTexture(@"shottie_bot.png", &textureShottieBot);
		
		loadTexture(@"missile_bot.png", &textureMissileBot);
		loadTexture(@"missile_weapon.png", &textureMissileWeapon);
		loadTexture(@"flame.png", &textureFlame);
		
		loadTexture(@"seeker_bot.png", &textureSeekerBot);
		loadTexture(@"seeker_weapon.png", &textureSeekerWeapon);

		loadTexture(@"laser_bot.png", &textureLaserBot);
		loadTexture(@"laser_weapon.png", &textureLaserWeapon);
		
		loadTexture(@"rammer_bot.png", &textureRammerBot);
		
		loadTexture(@"missile_double_bot.png", &textureMissileDoubleBot);
		
		loadTexture(@"laser_double_bot.png", &textureLaserDoubleBot);
		
		loadTexture(@"seeker_double_bot.png", &textureSeekerDoubleBot);

		loadTexture(@"mass_driver_bot.png", &textureMassDriverBot);
		loadTexture(@"mass_driver_weapon.png", &textureMassDriverWeapon);
		
		loadTexture(@"mine_layer_bot.png", &textureMineLayerBot);
		loadTexture(@"mine_weapon.png", &textureMineLayerWeapon);
		
		loadTexture(@"suicide_bot.png", &textureSuicideBot);
		
		loadTexture(@"plasma_bot.png", &texturePlasmaBot);
		loadTexture(@"plasma_weapon.png", &texturePlasmaWeapon);
		
		loadTexture(@"icy_bot.png", &textureIcyBot);
		loadTexture(@"snowflake1.png", &textureSnowFlakes[0]);
		loadTexture(@"snowflake2.png", &textureSnowFlakes[1]);
		loadTexture(@"snowflake3.png", &textureSnowFlakes[2]);
		loadTexture(@"snowflake4.png", &textureSnowFlakes[3]);
		
		loadTexture(@"flamethrower_bot.png", &textureFlamethrowerBot);
		loadTexture(@"fire_particle1.png", &fireParticles[0]);
		
		loadTexture(@"plasma_double_bot.png", &texturePlasmaDoubleBot);
		
		loadTexture(@"fatman_weapon.png", &textureFatManWeapon);
		loadTexture(@"fatman_bot.png", &textureFatManBot);
		loadTexture(@"fatman_master_bot1.png", &textureFatManMasterBot1);
		loadTexture(@"fatman_master_bot2.png", &textureFatManMasterBot2);
		loadTexture(@"fatman_master_bot3.png", &textureFatManMasterBot3);
		loadTexture(@"fatman_master_bot4.png", &textureFatManMasterBot4);
		loadTexture(@"fatman_explosion.png", &textureFatManExplosion);

		loadTexture(@"laser_master_bot.png", &textureLaserMasterBot);
		loadTexture(@"seeker_master_bot.png", &textureSeekerMasterBot);
		loadTexture(@"plasma_master_bot.png", &texturePlasmaMasterBot);
//		loadTexture(@"plasma_double_bot.png", &texturePlasmaDoubleBot);

		//bots must be added to the array in order of the BotType enum!!!
		////////////////////////////////////////////////////////////
		//TIER 1 - BASIC DONE
		////////////////////////////////////////////////////////////		
		//BOT_TYPE_SINGLE_SHOOTER_TIER_1
		NSMutableArray *normalAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_NORMAL Weapon:[[NormalWeapon alloc] initWithTexture:textureNormalWeapon] Rate:NORMAL_ATTACK_RATE];
		[normalAttacks addObject:attack];
		bot = [self makeBotWithName:@"Single Shooter"
						description:[NSString stringWithFormat:@"The most basic of all weapons.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureNormalBot 
						   maxSpeed:NORMAL_BOT_MOVEMENT_RATE
					 effectiveRange:0.8
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY
							   cost:0 
							   tier:0
							attacks:normalAttacks
					  scaleMovement:3.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		
		//BOT_TYPE_DUAL_SHOOTER_TIER_1
		NSMutableArray *normalDoubleAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_NORMAL_DOUBLE Weapon:[[NormalWeapon alloc] initWithTexture:textureNormalWeapon] Rate:NORMAL_ATTACK_RATE];
		[normalDoubleAttacks addObject:attack];
		bot = [self makeBotWithName:@"Dual Shooter" 
						description:[NSString stringWithFormat:@"Twice the power of the \nSingle Shooter.\n\nFire Delay: %0.1f sec\nDamage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 2*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureNormalDoubleBot 
						   maxSpeed:NORMAL_BOT_MOVEMENT_RATE
					 effectiveRange:0.8
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:100
							   tier:0
							attacks:normalDoubleAttacks
					  scaleMovement:3.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_QUICKIE_TIER_1
		NSMutableArray *normalQuickieAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_NORMAL Weapon:[[NormalWeapon alloc] initWithTexture:textureNormalWeapon] Rate:NORMAL_ATTACK_RATE/3.0];
		[normalQuickieAttacks addObject:attack];
		bot = [self makeBotWithName:@"Quickie" 
						description:[NSString stringWithFormat:@"Rapid fire shots for quick takedowns.\n\nFire Delay: %0.1f sec\nDamage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureQuickieBot 
						   maxSpeed:NORMAL_BOT_MOVEMENT_RATE
					 effectiveRange:0.8
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:250
							   tier:0
							attacks:normalQuickieAttacks
					  scaleMovement:3.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_SHOTTIE_TIER_1
		NSMutableArray *normalShottieAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_SHOTTIE Weapon:[[NormalWeapon alloc] initWithTexture:textureNormalWeapon] Rate:1.5*NORMAL_ATTACK_RATE];
		[normalShottieAttacks addObject:attack];
		bot = [self makeBotWithName:@"Shottie" 
						description:[NSString stringWithFormat:@"Spreads shots over a range for multiple hits.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 6*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureShottieBot 
						   maxSpeed:NORMAL_BOT_MOVEMENT_RATE
					 effectiveRange:0.8
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:500
							   tier:0
							attacks:normalShottieAttacks
					  scaleMovement:3.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
   		//BOT_TYPE_MISSILE_TIER_1
		NSMutableArray *missileAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_MISSILE Weapon:[[MissileWeapon alloc] initWithTexture:textureMissileWeapon] Rate:MISSILE_ATTACK_RATE];
		[missileAttacks addObject:attack];
		bot = [self makeBotWithName:@"Missile" 
						description:[NSString stringWithFormat:@"A more damaging weapon with a longer range and splash damage.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureMissileBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE 
					 effectiveRange:1.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:1100	
							   tier:0
							attacks:missileAttacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.2];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_LASER_TIER_1
		NSMutableArray *laserAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_LASER Weapon:[[LaserWeapon alloc] initWithTexture:textureLaserWeapon] Rate:LASER_ATTACK_RATE];
		[laserAttacks addObject:attack];
		bot = [self makeBotWithName:@"Laser" 
						description:[NSString stringWithFormat:@"A fast moving weapon with\nlong range.\n\nFire Delay: %0.1f sec\nDamage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureLaserBot 
						   maxSpeed:LASER_BOT_MOVEMENT_RATE 
					 effectiveRange:3.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:1500
							   tier:0
							attacks:laserAttacks
					  scaleMovement:2.0
						 scaleEvade:1.5
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_RAMMER_TIER_1
		NSMutableArray *rammerAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_RAMMER Weapon:[[RammerWeapon alloc] initWithTexture:0] Rate:RAMMER_ATTACK_RATE];
		[rammerAttacks addObject:attack];
		bot = [self makeBotWithName:@"Reamer" 
						description:[NSString stringWithFormat:@"An aggressive bot that slams into other bots.\n\nFire Delay: N/A\nDamage: harder impact =\nmore damage"]
							texture:textureRammerBot 
						   maxSpeed:RAMMER_BOT_MOVEMENT_RATE 
					 effectiveRange:0.1
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:2000
							   tier:0
							attacks:rammerAttacks
					  scaleMovement:7.0
						 scaleEvade:0.0
						scaleToward:0.0];
		[bot setMass:0.6];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		
		////////////////////////////////////////////////////////////
		//TIER 2 DONE
		////////////////////////////////////////////////////////////		
		
		//BOT_TYPE_KAMIKAZE_TIER_2
		NSMutableArray *suicide2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_SUICIDE Weapon:[[SuicideWeapon alloc] initWithTexture:0] Rate:SUICIDE_ATTACK_RATE];
		[suicide2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Kamikaze" 
						description:[NSString stringWithFormat:@"A suicide bomber with a powerful explosive device.\n\nFire Delay: N/A\nMax Damage: %0.1f\nSplash Range: %0.1f", [[attack attackWeapon] damage], [[attack attackWeapon] splashRange]]
							texture:textureSuicideBot 
						   maxSpeed:SUICIDE_BOT_MOVEMENT_RATE*2.0 
					 effectiveRange:0.1
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:3000
							   tier:1
							attacks:suicide2Attacks
					  scaleMovement:7.0
						 scaleEvade:0.0
						scaleToward:0.0];
        [bot setMass:0.6];
        [self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_DUAL_MISSILE_TIER_2
		NSMutableArray *missileDouble2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_MISSILE_DOUBLE Weapon:[[MissileWeapon alloc] initWithTexture:textureMissileWeapon] Rate:MISSILE_ATTACK_RATE];
		[missileDouble2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Dual Missile" 
						description:[NSString stringWithFormat:@"Twice the power of the Missile.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 2*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureMissileDoubleBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:1.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:4000
							   tier:1
							attacks:missileDouble2Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_DUAL_LASER_TIER_2
		NSMutableArray *laserDouble2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_LASER_DOUBLE Weapon:[[LaserWeapon alloc] initWithTexture:textureLaserWeapon] Rate:LASER_ATTACK_RATE];
		[laserDouble2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Dual Laser" 
						description:[NSString stringWithFormat:@"Twice the power of the Laser.\n\nFire Delay: %0.1f sec\nDamage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 2*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureLaserDoubleBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:3.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:5000
							   tier:1
							attacks:laserDouble2Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_SEEKER_TIER_2
		NSMutableArray *seekingMissile2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_SEEKING_MISSILE Weapon:[[SeekingMissileWeapon alloc] initWithTexture:textureSeekerWeapon] Rate:(0.6*MISSILE_ATTACK_RATE)];
		[seekingMissile2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Seeker" 
						description:[NSString stringWithFormat:@"A missile that tracks its target nearly always hitting it, \nsplash damage included.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureSeekerBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:1.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:6000
							   tier:1
							attacks:seekingMissile2Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_MINE_LAYER_TIER_2
		NSMutableArray *mineLayer2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_MINE_LAYER Weapon:[[MineLayerWeapon alloc] initWithTexture:textureMineLayerWeapon] Rate:MINE_LAYER_ATTACK_RATE];
		[mineLayer2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Mine Layer" 
						description:[NSString stringWithFormat:@"Lays mines to trap enemies.\n\nLaying Rate: %0.1f/sec\nMax Damage: %0.1f/mine\nSplash Range: %0.1f", 1.0/[attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] splashRange]]
							texture:textureMineLayerBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:0.1
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:8000
							   tier:1
							attacks:mineLayer2Attacks
					  scaleMovement:5.0
						 scaleEvade:3.0
						scaleToward:0.5];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_MASS_DRIVER_TIER_2
		NSMutableArray *massDriver2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_MASS_DRIVER Weapon:[[MassDriverWeapon alloc] initWithTexture:textureMassDriverWeapon] Rate:MASS_DRIVER_ATTACK_RATE];
		[massDriver2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Mass Driver" 
						description:[NSString stringWithFormat:@"Launches unstoppable slugs that deal hard hitting damage.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/hit\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureMassDriverBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:2.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:10000
							   tier:1
							attacks:massDriver2Attacks
					  scaleMovement:1.5
						 scaleEvade:1.5
						scaleToward:0.5];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		
		////////////////////////////////////////////////////////////
		//TIER 3
		////////////////////////////////////////////////////////////		
		
		//BOT_TYPE_ICY_TIER_3
		NSMutableArray *icy3Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_ICY Weapon:[[IcyWeapon alloc] init] Rate:ICY_ATTACK_RATE];
		[icy3Attacks addObject:attack];
		bot = [self makeBotWithName:@"Icy" 
						description:[NSString stringWithFormat:@"Freezes enemies in place with minor damage.\nFire Delay: %0.1f sec\nContinual Damage: %0.1f\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureIcyBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:0.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:12000
							   tier:2
							attacks:icy3Attacks
					  scaleMovement:2.5
						 scaleEvade:0.5
						scaleToward:0.5];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_FLAMETHROWER_TIER_3
		NSMutableArray *flamethrower3Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_FLAMETHROWER Weapon:[[FlamethrowerWeapon alloc] init] Rate:FLAMETHROWER_ATTACK_RATE];
		[flamethrower3Attacks addObject:attack];
		bot = [self makeBotWithName:@"Flamethrower" 
						description:[NSString stringWithFormat:@"Heats the enemy with a spread of major damage.\n\nFire Delay: %0.1f sec\nContinual Damage: %0.1f\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureFlamethrowerBot 
						   maxSpeed:FLAMETHROWER_BOT_MOVEMENT_RATE 
					 effectiveRange:0.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:12000
							   tier:2
							attacks:flamethrower3Attacks
					  scaleMovement:2.5
						 scaleEvade:0.5
						scaleToward:0.5];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_DUAL_SEEKER_TIER_3
		NSMutableArray *seekingMissile3Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_SEEKING_MISSILE_DOUBLE Weapon:[[SeekingMissileWeapon alloc] initWithTexture:textureSeekerWeapon] Rate:MISSILE_ATTACK_RATE];
		//[[attack attackWeapon] setDamage:1.5*[[attack attackWeapon] damage]];
		[seekingMissile3Attacks addObject:attack];
		bot = [self makeBotWithName:@"Dual Seekers" 
						description:[NSString stringWithFormat:@"Twice the power of the Seeker.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 2*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureSeekerDoubleBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:1.5
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:15000
							   tier:2
							attacks:seekingMissile3Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_PLASMA_CANNON_TIER_3
		NSMutableArray *plasmaCannon3Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_PLASMA_CANNON Weapon:[[PlasmaCannonWeapon alloc] initWithTexture:texturePlasmaWeapon] Rate:(0.75*PLASMA_ATTACK_RATE)];
		[plasmaCannon3Attacks addObject:attack];
		bot = [self makeBotWithName:@"B.F.G." 
						description:[NSString stringWithFormat:@"A big...gun with splash damage.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:texturePlasmaBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:2.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:20000
							   tier:2
							attacks:plasmaCannon3Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		

		
		////////////////////////////////////////////////////////////
		//TIER 4
		////////////////////////////////////////////////////////////		
		
		//BOT_TYPE_LIGHTNING_TIER_4
		loadTexture(@"lightning_bot.png", &textureLightningBot);
		NSMutableArray *lightning4Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_LIGHTNING Weapon:[[LightningWeapon alloc] init] Rate:LIGHTNING_ATTACK_RATE];
		[lightning4Attacks addObject:attack];
		bot = [self makeBotWithName:@"Tesla" 
						description:[NSString stringWithFormat:@"Damage up to four enemies from afar with the power of electricity.\n\nFire Delay: %0.1f sec\nContinual Damage: %0.1f/bot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureLightningBot 
						   maxSpeed:LIGHTNING_BOT_MOVEMENT_RATE 
					 effectiveRange:1.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:40000
							   tier:3
							attacks:lightning4Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_DUAL_PLASMA_TIER_4
		NSMutableArray *plasmaCannon4Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_PLASMA_CANNON_DOUBLE Weapon:[[PlasmaCannonWeapon alloc] initWithTexture:texturePlasmaWeapon] Rate:PLASMA_ATTACK_RATE];
		[plasmaCannon4Attacks addObject:attack];
		bot = [self makeBotWithName:@"Dual B.F.G." 
						description:[NSString stringWithFormat:@"Twice the power of the B.F.G.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], 1.5*[[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:texturePlasmaDoubleBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:2.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:50000
							   tier:3
							attacks:plasmaCannon4Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_DEATH_TIER_4
		loadTexture(@"death_bot.png", &textureDeathBot);
		NSMutableArray *deathAttacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_DEATH_RAY Weapon:[[DeathRayWeapon alloc] init] Rate:DEATH_RAY_ATTACK_RATE];
		[deathAttacks addObject:attack];
		bot = [self makeBotWithName:@"Death Ray" 
						description:[NSString stringWithFormat:@"A very powerful long range weapon.\n\nFire Delay: %0.1f sec\nContinual Damage: %0.1f\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureDeathBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:1.3
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:100000
							   tier:3
							attacks:deathAttacks
					  scaleMovement:1.5
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_FATMAN_TIER_4
		NSMutableArray *fatMan4Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_FATMAN Weapon:[[FatManWeapon alloc] initWithTexture:textureFatManWeapon] Rate:FATMAN_ATTACK_RATE];
		[fatMan4Attacks addObject:attack];
		bot = [self makeBotWithName:@"Fat Man" 
						description:[NSString stringWithFormat:@"A nuclear weapon with massive splash damage.\n\nFire Delay: %0.1f sec\nMax Damage: %0.1f/shot\nRange: %0.1f", [attack attackRate], [[attack attackWeapon] damage], [[attack attackWeapon] range]]
							texture:textureFatManBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:2.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_ENEMY 
							   cost:200000
							   tier:3
							attacks:fatMan4Attacks
					  scaleMovement:2.0
						 scaleEvade:1.0
						scaleToward:0.1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		
		float spawnRate;
		
		//BOT_TYPE_BOSS_1_TIER_5
		spawnRate = 120.0/CYCLES_PER_SECOND;
		NSMutableArray *boss1Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_LASER Weapon:[[LaserWeapon alloc] initWithTexture:0] Rate:LASER_ATTACK_RATE];
		[boss1Attacks addObject:attack];
		bot = [self makeBotWithName:@"Laser Master" 
						description:[NSString stringWithFormat:@"Spawns Laser bots\n\nSpawn Delay: %0.1f sec", spawnRate ]
							texture:textureLaserMasterBot
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:5.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND
							   cost:1000000
							   tier:4
							attacks:boss1Attacks
					  scaleMovement:2.0
						 scaleEvade:1.5
						scaleToward:0.1];
		[bot setIsBoss:true];
		[bot setSpawnRate:spawnRate];
		[bot setSpawnTimer:spawnRate];
		[bot setSpawnType:BOT_TYPE_LASER_TIER_1];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_BOSS_2_TIER_5
		spawnRate = 120.0/CYCLES_PER_SECOND;
		NSMutableArray *boss2Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_SEEKING_MISSILE Weapon:[[SeekingMissileWeapon alloc] initWithTexture:textureSeekerWeapon] Rate:MISSILE_ATTACK_RATE];
		[boss2Attacks addObject:attack];
		bot = [self makeBotWithName:@"Seeker Master" 
						description:[NSString stringWithFormat:@"Spawns Seeker bots\n\nSpawn Delay: %0.1f sec", spawnRate]
							texture:textureSeekerMasterBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:5.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND
							   cost:2000000
							   tier:4
							attacks:boss2Attacks
					  scaleMovement:2.0
						 scaleEvade:1.5
						scaleToward:0.1];
		[bot setIsBoss:true];
		[bot setSpawnRate:spawnRate];
		[bot setSpawnTimer:spawnRate];
		[bot setSpawnType:BOT_TYPE_SEEKER_TIER_2];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		//BOT_TYPE_BOSS_3_TIER_5
		spawnRate = 120/CYCLES_PER_SECOND;
		NSMutableArray *boss3Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_PLASMA_CANNON Weapon:[[PlasmaCannonWeapon alloc] initWithTexture:texturePlasmaWeapon] Rate:PLASMA_ATTACK_RATE];
		[boss3Attacks addObject:attack];
		bot = [self makeBotWithName:@"B.F.G. Master" 
						description:[NSString stringWithFormat:@"Spawns B.F.G. bots\n\nSpawn Delay: %0.1f sec", spawnRate]
							texture:texturePlasmaMasterBot 
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:5.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND
							   cost:4000000
							   tier:4
							attacks:boss3Attacks
					  scaleMovement:2.0
						 scaleEvade:1.5
						scaleToward:0.1];
		[bot setIsBoss:true];
		[bot setSpawnRate:spawnRate];
		[bot setSpawnTimer:spawnRate];
		[bot setSpawnType:BOT_TYPE_PLASMA_TIER_3];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
		
		//BOT_TYPE_BOSS_4_TIER_5
		spawnRate = 130/CYCLES_PER_SECOND;
		NSMutableArray *boss4Attacks = [[NSMutableArray alloc] initWithCapacity:1];
		attack = [[Attack alloc] initWithType:ATTACK_TYPE_FATMAN Weapon:[[FatManWeapon alloc] initWithTexture:textureFatManWeapon] Rate:FATMAN_ATTACK_RATE];
		[boss4Attacks addObject:attack];
		bot = [self makeBotWithName:@"Fat Man Master" 
						description:[NSString stringWithFormat:@"Spawns Fat Man bots\n\nSpawn Delay: %0.1f sec", spawnRate]
							texture:textureFatManMasterBot1
						   maxSpeed:MISSILE_BOT_MOVEMENT_RATE*2.0
					 effectiveRange:5.0
					defaultMovement:MOVEMENT_TYPE_FOLLOW_CLOSEST_FRIEND
							   cost:10000000
							   tier:4
							attacks:boss4Attacks
					  scaleMovement:2.0
						 scaleEvade:1.5
						scaleToward:0.1];
		[bot setIsBoss:true];
		[bot setIsFatManBoss:true];
		[bot setSpawnRate:spawnRate];
		[bot setSpawnTimer:spawnRate];
		[bot setSpawnType:BOT_TYPE_FATMAN_TIER_4];
		[self registerBot:bot];
		[attack release];
		[bot release];
		
    }
    return self;
}


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
/*
- (void)loadView
{
}
*/
/*
- (IBAction)movementTypeChanged:(id)sender
{
	
	float movementTypeSliderValue = [movementTypeSlider value];

	for (int i = 0; i < [movementTypes count]; i++)
	{
 NSArray *movementType = [movementTypes objectAtIndex:i];
 int movementTypeValue = [[movementType objectAtIndex:0] intValue];
		
		if ((i == 0 && movementTypeSliderValue < 1.5)  || (i == MOVEMENT_TYPE_NUM - 1 && movementTypeSliderValue >= MOVEMENT_TYPE_NUM - .5) 
			|| (movementTypeSliderValue >= movementTypeValue - .5 && movementTypeSliderValue < movementTypeValue + .5))
		{
			if (movementTypeValue != oldMovementTypeValue)
				playSound(shortClickSound);

			[movementTypeSlider setValue:movementTypeValue];
			[movementTypeLabel setText:[movementType objectAtIndex:1]];
			[selectedBot setCurrentMovement:movementTypeValue];
			oldMovementTypeValue = movementTypeValue;
		}
	}
	
	[movementTypes release];
	
}*/

- (int)shieldsCostForBot:(Bot *)bot orWithIndex:(int)index
{
	if (bot != nil)
	{
		return (([bot cost] == 0)?100:SHIELDS_COST_RATIO*[bot cost]);
	}
	else if (index >= 0 && index < [botTypes count])
	{
		Bot *b = [botTypes objectAtIndex:index];
		return (([b cost] == 0)?100:SHIELDS_COST_RATIO*[b cost]);
	}
	return 0;
}

- (int)jammerCostForBot:(Bot *)bot orWithIndex:(int)index
{
	if (bot != nil)
	{
		return (([bot cost] < 1000)?500:JAMMER_COST_RATIO*[bot cost]);
	}
	else if (index >= 0 && index < [botTypes count])
	{
		Bot *b = [botTypes objectAtIndex:index];
		return (([b cost] < 1000)?500:JAMMER_COST_RATIO*[b cost]);
	}
	return 0;	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 34;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return @"Tier 1 Weapons";
		case 1:
			return @"Tier 2 Weapons";
		case 2:
			return @"Tier 3 Weapons";
		case 3:
			return @"Tier 4 Weapons";
		case 4:
			return @"Tier 5 Weapons";
	}
	return @"";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = 0;
    for (int i = 0; i < [botTypes count]; i++)
	{
		if ([[botTypes objectAtIndex:i] tierLevel] == section)
			count++;
	}
	return count;
}

- (void)info:(id)sender
{
	playSound(shortClickSound);

	UITableViewCell *cell = (UITableViewCell*)[sender superview];
	NSIndexPath *indexPath = [mesaVista indexPathForCell:cell];
	int count = 0;
	for (int i = 0; i < indexPath.section; i++)
		count += [self tableView:mesaVista numberOfRowsInSection:i];
	
	Bot *bot = [botTypes objectAtIndex:count+indexPath.row];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[bot name] message:[bot description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	UIButton *infoButton;
    UILabel *label;
	//UIImageView *icon;
	UITableViewCell *cell = [mesaVista dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
		bg.backgroundColor = [UIColor clearColor];
		cell.backgroundView = bg;
		[bg release];

		infoButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
		[infoButton setTag:221];
		[infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
		infoButton.frame = CGRectMake(2.0, 4.0, 25.0, 25.0);
//		[infoButton setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
//		infoButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
		[infoButton setEnabled:true];
		[cell addSubview:infoButton];
		[infoButton release];
		
    	label = [[UILabel alloc] initWithFrame:CGRectMake(31, -2, 270, 36)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1]];
		[label setFont:[UIFont boldSystemFontOfSize:17]];
		[label setTag:222];
		[cell addSubview:label];
		[label release];

		label = [[UILabel alloc] initWithFrame:CGRectMake(160, -1, 90, 36)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont boldSystemFontOfSize:16]];
		[label setTextColor:[UIColor colorWithRed:0 green:.6 blue:0 alpha:1]];
		[label setTextAlignment:UITextAlignmentRight];
		[label setTag:223];
		[cell addSubview:label];
		[label release];
	}
	
	if (!selectedBot)
		return cell;
	
	int count = 0;
	for (int i = 0; i < indexPath.section; i++)
		count += [self tableView:mesaVista numberOfRowsInSection:i];
	
	Bot *bot = [botTypes objectAtIndex:count+indexPath.row];
	
	if (count+indexPath.row == [selectedBot type])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];
	
	//set the info button tag
//	infoButton = (UIButton *)[cell viewWithTag:221];
//	[infoButton setText:@"test"];

	//bot type name
	label = (UILabel *)[cell viewWithTag:222];
	[label setText:[bot name]];
	
	int nextCost = [bot cost] + ([shieldsSwitch isOn]?[self shieldsCostForBot:bot orWithIndex:-1]:0) + ([jammerSwitch isOn]?[self jammerCostForBot:bot orWithIndex:-1]:0);
	int currentCost = [selectedBot cost] + ([shieldsSwitch isOn]?[self shieldsCostForBot:selectedBot orWithIndex:-1]:0) + ([jammerSwitch isOn]?[self jammerCostForBot:selectedBot orWithIndex:-1]:0);
	
	if ([player funds] + currentCost - nextCost < 0)
		[label setTextColor:[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1]];
	else
		[label setTextColor:[UIColor colorWithRed:.75 green:.75 blue:.75 alpha:1]];
	
	if (![shieldsSwitch isOn] && [player funds] - [self shieldsCostForBot:selectedBot orWithIndex:-1] < 0)
		[shieldsSwitch setEnabled:NO];
	else if (![shieldsSwitch isEnabled] && [player funds] - [self shieldsCostForBot:selectedBot orWithIndex:-1] >= 0)
		[shieldsSwitch setEnabled:(YES && [aiWarsViewController shieldsOn])];
	
		
	if (![jammerSwitch isOn] && [player funds] - [self jammerCostForBot:selectedBot orWithIndex:-1] < 0)
		[jammerSwitch setEnabled:NO];
	else if (![jammerSwitch isEnabled] && [player funds] - [self jammerCostForBot:selectedBot orWithIndex:-1] >= 0)
		[jammerSwitch setEnabled:(YES && [aiWarsViewController jammingOn])];
	
	//bot type cost
	label = (UILabel *)[cell viewWithTag:223];
	[label setText:[NSString stringWithFormat:@"$ %i", (int)nextCost]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Player *player = [[[aiWarsViewController theGame] players] objectAtIndex:[selectedBot player]];
	int count = 0;
	for (int i = 0; i < indexPath.section; i++)
		count += [mesaVista numberOfRowsInSection:i];
	Bot *bot = [[botTypes objectAtIndex:count+indexPath.row] copy];

	int nextCost = [bot cost] + ([shieldsSwitch isOn]?[self shieldsCostForBot:bot orWithIndex:-1]:0) + ([jammerSwitch isOn]?[self jammerCostForBot:bot orWithIndex:-1]:0);
	int currentCost = [selectedBot cost] + ([shieldsSwitch isOn]?[self shieldsCostForBot:selectedBot orWithIndex:-1]:0) + ([jammerSwitch isOn]?[self jammerCostForBot:selectedBot orWithIndex:-1]:0);
	
	if ([player funds] + currentCost - nextCost < 0)
		return;
	
	playSound(selectBotSound);

	[self setPlayer:player fundsTo:[player funds] + currentCost - nextCost];
	
	for (UITableViewCell *tc in [mesaVista visibleCells])
		[tc setAccessoryType:UITableViewCellAccessoryNone]; 
	
	UITableViewCell *tc = [mesaVista cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[bot type]-count inSection:[bot tierLevel]]]; 
	tc.accessoryType = UITableViewCellAccessoryCheckmark;
		
	//store a temp copy of the selectedBot then copy the new bot data over
	[aiWarsViewController copyBot:selectedBot fromBot:bot];
	
	/*Bot *tmpBot = [selectedBot copy];
	memcpy(selectedBot, bot, sizeof(Bot));
	[selectedBot setX:[tmpBot x]];
	[selectedBot setY:[tmpBot y]];
	[selectedBot setZ:[tmpBot z]];
	[selectedBot setColor:[tmpBot color]];
	[selectedBot setBaseTexture:[tmpBot baseTexture]];
	[selectedBot setPlayer:[tmpBot player]];
	[selectedBot setComputer:[tmpBot computer]];
	[selectedBot setController:[tmpBot controller]];*/
	if ([jammerSwitch isOn])
	{
		Attack *jammer = [[Attack alloc] initWithType:ATTACK_TYPE_JAMMER Weapon:[[JammerWeapon alloc] initWithTexture:textureJammerWeapon] Rate:JAMMER_ATTACK_RATE];
		[jammer setAttackTimer:slyRandom(0, [jammer attackRate])];;
		[[selectedBot attackTypes] addObject:jammer];
		[jammer release];
	}
	if ([shieldsSwitch isOn])
		[selectedBot setShields:SHIELDS_VAL_FOR_BOT(selectedBot)];//100.0];
	
	[bot release];
	
	//reload the table data because some bots might become unavaliable.
	[mesaVista reloadData];
	
	//show the tutorial
	if ([[aiWarsViewController theGame] round] == 1 && [aiWarsViewController doTutorial])
	{
		if ([aiWarsViewController tutorialState] == 2)
			[aiWarsViewController setTutorialState:3];
		[aiWarsViewController hideTutorial];
		[aiWarsViewController showTutorial:[aiWarsViewController tutorialState]];
	}	
}

- (IBAction)shieldsInfo:(id)sender
{
	playSound(shortClickSound);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shields" message:@"Shields will double the bot's life.\n\nCost: 100% of the base price." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction)jammerInfo:(id)sender
{
	playSound(shortClickSound);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Jamming" message:@"Jamming temporarily disables enemies near the bot.\n\nCost: $500 or 50% of the base price, whichever is greater." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
//gage is a major cutie pants and all the girls want his cute lil butt. woo!!

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

- (void)deleteTextures
{
}

- (void)dealloc
{
/*
	[shieldsSwitch release];
	[jammerSwitch release];
 */
	[movementTypes release];
	[botTypes release];
	[self deleteTextures];
    [super dealloc];
}


@end
