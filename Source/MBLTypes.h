//
//  MBLTypes.h
//  MiniBatteryLogger
//
//  Created by delphine on 19-08-2007.
//  Copyright 2006-2008 Claudio Procida. All rights reserved.
//

/*!
 @enum MBLAlertMode
 @abstract Defines the possible alert modes used by the application.
 */
typedef enum {
	MBLAlertModeNone = 0,
	MBLAlertModeGrowl,
	MBLAlertModeSpeech
} MBLAlertMode;

/*!
 @enum MBLStatusItemMode
 @abstract Defines the possible visualization modes used in the status item.
 */
typedef enum {
	MBLStatusItemPlain = 0,
	MBLStatusItemCharge,
	MBLStatusItemTime,
	MBLStatusItemAll,
	MBLStatusItemBatteryTimer
} MBLStatusItemMode;
