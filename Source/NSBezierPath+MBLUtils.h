//
//  NSBezierPath+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 14-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (MBLUtils)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;
- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;
- (void)customVerticalFillWithCallbacks:(CGFunctionCallbacks)functionCallbacks firstColor:(NSColor *)firstColor secondColor:(NSColor *)secondColor;
- (void)linearGradientFillWithStartColor:(NSColor *)startColor endColor:(NSColor *)endColor;
- (void)bilinearGradientFillWithOuterColor:(NSColor *)outerColor innerColor:(NSColor *)innerColor;

@end
