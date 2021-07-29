//
//  ReminderCell.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReminderCell : UITableViewCell

@property (strong, nonatomic) Reminder* reminder;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *prescriptionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *alarmActiveButton;
@property (strong, nonatomic) NSString* alarmIdentifier;


@end

NS_ASSUME_NONNULL_END
