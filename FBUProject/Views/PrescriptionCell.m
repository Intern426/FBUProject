//
//  PrescriptionCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "PrescriptionCell.h"
#import "Parse/Parse.h"

@implementation PrescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.likeButton setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart.fill"] forState:UIControlStateSelected];
    [self.cartButton setImage:[UIImage systemImageNamed:@"cart"] forState:UIControlStateNormal];
    [self.expandedButton setImage:[UIImage systemImageNamed:@"plus.circle"] forState:UIControlStateNormal];
    [self.expandedButton setImage:[UIImage systemImageNamed:@"minus.circle"] forState:UIControlStateSelected];
    self.expandedButton.tintColor = [UIColor whiteColor];
    self.stackView.arrangedSubviews.lastObject.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)setPrescription: (Prescription*) prescription{
    _prescription = prescription;
    self.likeButton.selected = NO;
    self.cartButton.selected = NO;
    self.nameLabel.text = self.prescription.displayName;
    if ([self.prescription.dosageAmount isEqual:@""] || self.prescription.dosageAmount == nil)
        self.dosageLabel.hidden = YES;
    else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.prescription.displayName, self.prescription.dosageAmount];
        self.dosageLabel.text = [NSString stringWithFormat:@"Dosage: %@", self.prescription.dosageAmount];
    }
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
    [self updateUserAtKey:@"savedDrugs" withObject:self.prescription.prescriptionPointer updateButton:self.likeButton];
}

- (IBAction)didTapDelete:(id)sender {
    [self setEditing:YES];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:self.prescription.prescriptionPointer forKey:@"savedDrugs"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been saved.
            NSLog(@"Drug was removed");
            [self.profileDelegate updateFavorites:self.prescription];
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

- (IBAction)didTapExpand:(id)sender {
    if (self.collapse) {
        self.stackView.arrangedSubviews.lastObject.hidden = YES;
        self.expandedButton.selected = NO;
        self.collapse = NO;
    } else {
        self.stackView.arrangedSubviews.lastObject.hidden = NO;
        self.expandedButton.selected = YES;
        self.collapse = YES;
    }
    [self.stackDelegate collapseCell];
}

@end
