//
//  PHActivityViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/23.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHActivityViewController.h"
#import "UINavigationController+PHNavigationController.h"
#import "PHCustomMonitorViewController.h"
#import "UIColor+BFPaperColors.h"

//数据类
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "SMonitorExerciseDB.h"
#import "CalculateViewFrame.h"
#import "CalculateIndex.h"

#import "AppDelegate.h"

//界面子类
#import "PHMetabolismViewController.h"
//#import "PHPNIInputTableViewController.h"
#import "PNIInputViewController.h"


@interface PHActivityViewController ()<UITableViewDelegate,UITableViewDataSource,PHCustomMonitorViewControllerDelegate>
{
    NSInteger RecommendedNutrientIntake;
    int BaseMetabolism;
    
//    NSInteger stepsBase; //运动基础步伐数
    NSInteger stepsHours;// 当前小时步伐数
    NSInteger stepsToday; // 运动步数 = 运动基础步伐数 + 当前小时步伐数 appdelegate 已获取
    NSInteger consumeCalorie;//消耗的大卡
    
    Member *host ;
    
    PHCustomMonitorViewController * phcustomVC;
    NSInteger leftCalorie;
}


@end

@implementation PHActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    phcustomVC = [[PHCustomMonitorViewController alloc]initWithHealthType:PHHealthTypeActivity];
    phcustomVC.delegate = self;
    self.tableView.tableHeaderView = phcustomVC.view;
    
    ////    self.navigationController.navigationBar.clipsToBounds=YES;
//    [self.navigationController.navigationBar setAlpha:0.55];
    [self.view addSubview:self.tableView];
    
    //初始化摄入量与代谢量 暂时随便搞一个i饿值
    [self getRNIAndBM];
    //收听一个修改步伐的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshActivityStepsToday:) name:@"kRefreshNStepsNow" object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setActivity_Sleep_Mood_View];
    host = [[PHAppStartManager defaultManager]userHost];
    //获取当日数据
//    SMonitorExerciseDB * sexercisedb = [[SMonitorExerciseDB alloc]init];
//    NSString * todayStr = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
//    stepsToday = [sexercisedb selectTodayStepsWithMemberId:host.memberId WithDataTime:todayStr];
//    if (/* DISABLES CODE */ (NO)) {//判断cm 版本
//        AppDelegate * appdelegate = [UIApplication sharedApplication].delegate;
//        stepsBase = appdelegate.numM7Steps;
//    }
//    stepsToday = stepsHours + stepsBase;
    
    AppDelegate * appdelegate = [UIApplication sharedApplication].delegate;
    stepsToday = appdelegate.stepsToday.integerValue;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self changeDetailValue];
    
    UIImage * backgroundImg = [UIImage imageNamed:@"monitoring-backgroundInSide"];
    self.view.layer.contents = (id) backgroundImg.CGImage;
    
    [self.navigationItem setTitle:@"运动"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark - settingStaticLabel 设置动态label
-(void)settingMonitorDynamicalLabel{
    [self getRNIAndBM];
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.score],@"score", [NSNumber numberWithInteger:leftCalorie],@"leftCalorie",nil];
    [phcustomVC setDynamicLabelWithDic:dic];

}
#pragma mark -  changeDetailValue
-(void)changeDetailValue{
    phcustomVC.labelValue2.text = [NSString stringWithFormat:@"%ld步",(long)stepsToday];
    host = [[PHAppStartManager defaultManager]userHost];
    if (host.userWeight != 0) {
        consumeCalorie = [self CalculateBuenCaloriesWithSteps:stepsToday WithWeight:host.userWeight];
        phcustomVC.labelValue3.text = [NSString stringWithFormat:@"%ld大卡",(long)consumeCalorie];
    }else{
        phcustomVC.labelValue3.text = @"体重未设置";
    }
    
    self.score = [[NSNumber numberWithFloat:[CalculateIndex calculateActivity:stepsToday]] integerValue];
    [self settingMonitorDynamicalLabel];
}
#pragma mark - getRNIAndBM 初始化摄入量与代谢量
-(void)getRNIAndBM{
    RecommendedNutrientIntake = [[PHAppStartManager defaultManager] userHost].calorie;
    BaseMetabolism = [[NSNumber numberWithFloat:nearbyintf(host.metabolism)]intValue];
    leftCalorie = RecommendedNutrientIntake - BaseMetabolism - consumeCalorie;
    leftCalorie = leftCalorie<0?0:leftCalorie;
    
}
#pragma mark - setps delegate
-(void)refreshActivityStepsToday:(NSNotification *)aNotificaon{
    NSNumber * numberSteps =    [aNotificaon object];
    stepsToday = [numberSteps integerValue];
    [self changeDetailValue];
    //    phcustomVC.labelValue2.text = [NSString stringWithFormat:@"%u步",stepsToday];
//    NSLog(@"_____________________ %ld steps  ____________________ ",(long)stepsToday);
}
#pragma mark - settingBackgroundColor
-(void)settingBackgroundColor{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame =self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor paperColorBlueGray] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}
-(void)settingTableviewBackgroundColor{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -  点击下方动作
-(void)activityVCBtnSettingMetabolismBtnClick{
    PHMetabolismViewController *phmtaVC = [[PHMetabolismViewController alloc]init];
    [self.navigationController pushViewController:phmtaVC animated:YES];
}
-(void)activityVCBtnSettingPNIBtnClick{
    PNIInputViewController * phRniVC = [[PNIInputViewController alloc]init];
    [self.navigationController pushViewController:phRniVC animated:YES];
}
#pragma mark - 计算大卡与运动步伐 体重关系的数据
-(int)CalculateBuenCaloriesWithSteps:(int)steps WithWeight:(int)weight{
    double z = 0;
    if (steps < 1000) z = 23;
    else if (steps >= 1000 && steps < 5000)z = 23.5;
    else if (steps >= 5000 && steps < 10000)z = 24;
    else if (steps >= 10000)z = 25;
    
    double w = weight / 40;
    w = w < 0.9 ? 0.9 : w;
    w = w > 2.2 ? 2.2 : w;
    return (int)(steps / z * w);
}
@end
