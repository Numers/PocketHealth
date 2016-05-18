//
//  PHHeadImageView.m
//  PocketHealth
//
//  Created by macmini on 15-1-31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHHeadImageView.h"
#import "GlobalVar.h"
#import "Member.h"
#import "UIImageView+WebCache.h"
#define HeadWidthAndHeight 60.f
#define NickNameLabelHeight 17.f
#define NickNameLabelBottomMargin 38.0f
#define NikeNameLabelWidth 190.f

@implementation PHHeadImageView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        _backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_backGroundImageView setImage:[UIImage imageNamed:@"usercenter-userheadbackgroundimage"]];
        
        //关键步骤 设置可变化背景view属性
        _backGroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
        _backGroundImageView.clipsToBounds = YES;
        _backGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_backGroundImageView];
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - NikeNameLabelWidth)/2, frame.size.height - NickNameLabelHeight - NickNameLabelBottomMargin, NikeNameLabelWidth, NickNameLabelHeight)];
        [_nickNameLabel setCenter:CGPointMake(frame.size.width/2, frame.size.height - NickNameLabelHeight/2 - NickNameLabelBottomMargin)];
        [_nickNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nickNameLabel setTextColor:[UIColor whiteColor]];
        [_nickNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [_nickNameLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
        [_nickNameLabel setShadowOffset:CGSizeMake(0, 1)];
        [self addSubview:_nickNameLabel];
        
        _borderView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - HeadWidthAndHeight)/2 - 1.5, frame.size.height - NickNameLabelHeight - NickNameLabelBottomMargin - 7 - HeadWidthAndHeight - 1.5, HeadWidthAndHeight + 3, HeadWidthAndHeight + 3)];
        [_borderView.layer setCornerRadius:_borderView.frame.size.width / 2];
        _borderView.layer.masksToBounds = YES;
        [_borderView setBackgroundColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.7f]];
        [self addSubview:_borderView];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - HeadWidthAndHeight)/2, frame.size.height - NickNameLabelHeight - NickNameLabelBottomMargin - 7 - HeadWidthAndHeight, HeadWidthAndHeight, HeadWidthAndHeight)];
        [_headImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height - NickNameLabelBottomMargin - NickNameLabelHeight - 7 - HeadWidthAndHeight/2)];
        [_headImageView.layer setCornerRadius:HeadWidthAndHeight / 2];
        _headImageView.layer.masksToBounds = YES;
        [self addSubview:_headImageView];
        
        _btnUserHead = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - HeadWidthAndHeight)/2, frame.size.height - NickNameLabelHeight - NickNameLabelBottomMargin - 7 - HeadWidthAndHeight, HeadWidthAndHeight, HeadWidthAndHeight)];
        [_btnUserHead setCenter:CGPointMake(frame.size.width/2, frame.size.height - NickNameLabelBottomMargin - NickNameLabelHeight - 7 - HeadWidthAndHeight/2)];
        [_btnUserHead.layer setCornerRadius:HeadWidthAndHeight / 2];
        _btnUserHead.layer.masksToBounds = YES;
        [_btnUserHead addTarget:self action:@selector(clickHeadBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnUserHead];
    }
    return self;
}

-(void)clickHeadBtn
{
    if ([self.delegate respondsToSelector:@selector(clickHeadButton)]) {
        [self.delegate clickHeadButton];
    }
}

-(void)setupWithMember:(Member *)member
{
    if (member != nil) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:member.headImage] placeholderImage:[UIImage imageNamed:DefaultUserHeadImage]];
        [_nickNameLabel setText:member.nickName];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [_nickNameLabel setCenter:CGPointMake(rect.size.width/2, rect.size.height - NickNameLabelHeight/2 - NickNameLabelBottomMargin)];
    [_headImageView setCenter:CGPointMake(rect.size.width/2, rect.size.height - NickNameLabelBottomMargin - NickNameLabelHeight - 7 - HeadWidthAndHeight/2)];
    [_btnUserHead setCenter:CGPointMake(rect.size.width/2, rect.size.height - NickNameLabelBottomMargin - NickNameLabelHeight - 7 - HeadWidthAndHeight/2)];
    [_borderView setCenter:CGPointMake(rect.size.width/2, rect.size.height - NickNameLabelBottomMargin - NickNameLabelHeight - 7 - HeadWidthAndHeight/2)];
}


@end
