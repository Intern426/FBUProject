//
//  Prescription.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Prescription : NSObject

// Required information for List
@property (nonatomic, strong) NSString *displayName; // what will show up on the cell's title
@property (nonatomic, strong) NSString *dosageAmount;
@property (nonatomic, strong) NSString *price30;
@property (nonatomic, strong) NSString *price90;
@property (nonatomic, strong) NSString *amount30;
@property (nonatomic, strong) NSString *amount90;
@property (nonatomic, strong) PFObject *prescriptionPointer; // refers to the data saved in Parse

// Just for checkout purposes!
@property (nonatomic) int quantity;
@property (nonatomic) int selectedDays; // 30 days or 90 days - corresponds to segmented control: 0 = 30 days, 1 = 90 days.

+ (NSMutableArray *)prescriptionsDataInArray:(NSArray *)data;
- (instancetype)initWithParseData:(PFObject *)prescription;

- (NSNumber*) retrievePrice30;
- (NSNumber*) retrievePrice90;

@end

NS_ASSUME_NONNULL_END
