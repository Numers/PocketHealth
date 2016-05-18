//
//  PHBackViewTopToolBar.h
//  PocketHealth
//
//  Created by macmini on 15-3-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHBackViewTopToolBarDelegate <NSObject>
-(void)switchCamera;
@end
@interface PHBackViewTopToolBar : UIToolbar
{
    UILabel *lblTime;
    BOOL currentIsShow;
}
@property(nonatomic, assign) id<PHBackViewTopToolBarDelegate> myDelegate;
-(BOOL)isShow;
-(void)show;
-(void)hidden;
-(void)setTimeLabel:(NSInteger)seconds;
@end
