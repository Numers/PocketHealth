//
//  PHAttentionDoctorTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAttentionDoctorTableViewCell.h"
#import "GlobalVar.h"
#import "UIImageView+WebCache.h"
#import "Member.h"

@implementation PHAttentionDoctorTableViewCell

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
    _lblNameAndTitle.text = [NSString stringWithFormat:@"%@ %@",member.realName,member.diJobTitle];
    _lblDepartment.text = member.diDepartment;
    _lblOrganizationName.text = member.organizationName;
}

@end
