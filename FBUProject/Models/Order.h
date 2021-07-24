//
//  Order.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Order : NSObject

@property (nonatomic, strong) NSString *customer_id; // Use Parse's object ID
@property (nonatomic, strong) NSString *location_id;


@end

NS_ASSUME_NONNULL_END
