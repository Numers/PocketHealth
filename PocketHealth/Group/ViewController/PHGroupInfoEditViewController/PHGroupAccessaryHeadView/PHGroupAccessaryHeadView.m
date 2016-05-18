//
//  PHGroupAccessaryHeadView.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGroupAccessaryHeadView.h"
#import "UIImageView+WebCache.h"
#import "Group.h"
#import "GlobalVar.h"
#define IndicateViewWidth 8.f
#define IndicateViewHeight 13.f
#define ViewsMargin 8.0f

@implementation PHGroupAccessaryHeadView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgIndicateView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-IndicateViewWidth, (frame.size.height - IndicateViewHeight)/2, IndicateViewWidth, IndicateViewHeight)];
        [_imgIndicateView setImage:[UIImage imageNamed:@"usercenter-detail"]];
        [self addSubview:_imgIndicateView];
        
        float leftWidth = frame.size.width - IndicateViewWidth - ViewsMargin;
        float height = frame.size.height;
        if (leftWidth > height) {
            _imgHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(leftWidth - height, 0, height, height)];
        }else{
            _imgHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (height - leftWidth)/2, leftWidth, leftWidth)];
        }
        [self addSubview:_imgHeadView];
    }
    return self;
}

-(void)setupWithGroup:(Group *)group
{
    [_imgHeadView.layer setCornerRadius:8.f];
    [_imgHeadView.layer setMasksToBounds:YES];
    [_imgHeadView sd_setImageWithURL:[NSURL URLWithString:group.groupHeadImage] placeholderImage:[UIImage imageNamed:DefaultGroupHeadImage]];
}
@end
