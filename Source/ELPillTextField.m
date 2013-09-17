//
//  ELPillTextField.m
//  MiniBatteryLogger
//
//  Created by delphine on 25-03-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "ELPillTextField.h"
#import "NSBezierPath+MBLUtils.h"

@class ELPillTextFieldCell;

@interface NSColor (ELToolkit)

- (NSColor *)brightnessReducedBy:(float)amount;

@end

@implementation NSColor (ELToolkit)

- (NSColor *)brightnessReducedBy:(float)amount
{
	//NSLog(@"brightnessReducedBy:%f", amount);
	
	NSString *spaceName = [self colorSpaceName];
	if ([spaceName isEqualToString:NSCalibratedWhiteColorSpace])
	{
		return [NSColor colorWithCalibratedWhite:[self whiteComponent] * amount
										   alpha:[self alphaComponent]];
	}
	else if ([spaceName isEqualToString:NSDeviceWhiteColorSpace])
	{
		return [NSColor colorWithDeviceWhite:[self whiteComponent] * amount
									   alpha:[self alphaComponent]];
	}
	else if ([spaceName isEqualToString:NSCalibratedRGBColorSpace])
	{
		return [NSColor colorWithCalibratedHue:[self hueComponent]
									saturation:[self saturationComponent]
									brightness:[self brightnessComponent] * amount
										 alpha:[self alphaComponent]];
		
	}
	else if ([spaceName isEqualToString:NSDeviceRGBColorSpace])
	{
		return [NSColor colorWithDeviceHue:[self hueComponent]
								saturation:[self saturationComponent]
								brightness:[self brightnessComponent] * amount
									 alpha:[self alphaComponent]];
		
	}
	else
	{
		NSColor *cColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		//NSLog(@"Named color space: %@", cColor);
		return [NSColor colorWithDeviceHue:[cColor hueComponent]
								saturation:[cColor saturationComponent]
								brightness:[cColor brightnessComponent] * amount
									 alpha:[cColor alphaComponent]];
	}
}

@end

@implementation ELPillTextField

+ (Class) cellClass
{
	//NSLog(@"cellClass");
	return [ELPillTextFieldCell class];
}

+ (void)initialize
{
	[self setCellClass:[ELPillTextFieldCell class]];
}

/*
 - (void)drawRect:(NSRect)aRect
 {
	 NSLog(@"drawRect:");
	 [super drawRect:aRect];
	 
	 NSRect pillRect = [self bounds];
	 NSBezierPath *pill;
	 
	 if ([self drawsBackground])
	 {
		 pill = [NSBezierPath bezierPathWithRoundedRect:pillRect
										   cornerRadius:pillRect.size.height / 2];
		 [[self backgroundColor] set];
		 [pill fill];
	 }
	 
	 if ([self isBordered])
	 {
		 pillRect.origin.x += 0.5;
		 pillRect.origin.y += 0.5;
		 pillRect.size.width -= 1.0;
		 pillRect.size.height -= 1.0;
		 
		 pill = [NSBezierPath bezierPathWithRoundedRect:pillRect
										   cornerRadius:pillRect.size.height / 2];
		 [pill setLineWidth:1.0];
		 [_borderColor set];
		 [pill stroke];
	 }
	 //[super drawRect:aRect];
 }
 
 */

- (void)setObjectValue:(id)obj
{
	[super setObjectValue:obj];
	[self sizeToFit];
}

- (void)setStringValue:(NSString *)str
{
	[super setStringValue:str];
	[self sizeToFit];
}

- (void)setBackgroundColor:(NSColor *)aColor
{
	[self setBorderColor:[aColor brightnessReducedBy:0.8]];
	[super setBackgroundColor:aColor];
}

- (void)setBorderColor:(NSColor *)aColor
{
	[aColor retain];
	[_borderColor release];
	_borderColor = aColor;
}
- (NSColor *)borderColor
{
	return _borderColor;
}

- (void)sizeToFit
{
	//NSLog(@"sizeToFit");
	ELPillTextFieldCell *theCell = (ELPillTextFieldCell *)[self cell];
	
	[self setFrameSize:(NSSize)[theCell optimalSize]];
	//[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
	// This forces the borderColor to be set
	[self setBackgroundColor:[self backgroundColor]];
	[self setTextColor:[self textColor]];
	//NSLog(@"%@", [self cell]);
}

@end
