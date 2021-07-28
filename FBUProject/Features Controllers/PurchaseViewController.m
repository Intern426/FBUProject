//
//  PurchaseViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/21/21.
//

#import "PurchaseViewController.h"
#import "Parse/Parse.h"
@import SquareInAppPaymentsSDK;
#import "APIManager.h"
#import "Order.h"

@import MapKit;
@import CoreLocation;

@interface PurchaseViewController () <SQIPCardEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *buyerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (strong, nonatomic) NSMutableDictionary *purchaseDetails;
@property (strong, nonatomic) NSMutableDictionary *paymentDetails;


@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTransaction];
    self.purchaseDetails = [[NSMutableDictionary alloc] init];
    self.paymentDetails = [[NSMutableDictionary alloc] init];
    [self proccessOrders];
}

- (void) proccessOrders{
    Order *newOrder = [[Order alloc] init];
    [newOrder buyPrescriptions:self.prescriptions];
    
    [self.purchaseDetails addEntriesFromDictionary:@{@"idempotency_key": newOrder.object_id}];

    
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    [order addEntriesFromDictionary:newOrder.line_items];
    [order addEntriesFromDictionary:newOrder.fullfillment];
    [order addEntriesFromDictionary:@{@"location_id" : newOrder.location_id}];
    
    [self.purchaseDetails addEntriesFromDictionary:@{@"order": order}];
}


- (void) setupTransaction{
    PFUser *buyer = [PFUser currentUser];
    
    // self.squareManager = [APIManager sharedSquare];
    
    // Convert geocode back to user-friendly address
    PFGeoPoint *address = buyer[@"address"];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:address.latitude longitude:address.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            CLPlacemark* placemark = placemarks.firstObject;
            NSLog(@"%@", placemark.postalAddress);
            
            CNPostalAddress *addressConverter = placemark.postalAddress;
            CNPostalAddressFormatter *formatter = [[CNPostalAddressFormatter alloc] init];
            NSString *sample = [formatter stringFromPostalAddress:addressConverter];
            
            self.costLabel.text = [NSString stringWithFormat:@"$%.2f", self.cost];
            self.buyerInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", buyer[@"name"], sample];
        }
    }];
}


-(void) showCardEntryForm{
    SQIPTheme *theme = [[SQIPTheme alloc] init];
    
    theme.tintColor = UIColor.grayColor;
    theme.saveButtonTitle = @"Submit";
    
    SQIPCardEntryViewController *cardEntryForm = [[SQIPCardEntryViewController alloc] initWithTheme:theme];
    cardEntryForm.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cardEntryForm];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)cardEntryViewController:(SQIPCardEntryViewController *)cardEntryViewController didCompleteWithStatus:(SQIPCardEntryCompletionStatus)status{
    if (status == SQIPCardEntryCompletionStatusSuccess) {
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init]; // TODO: NSLock - thread safety!!!!! (1)
        [amount addEntriesFromDictionary:@{@"amount": [NSNumber numberWithFloat:self.cost*100]}];
        [amount addEntriesFromDictionary:@{@"currency": @"USD"}];
        
        [self.paymentDetails addEntriesFromDictionary:@{@"amount_money":amount}];
        [[APIManager shared] uploadPaymentWithCompletion:self.paymentDetails completion:^(NSDictionary * payment, NSError * error) {
            if (error != nil) {
                NSLog(@"Error! %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully uploaded payment to Square!"); //Can do TODO: Change currency
                
                // Display banner saying orders have been proccessed
                [self.delegate clearCart:YES];
            }
        }];
    } else {
        NSLog(@"Something went wrong...");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardEntryViewController:(SQIPCardEntryViewController *)cardEntryViewController didObtainCardDetails:(SQIPCardDetails *)cardDetails completionHandler:(void (^)(NSError * _Nullable))completionHandler{
    [self.paymentDetails addEntriesFromDictionary:@{@"source_id": cardDetails.nonce}];
    completionHandler(nil);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)didTapPayCard:(id)sender {
    [self showCardEntryForm];
    [[APIManager shared] uploadOrderWithCompletion:self.purchaseDetails completion:^(NSDictionary * order, NSError * error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription); //TODO: Pop up - UIAlertControl that shows error!
        } else {
            NSDictionary *completedOrder = order[@"order"];
            [self.paymentDetails addEntriesFromDictionary:@{@"order_id": completedOrder[@"id"]}]; // Block it - Progress Bar?
        }
    }];
}

@end
