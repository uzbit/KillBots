//
//  HumanPlayerViewController.h
//  AiWars
//
//  Created by Jeremiah Gage on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "Player.h"

@class MultiPlayerViewController;
//@class AiWarsViewController;
//@class MainMenuViewController;

@interface HumanPlayerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
{
	IBOutlet UILabel *header;
	IBOutlet UITextField *playerName;
	IBOutlet UITableView *colorTable, *baseTable;
	IBOutlet UIImageView *previewImage;
	IBOutlet UIButton *cancelButton, *deleteButton, *doneButton, *quitButton, *startButton;
	
	int selectedColor, selectedBase;
	int playerIndex; //the index of the player if we are editing a player. set this to -1 if we are creating a new player
	
	MultiPlayerViewController *multiPlayerViewController;
//	AiWarsViewController *aiWarsViewController;
//	MainMenuViewController *mainMenuViewController;

}

@property ATOMICITY_RETAIN UILabel *header;
@property ATOMICITY_RETAIN UITextField *playerName;
@property ATOMICITY_RETAIN UITableView *colorTable, *baseTable;
@property ATOMICITY_RETAIN UIImageView *previewImage;
@property ATOMICITY_RETAIN UIButton *cancelButton, *deleteButton, *doneButton, *quitButton, *startButton;

@property ATOMICITY_NONE int selectedColor, selectedBase;
@property ATOMICITY_NONE int playerIndex;

@property ATOMICITY_ASSIGN MultiPlayerViewController *multiPlayerViewController;

- (IBAction)cancel:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)start:(id)sender;

- (void)updatePreview;
+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;

@end
