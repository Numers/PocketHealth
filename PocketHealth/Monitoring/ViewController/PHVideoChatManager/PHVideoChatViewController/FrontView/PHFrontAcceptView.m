//
//  PHFrontAcceptView.m
//  PocketHealth
//
//  Created by macmini on 15-3-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHFrontAcceptView.h"
#define Margin 31.0f

@implementation PHFrontAcceptView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        btnAccept = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ButtonWidth, ButtonHeight)];
        [btnAccept addTarget:self action:@selector(clickAcceptBtn) forControlEvents:UIControlEventTouchUpInside];
        [btnAccept setBackgroundImage:[UIImage imageNamed:@"AcceptCallImage-Normal"] forState:UIControlStateNormal];
        [btnAccept setBackgroundImage:[UIImage imageNamed:@"AcceptCallImage-upsideInput"] forState:UIControlStateHighlighted];
        [btnAccept setCenter:CGPointMake(frame.size.width - (Margin + ButtonWidth / 2), self.frame.size.height - MarginToBottom)];
        [self addSubview:btnAccept];
        
        btnReject = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ButtonWidth, ButtonHeight)];
        [btnReject addTarget:self action:@selector(clickRejectBtn) forControlEvents:UIControlEventTouchUpInside];
        [btnReject setBackgroundImage:[UIImage imageNamed:@"ShutDownCallImage-Normal"] forState:UIControlStateNormal];
        [btnReject setBackgroundImage:[UIImage imageNamed:@"ShutDownCallImage-upsideInput"] forState:UIControlStateHighlighted];
        [btnReject setCenter:CGPointMake(Margin + ButtonWidth / 2, self.frame.size.height - MarginToBottom)];
        [self addSubview:btnReject];
    }
    return self;
}

-(void)clickAcceptBtn
{
    if ([self.delegate respondsToSelector:@selector(acceptCall)]) {
        [self.delegate acceptCall];
    }
}

-(void)clickRejectBtn
{
    if ([self.delegate respondsToSelector:@selector(rejectCall)]) {
        [self.delegate rejectCall];
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
