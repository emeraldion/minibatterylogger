//
//  MBLStatusItem.m
//  MiniBatteryLogger
//
//  Created by delphine on 16-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "MBLStatusItem.h"
#import "NSImage+MBLUtils.h"

@interface MBLStatusItem (Private)

- (void)update;

- (void)startObservingBattery:(Battery *)batt;
- (void)stopObservingBattery:(Battery *)batt;

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context;

@end

@implementation MBLStatusItem

+ (id)initialize
{
	[self exposeBinding:@"battery"];
}

- (id)initWithController:(NSObjectController *)controller
{
    if (self = [super init])
	{
		[self activate];
		
		/* Initialization code here */
		_mode = [[[NSUserDefaults standardUserDefaults] valueForKey:MBLStatusItemModeKey] intValue];
		_hideTime = [[[NSUserDefaults standardUserDefaults] valueForKey:MBLStatusItemHideTimeWhenPossibleKey] boolValue];
				
		_fontAttributes = 	[[NSMutableDictionary alloc] init];
		[_fontAttributes setObject:[NSFont fontWithName:@"Lucida Grande"
												  size:11.0]
							forKey:NSFontAttributeName];
		[_fontAttributes setObject:[NSColor controlTextColor]
							forKey:NSForegroundColorAttributeName];		
		
		[self bind:@"battery"
		  toObject:controller
	   withKeyPath:@"selection.self"
		   options:nil];
    }
    return self;
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding
	   toObject:observable
	withKeyPath:keyPath
		options:options];
	// Update now
	[self update];
}

- (void)activate
{
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		
	[_statusItem setImage:[NSImage imageNamed:@"bezel"]];
	[_statusItem setAlternateImage:[NSImage imageNamed:@"bezel_white"]];
	[_statusItem setHighlightMode:YES];	
}

- (void)remove
{
	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	_statusItem = nil;
}

- (void)dealloc
{
	[self stopObservingBattery:_battery];

	if (_statusItem != nil)
	{
		[self remove];
	}
	[_fontAttributes release];
	[_battery release];
	[super dealloc];
}

- (void)setMenu:(NSMenu *)menu
{
	[_statusItem setMenu:menu];
	[self update];
}

- (void)setHidesTimeWhenPossible:(BOOL)hide
{
	_hideTime = hide;
	[self update];
}

- (BOOL)hidesTimeWhenPossible
{
	return _hideTime;
}

- (void)setVisualizationMode:(MBLStatusItemMode)mode
{
	_mode = mode;
	[self update];
}

- (MBLStatusItemMode)visualizationMode
{
	return _mode;
}

- (void)setBattery:(Battery *)batt
{
	[self stopObservingBattery:_battery];
	
	[batt retain];
	[_battery release];
	_battery = batt;
	
	[self startObservingBattery:_battery];
}

- (Battery *)battery
{
	return _battery;
}

@end

@implementation MBLStatusItem (Private)

