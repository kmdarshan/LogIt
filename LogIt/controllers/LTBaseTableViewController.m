//
//  LTBaseTableViewController.m
//  LogIt
//
//  Created by kmd on 2/14/15.
//  Copyright (c) 2015 Lyft. All rights reserved.
//

#import "LTBaseTableViewController.h"

@interface LTBaseTableViewController ()

@end

@implementation LTBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setup];
}

#pragma mark - Setup
-(void) setup {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBar"]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifierTripDescription];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifierTripLogging];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper methods
-(BOOL) isLoggingSwitchOn {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:keyLocationLogging]) {
        return YES;
    }
    return NO;
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case LTSectionTripLogging:
            return 1;
        case LTSectionTripDescription:
            return 1;
        default:
            break;
    }
    return 0;
}

#pragma mark - Table height
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == LTSectionTripLogging) {
        return rowHeightTripLogging;
    } else {
        return rowHeightTripDescription;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == LTSectionTripLogging) {
        return rowHeightTripLogging;
    } else {
        return rowHeightTripDescription;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if ([indexPath section] == LTSectionTripLogging) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTripLogging forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"messageTripLogging", nil)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        if ([self isLoggingSwitchOn]) {
            [switchView setOn:YES animated:YES];
        } else {
            [switchView setOn:NO animated:YES];
        }
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTripDescription forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"iconCar"];
        cell.textLabel.text = @"darshan";
    }
    return cell;
}

#pragma mark - Switch 
-(void) switchChanged:(id)sender {
    NSLog(@"switch changed");
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
