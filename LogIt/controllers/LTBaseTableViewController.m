//
//  LTBaseTableViewController.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTBaseTableViewController.h"
#import "LTSwitchTableViewCell.h"
#import "LTDescriptionTableViewCell.h"
#import "LTDetails.h"
static const NSUInteger kDistanceFilter = 5; // the minimum distance (meters) for which we want to receive location updates (see docs for CLLocationManager.distanceFilter)
static const NSUInteger kHeadingFilter = 30; // the minimum angular change (degrees) for which we want to receive heading updates (see docs for CLLocationManager.headingFilter)
static const NSUInteger kDistanceAndSpeedCalculationInterval = 3; // the interval (seconds) at which we calculate the user's distance and speed
static const NSUInteger kMinimumLocationUpdateInterval = 1; // the interval (seconds) at which we ping for a new location if we haven't received one yet
@interface LTBaseTableViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *movementCheckingTimer;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) NSMutableArray *points;
@end

@implementation LTBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)viewDidAppear:(BOOL)animated {
    if ([self locationServicesEnabled]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
        [self.locationManager startUpdatingLocation];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    }
}

#pragma mark - Timer 
-(void) checkIfUserHasNotMoved {
    if (self.locations > 0) {
        CLLocation *location = [self.locations lastObject];
        NSDate *todaysDate = [NSDate date];
        NSTimeInterval interval = [todaysDate timeIntervalSinceDate:[location timestamp]];
        if (interval > 15) {
            // user is in the same place for more than 60 seconds
            CLLocation *startLocation = [self.locations objectAtIndex:0];
            CLLocation *endLocation = [self.locations lastObject];
            CLLocationDistance meters = [endLocation distanceFromLocation:startLocation];
            if (meters > 0) {
                NSLog(@"meters %f", meters);
                
                // add the objects into the array
                // sort it according to the start time
                LTDetails *details = [LTDetails new];
                [details setStartLocation:startLocation];
                [details setEndLocation:endLocation];
                [self.points addObject:details];
                [self.points sortUsingComparator:^ NSComparisonResult(LTDetails *startLocation, LTDetails *endLocation) {
                    NSDate *date1 = [[startLocation startLocation] timestamp];
                    NSDate *date2 = [[endLocation startLocation] timestamp];
                    return [date1 compare:date2];
                }];
                [self.tableView reloadData];
                [self.locations removeAllObjects];
            }
        }
    }
}

#pragma mark - Setup
-(void) setup {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBar"]];
    [self.tableView registerClass:[LTSwitchTableViewCell class] forCellReuseIdentifier:cellIdentifierTripLogging];
    [self.tableView registerClass:[LTDescriptionTableViewCell class] forCellReuseIdentifier:cellIdentifierTripDescription];

    self.locations = [NSMutableArray new];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kDistanceFilter;
    self.locationManager.headingFilter = kHeadingFilter;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:LTLoggingUserSwitchOnNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:LTLoggingUserSwitchOffNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.movementCheckingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(checkIfUserHasNotMoved) userInfo:nil repeats:YES];
     [[NSRunLoop mainRunLoop] addTimer:self.movementCheckingTimer forMode:NSRunLoopCommonModes];
    self.points = [NSMutableArray new];
    
    self.tableView.tableFooterView = [UIView new];
    
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

#pragma mark - Notification 
-(void)appEnteredForeground:(NSNotification*)notification {
    [self.tableView setNeedsDisplay];
}

#pragma mark - Location
-(void) handleNotifications:(NSNotification*)notification {
    if ([notification.name isEqualToString:LTLoggingUserSwitchOnNotification]) {
        [self requestAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    else if ([notification.name isEqualToString:LTLoggingUserSwitchOffNotification]) {
        [self stopAuthorization];
    }
}
-(BOOL) locationServicesEnabled {
    if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
        return NO;
    }
    return YES;
}
-(void) requestAuthorization {
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"messageLocationServicesTitle",@"")
                                                        message:NSLocalizedString(@"messageLocatonServicesDescription",@"")
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Settings", nil];
        [alert setTag:1];
        [alert show];     
    } else
    {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusDenied) {
            NSString *title = (status == kCLAuthorizationStatusDenied) ? NSLocalizedString(@"messageAskPermissionForLoggingTitleLocationOff", @"") : NSLocalizedString(@"messageAskPermissionForLoggingTitleBackgroundOff", @"");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:NSLocalizedString(@"messageAskPermissionForLoggingDescription", @"")
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            [alertView setTag:2];
            [alertView show];
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

-(void) stopAuthorization {
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
}
- (CLLocationCoordinate2D)deviceLocation {
    return CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
}

#pragma mark - Location Delegates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"change locations count %d %f %f speed %f", [locations count], lastLocation.coordinate.latitude, lastLocation.coordinate.longitude, [lastLocation speed]);
    
    if ([self.locations count] == 0) {
        // this is the first time, no locations are recorded
        if (lastLocation.speed > 10) {
            // the speed is greater than 10 miles, the trip is starting
            [self.locations addObject:lastLocation];
        }
    } else // this is not the first time, the app is already moving
    if ([self.locations count] > 0) {
        // keep adding the locations
        [self.locations addObject:lastLocation];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    } else {
        [self.locationManager startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
    }
}
#pragma mark - Alerts
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case 1:
            if (buttonIndex == 1) {
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
            }
            break;
        case 2:
            if (buttonIndex == 0) {
                [self stopAuthorization];
            } else
            if (buttonIndex == 1) {
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
            }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case LTSectionTripLogging:
            return 1;
        case LTSectionTripDescription:
            return [self.points count];
        default:
            break;
    }
    return 0;
}

#pragma mark - Table height
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == LTSectionTripLogging) {
        return rowHeightTripLogging;
    } else {
        return rowHeightTripDescription;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == LTSectionTripLogging) {
        return rowHeightTripLogging;
    } else {
        return rowHeightTripDescription;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == LTSectionTripLogging) {
        return [tableView dequeueReusableCellWithIdentifier:cellIdentifierTripLogging forIndexPath:indexPath];
    } else {
        LTDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTripDescription forIndexPath:indexPath];
        [cell setDetails:[self.points objectAtIndex:[indexPath row]]];
        return cell;
    }
}

#pragma mark - Switch 
-(void) switchChanged:(id)sender {
    NSLog(@"switch changed");
}

@end
