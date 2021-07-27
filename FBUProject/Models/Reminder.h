//
//  Reminder.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import <Foundation/Foundation.h>
#import "Prescription.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Reminder : NSObject

@property (strong, nonatomic) NSDate *time;
@property (strong, nonatomic) Prescription *prescription;
@property (strong, nonatomic) NSString *prescriptionName;

@property (strong, nonatomic) NSString *instructions;
@property (nonatomic) int quantityLeft;
@property (strong, nonatomic) PFUser *assignedUser; 

@end

NS_ASSUME_NONNULL_END
