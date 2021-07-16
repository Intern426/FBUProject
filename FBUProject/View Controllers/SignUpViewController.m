//
//  SignUpViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/16/21.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *addressSecondLineField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)didTapSignUp:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser[@"name"] = self.fullNameField.text;
    
    NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@", self.addressField.text, self.cityField.text, self.stateField.text, self.zipCodeField.text];
    NSLog(@"%@", address);
    
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error encoding address: %@", error.localizedDescription);
        } else {
            CLLocation *location = placemarks.firstObject.location;
            geoPoint.latitude = location.coordinate.latitude;
            geoPoint.longitude = location.coordinate.longitude;
            newUser[@"address"] = geoPoint;
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    NSLog(@"User registered successfully");
                    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                    // manually segue to logged in view
                }
            }];
        }
    }];
    
}

@end
