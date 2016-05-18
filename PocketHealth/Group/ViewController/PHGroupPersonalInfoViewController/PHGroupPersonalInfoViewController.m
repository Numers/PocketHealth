//
//  PHGroupPersonalInfoViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/15.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGroupPersonalInfoViewController.h"
//界面类
#import "CalculateViewFrame.h"
#import "PHGroupPersonalInfoCellHeaderViewController.h"
#import "UINavigationController+PHNavigationController.h"
#import "MBProgressHUD.h"

#import "PHAppStartManager.h"

//数据
#import "PHGroupHttpRequest.h"

#import "JSONKit.h"
#import "ClientHelper.h"

#import "PHQRCodeViewController.h"


static NSString *identifierPersonalInfoCell = @"PHPersonalInfoCellTableViewCell";

@interface PHGroupPersonalInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,PHPushChatViewDelegate,UIActionSheetDelegate>
{
    GroupMember * selectedMember;
    GroupMember *selectedHost;
    
    UIAlertView * addFriendAlert;
}
@property (strong, nonatomic) IBOutlet UITableView *personalMainTableView;

@end

@implementation PHGroupPersonalInfoViewController

-(id)initWithGroupMember:(GroupMember *)member WithMyGroupHost:(GroupMember *)ghost{
    self = [super init];
    if (self) {
        //
        selectedMember = member;
        selectedHost = ghost;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //界面构造简介
    [self.navigationController setTranslucentView];

    //0 host 够找

    //0.初始化tableview
    CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
    self.personalMainTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.personalMainTableView.delegate = self;
    self.personalMainTableView.dataSource = self;
    self.personalMainTableView.sectionHeaderHeight = 0;
    PHGroupPersonalInfoCellHeaderViewController * phGPHeadViewVC =[[PHGroupPersonalInfoCellHeaderViewController alloc]initWithMemberId:selectedMember.memberId];

    
    self.personalMainTableView.tableHeaderView = phGPHeadViewVC.view;
    
    //添加 tableview  footview
    [self createTableViewFooterView];
    
    
    //右上角入口
    [self.view addSubview:self.personalMainTableView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (selectedHost.groupMemberType!=groupUser) {
        [self createGroupMemberAdminBtn];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setOtherViewNavigation];
}
#pragma mark - 初始化右上角群详情按钮
-(void)createGroupMemberAdminBtn{
    //权限越大 数字越小 如果被选择的用户的权限 小于 操作人的权限 那么 就含有管理按钮
    if (selectedMember.groupMemberType > selectedHost.groupMemberType) {
        UIButton * groupMemberAdminBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        groupMemberAdminBtn.frame = CGRectMake(0, 0, 40, 40);
        [groupMemberAdminBtn setTitle:@"管理" forState:UIControlStateNormal];
        [groupMemberAdminBtn addTarget:self action:@selector(groupChatAdminBtnClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * groupChatViewBarButton = [[UIBarButtonItem alloc]initWithCustomView:groupMemberAdminBtn];
        self.navigationItem.rightBarButtonItem = groupChatViewBarButton;
    }
    
}
#pragma mark - tableview footview
-(void)createTableViewFooterView{
    UIView * btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.personalMainTableView.frame.size.width, 100)];
    
    UIButton *addChatBtn=  [UIButton buttonWithType:UIButtonTypeSystem];
    addChatBtn.frame = CGRectMake( 0 ,0, self.personalMainTableView.frame.size.width, 40);
    [addChatBtn setBackgroundImage:[UIImage imageNamed:@"naviTopBarColor"] forState:UIControlStateNormal];
    [addChatBtn addTarget:self action:@selector(addChatting) forControlEvents:UIControlEventTouchUpInside];
    addChatBtn.tintColor = [UIColor colorWithRed:255 green:254 blue:254 alpha:1];
    [addChatBtn setTitle:@"点击聊天" forState:UIControlStateNormal];
    
    [btnView addSubview:addChatBtn];
    
    UIButton *addFriendBtn=  [UIButton buttonWithType:UIButtonTypeSystem];
    addFriendBtn.frame = CGRectMake( 0 ,50, self.personalMainTableView.frame.size.width, 40);
    [addFriendBtn setBackgroundImage:[UIImage imageNamed:@"naviTopBarColor"] forState:UIControlStateNormal];
    [addFriendBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    addFriendBtn.tintColor = [UIColor colorWithRed:255 green:254 blue:254 alpha:1];
    [addFriendBtn setTitle:@"加为好友" forState:UIControlStateNormal];
    
    [btnView addSubview:addFriendBtn];
    
    self.personalMainTableView.tableFooterView = btnView;
}
-(void)groupChatAdminBtnClick{

    
    if (IOS_VERSION_8_OR_ABOVE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if (selectedHost.groupMemberType == groupOwner) {
            NSString *settingADMINBtnStr;
            UIAlertAction *adminAction;
            if (selectedMember.groupMemberType == groupAdmin) {
                settingADMINBtnStr =  NSLocalizedString(@"取消管理员 ", nil);
                adminAction = [UIAlertAction actionWithTitle:settingADMINBtnStr style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSLog(@"取消管理员");
                    [self cancalAdminOperating];
                }];
            }else{
                settingADMINBtnStr =  NSLocalizedString(@"设置管理员 ", nil);
                adminAction = [UIAlertAction actionWithTitle:settingADMINBtnStr style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSLog(@"我设置管理员");
                    [self settingAdminOperating];
                    
                }];
            }
            [alertController addAction:adminAction];
            
        }
        NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
        NSString *deleteButtonTitle = NSLocalizedString(@"删除用户", nil);
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"取消点击 ");
        }];
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"删除用户");
            //菊花提醒
            [self deleteUserAction];
            
        }];
        // Add the actions.
        [alertController addAction:cancelAction];
        [alertController addAction:destructiveAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        //ios8以下
        UIActionSheet * actionSheet;
        if (selectedHost.groupMemberType == groupOwner) {
           
            if (selectedMember.groupMemberType == groupAdmin) {

                actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除用户" otherButtonTitles:@"取消管理员", nil];
                actionSheet.tag = 1;


            }else{
                actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除用户" otherButtonTitles:@"设置管理员", nil];
                actionSheet.tag = 2;

            }
            
        }else{
            actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除用户" otherButtonTitles:nil];
        }
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
    }
    
    
    
    

    
}
#pragma mark - ios7 兼容 actionSheetdelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"点击删除用户");
            //菊花提醒
            [self deleteUserAction];
        }
            break;
        case 1:{
            if (actionSheet.tag == 1) {
                                    NSLog(@"取消管理员");
                                    [self cancalAdminOperating];
            }else if (actionSheet.tag == 2){
                                    NSLog(@"我设置管理员");
                                    [self settingAdminOperating];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - tableview delegate and datasoucre
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if(section == 1){
        return 2;
    }else if (section == 2){
        return 1;
    }else{
        return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0) ) {
        return 0.0f;
    }else{
        return 48.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierPersonalInfoCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierPersonalInfoCell];
    }
    switch (indexPath.section) {
        case 0:{
            
        }
            break;
        case 1:{
            switch (indexPath.row) {
                case 0:
                {
                   cell.textLabel.text= @"二维码名片";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:{
                    cell.textLabel.text= @"上次发言时间";
                    cell.detailTextLabel.text = selectedMember.lastChatTime;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:{
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
                    //推入二维码名片界面
                    //推入二维码名片
                    PHQRCodeViewController * qrVC = [[PHQRCodeViewController alloc]initWithMember:selectedMember WithMemberType:selectedMember.userType];
                    [self.navigationController pushViewController:qrVC animated:YES];
                }
                    break;
                case 1:
                {
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    
                    break;
                case 1:
                    
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - 添加好友addFriend
-(void)addFriend{
    addFriendAlert = [[UIAlertView alloc]initWithTitle:@"确认加为好友" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    addFriendAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addFriendAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *tf=[alertView textFieldAtIndex:0];
    NSLog(@"alertView.message %@",tf.text);
    NSString * alertMessage = tf.text;
    if (buttonIndex==0) {
        //直接加好友
        //推入用户详情界面。
//        Member *host = [[PHAppStartManager defaultManager] userHost];
//        +(void)requestAddAnFriend:(long long)toid WithFriendType:(MemberFriendType)friendType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
        if (selectedMember.userType == MemberUserTypeAdmin) {
            [PHGroupHttpRequest requestAddAnFriend:selectedMember.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
                //
                NSDictionary * dic = (NSDictionary *)responseObject;
                NSString * message = [dic objectForKey:@"Message"];
                
                //提示 您已成功加入群
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                
                hud.margin = 10.f;hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                    //                    NSDictionary *dic = (NSDictionary *)responseObject;
//                    NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",selectedHost.nickName,selectedMember.nickName];
//                    //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
//                    NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:selectedHost.headImage,@"HeadImg",selectedHost.loginName,@"LoginName",selectedHost.nickName,@"NickName",[NSString stringWithFormat:@"%lld",selectedHost.memberId],@"UserId",[NSString stringWithFormat:@"%u",selectedHost.userType],@"UserType", nil];
//                    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
//                    NSString *userInfoStr = [userInfo JSONString];
//                    NSInteger ret =  [ClientHelper addFriend:selectedHost.memberId Token:[CommonUtil MyToken] ToUid:selectedMember.memberId UserInfo:userInfoStr Msgsn:99999];
                    //这里把这个用户存入数据库
                    
                    
                    
                    hud.labelText = message;
                    [hud hide:YES afterDelay:1];
                    
                }else{
                    
                    hud.labelText = message;
                    [hud hide:YES afterDelay:1];
                    NSLog(@"帐号错误 一般不会打印");
                }
            } error:^(AFHTTPRequestOperation *operation, NSError *error) {
                //
            }];
        }else{
            //调用add
            NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友:%@",selectedHost.nickName,selectedMember.nickName,alertMessage];
            //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
            NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:selectedHost.headImage,@"HeadImg",selectedHost.loginName,@"LoginName",selectedHost.nickName,@"NickName",[NSString stringWithFormat:@"%lld",selectedHost.memberId],@"UserId",[NSString stringWithFormat:@"%u",selectedHost.userType],@"UserType", nil];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
            NSString *userInfoStr = [userInfo JSONString];
            NSInteger ret =  [ClientHelper addFriend:selectedHost.memberId Token:[CommonUtil MyToken] ToUid:selectedMember.memberId UserInfo:userInfoStr Msgsn:99999];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
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
}
#pragma mark - 点击聊天
-(void)addChatting{
    //pop 到顶  然后 推入私聊界面
    [[PHAppStartManager defaultManager]popToTabBarControllerWithIndex:1];
    id phGroupChatHomeVC = [[PHAppStartManager defaultManager] returnPHGroupChatHomeView];
    self.delegatePush = phGroupChatHomeVC;
    if ([self.delegatePush respondsToSelector:@selector(pushChatViewWithMemberId:WithUserType:)]) {
        [self.delegatePush pushChatViewWithMemberId:selectedMember.memberId WithUserType:selectedMember.userType];
    }
}
#pragma mark - 踢出用户
-(void)deleteUserAction{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [PHGroupHttpRequest requestDeleteUserWith:selectedMember.groupId WithDeletedId:selectedMember.memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"删除id : %lld 昵称 : %@",selectedMember.memberId,selectedMember.nickName);
        
        NSDictionary * dic = (NSDictionary *)responseObject;
        NSString * message = [dic objectForKey:@"Messge"];
     
        
        int code = [[dic objectForKey:@"Code"]intValue];
        if (code == 1) {
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
            
            if ([self.delegate respondsToSelector:@selector(deleteSelectedMember:)]) {
                [self.delegate deleteSelectedMember:selectedMember];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
        }
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        hud.labelText = @"网络错误";
        [hud hide:YES afterDelay:1];
        
    }];

}
#pragma mark - 处理设置与 取消管理员 方法
-(void)cancalAdminOperating{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [PHGroupHttpRequest settingGroupAdminOperateId:selectedMember.memberId WithGroupId:selectedMember.groupId OperateType:groupSettingAdminTypeCancal done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        
        NSDictionary * dic = (NSDictionary *)responseObject;
        NSString * message = [dic objectForKey:@"Message"];
        
        
        
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            //
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
            selectedMember.groupMemberType = groupUser;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        hud.labelText = @"网络错误";
        [hud hide:YES afterDelay:1];
    }];
}
//设置管理员
-(void)settingAdminOperating{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [PHGroupHttpRequest settingGroupAdminOperateId:selectedMember.memberId WithGroupId:selectedMember.groupId OperateType:groupSettingAdminTypeSetting done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSDictionary * dic = (NSDictionary *)responseObject;
        NSString * message = [dic objectForKey:@"Message"];

        
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            //修改内存中的值
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
            selectedMember.groupMemberType = groupAdmin;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if (message) {
                hud.labelText = message;
            }
            [hud hide:YES afterDelay:1];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        hud.labelText = @"网络错误";
        [hud hide:YES afterDelay:1];
    }];
}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 350;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
