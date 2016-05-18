//
//  PHFrontView.h
//  VideoDemo
//
//  Created by macmini on 15-3-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ButtonWidth 71.f
#define ButtonHeight 71.0f
#define MarginToBottom 61.0f
@protocol PHFrontViewDelegate <NSObject>
-(void)acceptCall;
-(void)rejectCall;
-(void)cancelCall;
@end
@interface PHFrontView : UIView
{
    UIImageView *headImageView;
    UILabel *lblNickName;
}
@property(nonatomic, assign) id<PHFrontViewDelegate> delegate;
-(void)setUpViewWithHeadImage:(NSString *)headImageUrl WithNickName:(NSString *)nickName;
@end
