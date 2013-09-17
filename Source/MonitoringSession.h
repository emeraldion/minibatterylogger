//
//  MonitoringSession.h
//  MiniBatteryLogger
//
//  Created by delphine on 5-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLEvent.h"
#import "NSFileManager+MBLUtils.h"

/*!
 @class MonitoringSession
 @abstract Represents a monitoring session, i.e. a container for power events.
 @discussion This class contains a "session", that is the collection of events
 that are collected during a monitoring session.

 A session is attributed with its date of start, the duration and an optional user comment.

 Since these attributes are derived from the content, the designed initializer can safely
 require only the content array as parameter.
 */
@interface MonitoringSession : NSObject <NSCoding> {

	NSMutableArray *events;
	NSString *comment;
	NSString *summary;
	NSCalendarDate *date;
	NSTimeInterval duration;
	BOOL active;
	BOOL modified;
}

/*!
 @method initWithEvents:
 @abstract Initializes the receiver with an array of events.
 @param arr An array of events.
 @result This method returns the receiver.
 */
- (id)initWithEvents:(NSArray *)arr;

/*!
 @method session
 @abstract Returns an autoreleased <tt>MonitoringSession</tt> object.
 @result An autoreleased <tt>MonitoringSession</tt> object.
 */
+ (MonitoringSession *)session;

#pragma mark === Loading sessions ===
/*!
 @method loadSessionsForIndex:
 @abstract Loads from disk and returns an array of sessions for the battery
 positioned at <tt>index</tt>.
 @discussion This method is deprecated and is maintained only for retrocompatibility
 with existing saved sessions, mainly to load and move them to a new location.
 @param index The position of the battery in the system's battery list.
 @result An array of sessions for the battery positioned at <tt>index</tt>.
 @deprecated This method is deprecated since version 1.7
 @seealso loadSessionsForBattery:atIndex:
 */
+ (NSArray *)loadSessionsForIndex:(int)index;

/*!
 @method loadSessionsPre1_5ForIndex:
 @abstract Loads from disk and returns an array of sessions for the battery
 positioned at <tt>index</tt>.
 @discussion This method is deprecated and is maintained only for retrocompatibility
 with existing saved sessions, mainly to load and move them to a new location.
 @param index The position of the battery in the system's battery list.
 @result An array of sessions for the battery positioned at <tt>index</tt>.
 @deprecated This method is deprecated since version 1.5
 @seealso loadSessionsForBattery:atIndex:
 */
+ (NSArray *)loadSessionsPre1_5ForIndex:(int)index;

/*!
 @method loadSessionsForBattery:atIndex:
 @abstract Loads from disk and returns an array of sessions for the battery
 with unique id <tt>name</tt> installed at position <tt>index</tt>.
 positioned at <tt>index</tt>.
 @discussion This method is the recommended way to load saved monitoring sessions.
 @param name The unique id of the battery.
 @param index The position of the battery in the system's battery list.
 @result An array of sessions for the battery positioned at <tt>index</tt>.
 */
+ (NSArray *)loadSessionsForBattery:(NSString *)name atIndex:(int)index;


#pragma mark === Saving sessions ===
+ (void)saveToFileSessions:(NSArray *)arr forBattery:(NSString *)name atIndex:(int)index;
+ (void)saveToFileSessions:(NSArray *)arr forBattery:(NSString *)name atIndex:(int)index removeMissing:(BOOL)remove;
+ (void)saveToFileSessions:(NSArray *)arr forIndex:(int)index;
+ (void)saveToFileSession:(MonitoringSession *)sess forIndex:(int)index;
+ (void)saveToFilePre1_5Sessions:(NSArray *)arr forIndex:(int)index;

#pragma mark === Deleting sessions ===
/*!
 @method deleteFromDiskSession:forBattery:atIndex:
 @abstract Removes saved sessions from disk.
 @discussion This method performs the removal of the session <tt>session</tt> for 
 the battery <tt>name</tt> positioned at <tt>index</tt>.
 @param session The session to remove.
 @param name The unique id of the battery.
 @param index The position of the battery.
 */
+ (void)deleteFromDiskSession:(MonitoringSession *)session forBattery:(NSString *)name atIndex:(int)index;

#pragma mark === Probing sessions ===
/*!
 @method existPre1_5Sessions
 @abstract Verifies the existence of pre 1.5 sessions on disk.
 @discussion This method is maintained only for retrocompatibility and should not be normally used.
 @deprecated This method has been deprecated since version 1.5.
 @seealso existPre1_7Sessions
 */
+ (BOOL)existPre1_5Sessions;

/*!
 @method existPre1_7Sessions
 @abstract Verifies the existence of pre 1.7 sessions on disk.
 @discussion This method is maintained only for retrocompatibility and should not be normally used.
 @deprecated This method has been deprecated since version 1.7.
 @seealso existPre1_5Sessions
 */
+ (BOOL)existPre1_7Sessions;

#pragma mark === Session files management ===

+ (NSString *)filePathForIndex:(int)index;
+ (NSString *)folderPath;


#pragma mark -
#pragma mark === Accessors ===

- (BOOL)isActive;
- (void)setActive:(BOOL)flag;

- (BOOL)isModified;
- (void)setModified:(BOOL)flag;

- (NSString *)comment;
- (void)setComment:(NSString *)str;

- (NSCalendarDate *)date;
- (void)setDate:(NSCalendarDate *)d;

/*!
 @method duration
 @abstract Returns the total duration of the monitoring session.
 @discussion The total duration of a session is the time elapsed between the first and
 last events of the session.
 @result The total duration of the monitoring session.
 */
- (NSTimeInterval)duration;

- (NSArray *)events;
- (void)setEvents:(NSArray *)arr;

- (NSString *)summary;
- (void)setSummary:(NSString *)str;

- (void)addEvent:(MBLEvent *)event;

- (NSImage *)statusImage;

@end
