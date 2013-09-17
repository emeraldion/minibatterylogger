//
//  MBLPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLPreferencePane.h"

@class AppController;

@implementation MBLPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super init]) {
		[self setIdentifier:theIdentifier];
		[self setLabel:theLabel];
		[self setCategory:theCategory];
		[self setIcon:[NSImage imageNamed:@"advanced"]];
	}
	return self;
}

- (void)dealloc
{
	[identifier release];
	[label release];
	[category release];
	[icon release];
	[super dealloc];
}

- (void)setIdentifier:(NSString *)str
{
	[str retain];
	[identifier release];
	identifier = str;
}
- (NSString *)identifier
{
	return identifier;
}

- (void)setLabel:(NSString *)str
{
	[str retain];
	[label release];
	label = str;
}
- (NSString *)label
{
	return label;
}

- (void)setIcon:(NSImage *)ico
{
	[ico retain];
	[icon release];
	icon = ico;
}
- (NSImage *)icon
{
	return icon;
}

- (void)setCategory:(NSString *)str
{
	[str retain];
	[category release];
	category = str;
}
- (NSString *)category
{
	return category;
}

- (NSView *)mainView
{
	if (!mainView)
	{
		// This will cause the outlet "mainView" to be set automatically
		[NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
		[self mainViewDidLoad];
	}
	return mainView;
}

- (void)mainViewDidLoad
{
	// Does nothing
}

#pragma mark === Actions ===

- (IBAction)onlineHelp:(id)sender
{
	[[AppController sharedController] onlineHelp:sender];
}

@end
