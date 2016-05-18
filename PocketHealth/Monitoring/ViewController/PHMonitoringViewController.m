//
//  PHMonitoringViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMonitoringViewController.h"
#import "PHAppStartManager.h"
#import "PHLoginManager.h"
#import "PHCheckViewController.h"
#import "PHOtherIndexViewController.h"
#import "PHReportViewController.h"
#import "CommonUtil.h"
#import "CalculateViewFrame.h"
#import "PHLocationHelper.h"
#import "UINavigationController+PHNavigationController.h"

#import "AppDelegate.h"
#import "PHMonitoringUploadHelper.h"
#import "PHMonitoringDateBaseHelper.h"
#import "Reachability.h"

#import "PHProtocol.h"

//#import "PHActivityTableViewController.h"
//数据类
#import "PHGettingMonitorValueManager.h"

//下方3按钮界面子类
#import "PHSleepViewController.h"
#import "PHActivityViewController.h"
#import "PHMoodViewController.h"
#define UpLoadDuration 7200
#define CheckDuration 60*60*24*2
#define LocationDuration 3600

//一件寻医 按钮
#import "PHOneKeyFindDocListViewController.h"

@interface PHMonitoringViewController ()<UIScrollViewDelegate,UIAppDelegate,PHLocationHelperDelegate,PHOtherIndexViewDelegate,PHMoodViewControllerDelegate,UIAlertViewDelegate,PHCheckViewDelegate,PHPushFindDocotorViewDelegate>
{
    Member *host;
    UIScrollView *scrollView;
    
    PHCheckViewController *phCheckVC;
    PHOtherIndexViewController *phOtherIndexVC;
    
    PHLocationHelper *locationHelper;
    Reachability *internetReach;
    
    //3个子界面的分数
    float moodScore;
    float activyScore ;
    float sleepScore;
//    NSNumber * numberSteps;
}

@end

@implementation PHMonitoringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置背景效果
    UIImage * backgroundImg = [UIImage imageNamed:@"monitoring-firstbackgroundimage"];
    self.view.layer.contents = (id) backgroundImg.CGImage;

    host = [[PHAppStartManager defaultManager] userHost];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMonitorStepsToday:) name:@"kRefreshNStepsNow" object:nil];
    
    //1.查询网络状态
    internetReach= [Reachability reachabilityWithHostName:CheckConnectHostUrl];
    [internetReach startNotifier];
    //2.查询网络状态的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkReachabe:) name:kReachabilityChangedNotification object:nil];
    
