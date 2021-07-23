//
//  PrescriptionCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Prescription.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PrescriptionCellDelegate <NSObject>

-(void) updateFavorites;

@end

@interface PrescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;


@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *quantityControl;

@property (weak, nonatomic) id<PrescriptionCellDelegate> delegate;

-(void)setPrescription:(Prescription *) prescription;

@property (strong, nonatomic) Prescription *prescription;

@end

NS_ASSUME_NONNULL_END
