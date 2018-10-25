//
//  BotSelectorViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 3/16/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bot.h"
#import "Types.h"
#import "Defines.h"
#import "SlySwitch.h"

#define TEXTURE_BASE_NUM				3
#define TEXTURE_BASE_UNLOCKED_NUM		11
#define TEXTURE_BASE_COMPUTER			3
#define SHIELDS_COST_RATIO				1
#define JAMMER_COST_RATIO				0.5

//Bot textures
GLuint textureBases[TEXTURE_BASE_UNLOCKED_NUM];
GLuint textureLifeBar, textureLifeBarShort;

GLuint textureNormalBot, textureNormalDoubleBot, textureQuickieBot, textureShottieBot, textureLaserBot, textureMissileBot, textureSeekerBot, textureSuicideBot;
GLuint textureRammerBot, textureFlamethrowerBot, textureLightningBot, textureMissileDoubleBot;
GLuint textureLaserDoubleBot, textureSeekerDoubleBot, texturePlasmaBot, texturePlasmaDoubleBot, textureDeathBot, textureFatManBot;
GLuint textureMassDriverBot, textureMineLayerBot, textureIcyBot;
GLuint textureLaserMasterBot, textureSeekerMasterBot, texturePlasmaMasterBot, textureFatManMasterBot1, textureFatManMasterBot2, textureFatManMasterBot3, textureFatManMasterBot4;

//Weapon textures
GLuint textureNormalWeapon, textureLaserWeapon, textureMissileWeapon, textureSeekerWeapon, textureJammerWeapon;
GLuint texturePlasmaWeapon, textureMassDriverWeapon, textureMineLayerWeapon, textureFatManWeapon;

//bot identifier
GLuint textureBotIdentifier, textureBotIdentifierBg;

//Shield texture
GLuint textureShields;

//Icy texture
GLuint textureIcy;

@interface BotSelectorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	Bot *selectedBot;
	NSMutableArray *botTypes, *movementTypes;
	bool jammerSwitchWasOn, shieldsSwitchWasOn;
	
	IBOutlet UIButton *doneButton, *previousBotButton, *nextBotButton, *shieldsInfoButton, *jammerInfoButton, *previousMovementButton, *nextMovementButton;
	IBOutlet UITableView *mesaVista;
	IBOutlet UILabel *botNumberLabel, *movementTypeLabel, *fundsLabel;
	//IBOutlet UISlider *movementTypeSlider;
	//IBOutlet UISwitch *shieldsSwitch, *jammerSwitch;
	IBOutlet SlySwitch *shieldsSwitch, *jammerSwitch;
	
	AiWarsViewController *aiWarsViewController;
	
	int movementTypeIndex;
}

@property ATOMICITY_RETAIN NSMutableArray *botTypes, *movementTypes;
@property ATOMICITY_NONE bool jammerSwitchWasOn, shieldsSwitchWasOn;

@property ATOMICITY_RETAIN Bot *selectedBot;
@property ATOMICITY_RETAIN IBOutlet UIButton *doneButton, *previousBotButton, *nextBotButton, *shieldsInfoButton, *jammerInfoButton, *previousMovementButton, *nextMovementButton;
@property ATOMICITY_RETAIN IBOutlet UITableView *mesaVista;
@property ATOMICITY_RETAIN IBOutlet UILabel *botNumberLabel, *movementTypeLabel, *fundsLabel;
//@property ATOMICITY_RETAIN IBOutlet UISlider *movementTypeSlider;
@property ATOMICITY_RETAIN IBOutlet SlySwitch *shieldsSwitch, *jammerSwitch;

@property ATOMICITY_ASSIGN AiWarsViewController *aiWarsViewController;

- (void)deleteTextures;
- (void)registerBot:(Bot *)bot;
- (void)selectBot:(Bot *)bot;
- (IBAction)done:(id)sender;
- (void)jammerChanged:(id)sender;
- (void)shieldsChanged:(id)sender;
- (int)calculateCostForBot:(Bot *)bot;
- (IBAction)previousBot:(id)sender;
- (IBAction)nextBot:(id)sender;
- (IBAction)previousMovement:(id)sender;
- (IBAction)nextMovement:(id)sender;
- (IBAction)shieldsInfo:(id)sender;
- (IBAction)jammerInfo:(id)sender;
- (void)info:(id)sender;

- (int)shieldsCostForBot:(Bot *)bot orWithIndex:(int)index;
- (int)jammerCostForBot:(Bot *)bot orWithIndex:(int)index;

//- (IBAction)movementTypeChanged:(id)sender;

@end
