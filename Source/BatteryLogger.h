//
//  BatteryLogger.h
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatteryEvent.h"

/*!
 @class BatteryLogger
 @abstract Manager for the log file of power events.
 @discussion The BatteryLogger is responsible of storing, managing and writing to file the log
 of power events generated during the life cycle of the application.
 */
@interface BatteryLogger : NSObject {

	NSFileHandle *logFile;
}

/*!
 @method logPath
 @abstract Returns the path of the log file.
 @result The path of the log file.
*/
+ (NSString *)logPath;

/*!
 @method logFolderPath
 @abstract Returns the path of the folder which holds log files.
 @result The path of the folder which holds log files.
 */
+ (NSString *)logFolderPath;

/*!
 @method clearLog
 @abstract Clears the log file.
 @discussion This method is currently not implemented.
 */
- (void)clearLog;

/*!
 @method rotateLogs
 @abstract Rotates log files, i.e. compresses and archives old logs.
 */
+ (void)rotateLogs;

/*!
 @method logEvent:
 @abstract Logs the given event.
 @discussion Calling this method will cause a line containing a string representation
 of <tt>event</tt> to be appended to the log file.
 @param event The event to log.
 */
- (void)logEvent:(BatteryEvent *)event;

/*!
 @method logText:
 @abstract Logs the given text.
 @discussion Calling this method will cause a line containing <tt>txt</tt> to be appended
 to the log file.
 @param txt The text to log.
 */
- (void)logText:(NSString *)txt;

@end
