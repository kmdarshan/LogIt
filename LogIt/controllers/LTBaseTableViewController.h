//
//  LTBaseTableViewController.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LTBase.h"
#import "LTSwitchTableViewCell.h"
#import "LTDescriptionTableViewCell.h"
#import "LTDetails.h"
#import "LTLocationManager.h"
typedef NS_ENUM(int, LTSection) {
    LTSectionTripLogging = 0,
    LTSectionTripDescription
};
typedef NS_ENUM(int, LTAlertType) {
    LTAlertTypeSettins = 1,
    LTAlertTypeInfo = 2
};

#pragma mark - height
static const CGFloat rowHeightTripDescription = 50.0f;
static const CGFloat rowHeightTripLogging = 60.0f;
#pragma mark - identifiers
static NSString *cellIdentifierTripLogging = @"cell.identifier.trip.logging";
static NSString *cellIdentifierTripDescription = @"cell.identifier.trip.description";
@interface LTBaseTableViewController : UITableViewController

@end
