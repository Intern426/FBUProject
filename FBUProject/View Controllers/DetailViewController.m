//
//  DetailViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/26/21.
//

#import "DetailViewController.h"
#import "APIManager.h"
#import "MBProgressHUD.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSDictionary *drugInformation;
@property (nonatomic, strong) NSDictionary *rxNormDrugInformation;
@property (nonatomic) BOOL keepLooking;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString* searchingDrugName = self.prescription.displayName;
    // TODO: Fix this. In some cases, can get away with just searching the whole display name but in cases like Zmax ER (where ER = extended release)
    // TODO: it just confuses query
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
    //    3.1 Save the data for RxNorm so you don't have to call it again.
    //    3.2 Make a call to openFDA using search = rxcui.exact
    // 4. Make a call to openFDA using the name RxNorm returns.
    //  --> For example, Zmax is also known as Azithromycin and RxNorm will return it's generic name to you as it's name field.
    //      so search through openFDA for this name instead of Zmax, and you get results.
    
}

-(void) queryOpenFDABrand:(NSString* )query {
    [[APIManager shared] getDrugInformationOpenFDABrandName:query completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [self displayError];
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
            [self displayError];
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            } else {
                if (self.keepLooking)
                    [self queryRxNorm:query];
                else {
                    [self displayError];
                }
            }
        }
    }];
}

-(void) queryRxNorm:(NSString*) query{
    [[APIManager shared] getDrugInformationRxNorm:query completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [self displayError];
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
                [self displayError];
            }
        }
    }];
}

-(void) displayError{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Currently cannot get more information on the drug. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        [self.navigationController popViewControllerAnimated:true];
    }];
    
    [alert addAction:defaultAction];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) queryUsingRxcui:(NSString* )rxcui{
    [[APIManager shared] getDrugInformationOpenFdaUsingRxcui: rxcui completion:^(NSDictionary * _Nonnull information, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [self displayError];
        } else {
            if (information[@"results"]) {
                NSArray *result = information[@"results"];
                self.drugInformation = result[0]; // for now, just grab the data from the first manufacturer company
                [self displayInformation];
            } else {
                self.keepLooking = false;
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
        //    NSArray *descriptionInfo = self.drugInformation[@"description"];
        //   NSString *description = descriptionInfo[0];
        //   if ([description containsString:@"inactive ingredient"]) {
        //    [self findInactiveIngredients:description];
        //  } else {
        self.inactiveIngredientLabel.hidden = YES;
        // }
    }
    if (self.drugInformation[@"purpose"]) {
        NSArray *purposeInfo = self.drugInformation[@"purpose"];
        self.purposeLabel.text = purposeInfo[0];
    } else {
        self.purposeLabel.hidden = YES;
    }
    [self showFields];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


// TODO: Improve method or possibly take it out.
// Refer to this StackOverflow Post: https://stackoverflow.com/questions/32168581/split-paragraphs-into-sentences
-(void) findInactiveIngredients:(NSString*) description{
    NSArray* descriptionSentences = [description componentsSeparatedByString:@"."];
    BOOL noFoundIngredients = YES;
    for (int i = 0; i < descriptionSentences.count && noFoundIngredients; i++) {
        NSString *sentence = descriptionSentences[i];
        if ([sentence containsString:@"inactive ingredient"]) {
            NSArray* words = [sentence componentsSeparatedByString:@"inactive ingredient"];
            self.inactiveIngredientLabel.text = words[1];
        }
    }
    self.inactiveIngredientLabel.text = @"It's there.";
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

-(void) showFields{
    self.activeIngredientLabel.hidden = false;
    self.amountLabel.hidden = false;
    self.brandLabel.hidden = false;
    self.cartButton.hidden = false;
    self.dosageHolderLabel.hidden = false;
    self.dosageLabel.hidden = false;
    self.likeButton.hidden = false;
    self.manufacturerLabel.hidden = false;
    self.priceLabel.hidden = false;
    self.quantityControl.hidden = false;
    self.routeLabel.hidden = false;
    self.searchButton.hidden = false;
    self.qualityHolderLabel.hidden = false;
    self.priceHolderLabel.hidden = false;
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
