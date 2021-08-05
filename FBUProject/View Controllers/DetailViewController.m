//
//  DetailViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/26/21.
//

#import "DetailViewController.h"
#import "APIManager.h"
#import "MBProgressHUD.h"
@import NaturalLanguage;

@interface DetailViewController ()

@property (nonatomic, strong) NSDictionary *drugInformation;
@property (nonatomic, strong) NSDictionary *rxNormDrugInformation;
@property (nonatomic) BOOL keepLooking;

@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel; // the company that provided this information on openFDA!
@property (weak, nonatomic) IBOutlet UILabel *activeIngredientLabel; //AKA the generic name
@property (weak, nonatomic) IBOutlet UILabel *brandLabel; // brand name(s), brands that sell this drug
@property (weak, nonatomic) IBOutlet UILabel *inactiveIngredientLabel;// may or may not be visible depending on whether or not I can get this information
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel; // may be known as purpose or indications/usage in openFDA
@property (weak, nonatomic) IBOutlet UILabel *routeLabel; //oral, subcutaneous, etc.

// Fields already known from Prescription database
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *quantityControl;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

// Fields that are created just to hide/show while waiting for the load.
@property (weak, nonatomic) IBOutlet UILabel *dosageHolderLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UILabel *qualityHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *additionalInfoButton;

@property (nonatomic) BOOL grabNextSentence;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    self.keepLooking = YES;
    self.grabNextSentence = NO;
    self.manufacturerInfoLabel.layer.cornerRadius = 10;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString* searchingDrugName = self.prescription.displayName;
    NSArray* splitDrugName = [searchingDrugName componentsSeparatedByString:@" "];
    if (splitDrugName.count > 1) {
        searchingDrugName = splitDrugName[0];
    }
    [super viewDidLoad];
    
    [self.likeButton setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart.fill"] forState:UIControlStateSelected];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart"] forState:UIControlStateNormal];
    
    [self.navigationItem setTitle:self.prescription.displayName];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Flow of the API Calls
    // 1. Make a call to openFDA using search = BRAND_NAME
    // 2. Make a call to openFDA using search = GENERIC_NAME
    // 3. Make a call to RxNorm with the drug name and see if the rxcui number gets you results so
    //    3.1 Save the data for RxNorm so you don't have to call it again.
    //    3.2 Make a call to openFDA using search = rxcui.exact
    // 4. Make a call to openFDA using the name RxNorm returns.
    //  --> For example, Zmax is also known as Azithromycin and RxNorm will return it's generic name to you as it's name field.
    //      so search through openFDA for this name instead of Zmax, and you get results.
    [self queryOpenFDABrand:searchingDrugName];
}

- (void)viewDidAppear:(BOOL)animated{
    PFUser* currentUser = [PFUser currentUser];
    if (currentUser[@"savedDrugs"]) {
        [self checkForSavedFavorites:currentUser[@"savedDrugs"]];
    }
    if (currentUser[@"buyingDrugs"]) {
        [self checkForBoughtDrugs:currentUser[@"buyingDrugs"]];
    }
}

-(void) checkForSavedFavorites:(NSArray*) savedDrugs{
    for (int i = 0; i < savedDrugs.count; i++) {
        PFObject *object = savedDrugs[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object.objectId]];
        if ([self.prescription isEqual:prescription])
            self.likeButton.selected = YES;
    }
}

