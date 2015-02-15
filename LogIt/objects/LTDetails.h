//
//  LTDetails.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface LTDetails : NSObject
@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) CLLocation *endLocation;
@end
