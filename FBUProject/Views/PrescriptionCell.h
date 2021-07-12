//
//  PrescriptionCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Prescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ndcLabel;
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *pharmacyLabel;
@property (strong, nonatomic) Prescription *prescription;

@end

NS_ASSUME_NONNULL_END
