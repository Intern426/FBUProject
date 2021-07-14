//
//  ReminderNotificationManager.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "ReminderNotificationManager.h"
@import UserNotifications;

@implementation ReminderNotificationManager

-(void) testNotifications{
    /* Setup notifications
     * Link: (https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html)
    */
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Hello hello!" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Time to take ...."
            arguments:nil];
    
    // Configure an 'alarm'
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = 12;
    date.minute = 44;
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
           triggerWithDateMatchingComponents:date repeats:NO];
     
    // Create the request object.
    UNNotificationRequest* request = [UNNotificationRequest
           requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
    
    // Call it!
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
       if (error != nil) {
           NSLog(@"%@", error.localizedDescription);
       }
    }];
    
}

@end
