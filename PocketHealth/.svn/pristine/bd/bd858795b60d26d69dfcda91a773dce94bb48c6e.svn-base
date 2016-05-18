//
//  PHActivityTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHActivityTableViewController.h"
#import "PHCustomMonitorViewController.h"
#import "UIColor+BFPaperColors.h"

//数据类
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "SMonitorExerciseDB.h"
//#import "AppDelegate.h"

@interface PHActivityTableViewController ()
{
    int RecommendedNutrientIntake;
    int BaseMetabolism;
    
    int stepsBase; //运动基础步伐数
    int stepsHours;// 当前小时步伐数
    int stepsToday; // 运动步数 = 运动基础步伐数 + 当前小时步伐数
    int consumeCalorie;//消耗的卡路里
 
    Member *host ;
    
    PHCustomMonitorViewController * phcustomVC;
//    AppDelegate * appDelegate;
}
@end

@implementation PHActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self settingBackgroundColor];
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    
//    self.view.backgroundColor = [UIColor blueColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    [self settingTableviewBackgroundColor];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"monitoring-backgroundInSide"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    

//    self.tableView.backgroundColor = [UIColor redColor];
    NSLog(@"%f %f ",self.tableView.frame.size.height,self.view.frame.size.height);

    self.tableView.frame = self.view.frame;
//    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"monitoring-backgroundInSide"]];
    host = [[PHAppStartManager defaultManager]userHost];
    //获取当日数据
    SMonitorExerciseDB * sexercisedb = [[SMonitorExerciseDB alloc]init];
    NSString * todayStr = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    stepsBase = [sexercisedb selectTodayStepsWithMemberId:host.memberId WithDataTime:todayStr];
    
    stepsToday = stepsHours + stepsBase;
    //初始化摄入量与代谢量 暂时随便搞一个i饿值
    [self getRNIAndBM];
    //收听一个修改步伐的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshActivityStepsToday:) name:@"kRefreshNStepsNow" object:nil];
    
    phcustomVC = [[PHCustomMonitorViewController alloc]init];
    
    self.tableView.tableHeaderView = phcustomVC.view;

//     self.clearsSelectionOnViewWillAppear = NO;
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self settingStaticLabel];
    [self changeDetailValue];
    
    
//    phcustomVC.labelValue3.text = [NSString stringWithFormat:@"%u大卡",]
}
#pragma mark - settingStaticLabel 设置静态label
-(void)settingStaticLabel{
    phcustomVC.labelTopTitle.text = @"运动概况";
    phcustomVC.labelProper1.text = @"今日运动";
    phcustomVC.labelProper2.text = @"运动步数";
    phcustomVC.labelProper3.text = @"消耗热量";
    phcustomVC.labelDetailLabel.text = @"今日热量消耗";
    
    //设置分数
    NSString * scoreStr = [NSString stringWithFormat:@"%u分",self.score];
    NSRange range = [scoreStr rangeOfString:@"分"];
    NSMutableAttributedString * showScoreStr = [[NSMutableAttributedString alloc]initWithString:scoreStr];
    [showScoreStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:45.0] range:NSMakeRange(0, range.location)];
    [showScoreStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:25.0] range:range];
    phcustomVC.labelScore.attributedText = showScoreStr;
    
    //设置分数对应的 标签 好 差
    NSString * scoreDescribe;
    if (self.score<65) {
        scoreDescribe = @"太少";
    }else if (self.score<78&&self.score>64){
        scoreDescribe = @"适当";
    }else if (self.score>79){
        scoreDescribe = @"极佳";
    }else{
        scoreDescribe = @"未知";
    }
    phcustomVC.labelValue1.text = scoreDescribe;
}
#pragma mark -  changeDetailValue
-(void)changeDetailValue{
    phcustomVC.labelValue2.text = [NSString stringWithFormat:@"%u步",stepsToday];
    consumeCalorie = [self CalculateBuenCaloriesWithSteps:stepsToday WithWeight:50];
    phcustomVC.labelValue3.text = [NSString stringWithFormat:@"%u卡路里",consumeCalorie];
}
#pragma mark - getRNIAndBM 初始化摄入量与代谢量
-(void)getRNIAndBM{
    RecommendedNutrientIntake = 2000;
    BaseMetabolism = 1000;
}
#pragma mark - setps delegate
-(void)refreshActivityStepsToday:(NSNotification *)aNotificaon{
    NSNumber * numberSteps =    [aNotificaon object];
    stepsHours = numberSteps.intValue;
    stepsToday = stepsBase + stepsHours;
    [self changeDetailValue];
//    phcustomVC.labelValue2.text = [NSString stringWithFormat:@"%u步",stepsToday];
    NSLog(@"_____________________ %ld steps  ____________________ ",(long)stepsToday);
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
