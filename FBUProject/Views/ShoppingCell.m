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
    self.drugNameLabel.text = [NSString stringWithFormat:@"Name: %@", self.prescription.displayName];
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
    [self.delegate updateTotal];
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
    NSArray *array = currentUser[@"buyingDrugs"];  //TODO: Better way to do this??
    for (int i = 0; i < array.count; i++) {
        NSDictionary *object = array[i];
        if ([object[@"item"] isEqual:self.prescription.prescriptionPointer.objectId]) {
            [currentUser removeObject:object forKey:@"buyingDrugs"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The PFUser has been saved.
                    NSLog(@"Drug was removed");
                    [self.delegate updateShoppingList];
                    return;
                } else {
                    // There was a problem, check error.description
                    NSLog(@"boo.....%@", error.localizedDescription);
                }
            }];
        }
    }
}

@end
