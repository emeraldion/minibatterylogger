//
//  LogArrayController.h
//  MiniBatteryLogger
//
//  Created by delphine on 30-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LogArrayController : NSArrayController
{
	NSString *searchString;
	NSMutableArray *linesToAppend;
	BOOL filteredMode;
}

- (NSString *)searchString;
- (void)setSearchString:(NSString *)sString;
- (IBAction) filter:(id)sender;

@end