//
//  AboutController.h
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CFBundle.h>
#import <ELToolkitFramework/ELFlatGradientView.h>

/*!
 @class AboutController
 @abstract Window controller for the About window.
 */
@interface AboutController : NSWindowController {

	/*!
	 @var appName
	 @abstract Text field for the name of the application.
	 */
	IBOutlet NSTextField *appName;

	/*!
	 @var copyright
	 @abstract Text field for the copyright info.
	 */
	IBOutlet NSTextField *copyright;
	
	/*!
	 @var appVersion
	 @abstract Text field for the version number of the application.
	 */
	IBOutlet NSTextField *appVersion;
	
	/*!
	 @var credits
	 @abstract Text field for the credits informations.
	 */
	IBOutlet NSTextView *credits;
	
}

@end
