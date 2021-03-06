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

- (void)uploadOrderWithCompletion:(NSMutableDictionary *)order completion:(void (^)(NSDictionary *order, NSError *error))completion;
- (void) uploadPaymentWithCompletion: (NSMutableDictionary*) amount completion:  (void (^)(NSDictionary * payment, NSError * error))completion;
- (void) getDrugInformationOpenFDABrandName:(NSString*) drugName completion: (void (^)(NSDictionary * information, NSError * error))completion;
- (void) getDrugInformationOpenFDAGenericName:(NSString*) drugName completion: (void (^)(NSDictionary * information, NSError * error))completion;

- (void) getDrugInformationRxNorm:(NSString *)drugName completion:(void (^)(NSDictionary * information, NSError * error))completion;
- (void) getDrugInformationOpenFdaUsingRxcui:(NSString *)rxcui completion:(void (^)(NSDictionary * _Nonnull, NSError * _Nonnull))completion;

- (void) getNearbyWalgreens: (NSMutableDictionary*) parameters completion:  (void (^)(NSDictionary * stores, NSError * error))completion;
- (void) getWalgreenDetails: (NSString*) storeNumber completion:  (void (^)(NSDictionary * details, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
