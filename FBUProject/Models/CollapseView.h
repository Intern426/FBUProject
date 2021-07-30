//
//  CollapseView.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/29/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollapseView : NSObject

@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSArray *children;
@property(nonatomic) BOOL isCollapsed;
@property(nonatomic) BOOL needsSeparator;


@end

NS_ASSUME_NONNULL_END
