//
//  RemoteConnectionController.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @class RemoteConnectionController
 @abstract <tt>NSWindowController</tt> subclass responsible of managing remote battery connections,
 favorite remote batteries and authentication requests.
 */
@interface RemoteConnectionController : NSWindowController {
@private
	IBOutlet NSTextField *remoteAddressField;
	IBOutlet NSArrayController *favoritesController;
	IBOutlet NSTableView *favoritesList;
	
	IBOutlet NSTextField *authorizationLabel;
	IBOutlet NSWindow *authorizationSheet;
	IBOutlet NSSecureTextField *passwordField;
	IBOutlet NSButton *rememberCheckbox;
	
	/* Weak reference */
	id owner;
}

+ (NSArray *)startupConnectionAddresses;
- (void)setOwner:(id)owner;
- (NSMutableArray *)loadFavorites;
- (void)saveFavorites:(NSNotification *)notif;
- (IBAction)addToFavorites:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)enterPassword:(id)sender;
- (IBAction)dismissPasswordRequest:(id)sender;

@end
