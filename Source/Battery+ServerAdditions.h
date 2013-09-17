//
//  Battery+ServerAdditions.h
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Battery.h"

/*!
 @const kMBLCapacityHeaderKey
 @abstract Key for the capacity response header.
 */
extern const NSString *kMBLCapacityHeaderKey;

/*!
 @const kMBLMaxCapacityHeaderKey
 @abstract Key for the maximum capacity response header.
 */
extern const NSString *kMBLMaxCapacityHeaderKey;

/*!
 @const kMBLDesignCapacityHeaderKey
 @abstract Key for the design capacity response header.
 */
extern const NSString *kMBLDesignCapacityHeaderKey;

/*!
 @const kMBLCycleCountHeaderKey
 @abstract Key for the cycle count response header.
 */
extern const NSString *kMBLCycleCountHeaderKey;

/*!
 @const kMBLChargeHeaderKey
 @abstract Key for the charge response header.
 */
extern const NSString *kMBLChargeHeaderKey;

/*!
 @const kMBLTimeToEmptyHeaderKey
 @abstract Key for the time to empty response header.
 */
extern const NSString *kMBLTimeToEmptyHeaderKey;

/*!
 @const kMBLTimeToFullHeaderKey
 @abstract Key for the time to full response header.
 */
extern const NSString *kMBLTimeToFullHeaderKey;

/*!
 @const kMBLInstalledHeaderKey
 @abstract Key for the installed status response header.
 */
extern const NSString *kMBLInstalledHeaderKey;

/*!
 @const kMBLChargingHeaderKey
 @abstract Key for the charging status response header.
 */
extern const NSString *kMBLChargingHeaderKey;

/*!
 @const kMBLPluggedHeaderKey
 @abstract Key for the plugged status response header.
 */
extern const NSString *kMBLPluggedHeaderKey;

/*!
 @const kMBLAmperageHeaderKey
 @abstract Key for the amperage response header.
 */
extern const NSString *kMBLAmperageHeaderKey;

/*!
 @const kMBLVoltageHeaderKey
 @abstract Key for the voltage response header.
 */
extern const NSString *kMBLVoltageHeaderKey;

/*!
 @const kMBLManufacturerHeaderKey
 @abstract Key for the manufacturer response header.
 */
extern const NSString *kMBLManufacturerHeaderKey;

/*!
 @const kMBLSerialHeaderKey
 @abstract Key for the serial number response header.
 */
extern const NSString *kMBLSerialHeaderKey;

/*!
 @const kMBLManufactureDateHeaderKey
 @abstract Key for the manufacture date response header.
 */
extern const NSString *kMBLManufactureDateHeaderKey;

/*!
 @const kMBLDeviceNameHeaderKey
 @abstract Key for the device name response header.
 */
extern const NSString *kMBLDeviceNameHeaderKey;

/*!
 @category ServerAdditions
 @abstract Collection of methods used to serve battery information over the network.
 */
@interface Battery (ServerAdditions)

/*!
 @method setPropertiesFromServerResponse:
 @abstract Sets one-time battery properties from the server's response.
 @param response The server's response.
 */
- (void)setPropertiesFromServerResponse:(NSString *)response;

/* Headers, <cr><lf> terminated, used in server responses */
/*!
 @method capacityResponseHeader
 @abstract Header for battery capacity.
 */
- (NSString *)capacityResponseHeader;

/*!
 @method cycleCountResponseHeader
 @abstract Header for cycle count.
 */
- (NSString *)cycleCountResponseHeader;

/*!
 @method chargeResponseHeader
 @abstract Header for battery charge.
 */
- (NSString *)chargeResponseHeader;

/*!
 @method timeToEmptyResponseHeader
 @abstract Header for time to empty.
 */
- (NSString *)timeToEmptyResponseHeader;

/*!
 @method timeToFullChargeResponseHeader
 @abstract Header for time to full charge.
 */
- (NSString *)timeToFullChargeResponseHeader;

/*!
 @method installedResponseHeader
 @abstract Header for information on battery installed status.
 */
- (NSString *)installedResponseHeader;

/*!
 @method chargingResponseHeader
 @abstract Header for information on battery charging status.
 */
- (NSString *)chargingResponseHeader;

/*!
 @method pluggedResponseHeader
 @abstract Header for information on battery plugged status.
 */
- (NSString *)pluggedResponseHeader;

/*!
 @method amperageResponseHeader
 @abstract Header for battery amperage.
 */
- (NSString *)amperageResponseHeader;

/*!
 @method voltageResponseHeader
 @abstract Header for battery voltage.
 */
- (NSString *)voltageResponseHeader;

/*!
 @method maxCapacityResponseHeader
 @abstract Header for battery maximum capacity.
 */
- (NSString *)maxCapacityResponseHeader;

/*!
 @method designCapacityResponseHeader
 @abstract Header for battery design capacity.
 */
- (NSString *)designCapacityResponseHeader;

/*!
 @method manufacturerResponseHeader
 @abstract Header for battery manufacturer.
 */
- (NSString *)manufacturerResponseHeader;

/*!
 @method manufactureDateResponseHeader
 @abstract Header for battery manufacture date.
 */
- (NSString *)manufactureDateResponseHeader;

/*!
 @method deviceNameResponseHeader
 @abstract Header for battery device name.
 */
- (NSString *)deviceNameResponseHeader;

/*!
 @method serialResponseHeader
 @abstract Header for battery serial number.
 */
- (NSString *)serialResponseHeader;

@end
