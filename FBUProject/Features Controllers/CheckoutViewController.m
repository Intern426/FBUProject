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

@interface CheckoutViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, ShoppingCellDelegate, PurchaseViewControllerDelegate>
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
    if (!self.currentUser[@"buyingDrugs"]) {
        self.currentUser[@"buyingDrugs"] = [[NSMutableArray alloc] init];
    }
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

// Goes through the drugs they bought - which is stored in Parse - and converts them to Prescription objects
-(void) queryPrescriptions {
    self.totalCost = 0;
    NSMutableArray* currentPrescriptions = [[NSMutableArray alloc] init];
    NSArray *array = self.currentUser[@"buyingDrugs"];  //TODO: Give these vars better names!!!
    for (int i = 0; i < array.count; i++) {
        NSDictionary *object = array[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object[@"item"]]];
        
        // Sets the cost
        self.totalCost += [prescription.retrievePrice30 floatValue];
        
        // TODO: Clean this part up -- can simplify it to int
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *quantity = [formatter numberFromString:object[@"quantity"]];
        
        [prescription setQuantity:[quantity intValue]];
        [currentPrescriptions addObject:prescription];
    }
    self.prescriptions = currentPrescriptions;
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShoppingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingCell"];
    cell.delegate = self;
    cell.prescription = self.prescriptions[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.prescriptions.count;
}

-(void)updateCart{
    [self loadBoughtPrescriptions];
}

-(void) updateShoppingList{
    [self loadBoughtPrescriptions];
}

-(void) clearCart{
    PFUser *currentUser = [PFUser currentUser];
    NSArray *array = currentUser[@"buyingDrugs"];  //TODO: Better way to do this??
    for (int i = 0; i < array.count; i++) {
        NSDictionary *object = array[i];
        [currentUser removeObject:object forKey:@"buyingDrugs"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"Drug was removed");
                [self loadBoughtPrescriptions];
                return;
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navigationControl = [segue destinationViewController];
    PurchaseViewController *purchaseController = (PurchaseViewController*)navigationControl.topViewController;
    purchaseController.delegate = self;
    purchaseController.cost =  self.totalCost;
    purchaseController.prescriptions = self.prescriptions;
}

@end
