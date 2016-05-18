//
//  PHGroupAccessaryHeadView.h
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@interface PHGroupAccessaryHeadView : UIView
@property(nonatomic, strong) UIImageView *imgHeadView;
@property(nonatomic, strong) UIImageView *imgIndicateView;

-(void)setupWithGroup:(Group *)group;
@end
