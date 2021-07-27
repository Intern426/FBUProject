//
//  DetailViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/26/21.
//

#import "DetailViewController.h"
#import "APIManager.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSMutableDictionary *drugInformation;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:self.prescription.displayName];
    
    // Do any additional setup after loading the view.
    // 1. Make a call to openFDA with the drug name and see if you can get the information.
    [[APIManager shared] getDrugInformationOpenFDA:self.prescription.displayName completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            }
        }
    }];
}


-(void) displayInformation{
    [self displayBuyingInformation];
    NSLog(@"%@", self.drugInformation);
    NSDictionary *openFdaData = self.drugInformation[@"openfda"];
    
    NSArray *manufacturerInformation = openFdaData[@"manufacturer_name"];
    self.manufacturerLabel.text = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerInformation[0]];
    
    NSArray *brandNameInformation = openFdaData[@"brand_name"];
    self.brandLabel.text = [NSString stringWithFormat:@"Brand: %@", [brandNameInformation[0] capitalizedString]];
    
    
    NSArray *genericNameInformation = openFdaData[@"generic_name"];
    self.activeIngredientLabel.text = [NSString stringWithFormat:@"Active Ingredient: %@", [genericNameInformation[0] capitalizedString]];
    
    NSArray *oralInformation = openFdaData[@"route"];
    self.routeLabel.text = [NSString stringWithFormat:@"Route: %@", [oralInformation[0] capitalizedString]];
    
   
    if (self.drugInformation[@"inactive_ingredients"]) {
        NSArray *inactiveIngredientInfo = self.drugInformation[@"inactive_ingredients"];
        self.inactiveIngredientLabel.text = inactiveIngredientInfo[0];
    } else {
        NSArray *descriptionInfo = self.drugInformation[@"description"];
        NSString *description = descriptionInfo[0];
        if ([description containsString:@"inactive ingredient"]) {
            self.inactiveIngredientLabel.text = @"It's there.";
        } else {
            self.inactiveIngredientLabel.hidden = YES;
        }
    }
    
    if (self.drugInformation[@"purpose"]) {
        NSArray *purposeInfo = self.drugInformation[@"purpose"];
        self.purposeLabel.text = purposeInfo[0];
    } else {
        self.purposeLabel.hidden = YES;
    }
}

-(void)displayBuyingInformation{
    self.dosageLabel.text = [NSString stringWithFormat:@"Dosage: %@", self.prescription.dosageAmount];
    if (self.quantityControl.selectedSegmentIndex == 0) {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount30];
        self.priceLabel.text = self.prescription.price30;
    } else {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount90];
        self.priceLabel.text =  self.prescription.price90;
    }
}

- (IBAction)didChangeQuantity:(id)sender {
    if (self.quantityControl.selectedSegmentIndex == 0) {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount30];
        self.priceLabel.text = self.prescription.price30;
    } else {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount90];
        self.priceLabel.text =  self.prescription.price90;
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
