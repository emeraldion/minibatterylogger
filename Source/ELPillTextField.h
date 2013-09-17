//
//  ELPillTextField.h
//  MiniBatteryLogger
//
//  Created by delphine on 25-03-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ELPillTextFieldCell.h"

@interface ELPillTextField : NSTextField {
	
	NSColor *_borderColor;
}

- (void)setBorderColor:(NSColor *)aColor;
- (NSColor *)borderColor;

@end
