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
    self.prescription = [[Prescription alloc] init];
    self.prescription.genericName = self.nameLabel.text;
    self.quantityLabel.text = [NSString stringWithFormat:@"Quantity: %@", LoremIpsum.word];;
    self.pharmacyLabel.text = [NSString stringWithFormat:@"Pharmacy: %@", LoremIpsum.word];
    
    self.pricesButton.menu = [self createMenu];
    self.pricesButton.showsMenuAsPrimaryAction = YES;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser[@"savedDrugs"]) {
        NSArray *array = currentUser[@"savedDrugs"];
        if ([array containsObject:self.nameLabel.text]) {
            self.likeButton.selected = YES;
        }
    }
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
            self.searchButton.hidden = NO;
            self.pharmacyLabel.text = @"Pharmacy: Walgreens";
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
        [currentUser removeObject:self.prescription.genericName forKey:@"savedDrugs"];
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
        [currentUser addObject:self.prescription.genericName forKey:@"savedDrugs"];
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

- (IBAction)didTapSearch:(id)sender {
}

@end
