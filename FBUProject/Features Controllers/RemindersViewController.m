//
//  RemindersViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "RemindersViewController.h"
#import "ReminderNotificationManager.h"
#import "NewReminderViewController.h"
#import "ReminderCell.h"
#import "Parse/Parse.h"
@import UserNotifications;

@interface RemindersViewController () <UITableViewDelegate, UITableViewDataSource, NewReminderViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* reminders;
@end

@implementation RemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchReminders];
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

-(void) fetchReminders{
    PFQuery *query = [PFQuery queryWithClassName:@"Reminder"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable reminders, NSError * _Nullable error) {
        self.reminders = [Reminder initWithArray:reminders];
        [self.tableView reloadData];
    }];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReminderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReminderCell"];
    cell.reminder = self.reminders[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reminders.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateReminder {
    [self.tableView reloadData];
}

@end
