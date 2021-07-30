//
//  CollapsibleCell.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/29/21.
//

#import "CollapsibleCell.h"
#import "CollapseView.h"

@implementation CollapsibleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.separator = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) configure:(CollapseView*) viewModel{
    self.textLabel.text = viewModel.label;
    if(viewModel.needsSeparator) {
        self.separator.backgroundColor = UIColor.grayColor;
        [self.contentView addSubview:self.separator];
    } else {
        [self.separator removeFromSuperview];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float separatorHeight = 1 / [UIScreen mainScreen].scale;
    self.separator.frame = CGRectMake(self.separatorInset.left, self.contentView.bounds.size.height - separatorHeight, self.contentView.bounds.size.width-self.separatorInset.left-self.separatorInset.right, separatorHeight);
}
@end
