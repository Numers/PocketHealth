//
//  PHOtherIndexViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOtherIndexViewController.h"
#import "PHCircleView.h"
#import "CalculateIndex.h"
#import "PHLocationHelper.h"
#import "AppDelegate.h"
#import "PHAppStartManager.h"
#import "SSleepingDB.h"

@interface PHOtherIndexViewController ()<PHCircleViewDelegate>
{
    IBOutlet PHCircleView *phMoodCircleView;
    IBOutlet UILabel *lblMoodText;
    IBOutlet PHCircleView *phActivityCircleView;
    IBOutlet UILabel *lblActivityText;
    IBOutlet PHCircleView *phSleepCircleView;
    IBOutlet UILabel *lblSleepText;
}
@end

@implementation PHOtherIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    phMoodCircleView.tag = 1;
    [phMoodCircleView inilizedView];
    [phMoodCircleView setBackCircleViewStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.18]];
    [phMoodCircleView setStrokeColor:[UIColor colorWithRed:146/255.0f green:209/255.0f blue:30/255.0f alpha:1.0f]];
    [phMoodCircleView setImage:[UIImage imageNamed:@"monitoring-smile"]];
    
    phActivityCircleView.tag = 2;
    [phActivityCircleView inilizedView];
    [phActivityCircleView setBackCircleViewStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.18]];
    [phActivityCircleView setStrokeColor:[UIColor colorWithRed:255/255.0f green:159/255.0f blue:49/255.0f alpha:1.0f]];
    [phActivityCircleView setImage:[UIImage imageNamed:@"monitoring-sports"]];
    
    phSleepCircleView.tag = 3;
    [phSleepCircleView inilizedView];
    [phSleepCircleView setBackCircleViewStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.18]];
    [phSleepCircleView setStrokeColor:[UIColor colorWithRed:0.0f green:194/255.0f blue:242/255.0f alpha:1.0f]];
    [phSleepCircleView setImage:[UIImage imageNamed:@"monitoring-sleep"]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProgressWithMoodValue:(CGFloat)mood WithActivityValue:(CGFloat)activity WithSleepValue:(CGFloat)sleep
{
    [phMoodCircleView setProgress:mood WithAnimate:YES];
    [phActivityCircleView setProgress:activity WithAnimate:YES];
    [phSleepCircleView setProgress:sleep WithAnimate:YES];
}

-(void)inilizedData
{
    float mood = [[PHLocationHelper defaultHelper] returnSuggestMoodNumber];
    float pmValue = [[PHLocationHelper defaultHelper] returnPMValue];
    [self setPHLabel:pmValue];
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger steps = appdelegate.stepsToday.integerValue;
    float activity = [CalculateIndex calculateActivity:steps];
    [self setStepsLabel:steps];
    SSleepingDB * ssleepDB = [[SSleepingDB alloc]init];
    long long memebrID = [[PHAppStartManager defaultManager] userHost].memberId;
    NSString * startTime = [ssleepDB selectTodaySleepingStartTimeWithMemberId:memebrID];
    float sleep;
    NSInteger sleepDuration;
    if (startTime == nil) {
        sleep = 0.f;
        sleepDuration = 0.f;
    }else{
        sleepDuration = [[(AppDelegate *)[UIApplication sharedApplication].delegate returnYesterdaySleepMinutes:memebrID] integerValue];
        float sleepTime = [self sleepTime:startTime];
        sleep = [CalculateIndex calculateSleep:sleepDuration WithSleepHour:sleepTime];
    }
    
    [self setSleepDurationLabel:sleepDuration];
    
    [self setProgressWithMoodValue:mood WithActivityValue:activity WithSleepValue:sleep];
}

-(void)resetSleepAndActivityData
{
    AppDelegate * appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger steps = appdelegate.stepsToday.integerValue;
    float activity = [CalculateIndex calculateActivity:steps];
    [self setStepsLabel:steps];
    [phActivityCircleView setProgress:activity WithAnimate:NO];
    
    SSleepingDB * ssleepDB = [[SSleepingDB alloc]init];
    long long memebrID = [[PHAppStartManager defaultManager] userHost].memberId;
    NSString * startTime = [ssleepDB selectTodaySleepingStartTimeWithMemberId:memebrID];
    float sleep;
    NSInteger sleepDuration;
    if (startTime == nil) {
        sleep = 0.f;
        sleepDuration = 0.f;
    }else{
        sleepDuration = [[(AppDelegate *)[UIApplication sharedApplication].delegate returnYesterdaySleepMinutes:memebrID] integerValue];
        float sleepTime = [self sleepTime:startTime];
        sleep = [CalculateIndex calculateSleep:sleepDuration WithSleepHour:sleepTime];
    }
    
    [self setSleepDurationLabel:sleepDuration];
    
    [phSleepCircleView setProgress:sleep WithAnimate:NO];
}

-(float)sleepTime:(NSString *)time
{
    if (time == nil) {
        return 0.f;
    }
    float sleepHour = [[time substringToIndex:2] floatValue];
    float sleepminite = [[time substringFromIndex:3] integerValue] / 60.f;
    return sleepHour + sleepminite;
}

-(void)setProgressWithMoodValue:(CGFloat)mood
{
    [phMoodCircleView setProgress:mood WithAnimate:YES];
}

-(void)setPHLabel:(float)phValue
{
    if (phValue > 0) {
        lblMoodText.text = [NSString stringWithFormat:@"PM2.5 %.2f",phValue];
    }else{
    
        lblMoodText.text = @"PM2.5未获取";
    }
}

-(void)setStepsLabel:(NSInteger)steps
{
    lblActivityText.text = [NSString stringWithFormat:@"步行%ld步",steps];
    [phActivityCircleView setProgress:[CalculateIndex calculateActivity:steps] WithAnimate:NO];
}

-(void)setSleepDurationLabel:(NSInteger)sleepDuration
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"睡了"];
    NSInteger hour = sleepDuration / 60;
    if (hour > 0) {
        [str appendString:[NSString stringWithFormat:@"%.1f小时",sleepDuration / 60.0f]];
    }else{
        [str appendString:[NSString stringWithFormat:@"%ld分钟",sleepDuration]];
    }
    lblSleepText.text = str;
}

#pragma -mark PHCircleViewDelegate
-(void)clickCircleView:(id)sender
{
    PHCircleView *circleView = (PHCircleView *)sender;
    switch (circleView.tag) {
        case 1:
        {
            if ([self.delegate respondsToSelector:@selector(selectMoodSection)]) {
                [self.delegate selectMoodSection];
            }
        }
            break;
        case 2:
        {
            if ([self.delegate respondsToSelector:@selector(selectActivitySection)]) {
                [self.delegate selectActivitySection];
            }
        }
            break;
        case 3:
        {
            if ([self.delegate respondsToSelector:@selector(selectSleepSection)]) {
                [self.delegate selectSleepSection];
            }
        }
            break;
            
        default:
            break;
    }
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
