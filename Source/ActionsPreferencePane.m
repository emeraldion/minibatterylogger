//
//  ActionsPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 23-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "ActionsPreferencePane.h"


@implementation ActionsPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"general"]];
	}
	return self;
}

@end
