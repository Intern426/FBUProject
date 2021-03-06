//
//  PrescriptionsViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "PrescriptionsViewController.h"
#import "PrescriptionCell.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "APIManager.h"
#import "DetailViewController.h"
#import "Reachability.h"
#import "InfiniteScrollActivityView.h"

@interface PrescriptionsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, PrescriptionCellDetailDelegate, UIScrollViewDelegate, StackViewCollapseDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (strong, nonatomic) NSMutableArray *searchedPrescriptions;
@property (strong, nonatomic) NSMutableArray *allPrescriptions;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) Prescription* collapsePrescription;

@property (strong, nonatomic) NSLock * arrayLock;
@property (nonatomic) int toggleStack; // 0 - do nothing, 1 - collapse, 2 - expand

@end

@implementation PrescriptionsViewController

BOOL isMoreDataLoading = false;
InfiniteScrollActivityView* loadingMoreView;
const int TOTAL_PRESCRIPTION_IN_THOUSANDS = 2; // About 2 thousand prescriptions and you can only get max 1000 at a time...
const int COLLAPSE = 1;
const int EXPAND = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayLock = [[NSLock alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.searchBar.delegate = self;
    self.toggleStack = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadPrescriptions) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy
    [self.loadingIndicatorView startAnimating];
    
    // Set up Infinite Scroll loading indicator
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreView.hidden = true;
    [self.tableView addSubview:loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
  //[self retrieveAllPrescriptions];
}

-(void) checkInternetConnection {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get prescriptions"
                                                                       message:@"There seems to be no internet connection"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
            [self loadPrescriptions];
        }];
        [alert addAction:tryAgainAction];
        [self presentViewController:alert animated:YES completion:^{}];
    } else
        [self loadPrescriptions];
}

- (void)viewDidAppear:(BOOL)animated{
    // When switching tabs, will update favorites as needed
    [self checkInternetConnection];
}

-(void) retrieveAllPrescriptions{
    [self.arrayLock lock];
    self.allPrescriptions = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    query.limit = 1000;
    for (int i = 0; i < TOTAL_PRESCRIPTION_IN_THOUSANDS; i++) {
        query.skip = 1000 * i;
        [self.allPrescriptions addObjectsFromArray:[Prescription prescriptionsDataInArray:[query findObjects]]];
    }
    [self.arrayLock unlock];
}


- (void) loadPrescriptions {
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    query.limit = 50;
    [query orderByDescending:@"drugName"];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *prescriptions, NSError *error) {
        if (prescriptions != nil) {
            // do something with the array of object returned by the call
            self.prescriptions = [Prescription prescriptionsDataInArray:prescriptions];
            self.searchedPrescriptions = [NSMutableArray arrayWithArray:self.prescriptions];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
        [self.loadingIndicatorView stopAnimating];
    }];
}

- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil]; // Access Main.storyboard
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"]; // Call forth the login view controller
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0) {
        self.searchBar.showsCancelButton = true;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Prescription *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.displayName containsString:searchText];
        }];
        self.searchedPrescriptions = (NSMutableArray*)[self.allPrescriptions filteredArrayUsingPredicate:predicate];
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
    cell.prescription = self.searchedPrescriptions[indexPath.row];
    cell.detailDelegate = self;
    cell.stackDelegate = self;
    if (self.toggleStack == COLLAPSE) {
        cell.collapse = YES;
        [cell didTapExpand:self];
    } else if (self.toggleStack == EXPAND) {
        cell.collapse = NO;
        [cell didTapExpand:self];
    }
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
    if (indexPath.row + 1 == [self.prescriptions count]){
        // Update position of loadingMoreView, and start loading indicator
        CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
        loadingMoreView.frame = frame;
        [loadingMoreView startAnimating];
        [self loadMoreData:[self.prescriptions count] + 20];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!isMoreDataLoading){
        isMoreDataLoading = true;
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            isMoreDataLoading = true;
            
            // Update position of loadingMoreView, and start loading indicator
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            loadingMoreView.frame = frame;
            [loadingMoreView startAnimating];
            [self loadMoreData:[self.prescriptions count] + 20];
        }
    }
}

-(void)loadMoreData:(int) newData{
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    [query orderByDescending:@"drugName"];
    query.skip = newData;
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *prescriptions, NSError *error) {
        if (prescriptions != nil) {
            isMoreDataLoading = false;
            [self.prescriptions addObjectsFromArray:[Prescription prescriptionsDataInArray:prescriptions]];
            self.searchedPrescriptions = [NSMutableArray arrayWithArray:self.prescriptions];
            [loadingMoreView stopAnimating];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) collapseCell{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (IBAction)didTapExpandAll:(id)sender {
    self.toggleStack = EXPAND;
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.toggleStack = 0; //reset the toggle so the cell doesn't suddenly expand/collapse when its off-screen
    });
}

- (IBAction)didTapCollapseAll:(id)sender {
    self.toggleStack = COLLAPSE;
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.toggleStack = 0; //reset the toggle so the cell doesn't suddenly expand/collapse when its off-screen
    });
}

@end
