//
//  MBLEvent.h
//  MiniBatteryLogger
//
//  Created by delphine on 7-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *MBLEventType;

/*!
 @class MBLEvent
 @abstract Abstract superclass of all power events.
 @discussion Subclasses of <tt>MBLEvent</tt> represent power events generated
 on the running system.
 */
@interface MBLEvent : NSObject <NSCoding> {

	NSCalendarDate *date;
}

/*!
 @method type
 @abstract Returns a string description of this event type.
 @result A string description of this event type.
 */
- (NSString *)type;

/*!
 @method date
 @abstract Returns the date in which the receiver was generated.
 @result The date in which the receiver was generated.
 */
- (NSCalendarDate *)date;

/*!
 @method setDate:
 @abstract Sets the date in which the receiver was generated.
 @param date The date in which the receiver was generated.
 */
- (void)setDate:(NSCalendarDate *)date;

@end

/*!
 @category CSVExporting
 @abstract Adds convenience methods useful for CSV data exporting.
 */
@interface MBLEvent (CSVExporting)

/*!
 @method CSVHeader
 @abstract Returns a CSV header for a list of <tt>MBLEvent</tt> objects.
 @result A CSV header for a list of <tt>MBLEvent</tt> objects.
 */
+ (NSString *)CSVHeader;

/*!
 @method CSVHeaderMSExcel
 @abstract Returns a CSV header for a list of <tt>MBLEvent</tt> objects suitable for MS Excel.
 @result A CSV header for a list of <tt>MBLEvent</tt> objects suitable for MS Excel.
 */
+ (NSString *)CSVHeaderMSExcel;

/*!
 @method CSVHeaderUsingSeparator:
 @abstract Returns a CSV header for a list of <tt>MBLEvent</tt> objects with a custom separator.
 @param sep A custom separator.
 @result A CSV header for a list of <tt>MBLEvent</tt> objects with a custom separator.
 */
+ (NSString *)CSVHeaderUsingSeparator:(NSString *)sep;

/*!
 @method CSVLine
 @abstract Returns a CSV representation of the receiver.
 @result A CSV representation of the receiver.
 */
- (NSString *)CSVLine;

/*!
 @method CSVLineMSExcel
 @abstract Returns a CSV representation of the receiver suitable for MS Excel.
 @result A CSV representation of the receiver suitable for MS Excel.
 */
- (NSString *)CSVLineMSExcel;

/*!
 @method CSVLineUsingSeparator:
 @abstract Returns a CSV representation of the receiver with a custom separator.
 @param sep A custom separator.
 @result A CSV representation of the receiver with a custom separator.
 */
- (NSString *)CSVLineUsingSeparator:(NSString *)sep;

@end
