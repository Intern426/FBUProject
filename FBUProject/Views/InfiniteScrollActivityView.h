//  InfiniteScrollActivityView.h
//  Link: https://guides.codepath.org/ios/Table-View-Guide#adding-infinite-scroll

#import <UIKit/UIKit.h>

@interface InfiniteScrollActivityView : UIView

@property (class, nonatomic, readonly) CGFloat defaultHeight;

- (void)startAnimating;
- (void)stopAnimating;

@end
