//
//  PHAVCaptureVideoPreView.h
//  PocketHealth
//
//  Created by macmini on 15-3-18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PHAVCaptureVideoPreView : UIView
{
    AVCaptureVideoPreviewLayer *preViewLayer;
    UITapGestureRecognizer *tapGesture;
    CGFloat TopAndBottomPADDING;
    CGFloat LeftAndRightPADDING;
    BOOL canTap;
}
@property(nonatomic,assign,getter = isDragEnable)   BOOL dragEnable;
@property(nonatomic,assign,getter = isAdsorbEnable) BOOL adsorbEnable;

-(id)initWithFrame:(CGRect)frame WithSession:(AVCaptureSession *)session;
-(void)changeFrame:(CGRect)frame;
@end
