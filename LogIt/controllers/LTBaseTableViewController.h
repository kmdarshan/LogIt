//
//  LTBaseTableViewController.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTBase.h"
typedef enum {
    LTSectionTripLogging = 0,
    LTSectionTripDescription
}LTSection;

#pragma mark - height
static const CGFloat rowHeightTripDescription = 60.0f;
static const CGFloat rowHeightTripLogging = 80.0f;
#pragma mark - identifiers
static NSString *cellIdentifierTripLogging = @"cell.identifier.trip.logging";
static NSString *cellIdentifierTripDescription = @"cell.identifier.trip.description";
@interface LTBaseTableViewController : UITableViewController

@end
