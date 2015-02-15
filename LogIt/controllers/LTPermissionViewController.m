//
//  LTPermissionViewController.m
//  LogIt
//
//  Created by kmd on 2/15/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTPermissionViewController.h"
@interface LTPermissionViewController ()

@end

@implementation LTPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBar"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.90, 130.0f)];
    [label setText:NSLocalizedString(@"messageAllowNotificationsDescriptions", @"")];
    [label setFont:LTRegularFont(18.0f)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:LTMediumColor()];
    [self.view addSubview:label];
    [label setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:NSLocalizedString(@"messageAllowNotifications", @"") forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.70, 90.0f)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:LTBoldFont(17.0f)];
    [button setBackgroundColor:LTLyftColor()];
    [self.view addSubview:button];
    [button setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [button addTarget:self action:@selector(askForNotifications) forControlEvents:UIControlEventTouchUpInside];
    [label setFrame:CGRectMake(label.frame.origin.x, button.frame.origin.y - label.frame.size.height, label.frame.size.width, label.frame.size.height)];
    [label setNumberOfLines:0];
}
-(void)askForNotifications {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LTLoggingSwitchOnNotification object:nil];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
