//
//  Map.m
//  AiWars
//
//  Created by Ted McCormack on 3/8/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "Map.h"
#import "Pathfind.h"

@implementation Map

- (Map *) initWithBackground:(NSString *)bFile andGrid:(NSString *)gFile
{
	CGImageRef spriteImage = [UIImage imageNamed:bFile].CGImage;
	CGImageRef gridImage = [UIImage imageNamed:gFile].CGImage;
	
	if(spriteImage) 
	{
		size_t width = CGImageGetWidth( spriteImage );
		size_t height = CGImageGetHeight( spriteImage );
		// Allocated memory needed for the bitmap context
		GLubyte *spriteData = (GLubyte *) malloc(width * height * 4);
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
		// After you create the context, you can draw the sprite image to the context.
		CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(spriteContext);
			
		// Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, &backgroundId);
		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, backgroundId);
		// Specify a 2D texture image, providing the pointer to the image data in memory
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
		// Release the image data
		free(spriteData);

		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	if (gridImage)
	{
		grid = (short **)malloc(GRID_BOUNDS_X * sizeof(short *));
		for(int i = 0; i < GRID_BOUNDS_X; i++)
			grid[i] = (short *)malloc(GRID_BOUNDS_Y * sizeof(short));
		
		CFDataRef inputData = CGDataProviderCopyData(CGImageGetDataProvider(gridImage));
		unsigned char *pixelData = (unsigned char *) CFDataGetBytePtr(inputData);
		int length = CFDataGetLength(inputData);
		size_t bytesPerRow = CGImageGetBytesPerRow(gridImage);
		
		/*		
		size_t width = CGImageGetWidth(gridImage);
		size_t height = CGImageGetHeight(gridImage);
		
		size_t bitsPerComponent = CGImageGetBitsPerComponent(gridImage);
		size_t bitsPerPixel = CGImageGetBitsPerPixel(gridImage);
		NSLog(@"width %d, height %d, bPc %d, bpp %d, bpr %d, length %d", width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, length);
		 */	
		int i = 0, j = 0;
		
		for (int index = 0; index < length; index += 4 ) {
			unsigned char red   = *(pixelData + index);
			unsigned char green = *(pixelData + index + 1);
			unsigned char blue  = *(pixelData + index + 2);
			
			if (index % (4*GRID_PIXEL_SIZE) == 0 && index != 0)
				i++;
			
			if (index % (bytesPerRow*GRID_PIXEL_SIZE) == 0 && index != 0)
				j++;
			
			if (index % bytesPerRow == 0)
				i = 0;
			
			if (!(red || blue || green))
				grid[i][j] = MAP_ALLOW_NONE;
			else if (green)
				grid[i][j] = MAP_ALLOW_ALL;
			else 
				grid[i][j] = MAP_ALLOW_FLIGHT;
		}
		
		registerGrid(grid);
		
	}
	
	//JUST FOR TESTING PATHFIND:
	//Use for verifying boundaries
	 //. = nogo and - = go
	 /*
	PathNode *start = [PathNode alloc];
	PathNode *goal = [PathNode alloc];
	mapOglToGrid(-1.49, 0.99, start);
	mapOglToGrid(1.49, 0.99, goal);
	NSMutableArray *aPath = [[[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:nil]] retain];
	findAStarPath(start, goal, aPath);
	for (PathNode *p in aPath)
		NSLog(@"(x, y) = %d, %d", [p x], [p y]);
	
	 for (int j = 0; j < GRID_BOUNDS_Y; j ++)
	 {
		 for(int i = 0; i < GRID_BOUNDS_X; i++)
		 {
			 if ([start x] == i && [start y] == j)
			 {
				 printf("S");
			 }
			 else if ([goal x] == i && [goal y] == j)
			 {
				 printf("G");
			 }
			 int foundPath = 0;
			 for (PathNode *pn in aPath)
			 {
				 if ([pn x] == i && [pn y] == j)
				 {
					 printf("#");
					 foundPath = 1;
					 break;
				 }			
			 }
			 if (!foundPath)
			 {
				 printf("%c", (char)((grid[i][j])?'-':'.'));
			 }
		 }
		 printf("\n");
	 }
	[start release];
	[goal release];
	[aPath release];*/
				 
	return self;
}


- (void)draw2
{
	//NSLog(@"Called MapDraw");
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

	glColor4f(1, 1, 1, 1);
	
	glTranslatef(0, 0, -1);
	glRotatef(90, 0, 0, -1);
	static int angle = 0; angle++;
	glRotatef(angle, 1, 1, 0);

	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
    glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

- (void)dealloc
{
	for(int i = 0; i < GRID_BOUNDS_X; i++)
		free(grid[i]);
	free(grid);
	glDeleteTextures(1, &backgroundId);
    [super dealloc];
}


@end
