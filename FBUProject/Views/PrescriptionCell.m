//
//  PrescriptionCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "PrescriptionCell.h"
#import "LoremIpsum/LoremIpsum.h"

@implementation PrescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    self.pricesButton.menu = [self createMenu];
    self.pricesButton.showsMenuAsPrimaryAction = YES;
    
}

-(UIMenu*) createMenu{
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
            self.pharmacyLabel.text = @"Pharmacy: Walgreens";
        }];
        [priceOptions addObject:testAction];
    }
    
    
    UIMenu *menu = [UIMenu menuWithChildren:priceOptions];
    return menu;
    
}
- (IBAction)changedValue:(id)sender {
    if(![self.pricesButton.titleLabel.text isEqual:
         @"Select Price"]) {
        self.pharmacyLabel.hidden = NO;
        self.pharmacyLabel.text = @"Pharmacy: Walgreens";
    }
}

- (IBAction)didTapPriceSelection:(id)sender {
    if(![self.pricesButton.titleLabel.text isEqual:
         @"Select Price"]) {
        self.pharmacyLabel.hidden = NO;
        self.pharmacyLabel.text = @"Pharmacy: Walgreens";
    }
}


- (IBAction)didChangePriceSelection:(id)sender {
    if(![self.pricesButton.titleLabel.text isEqual:
         @"Select Price"]) {
        self.pharmacyLabel.hidden = NO;
        self.pharmacyLabel.text = @"Pharmacy: Walgreens";
    }
}

@end
