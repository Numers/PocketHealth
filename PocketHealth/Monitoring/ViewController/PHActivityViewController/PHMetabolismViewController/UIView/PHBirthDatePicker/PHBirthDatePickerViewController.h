//
//  PHWeightViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DefalutMaxAge 70
@protocol PHBirthDatePickerViewDelegate <NSObject>
-(void)pickBirthDate:(NSDate *)birthDate;
@end
@interface PHBirthDatePickerViewController : UIViewController
@property(nonatomic, assign) id<PHBirthDatePickerViewDelegate> delegate;

-(id)initWithBirthDate:(NSTimeInterval)birth;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
