//
//  PrivateMutableArray.h
//  AiWars
//
//  Created by Jeremiah Gage on 8/22/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PrivateMutableArray : NSObject <NSFastEnumeration>
{
	id             *pointers_;
	unsigned int   size_;
	unsigned int   nPointers_;
}

- (id) initWithCapacity:(unsigned int) n;
- (id) initWithArray:(NSArray *)array;
- (void) dealloc;
- (void) grow;
- (void) addObject:(id) p;
- (void) insertObject:(id)p atIndex:(unsigned int)i;
- (void) addObjectsFromArray:(NSArray *)array;
- (void) addObjectsFromPrivateArray:(PrivateMutableArray *)array;
- (void) removeAllObjects;
- (unsigned int) count;
- (id) objectAtIndex:(unsigned int) i;
- (id) lastObject;
- (unsigned int) indexOfObject:(id) p;
- (void) removeObjectAtIndex:(unsigned int) i;
- (void) removeLastObject;
- (void) removeObject:(id)p;
- (void) replaceObjectAtIndex:(unsigned int)i withObject:(id)p;
- (void) removeObjectsInArray:(NSArray *)array;
- (void) removeObjectsInPrivateArray:(PrivateMutableArray *)array;

@end
