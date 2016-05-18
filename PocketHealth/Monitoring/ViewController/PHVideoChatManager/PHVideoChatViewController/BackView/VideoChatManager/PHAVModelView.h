//
//  PHAVModelView.h
//  PocketHealth
//
//  Created by macmini on 15-3-20.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHAVModelView : UIView
{
    UITapGestureRecognizer *tapGesture;
    CGFloat TopAndBottomPADDING;
    CGFloat LeftAndRightPADDING;
    BOOL canTap;
}
@property(nonatomic,assign,getter = isDragEnable)   BOOL dragEnable;
@property(nonatomic,assign,getter = isAdsorbEnable) BOOL adsorbEnable;
-(void)changeFrame:(CGRect)frame;
@end
