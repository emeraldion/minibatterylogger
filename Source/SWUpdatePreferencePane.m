//
//  SWUpdatePreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 2-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "SWUpdatePreferencePane.h"


@implementation SWUpdatePreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"swupdate"]];
	}
	return self;
}

@end
