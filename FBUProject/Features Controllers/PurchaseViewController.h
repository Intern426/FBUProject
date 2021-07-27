//
//  PurchaseViewController.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/21/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PurchaseViewControllerDelegate <NSObject>

-(void) clearCart;

@end

@interface PurchaseViewController : UIViewController

@property (nonatomic) double cost;
@property (nonatomic, strong) NSMutableArray *prescriptions;
@property (weak, nonatomic) id<PurchaseViewControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
