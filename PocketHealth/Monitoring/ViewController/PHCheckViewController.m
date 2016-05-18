//
//  PHCheckViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHCheckViewController.h"
#import "PHProgressView.h"
#import "CommonUtil.h"
#import "PHMonitoringUploadHelper.h"
#import "PHMonitoringDateBaseHelper.h"
#import "PHGettingMonitorValueManager.h"
#import "PHAppStartManager.h"
#import "PHGettingMonitorValueManager.h"
#import "AppDelegate.h"
#define  ViewWidth [[UIScreen mainScreen] bounds].size.width
#define ProgressViewLeftMargin 55.0f
#define MinProgress 58.0f

@interface PHCheckViewController ()<PHProgressViewDelegate>
{
    Member *host;
    PHProgressView *progressView;
    UILabel *lblLastCheckTime;
    UIButton *btnCheck;
    
    float mood;
    float phValue;
    float activity;
    NSInteger runSteps;
    float sleep;
    NSInteger sleepDuration;
}

@end

@implementation PHCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    host = [[PHAppStartManager defaultManager] userHost];
    progressView = [[PHProgressView alloc] initWithFrame:CGRectMake(ProgressViewLeftMargin,15, ViewWidth-ProgressViewLeftMargin*2,ViewWidth-ProgressViewLeftMargin*2)];
    progressView.delegate = self;
    [self.view addSubview:progressView];
    
    lblLastCheckTime = [[UILabel alloc] initWithFrame:CGRectMake(0, progressView.frame.origin.y + progressView.frame.size.height + 9.0f, ViewWidth, 21)];
    [lblLastCheckTime setTextColor:[UIColor whiteColor]];
    [lblLastCheckTime setFont:[UIFont systemFontOfSize:12.f]];
    [lblLastCheckTime setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblLastCheckTime];
    
    btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCheck setFrame:CGRectMake(32, lblLastCheckTime.frame.origin.y + lblLastCheckTime.frame.size.height + 9, ViewWidth - 64, 42)];
    [btnCheck addTarget:self action:@selector(checkOrSearchReport) forControlEvents:UIControlEventTouchUpInside];
    [btnCheck.layer setCornerRadius:21.0f];
    [btnCheck setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.68f]];
    [btnCheck showsTouchWhenHighlighted];
    [btnCheck setTitle:@"立即检测" forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor colorWithRed:138.0f/255 green:138.0f/255 blue:138.0f/255 alpha:1.0f] forState:UIControlStateNormal];
    [btnCheck.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [self.view addSubview:btnCheck];
    [self inilizedCheckAndTimeLabel];
}
-(void)updateViewConstraints{
    [super updateViewConstraints];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)inilizedCheckAndTimeLabel
{
    NSNumber *scoreNumber = [CommonUtil localUserDefaultsForKey:KMY_LastCheckScore];
    if (scoreNumber == nil) {
        [progressView setDynamicProgress:MinProgress];
    }else{
        [progressView setDynamicProgress:[scoreNumber floatValue]];
    }
    
    NSNumber *checkTime = [CommonUtil localUserDefaultsForKey:KMY_LastCheckTime];
    if (checkTime == nil) {
        [lblLastCheckTime setText:@"最近您没有进行检测"];
    }else{
        NSTimeInterval checkTimeInterval = [checkTime doubleValue];
        NSString *checkTimeStr = [NSString stringWithFormat:@"最近检测 %@",[CommonUtil TimeStrMMDDHHmmWithInterval:checkTimeInterval]];
        [lblLastCheckTime setText:checkTimeStr];
    }
}

-(void)checkStrAndTimeLabelSetting
{
    NSNumber *scoreNumber = [CommonUtil localUserDefaultsForKey:KMY_LastCheckScore];
    if (scoreNumber == nil) {
        [progressView setProgress:MinProgress animated:NO];
    }else{
        [progressView setProgress:[scoreNumber floatValue] animated:NO];
//        [progressView setProgress:97 animated:NO];
    }
    
    NSNumber *checkTime = [CommonUtil localUserDefaultsForKey:KMY_LastCheckTime];
    if (checkTime == nil) {
        [lblLastCheckTime setText:@"最近您没有进行检测"];
    }else{
        NSTimeInterval checkTimeInterval = [checkTime doubleValue];
        NSString *checkTimeStr = [NSString stringWithFormat:@"最近检测 %@",[CommonUtil TimeStrMMDDHHmmWithInterval:checkTimeInterval]];
        [lblLastCheckTime setText:checkTimeStr];
    }
}

