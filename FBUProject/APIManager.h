//
//  APIManager.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/20/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (instancetype)shared;

- (void) getDrugsWithCompletion:(void(^)(NSArray*, NSError*)) completion; // nothing significant about withCompletion suffix, just makes it clear that you're passing a completion

@end

NS_ASSUME_NONNULL_END
