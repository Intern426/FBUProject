//
//  ShoppingCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/19/21.
//

#import "ShoppingCell.h"

@implementation ShoppingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setPrescription:(Prescription *)prescription{
    _prescription = prescription;
    self.quantityControl.selectedSegmentIndex = self.prescription.selectedDays;
    self.drugNameLabel.text = [NSString stringWithFormat:@"%@", self.prescription.displayName];
    if (self.quantityControl.selectedSegmentIndex == 0) {
        self.quantityLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount30];
        self.priceLabel.text = self.prescription.price30;
        self.prescription.selectedDays = 0;
    } else {
        self.quantityLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount90];
        self.priceLabel.text =  self.prescription.price90;
        self.prescription.selectedDays = 1;
    }
    self.dosageLabel.text = [NSString stringWithFormat:@"Dosage: %@", self.prescription.dosageAmount];
    
    [self.amountButton setTitle:[NSString stringWithFormat:@"%d", self.prescription.quantity] forState:UIControlStateNormal];
    self.amountButton.menu = [self createAmountMenu];
    self.amountButton.showsMenuAsPrimaryAction = YES;
}

-(UIMenu*) createAmountMenu{
    NSMutableArray *amountChoices = [[NSMutableArray alloc] init];
    for (int i = 1; i < 11; i++) {
        NSString *value = [NSString stringWithFormat:@"%d", i];
        UIAction *testAction = [UIAction actionWithTitle:value image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self.amountButton setTitle:value forState:UIControlStateNormal];
            [self.amountButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            self.prescription.quantity = [value intValue];
            [self.delegate updateTotal];
        }];
        [amountChoices addObject:testAction];
    }
    UIMenu *menu = [UIMenu menuWithChildren:amountChoices];
    return menu;
}

- (IBAction)didChangeQuantity:(id)sender {
    if (self.quantityControl.selectedSegmentIndex == 0) {
        self.quantityLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount30];
        self.priceLabel.text = self.prescription.price30;
        self.prescription.selectedDays = 0;
    } else {
        self.quantityLabel.text = [NSString stringWithFormat:@"X %@", self.prescription.amount90];
        self.priceLabel.text =  self.prescription.price90;
        self.prescription.selectedDays = 1;
    }
    [self.delegate updateTotal];
}

- (IBAction)didTapDelete:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableDictionary *prescriptionInfo = [[NSMutableDictionary alloc] init];
    [prescriptionInfo addEntriesFromDictionary:@{@"item": self.prescription.prescriptionPointer.objectId}];
    [prescriptionInfo addEntriesFromDictionary:@{@"name": [NSString stringWithFormat:@"%@ %@", self.prescription.displayName, self.prescription.dosageAmount]}];
    [prescriptionInfo addEntriesFromDictionary:@{@"quantity": [NSString stringWithFormat:@"%d", self.prescription.quantity]}];
    [prescriptionInfo addEntriesFromDictionary:@{@"number_of_days": [NSString stringWithFormat:@"%d", self.prescription.selectedDays]}];
    [currentUser removeObject:prescriptionInfo forKey:@"buyingDrugs"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The PFUser has been saved.
            NSLog(@"No longer buying drug.");
            [self.delegate updateShoppingList];
        } else {
            // There was a problem, check error.description
            NSLog(@"boo.....%@", error.localizedDescription);
        }
    }];
}

@end
