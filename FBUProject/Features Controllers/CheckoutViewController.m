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
    self.prescriptions = [[NSMutableArray alloc] init];
}

// In-App Payment only supports portrait orientation on landscape so we'll limit this view controller to portrait mode
- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) viewDidAppear:(BOOL)animated{
    // Every time user selects tab reload data just in case they added a prescription
    if (!self.currentUser[@"buyingDrugs"]) {
        self.currentUser[@"buyingDrugs"] = [[NSMutableArray alloc] init];
    }
    [self loadBoughtPrescriptions];
}

-(void) loadBoughtPrescriptions{
    self.totalCost = 0; // prevents total from adding the cost of the same prescription
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
    NSMutableArray* currentPrescriptions = [[NSMutableArray alloc] init];
    NSArray *boughtDrugs = self.currentUser[@"buyingDrugs"];
    NSLog(@"Data in Parse: %@", self.currentUser[@"buyingDrugs"]);
    for (int i = 0; i < boughtDrugs.count; i++) {
        NSDictionary *object = boughtDrugs[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object[@"item"]]];
    
        NSString *quantity = object[@"quantity"];
        prescription.quantity = [quantity intValue];
        [prescription setQuantity:[quantity intValue]];
    
        self.totalCost += [prescription.retrievePrice30 floatValue] * prescription.quantity;
        [currentPrescriptions addObject:prescription];
    }
    self.prescriptions = currentPrescriptions;
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
}

- (void)updateTotal{
    [self refreshCart];
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

-(void) refreshCart{
    [self emptyCartSynchronously];
    for (int i = 0; i < self.prescriptions.count; i++) {
        Prescription* prescription = self.prescriptions[i];
        NSMutableDictionary *prescriptionInfo = [[NSMutableDictionary alloc] init];
        [prescriptionInfo addEntriesFromDictionary:@{@"item": prescription.prescriptionPointer.objectId}];
        [prescriptionInfo addEntriesFromDictionary:@{@"quantity": [NSString stringWithFormat:@"%d", prescription.quantity]}];
        [self.currentUser addObject:prescriptionInfo forKey:@"buyingDrugs"];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been updated.
            [self loadBoughtPrescriptions];
        } else {
            // There was a problem, check error.description
            NSLog(@"boo.....%@", error.localizedDescription);
        }
    }];
}

-(void) emptyCartSynchronously{
    NSArray *cart = self.currentUser[@"buyingDrugs"];  //TODO: Better way to do this??
    for (int i = 0; i < cart.count; i++) {
        NSDictionary *object = cart[i];
        [self.currentUser removeObject:object forKey:@"buyingDrugs"];
    }
    [self.currentUser save];
}

-(void) clearCart:(BOOL) updateList{
    NSArray *cart = self.currentUser[@"buyingDrugs"];  //TODO: Better way to do this??
    for (int i = 0; i < cart.count; i++) {
        NSDictionary *object = cart[i];
        [self.currentUser removeObject:object forKey:@"buyingDrugs"];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been saved.
            NSLog(@"Drug was removed");
            if (updateList)
                [self loadBoughtPrescriptions];
        } else {
            // There was a problem, check error.description
            NSLog(@"boo.....%@", error.localizedDescription);
        }
    }];
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
