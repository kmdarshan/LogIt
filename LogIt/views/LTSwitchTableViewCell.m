//
//  LTSwitchTableViewCell.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTSwitchTableViewCell.h"
#import "LTBase.h"
@interface LTSwitchTableViewCell ()
@property (nonatomic, strong) UISwitch *switchView;
@end
@implementation LTSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"messageTripLogging", nil)];
        self.textLabel.font = LTBoldFont(16.0f);
        self.textLabel.textColor = LTDarkColor();
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.switchView setOnTintColor:[UIColor colorWithRed:43.0/255.0 green:179.0/255.0 blue:173.0/255.0 alpha:1.0]];
        self.accessoryView = self.switchView;
        if ([self isLoggingSwitchOn]) {
            [self.switchView setOn:YES animated:YES];
        } else {
            [self.switchView setOn:NO animated:YES];
        }
        [self.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSwitch:) name:LTLoggingSwitchOffNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSwitch:) name:LTLoggingSwitchOnNotification object:nil];
    }
    return self;
}

-(BOOL) isLoggingSwitchOn {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:keyLocationLogging]) {
        return YES;
    }
    return NO;
}

-(void) switchChanged:(id)sender {
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingUserSwitchOnNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingUserSwitchOffNotification object:nil];
    }
}

-(void) resetSwitch:(NSNotification*) notification {
    if ([[notification name] isEqualToString:LTLoggingSwitchOffNotification]) {
        [self.switchView setOn:NO animated:YES];
    } else {
        [self.switchView setOn:YES animated:YES];
    }
}
@end
