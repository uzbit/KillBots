//
//  ComputerPlayerViewController.h
//  AiWars
//
//  Created by Ted McCormack on 6/10/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class MultiPlayerViewController;
@class AiWarsViewController;
@class MainMenuViewController;

@interface ComputerPlayerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
{
	IBOutlet UILabel *header;
	IBOutlet UITableView *botTable;
	IBOutlet UIImageView *previewImage;
	IBOutlet UIButton *cancelButton, *deleteButton, *doneButton;
	IBOutlet UITextView *descriptionField;
	
	int selectedType;
	int playerIndex; //the index of the player if we are editing a player. set this to -1 if we are creating a new player
	
	MultiPlayerViewController *multiPlayerViewController;	
}

@property ATOMICITY_RETAIN UILabel *header;
@property ATOMICITY_RETAIN UITableView *botTable;
@property ATOMICITY_RETAIN UIImageView *previewImage;
@property ATOMICITY_RETAIN UIButton *cancelButton, *deleteButton, *doneButton;
@property ATOMICITY_RETAIN UITextView *descriptionField;

@property ATOMICITY_NONE int selectedType;
@property ATOMICITY_NONE int playerIndex;


@property ATOMICITY_ASSIGN MultiPlayerViewController *multiPlayerViewController;

- (IBAction)cancel:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)done:(id)sender;

- (void)updatePreview;

@end