-(void) checkForBoughtDrugs:(NSArray*) boughtDrugs{
    for (int i = 0; i < boughtDrugs.count; i++) {
        NSDictionary *object = boughtDrugs[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object[@"item"]]];
        if ([self.prescription isEqual:prescription])
            self.cartButton.selected = YES;
    }
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
                self.drugInformation = result[0];
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
        NSArray *descriptionInformation = self.drugInformation[@"description"];
        NSString *description = descriptionInformation[0];
        if ([description containsString:@"inactive ingredient"])
            [self findInactiveIngredients:description];
        else
            self.inactiveIngredientLabel.hidden = YES;
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
-(void) findInactiveIngredients:(NSString*) description{
    NSRange range = NSMakeRange(0, description.length);
    NLTokenizer* tokenizer = [[NLTokenizer alloc] initWithUnit:NLTokenUnitSentence];
    tokenizer.string = description;
    NSMutableString* inactiveIngredient = [[NSMutableString alloc] init];
    [tokenizer enumerateTokensInRange:range usingBlock:^(NSRange tokenRange, NLTokenizerAttributes flags, BOOL * _Nonnull stop) {
        NSString *sentence = [description substringWithRange:tokenRange];
        if (self.grabNextSentence) {
            [inactiveIngredient appendString:sentence];
            self.grabNextSentence = NO;
        } else {
        if ([[description substringWithRange:tokenRange] containsString:@"inactive ingredient"]) {
                NSArray* array = [sentence componentsSeparatedByString:@"inactive ingredients"];
                if (array == 0)
                    array = [sentence componentsSeparatedByString:@"inactive ingredient"];
                if (array.count > 1) {
                    if ([sentence hasSuffix:@"No. "]) {
                        [inactiveIngredient appendString:array[1]];
                        self.grabNextSentence = YES;
                    }
                }
            }
        }
    }];
    if (inactiveIngredient.length != 0) {
    if ([inactiveIngredient containsString:@":"])
        self.inactiveIngredientLabel.text = [NSString stringWithFormat:@"Inactive Ingredient%@", inactiveIngredient];
    else
        self.inactiveIngredientLabel.text = [NSString stringWithFormat:@"Inactive Ingredient:%@", inactiveIngredient];
    self.inactiveIngredientLabel.hidden = false;
    }
}

-(void)displayBuyingInformation{
    if ([self.prescription.dosageAmount isEqual:@""])
        self.dosageLabel.hidden = YES;
    else
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
    self.additionalInfoButton.hidden = false;
}

- (IBAction)didTapInfo:(id)sender {
    self.manufacturerInfoLabel.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.manufacturerInfoLabel.hidden = YES;
    });
}



- (IBAction)didTapFavorite:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"savedDrugs"]) {
        currentUser[@"savedDrugs"] = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *prescriptionInfo = [[NSMutableDictionary alloc] init];
    [prescriptionInfo addEntriesFromDictionary:@{@"name": [NSString stringWithFormat:@"%@ %@", self.prescription.displayName, self.prescription.dosageAmount]}];
    [prescriptionInfo addEntriesFromDictionary:@{@"item": self.prescription.prescriptionPointer.objectId}];
    [self updateUserAtKey:@"savedDrugs" withObject:prescriptionInfo updateButton:self.likeButton];
}

- (IBAction)didTapBuy:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"buyingDrugs"]) {
        currentUser[@"buyingDrugs"] = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *prescriptionInfo = [[NSMutableDictionary alloc] init];
    [prescriptionInfo addEntriesFromDictionary:@{@"item": self.prescription.prescriptionPointer.objectId}];
    [prescriptionInfo addEntriesFromDictionary:@{@"name": [NSString stringWithFormat:@"%@ %@", self.prescription.displayName, self.prescription.dosageAmount]}];
    [prescriptionInfo addEntriesFromDictionary:@{@"quantity": @"1"}];
    [prescriptionInfo addEntriesFromDictionary:@{@"number_of_days": [NSString stringWithFormat:@"%d", self.quantityControl.selectedSegmentIndex]}];
    [self updateUserAtKey:@"buyingDrugs" withObject:prescriptionInfo updateButton:self.cartButton];
}

-(void) updateUserAtKey: (NSString*) key withObject: (NSObject*) object updateButton:(UIButton*) button {
    PFUser *currentUser = [PFUser currentUser];
    if (button.isSelected) {
        [currentUser removeObject:object forKey:key];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"%@", [NSString stringWithFormat:@"User's key %@ was updated - deleted item.", key]);
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        button.selected = NO;
    } else {
        [currentUser addObject:object forKey:key];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"%@", [NSString stringWithFormat:@"User's key %@ was updated - added item.", key]);
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        if (button != nil)
            button.selected = YES;
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

