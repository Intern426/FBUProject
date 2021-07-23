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

- (void)postOrderWithCompletion:(NSString *)text completion:(void (^)(Order *order, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
