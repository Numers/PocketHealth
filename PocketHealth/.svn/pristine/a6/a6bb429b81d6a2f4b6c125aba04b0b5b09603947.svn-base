//
//  PHAddDetailMemberFkViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/30.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAddDetailMemberFkViewController.h"

#import "CalculateViewFrame.h"
#import "PHGroupPersonalInfoCellHeaderViewController.h"

//界面类
#import "MBProgressHUD.h"
#import "PHGroupHttpRequest.h"
#import "PHAppStartManager.h"
#import "CalculateViewFrame.h"
#import "JSONKit.h"

#import "ClientHelper.h"
#import "UINavigationController+PHNavigationController.h"
#import "PHAppStartManager.h"

#import "CustomStyleValue1TableViewCell.h"
#import "PHProtocol.h"


static NSString * identifierAddDetailMemberInfoCell = @"identifierAddDetailMemberInfoCell";

@interface PHAddDetailMemberFkViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,PHGroupPersonalInfoCellHeaderViewControllerDelegate>
{
    Member * member;
    UIAlertView * addFriendAlert;
    UIAlertView * delFriendAlert;

    

    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PHAddDetailMemberFkViewController

-(id)initWithMember:(Member *)mem{
    self = [super init];
    if (self) {
        //
        member = mem;
        id phGroupChatHomeVC = [[PHAppStartManager defaultManager] returnPHGroupChatHomeView];
        self.delegate = phGroupChatHomeVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //0.初始化tableview
        CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 0;
    
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomStyleValue1TableViewCell" bundle:nil] forCellReuseIdentifier:identifierAddDetailMemberInfoCell];
    
    PHGroupPersonalInfoCellHeaderViewController * phGPHeadViewVC =[[PHGroupPersonalInfoCellHeaderViewController alloc]initWithMemberId:member.memberId];
    phGPHeadViewVC.delegate = self;
    self.tableView.tableHeaderView = phGPHeadViewVC.view;
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setTranslucentView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setOtherViewNavigation];
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //************************ 逻辑分支 身份判断********************//
    NSInteger n = 0;
    if (member) {
        if (member.userType == MemberUserTypeDoctor) {
            n = 1;
        }
    }
    return n;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60;
    if (indexPath.row == 0) {
        return 60;
    }
    else{
        return 44;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 100;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    
    
    UIButton *friendBtn=  [UIButton buttonWithType:UIButtonTypeSystem];
    friendBtn.frame = CGRectMake( 0 ,10, [UIScreen mainScreen].bounds.size.width, 40);
    friendBtn.tintColor = [UIColor colorWithRed:255 green:254 blue:254 alpha:1];
    [friendBtn setBackgroundImage:[UIImage imageNamed:@"naviTopBarColor"] forState:UIControlStateNormal];
    if (member.utuid <= 0) {
        //出现加为好友
        [friendBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        [friendBtn setTitle:@"加为好友" forState:UIControlStateNormal];
        
        [footerView addSubview:friendBtn];
    }else{
        [friendBtn setTitle:@"进入聊天" forState:UIControlStateNormal];
        [friendBtn addTarget:self action:@selector(intoChat) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:friendBtn];
        
        //再添加一个按钮叫做 删除好友
        UIButton *deleteFriendBtn=  [UIButton buttonWithType:UIButtonTypeSystem];
        deleteFriendBtn.frame = CGRectMake( 0,60, [UIScreen mainScreen].bounds.size.width, 40);
        deleteFriendBtn.tintColor = [UIColor colorWithRed:255 green:254 blue:254 alpha:1];
        [deleteFriendBtn setBackgroundColor:[UIColor redColor]];
        [deleteFriendBtn setTitle:@"删除好友" forState:UIControlStateNormal];
        [deleteFriendBtn addTarget:self action:@selector(delFriend) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView addSubview:deleteFriendBtn];
    }
    return footerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomStyleValue1TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierAddDetailMemberInfoCell];
    if (cell == nil) {
        cell = [[CustomStyleValue1TableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierAddDetailMemberInfoCell];
    }
    if (member.userType == MemberUserTypeDoctor) {
        cell.leftTextLabel.text = @"简介";
        cell.rightDetailTextLabel.text = [NSString stringWithFormat:@"%@",member.dimark];
    }
    return cell;
}
#pragma mark - 添加好友addFriend
-(void)addFriend{
    NSLog(@"加好友按钮点击");
    addFriendAlert = [[UIAlertView alloc]initWithTitle:@"确认加为好友" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    addFriendAlert.tag = 0;
    addFriendAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf=[addFriendAlert textFieldAtIndex:0];
    Member *host = [[PHAppStartManager defaultManager] userHost];
    tf.placeholder = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
    [addFriendAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *tf=[alertView textFieldAtIndex:0];
    NSLog(@"alertView.message %@",tf.text);
    NSString * alertMessage = tf.text;
    
    switch (alertView.tag) {
        case 0:
        {
            if (buttonIndex==0) {
                //直接加好友
                //推入用户详情界面。
                Member *host = [[PHAppStartManager defaultManager] userHost];
                if (member.userType == MemberUserTypeAdmin) {
                    [PHGroupHttpRequest requestAddAnFriend:member.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //
                        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                            
                            //这里把这个用户存入数据库
                            
                            //提示 您已成功加入群
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            
                            // Configure for text only and offset down
                            hud.mode = MBProgressHUDModeText;
                            hud.labelText = @"已提交你的加好友申请";
                            hud.margin = 10.f;hud.yOffset = 150.f;
                            hud.removeFromSuperViewOnHide = YES;
                            
                            [hud hide:YES afterDelay:2];
                            
                        }else{
                            NSLog(@"帐号错误 一般不会打印");
                        }
                        
                        
                    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
                        //
                    }];
                }else{
                    //                    NSDictionary *dic = (NSDictionary *)responseObject;
                    //            NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友:%@",host.nickName,member.nickName,alertMessage];
                    NSString * sendTag = [NSString stringWithFormat:@"%@",alertMessage];
                    
                    //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
                    NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
                    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
                    NSString *userInfoStr = [userInfo JSONString];
                    NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    
                    hud.margin = 10.f;hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    if (ret>0) {
                        //请求成功
                        hud.labelText = @"已提交你的加好友申请";
                        [hud hide:YES afterDelay:1];
                    }else{
                        hud.labelText = @"网络错误 请重试";
                        [hud hide:YES afterDelay:1];
                    }
                    
                }
        }
            break;
        case 1:{
            [self.delegate deleteFriendWithMemberId:member.memberId result:^(BOOL flag) {
                if (flag) {
                    [CommonUtil HUDShowText:@"删除成功" InView:[[UIApplication sharedApplication].delegate window]];
                    [[PHAppStartManager defaultManager]popToTabBarControllerWithIndex:1];
                }else{
                    //删除失败
                    NSLog(@"删除错误");
                }
            }];
        }
            break;
        default:
            break;
    }
    
        
    }
}
#pragma mark - 数据更新委托
-(void)rebackMemberInfo:(Member *)tmpMember{
    member = tmpMember;
    [self.tableView reloadData];
}
#pragma mark - 进入聊天
-(void)intoChat{
#warning 做的更好
    [[PHAppStartManager defaultManager]popToTabBarControllerWithIndex:1];
    if ([self.delegate respondsToSelector:@selector(pushChatViewWithMemberId:WithUserType:)]) {
        [self.delegate pushChatViewWithMemberId:member.memberId WithUserType:member.userType];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}
-(void)delFriend{
    NSLog(@"删除 好友按钮点击");
    delFriendAlert = [[UIAlertView alloc]initWithTitle:@"是否删除好友" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    delFriendAlert.tag = 1;
    [delFriendAlert show];
}

@end
