//
//  PHWeightViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHHeightViewDelegate <NSObject>
-(void)pickHeight:(NSInteger)height;
@end
@interface PHHeightViewController : UIViewController
@property(nonatomic, assign) id<PHHeightViewDelegate> delegate;

-(id)initWithHeight:(NSInteger)h;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
