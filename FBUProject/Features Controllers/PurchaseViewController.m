//
//  PurchaseViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/21/21.
//

#import "PurchaseViewController.h"
#import "Parse/Parse.h"
@import SquareInAppPaymentsSDK;

@import MapKit;
@import CoreLocation;

@interface PurchaseViewController () <SQIPCardEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *buyerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTransaction];
}


- (void) setupTransaction{
    PFUser *buyer = [PFUser currentUser];
    
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

                self.costLabel.text = [NSString stringWithFormat:@"%f", self.cost];
                self.buyerInfoLabel.text = [NSString stringWithFormat:@"%@ \n%@\n%@, %@, %@", buyer[@"name"], addressConverter.street,
                                            addressConverter.city, addressConverter.state, addressConverter.postalCode];
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
    if (status) {
        NSLog(@"Success!");
        // TODO: Clear the cart -- already bought all their stuff
        // TODO: Deal with tracking and delivery order
    } else {
        NSLog(@"Something went wrong...");
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardEntryViewController:(SQIPCardEntryViewController *)cardEntryViewController didObtainCardDetails:(SQIPCardDetails *)cardDetails completionHandler:(void (^)(NSError * _Nullable))completionHandler{
    // TODO: Can store the card on Parse if they want to buy something again with the same card
    // TODO: Integrate it with Walgreen's Add to Cart
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
}

@end
