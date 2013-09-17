//
//  MBLPreferencePane.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AMPreferencePane/AMPreferencePane.h>

@interface MBLPreferencePane : NSObject <AMPrefPaneProtocol> {
	
	IBOutlet NSView *mainView;

	NSString *identifier;
	NSString *label;
	NSString *category;
	NSImage *icon;	
}

- (IBAction)onlineHelp:(id)sender;

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory;

- (void)setIdentifier:(NSString *)str;
- (NSString *)identifier;
- (void)setLabel:(NSString *)str;
- (NSString *)label;
- (void)setIcon:(NSImage *)ico;
- (NSImage *)icon;
- (void)setCategory:(NSString *)str;
- (NSString *)category;

- (NSView *)mainView;
/* Called when the Nib file has been loaded. Useful for setup of the GUI */
- (void)mainViewDidLoad;


@end
