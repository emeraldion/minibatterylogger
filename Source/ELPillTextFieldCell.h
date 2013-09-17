//
//  ELPillTextFieldCell.h
//  ELPillTextField
//
//  Created by delphine on 25-03-2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ELPillTextFieldCell : NSTextFieldCell {

	NSString *_title;
}

- (NSSize)optimalSize;

@end
