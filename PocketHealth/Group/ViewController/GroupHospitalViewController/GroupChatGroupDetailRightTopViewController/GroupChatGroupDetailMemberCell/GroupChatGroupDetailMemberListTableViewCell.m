//
//  GroupChatGroupDetailMemberListTableViewCell.m
//  PocketHealth
//
//  Created by YangFan on 15/1/17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupChatGroupDetailMemberListTableViewCell.h"

@implementation GroupChatGroupDetailMemberListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.autoresizesSubviews = NO;
//        [self loadViews];
//        [self constrainViews];
    }
    return self;
}

@end
