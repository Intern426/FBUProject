//
//  PurchaseViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/21/21.
//

#import "PurchaseViewController.h"
#import "Parse/Parse.h"
@import SquareInAppPaymentsSDK;

@interface PurchaseViewController () <SQIPCardEntryViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *buyerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *buyer = [PFUser currentUser];
    self.buyerInfoLabel.text = [NSString stringWithFormat:@"%@ \n %@", buyer[@"name"], buyer[@"address"]];
    self.costLabel.text = [NSString stringWithFormat:@"%f", self.cost];
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
