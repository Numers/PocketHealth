//
//  PHOrganizationTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOrganizationTableViewCell.h"
#import "Organization.h"
#import "UIImageView+WebCache.h"
#import "GlobalVar.h"

@implementation PHOrganizationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithOrganization:(Organization *)organization
{
    [_lblOrganizationName setText:organization.organizationName];
    [_lblOrganizationLevel setText:organization.organizationLevel];
    [_lblOrganizationAddress setText:organization.organizationAddress];
    [_imgHeadImageView sd_setImageWithURL:[NSURL URLWithString:organization.organizationHeadImage] placeholderImage:[UIImage imageNamed:DefaultOrganizationHeadImage]];
    [_imgHeadImageView.layer setCornerRadius:5.f];
    [_imgHeadImageView.layer setMasksToBounds:YES];
}
@end
