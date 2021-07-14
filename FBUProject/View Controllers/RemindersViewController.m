//
//  RemindersViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "RemindersViewController.h"
#import "ReminderNotificationManager.h"
#import "ReminderCell.h"
@import UserNotifications;

@interface RemindersViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Request to notify user
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
       completionHandler:^(BOOL granted, NSError * _Nullable error) {
          // Enable or disable features based on authorization.
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (!granted) {
            NSLog(@"User did not grant access... Alert them that they will not see alarms until they accept!");
        }
    }];

    ReminderNotificationManager *reminder = [[ReminderNotificationManager alloc] init];
    [reminder testNotifications];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReminderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReminderCell"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
