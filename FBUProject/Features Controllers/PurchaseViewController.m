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

@import CoreLocation;

@interface PurchaseViewController () <SQIPCardEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *buyerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (strong, nonatomic) NSMutableDictionary *purchaseDetails;
@property (strong, nonatomic) NSMutableDictionary *paymentDetails;
@property (strong, nonatomic) CNPostalAddress *buyerAddress;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.loadingIndicator startAnimating];
    self.payButton.alpha = 0.5;
    self.payButton.enabled = FALSE;
    [self setupTransaction];
    self.purchaseDetails = [[NSMutableDictionary alloc] init];
    self.paymentDetails = [[NSMutableDictionary alloc] init];
}

- (void) proccessOrders{
    Order *newOrder = [[Order alloc] init];
    if (self.buyerAddress) {
        [newOrder setPostalAddress:self.buyerAddress];
    }
    
    [newOrder setupShipping];
    [newOrder buyPrescriptions:self.prescriptions];
    
    [self.purchaseDetails addEntriesFromDictionary:@{@"idempotency_key": newOrder.object_id}];
    
    NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
    [order addEntriesFromDictionary:newOrder.line_items];
    [order addEntriesFromDictionary:newOrder.fullfillment];
    [order addEntriesFromDictionary:@{@"location_id" : newOrder.location_id}];
    
    [self.purchaseDetails addEntriesFromDictionary:@{@"order": order}];
}


- (void) setupTransaction{
    self.costLabel.text = [NSString stringWithFormat:@"$%.2f", self.cost];

    PFUser *buyer = [PFUser currentUser];
    // Convert geocode back to user-friendly address
    if (buyer[@"address"]) {
        PFGeoPoint *address = buyer[@"address"];
        CLLocation* location = [[CLLocation alloc] initWithLatitude:address.latitude longitude:address.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                CLPlacemark* placemark = placemarks.firstObject;
                CNPostalAddress *addressConverter = placemark.postalAddress;
                CNPostalAddressFormatter *formatter = [[CNPostalAddressFormatter alloc] init];
                NSString *sample = [formatter stringFromPostalAddress:addressConverter];
                self.buyerInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", buyer[@"name"], sample];
                self.buyerAddress = addressConverter;
                self.payButton.alpha = 1;
                self.payButton.enabled = TRUE;
                [self.loadingIndicator stopAnimating];
                self.buyerInfoLabel.hidden = NO;
                [self proccessOrders];
            }
        }];
    } else {
        self.buyerInfoLabel.text = [NSString stringWithFormat:@"%@", buyer[@"name"]];
        self.payButton.alpha = 1;
        self.payButton.enabled = TRUE;
        self.buyerInfoLabel.hidden = NO;
        [self.loadingIndicator stopAnimating];
        [self proccessOrders];
    }
    
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
        [[APIManager shared] uploadPaymentWithCompletion:self.paymentDetails completion:^(NSDictionary * payment, NSError * error) {
            if (error != nil) {
                NSLog(@"Error! %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully uploaded payment to Square!"); //Can do TODO: Change currency
                [self.delegate clearCart:YES];
            }
        }];
    } else {
        [self displayError:@"Cannot process payment. Please try again."];
        NSLog(@"Something went wrong..."); // Should check SQIPCardEntryCompletionStatus
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
            NSLog(@"%@", error.localizedDescription);
        } else {
            if (order[@"order"]) {
            NSDictionary *completedOrder = order[@"order"];
            NSDictionary *totalMoney = completedOrder[@"total_money"];
            
            [self.paymentDetails addEntriesFromDictionary:@{@"order_id": completedOrder[@"id"]}]; // Block it - Progress Bar?
            NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
            [amount addEntriesFromDictionary:@{@"amount": totalMoney[@"amount"]}];
            [amount addEntriesFromDictionary:@{@"currency": totalMoney[@"currency"]}];
            [self.paymentDetails addEntriesFromDictionary:@{@"amount_money":amount}];
            } else {
                [self displayError:@"Cannot process order. Please try again."];
            }
        }
    }];
}

-(void) displayError:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        [self.navigationController popViewControllerAnimated:true];
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
