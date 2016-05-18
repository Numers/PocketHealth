//
//  PHUserCenterTableViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUserCenterTableViewController.h"
#import "UINavigationController+PHNavigationController.h"
#import "CExpandHeader.h"
#import "CalculateViewFrame.h"
#import "GlobalVar.h"

#import "PHUserCenterHeadView.h"
#import "PHHeadImageView.h"

//数据
#import "PHAppStartManager.h"

#import "PHUserCenterTableViewCell.h"
#import "PHPhysicalExamTableListViewController.h"
#import "PHPersonalProfileViewController.h"
#import "PHPhysicalExamBookRecoderViewController.h"
#import "PHFriendAttantionListViewController.h"
#import "PHDoctorAttantionListViewController.h"
#import "PHOrganizationAttantionListViewController.h"
#import "PHPhysicalExamTestViewController.h"
#import "PHPhysicalExamQuestionViewController.h"
#import "PHAccountBalanceViewController.h"
#import "PHUserCenterSettingViewController.h"


static NSString *identifierUserCenterCell = @"PHUserCenterTableViewCell";
@interface PHUserCenterTableViewController ()<UIScrollViewDelegate,PHHeadImageViewDelegate,PHUserCenterHeadViewDelegate>
{
    Member *host;
    PHHeadImageView *phHeadImageView;
    PHUserCenterHeadView *phUserCenterHeadView;
    CExpandHeader *exPandHeader;
}
@end

@implementation PHUserCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:ViewBackGroundColor];
    //界面构造简介
    [self.navigationController setNavigationBarHidden:NO];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
        
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"PHUserCenterTableViewCell" bundle:nil] forCellReuseIdentifier:identifierUserCenterCell];
    
    phHeadImageView = [[PHHeadImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 156.f)];
    phHeadImageView.delegate = self;
    exPandHeader = [CExpandHeader expandWithScrollView:self.tableView expandView:phHeadImageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    [self.tableView setFrame:frame];
    //获取用户信息
    host = [[PHAppStartManager defaultManager] userHost];
    [phHeadImageView setupWithMember:host];
    if (phUserCenterHeadView != nil) {
        [phUserCenterHeadView updateUIViewContentWithMember:host];
    }
}

-(void)navigationControllerSetting
{
    [self.tabBarController.navigationController setOtherViewNavigation];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(clickSettingBtn)];
    [leftBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.f]} forState:UIControlStateNormal];
    [self.tabBarController.navigationItem setLeftBarButtonItem:leftBarItem];
    [self.navigationItem setLeftBarButtonItem:leftBarItem];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"账户余额" style:UIBarButtonItemStyleBordered target:self action:@selector(clickAccountBtn)];
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.f]} forState:UIControlStateNormal];
    [self.tabBarController.navigationItem setRightBarButtonItem:rightBarItem];
    
    [self.tabBarController.navigationItem setTitle:@"我"];
    
//    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [backBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.f]} forState:UIControlStateNormal];
//    [self.tabBarController.navigationItem setBackBarButtonItem:backBarItem];
}

-(void)clickSettingBtn
{
    PHUserCenterSettingViewController *phUserCenterSettingVC = [[PHUserCenterSettingViewController alloc] init];
    [self.navigationController pushViewController:phUserCenterSettingVC animated:YES];
}

