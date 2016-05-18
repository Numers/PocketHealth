//
//  PHNotificaionViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHNotificaionViewController.h"

#import "CalculateViewFrame.h"
//数据
#import "NotificationMessage.h"
#import "SNotificationMessage.h"
#import "Member.h"
#import "ClientHelper.h"
#import "CommonUtil.h"

#import "PHAppStartManager.h"
#import "PHGroupHttpRequest.h"
#import "PHChatDatabaseHelper.h"
//界面
#import "CustomSubtitleHasRightBtnTableViewCell.h"
#import "UIImageView+WebCache.h"
//#import "PHNotificationInsideUserInfoTableViewController.h"

#import "PHNotificationUserInfoViewController.h"

static NSString *identifierNotificaion = @"NotificaionFriendTypeTableViewCell";
@interface PHNotificaionViewController ()<UITableViewDataSource,UITableViewDelegate,PHNotificationUserInfoViewControllerDelegate>
{
    UITableView * notificaionTableVIew; //个人消息列表
//    UITableView * notificationGroupTypeTableView;//群列表
    NSArray * friendMsgArray;//用一个数组 个人
    NSArray * groupMsgArray; //群
    Member *host;
    
    PHNotificationUserInfoViewController * phNotificaionVC;//子页面
}
@end

@implementation PHNotificaionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通知";
    host = [[PHAppStartManager defaultManager] userHost];
    //添加右上角清空消息按钮
    [self createTopRightClearNotificaionBtn];
    //上方SegmentControl初始化
    [self createSegmentControl];
    
    
    // tablview初始化
    [self createFriendNotificationTableView];
    
    //从数据库读取所有的好友消息
    if (friendMsgArray)friendMsgArray = [[NSArray alloc]init];
    friendMsgArray = [self loadNotificaionFriendTypeMsgFromDB:MessageCodeAddFriend];
    //group消息
    if (groupMsgArray)groupMsgArray = [[NSArray alloc]init];
    groupMsgArray = [self loadNotificaionFriendTypeMsgFromDB:MessageCodeJoinGroup];
    
    //将通知设为已读取
    SNotificationMessage * snodb = [[SNotificationMessage alloc]init];
    [snodb mergeNotificaionStateHadSeeWithHostId:host.memberId];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -
