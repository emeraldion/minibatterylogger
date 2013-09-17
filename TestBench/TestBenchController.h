//
//  TestBenchController.h
//  MiniBatteryLogger
//
//  Created by delphine on 25-01-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PowerDefines.h"
#import "RemoteBatteryManager.h"

@interface TestBenchController : NSObject {

	CFRunLoopSourceRef runLoopSource;
	SCDynamicStoreRef dynamicStore;
	BOOL test1Running;
	NSNetServiceBrowser *serviceBrowser;
	RemoteBatteryManager *batteryManager;

	IBOutlet NSWindow *window;
	IBOutlet NSTextView *infoOutput;
	IBOutlet NSProgressIndicator *infoProgress;
	
	/* Mac Intel test */
	IBOutlet NSTextView *intelOutput;
	IBOutlet NSTextView *ppcOutput;
}

- (IBAction)sendResultsByMail:(id)sender;

- (IBAction)startInfoTest:(id)sender;
- (IBAction)stopInfoTest:(id)sender;

- (IBAction)performCopyBatteryInfoTest:(id)sender;
- (IBAction)performIOPSCopyPowerSourcesInfoTest:(id)sender;

- (IBAction)startIOPSNotificationCreateRunLoopSourceTest:(id)sender;
- (IBAction)stopIOPSNotificationCreateRunLoopSourceTest:(id)sender;

- (void)appendOutput:(id)obj description:(NSString *)desc;

- (IBAction)startTestSuite:(id)sender;

- (IBAction)performMacPPCTest:(id)sender;
- (IBAction)performMacIntelTest:(id)sender;

void powerSourceCallback(void *context);

void _storeCallBack( SCDynamicStoreRef    store,
					CFArrayRef changedKeys,
					void *info);

@end
