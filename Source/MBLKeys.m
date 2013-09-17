//
//  MBLKeys.m
//  MiniBatteryLogger
//
//  Created by delphine on 26-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLTypes.h"

#pragma mark === Server Configuration ===

int MBLRemoteBatteryMonitoringPort						= 4153;
NSString *MBLRemoteBatteryMonitoringServiceType			= @"_mbl-battd._tcp.";

#pragma mark === Shared Strings ===

// Preferences keys
NSString *MBLProbeIntervalKey							= @"MBLProbeInterval";
NSString *MBLDisplayCustomIconKey						= @"MBLDisplayCustomIcon";
NSString *MBLSaveSessionOnQuitKey						= @"MBLSaveSessionOnQuit";
NSString *MBLAutoSaveSessionsKey						= @"MBLAutoSaveSessions";
NSString *MBLHideDockIconKey							= @"MBLHideDockIcon";
NSString *MBLShowDesktopBatteryKey						= @"MBLShowDesktopBattery";
NSString *MBLStartMonitoringAtLaunchKey					= @"MBLStartMonitoringAtLaunch";
NSString *MBLLastLocalBatteryIndexKey					= @"MBLLastLocalBatteryIndex";

NSString *LSUIElementKey								= @"LSUIElement";

NSString *MBLExportFolderKey							= @"MBLExportFolder";
NSString *MBLPlaySoundsKey								= @"MBLPlaySounds";

NSString *MBLLowAlertLevelKey							= @"MBLLowAlertLevel";
NSString *MBLDyingAlertLevelKey							= @"MBLDyingAlertLevel";
NSString *MBLAlertModeKey								= @"MBLAlertUsing";

NSString *MBLSendOwnDataKey								= @"MBLSendOwnData";
NSString *MBLRetrieveDataKey							= @"MBLRetrieveData";
NSString *MBLDisplayStatusItemKey						= @"MBLDisplayStatusItem";
NSString *MBLStatusItemModeKey							= @"MBLStatusItemMode";
NSString *MBLStatusItemHideTimeWhenPossibleKey			= @"MBLStatusHideTimeWhenPossible";

NSString *MBLDebugModeKey								= @"MBLDebugMode";

NSString *MBLShareOwnDataKey							= @"MBLShareOwnData";
NSString *MBLLookForSharedDataKey						= @"MBLLookForSharedData";
NSString *MBLShareWithPasswordKey						= @"MBLShareWithPassword";
NSString *MBLAdvertiseServiceKey						= @"MBLAdvertiseService";
NSString *MBLSharingPasswordKey							= @"MBLSharingPassword";

NSString *MBLShareOwnDataChangedNotification			= @"MBLShareOwnDataChanged";
NSString *MBLLookForSharedDataChangedNotification		= @"MBLLookForSharedDataChanged";
NSString *MBLAdvertiseServiceChangedNotification		= @"MBLAdvertiseServiceChanged";

// Notification names
NSString *MBLProbeIntervalChangedNotification			= @"MBLProbeIntervalChanged";
NSString *MBLDisplayCustomIconChangedNotification		= @"MBLDisplayCustomIconChanged";
NSString *MBLDisplayStatusItemChangedNotification		= @"MBLDisplayStatusItemChanged";