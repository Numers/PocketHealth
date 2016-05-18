//
//  PHHeadImageView.h
//  PocketHealth
//
//  Created by macmini on 15-1-31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHHeadImageViewDelegate <NSObject>
-(void)clickHeadButton;
@end
@class Member;
@interface PHHeadImageView : UIView
@property(nonatomic, strong) UIImageView *backGroundImageView;
@property(nonatomic, strong) UILabel *nickNameLabel;
@property(nonatomic, strong) UIImageView *headImageView;
@property(nonatomic, strong) UIButton *btnUserHead;
@property(nonatomic, strong) UIView *borderView;

@property(nonatomic, weak) id<PHHeadImageViewDelegate> delegate;

-(void)setupWithMember:(Member *)member;
@end
