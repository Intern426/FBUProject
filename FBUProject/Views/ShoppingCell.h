//
//  ShoppingCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/19/21.
//

#import <UIKit/UIKit.h>
#import "Prescription.h"

NS_ASSUME_NONNULL_BEGIN


@protocol ShoppingCellDelegate <NSObject>

-(void) updateShoppingList;
-(void) updateTotal;

@end

@interface ShoppingCell : UITableViewCell


@property (strong, nonatomic) Prescription *prescription;
@property (weak, nonatomic) id<ShoppingCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *drugNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UIButton *amountButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *quantityControl;
@end

NS_ASSUME_NONNULL_END
