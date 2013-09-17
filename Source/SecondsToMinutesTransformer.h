//
//  SecondsToMinutesTransformer.h
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @enum MBLSecondsToMinutesTransformerMode
 @abstract Defines the formatting mode of the value transformer.
 */
typedef enum {
	MBLSecondsToMinutesTransformerNaturalLanguageMode = 1,
	MBLSecondsToMinutesTransformerCompactMode,
	MBLSecondsToMinutesTransformerInfinityMode
} MBLSecondsToMinutesTransformerMode;

/*!
 @class SecondsToMinutesTransformer
 @abstract Objects of class <tt>SecondsToMinutesTransformer</tt> transform seconds to
 formatted minutes & hours.
 */
@interface SecondsToMinutesTransformer : NSValueTransformer {
	/*!
	 @var mode
	 @abstract Determines the formatting mode of this instance.
	 */
	MBLSecondsToMinutesTransformerMode mode;
}

/*!
 @method initWithMode:
 @abstract Initializes the receiver with the desired formatting mode.
 @param mode The formatting mode.
 @result The receiver.
 */
- (id)initWithMode:(MBLSecondsToMinutesTransformerMode)mode;

/*!
 @method mode
 @abstract Returns the formatting mode.
 @result The formatting mode.
 */
- (MBLSecondsToMinutesTransformerMode)mode;

/*!
 @method setMode:
 @abstract Sets the receiver's formatting mode.
 @param mode The formatting mode.
 */
- (void)setMode:(MBLSecondsToMinutesTransformerMode)mode;

@end
