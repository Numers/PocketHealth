//
//  PHMoodInsideViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PHMoodInsideViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *moodImageView;

@property (strong, nonatomic) IBOutlet UISlider *moodSlider;
@property (nonatomic) NSInteger progressValue;


@end
