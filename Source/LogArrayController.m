//
//  LogArrayController.m
//  MiniBatteryLogger
//
//  Created by delphine on 30-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "LogArrayController.h"

@implementation LogArrayController

- (NSArray *)arrangeObjects:(NSArray *)objects {
    
    if (searchString == nil ||
		searchString == @"") {
        return [super arrangeObjects:objects];   
    }
    
    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    NSEnumerator *objectsEnumerator = [objects objectEnumerator];
    id item;
    
    while (item = [objectsEnumerator nextObject]) {
        if ([item rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filteredObjects addObject:item];
        }
    }
    return [super arrangeObjects:filteredObjects];
}

- (void)dealloc
{
	[searchString release];
	[super dealloc];
}

- (NSString *)searchString
{
	return searchString;
}

- (void)setSearchString:(NSString *)sString
{
    [searchString release];
	
    if ([sString length] == 0)
	{
        searchString = nil;
    }
	else
	{
        searchString = [sString copy];
    }
}

- (IBAction)filter:(id)sender
{
	[self setSearchString: [sender stringValue]];
    [self rearrangeObjects];
}

/*
- (void)addObject:(id)anObject
{
	NSLog(@"adding: %@", anObject);
	[super addObject:anObject];
}
*/

@end
