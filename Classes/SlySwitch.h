//
//  SlySwitch.h
//  AiWars
//
//  Created by Ted McCormack on 9/23/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface SlySwitch : UIButton 
{
	UIImage *onImage, *offImage, *disabledImage;
	bool isOn;
}

@property ATOMICITY_RETAIN UIImage *onImage, *offImage, *disabledImage;
@property ATOMICITY_NONE bool isOn;

- (void)setup;
- (void)setOnImage:(NSString*)on OffImage:(NSString*)off DisabledImage:(NSString*)disabled;
- (void)toggle;
- (void)setOn:(bool)val animated:(bool)animated;

@end
