//
//  LTBase.h
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#ifndef LogIt_LTBase_h
#define LogIt_LTBase_h
typedef void(^LTCallback)(BOOL success, id result);
#define keyLocationLogging  @"com.lyft.logger.logging"
static NSString * const LTLoggingSwitchOffNotification = @"com.lyft.logger.switch.off";
static NSString * const LTLoggingSwitchOnNotification = @"com.lyft.logger.switch.on";
static NSString * const LTLoggingUserSwitchOnNotification = @"com.lyft.logger.switch.user.on";
static NSString * const LTLoggingUserSwitchOffNotification = @"com.lyft.logger.switch.user.off";
static NSString * const LTSwitchStatus = @"switchStatus";
#endif
