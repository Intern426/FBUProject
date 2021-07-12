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
    self.dosageLabel.text = [NSString stringWithFormat:@"Dosage: %@", LoremIpsum.word];;
    self.priceLabel.text = [NSString stringWithFormat:@"Price: %@", LoremIpsum.word];
    self.ndcLabel.text = [NSString stringWithFormat:@"NDC: %@", LoremIpsum.word];
    self.pharmacyLabel.text = [NSString stringWithFormat:@"Pharmacy: %@", LoremIpsum.word];
}
@end
