//
//  LTDescriptionTableViewCell.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LTDetails.h"
@interface LTDescriptionTableViewCell : UITableViewCell
@property (nonatomic, strong) LTDetails *details;
@end
