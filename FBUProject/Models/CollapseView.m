//
//  CollapseView.m
//  FBUProject
//
//  StackOverflow: https://stackoverflow.com/questions/33186659/drop-down-list-in-uitableview-in-ios
//

#import "CollapseView.h"

@implementation CollapseView

-(instancetype) init:(NSString*)label children:(NSArray*) children isCollasped:(BOOL) isCollapsed{
    self = [super init];
    self.label = label;
    self.children = children;
    self.isCollapsed = isCollapsed;
    
    for (CollapseView *child in self.children) {
        child.needsSeparator = false;
    }
    CollapseView* lastChild = self.children.lastObject;
    lastChild.needsSeparator = true;
    return self;
}


@end
