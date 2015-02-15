//
//  LTDescriptionTableViewCell.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTDescriptionTableViewCell.h"
#import "LTBase.h"
@implementation LTDescriptionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    style = UITableViewCellStyleSubtitle;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = [UIImage imageNamed:@"iconCar"];
    }
    return self;
}
-(void)setDetails:(LTDetails *)details {
    CLLocation *startLocation = [details startLocation];
    CLLocation *endLocation = [details endLocation];
    [self reverseGeoCode:startLocation endLocation:endLocation callback:^(BOOL success, id result) {
        self.textLabel.text = result;
        self.textLabel.font = LTRegularFont(15.0f);
        self.textLabel.textColor = LTMediumColor();
    }];
    [self subTitleForLocation:startLocation endLocation:endLocation callback:^(BOOL success, id result) {
        self.detailTextLabel.text = result;
        self.detailTextLabel.font = LTItalicFont(12.0f);
        self.detailTextLabel.textColor = LTLightColor();
    }];
}
-(void) subTitleForLocation:(CLLocation*)startLocation endLocation:(CLLocation*)endLocation callback:(LTCallback)callback {
    NSTimeInterval duration = [[endLocation timestamp] timeIntervalSinceDate:[startLocation timestamp]];
    NSInteger days = ((NSInteger) duration) / (60 * 60 * 24);
    NSInteger hours = (((NSInteger) duration) / (60 * 60)) - (days * 24);
    NSInteger minutes = (((NSInteger) duration) / 60) - (days * 24 * 60) - (hours * 60);
    NSString *startDate = [self stringFromDate:[startLocation timestamp]];
    NSString *endDate = [self stringFromDate:[endLocation timestamp]];
    NSString *subtitleText = [NSString stringWithFormat:@"%@-%@ (%ldmin)",startDate, endDate, (long)minutes];
    callback(YES, subtitleText);
}
-(NSString*) stringFromDate:(NSDate*)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *components = [calendar components:units fromDate:date];
    date = [calendar dateFromComponents:components];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    return [timeFormatter stringFromDate:date];
}
-(void) reverseGeoCode:(CLLocation*)startLocation endLocation:(CLLocation*)endLocation callback:(LTCallback)callback {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:startLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            callback(YES, error);
        } else {
            CLPlacemark *startPlacemark = [placemarks lastObject];
            [geoCoder reverseGeocodeLocation:endLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if(error){
                    callback(YES, error);
                } else {
                    CLPlacemark *endPlacemark = [placemarks lastObject];
                    NSString *startAddressString = [NSString stringWithFormat:@"%@ %@",
                                                    (startPlacemark.subThoroughfare != nil ? startPlacemark.subThoroughfare : @""), (startPlacemark.thoroughfare != nil ? startPlacemark.thoroughfare : @"")
                                                    ];
                    NSString *endAddressString = [NSString stringWithFormat:@"%@ %@",
                                                  (endPlacemark.subThoroughfare != nil ? endPlacemark.subThoroughfare : @""), (endPlacemark.thoroughfare != nil ? endPlacemark.thoroughfare : @"")
                                                  ];
                    NSString *fullText = [NSString stringWithFormat:@"%@ > %@", startAddressString, endAddressString];
                    callback(YES, fullText);
                }
            }];
        }
        
    }];
}
@end
