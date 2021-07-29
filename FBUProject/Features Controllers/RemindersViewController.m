//
//  RemindersViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "RemindersViewController.h"
#import "NewReminderViewController.h"
#import "ReminderCell.h"
#import "Parse/Parse.h"
@import UserNotifications;

@interface RemindersViewController () <UITableViewDelegate, UITableViewDataSource, NewReminderViewControllerDelegate, UNUserNotificationCenterDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* reminders;
@property (strong, nonatomic) UNUserNotificationCenter* center;

@end

@implementation RemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.center = [UNUserNotificationCenter currentNotificationCenter];
    self.center.delegate = self;
    [self fetchReminders];
}

- (void)viewDidAppear:(BOOL)animated{
    [self fetchReminders];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    completionHandler(UNNotificationPresentationOptionSound);
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
