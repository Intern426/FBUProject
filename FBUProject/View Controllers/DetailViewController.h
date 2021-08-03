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

@property (nonatomic, strong) Prescription *prescription; // Received from Prescription List

@end

NS_ASSUME_NONNULL_END
