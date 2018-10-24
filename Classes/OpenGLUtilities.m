//
//  utilities.m
//  Bounce
//
//  Created by Jeremiah Gage on 2/21/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "OpenGLUtilities.h"

void perspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	GLfloat xmin, xmax, ymin, ymax;
	
	ymax = zNear * tan(fovy * M_PI / 360.0);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
	
	glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
	
	
	glMatrixMode(GL_MODELVIEW);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	
	glDepthMask(GL_TRUE);
}

// returns m1*m2 in result (4x4)
// this is column major order
void matrixMultiply4x4(const GLfloat *m1, const GLfloat *m2, GLfloat *result)
{
	// first column
	result[0] = m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3];
	result[1] = m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3];
	result[2] = m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3];
	result[3] = m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3];
	
	// second column
	result[4] = m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7];
	result[5] = m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7];
	result[6] = m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7];
	result[7] = m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7];
	
	// third column
	result[8] = m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11];
	result[9] = m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11];
	result[10] = m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11];
	result[11] = m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11];
	
	// fourth column
	result[12] = m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15];
	result[13] = m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15];
	result[14] = m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15];
	result[15] = m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15];
	
}

// returns m1*v1 in result (4x1)
// this is column major order
void matrixVectorMultiply4x1(const GLfloat *m1, const GLfloat *v1, GLfloat *result)
{
	result[0] = v1[0]*m1[0] + v1[1]*m1[4] + v1[2]*m1[8] + v1[3]*m1[12];
	result[1] = v1[0]*m1[1] + v1[1]*m1[5] + v1[2]*m1[9] + v1[3]*m1[13];
	result[2] = v1[0]*m1[2] + v1[1]*m1[6] + v1[2]*m1[10] + v1[3]*m1[14];
	result[3] = v1[0]*m1[3] + v1[1]*m1[7] + v1[2]*m1[11] + v1[3]*m1[15];
}

void slyGluProject(const GLfloat *obj, GLfloat *win)
{
	GLfloat v[4] = {obj[0], obj[1], obj[2], 1.0};
	static GLint viewport[4];								// Where The Viewport Values Will Be Stored
	static GLfloat modelview[16];					// Where The 16 Doubles Of The Modelview Matrix Are To Be Stored
	static GLfloat projection[16];				// Where The 16 Doubles Of The Projection Matrix Are To Be Stored
	static GLfloat vP[4], vPP[4];
	
	glGetIntegerv(GL_VIEWPORT, viewport);			// Retrieves The Viewport Values (X, Y, Width, Height)
    //NSLog(@"%d, %d, %d, %d", viewport[0], viewport[1], viewport[2], viewport[3]);
    viewport[2] = APP_WIDTH;
    viewport[3] = APP_HEIGHT;
	glGetFloatv(GL_MODELVIEW_MATRIX, modelview);		// Retrieve The Modelview Matrix

	glGetFloatv(GL_PROJECTION_MATRIX, projection);		// Retrieve The Projection Matrix
	
	matrixVectorMultiply4x1(modelview, v, vP);
	matrixVectorMultiply4x1(projection, vP, vPP);
/*
	NSLog(@"projection: %f, %f, %f, %f", projection[0], projection[4], projection[8], projection[12]);
	NSLog(@"projection: %f, %f, %f, %f", projection[1], projection[5], projection[9], projection[13]);
	NSLog(@"projection: %f, %f, %f, %f", projection[2], projection[6], projection[10], projection[14]);
	NSLog(@"projection: %f, %f, %f, %f", projection[3], projection[7], projection[11], projection[15]);
	
	NSLog(@"modelview: %f, %f, %f, %f", modelview[0], modelview[4], modelview[8], modelview[12]);
	NSLog(@"modelview: %f, %f, %f, %f", modelview[1], modelview[5], modelview[9], modelview[13]);
	NSLog(@"modelview: %f, %f, %f, %f", modelview[2], modelview[6], modelview[10], modelview[14]);
	NSLog(@"modelview: %f, %f, %f, %f", modelview[3], modelview[7], modelview[11], modelview[15]);

	NSLog(@"vP: %f, %f, %f, %f", vP[0], vP[1], vP[2], vP[3]);
	NSLog(@"vPP: %f, %f, %f, %f", vPP[0], vPP[1], vPP[2], vPP[3]);
*/
	vPP[0] /= vPP[3];
	vPP[1] /= vPP[3];
	vPP[2] /= vPP[3];
	
	win[0] = viewport[0] + viewport[2] * (vPP[0] + 1) / 2;
	win[1] = viewport[1] + viewport[3] * (vPP[1] + 1) / 2;
	win[2] = (vPP[2]	+ 1) / 2;
}

void loadTexture(NSString *file, GLuint *name)
{
	CGImageRef spriteImage = [UIImage imageNamed:file].CGImage;
	
	if(spriteImage) 
	{
		size_t width = CGImageGetWidth( spriteImage );
		size_t height = CGImageGetHeight( spriteImage );
		// Allocated memory needed for the bitmap context
		GLubyte *spriteData = (GLubyte *) malloc(width * height * 4);
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
		//clear the context
		CGContextClearRect(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height));
		// After you create the context, you can draw the sprite image to the context.
		CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(spriteContext);
		
		// Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, name);

		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, *name);

		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//		glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);

//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		// Specify a 2D texture image, providing the pointer to the image data in memory
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);

		glGenerateMipmapOES(GL_TEXTURE_2D);

		// Release the image data
		free(spriteData);
	}
}

void unloadTexture(GLuint *name)
{
	glDeleteTextures(1 , name);
}

void loadPVRTexture(NSString *file, GLuint *name)
{
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	PVRTexture *pvrTexture = [PVRTexture pvrTextureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"pvr"]];
	[pvrTexture retain];

	if (pvrTexture == nil)
		NSLog(@"Failed to load pvr");
	else
		*name = [pvrTexture name];
}

void texImage2DPVRTC(GLint level, GLsizei bpp, GLboolean hasAlpha, GLsizei width, GLsizei height, void *data)
{
    GLenum format;
    GLsizei size = width * height * bpp / 8;
    if(hasAlpha) {
        format = (bpp == 4) ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
    } else {
        format = (bpp == 4) ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
    }
    if(size < 32) {
        size = 32;
    }
    glCompressedTexImage2D(GL_TEXTURE_2D, level, format, width, height, 0, size, data);
}

void GLDrawEllipse(int segments, CGFloat width, CGFloat height, bool filled)
{
	GLfloat vertices[segments*2];
	int count=0;
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/segments))
	{
		vertices[count++] = (cos(DEGREES_TO_RADIANS(i))*width);
		vertices[count++] = (sin(DEGREES_TO_RADIANS(i))*height);
	}
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT , 0, vertices); 
	glDrawArrays((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void GLDrawCircle(int circleSegments, CGFloat circleSize, bool filled) 
{
	GLDrawEllipse(circleSegments, circleSize, circleSize, filled);
}
