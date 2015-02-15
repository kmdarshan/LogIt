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
        [self.switchView setOnTintColor:LTLyftColor()];
        self.accessoryView = self.switchView;
        if ([self isLoggingSwitchOn]) {
            [self.switchView setOn:YES animated:YES];
        } else {
            [self.switchView setOn:NO animated:YES];
        }
        [self.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
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

-(void)setSwitchOn:(BOOL)switchOn {
    if (switchOn) {
        [self.switchView setOn:YES animated:YES];
    } else {
        [self.switchView setOn:NO animated:YES];
    }
}
@end
