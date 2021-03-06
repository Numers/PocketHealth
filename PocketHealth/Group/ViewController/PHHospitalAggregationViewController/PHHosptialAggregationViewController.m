//
//  PHHosptialAggregationViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHHosptialAggregationViewController.h"
#import "PHAppStartManager.h"
#import "PrivateChatViewViewController.h"

//数据型
#import "Member.h"
#import "SFirendDB.h"
#import "GroupIndexTableViewCell.h"
#import "CalculateViewFrame.h"

#import "CommonUtil.h"
#import "SOneForOneMessageDB.h"


static NSString *identifierHosptialAggregationCell = @"PHHosptialAggregationCell";

@interface PHHosptialAggregationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    Member *host;
}
@end



@implementation PHHosptialAggregationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"医院号";
    //———————————————————————————————————— 数据部分初始化 (标号相同为可并行  ———————————————————————
    //1.获取当前用户
    [self createHost];
    
    //————————————————————————————————————— 界面部分初始化
    //1.创建tableview
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView.frame = frame;
    
    [_tableView registerNib:[UINib nibWithNibName:@"GroupIndexTableViewCell" bundle:nil] forCellReuseIdentifier:identifierHosptialAggregationCell];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DBTOUIPRIVATEMESSAGETEXTInside" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
        //
        NSDictionary * dic = (NSDictionary *)((NSNotification *)notification).object;
        [self uploadMyPrivateNotification:dic];
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadMyPrivateNotification:) name:@"DBTOUIPRIVATEMESSAGETEXTInside" object:nil];
    
    [self createHosptialAggregationChatTableViewDataSourceMainArray];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //记录当前的
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 消息分发处理 私聊刷新
-(void)uploadMyPrivateNotification:(NSDictionary *)dic{
    //查看自己的数组
    OneForOneMessage * pMeseeage = [dic objectForKey:@"msg"];
    Member * member = [dic objectForKey:@"member"];
    
    Member * tmpMember = [self searchHospitalInChatList:member.memberId];
    if (tmpMember == nil) {
        //忽略
    }else{
        if (tmpMember.isSession == 0) {
            
        }else{
            tmpMember.sessionDate = pMeseeage.time;
            if (tmpMember.chatVC != nil) {
                if([tmpMember.chatVC isCurrentPresentView])
                {
                    pMeseeage.readState = MessageRead;
                    
                }else{
                    [CommonUtil playMessageComeNotify];
                    tmpMember.messageNotReadCount++;
                    host.messageNotReadCount++;
                }
                [tmpMember.chatVC addMessage:pMeseeage isSave:NO];
            }else{
                [CommonUtil playMessageComeNotify];
                tmpMember.isSession = 1;
                SFirendDB *frienddb = [[SFirendDB alloc] init];
                [frienddb mergeWithUser:tmpMember WithBelongUid:host.memberId];
                //                [frienddb close];
                [tmpMember.messageArr addObject:pMeseeage];
                tmpMember.messageNotReadCount++;
                host.messageNotReadCount++;
            }
        }
    }
    [self.tableView reloadData];
}
#pragma mark -
#pragma mark - createMemberHost
#pragma mark -
-(void)createHost{
    host =  [[PHAppStartManager defaultManager] userHost];
}
-(void)createHosptialAggregationChatTableViewDataSourceMainArray{
    //初始化数组
    if (!self.PHHopstailChatTableViewDataSourceMainArray) {
        self.PHHopstailChatTableViewDataSourceMainArray = [[NSMutableArray alloc]init];
    }
    //清空数据
    [self.PHHopstailChatTableViewDataSourceMainArray removeAllObjects];
    
    //获取当前好友为医院的集合
    SFirendDB * sfirenddb = [[SFirendDB alloc]init];
    NSArray * chatingMemberArray = [sfirenddb selectWithoutSessionUserWithHospitalWithBelongUid:host.memberId];
    [self.PHHopstailChatTableViewDataSourceMainArray addObjectsFromArray:chatingMemberArray];
    
    [self.tableView reloadData];
}
#pragma mark - 创建tableview委托以及数据塞入
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.PHHopstailChatTableViewDataSourceMainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupIndexTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierHosptialAggregationCell];
    if (cell == nil) {
        cell = [[GroupIndexTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierHosptialAggregationCell];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            id inCellMember = [self.PHHopstailChatTableViewDataSourceMainArray objectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                if ([inCellMember isKindOfClass:[Member class]]) {
                    [cell setUpCellWithMember:inCellMember];
                }
            });
        }
    });
    
    
    return cell;
}
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    //处理用户私聊  需要进行一些操作
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"%d", indexPath.row);
//        //获取我删除的数据源数据
//        Member * tmpMember = self.PHHopstailChatTableViewDataSourceMainArray[indexPath.row];
//        //对member进行解析 然后处理 调用本地方法
//        //1.session = 0
//        tmpMember.isSession = NO;
//        SFirendDB * sfriendDB  = [[SFirendDB alloc]init];
//        [sfriendDB mergeWithUser:tmpMember WithBelongUid:host.memberId];
//        //2.聊天消息清空
//        SOneForOneMessageDB * smessageDB = [[SOneForOneMessageDB alloc]init];
//        [smessageDB deleteMessageWithUid:tmpMember.memberId WithContactUid:host.memberId];
//        //仅清除数据
//        [self.PHHopstailChatTableViewDataSourceMainArray removeObjectAtIndex:[indexPath row]];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
//    }
//    
//}
////修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}
#pragma mark -  cell点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id inCellmember = [self.PHHopstailChatTableViewDataSourceMainArray objectAtIndex:indexPath.row];
    if (inCellmember != nil) {
        if ([inCellmember isKindOfClass:[Member class]]){
            Member * oneMember = (Member *)inCellmember;
            PrivateChatViewViewController *privateVC = [[PrivateChatViewViewController alloc]initWithMember:oneMember WithHostMember:host];
            oneMember.chatVC = privateVC;
            [self.navigationController pushViewController:privateVC animated:YES];
            //推入私聊对话界面
        }
    }
}
#pragma mark -  cell 高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}
- ( CGFloat )tableView:( UITableView  *)tableView heightForRowAtIndexPath:( NSIndexPath  *)indexPath
{
    return   65 ;
}

#pragma mark - 在 chatFriendList 找到该消息的聊天人
-(Member *)searchHospitalInChatList:(long long)memberId{
    NSInteger i = 0;
    Member *temp = nil;
    for (id m in self.PHHopstailChatTableViewDataSourceMainArray) {
        if ([m isKindOfClass:[Member class]]) {
            Member *current = (Member *)m;
            if (memberId == current.memberId) {
                temp = current;
                break;
            }
        }
        i++;
    }
    return temp;
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
