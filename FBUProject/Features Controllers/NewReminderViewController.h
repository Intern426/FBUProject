//
//  NewReminderViewController.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/16/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NewReminderViewControllerDelegate <NSObject>

-(void) updateReminder;

@end

@interface NewReminderViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
