//
//  ELPlainButton.m
//  MiniBatteryLogger
//
//  Created by delphine on 18-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "ELPlainButton.h"


@implementation ELPlainButton

- (id)init
{
	if (self = [super init])
	{
		[self setFocusRingType:NSFocusRingTypeNone];
	}
	return self;
}

@end

@implementation ELPlainButton (NSNibAwaking)

- (void)awakeFromNib
{
	[self setFocusRingType:NSFocusRingTypeNone];
}

@end