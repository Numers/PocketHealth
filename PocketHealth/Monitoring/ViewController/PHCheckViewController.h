//
//  PHCheckViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHCheckViewDelegate <NSObject>
-(void)pushReportView;
@end
@interface PHCheckViewController : UIViewController
@property(nonatomic, weak) id<PHCheckViewDelegate> delegate;
-(void)resetCheckBtnState;
-(void)check;
@end
