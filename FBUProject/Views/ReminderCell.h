//
//  ReminderCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ReminderCellDelegate <NSObject>

-(void) updateReminders;
-(void) displayError:(NSString*) error;

@end

@interface ReminderCell : UITableViewCell

@property (strong, nonatomic) Reminder* reminder;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *prescriptionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *alarmActiveButton;
@property (strong, nonatomic) NSString* alarmIdentifier;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;

@property (weak, nonatomic) id<ReminderCellDelegate> delegate;

- (void) checkAllNotifications;

@end

NS_ASSUME_NONNULL_END
