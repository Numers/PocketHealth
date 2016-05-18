//
//  PHAttentionFriendTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAttentionFriendTableViewCell.h"
#import "Member.h"
#import "GlobalVar.h"
#import "UIImageView+WebCache.h"

@implementation PHAttentionFriendTableViewCell
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithMember:(Member *)member
{
    [_imgHeadImage.layer setCornerRadius:5.f];
    [_imgHeadImage.layer setMasksToBounds:YES];
    [_imgHeadImage sd_setImageWithURL:[NSURL URLWithString:member.headImage] placeholderImage:[UIImage imageNamed:DefaultUserHeadImage]];
    _lblNickName.text = member.nickName;
}
@end
