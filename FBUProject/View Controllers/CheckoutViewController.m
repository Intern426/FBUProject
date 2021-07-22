//
//  CheckoutViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/19/21.
//

#import "CheckoutViewController.h"
#import "PrescriptionCell.h"
#import "ShoppingCell.h"
#import "Parse/Parse.h"
@import SquareInAppPaymentsSDK;
#import "PurchaseViewController.h"

@interface CheckoutViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, SQIPCardEntryViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (nonatomic) double totalCost;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) NSMutableArray *prescriptions;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.currentUser = [PFUser currentUser];
}

// In-App Payment only supports portrait orientation on landscape so we'll limit this view controller to portrait mode
- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) viewDidAppear:(BOOL)animated{
    // Every time user selects tab reload data just in case they added a prescription
    self.totalCost = 0; // prevents total from adding the cost of the same prescription
    [self loadBoughtPrescriptions];
}

-(void) loadBoughtPrescriptions{
    self.prescriptions = self.currentUser[@"buyingDrugs"];
    if (self.prescriptions != nil && self.prescriptions.count != 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero]; // Make sure no lines show up
        self.emptyLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShoppingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingCell"];
    NSArray *array = self.prescriptions[indexPath.row];
    cell.drugNameLabel.text = array[0];
    cell.manufacturerLabel.text = [NSString stringWithFormat:@"Manufacturer: %@", array[1]];
    cell.formLabel.text = [NSString stringWithFormat:@"Form: %@, %@", array[2], array[3]];
    self.totalCost += 19.99;
    
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.prescriptions.count;
}

-(void)updateCart{
    [self loadBoughtPrescriptions];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     UINavigationController *navigationControl = [segue destinationViewController];
     PurchaseViewController *purchaseController = (PurchaseViewController*)navigationControl.topViewController;
     purchaseController.cost =  self.totalCost;
 }
 


@end
