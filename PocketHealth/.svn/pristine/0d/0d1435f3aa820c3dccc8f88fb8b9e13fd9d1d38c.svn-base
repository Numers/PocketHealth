//
//  PHFrontView.m
//  VideoDemo
//
//  Created by macmini on 15-3-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHFrontView.h"
#import "UIImageView+WebCache.h"
#import "GlobalVar.h"
#define ImageViewWidthAndHeight 96.0f
@implementation PHFrontView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor blackColor]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 22.0f)];
        [titleLabel setText:@"视频通话"];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f]];
        [titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [titleLabel setCenter:CGPointMake(frame.size.width / 2, 55.0f)];
        [self addSubview:titleLabel];
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ImageViewWidthAndHeight, ImageViewWidthAndHeight)];
        [headImageView setBackgroundColor:[UIColor whiteColor]];
        [headImageView.layer setCornerRadius:ImageViewWidthAndHeight / 2];
        [headImageView.layer setMasksToBounds:YES];
        [headImageView setCenter:CGPointMake(frame.size.width / 2, 173.0f)];
        [self addSubview:headImageView];
        
        lblNickName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 22)];
        [lblNickName setTextAlignment:NSTextAlignmentCenter];
        [lblNickName setCenter:CGPointMake(frame.size.width / 2, 251.0f)];
        [lblNickName setTextColor:[UIColor whiteColor]];
        [lblNickName setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:lblNickName];
    }
    return self;
}

-(void)setUpViewWithHeadImage:(NSString *)headImageUrl WithNickName:(NSString *)nickName
{
    if (headImageUrl) {
        [headImageView sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:[UIImage imageNamed:DefaultDoctorHeadImage]];
    }else{
        [headImageView setImage:[UIImage imageNamed:DefaultDoctorHeadImage]];
    }
    
    if (nickName) {
        [lblNickName setText:nickName];
    }else{
        [lblNickName setText:@"正在跟医生进行连接..."];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
