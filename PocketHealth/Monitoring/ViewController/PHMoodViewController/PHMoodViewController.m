//
//  PHMoodViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMoodViewController.h"
//界面
#import "PHCustomMonitorViewController.h"
#import "UIColor+BFPaperColors.h"
#import "UINavigationController+PHNavigationController.h"
#import "PHLocationHelper.h"

//数据
#import "CalculateViewFrame.h"
#import "PHMonitoringHttpRequest.h"
#import "CommonUtil.h"
#import "PHAppStartManager.h"
//子界面

@interface PHMoodViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    PHCustomMonitorViewController * phcustomVC;
    NSDictionary * moodDic;
    long long memberId;
    NSNumber * moodValueChange;
    
    BOOL isChangeMoodValue;
}
@end

@implementation PHMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isChangeMoodValue = NO;
    memberId = [[PHAppStartManager defaultManager]userHost].memberId;
    self.score = [[PHLocationHelper defaultHelper] returnSuggestMoodNumber];
    moodValueChange = [NSNumber numberWithInteger:self.score];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phMoodValueChange:) name:@"PHMoodValueChange" object:nil];
    [self initSelfTableView];
    [self settingStaticLabel];
    // Do any additional setup after loading the view.
    
//    float pmValut = [[PHLocationHelper defaultHelper] returnPMValue];
//    if (pmValut<=0) {
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的网络可能有问题" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alertView show];
//    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setActivity_Sleep_Mood_View];
    UIImage * backgroundImg = [UIImage imageNamed:@"monitoring-backgroundInSide"];
    self.view.layer.contents = (id) backgroundImg.CGImage;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self settingMoodDynamicalLabel];
    [self.navigationItem setTitle:@"心情"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //上传心情数据
    if (isChangeMoodValue) {
        NSMutableDictionary * moodSendDic = [[NSMutableDictionary alloc]init];
        [moodSendDic setObject:moodValueChange forKey:@"mdNumber"];
        [moodSendDic setObject:[moodDic objectForKey:@"pm25"] forKey:@"mdPmNumber"];
        [moodSendDic setObject:[NSString stringWithFormat:@"%lld",memberId] forKey:@"userId"];
        [moodSendDic setObject:[CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]] forKey:@"mdBelongDate"];
        NSArray * moodArray  = [NSArray arrayWithObjects:moodSendDic, nil];
        [PHMonitoringHttpRequest uploadExercise:nil MoodList:moodArray Sleeping:nil done:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                NSLog(@"上传心情成功");
                [[PHLocationHelper defaultHelper] setMoodNumber:[moodValueChange floatValue]];
            }
        } error:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
        }];
    }
    
}
#pragma mark - initSelfTableView
-(void)initSelfTableView{
    CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    phcustomVC = [[PHCustomMonitorViewController alloc]initWithHealthType:PHHealthTypeMood];
    self.tableView.tableHeaderView = phcustomVC.view;
    [self.view addSubview:self.tableView];
}
-(void)settingMoodDynamicalLabel{
    float pm25Value = [[PHLocationHelper defaultHelper]returnPMValue];
    NSNumber * pm25Number = [NSNumber numberWithFloat:pm25Value];
    NSString * uvStr = [[PHLocationHelper defaultHelper]returnUV];
    NSString * weather = [[PHLocationHelper defaultHelper]returnTemperature];
    moodDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.score],@"score",pm25Number,@"pm25",uvStr,@"uv",weather,@"weather",nil];
    [phcustomVC setDynamicLabelWithDic:moodDic];
}
#pragma mark - settingStaticLabel 设置静态的label
-(void)settingStaticLabel{
    
}
#pragma mark - 滑动条通知接受
-(void)phMoodValueChange:(NSNotification *)notifi{
    isChangeMoodValue = YES;
    moodValueChange = [notifi object];
    [phcustomVC settingScore:moodValueChange.integerValue];
    if ([self.delegate respondsToSelector:@selector(sendMoodValue:)]) {
        [self.delegate sendMoodValue:[moodValueChange integerValue]];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
