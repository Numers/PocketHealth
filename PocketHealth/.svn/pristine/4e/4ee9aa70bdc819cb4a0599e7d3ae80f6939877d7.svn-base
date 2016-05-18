//
//  PHBackViewBottomToolBar.h
//  VideoDemo
//
//  Created by macmini on 15-3-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHBackViewBottomToolBarDelegate <NSObject>
-(void)shutUpCall;
-(void)switchCamera;
@end
@interface PHBackViewBottomToolBar : UIToolbar
{
    UIButton *btnShutUp;
    UIButton *btnSwitchCamera;
    BOOL currentIsShow;
}

@property(nonatomic, assign) id<PHBackViewBottomToolBarDelegate> myDelegate;
-(BOOL)isShow;
-(void)show;
-(void)hidden;
@end