//    //启动定位获取天气信息
//    [self startLocation];
    
    // Do any additional setup after loading the view from its nib.
    scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    [scrollView setBackgroundColor:[UIColor clearColor]];

    [self.view addSubview:scrollView];
    float IPhone5Height = [UIScreen mainScreen].bounds.size.height * 0.59;
    float myViewHeight = IPhone5Height > 335.12 ? IPhone5Height : 335.12;
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, myViewHeight)];
    [myView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:myView];
    
    phCheckVC = [[PHCheckViewController alloc] init];
    phCheckVC.delegate = self;
    [phCheckVC.view setBackgroundColor:[UIColor clearColor]];
    [phCheckVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [myView addSubview:phCheckVC.view];
    
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:phCheckVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:myView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [myView addConstraint:constraint5];
    
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:phCheckVC.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0];
    [myView addConstraint:constraint6];
    
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:phCheckVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:myView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [myView addConstraint:constraint7];
    
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:phCheckVC.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [myView  addConstraint:constraint8];
    
    NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:phCheckVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:myView.frame.size.width];
    [phCheckVC.view  addConstraint:constraint9];
    
    UIView *myView1 = [[UIView alloc] initWithFrame:CGRectMake(0, myView.frame.size.height, [UIScreen mainScreen].bounds.size.width, 115)];
    [myView1 setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:myView1];

    
    phOtherIndexVC = [[PHOtherIndexViewController alloc] init];
    [phOtherIndexVC.view setBackgroundColor:[UIColor clearColor]];
    phOtherIndexVC.delegate = self;
    [phOtherIndexVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [myView1 addSubview:phOtherIndexVC.view];
    
    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:phOtherIndexVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:myView1 attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [myView1 addConstraint:constraint10];
    
    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:myView1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:phOtherIndexVC.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0];
    [myView1 addConstraint:constraint11];
    
    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:phOtherIndexVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:myView1 attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [myView1 addConstraint:constraint12];
    
    NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:myView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:phOtherIndexVC.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [myView1  addConstraint:constraint13];
    
    NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:phOtherIndexVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:myView1.frame.size.width];
    [phOtherIndexVC.view  addConstraint:constraint14];
    
    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, myView.frame.size.height + myView1.frame.size.height)];
    
    if ([self shouldCheck]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您已经很长时间没有检测了哟,赶快来检测一次吧!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
    //登录时上传健康数据
//    [self uploadHealthData];
    //test 上传所有上传睡眠数据
//    [PHMonitoringUploadHelper uploadExercise_Mood_SleepingListWithMemberId:host.memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //
//        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
//            [PHMonitoringDateBaseHelper mergeUnUploadSleepingToUploaded:host.memberId];
//            [PHMonitoringDateBaseHelper mergeUnUploadExerciseToUploaded:host.memberId];
//        }
//#warning 以后加心情数据
//    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //
//    }];
    
//    [PHMonitoringUploadHelper uploadSleepDetail:host.memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //成功之后将这些数据删除
//        [PHMonitoringDateBaseHelper mergeUnUploadSleepingToUploaded:host.memberId];
//    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
//    //test 上传ExerciseDetail:
//    [PHMonitoringUploadHelper uploadExerciseDetail:host.memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [PHMonitoringDateBaseHelper mergeUnUploadExerciseToUploaded:host.memberId];
//    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //
//    }];
//    NSString *  todaySleep=[PHMonitoringDateBaseHelper selectTodaySleepingMinutes:host.memberId];
//    NSLog(@"%@",todaySleep);
//    NSString *thatDay =  [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]-86400];
//    NSString * s114 = [PHMonitoringDateBaseHelper selectOneDayWithDateTIme:thatDay WithMemberId:host.memberId];
//    NSLog(@"%@",s114);
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    [scrollView setFrame:frame];
    //校准appdelegate运动步伐数据
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate clearStepsWithZero];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if ([self shouldUpload]) {
//        [self uploadHealthData];
//    }
    if ([self shouldLocation]) {
        [self startLocation];
    }
    
    [phOtherIndexVC inilizedData];
    [phCheckVC resetCheckBtnState];
    
    
}

-(void)startLocation
{
    locationHelper = [PHLocationHelper defaultHelper];
    locationHelper.delegate = self;
    [locationHelper uploadMyLocationInfo];
}

-(BOOL)shouldCheck
{
    BOOL check = NO;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastCheckTimeNumber = [CommonUtil localUserDefaultsForKey:KMY_LastCheckTime];
    if (lastCheckTimeNumber == nil) {
        check = NO;
    }else{
        NSTimeInterval lastCheckTime = [lastCheckTimeNumber doubleValue];
        NSTimeInterval duration = now - lastCheckTime;
        if (duration > CheckDuration) {
            check = YES;
        }else{
            check = NO;
        }
    }
    return check;
}

-(BOOL)shouldUpload
{
    BOOL upload = NO;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastUploadTimeNumber = [CommonUtil localUserDefaultsForKey:KMY_LastUploadTime];
    if (lastUploadTimeNumber == nil) {
        upload = YES;
    }else{
        NSTimeInterval lastUploadTime = [lastUploadTimeNumber doubleValue];
        NSTimeInterval duration = now - lastUploadTime;
        if (duration > UpLoadDuration) {
            upload = YES;
        }else{
            upload = NO;
        }
    }
    return upload;
}

