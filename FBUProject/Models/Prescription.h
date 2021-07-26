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
@property (nonatomic, strong) NSString *dosageForm;
@property (nonatomic, strong) NSString *price30;
@property (nonatomic, strong) NSString *price90;
@property (nonatomic, strong) NSString *amount30;
@property (nonatomic, strong) NSString *amount90;
@property (nonatomic, strong) PFObject *prescriptionPointer; // refers to the data saved in Parse

@property (nonatomic) int quantity; // Just for checkout purposes!


// Additional/Detail info
 // Active Ingredient
 // Inactive Ingredient
 // Purpose (i.e. Pain reliver)
 // Side Effects and Warnings
 // Generic and Brand name
 // Manufacturer who provided info


+ (NSMutableArray *)prescriptionsDatainArray:(NSArray *)data;
+ (NSMutableArray *)prescriptionsWithArray:(NSArray *)dictionaries;
+ (NSMutableArray *)prescriptionsWithStrings:(NSArray *)dictionaries;

- (instancetype)initWithParseData:(PFObject *)prescription;

- (NSNumber*) retrievePrice30;

@end

NS_ASSUME_NONNULL_END
