//
//  PHSleepViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHSleepViewController.h"

//界面
#import "PHCustomMonitorViewController.h"
#import "UIColor+BFPaperColors.h"
#import "UINavigationController+PHNavigationController.h"

//数据
#import "CalculateViewFrame.h"
#import "CalculateIndex.h"
#import "SSleepingDB.h"
#import "PHAppStartManager.h"
#import "AppDelegate.h"

@interface PHSleepViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    PHCustomMonitorViewController * phcustomVC;
}
@end

@implementation PHSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSelfTableView];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setActivity_Sleep_Mood_View];
    
    UIImage * backgroundImg = [UIImage imageNamed:@"monitoring-backgroundInSide"];
    self.view.layer.contents = (id) backgroundImg.CGImage;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self settingSleepDynamicalLabel];
    [self.navigationItem setTitle:@"睡眠"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark - initSelfTableView
-(void)initSelfTableView{
    CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    phcustomVC = [[PHCustomMonitorViewController alloc]initWithHealthType:PHHealthTypeSleep];
    self.tableView.tableHeaderView = phcustomVC.view;
    [self.view addSubview:self.tableView];
}
#pragma mark -  设置动态的子页面数据
-(void)settingSleepDynamicalLabel{
    //从数据库获取本地睡眠数据
    SSleepingDB * ssleepDB = [[SSleepingDB alloc]init];
    long long memebrID = [[PHAppStartManager defaultManager] userHost].memberId;
    NSString * startTime = [ssleepDB selectTodaySleepingStartTimeWithMemberId:memebrID];
    NSDictionary * dic;
    if (startTime == nil) {
        self.score = 0.0f;
        dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.score],@"score",@"--",@"sleepstart",@"0",@"duration",nil];
    }else{
        float sleepTime = [self sleepTime:startTime];
        NSNumber * sleepDuration = [(AppDelegate *)[UIApplication sharedApplication].delegate returnYesterdaySleepMinutes:memebrID];
        if([sleepDuration integerValue] == 0)
        {
            dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.score],@"score",@"--",@"sleepstart",@"0",@"duration",nil];
        }else{
            self.score = [[NSNumber numberWithFloat:[CalculateIndex calculateSleep:[sleepDuration integerValue] WithSleepHour:sleepTime]] integerValue];
            dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.score],@"score",startTime,@"sleepstart",sleepDuration.stringValue,@"duration",nil];
        }
    }
    [phcustomVC setDynamicLabelWithDic:dic];
    
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
