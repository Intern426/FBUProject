//
//  DetailViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/26/21.
//

#import "DetailViewController.h"
#import "APIManager.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSDictionary *drugInformation;

@property (nonatomic, strong) NSDictionary *rxNormDrugInformation;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    NSString* searchingDrugName = self.prescription.displayName;
    NSArray* splitDrugName = [searchingDrugName componentsSeparatedByString:@" "];
    if (splitDrugName.count > 1) {
        searchingDrugName = splitDrugName[0];
    }
    [super viewDidLoad];
    [self.navigationItem setTitle:self.prescription.displayName];
    [self queryOpenFDABrand:searchingDrugName];
    // Do any additional setup after loading the view.
    
    // Flow of the API Calls
    // 1. Make a call to openFDA using search = BRAND_NAME
    // 2. Make a call to openFDA using search = GENERIC_NAME
    // 3. Make a call to RxNorm with the drug name and see if the rxcui number gets you results so
    //    3.1 Save the data for RxNorm just in case.
    //    3.2 Make a call to openFDA using search = rxcui.exact
    // 4. When you make the call to RxNorm, just save the data then check the name... see if that name gets results!
    
}

-(void) queryOpenFDABrand:(NSString* )query {
    [[APIManager shared] getDrugInformationOpenFDABrandName:query completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            } else {
                [self queryOpenFDAGeneric:query];
            }
        }
    }];
}

-(void) queryOpenFDAGeneric:(NSString* )query {
    [[APIManager shared] getDrugInformationOpenFDAGenericName:query completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            } else {
                [self queryRxNorm:query];
            }
        }
    }];
}

-(void) queryRxNorm:(NSString*) query{
    [[APIManager shared] getDrugInformationRxNorm:query completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            NSDictionary *dictionary = information[@"drugGroup"];
            NSArray *results = dictionary[@"conceptGroup"];
            if (results != nil) {
                NSDictionary *drugData = results[1];
                NSArray *drugResults = drugData[@"conceptProperties"];
                NSDictionary* drugActualResults = drugResults[0];
                self.rxNormDrugInformation = drugActualResults;
                NSString* rxcuiString = drugActualResults[@"rxcui"];
                [self queryUsingRxcui:rxcuiString];
            } else {
                
            }
        }
    }];
}

-(void) queryUsingRxcui:(NSString* )rxcui{
    [[APIManager shared] getDrugInformationOpenFdaUsingRxcui: rxcui completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            } else {
                NSArray *lastQuery = [self.rxNormDrugInformation[@"name"] componentsSeparatedByString:@" "];
                NSMutableString *drugName = [[NSMutableString alloc]init];
                BOOL isDrugName = YES;
                for (int i = 0; i < lastQuery.count && isDrugName; i++) {
                    NSString *result =  lastQuery[i];
                    unichar firstCharacter = [result characterAtIndex:0];
                    NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
                    if ([numericSet characterIsMember:firstCharacter]) { // Starts with a number so not the drug name
                        isDrugName = NO;
                    } else {
                        [drugName appendString: [NSString stringWithFormat:@"%@ ", result]];
                    }
                }
                [self queryOpenFDABrand:drugName];
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
