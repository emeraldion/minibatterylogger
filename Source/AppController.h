//
//  AppController.h
//  MiniBatteryLogger
//
//  Created by delphine on 26-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import <Growl/Growl.h>
#import <ELToolkitFramework/ElToolkit.h>
#import <RBSplitView/RBSplitView.h>
#import "PowerDefines.h"
#import "CPChartView.h"
#import "BatteryLogger.h"
#import "BatteryEvent.h"
#import "BatterySnapshots.h"
#import "WakeUpEvent.h"
#import "SleepEvent.h"
#import "Battery.h"
#import "LogArrayController.h"
#import "NSImage+MBLUtils.h"
#import "SecondsToMinutesTransformer.h"
#import "StatusLedValueTransformer.h"
#import "GeneralPreferencePane.h"
#import "AboutController.h"
#import "RecallController.h"
#import "NSData+MBLUtils.h"
#import "NSString+MBLUtils.h"
#import "MonitoringSession.h"
#import "BatteryComparationAgent.h"
#import "BatteryManager.h"
#import "LocalBatteryManager.h"
#import "DemoBatteryManager.h"
#import "MBLSharingService.h"
#import "PreferenceController.h"
#import "DesktopBatteryController.h"
#import "MBLStatusItem.h"
#import "MBLBatteryManagersTableView.h"

extern NSString *MBLProbeIntervalKey;
extern NSString *MBLDisplayCustomIconKey;
extern NSString *MBLSaveSessionOnQuitKey;
extern NSString *MBLAutoSaveSessionsKey;
extern NSString *MBLStartMonitoringAtLaunchKey;
extern NSString *MBLHideDockIconKey;
extern NSString *MBLShowDesktopBatteryKey;
extern NSString *MBLLastLocalBatteryIndexKey;

extern NSString *LSUIElementKey;

extern NSString *MBLExportFolderKey;
extern NSString *MBLPlaySoundsKey;

extern NSString *MBLLowAlertLevelKey;
extern NSString *MBLDyingAlertLevelKey;
extern NSString *MBLAlertModeKey;

extern NSString *MBLSendOwnDataKey;
extern NSString *MBLRetrieveDataKey;
extern NSString *MBLDisplayStatusItemKey;
extern NSString *MBLStatusItemModeKey;
extern NSString *MBLStatusItemHideTimeWhenPossibleKey;

extern NSString *MBLDebugModeKey;

extern NSString *MBLShareOwnDataKey;
extern NSString *MBLLookForSharedDataKey;
extern NSString *MBLShareWithPasswordKey;
extern NSString *MBLAdvertiseServiceKey;
extern NSString *MBLSharingPasswordKey;

extern NSString *MBLShareOwnDataChangedNotification;
extern NSString *MBLLookForSharedDataChangedNotification;
extern NSString *MBLAdvertiseServiceChangedNotification;

extern NSString *MBLProbeIntervalChangedNotification;
extern NSString *MBLDisplayCustomIconChangedNotification;
extern NSString *MBLDisplayStatusItemChangedNotification;

extern NSString *MBLChartBackgroundColorChangedNotification;
extern NSString *MBLChartChargingColorChangedNotification;
extern NSString *MBLChartPluggedColorChangedNotification;
extern NSString *MBLChartUnpluggedColorChangedNotification;
extern NSString *MBLChartScaleColorChangedNotification;
extern NSString *MBLUpdateIntervalChangedNotification;

extern NSString *MBLTableViewMouseExitedNotification;

extern NSString *MBLDefaultsRegisteredUserKey;
extern NSString *MBLDefaultsRegistrationKeyKey;

extern NSString *MBLBatteryManagerRemoteConnectionErrorNotification;

@class AMPreferenceWindowController;
@class Battery;
@class AboutController;
@class BatteryComparationAgent;
@class BatteryStatusView;
@class MBLLicense;
@class RemoteConnectionController;
@class SessionPreviewController;

@protocol MBLSharingMaster

- (oneway void)setSharingService:(id)theService;

@end

/*!
 @class AppController
 @abstract Main application controller for MiniBatteryLogger.
 @discussion AppController is the class of the main controller object that manages the behavior of the MiniBatteryLogger application.
 It is responsible for attaching battery managers, updating the charts and information panes and much more.
 It implements GrowlApplicationBridgeDelegate protocol to issue Growl notifications in response to particular power events.
 */
