//
//  PHAppStartView.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAppStartView.h"
#define ImageViewEdge 79.f
#define TopSpacePercent 0.35f
#define FrameChangePixl 40.f

@implementation PHAppStartView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:13/255.f green:197/255.f blue:203/255.f alpha:1.f]];
        imageViewBig = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - ImageViewEdge) / 2, frame.size.height * TopSpacePercent, ImageViewEdge, ImageViewEdge)];
        [imageViewBig setImage:[UIImage imageNamed:@"AppStartIconBig"]];
        [self addSubview:imageViewBig];
        
        imageViewSmall = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - ImageViewEdge) / 2, frame.size.height * TopSpacePercent, ImageViewEdge, ImageViewEdge)];
        [imageViewSmall setImage:[UIImage imageNamed:@"AppStartIconSmall"]];
        [self addSubview:imageViewSmall];
    }
    return self;
}

-(void)startAnimate
{
    [NSThread sleepForTimeInterval:0.5f];
    [self changeFrameAnimate];
    [self startBigImageRotation];
    [self startSmallImageRotation];
}

-(void)startSmallImageRotation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * -1];
    rotationAnimation.duration = AnimateDuration / 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 2.f;
    rotationAnimation.delegate = self;
    
    [imageViewSmall.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)startBigImageRotation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = AnimateDuration / 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 2.f;
    rotationAnimation.delegate = self;
    
    [imageViewBig.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)changeFrameAnimate
{
    [UIView animateWithDuration:AnimateDuration animations:^{
        [imageViewBig setFrame:CGRectMake((self.frame.size.width - ImageViewEdge) / 2  - FrameChangePixl, self.frame.size.height * TopSpacePercent - FrameChangePixl, ImageViewEdge + FrameChangePixl * 2, ImageViewEdge + FrameChangePixl * 2)];
        [imageViewSmall setFrame:CGRectMake((self.frame.size.width - ImageViewEdge) / 2  - FrameChangePixl, self.frame.size.height * TopSpacePercent - FrameChangePixl, ImageViewEdge + FrameChangePixl * 2, ImageViewEdge + FrameChangePixl * 2)];
    } completion:^(BOOL finished) {
        
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
