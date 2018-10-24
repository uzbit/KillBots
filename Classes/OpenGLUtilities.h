//
//  utilities.h
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import "PVRTexture.h"
#import "Utilities.h"

#define APP_WIDTH	320
#define APP_HEIGHT	480

static inline float radians (float degrees) {return degrees * M_PI/180;}
#define SIGN(x) ((x < 0.0f)?-1.0f:1.0f)

void perspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);

// returns m1*m2 in result (4x4)
void matrixMultiply4x4(const GLfloat *m1, const GLfloat *m2, GLfloat *result);

// returns m1*v1 in result (4x1)
void matrixVectorMultiply4x1(const GLfloat *m1, const GLfloat *v1, GLfloat *result);

// obj (3x1) is gl object position
// win (3x1) is window object position
void slyGluProject(const GLfloat *obj, GLfloat *win);

//loads a texture
void loadTexture(NSString *file, GLuint *name);

//unloads a texture
void unloadTexture(GLuint *name);

//loads a pvr texture
void loadPVRTexture(NSString *file, GLuint *name);

//loads a pvr texture
void texImage2DPVRTC(GLint level, GLsizei bpp, GLboolean hasAlpha, GLsizei width, GLsizei height, void *data);

//circle drawing
void GLDrawEllipse(int segments, CGFloat width, CGFloat height, bool filled);
void GLDrawCircle(int circleSegments, CGFloat circleSize, bool filled);
