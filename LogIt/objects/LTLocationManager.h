//
//  LTLocationManager.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class LTLocationManager;

@protocol LTLocationManagerDelegate <NSObject>
@optional
-(void) distanceUpdated;
@end

@interface LTLocationManager : NSObject<CLLocationManagerDelegate>
+ (LTLocationManager *)sharedLocationManager;
//-(void)startUpdating;
//-(void)stopUpdating;
@end