-(void)getMonitoringValueWithMemberId:(long long)memberId
{
    [[PHGettingMonitorValueManager defaultManager] gettingScoreWithMoodActivitySleep:memberId result:^(NSDictionary *result) {
        if (result != nil) {
//            NSDictionary *moodDic = [result objectForKey:@"Mood"];
//            if (([moodDic isKindOfClass:[NSNull class]]) || (moodDic == nil)) {
//                mood = 0;
//                phValue = 0;
//            }else{
//                mood = [[moodDic objectForKey:@"Mdnumber"] floatValue];
//                phValue = [[moodDic objectForKey:@"Mdpmnumber"] floatValue];
//            }
//            
//            NSDictionary *exerciseDic = [result objectForKey:@"Exercise"];
//            if (([exerciseDic isKindOfClass:[NSNull class]]) || (exerciseDic == nil))
//            {
//                activity = 0;
//                runSteps = 0;
//            }else{
//                activity = [[exerciseDic objectForKey:@"Ednumber"] floatValue];
//                runSteps = [[(AppDelegate *)[UIApplication sharedApplication].delegate stepsToday] integerValue];
//                if (runSteps == 0) {
//                    runSteps = [[exerciseDic objectForKey:@"Edsteps"] integerValue];
//                }
//            }
//            
//            NSDictionary *sleepDic = [result objectForKey:@"Sleep"];
//            if (([sleepDic isKindOfClass:[NSNull class]]) || (sleepDic == nil))
//            {
//                sleep = 0;
//                sleepDuration = [[(AppDelegate *)[UIApplication sharedApplication].delegate returnYesterdaySleepMinutes:host.memberId] integerValue];
//            }else{
//                sleep = [[sleepDic objectForKey:@"Sssleepnumber"] floatValue];
//                sleepDuration = [[(AppDelegate *)[UIApplication sharedApplication].delegate returnYesterdaySleepMinutes:host.memberId] integerValue];
//                if (sleepDuration == 0) {
//                    sleepDuration = [[sleepDic objectForKey:@"Sssleepduration"] integerValue];
//                }
//            }
            
            float complex;
            NSDictionary *complexDic = [result objectForKey:@"Complex"];
            if (([complexDic isKindOfClass:[NSNull class]]) || (complexDic == nil))
            {
                NSNumber *lastCheckScore = [CommonUtil localUserDefaultsForKey:KMY_LastCheckScore];
                if (lastCheckScore == nil) {
                    complex = 58.f;
                }else{
                    complex = [lastCheckScore floatValue];
                }
            }else{
                complex = [[complexDic objectForKey:@"Cscomplexnumber"] floatValue];
            }
            
            [CommonUtil localUserDefaultsValue:[NSNumber numberWithFloat:complex] forKey:KMY_LastCheckScore];
//            [CommonUtil localUserDefaultsValue:[NSNumber numberWithFloat:phValue] forKey:KMY_LastPHValue];
//            [CommonUtil localUserDefaultsValue:[NSNumber numberWithFloat:mood] forKey:KMY_LastMoodScore];
//            [CommonUtil localUserDefaultsValue:[NSNumber numberWithFloat:activity] forKey:KMY_LastActivityScore];
//            [CommonUtil localUserDefaultsValue:[NSNumber numberWithFloat:sleep] forKey:KMY_LastSleepScore];
            [self checkStrAndTimeLabelSetting];
//            if ([self.delegate respondsToSelector:@selector(deliveryMood:PHValue:WithActivity:WithSteps:WithSleep:WithSleepDuration:)]) {
//                [self.delegate deliveryMood:mood PHValue:phValue WithActivity:activity WithSteps:runSteps WithSleep:sleep WithSleepDuration:sleepDuration];
//            }
        }else{
            [lblLastCheckTime setText:@"检测失败,请重新检测"];
            [btnCheck setEnabled:YES];
            [self resetCheckBtnState];
        }
    }];
}

-(void)checkBtnStateBeginCheck
{
    [btnCheck setTitle:@"正在检测" forState:UIControlStateNormal];
    [btnCheck setEnabled:NO];
    [btnCheck setAlpha:0.7f];
}

-(void)checkBtnStateEndCheck
{
    [btnCheck setTitle:@"查看报告" forState:UIControlStateNormal];
    [btnCheck setEnabled:YES];
    [btnCheck setAlpha:1.0f];
}

-(void)resetCheckBtnState
{
    if ([btnCheck isEnabled]) {
        [btnCheck setTitle:@"立即检测" forState:UIControlStateNormal];
        [btnCheck setAlpha:1.0f];
    }
}

-(void)check
{
    [self checkBtnStateBeginCheck];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    [CommonUtil localUserDefaultsValue:[NSNumber numberWithDouble:now] forKey:KMY_LastCheckTime];
    [PHMonitoringUploadHelper uploadExercise_Mood_SleepingListWithMemberId:host.memberId cancal:^(BOOL flag) {
        [CommonUtil localUserDefaultsValue:[NSNumber numberWithDouble:now] forKey:KMY_LastUploadTime];
        [self getMonitoringValueWithMemberId:host.memberId];
    } done:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            [CommonUtil localUserDefaultsValue:[NSNumber numberWithDouble:now] forKey:KMY_LastUploadTime];
            [PHMonitoringDateBaseHelper mergeUnUploadExerciseToUploaded:host.memberId];
            [PHMonitoringDateBaseHelper mergeUnUploadSleepingToUploaded:host.memberId];
            [self getMonitoringValueWithMemberId:host.memberId];
        }else{
            [lblLastCheckTime setText:@"检测失败,请重新检测"];
            [btnCheck setEnabled:YES];
            [self resetCheckBtnState];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        [lblLastCheckTime setText:@"检测失败,请重新检测"];
        [btnCheck setEnabled:YES];
        [self resetCheckBtnState];
    }];
}

-(void)checkOrSearchReport
{
    if ([btnCheck.titleLabel.text isEqualToString:@"立即检测"]) {
        [self check];
    }
    
    if ([btnCheck.titleLabel.text isEqualToString:@"查看报告"]) {
        if ([self.delegate respondsToSelector:@selector(pushReportView)]) {
            [self.delegate pushReportView];
        }
    }
}

#pragma -mark PHProgeressViewDelegate
-(void)stopAnimateProgress
{
    [self checkBtnStateEndCheck];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