@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {

	IBOutlet CPChartView *chartView;
	IBOutlet BatteryStatusView *statusView;
	IBOutlet NSWindow *window;

	/* Diagnostics sheet */
	IBOutlet NSWindow *diagnosticsSheet;
	
	IBOutlet NSTabView *tabView;
	IBOutlet NSTextView *logView;
	IBOutlet NSPanel *detailsPanel;

	IBOutlet NSTableView *snapshotsView;
	IBOutlet NSTableView *sessionsView;

	IBOutlet LogArrayController *logController;
	IBOutlet NSArrayController *snapshotsController;
	IBOutlet NSArrayController *sessionsController;
	IBOutlet NSArrayController *managerController;
	IBOutlet NSObjectController *batteryController;
	
	IBOutlet MBLBatteryManagersTableView *managersList;

	/* Split views */
	IBOutlet NSSplitView *statsSplitView;
	IBOutlet RBSplitView *sidebarSplitView;
	IBOutlet RBSplitSubview *sidebar;
	IBOutlet RBSplitView *batteryStatusSplitView;

	IBOutlet NSButton *batteryStatusToggler;
	IBOutlet NSView *dragView;
	
	IBOutlet BatteryComparationAgent *comparationAgent;
	IBOutlet NSDrawer *sessionsDrawer;
	IBOutlet NSPanel *balloon;
	
	/* View Selectors */
	IBOutlet NSMenuItem *chartViewItem;
	IBOutlet NSMenuItem *statsViewItem;
	IBOutlet NSMenuItem *compViewItem;
	IBOutlet NSMenuItem *logViewItem;	
	
	/* Status Menu */
	IBOutlet NSMenuItem *powerStateItem;
	IBOutlet NSMenuItem *chargeAmountItem;
	IBOutlet NSMenuItem *hideTimeItem;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *iconOnlyItem;
	IBOutlet NSMenuItem *timeItem;
	IBOutlet NSMenuItem *chargeItem;
	IBOutlet NSMenuItem *timeChargeItem;
	IBOutlet NSMenuItem *batteryTimerItem;
	IBOutlet NSMenuItem *auxQuitMenuItem;
	IBOutlet NSMenuItem *auxHelpMenuItem;
	IBOutlet NSMenuItem *auxPreferencesMenuItem;
	IBOutlet NSMenuItem *auxSeparatorMenuItem;

	MBLStatusItem *statusItem;
	BOOL displayStatusItem;
	NSArray *statusMenuItems;
	NSArray *auxStatusMenuItems;
	
	NSSpeechSynthesizer *speechSynth;
	
	int localBatteries;
	/* This array holds the current (open) sessions */
	NSMutableArray *currentSessions;

	/* This array holds the registered battery managers */
	NSMutableArray *batteryManagers;

	PreferenceController *preferenceController;
	AboutController *aboutController;
	RecallController *recallController;
	DesktopBatteryController *desktopBatteryController;
	RemoteConnectionController *remoteConnectionController;
	SessionPreviewController *sessionPreviewController;
	
	NSDictionary *dictionaryForGrowl;

	NSArray *helpAnchors;

	/* Weak references */
	NSSegmentedControl *viewSwitcher;
	NSSegmentedControl *zoomControl;
	NSSegmentedControl *shiftControl;
	
	BatteryLogger *logger;

	NSToolbar *toolbar;
	NSToolbarItem *stopResumeItem;

	BatterySnapshots *snapshots;
	
	int charge;
	int maxCapacity;
	BOOL plugged;
	BOOL charging;
	BatteryManager *batteryManager;
	Battery *battery;
	
	NSNetServiceBrowser *serviceBrowser;
	NSMutableDictionary *remoteServices;
	NSMutableDictionary *loadedSessions;
	
	MBLSharingService *sharingService;
	MBLLicense *_license;
}

/*!
 @method sharedController
 @abstract Returns the one and only application controller instance.
 */
+ (id)sharedController;

/* Dock icon management */

/*!
 @method setHidesDockIcon:
 @abstract Sets whether the application should have a Dock icon or not.
 @discussion This method manipulates the application's Info property list file in order to
 set it as a LSUIElement if required. Every call to this function will require an application
 restart in order to be effective.
 @param yorn <tt>YES</tt> to hide the application's Dock icon, <tt>NO</tt> to show it.
 @result <tt>YES</tt> when the change has been successful, <tt>NO</tt> otherwise.
 */
+ (BOOL)setHidesDockIcon:(BOOL)yorn;

/*!
 @method checkDockIcon
 @abstract Checks that the application's Info property list reflects current Dock visibility settings.
 */
+ (void)checkDockIcon;

/*!
 @method applicationName
 @abstract Returns the name of the running application with version number.
 */
+ (NSString *)applicationName;

/*!
 @method applicationVersion
 @abstract Returns the version of the running application.
 */
+ (NSString *)applicationVersion;

/* Desktop battery window management */

- (void)showDesktopBatteryWindow;
- (void)hideDesktopBatteryWindow;

