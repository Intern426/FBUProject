//
//  Prescription.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Prescription : NSObject

// Required information
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *genericName;
@property (nonatomic) double dosageAmount;
@property (nonatomic, strong) NSString *dosageForm; // i.e. tablet
@property (nonatomic) double price;
@property (nonatomic, strong) NSString* pharamcy;

// GoodRX requirement
@property (nonatomic, strong) NSString *url; //Links back to the GoodRX website as per Terms and Conditions

// Additional/Detail info
 // Active Ingredient
 // Inactive Ingredient
 // --> Might drop ingredients - difficult to acquire and frankly kinda confusing  so instead might just list
 // Purpose (i.e. Pain reliver)
 // Side Effects and Warnings


@end

NS_ASSUME_NONNULL_END