-(void)clickAccountBtn
{
    PHAccountBalanceViewController *phAccountBalanceVC = [[PHAccountBalanceViewController alloc] init];
    [self.navigationController pushViewController:phAccountBalanceVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate and datasoucre
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 51.0f;
    }else{
        return 20.0f;
    }
    return 0.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 51.f)];
        [view setBackgroundColor:[UIColor whiteColor]];
        phUserCenterHeadView = [[PHUserCenterHeadView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        phUserCenterHeadView.delegate = self;
        [phUserCenterHeadView updateUIViewContentWithMember:host];
        [view addSubview:phUserCenterHeadView];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        return 2;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0) ) {
        return 0.0f;
    }else{
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PHUserCenterTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierUserCenterCell];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.imgHeadView setImage:[UIImage imageNamed:@"usercenter-user-test"]];
                    [cell.lblTitle setText:@"我的体检"];
                    [cell.lblDetailTitle setText:nil];
                    break;
                case 1:
                    [cell.imgHeadView setImage:[UIImage imageNamed:@"usercenter-appointment"]];
                    [cell.lblTitle setText:@"体检预约"];
                    [cell.lblDetailTitle setText:nil];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.imgHeadView setImage:[UIImage imageNamed:@"usercenter-questionnaire"]];
                    [cell.lblTitle setText:@"体检问卷"];
                    [cell.lblDetailTitle setText:nil];
                    break;
                case 1:
                    [cell.imgHeadView setImage:[UIImage imageNamed:@"usercenter-self-testing"]];
                    [cell.lblTitle setText:@"体检自测"];
                    [cell.lblDetailTitle setText:nil];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}
#pragma mark - tableview点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    PHPhysicalExamTableListViewController *phPhysicalExamTableListVC = [[PHPhysicalExamTableListViewController alloc] init];
                    [self.navigationController pushViewController:phPhysicalExamTableListVC animated:YES];
                }
                    break;
                case 1:
                {
                    PHPhysicalExamBookRecoderViewController *phPhysicalExamBookRecoderVC = [[PHPhysicalExamBookRecoderViewController alloc] init];
                    [self.navigationController pushViewController:phPhysicalExamBookRecoderVC animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                {
                    PHPhysicalExamQuestionViewController *phPhysicalExamQuestionVC = [[PHPhysicalExamQuestionViewController alloc] init];
                    [self.navigationController pushViewController:phPhysicalExamQuestionVC animated:YES];
                }
                    break;
                case 1:
                {
                    PHPhysicalExamTestViewController *phPhysicalExamTestVC = [[PHPhysicalExamTestViewController alloc] init];
                    [self.navigationController pushViewController:phPhysicalExamTestVC animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma -mark  PHHeadImageViewDelegate
-(void)clickHeadButton
{
    PHPersonalProfileViewController *phPersonalProfileVC = [[PHPersonalProfileViewController alloc] init];
    [self.navigationController pushViewController:phPersonalProfileVC animated:YES];
}

#pragma -mark PHUserCenterHeadViewDelegate
-(void)friendListBtnClick
{
    //推入好友列表界面
    PHFriendAttantionListViewController *phFriendAttantionListVC = [[PHFriendAttantionListViewController alloc] init];
    id phGroupChatHomeVC = [[PHAppStartManager defaultManager] returnPHGroupChatHomeView];
    phFriendAttantionListVC.delegate = phGroupChatHomeVC;
    [self.navigationController pushViewController:phFriendAttantionListVC animated:YES];
}

-(void)doctorListBtnClick
{
    //推入医生列表界面
    PHDoctorAttantionListViewController *phDoctorAttantionListVC = [[PHDoctorAttantionListViewController alloc] init];
    id phGroupChatHomeVC = [[PHAppStartManager defaultManager] returnPHGroupChatHomeView];
    phDoctorAttantionListVC.delegate = phGroupChatHomeVC;
    [self.navigationController pushViewController:phDoctorAttantionListVC animated:YES];
}

-(void)organizationListBtnClick
{
    //推入医院列表界面
    PHOrganizationAttantionListViewController *phOrganizationAttationListVC = [[PHOrganizationAttantionListViewController alloc] init];
    id phGroupChatHomeVC = [[PHAppStartManager defaultManager] returnPHGroupChatHomeView];
    phOrganizationAttationListVC.delegate = phGroupChatHomeVC;
    [self.navigationController pushViewController:phOrganizationAttationListVC animated:YES];
}
@end