- (void)handleSleepWakeShutdown:(NSNotification *)note;
- (void)handleDisplayCustomIconChange:(NSNotification *)note;
- (void)handleDisplayStatusItemChange:(NSNotification *)note;

#pragma mark === Accessors ===

- (NSString *)registeredUser;
- (BOOL)isRegistered;
- (void)setLicense:(MBLLicense *)license;
- (Battery *)battery;
- (BatteryManager *)batteryManager;

#pragma mark === Actions ===

/* View Togglers */
- (IBAction)switchView:(id)sender;
- (IBAction)switchToView:(id)sender;
- (IBAction)toggleSidebar:(id)sender;
- (IBAction)toggleBatteryStatus:(id)sender;
- (IBAction)toggleSessionsBrowser:(id)sender;

/* Windows management */
- (IBAction)showWindow:(id)sender;
- (IBAction)showPreferenceWindow:(id)sender;
- (IBAction)showRegistrationPane:(id)sender;
- (IBAction)showAboutPanel:(id)sender;
- (IBAction)showBatteryRecallAssistant:(id)sender;
- (IBAction)showBatteryDetails:(id)sender;
- (IBAction)dismissDiagnosticsSheet:(id)sender;

/* Chart controls */
- (IBAction)zoomChartInOut:(id)sender;
- (IBAction)shiftChartLeftRight:(id)sender;

/* Snapshots management */
- (IBAction)addSnapshot:(id)sender;

/* Help menu commands */
- (IBAction)sendFeedback:(id)sender;
- (IBAction)onlineHelp:(id)sender;

/* Sessions */

- (IBAction)showSession:(id)sender;
- (IBAction)showCurrentSession:(id)sender;
- (IBAction)saveSessions:(id)sender;
- (IBAction)removeSession:(id)sender;

/*!
 @method removeAllSavedSessions:
 @abstract Removes all saved sessions regardlessly.
 */
- (IBAction)removeAllSavedSessions:(id)sender;

/*!
 @method removeZeroLengthSessions:
 @abstract Removes all sessions whose duration is zero.
 */
- (IBAction)removeZeroDurationSessions:(id)sender;

/*!
 @method newSession:
 @abstract Creates a new active monitoring session for the current battery.
 */
- (IBAction)newSession:(id)sender;

- (void)loadSessions:(id)manager;
- (void)unloadSessions;

- (IBAction)openLogInConsole:(id)sender;
- (IBAction)stopResumeMonitoring:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)resetOnBatteryTimer:(id)sender;

- (IBAction)openEnergySaver:(id)sender;

/*!
 @method inspectChart:
 @abstract Causes the inspector to show and forces the chart to higlight a selection.
 */
- (IBAction)inspectChart:(id)sender;

/*!
 @method diagnoseBattery:
 @abstract Shows the Diagnostics sheet.
 */
- (IBAction)diagnoseBattery:(id)sender;

/* Web links */
- (IBAction)goToEmeLodge:(id)sender;
- (IBAction)goToWebsite:(id)sender;
- (IBAction)goToGGroup:(id)sender;

/* Status item handling */
- (IBAction)changeStatusItemMode:(id)sender;
- (IBAction)changeStatusItemTimeDisplay:(id)sender;

/* Data import/export */
- (IBAction)exportDataToCSV:(id)sender;
- (IBAction)exportDataToCSVMSExcel:(id)sender;

@end

/*!
 @category SharedBatteryDataArchive
 @abstract Methods that leverage functionality offered by Shared Battery Data Archive web services.
 */
@interface AppController (SharedBatteryDataArchive)

/*!
 @method archiveEntryPage:
 @abstract Launches the default web browser to the archive page for current battery.
 */
- (IBAction)archiveEntryPage:(id)sender;

@end

/*!
 @category RemoteMonitoring
 @abstract Methods for remote battery monitoring management.
 */
@interface AppController (RemoteMonitoring)

/*!
 @method disconnectManager:
 @abstract Detaches currently selected remote battery manager.
 @param sender The sender of the action.
 */
- (IBAction)disconnectManager:(id)sender;

/*!
 @method disconnectAllManagers:
 @abstract Detaches all remote battery managers.
 @param sender The sender of the action.
 */
- (IBAction)disconnectAllManagers:(id)sender;

/*!
 @method connectManager:
 @abstract Attaches a new remote battery manager.
 @discussion This method brings up a dialog to choose a favorite remote battery manager
 or enter a new one by its address.
 @param sender The sender of the action.
 */
- (IBAction)connectManager:(id)sender;

/*!
 @method connectToAddress:
 @abstract Connects a remote battery manager known its IP address.
 @param address The IP address of the remote manager.
 */
- (void)connectToAddress:(NSString *)address;

@end