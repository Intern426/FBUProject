//
//  ProfileViewController.h
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileViewControllerDelegate <NSObject>

-(void) updateFavorites;

@end


@interface ProfileViewController : UIViewController

@property (nonatomic, weak) id<ProfileViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
