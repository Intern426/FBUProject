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

@interface PrescriptionsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (strong, nonatomic) NSMutableArray *searchedPrescriptions;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation PrescriptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self loadPrescriptions];
    // Do any additional setup after loading the view.
}

- (void) loadPrescriptions {
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    query.limit = 20;
    
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
       // [self.refreshControl endRefreshing];
       // [self.loadingIndicatorView stopAnimating];
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
    cell.prescription = self.searchedPrescriptions[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchedPrescriptions.count;
}

@end
