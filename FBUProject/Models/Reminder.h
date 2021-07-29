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

@interface Reminder : PFObject<PFSubclassing>

@property (strong, nonatomic) NSDate *alarm;
@property (strong, nonatomic) PFObject *prescription;
@property (strong, nonatomic) NSString *prescriptionName;

@property (strong, nonatomic) NSString *instruction;
@property (nonatomic) int quantityLeft;
@property (strong, nonatomic) PFUser *author;

-(instancetype) initWithPrescription:(Prescription*) prescription name:(NSString*) name time: (NSDate*) date instructions: (NSString*) instruction quantity: (int) quantity;
-(instancetype) initWithParseData:(PFObject*) reminder;
+ (NSMutableArray *)initWithArray:(NSArray *)data;


@end

NS_ASSUME_NONNULL_END
