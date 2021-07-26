//
//  APIManager.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/20/21.
//

#import <Foundation/Foundation.h>
#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Order.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;
+ (instancetype) sharedSquare;

- (void) getDrugsWithCompletion:(void(^)(NSArray*, NSError*)) completion; // nothing significant about withCompletion suffix, just makes it clear that you're passing a completion

- (void)uploadOrderWithCompletion:(NSMutableDictionary *)order completion:(void (^)(NSDictionary *order, NSError *error))completion;

- (void) uploadPaymentWithCompletion: (NSMutableDictionary*) amount completion:  (void (^)(NSDictionary * payment, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
