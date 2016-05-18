//
//  PHChathomeAddDetailTableViewCell.m
//  PocketHealth
//
//  Created by YangFan on 15/1/18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHChathomeAddDetailTableViewCell.h"

@implementation PHChathomeAddDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect  textLabelFrame =  self.textLabel.frame;
    textLabelFrame.origin.y = self.imageView.frame.origin.y;
    self.textLabel.frame = textLabelFrame;
    
    CGRect textDetailFrame = self.detailTextLabel.frame;
    textDetailFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height - self.detailTextLabel.frame.size.height;
    self.detailTextLabel.frame = textDetailFrame;
    
}
@end
