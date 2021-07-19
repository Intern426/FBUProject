//
//  PrescriptionCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "PrescriptionCell.h"
#import "LoremIpsum/LoremIpsum.h"
#import "Parse/Parse.h"
#import "ProfileViewController.h"

@implementation PrescriptionCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.likeButton setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [self setupPrescription];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setupPrescription{
    // _prescription = prescription;
    self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", LoremIpsum.firstName];
    self.quantityLabel.text = [NSString stringWithFormat:@"Quantity: %@", LoremIpsum.word];;
    self.pharmacyLabel.text = [NSString stringWithFormat:@"Pharmacy: %@", LoremIpsum.word];
    
    self.prescription = [[Prescription alloc] init];
    self.prescription.displayName = self.nameLabel.text;
    self.prescription.manufacturer = @"Generic";
    self.prescription.dosageAmount = @"500 mg";
    self.prescription.dosageForm = @"60 tablets";

    
    self.pricesButton.menu = [self createPriceMenu];
    self.pricesButton.showsMenuAsPrimaryAction = YES;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser[@"savedDrugs"]) {
        NSArray *array = currentUser[@"savedDrugs"];
        if ([array containsObject:self.nameLabel.text]) {
            self.likeButton.selected = YES;
        }
    }
}

-(UIMenu*) createPriceMenu{
    NSMutableArray* pricesGathered = [[NSMutableArray alloc] init];
    [pricesGathered addObject:[NSString stringWithFormat:@"%.2f", 19.99]];
    [pricesGathered addObject:[NSString stringWithFormat:@"%.2f", 30.99]];
    [pricesGathered addObject:[NSString stringWithFormat:@"%.2f", 60.99]];
    NSMutableArray *priceOptions = [[NSMutableArray alloc] init];
    
    for (NSString *price in pricesGathered) {
        UIAction *testAction = [UIAction actionWithTitle:price image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self.pricesButton setTitle:price forState:UIControlStateNormal];
            [self.pricesButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            self.pharmacyLabel.hidden = NO;
            self.searchButton.hidden = NO;
            NSArray* pharmacy = @[@"Walgreens", @"CVS", @"Rite Aid"];
            int random = arc4random_uniform(3);
            self.pharmacyLabel.text = pharmacy[random];
        }];
        [priceOptions addObject:testAction];
    }
    
    UIMenu *menu = [UIMenu menuWithChildren:priceOptions];
    return menu;
}

- (IBAction)didTapFavorite:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"savedDrugs"]) {
        currentUser[@"savedDrugs"] = [[NSMutableArray alloc] init];
    }
    if (self.likeButton.isSelected) {
        [currentUser removeObject:self.prescription.displayName forKey:@"savedDrugs"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"Drug was removed");
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.likeButton.selected = NO;
    } else {
        [currentUser addObject:self.prescription.displayName forKey:@"savedDrugs"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"Drug was favorited");
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.likeButton.selected = YES;
    }
}

- (IBAction)didTapDelete:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:self.prescription.displayName forKey:@"savedDrugs"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been saved.
            NSLog(@"Drug was removed");
            [self.delegate updateFavorites];
        } else {
            // There was a problem, check error.description
            NSLog(@"boo.....%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapBuy:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"buyingDrugs"]) {
        currentUser[@"buyingDrugs"] = [[NSMutableArray alloc] init];
    }
    NSMutableArray *prescriptionInfo = [[NSMutableArray alloc] init];
    [prescriptionInfo addObject:self.prescription.displayName];
    [prescriptionInfo addObject:self.prescription.manufacturer];
    [prescriptionInfo addObject:self.prescription.dosageForm];
    [prescriptionInfo addObject:self.prescription.dosageAmount];

    
    if (self.cartButton.isSelected) {
        [currentUser removeObject:prescriptionInfo forKey:@"buyingDrugs"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"Drug was removed from cart");
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.likeButton.selected = NO;
    } else {
        [currentUser addObject:prescriptionInfo forKey:@"buyingDrugs"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog(@"Drug was added to cart");
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.cartButton.selected = YES;
    }
}


/* For refactoring purpose!!! --> Can replace all the instances where I'm updating hte user with this general method 
-(void) updateUser: (BOOL) remove atKey: (NSString*) key withObject: (NSObject*) object {
    PFUser *currentUser = [PFUser currentUser];
    if (remove) {
        [currentUser removeObject:object forKey:key];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog([NSString stringWithFormat:@"User's key %@ was updated - deleted item.", key]);
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.likeButton.selected = NO;
    } else {
        [currentUser addObject:object forKey:key];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The PFUser has been saved.
                NSLog([NSString stringWithFormat:@"User's key %@ was updated - added item.", key]);
            } else {
                // There was a problem, check error.description
                NSLog(@"boo.....%@", error.localizedDescription);
            }
        }];
        self.likeButton.selected = YES;
    }
}
*/
@end
