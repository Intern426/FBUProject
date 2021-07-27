//
//  DetailViewController.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/26/21.
//

#import <UIKit/UIKit.h>
#import "Prescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel; // the company that provided this information on openFDA!
@property (weak, nonatomic) IBOutlet UILabel *activeIngredientLabel; //AKA the generic name
@property (weak, nonatomic) IBOutlet UILabel *brandLabel; // brand name(s), brands that sell this drug
@property (weak, nonatomic) IBOutlet UILabel *inactiveIngredientLabel;// may or may not be visible depending on whether or not I can get this information
@property (weak, nonatomic) IBOutlet UILabel *purposeLabel; // may be known as purpose or indications/usage in openFDA
@property (weak, nonatomic) IBOutlet UILabel *routeLabel; //oral, subcutaneous, etc.

// Fields already known from Prescription database
@property (weak, nonatomic) IBOutlet UILabel *dosageLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *quantityControl;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) Prescription *prescription;

// Fields that are created just to hide/show while waiting for the load.
@property (weak, nonatomic) IBOutlet UILabel *dosageHolderLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UILabel *qualityHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceHolderLabel;

@end

NS_ASSUME_NONNULL_END
