//
//  PHGuidViewPanel.m
//  PocketHealth
//
//  Created by macmini on 15-2-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGuidViewPanel.h"
#define SkipButtonWidth 170.f
#define SkipButtonHeight 40.f
#define SkipButtonBottomMargin 79.f

@implementation PHGuidViewPanel
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:imageview];
        btnSkip = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - SkipButtonWidth)/2, frame.size.height - SkipButtonBottomMargin - SkipButtonHeight, SkipButtonWidth, SkipButtonHeight)];
        [btnSkip setBackgroundColor:[UIColor colorWithRed:11/255.f green:236/255.f blue:209/255.f alpha:1.f]];
        [btnSkip.layer setCornerRadius:5.f];
        [btnSkip.layer setMasksToBounds:YES];
        [btnSkip addTarget:self action:@selector(clickSkipButton) forControlEvents:UIControlEventTouchUpInside];
        [btnSkip setTitle:@"立即体验" forState:UIControlStateNormal];
        [self addSubview:btnSkip];
    }
    return self;
}

-(void)clickSkipButton
{
    if ([self.delegate respondsToSelector:@selector(clickSkipBtn)]) {
        [self.delegate clickSkipBtn];
    }
}

-(void)setImage:(UIImage *)image ShowSkipButton:(BOOL)show
{
    [imageview setImage:image];
    [btnSkip setHidden:!show];
}
@end
