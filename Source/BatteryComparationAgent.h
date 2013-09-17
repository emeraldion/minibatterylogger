//
//  BatteryComparationAgent.h
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>
#import "Battery.h"
#import "DifferentialBattery.h"
#import "NSData+MBLUtils.h"
#import "MBLStarsView.h"
#import "CPSystemInformation.h"

@class AppController, MBLWearView;

extern NSString *MBLHumanMachineModelKey;
extern NSString *MBLBatteryPurchaseDateKey;

/*!
 @class BatteryComparationAgent
 @abstract Objects of class <tt>BatteryComparationAgent</tt> are responsible for
 performing comparations between battery instances, often querying the Shared Battery
 Data Archive as part of the task.
 */
@interface BatteryComparationAgent : NSObject <NSURLHandleClient> {

	IBOutlet NSObjectController *batteryController;
	IBOutlet NSObjectController *worstBatteryController;
	IBOutlet NSObjectController *bestBatteryController;
	IBOutlet NSObjectController *averageBatteryController;
	IBOutlet NSObjectController *differentialBatteryController;
	
	IBOutlet NSArrayController *managerController;

	/* Comparison tab */
	IBOutlet NSPopUpButton *machineChooser;
	IBOutlet NSBox *hostNameBox;
	IBOutlet NSTextField *hostNameLabel;

	//IBOutlet NSTextField *modelLabel;
	IBOutlet NSTextField *batteryManufacturedLabel;
	IBOutlet NSTextField *batteryManufactureDateLabel;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *ownMachineCountLabel;
	IBOutlet NSTextField *ownModelCountLabel;
	
	/* Diagnostics sheet */
	IBOutlet NSImageView *batteryIcon;

	IBOutlet NSTextField *batteryDeathLabel;
	IBOutlet NSTextField *remainingLifeLabel;

	IBOutlet NSTextField *overallLabel;
	IBOutlet NSTextField *capacityLabel;
	IBOutlet NSTextField *cyclesLabel;
	IBOutlet NSTextField *ageLabel;
	
	IBOutlet NSTextField *remarksField;
	
	IBOutlet MBLStarsView *overallSView;
	IBOutlet MBLStarsView *ageSView;
	IBOutlet MBLStarsView *capacitySView;
	IBOutlet MBLStarsView *cycleSView;
	
	IBOutlet MBLWearView *wearView;
	IBOutlet AppController *appController;
	IBOutlet NSTableView *managersList;

	CURLHandle *mURLHandle;
	int mBytesRetrievedSoFar;
	int mOperationMode;
	
	NSString *machineType;
	NSString *machineModel;
	NSString *computerSerialNumber;
	NSString *computerName;
	NSString *batteryModel;
	NSCalendarDate *batteryDate;

	NSDictionary *batteryPartNumbers;
	
	int allCount;
	int ownMachineCount;
	int ownModelCount;
}

- (void)setBatteryPartNumbers:(NSDictionary *)dict;

- (void)setMachineType:(NSString *)type;
- (void)setMachineModel:(NSString *)model;
- (void)setComputerName:(NSString *)name;
- (void)setComputerSerialNumber:(NSString *)num;
- (void)setBatteryDate:(NSCalendarDate *)date;
- (void)setBatteryModel:(NSString *)model;

- (void)setOwnModelCount:(int)count;
- (void)setOwnMachineCount:(int)count;
- (void)setAllCount:(int)count;

/*!
 @method ownMachineCount
 @abstract Returns the number of batteries of the same machine kind of the user's computer that are present in the Archive.
 @result The number of batteries of the same machine kind of the user's computer that are present in the Archive.
 @deprecated This method is deprecated. Methods that query battery model and manufacturer should be used instead.
 */
- (int)ownMachineCount;

/*!
 @method ownModelCount
 @abstract Returns the number of batteries of the same laptop model of the user's computer that are present in the Archive.
 @result The number of batteries of the same laptop model of the user's computer that are present in the Archive.
 @deprecated This method is deprecated. Methods that query battery model and manufacturer should be used instead.
 */
- (int)ownModelCount;

/*!
 @method allCount
 @abstract Returns the total number of batteries that are present in the Archive.
 @result The total number of batteries that are present in the Archive.
 */
- (int)allCount;

- (void)setURLHandle:(CURLHandle *)handle;

- (IBAction)chooseExactMachineType:(id)sender;
- (IBAction)updateBatteryDate:(id)sender;
- (IBAction)shareBatteryData:(id)sender;
- (IBAction)getSharedBatteryData:(id)sender;
- (IBAction)gotoSharedBatteryDataArchive:(id)sender;

- (IBAction)prepareDiagnostics:(id)sender;

@end