//
//  PHJoinStrategyViewController.h
//  PocketHealth
//
//  Created by macmini on 15-3-3.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
@protocol PHJoinStrategyViewDelegate <NSObject>
-(void)selectStrategy:(JoinStrategy)strategy;
@end
@interface PHJoinStrategyViewController : UIViewController
@property(nonatomic, assign) id<PHJoinStrategyViewDelegate> delegate;

-(id)initWithJoinStrategy:(JoinStrategy)strategy;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
