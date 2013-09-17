//
//  NSArrayAdditionsTest.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "NSArrayAdditionsTest.h"

@implementation NSArrayAdditionsTest

- (void)testRemoveDuplicates
{
	NSMutableArray *dupes = [NSMutableArray arrayWithObjects:@"ciao",
		@"ciao",
		@"hola",
		@"bonsoir",
		@"hello",
		@"bonsoir",
		@"guten tag",
		@"hola",
		nil];
	
	STAssertTrue([dupes count] == 8, @"Duplicates have not been removed yet");
	[dupes removeDuplicates];
	STAssertTrue([dupes count] == 5, @"Duplicates were not removed properly");
	
	NSMutableArray *unique = [NSMutableArray arrayWithObjects:@"ciao",
		@"hola",
		@"bonsoir",
		@"hello",
		@"guten tag",
		nil];

	STAssertTrue([unique count] == 5, @"Duplicates have not been removed yet");
	[unique removeDuplicates];
	STAssertTrue([unique count] == 5, @"Duplicates were not removed properly");
}

- (void)testArrayByRemovingDuplicates
{
	NSArray *dupes = [NSArray arrayWithObjects:@"ciao",
		@"ciao",
		@"hola",
		@"bonsoir",
		@"hello",
		@"bonsoir",
		@"guten tag",
		@"hola",
		nil];
	
	NSArray *unique = [dupes arrayByRemovingDuplicates];
	STAssertTrue([unique count] == 5, @"Duplicates were not removed properly");
}

@end
