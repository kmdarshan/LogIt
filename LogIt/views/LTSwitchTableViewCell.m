//
//  LTSwitchTableViewCell.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTSwitchTableViewCell.h"
#import "LTBase.h"
@implementation LTSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"messageTripLogging", nil)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = switchView;
        if ([self isLoggingSwitchOn]) {
            [switchView setOn:YES animated:YES];
        } else {
            [switchView setOn:NO animated:YES];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
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
    NSLog(@"switch changed");
}
@end
