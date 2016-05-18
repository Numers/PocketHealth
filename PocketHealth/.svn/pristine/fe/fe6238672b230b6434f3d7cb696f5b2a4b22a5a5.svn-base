//
//  PHFrontHangupView.m
//  PocketHealth
//
//  Created by macmini on 15-3-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHFrontHangupView.h"

@implementation PHFrontHangupView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ButtonWidth, ButtonHeight)];
        [btnCancel addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"ShutDownCallImage-Normal"] forState:UIControlStateNormal];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"ShutDownCallImage-upsideInput"] forState:UIControlStateHighlighted];
        [btnCancel setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height - MarginToBottom)];
        [self addSubview:btnCancel];
        
        callNotifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 21)];
        [callNotifyLabel setTextColor:[UIColor whiteColor]];
        [callNotifyLabel setTextAlignment:NSTextAlignmentCenter];
        [callNotifyLabel setBackgroundColor:[UIColor lightGrayColor]];
        [callNotifyLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [callNotifyLabel setCenter:CGPointMake(frame.size.width / 2, 282.0f)];
        [callNotifyLabel setHidden:YES];
        [self addSubview:callNotifyLabel];
        
        NSString *notify = @"本次通话前5分钟免费，之后开始计价收费，每次10分钟30元人民币";
        UILabel *notifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190.0f, 42.0f)];
        [notifyLabel setText:notify];
        [notifyLabel setTextColor:[UIColor colorWithRed:148/255.0f green:148/255.0f blue:148/255.0f alpha:1.0f]];
        [notifyLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [notifyLabel setCenter:CGPointMake(frame.size.width / 2, 322.0f)];
        [notifyLabel setNumberOfLines:0];
        [self addSubview:notifyLabel];
    }
    return self;
}

-(void)showCallNotifyLabelWithDesc:(NSString *)text
{
    [callNotifyLabel setText:text];
    [callNotifyLabel setHidden:NO];
}

-(BOOL)isCallNotifyHidden
{
    return callNotifyLabel.hidden;
}

-(void)clickCancelBtn
{
    if ([self.delegate respondsToSelector:@selector(cancelCall)]) {
        [self.delegate cancelCall];
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
