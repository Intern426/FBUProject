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
#import "PurchaseViewController.h"

@interface CheckoutViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>
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
    self.prescriptions = [[NSMutableArray alloc] init];
    [self loadBoughtPrescriptions];
}

-(void) loadBoughtPrescriptions{
    [self queryPrescriptions];
    if (self.prescriptions != nil && self.prescriptions.count != 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero]; // Make sure no lines show up
        self.emptyLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

-(void) queryPrescriptions {
    NSArray *array = self.currentUser[@"buyingDrugs"];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *object = array[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object[@"item"]]];
        self.totalCost +=  [prescription.retrievePrice30 floatValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *quantity = [formatter numberFromString:object[@"quantity"]];
        NSLog(@"%@", quantity);
        [prescription setQuantity:[quantity intValue]];
        [self.prescriptions addObject:prescription];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShoppingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingCell"];
    cell.prescription = self.prescriptions[indexPath.row];
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
     purchaseController.prescriptions = self.prescriptions;
 }
 
@end
