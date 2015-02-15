//
//  LTLocationManager.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTLocationManager.h"
#import "LTBase.h"
// the minimum distance (meters) for which we want to receive location updates (see docs for CLLocationManager.distanceFilter)
static const NSUInteger kDistanceFilter = 5;
// the minimum angular change (degrees) for which we want to receive heading updates (see docs for CLLocationManager.headingFilter)
static const NSUInteger kHeadingFilter = 30;
// the interval (seconds) at which we ping for a new location if we haven't received one yet
static const NSUInteger kMinimumLocationUpdateInterval = 5;
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
            self.movementCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movementCheckingTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    } else
    if ([[notification name] isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self.movementCheckingTimer invalidate];
        self.movementCheckingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.movementCheckingTimer forMode:NSRunLoopCommonModes];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
        }
    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusDenied) {
            NSString *title = (status == kCLAuthorizationStatusDenied) ? NSLocalizedString(@"messageAskPermissionForLoggingTitleLocationOff", @"") : NSLocalizedString(@"messageAskPermissionForLoggingTitleBackgroundOff", @"");
            if ([self.delegate respondsToSelector:@selector(failedToRequestLocationPermission:message:error:)]) {
                [self.delegate failedToRequestLocationPermission:title message:NSLocalizedString(@"messageAskPermissionForLoggingDescription", @"") error:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
        }
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestAlwaysAuthorization];
        }
        else if (status == kCLAuthorizationStatusRestricted) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
        } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
            [self.locationManager startUpdatingLocation];
        }
    }
}
-(void) startUpdating {
    [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
    [self.locationManager startUpdatingLocation];
    self.movementCheckingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkAppsPosition) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.movementCheckingTimer forMode:NSRunLoopCommonModes];
}
-(void) stopUpdating {
    [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    [self.locationManager stopUpdatingLocation];
    [self.movementCheckingTimer invalidate];
}

#pragma mark - Location delegates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"change locations count %lu %f %f speed %f", (unsigned long)[locations count], lastLocation.coordinate.latitude, lastLocation.coordinate.longitude, [lastLocation speed]);
    if ([self.temporaryLocations count] == 0) {
        // this is the first time, no locations are recorded
        if (lastLocation.speed > 10) {
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
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    } else {
        [self.locationManager startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
    }
}
-(void) checkAppsPosition {
    if (self.temporaryLocations > 0) {
        CLLocation *location = [self.temporaryLocations lastObject];
        NSDate *todaysDate = [NSDate date];
        NSTimeInterval interval = [todaysDate timeIntervalSinceDate:[location timestamp]];
        if (interval > 15) {
            // user is in the same place for more than 60 seconds
            CLLocation *startLocation = [self.temporaryLocations objectAtIndex:0];
            CLLocation *endLocation = [self.temporaryLocations lastObject];
            CLLocationDistance meters = [endLocation distanceFromLocation:startLocation];
            if (meters > 0) {
                NSLog(@"meters %f", meters);
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
