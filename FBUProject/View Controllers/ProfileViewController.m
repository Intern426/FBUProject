//
//  ProfileViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "ProfileViewController.h"
#import "PrescriptionCell.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource, PrescriptionCellProfileDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (strong, nonatomic) PFUser *currentUser;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Hello %@", PFUser.currentUser.username];
    
   
    // Do any additional setup after loading the view.
    self.currentUser = [PFUser currentUser];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFavorites) forControlEvents:UIControlEventValueChanged]; //Deprecated and only used for older objects
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy
    [self.loadingIndicatorView startAnimating];
    [self loadFavorites];
}


-(void) loadFavorites{
    self.prescriptions =  [[NSMutableArray alloc] init];
    [self queryPrescriptions];
    [self checkEmpty];
    [self.tableView reloadData];
}

-(void) checkEmpty{
    if (self.prescriptions != nil && self.prescriptions.count != 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero]; // Make sure no lines show up
        self.emptyLabel.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    // When switching tabs, will update favorites as needed
    [self loadFavorites];
}

-(void) queryPrescriptions {
    NSArray *array = self.currentUser[@"savedDrugs"];
    for (int i = 0; i < array.count; i++) {
        PFObject *object = array[i];
        NSString *objectId =  object.objectId;
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:objectId]];
        [self.prescriptions addObject:prescription];
    }
    [self.loadingIndicatorView stopAnimating];
    [self.refreshControl endRefreshing];
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
    cell.profileDelegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.prescriptions.count;
}

- (void)updateFavorites:(Prescription*) prescription{
    [self loadFavorites];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Prescription* prescription = self.prescriptions[indexPath.row];
        [self.prescriptions removeObjectAtIndex:indexPath.row];
        [self.currentUser removeObject:prescription.prescriptionPointer forKey:@"savedDrugs"];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else{
            NSLog(@"Success");
        }
    }];
    [self.tableView reloadData];
    [self checkEmpty];
}


@end
