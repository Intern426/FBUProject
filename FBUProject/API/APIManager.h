//
//  APIManager.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/20/21.
//

#import <Foundation/Foundation.h>
#import "Order.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (instancetype)shared;
+ (instancetype) sharedSquare;

- (void)uploadOrderWithCompletion:(NSMutableDictionary *)order completion:(void (^)(NSDictionary *order, NSError *error))completion;
- (void) uploadPaymentWithCompletion: (NSMutableDictionary*) amount completion:  (void (^)(NSDictionary * payment, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
