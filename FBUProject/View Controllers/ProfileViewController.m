//
//  ProfileViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "ProfileViewController.h"
#import "PrescriptionCell.h"
#import "Parse/Parse.h"
#import "DetailViewController.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource, PrescriptionCellProfileDelegate, PrescriptionCellDetailDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (strong, nonatomic) NSMutableArray *searchedPrescriptions;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
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
    if (self.searchedPrescriptions != nil && self.searchedPrescriptions.count != 0) {
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
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    NSArray *array = self.currentUser[@"savedDrugs"];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *savedInfo = array[i];
        NSString *objectId =  savedInfo[@"item"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:objectId]];
        [self.prescriptions addObject:prescription];
    }
    self.searchedPrescriptions = [NSMutableArray arrayWithArray:self.prescriptions];
    [self.loadingIndicatorView stopAnimating];
    [self.refreshControl endRefreshing];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"detailSegue"]) {
        DetailViewController *detailController = [segue destinationViewController];
        detailController.prescription = sender;
    }
}

- (void)sendDetailInformation:(Prescription *)prescription{
    [self performSegueWithIdentifier:@"detailSegue" sender:prescription];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PrescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrescriptionCell"];
    cell.prescription = self.prescriptions[indexPath.row];
    cell.profileDelegate = self;
    cell.detailDelegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchedPrescriptions.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    PrescriptionCell *modifiedCell = (PrescriptionCell*) cell;
    UIColor *navigationColor = self.navigationController.navigationBar.barTintColor; // to get the custom color
    if (modifiedCell.nameView) {
        if (indexPath.row % 2 == 0) {
            modifiedCell.nameView.backgroundColor = navigationColor;
        } else {
            modifiedCell.nameView.backgroundColor = [UIColor blueColor];
        }
        cell = modifiedCell;
    }
}

- (void)updateFavorites{
    [self loadFavorites];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Prescription* prescription = self.searchedPrescriptions[indexPath.row];
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        [object addEntriesFromDictionary:@{@"name": [NSString stringWithFormat:@"%@ %@", prescription.displayName, prescription.dosageAmount]}];
        [object addEntriesFromDictionary:@{@"item": prescription.prescriptionPointer.objectId}];
        [self.searchedPrescriptions removeObjectAtIndex:indexPath.row];
        [self.currentUser removeObject:object forKey:@"savedDrugs"];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self.tableView reloadData];
            [self checkEmpty];
        } else{
            NSLog(@"Success");
        }
    }];
    [self.tableView reloadData];
    [self checkEmpty];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0) {
        self.searchBar.showsCancelButton = true;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Prescription *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.displayName containsString:searchText];
        }];
        self.searchedPrescriptions = (NSMutableArray*)[self.prescriptions filteredArrayUsingPredicate:predicate];
    } else {
        self.searchBar.showsCancelButton = false;
        self.searchedPrescriptions = self.prescriptions;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.searchedPrescriptions = self.prescriptions;
    [self.tableView reloadData];
}




@end
