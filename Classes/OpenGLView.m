//
//  OpenGLView.m
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLView.h"
#import "OpenGLObject.h"

@implementation OpenGLView

@synthesize needsBotIdentifier, drawBotIdentifier;

@synthesize objects;
@synthesize context;
@synthesize x, y, z;
@synthesize controller;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		needsBotIdentifier = drawBotIdentifier = false;
		
		//set the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
		//[self setAlpha:.5];
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
		//set the context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];        
        if (!context || ![EAGLContext setCurrentContext:context])
		{
            [self release];
            return nil;
        }
		[EAGLContext setCurrentContext:context];
		
		perspective(90, (float)APP_WIDTH/APP_HEIGHT, .01, 10);
		
		//rotate the screen for landscape mode
		glMatrixMode(GL_PROJECTION);
		glRotatef(90, 0, 0, -1);
		glMatrixMode(GL_MODELVIEW);
		
		x = y = z = 0;

		//set OpenGL parameters
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
//		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.01);
		
//		glEnable(GL_DEPTH_TEST);
		
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
		//glEnable(GL_LINE_SMOOTH);
	}
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[controller touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[controller touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[controller touchesMoved:touches withEvent:event];
}

- (bool)createFramebuffer
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);    
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer
{
    if (viewFramebuffer)
	{
		glDeleteFramebuffersOES(1, &viewFramebuffer);
		viewFramebuffer = 0;
	}
	
	if (viewRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &viewRenderbuffer);
		viewRenderbuffer = 0;
	}

    if(depthRenderbuffer)
	{
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)setObjects:(NSMutableArray *)object_array
{
	objects = object_array;
}

- (void)drawRect:(CGRect)rect
{
}

- (void)fixBounds
{
	bool outOfBounds;
	do
	{
		outOfBounds = false;
		glPushMatrix();
		glLoadIdentity();
		glTranslatef(-x, -y, -z);
		
		glTranslatef(.12, -.72, -1.801);
		glRotatef(90, 0, 0, -1);
		glScalef(3.85, 3.85, 1);
		
		GLfloat coord[3] = {.125, .5, 0};
		GLfloat win_coord[3];
		slyGluProject(coord, win_coord);
		//	NSLog(@"x: %f, y: %f", win_coord[0], win_coord[1]);
		GLfloat coord2[3] = {-.5, -.5, 0};
		GLfloat win_coord2[3];
		slyGluProject(coord2, win_coord2);

		glPopMatrix();

		if (win_coord[0] > 0)
		{
			y+=.01;
//			outOfBounds = true;
		}
		else if (win_coord2[0] < 320)
		{
			y-=.01;
//			outOfBounds = true;
		}

		if (win_coord[1] > 0)
		{
			x+=.01;
//			outOfBounds = true;
		}
 		else if (win_coord2[1] < 480)
		{
			x-=.01;
//			outOfBounds = true;
		}

	} while (outOfBounds);
}

- (void)draw
{	
	/*
	if (needsBotIdentifier)
	{
		drawBotIdentifier = true;
		needsBotIdentifier = false;
	}
	 */
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glViewport(0, 0, backingWidth, backingHeight);
    
//	glClearColor(.2, .4, .6, 1);
	glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	perspective(90, (float)APP_WIDTH/APP_HEIGHT, .01, 10);
	
	//rotate the screen for landscape mode
	glMatrixMode(GL_PROJECTION);
	glRotatef(90, 0, 0, -1);
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
	glTranslatef(-x, -y, -z);
	

	//draw background
	const GLfloat spriteVertices[] = {
		-.5,  -.5,
		-.5, .5,
		.5,  -.5,
		.5, .5,
	};
	
	// Sets up an array of values for the texture coordinates.
	const GLshort spriteTexcoords[] = {
		0, 0,
		1, 0,
		0, 1,
		1, 1,
	};
	
	glPushMatrix();
	glTranslatef(.12, -.72, -1.801);
	glRotatef(90, 0, 0, -1);
	glScalef(6.5, 6.5, 1); //large background to get rid of the black on the sides when zoomed out too far
//	glScalef(3.85, 3.85, 1); //background fits to screen
	glColor4f(1, 1, 1, 1);

	glBindTexture(GL_TEXTURE_2D, textureBackground);
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glEnable(GL_TEXTURE_2D);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
	
	//my computer can't handle drawing the damn background
#if TARGET_IPHONE_SIMULATOR
#else
#endif
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glPopMatrix();
	
	id object;

	//draw the first layer
	for (int i = 0; i < [objects count]; i++)
	{
		object = [objects objectAtIndex:i];
		glPushMatrix();
		[(OpenGLObject*)object draw1];
		glPopMatrix();
	}

	//draw the second layer
	for (int i = 0; i < [objects count]; i++)
	{
		object = [objects objectAtIndex:i];
		glPushMatrix();
		[(OpenGLObject*)object draw2];
		glPopMatrix();
	}

	//draw the third layer
	for (int i = 0; i < [objects count]; i++)
	{
		object = [objects objectAtIndex:i];
		glPushMatrix();
		[(OpenGLObject*)object draw3];
		glPopMatrix();
	}

	//draw the fourth layer
	for (int i = 0; i < [objects count]; i++)
	{
		object = [objects objectAtIndex:i];
		glPushMatrix();
		[(OpenGLObject*)object draw4];
		glPopMatrix();
	}

	/*
	if (drawBotIdentifier)
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, textureBuffer1);
		glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, 128, 128, 0);
		glDisable(GL_TEXTURE_2D);
	}
	*/

    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];

	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
	
	drawBotIdentifier = false;
}

- (void)clear
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glViewport(0, 0, backingWidth, backingHeight);
    
	//	glClearColor(.2, .4, .6, 1);
	glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
}


- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == context)
	{
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	
    [super dealloc];
}


@end
