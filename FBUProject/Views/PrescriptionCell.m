//
//  PrescriptionCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "PrescriptionCell.h"
#import "Parse/Parse.h"
#import "ProfileViewController.h"

@implementation PrescriptionCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.likeButton setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart.fill"] forState:UIControlStateSelected];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(void)setPrescription: (Prescription*) prescription{
     _prescription = prescription;
    self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", self.prescription.displayName];
    self.dosageLabel.text = [NSString stringWithFormat:@"Dosage: %@", self.prescription.dosageAmount];
    if (self.quantityControl.selectedSegmentIndex == 0) {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount30];
        self.priceLabel.text = self.prescription.price30;
    } else {
        self.amountLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount90];
        self.priceLabel.text =  self.prescription.price90;
    }
    
    PFUser *currentUser = [PFUser currentUser];
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
        if ([prescription.displayName isEqual:self.prescription.displayName] && [prescription.dosageAmount isEqual:self.prescription.dosageAmount])
            self.likeButton.selected = YES;
    }
}

-(void) checkForBoughtDrugs:(NSArray*) boughtDrugs{
    for (int i = 0; i < boughtDrugs.count; i++) {
        NSDictionary *object = boughtDrugs[i];
        PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
        Prescription *prescription = [[Prescription alloc] initWithParseData:[query getObjectWithId:object[@"item"]]];
        if ([prescription.displayName isEqual:self.prescription.displayName] && [prescription.dosageAmount isEqual:self.prescription.dosageAmount])
            self.cartButton.selected = YES;
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



- (IBAction)didTapFavorite:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"savedDrugs"]) {
        currentUser[@"savedDrugs"] = [[NSMutableArray alloc] init];
    }
    if (self.likeButton.isSelected) {
        [currentUser removeObject:self.prescription.prescriptionPointer forKey:@"savedDrugs"];
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
        [currentUser addObject:self.prescription.prescriptionPointer forKey:@"savedDrugs"];
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
    [currentUser removeObject:self.prescription.prescriptionPointer forKey:@"savedDrugs"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been saved.
            NSLog(@"Drug was removed");
            [self.profileDelegate updateFavorites];
        } else {
            // There was a problem, check error.description
            NSLog(@"boo.....%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapDetail:(id)sender {
    [self.detailDelegate sendDetailInformation:self.prescription];
}

- (IBAction)didTapBuy:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser[@"buyingDrugs"]) {
        currentUser[@"buyingDrugs"] = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *prescriptionInfo = [[NSMutableDictionary alloc] init];
    [prescriptionInfo addEntriesFromDictionary:@{@"item": self.prescription.prescriptionPointer.objectId}];
    [prescriptionInfo addEntriesFromDictionary:@{@"quantity": @"1"}];
    
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
        self.cartButton.selected = NO;
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
