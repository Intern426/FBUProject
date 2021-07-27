//
//  ReminderCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "ReminderCell.h"

@implementation ReminderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setReminder:(Reminder *)reminder{
    _reminder = reminder;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", self.reminder[@"alarm"]];
    self.prescriptionNameLabel.text = [NSString stringWithFormat:@"Prescription: %@", self.reminder[@"prescriptionName"]];
    self.instructionLabel.text = [NSString stringWithFormat:@"Instructions: %@", self.reminder[@"instruction"]];
   // self.quantityLabel.text = [NSString stringWithFormat:@"Quantity: %@ %@ left", quantity, @"tablets"];
}

@end
