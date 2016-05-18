//
//  PHRNITableViewCell.m
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHRNITableViewCell.h"

@implementation PHRNITableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.btnPlus setBackgroundImage:[UIImage imageNamed:@"activityPNI_plus"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
