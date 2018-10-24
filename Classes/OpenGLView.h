//
//  OpenGLView.h
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLUtilities.h"
#import "Defines.h"

@class OpenGLViewController;

GLuint textureBackground, textureBuffer1;

@interface OpenGLView : UIView
{
	bool needsBotIdentifier, drawBotIdentifier;

	NSMutableArray *objects;
	    
	GLint backingWidth;
    GLint backingHeight;
	
	EAGLContext *context;	

    GLuint viewRenderbuffer, viewFramebuffer;
    GLuint depthRenderbuffer;
	
	float x, y, z;

	OpenGLViewController *controller;
}

@property ATOMICITY_NONE bool needsBotIdentifier, drawBotIdentifier;
@property ATOMICITY_RETAIN NSMutableArray *objects;
@property ATOMICITY_RETAIN EAGLContext *context;
@property ATOMICITY_NONE float x, y, z;
@property ATOMICITY_RETAIN OpenGLViewController *controller;

- (void)fixBounds;

- (bool)createFramebuffer;
- (void)destroyFramebuffer;

- (void)setObjects:(NSMutableArray *)object_array;
- (void)draw;
- (void)clear;

@end
