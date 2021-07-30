//
//  ReminderCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "ReminderCell.h"
@import UserNotifications;

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
    NSDate *time = self.reminder[@"alarm"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [formatter stringFromDate:time]];
    self.prescriptionNameLabel.text = [NSString stringWithFormat:@"Prescription: %@", self.reminder[@"prescriptionName"]];
    self.instructionLabel.text = [NSString stringWithFormat:@"Instructions: %@", self.reminder[@"instruction"]];
    // self.quantityLabel.text = [NSString stringWithFormat:@"Quantity: %@ %@ left", quantity, @"tablets"];
    self.alarmIdentifier = self.reminder[@"alarmIdentifier"];
    [self setAlarm];
}


- (void)setAlarm {
    /* Setup notifications
     * Link: (https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html)
     */
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Prescription Reminder" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"Time to take %@", self.prescriptionNameLabel.text]
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    // Configure an 'alarm'
    NSDateComponents* date = [self getAlarmTime];
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                                              triggerWithDateMatchingComponents:date repeats:YES];
    
    // Create the request object.
    UNNotificationRequest* request = [UNNotificationRequest
                                      requestWithIdentifier:self.alarmIdentifier content:content trigger:trigger];
    
    // Call it!
    [self setAlarm:request];
}

- (void) setAlarm:(UNNotificationRequest*) requestSaved {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        for (UNNotificationRequest *request in requests) {
            if ([request.identifier isEqual:requestSaved.identifier])
                return;
        }
        [center addNotificationRequest:requestSaved withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }];
}


- (NSDateComponents*) getAlarmTime{
    NSDate *time = self.reminder[@"alarm"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSArray *wholeTime  = [[formatter stringFromDate:time] componentsSeparatedByString:@":"];
    
    int hours = [wholeTime[0] intValue];
    NSString *minute = [wholeTime[1] componentsSeparatedByString:@" "][0];
    NSString *amPm = [wholeTime[1] componentsSeparatedByString:@" "][1];
    if ([amPm isEqual:@"PM"] && hours != 12) {
        hours += 12;
    } else if ([amPm caseInsensitiveCompare:@"AM"] && hours == 12) {
        hours = 0;
    }
    
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.hour = hours;
    date.minute = [minute intValue];
    return date;
}

@end