- (void)update
{
	[_statusItem setImage:[NSImage statusImageForBattery:_battery
											 highlighted:NO]];
	[_statusItem setAlternateImage:[NSImage statusImageForBattery:_battery
											   highlighted:YES]];
	NSString *chargeAmountTitle;
	if ([_battery isInstalled])
	{
		chargeAmountTitle = [NSString stringWithFormat:NSLocalizedString(@"Charge: %d%%", @"Charge: %d%%"), [_battery charge]];
		if ([_battery isCharging] &&
			[_battery timeToFullCharge] > 0)
		{
			chargeAmountTitle = [chargeAmountTitle stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@". %@ to full charge", @". %@ to full charge"), [[NSValueTransformer valueTransformerForName:@"SecondsToMinutesCompactTransformer"] transformedValue:[NSNumber numberWithInt:[_battery timeToFullCharge]]]]];
		}
		else if (![_battery isPlugged] &&
				 [_battery timeToEmpty] > 0)
		{
			chargeAmountTitle = [chargeAmountTitle stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@". %@ to empty", @". %@ to empty"), [[NSValueTransformer valueTransformerForName:@"SecondsToMinutesCompactTransformer"] transformedValue:[NSNumber numberWithInt:[_battery timeToEmpty]]]]];
		}
	}
	else
	{
		chargeAmountTitle = NSLocalizedString(@"The battery is not installed",
											  @"The battery is not installed");
	}
	[[[_statusItem menu] itemWithTag:128] setTitle:chargeAmountTitle];
	
	NSString *powerStateTitle = [NSString stringWithFormat:NSLocalizedString(@"Power source: %@", @"Power source: %@"),
		([_battery isPlugged] ?
		 NSLocalizedString(@"AC adapter", @"AC adapter") :
		 NSLocalizedString(@"battery", @"battery"))];
	[[[_statusItem menu] itemWithTag:129] setTitle:powerStateTitle];
	
	NSString *statusItemTitle;
	NSString *timeString;
	NSTimeInterval seconds;
	
	seconds = ([_battery isCharging] ? [_battery timeToFullCharge] : [_battery timeToEmpty]);
	
	if (_hideTime && seconds <= 0)
	{
		timeString = @"";
	}
	else
	{
		timeString = [[NSValueTransformer valueTransformerForName:@"SecondsToMinutesInfinityTransformer"] transformedValue:[NSNumber numberWithInt:seconds]];
	}
	
	switch (_mode)
	{
		case MBLStatusItemCharge:
			statusItemTitle = [NSString stringWithFormat:@"%d%%", [_battery charge]];
			break;
		case MBLStatusItemTime:
			statusItemTitle = timeString;
			break;
		case MBLStatusItemAll:
			statusItemTitle = [NSString stringWithFormat:@"%d%%", [_battery charge]];
			if ([timeString length] > 0)
			{
				statusItemTitle = [statusItemTitle stringByAppendingFormat:@" %@", timeString];
			}
			break;
		case MBLStatusItemBatteryTimer:
			statusItemTitle = [[NSValueTransformer valueTransformerForName:@"SecondsToMinutesCompactTransformer"] transformedValue:[NSNumber numberWithInt:[_battery timeOnBattery]]];
			break;
		case MBLStatusItemPlain:
		default:
			statusItemTitle = @"";
	}
	
	NSAttributedString *attrStatusItemTitle = [[NSAttributedString alloc] initWithString:statusItemTitle
																			  attributes:_fontAttributes];
	[_statusItem setAttributedTitle:attrStatusItemTitle];
	[attrStatusItemTitle release];
}

- (void)startObservingBattery:(Battery *)batt
{
	[batt addObserver:self
		   forKeyPath:@"charge"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"plugged"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"charging"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"timeToFullCharge"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"timeToEmpty"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[batt addObserver:self
		   forKeyPath:@"timeOnBattery"
			  options:NSKeyValueObservingOptionOld
			  context:NULL];
	[self update];
}

- (void)stopObservingBattery:(Battery *)batt
{
	[batt removeObserver:self
			  forKeyPath:@"charge"];
	[batt removeObserver:self
			  forKeyPath:@"plugged"];
	[batt removeObserver:self
			  forKeyPath:@"charging"];
	[batt removeObserver:self
			  forKeyPath:@"timeToFullCharge"];
	[batt removeObserver:self
			  forKeyPath:@"timeToEmpty"];
	[batt removeObserver:self
			  forKeyPath:@"timeOnBattery"];
}

/**
 *	This method will be called when one of the observed keypaths
 *	of the battery is changed
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	// Request a redraw on observed property change
	[self update];
}

- (void)copyBatteryToPasteboard:(NSPasteboard *)pb
{
	// Put the battery description to the pasteboard
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pb setString:[_battery description] forType:NSStringPboardType];	
}

@end

