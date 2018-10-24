//
//  Color.h
//  AiWars
//
//  Created by Jeremiah Gage on 4/20/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

#define COLOR_NUM			18
#define COLOR_GREY			[Color getWithName:@"Grey" Red:1.0 Green:1.0 Blue:1.0 Alpha:1.0]
#define COLOR_DARK_GREY		[Color getWithName:@"Dark Grey" Red:0.5 Green:0.5 Blue:0.5 Alpha:1.0]
#define COLOR_BLACK			[Color getWithName:@"Black" Red:0.1 Green:0.1 Blue:0.1 Alpha:1.0]
#define COLOR_RED			[Color getWithName:@"Red" Red:1.0 Green:0.0 Blue:0.0 Alpha:1.0]
#define COLOR_MAROON		[Color getWithName:@"Maroon" Red:0.6 Green:0.0 Blue:0.0 Alpha:1.0]
#define COLOR_ORANGE		[Color getWithName:@"Orange" Red:1.0 Green:0.5 Blue:0.0 Alpha:1.0]
#define COLOR_YELLOW		[Color getWithName:@"Yellow" Red:1.0 Green:1.0 Blue:0.0 Alpha:1.0]
#define COLOR_GOLD			[Color getWithName:@"Gold" Red:0.83 Green:0.68 Blue:0.21 Alpha:1.0]
#define COLOR_LIGHT_GREEN	[Color getWithName:@"Light Green" Red:0.6 Green:1.0 Blue:0.6 Alpha:1.0]
#define COLOR_GREEN			[Color getWithName:@"Green" Red:0.0 Green:0.9 Blue:0.0 Alpha:1.0]
#define COLOR_DARK_GREEN	[Color getWithName:@"Dark Green" Red:0.0 Green:0.6 Blue:0.0 Alpha:1.0]
#define COLOR_TEAL			[Color getWithName:@"Teal" Red:0.0 Green:0.5 Blue:0.5 Alpha:1.0]
#define COLOR_LIGHT_BLUE	[Color getWithName:@"Light Blue" Red:0.08 Green:0.38 Blue:0.74 Alpha:1.0]
#define COLOR_BLUE			[Color getWithName:@"Blue" Red:0.0 Green:0.0 Blue:1.0 Alpha:1.0]
#define COLOR_DARK_BLUE		[Color getWithName:@"Dark Blue" Red:0.0 Green:0.0 Blue:0.7 Alpha:1.0]
#define COLOR_PURPLE		[Color getWithName:@"Purple" Red:0.6 Green:0.0 Blue:0.6 Alpha:1.0]
#define COLOR_PINK			[Color getWithName:@"Pink" Red:1.0 Green:0.41 Blue:0.7 Alpha:1.0]
#define COLOR_BROWN			[Color getWithName:@"Brown" Red:0.7 Green:0.4 Blue:0.0 Alpha:1.0]

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

@interface Color : NSObject
{
	NSString *name;
	float red, green, blue, alpha;
}

@property ATOMICITY_ASSIGN NSString *name;
@property ATOMICITY_NONE float red, green, blue, alpha;

- (id)initWithName:(NSString *)n Red:(float)r Green:(float)g Blue:(float)b Alpha:(float)a;
+ (id)getWithName:(NSString *)n Red:(float)r Green:(float)g Blue:(float)b Alpha:(float)a;
- (UIColor *)getUIColor;
		
@end
