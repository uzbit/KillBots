//
//  PrivateMutableArray.m
//  AiWars
//
//  Created by Jeremiah Gage on 8/22/09.
//  Copyright 2009 Slyco. All rights reserved.
//

#import "PrivateMutableArray.h"


@implementation PrivateMutableArray


- (id) init
{
	return [self initWithCapacity:1];
}

- (id) initWithCapacity:(unsigned int) n
{
	[super init];
	
	pointers_  = malloc( sizeof( id) * n);
	nPointers_ = 0;
	size_      = n;
	return( self);
}

- (id) initWithArray:(NSArray *)array
{
	[super init];
	
	nPointers_ = [array count];
	pointers_  = malloc( sizeof( id) * nPointers_);
	for (int index = 0; index < [array count]; index++)
	{
		pointers_[index] = [array objectAtIndex:index];
	}
	size_      = nPointers_;

	return( self);
}

- (id) initWithPrivateArray:(PrivateMutableArray *)array
{
	[super init];
	
	nPointers_ = [array count];
	pointers_  = malloc( sizeof( id) * nPointers_);
	for (int index = 0; index < [array count]; index++)
	{
		pointers_[index] = [array objectAtIndex:index];
	}
	size_      = nPointers_;
	
	return( self);
}

- (void) dealloc
{
	[self removeAllObjects];
	free( pointers_);
	[super dealloc];
}


- (void) grow
{
    unsigned int newsize;
	
    if( (newsize = size_ + size_) < size_ + 4)
		newsize = size_ + 4;
    if( ! (pointers_ = realloc( pointers_, newsize * sizeof( id))))
        [NSException raise:NSMallocException format:@"%@ can't grow from %u to %u entries", self, size_, newsize];
    size_ = newsize;
}


- (void) addObject:(id) p
{
	if( ! p)
		[NSException raise:NSInvalidArgumentException format:@"null pointer"];
	if( nPointers_ >= size_)
		[self grow];
	self->pointers_[ self->nPointers_++] = [p retain];
}

- (void)insertObject:(id)p atIndex:(unsigned int)i
{
	if( i > nPointers_)
		[NSException raise:NSInvalidArgumentException format:@"index %d out of bounds %d", i, nPointers_];
	if( nPointers_ >= size_)
		[self grow];

	for (int index = nPointers_-1; index >= i; index--)
	{
		self->pointers_[index+1] = self->pointers_[index];
	}

	self->pointers_[i] = [p retain];
	self->nPointers_++;
}

- (void)addObjectsFromArray:(NSArray *)array
{
	for (int index = 0; index < [array count]; index++)
	{
		[self addObject:[array objectAtIndex:index]];
	}
}

- (void)addObjectsFromPrivateArray:(PrivateMutableArray *)array
{
	for (int index = 0; index < [array count]; index++)
	{
		[self addObject:[array objectAtIndex:index]];
	}
}

- (void) removeAllObjects
{
	unsigned int i;
	
	for( i = 0; i < nPointers_; i++)
		[pointers_[ i] release];
	
	self->nPointers_ = 0;
}

- (void) removeLastObject
{
	if (nPointers_ == 0)
		[NSException raise:NSObjectInaccessibleException format:@"array is empty"];
	[pointers_[nPointers_-1] release];
	nPointers_--;
}

- (void) removeObject:(id)p
{
	unsigned int index = [self indexOfObject:p];
	if (index != NSNotFound)
	{
		[self removeObjectAtIndex:index];
	}
}

- (void) replaceObjectAtIndex:(unsigned int)i withObject:(id)p
{
	if( i >= nPointers_)
		[NSException raise:NSInvalidArgumentException format:@"index %d out of bounds %d", i, nPointers_];
	self->pointers_[i] = p;
}

- (unsigned int) count
{
	return( nPointers_);
}

- (id) objectAtIndex:(unsigned int) i
{
	if( i >= nPointers_)
		[NSException raise:NSInvalidArgumentException format:@"index %d out of bounds %d", i, nPointers_];
	return( pointers_[ i]);
}

- (id) lastObject
{
	if (nPointers_ == 0)
		[NSException raise:NSObjectInaccessibleException format:@"array is empty"];
	return pointers_[nPointers_-1];
}

- (unsigned int)indexOfObject:(id) p
{
	unsigned int i;
	
	for( i = 0; i < nPointers_; i++)
	{
		if (self->pointers_[i] == p)
			return i;
	}
	return NSNotFound;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    if (state->state >= nPointers_)
    {
        return 0;
    }
	
	state->itemsPtr = pointers_;
    state->state = nPointers_;
    state->mutationsPtr = (unsigned long *)self;
    
    return nPointers_;
}

- (void) removeObjectAtIndex:(unsigned int) i
{
	if( i >= nPointers_)
		[NSException raise:NSInvalidArgumentException format:@"index %d out of bounds %d", i, nPointers_];
return;
	[pointers_[ i] release];
	for (int index = i; index <= nPointers_-1; index++)
	{
		self->pointers_[index] = self->pointers_[index+1];
	}
	nPointers_--;
}

- (void)removeObjectsInArray:(NSArray *)array
{
	for (int index = 0; index < [array count]; index++)
	{
		[self removeObject:[array objectAtIndex:index]];
	}
}

- (void)removeObjectsInPrivateArray:(PrivateMutableArray *)array
{
	unsigned int i;
	for (int index = 0; index < [array count]; index++)
	{
		i = [self indexOfObject:[array objectAtIndex:index]];
		if (i != NSNotFound)
			[self removeObjectAtIndex:i];
	}
}

@end