//
//  PrescriptionCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Prescription.h"
#import "ProfileViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PrescriptionCellProfileDelegate <NSObject>

-(void) updateFavorites:(Prescription*) prescription;
@end

@protocol PrescriptionCellDetailDelegate <NSObject>

-(void) sendDetailInformation:(Prescription*) prescription;

@end

@protocol StackViewCollapseDelegate <NSObject>

-(void) collapseCell;

@end

@interface PrescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *quantityControl;
@property (weak, nonatomic) IBOutlet UILabel *deleteAnimationLabel;

//For display purposes
@property (weak, nonatomic) IBOutlet UIView *labelsContainerView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;


@property (weak, nonatomic) id<PrescriptionCellProfileDelegate> profileDelegate;
@property (weak, nonatomic) id<PrescriptionCellDetailDelegate> detailDelegate;
@property (weak, nonatomic) id<StackViewCollapseDelegate> stackDelegate;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutHeightConstraint;


-(void)setPrescription:(Prescription *) prescription;

@property (strong, nonatomic) Prescription *prescription;
@property (weak, nonatomic) IBOutlet UIButton *expandedButton;

@end

NS_ASSUME_NONNULL_END
