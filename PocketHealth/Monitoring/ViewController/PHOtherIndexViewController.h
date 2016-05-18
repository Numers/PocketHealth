//
//  PHOtherIndexViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHOtherIndexViewDelegate<NSObject>
-(void)selectMoodSection;
-(void)selectActivitySection;
-(void)selectSleepSection;
@end
@interface PHOtherIndexViewController : UIViewController
@property(nonatomic, assign) id<PHOtherIndexViewDelegate> delegate;
-(void)inilizedData;
-(void)resetSleepAndActivityData;
-(void)setProgressWithMoodValue:(CGFloat)mood;
-(void)setPHLabel:(float)phValue;
-(void)setStepsLabel:(NSInteger)steps;
-(void)setSleepDurationLabel:(NSInteger)sleepDuration;
@end
