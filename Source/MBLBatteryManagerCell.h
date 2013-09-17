//
//  MBLBatteryManagerCell.h
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//	Inspired by class TitledImageCell by L.Sansonetti
//

#import <Cocoa/Cocoa.h>


@interface MBLBatteryManagerCell : NSTextFieldCell {
	
    NSString *_title;
    NSString *_details;
}

@end
