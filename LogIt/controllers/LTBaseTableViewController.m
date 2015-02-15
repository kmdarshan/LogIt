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
#import "LTLocationManager.h"

@interface LTBaseTableViewController () <LTLocationManagerDelegate>
@property (strong, nonatomic) NSTimer *movementCheckingTimer;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) NSMutableArray *points;
@end

@implementation LTBaseTableViewController

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)viewDidAppear:(BOOL)animated {
    if ([self locationServicesEnabled]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
        [[LTLocationManager sharedLocationManager] startUpdating];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    }
}

#pragma mark - LTLocationManagerDelegates
-(void)distanceUpdated:(LTDetails *)details {
    [self.points addObject:details];
    [self.points sortUsingComparator:^ NSComparisonResult(LTDetails *startLocation, LTDetails *endLocation) {
        NSDate *date1 = [[startLocation startLocation] timestamp];
        NSDate *date2 = [[endLocation startLocation] timestamp];
        return [date1 compare:date2];
    }];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:LTSectionTripDescription] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)failedToRequestLocationPermission:(NSString *)title message:(NSString *)description error:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:description
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Settings", nil];
    [alertView show];
}

#pragma mark - Setup
-(void) setup {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBar"]];
    [self.tableView registerClass:[LTSwitchTableViewCell class] forCellReuseIdentifier:cellIdentifierTripLogging];
    [self.tableView registerClass:[LTDescriptionTableViewCell class] forCellReuseIdentifier:cellIdentifierTripDescription];
    [LTLocationManager sharedLocationManager].delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:LTLoggingUserSwitchOnNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:LTLoggingUserSwitchOffNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
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
-(void) handleNotifications:(NSNotification*)notification {
    if ([notification.name isEqualToString:LTLoggingUserSwitchOnNotification]) {
        [[LTLocationManager sharedLocationManager] requestLocationPermission];
        [[LTLocationManager sharedLocationManager] startUpdating];
    }
    else if ([notification.name isEqualToString:LTLoggingUserSwitchOffNotification]) {
        [[LTLocationManager sharedLocationManager] stopUpdating];
    }
}
#pragma mark - Helper
-(BOOL) locationServicesEnabled {
    if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
        return NO;
    }
    return YES;
}

#pragma mark - Alerts
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOffNotification object:nil];
    }
    if (buttonIndex == 1) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
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

@end