-(BOOL)shouldLocation
{
    BOOL location = NO;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastLocationTimeNumber = [CommonUtil localUserDefaultsForKey:KMY_LastLocationTime];
    if (lastLocationTimeNumber == nil) {
        location = YES;
    }else{
        NSTimeInterval lastLocationTime = [lastLocationTimeNumber doubleValue];
        NSTimeInterval duration = now - lastLocationTime;
        if (duration > LocationDuration) {
            location = YES;
        }else{
            location = NO;
        }
    }
    return location;
}

-(void)navigationControllerSetting
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"一键寻医" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftItem)];
    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f],NSFontAttributeName : [UIFont systemFontOfSize:15.f]} forState:UIControlStateNormal];
    [self.tabBarController.navigationItem setLeftBarButtonItem:leftItem];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"查看报告" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightItem)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f],NSFontAttributeName : [UIFont systemFontOfSize:15.f]} forState:UIControlStateNormal];
    [self.tabBarController.navigationItem setRightBarButtonItem:rightItem];
    [self.tabBarController.navigationItem setTitle:@"天天健康"];
    [self.tabBarController.navigationController setMonitoringViewNavigationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickLeftItem
{
    [self pushFindDoctorView];
}

-(void)pushReportViewController
{
    PHReportViewController *phReportVC = [[PHReportViewController alloc] init];
    phReportVC.delegate = self;
    [self.navigationController pushViewController:phReportVC animated:YES];
}

-(void)clickRightItem
{
    [self pushReportViewController];
}
#pragma mark - appdelegate  通知
-(void)refreshMonitorStepsToday:(NSNotification*) aNotification{
    NSNumber * numberSteps =    [aNotification object];
    int steps = numberSteps.intValue;
    NSLog(@"_____________________ %ld steps  ____________________ ",(long)steps);
    [phOtherIndexVC setStepsLabel:steps];
}

#pragma -mark PHOtherIndexViewDelegate
-(void)selectMoodSection
{
    PHMoodViewController *phmoodVC = [[PHMoodViewController alloc]init];
    phmoodVC.delegate = self;
    [self.navigationController pushViewController:phmoodVC animated:YES];
}

-(void)selectActivitySection
{

    PHActivityViewController * phactivityVC = [[PHActivityViewController alloc]init];
    [self.navigationController pushViewController:phactivityVC animated:YES];
}

-(void)selectSleepSection
{
    PHSleepViewController *phSleepVC = [[PHSleepViewController alloc]init];
    [self.navigationController pushViewController:phSleepVC animated:YES];
}
#pragma -mark PHMoodViewDelegate
-(void)sendMoodValue:(NSInteger )moodValue
{
    [phOtherIndexVC setProgressWithMoodValue:moodValue];
    moodScore = moodValue;
}

#pragma -mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [phCheckVC check];
    }
}

#pragma -mark PHLocationHelperDelegate
-(void)requestWeathInfoComplete:(float)mood WithPMValue:(float)pm
{
    [phOtherIndexVC setProgressWithMoodValue:mood];
    [phOtherIndexVC setPHLabel:pm];
}

#pragma -mark PHCheckViewDelegate
-(void)pushReportView
{
    [self pushReportViewController];
}

#pragma mark - 断线重连
-(void)netWorkReachabe:(NSNotification *)noti{
    
    Reachability *currReach=[noti object];
    NetworkStatus netStatus = [currReach currentReachabilityStatus];
    
    switch (netStatus) {
        case  NotReachable:
            //没有网络
            break;
        case ReachableViaWWAN:
            //使用3g网络
            [self startLocation];
            break;
        case ReachableViaWiFi:
            //使用wifi网络
            [self startLocation];
            break;
            
        default:
            break;
    }
}

#pragma -mark PHPushFindDoctorViewDelegate
-(void)pushFindDoctorView
{
    //推入可选界面
    PHOneKeyFindDocListViewController * onekeydocVC = [[PHOneKeyFindDocListViewController alloc]init];
    [self.navigationController pushViewController:onekeydocVC animated:YES];
}
@end
