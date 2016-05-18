//
//  PHInterestingGroupTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHInterestingGroupTableViewCell.h"
#import "Group.h"
#import "UIImageView+WebCache.h"
#import "GlobalVar.h"
@implementation PHInterestingGroupTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithGroup:(Group *)group
{
    [_imgHeadImage sd_setImageWithURL:[NSURL URLWithString:group.groupHeadImage] placeholderImage:[UIImage imageNamed:DefaultGroupHeadImage]];
    _lblGroupName.text = group.groupName;
    _lblMemberCount.text = [NSString stringWithFormat:@"%ld人",group.groupMemberCount];
    _lblIntroduction.text = group.groupBriefIntroduction;
}
@end
