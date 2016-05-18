//
//  PHBackViewTopToolBar.m
//  PocketHealth
//
//  Created by macmini on 15-3-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHBackViewTopToolBar.h"
#define LabelWidth 50.0f
#define LabelHeight 22.0f
#define AnimateDuration 0.3f

@implementation PHBackViewTopToolBar
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTranslucent:YES];
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundImage:[UIImage imageNamed:@"VideoChatViewTopToolBarBackImage"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];

        UIBarButtonItem *ItemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        lblTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LabelWidth, LabelHeight)];
        [lblTime setText:@"10:03"];
        [lblTime setTextColor:[UIColor whiteColor]];
        [lblTime setFont:[UIFont systemFontOfSize:18.0f]];
//        [lblTime setShadowColor:[UIColor lightGrayColor]];
//        [lblTime setShadowOffset:CGSizeMake(0, 1)];
        UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithCustomView:lblTime];
        
        [self setItems:@[ItemSpace,centerSpace,ItemSpace]];
        
        currentIsShow = NO;
    }
    return self;
}

-(void)setTimeLabel:(NSInteger)seconds
{
    NSInteger minites = seconds / 60;
    NSInteger second = seconds % 60;
    NSString *minitesStr = nil;
    NSString *secondsStr = nil;
    if (minites < 10) {
        minitesStr = [NSString stringWithFormat:@"0%ld",(long)minites];
    }else{
        minitesStr = [NSString stringWithFormat:@"%ld",(long)minites];
    }
    
    if (second < 10) {
        secondsStr = [NSString stringWithFormat:@"0%ld",(long)second];
    }else{
        secondsStr = [NSString stringWithFormat:@"%ld",(long)second];
    }
    [lblTime setText:[NSString stringWithFormat:@"%@:%@",minitesStr,secondsStr]];
}

-(BOOL)isShow
{
    return currentIsShow;
}

-(void)show
{
    [UIView animateWithDuration:AnimateDuration animations:^{
        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        currentIsShow = YES;
    }];
}

-(void)hidden
{
    [UIView animateWithDuration:AnimateDuration animations:^{
        [self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        currentIsShow = NO;
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