#pragma mark - 初始化界面
#pragma mark -
#pragma mark - 右上角按钮
-(void)createTopRightClearNotificaionBtn{
    UIButton * clearNotifciaonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearNotifciaonBtn.frame = CGRectMake(0, 0, 60, 40);
    [clearNotifciaonBtn setTitle:@"清空" forState:UIControlStateNormal];
    [clearNotifciaonBtn addTarget:self action:@selector(clearNotifciaonBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * clearNotifciaonBarBtn = [[UIBarButtonItem alloc]initWithCustomView:clearNotifciaonBtn];
    self.navigationItem.rightBarButtonItem = clearNotifciaonBarBtn;
}
-(void)clearNotifciaonBtnClick{
    //数据库清空当前用户消息
    if (self.notificaionMessageTypeSwitchSegmentControl.selectedSegmentIndex == 0) {
        //如果在好友消息界面 清空好友消息
        [PHChatDatabaseHelper deleteFriendNotification];
        friendMsgArray = [self loadNotificaionFriendTypeMsgFromDB:MessageCodeAddFriend];
        [notificaionTableVIew reloadData];
    }else{
        //在群消息界面 清空群消息
        //如果在好友消息界面 清空好友消息
        [PHChatDatabaseHelper deleteGroupNotification];
        groupMsgArray = [self loadNotificaionFriendTypeMsgFromDB:MessageCodeJoinGroup];
        [notificaionTableVIew reloadData];
    }
}
#pragma mark -table初始化
-(void)createFriendNotificationTableView{
    notificaionTableVIew = [[UITableView alloc]init];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    frame.origin.y = self.notificaionMessageTypeSwitchSegmentControl.frame.size.height + 8;
    frame.size.height -= frame.origin.y ;
    notificaionTableVIew.delegate = self;
    notificaionTableVIew.dataSource = self;
    [notificaionTableVIew registerNib:[UINib nibWithNibName:@"CustomSubtitleHasRightBtnTableViewCell" bundle:nil] forCellReuseIdentifier:identifierNotificaion];
    notificaionTableVIew.frame = frame;
    [self.view addSubview:notificaionTableVIew];
   
}

#pragma mark - segemt初始化
-(void)createSegmentControl{
    self.notificaionMessageTypeSwitchSegmentControl = [[HMSegmentedControl alloc]initWithSectionTitles:@[@"好友消息", @"群消息"]];
    self.notificaionMessageTypeSwitchSegmentControl.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
    self.notificaionMessageTypeSwitchSegmentControl.backgroundColor = [UIColor clearColor];
    self.notificaionMessageTypeSwitchSegmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.notificaionMessageTypeSwitchSegmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    [self.notificaionMessageTypeSwitchSegmentControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.notificaionMessageTypeSwitchSegmentControl];
}
#pragma mark - 从数据库拿出消息
-(NSArray *)loadNotificaionFriendTypeMsgFromDB:(MessageCode)messageCode{
    SNotificationMessage * sNotifiMsgDB = [[SNotificationMessage alloc]init];
    return [sNotifiMsgDB selectAllNoticationMessageWithHostId:host.memberId MessageCode:messageCode ResultCount:10];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView datasourse & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.notificaionMessageTypeSwitchSegmentControl.selectedSegmentIndex == 0) {
        return friendMsgArray.count;
    }else{
        return groupMsgArray.count;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.notificaionMessageTypeSwitchSegmentControl.selectedSegmentIndex == 0) {
        NotificationMessage *notifiMsg =  [friendMsgArray objectAtIndex:indexPath.row];
        CustomSubtitleHasRightBtnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierNotificaion];
        if (cell == nil) {
            cell = [[CustomSubtitleHasRightBtnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierNotificaion];
            
        }
        cell.customLabel.text= [NSString stringWithFormat:@"%@",notifiMsg.member.nickName];
        cell.customDetailLabel.text = notifiMsg.content;
        NSString *imageStr = [NSString stringWithFormat:@"%@%@",ServerBaseURL,notifiMsg.member.headImage];
        [cell.customImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"defult_people_icons"]];
        if (notifiMsg.state == NotificationMessageStateAgree) {
            [cell.customRightBtn setTitle:@"已同意" forState:UIControlStateDisabled];
            [cell.customRightBtn setEnabled:NO];
        }else{
            [cell.customRightBtn setTitle:@"同意" forState:UIControlStateNormal];
        }
        [cell.customRightBtn addTarget:self action:@selector(agreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //        cell.accessoryView = loginButton;
        
        return cell;
    }else{
        NotificationMessage *notifiMsg =  [groupMsgArray objectAtIndex:indexPath.row];
        CustomSubtitleHasRightBtnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierNotificaion];
        if (cell == nil) {
            cell = [[CustomSubtitleHasRightBtnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierNotificaion];
            
        }
        cell.customLabel.text= [NSString stringWithFormat:@"%@",notifiMsg.nickName];
        cell.customDetailLabel.text = notifiMsg.content;
        NSString *imageStr = [NSString stringWithFormat:@"%@%@",ServerBaseURL,notifiMsg.headImg];
        [cell.customImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"defult_people_icons"]];
        if (notifiMsg.state == NotificationMessageStateAgree) {
            [cell.customRightBtn setTitle:@"已同意" forState:UIControlStateDisabled];
            [cell.customRightBtn setEnabled:NO];
        }else{
            [cell.customRightBtn setTitle:@"同意" forState:UIControlStateNormal];
        }
        [cell.customRightBtn addTarget:self action:@selector(agreeGroupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //        cell.accessoryView = loginButton;
        
        return cell;
    }

    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if (self.notificaionMessageTypeSwitchSegmentControl.selectedSegmentIndex == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NotificationMessage *notifiMsg =  [friendMsgArray objectAtIndex:indexPath.row];
        phNotificaionVC = nil;
        phNotificaionVC = [[PHNotificationUserInfoViewController alloc]init];
        phNotificaionVC.notifiMessage = notifiMsg;
        phNotificaionVC.delegate  = self;
        [self.navigationController pushViewController:phNotificaionVC animated:YES];
    }else{
        //
        NSLog(@"groupmsg click");
    }
    
    
}
#pragma mark - 子页面同意委托
-(void)agreeBtnClickReback:(NotificationMessage *)notificationMessage{
    NSLog(@"%@",notificationMessage);
    [self requestAddAnFriend:notificationMessage];
}
#pragma  mark - 点击同意之后
-(void)agreeBtnClick:(UIButton *)sender{
    
    NSLog(@"%ld",(long)sender.tag);
    NotificationMessage *notifiMsg =  [friendMsgArray objectAtIndex:sender.tag];
    [self requestAddAnFriend:notifiMsg];

}
-(void)agreeGroupBtnClick:(UIButton *)sender{
    NSLog(@"%ld",(long)sender.tag);
    NotificationMessage *notifiMsg =  [groupMsgArray objectAtIndex:sender.tag];
    [self requestAcptGroupUser:notifiMsg];
}
#pragma mark - 加好友方法
-(void)requestAddAnFriend:(NotificationMessage *)nofitcaionMessage{
    [PHGroupHttpRequest requestAddAnFriend:nofitcaionMessage.memberId WithMemberType:(MemberUserType)MemberUserTypeNil done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        bool isValidate =[CommonUtil isValidateHttpResponseObject:responseObject];
        //        if (isValidate) {
        if (isValidate) {
            nofitcaionMessage.state = NotificationMessageStateAgree;
            SNotificationMessage * notificaionMsgDB = [[SNotificationMessage alloc]init];
            [notificaionMsgDB mergeNotificaionState:nofitcaionMessage HostId:host.memberId];
            [notificaionTableVIew reloadData];
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSLog(@"requestAddAnFriend message is  %@",[dic objectForKey:@"message"]);
            //一个允许通过
            [ClientHelper acceptFriend:host.memberId Token:[CommonUtil MyToken] ToUid:nofitcaionMessage.memberId Msgsn:88888];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}
-(void)requestAcptGroupUser:(NotificationMessage *)nofitcaionMessage{
    unsigned rdid = nofitcaionMessage.recordId;
    
    [PHGroupHttpRequest adminAcptGroupUserWithRecordid:rdid toDo:joinToDoTypeAcpt done:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            nofitcaionMessage.state = NotificationMessageStateAgree;
            SNotificationMessage * notificaionMsgDB = [[SNotificationMessage alloc]init];
            [notificaionMsgDB mergeNotificaionState:nofitcaionMessage HostId:host.memberId];
            [notificaionTableVIew reloadData];
            
            [CommonUtil HUDShowText:@"操作成功" InView:[[UIApplication sharedApplication].delegate window]];
        }

    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        [CommonUtil HUDShowText:@"网络错误" InView:[[UIApplication sharedApplication].delegate window]];
    }];
}
#pragma mark - 改变消息类型
-(void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl{
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [notificaionTableVIew reloadData];
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
