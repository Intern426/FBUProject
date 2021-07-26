//
//  Order.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Order : NSObject

@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *object_id; // Also known as idempotency_key when uploading to Parse SUPER IMPORTANT FOR PAYING!

@property (nonatomic, strong) NSMutableDictionary *line_items; // contains each individual prescription being bought

@property (nonatomic, strong) NSMutableDictionary *fullfillment; // contains the details of the order (Pickup or Shipping?)

-(void) buyPrescriptions:(NSMutableArray*) prescriptions;

@end

NS_ASSUME_NONNULL_END
