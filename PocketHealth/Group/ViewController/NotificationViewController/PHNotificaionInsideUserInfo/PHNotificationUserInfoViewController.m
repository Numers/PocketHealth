//
//  PHNotificationUserInfoViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/2/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHNotificationUserInfoViewController.h"

#import "PHGroupPersonalInfoCellHeaderViewController.h"
#import "CalculateViewFrame.h"

#import "UINavigationController+PHNavigationController.h"
//自定义按钮
#import "PHBlueButton.h"
#import "MBProgressHUD.h"

static NSString * identifierNotificaionDetailUserCell = @"identifierNotificaionDetailUserCell";
@interface PHNotificationUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
     PHGroupPersonalInfoCellHeaderViewController * phGPHeadViewVC;
}
@end

@implementation PHNotificationUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setTranslucentView];
    
    CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
    self.tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    phGPHeadViewVC =[[PHGroupPersonalInfoCellHeaderViewController alloc]initWithMemberId:_notifiMessage.memberId];
    self.tableView.tableHeaderView = phGPHeadViewVC.view;
    
    
    [self.view addSubview:self.tableView];
    
    

    [self createTwoBtnAddTableViewFootView];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setOtherViewNavigation];
}
#pragma mark - createTwoBtnAddTableViewFootView
-(void)createTwoBtnAddTableViewFootView{
    UIView * bottomBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65)];
    PHBlueButton * blueBtnLeft = [[PHBlueButton alloc]initWithFrame:CGRectMake(kBtnLeftMargin, 0, kBottomBtnWidthWithTWO, 44)];
    blueBtnLeft.backgroundColor = [UIColor paperColorBlueA400];
    [blueBtnLeft addTarget:self action:@selector(agreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blueBtnLeft setTitle:@"同意申请" forState:UIControlStateNormal];
    
    PHBlueButton * blueBtnRight = [[PHBlueButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2+kBtnLeftMargin, 0, kBottomBtnWidthWithTWO, 44)];
    blueBtnRight.backgroundColor = [UIColor paperColorBlueA400];
    [blueBtnRight addTarget:self action:@selector(cancalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blueBtnRight setTitle:@"取   消" forState:UIControlStateNormal];
    
    [bottomBtnView addSubview:blueBtnLeft];
    [bottomBtnView addSubview:blueBtnRight];
    
    self.tableView.tableFooterView = bottomBtnView;
}
#pragma mark -  按钮委托
-(void)agreeBtnClick:(id)sender{
    if (self.notifiMessage.state == NotificationMessageStateAgree) {
        //如果已经同意过了 那么就弹出提示表示已同意
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"你已同意过了";
        hud.margin = 10.f;hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
    }else{
        //否则，加好友
        if ([self.delegate respondsToSelector:@selector(agreeBtnClickReback:)]) {
            [self.delegate agreeBtnClickReback:self.notifiMessage];
        }
    }
    
}
-(void)cancalBtnClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierNotificaionDetailUserCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierNotificaionDetailUserCell];
    }
    
    
    return cell;
}

@end
