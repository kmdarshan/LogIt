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
-(void) distanceUpdated:(LTDetails*)details;
-(void) failedToRequestLocationPermission:(NSString*)title message:(NSString*)description error:(NSError*)error;
@end

@interface LTLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, weak) id<LTLocationManagerDelegate> delegate;
+(LTLocationManager*) sharedLocationManager;
-(void) requestLocationPermission;
-(void) stopUpdating;
-(void) startUpdating;
@end

