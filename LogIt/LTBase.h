//
//  LTBase.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#ifndef LogIt_LTBase_h
#define LogIt_LTBase_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^LTCallback)(BOOL success, id result);
#define keyLocationLogging  @"com.lyft.logger.logging"
static NSString * const LTLoggingSwitchOffNotification = @"com.lyft.logger.switch.off";
static NSString * const LTLoggingSwitchOnNotification = @"com.lyft.logger.switch.on";
static NSString * const LTLoggingUserSwitchOnNotification = @"com.lyft.logger.switch.user.on";
static NSString * const LTLoggingUserSwitchOffNotification = @"com.lyft.logger.switch.user.off";
static NSString * const LTSwitchStatus = @"switchStatus";
static CGFloat const regularFontSize = 15.0f;
static CGFloat const smallFontSize = 12.0f;
static inline UIColor *LTMediumColor() {
    return [UIColor colorWithRed:95.0/255.0 green:94.0/255.0 blue:92.0/255.0 alpha:1.0];
}
static inline UIColor *LTDarkColor() {
    return [UIColor colorWithRed:89.0/255.0 green:86.0/255.0 blue:82.0/255.0 alpha:1.0];
}
static inline UIColor *LTLightColor() {
    return [UIColor colorWithRed:153.0/255.0 green:152.0/255.0 blue:150.0/255.0 alpha:1.0];
}
static inline UIFont *LTRegularFont(CGFloat size) {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}
static inline UIFont *LTItalicFont(CGFloat size) {
    return [UIFont fontWithName:@"HelveticaNeue-Italic" size:size];
}
static inline UIFont *LTBoldFont(CGFloat size) {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}
#endif
