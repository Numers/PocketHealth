//
//  PHAttentionOrganizationTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAttentionOrganizationTableViewCell.h"
#import "GlobalVar.h"
#import "UIImageView+WebCache.h"
#import "Organization.h"

@implementation PHAttentionOrganizationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithOrganization:(Organization *)organization
{
    [_imgHeadImage.layer setCornerRadius:5.f];
    [_imgHeadImage.layer setMasksToBounds:YES];
    [_imgHeadImage sd_setImageWithURL:[NSURL URLWithString:organization.organizationHeadImage] placeholderImage:[UIImage imageNamed:DefaultOrganizationHeadImage]];
    _lblOrganizationName.text = organization.organizationName;
    _lblOrganizationLevel.text = organization.organizationLevel;
    _lblOrganizationTel.text = organization.organizationTel;
    _lblOrganizationAddress.text = organization.organizationAddress;
}
@end
