//
//  PHAddDetailMemberTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAddDetailMemberTableViewController.h"

//界面类
#import "MBProgressHUD.h"
#import "PHGroupHttpRequest.h"
#import "PHAppStartManager.h"
#import "CalculateViewFrame.h"
#import "JSONKit.h"

#import "PHGroupPersonalInfoCellHeaderViewController.h"
#import "ClientHelper.h"
#import "UINavigationController+PHNavigationController.h"

static NSString * identifierAddDetailMemberInfoCell = @"identifierAddDetailMemberInfoCell";
@interface PHAddDetailMemberTableViewController ()<UIAlertViewDelegate>
{
    Member * member;
    UIAlertView * addFriendAlert;
}
@end

@implementation PHAddDetailMemberTableViewController

-(id)initWithMember:(Member *)m{
    self = [super init];
    if(self){
        member = m;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //界面构造简介

//    [self.navigationController setTranslucentView];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController.navigationBar setTranslucent:YES];
//    CGRect frame = [CalculateViewFrame viewFrame:nil withTabBarController:self.tabBarController];
//    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    self.tableView.sectionHeaderHeight = 0;
    PHGroupPersonalInfoCellHeaderViewController * phGPHeadViewVC =[[PHGroupPersonalInfoCellHeaderViewController alloc]initWithMemberId:member.memberId];
    self.tableView.tableHeaderView = phGPHeadViewVC.view;
    
    UIButton *addFriendBtn=  [UIButton buttonWithType:UIButtonTypeSystem];
    addFriendBtn.frame = CGRectMake( 0 ,0, 0, 40);
    [addFriendBtn setBackgroundImage:[UIImage imageNamed:@"naviTopBarColor"] forState:UIControlStateNormal];
    [addFriendBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    addFriendBtn.tintColor = [UIColor colorWithRed:255 green:254 blue:254 alpha:1];
    [addFriendBtn setTitle:@"加为好友" forState:UIControlStateNormal];
    self.tableView.tableFooterView = addFriendBtn;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController setOtherViewNavigation];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierAddDetailMemberInfoCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierAddDetailMemberInfoCell];
    }
    
    return cell;
}
#pragma mark - 添加好友addFriend
-(void)addFriend{
    NSLog(@"加好友按钮点击");
    addFriendAlert = [[UIAlertView alloc]initWithTitle:@"确认为好友" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [addFriendAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (buttonIndex==0) {
                        //直接加好友
                        //推入用户详情界面。
                        Member *host = [[PHAppStartManager defaultManager] userHost];
                        //+(void)requestAddAnFriend:(long long)toid WithFriendType:(MemberFriendType)friendType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
                        [PHGroupHttpRequest requestAddAnFriend:member.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
                            //
                            if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            //                    NSDictionary *dic = (NSDictionary *)responseObject;
                                NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
            //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
                                NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
                                NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
                                NSString *userInfoStr = [userInfo JSONString];
                                NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
                                //这里把这个用户存入数据库
                                
                                
            
                                NSLog(@"addFriend %ld",(long)ret);
                                //提示 您已成功加入群
                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                
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
        }
}

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

@end
