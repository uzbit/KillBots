//
//  SlySwitch.m
//  AiWars
//
//  Created by Ted McCormack on 9/23/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "SlySwitch.h"


@implementation SlySwitch
@synthesize onImage, offImage, disabledImage;
@synthesize isOn;

- (id)initWithCoder:(NSCoder *)inCoder
{
	if (self = [super initWithCoder:inCoder])
	{
		[self setup];
	}
	return self;
}

- (void)setup
{
	[self setOnImage:@"button_on.png" OffImage:@"button_off.png" DisabledImage:@"button_off_disabled.png"];
	[self setImage:offImage forState:UIControlStateNormal];
	[self setImage:disabledImage forState:UIControlStateDisabled];
	isOn = NO;
}

- (void)setOnImage:(NSString*)on OffImage:(NSString*)off DisabledImage:(NSString*)disabled
{
	onImage = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:on] CGImage]];
	offImage = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:off] CGImage]];
	disabledImage = [[UIImage alloc] initWithCGImage:[[UIImage imageNamed:disabled] CGImage]];
}

- (void)toggle
{
	[self setOn:!isOn animated:false];
}

- (void)setOn:(bool)val animated:(bool)animated
{
	isOn = val;
	[self setImage:(isOn?onImage:offImage) forState:UIControlStateNormal];
}

- (void)dealloc
{
	[onImage release];
	[offImage release];
	[disabledImage release];
	[super dealloc];
}


@end
