//
//  PHCommentAlertViewController.h
//  PocketHealth
//
//  Created by macmini on 15-3-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHCommentAlertViewDelegate <NSObject>
-(void)commentWithScore:(NSInteger)score;
@end
@interface PHCommentAlertViewController : UIViewController
@property(nonatomic, assign) id<PHCommentAlertViewDelegate> delegate;
-(id)initWithCallTime:(NSTimeInterval)timeInterval;
-(void)showInView:(UIView *)view;
-(void)hidden;
@end
