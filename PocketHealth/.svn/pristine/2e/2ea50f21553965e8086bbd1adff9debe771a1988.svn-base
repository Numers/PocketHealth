//
//  PHFindDoctorListTableViewCell.m
//  PocketHealth
//
//  Created by macmini on 15-3-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHFindDoctorListTableViewCell.h"
#import "Room.h"
#import "Doctor.h"
#import "UIImageView+WebCache.h"
#import "GlobalVar.h"

@implementation PHFindDoctorListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpCellWithDictionary:(NSDictionary *)dic
{
    [_imgHeadImageBackColorView.layer setCornerRadius:_imgHeadImageBackColorView.frame.size.width/2];
    [_imgHeadImageBackColorView.layer setMasksToBounds:YES];
    [_imgHeadImageView.layer setCornerRadius:_imgHeadImageView.frame.size.width/2];
    [_imgHeadImageView.layer setMasksToBounds:YES];
    room = [dic objectForKey:@"Room"];
    doctor = [dic objectForKey:@"Doctor"];
    [_imgHeadImageView sd_setImageWithURL:[NSURL URLWithString:doctor.headImage] placeholderImage:[UIImage imageNamed:DefaultUserHeadImage]];
    _lblName.text = [NSString stringWithFormat:@"%@ %@",doctor.realName,doctor.diJobTitle];
    _lblDepartment.text = [NSString stringWithFormat:@"%@-%@",doctor.dpName,doctor.nickName];
    _lblJob.text = doctor.remark;
    [_imgStarLevel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"StarImage-%.0lf",doctor.score]]];
}

-(IBAction)clickVideoBtn:(id)sender
{
    if ([_delegate respondsToSelector:@selector(pushToVideoChatWithTag:)]) {
        [_delegate pushToVideoChatWithTag:_indexTag];
    }
}
@end
