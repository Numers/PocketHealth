//
//  PHPhysicalExamTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-1-21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPhysicalExamTableViewCell.h"
#import "PhysicalExamTable.h"
#import "CommonUtil.h"

@implementation PHPhysicalExamTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupCellWithPhysicalExamTable:(PhysicalExamTable *)physicalExamTable
{
//    [_imgTableIcon.layer setCornerRadius:5.f];
//    [_imgTableIcon.layer setMasksToBounds:YES];
    _lblOrganizationName.text = physicalExamTable.belongOrganizationName;
    _lblTime.text = [CommonUtil TimeStrYYYYMMDDWithInterval:physicalExamTable.examinTime];
}
@end
