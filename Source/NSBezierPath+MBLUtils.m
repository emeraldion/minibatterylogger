//
//  NSBezierPath+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 14-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSBezierPath+MBLUtils.h"


@implementation NSBezierPath (MBLUtils)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius
{
    NSBezierPath *result = [NSBezierPath bezierPath];
    [result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
    return result;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius
{
    if (!NSIsEmptyRect(rect)) {
		if (radius > 0.0) {
			// Clamp radius to be no larger than half the rect's width or height.
			float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width,  
														rect.size.height));
			
			NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
			NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
			NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
			
			[self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
			[self appendBezierPathWithArcFromPoint:topLeft      
										   toPoint:rect.origin radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:rect.origin  
										   toPoint:bottomRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:bottomRight  
										   toPoint:topRight    radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:topRight    
										   toPoint:topLeft    radius:clampedRadius];
			[self closePath];
		} else {
			// When radius == 0.0, this degenerates to the simple case of a plain rectangle.
			[self appendBezierPathWithRect:rect];
		}
    }
}

static void linearShadedColor(void *info, const float *in, float *out)
{
	float *colors = info;
	*out++ = colors[0] + *in * colors[8];
	*out++ = colors[1] + *in * colors[9];
	*out++ = colors[2] + *in * colors[10];
	*out++ = colors[3] + *in * colors[11];
}

static void bilinearShadedColor(void *info, const float *in, float *out)
{
	float *colors = info;
	float factor = (*in)*2.0;
	if (*in > 0.5) {
		factor = 2-factor;
	}
	*out++ = colors[0] + factor * colors[8];
	*out++ = colors[1] + factor * colors[9];
	*out++ = colors[2] + factor * colors[10];
	*out++ = colors[3] + factor * colors[11];
}

- (void)linearGradientFillWithStartColor:(NSColor *)startColor endColor:(NSColor *)endColor
{
	/*
	 CGColorSpaceRef colorspace;
	 CGShadingRef shading;
	 CGPoint startPoint = {0, 0};
	 CGPoint endPoint = {0, 0};
	 CGFunctionRef function;
	 float colors[12]; // pointer to color values
	 
	 // get my context
	 CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	 
	 NSColor *deviceDependentStartColor = [startColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	 NSColor *deviceDependentEndColor = [endColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	 
	 // set up colors for gradient
	 colors[0] = [deviceDependentStartColor redComponent];
	 colors[1] = [deviceDependentStartColor greenComponent];
	 colors[2] = [deviceDependentStartColor blueComponent];
	 colors[3] = [deviceDependentStartColor alphaComponent];
	 
	 colors[4] = [deviceDependentEndColor redComponent];
	 colors[5] = [deviceDependentEndColor greenComponent];
	 colors[6] = [deviceDependentEndColor blueComponent];
	 colors[7] = [deviceDependentEndColor alphaComponent];
	 
	 // difference between start and end color for each color components
	 colors[8] = (colors[4]-colors[0]);
	 colors[9] = (colors[5]-colors[1]);
	 colors[10] = (colors[6]-colors[2]);
	 colors[11] = (colors[7]-colors[3]);
	 
	 // draw gradient
	 colorspace = CGColorSpaceCreateDeviceRGB();
	 
	 size_t components = 1 + CGColorSpaceGetNumberOfComponents(colorspace);
	 static const float  domain[2] = {0.0, 1.0};
	 static const float  range[10] = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1};
	 static const CGFunctionCallbacks callbacks = {0, &shadedColor, NULL};
	 
	 // Create a CGFunctionRef that describes a function taking 1 input and kChannelsPerColor outputs.
	 function = CGFunctionCreate(colors, 1, domain, components, range, &callbacks);
	 
	 startPoint.x=0;
	 startPoint.y=[self bounds].origin.y;
	 endPoint.x=0;
	 endPoint.y=NSMaxY([self bounds]);
	 
	 shading = CGShadingCreateAxial(colorspace, startPoint, endPoint, function, NO, NO);
	 
	 CGContextSaveGState(currentContext);
	 [self addClip];
	 CGContextDrawShading(currentContext, shading);
	 CGContextRestoreGState(currentContext);
	 
	 CGShadingRelease(shading);
	 CGFunctionRelease(function);
	 CGColorSpaceRelease(colorspace);
	 */
	
	static const CGFunctionCallbacks callbacks = {0, &linearShadedColor, NULL};
	
	[self customVerticalFillWithCallbacks:callbacks firstColor:startColor secondColor:endColor];
};

- (void)bilinearGradientFillWithOuterColor:(NSColor *)outerColor innerColor:(NSColor *)innerColor
{
	static const CGFunctionCallbacks callbacks = {0, &bilinearShadedColor, NULL};
	
	[self customVerticalFillWithCallbacks:callbacks firstColor:innerColor secondColor:outerColor];
}

- (void)customVerticalFillWithCallbacks:(CGFunctionCallbacks)functionCallbacks firstColor:(NSColor *)firstColor secondColor:(NSColor *)secondColor
{
	CGColorSpaceRef colorspace;
	CGShadingRef shading;
	CGPoint startPoint = {0, 0};
	CGPoint endPoint = {0, 0};
	CGFunctionRef function;
	float colors[12]; // pointer to color values
	
	// get my context
	CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	
	NSColor *deviceDependentFirstColor = [firstColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	NSColor *deviceDependentSecondColor = [secondColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	// set up colors for gradient
	colors[0] = [deviceDependentFirstColor redComponent];
	colors[1] = [deviceDependentFirstColor greenComponent];
	colors[2] = [deviceDependentFirstColor blueComponent];
	colors[3] = [deviceDependentFirstColor alphaComponent];
	
	colors[4] = [deviceDependentSecondColor redComponent];
	colors[5] = [deviceDependentSecondColor greenComponent];
	colors[6] = [deviceDependentSecondColor blueComponent];
	colors[7] = [deviceDependentSecondColor alphaComponent];
	
	// difference between start and end color for each color components
	colors[8] = (colors[4]-colors[0]);
	colors[9] = (colors[5]-colors[1]);
	colors[10] = (colors[6]-colors[2]);
	colors[11] = (colors[7]-colors[3]);
	
	// draw gradient
	colorspace = CGColorSpaceCreateDeviceRGB();
	size_t components = 1 + CGColorSpaceGetNumberOfComponents(colorspace);
	static const float  domain[2] = {0.0, 1.0};
	static const float  range[10] = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1};
	//static const CGFunctionCallbacks callbacks = {0, &bilinearShadedColor, NULL};
	
	// Create a CGFunctionRef that describes a function taking 1 input and kChannelsPerColor outputs.
	function = CGFunctionCreate(colors, 1, domain, components, range, &functionCallbacks);
	
	startPoint.x=0;
	startPoint.y=[self bounds].origin.y;
	endPoint.x=0;
	endPoint.y=NSMaxY([self bounds]);
	
	shading = CGShadingCreateAxial(colorspace, startPoint, endPoint, function, NO, NO);
	
	CGContextSaveGState(currentContext);
	[self addClip];
	CGContextDrawShading(currentContext, shading);
	CGContextRestoreGState(currentContext);
	
	CGShadingRelease(shading);
	CGFunctionRelease(function);
	CGColorSpaceRelease(colorspace);
}

@end
