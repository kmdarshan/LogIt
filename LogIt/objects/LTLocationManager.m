//
//  LTLocationManager.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTLocationManager.h"
#import "LTBase.h"
static const NSUInteger kDistanceFilter = 5;
static const NSUInteger kHeadingFilter = 30;
static const NSUInteger kMinimumLocationUpdateInterval = 30;
static const NSUInteger kMinimumSpeedForTrackingUser = 4.4704; // metres/sec that is 10 miles/hour
static const NSUInteger kMinimumIntervalForCheckingUserLocation = 60; // if the user is still for a minute
@interface LTLocationManager()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *temporaryLocations;
@property (nonatomic, strong) NSTimer *movementCheckingTimer;
@end

@implementation LTLocationManager
+ (id)sharedLocationManager {
    static dispatch_once_t pred;
    static LTLocationManager *locationManagerSingleton = nil;
    dispatch_once(&pred, ^{
        locationManagerSingleton = [[self alloc] init];
    });
    return locationManagerSingleton;
}

- (id)init {
    if ((self = [super init])) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kDistanceFilter;
        self.locationManager.headingFilter = kHeadingFilter;
        self.temporaryLocations = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manageNotifications:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manageNotifications:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
#pragma mark - Notifications
-(void) manageNotifications:(NSNotification*)notification {
    if ([[notification name] isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self.movementCheckingTimer invalidate];
        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.movementCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movementCheckingTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    } else
    if ([[notification name] isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self.movementCheckingTimer invalidate];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.movementCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movementCheckingTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}
-(BOOL) locationServicesEnabled {
    if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
        return NO;
    }
    return YES;
}
-(void) requestLocationPermission {
    if (![CLLocationManager locationServicesEnabled]) {
        if ([self.delegate respondsToSelector:@selector(failedToRequestLocationPermission:message:error:)]) {
            [self.delegate failedToRequestLocationPermission:NSLocalizedString(@"messageLocationServicesTitle",@"") message:NSLocalizedString(@"messageLocatonServicesDescription",@"") error:nil];
        }
        if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
            [self.delegate changeSwitchTo:NO];
        }

    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusDenied) {
            NSString *title = (status == kCLAuthorizationStatusDenied) ? NSLocalizedString(@"messageAskPermissionForLoggingTitleLocationOff", @"") : NSLocalizedString(@"messageAskPermissionForLoggingTitleBackgroundOff", @"");
            if ([self.delegate respondsToSelector:@selector(failedToRequestLocationPermission:message:error:)]) {
                [self.delegate failedToRequestLocationPermission:title message:NSLocalizedString(@"messageAskPermissionForLoggingDescription", @"") error:nil];
            }
            if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
                [self.delegate changeSwitchTo:NO];
            }
        }
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestAlwaysAuthorization];
        }
        else if (status == kCLAuthorizationStatusRestricted) {
            if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
                [self.delegate changeSwitchTo:NO];
            }
        } else if (status == kCLAuthorizationStatusAuthorizedAlways) { 
            [self.locationManager startUpdatingLocation];
            if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
                [self.delegate changeSwitchTo:YES];
            }
        }
    }
}
-(void) startUpdating {
    if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
        [self.delegate changeSwitchTo:YES];
    }
    [self.locationManager startUpdatingLocation];
    self.movementCheckingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.movementCheckingTimer forMode:NSRunLoopCommonModes];
}
-(void) stopUpdating {
    if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
        [self.delegate changeSwitchTo:NO];
    }

    [self.locationManager stopUpdatingLocation];
    [self.movementCheckingTimer invalidate];
}

#pragma mark - Location delegates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    if ([self.temporaryLocations count] == 0) {
        // this is the first time, no locations are recorded
        if (lastLocation.speed > kMinimumSpeedForTrackingUser) {
            // the speed is greater than 10 miles, the trip is starting
            [self.temporaryLocations addObject:lastLocation];
        }
    } else // this is not the first time, the app is already moving
        if ([self.temporaryLocations count] > 0) {
            // keep adding the locations
            [self.temporaryLocations addObject:lastLocation];
        }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"fail slowly, don't crash the app %@", [error description]);
    [self.locationManager stopUpdatingLocation];
    if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
        [self.delegate changeSwitchTo:NO];
    }
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
            [self.delegate changeSwitchTo:NO];
        }

    } else {
        [self.locationManager startUpdatingLocation];
        if ([self.delegate respondsToSelector:@selector(changeSwitchTo:)]) {
            [self.delegate changeSwitchTo:YES];
        }
    }
}
-(void) checkAppsPosition {
    if (self.temporaryLocations > 0) {
        CLLocation *location = [self.temporaryLocations lastObject];
        NSDate *todaysDate = [NSDate date];
        NSTimeInterval interval = [todaysDate timeIntervalSinceDate:[location timestamp]];
        if (interval > kMinimumIntervalForCheckingUserLocation) {
            // user is in the same place for more than 60 seconds
            CLLocation *startLocation = [self.temporaryLocations objectAtIndex:0];
            CLLocation *endLocation = [self.temporaryLocations lastObject];
            CLLocationDistance meters = [endLocation distanceFromLocation:startLocation];
            if (meters > 0) {
                LTDetails *details = [LTDetails new];
                [details setStartLocation:startLocation];
                [details setEndLocation:endLocation];
                if ([self.delegate respondsToSelector:@selector(distanceUpdated:)]) {
                    [self.delegate distanceUpdated:details];
                }
                [self.temporaryLocations removeAllObjects];
            }
        }
    }
}
@end
