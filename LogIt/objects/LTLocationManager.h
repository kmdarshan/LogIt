//
//  LTLocationManager.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LTDetails.h"
@class LTLocationManager;

@protocol LTLocationManagerDelegate <NSObject>
@optional
// method is used for setting the distance, mainly the start and end points, if the user has finished a trip
-(void) distanceUpdated:(LTDetails*)details;
// method is used to send an error, if the there is a error in requesting user location
-(void) failedToRequestLocationPermission:(NSString*)title message:(NSString*)description error:(NSError*)error;
// method is used to change the switch position accordingly to on/off
-(void) changeSwitchTo:(BOOL)switchOn;
// method is used for setting the error messages from didFailWithError location delegate
-(void) unknownError:(NSString*)message;
@end

@interface LTLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, weak) id<LTLocationManagerDelegate> delegate;
+(LTLocationManager*) sharedLocationManager;
-(void) requestLocationPermission;
// stop updating the location and invalidate timer
-(void) stopUpdating;
// start updating the location and start timer
-(void) startUpdating;
@end

