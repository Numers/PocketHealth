//
//  PHBottomToolBar.h
//  PocketHealth
//
//  Created by macmini on 15-2-28.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHBottomToolBarDelegate <NSObject>
-(void)pushToSearchDoctorView;
-(void)pushToChatView;
@end
@interface PHBottomToolBar : UIToolbar
{
    UIButton *btnLeft;
    UIButton *btnRight;
    
    BOOL currentIsShow;
}
@property(nonatomic, assign) id<PHBottomToolBarDelegate> myDelegate;
-(BOOL)isShow;
-(void)show;
-(void)hidden;
@end
