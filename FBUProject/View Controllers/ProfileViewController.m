//
//  ProfileViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "ProfileViewController.h"
#import "PrescriptionCell.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource, PrescriptionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (strong, nonatomic) PFUser *currentUser;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Hello %@", PFUser.currentUser.username];
    
    // Do any additional setup after loading the view.
    self.currentUser = [PFUser currentUser];
    [self loadFavorites];
}

-(void) loadFavorites{
    self.prescriptions =  [Prescription prescriptionsWithStrings:self.currentUser[@"savedDrugs"]];
    if (self.prescriptions != nil && self.prescriptions.count != 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero]; // Make sure no lines show up
        self.emptyLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    // When switching tabs, will update favorites as needed
    [self loadFavorites];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PrescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrescriptionCell"];
    cell.prescription = self.prescriptions[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.prescriptions.count;
}

- (void)updateFavorites{
    [self loadFavorites];
}

@end
