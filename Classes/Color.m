//
//  Color.m
//  AiWars
//
//  Created by Jeremiah Gage on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Color.h"


@implementation Color

@synthesize name;
@synthesize red, green, blue, alpha;

- (id)initWithName:(NSString *)n Red:(float)r Green:(float)g Blue:(float)b Alpha:(float)a
{
    if (self = [super init])
	{
		[self setName:n];
		[self setRed:r];
		[self setGreen:g];
		[self setBlue:b];
		[self setAlpha:a];
		
		return self;
	}
	return nil;
}

+ (id)getWithName:(NSString *)n Red:(float)r Green:(float)g Blue:(float)b Alpha:(float)a
{
	Color *color = [[Color alloc] initWithName:n Red:r Green:g Blue:b Alpha:a];
	return color;
}

- (UIColor *)getUIColor
{
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)dealloc
{
	[name release];
	[super dealloc];
}

@end
