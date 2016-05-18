//
//  GroupHelperIndexViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupHelperIndexViewController.h"
//界面
#import "GroupIndexTableViewCell.h"
#import "GroupChatViewController.h"
#import "CommonUtil.h"
#import "PHAddDetailFindNewGroupTableViewController.h"

//数据
#import "CalculateViewFrame.h"
#import "SGroupDB.h"
#import "Group.h"
#import "Member.h"
#import "PHAppStartManager.h"

#import "PHGroupHttpRequest.h"
#import "PHChatDatabaseHelper.h"

static NSString *identifierGroupHelperIndexCell = @"PHGroupHelperIndexTableViewCell";

@interface GroupHelperIndexViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    Member *host;
}
@end

@implementation GroupHelperIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群助手";
    //———————————————————————————————————— 数据部分初始化 (标号相同为可并行———————————————————————

    //1.获取当前用户
    [self createHost];
    //————————————————————————————————————— 界面部分初始化
    //1.创建tableview
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView.frame = frame;
    
    [_tableView registerNib:[UINib nibWithNibName:@"GroupIndexTableViewCell" bundle:nil] forCellReuseIdentifier:identifierGroupHelperIndexCell];
    //1.后台请求自己的群信息 同步群信息
    [self performSelectorInBackground:@selector(selectMyGroupWithServerHelperIndex) withObject:nil];
    
//    [self createPHGroupsAttentionTableViewDataSourceMainArray];
    //数组作为tableview的数据源
    [self.view addSubview:_tableView];
    //右上角加群
    [self createGroupChatViewRightBtn];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateGroupMessageModel:) name:@"DBTOUIGROUPMESSAGETEXT" object:nil];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //从数据库拉取群组信息 加入到数组
    [self createPHGroupsAttentionTableViewDataSourceMainArray];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - 初始化右上角群详情按钮
-(void)createGroupChatViewRightBtn{

    UIBarButtonItem * groupChatViewBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushAddGroupList)];
    self.navigationItem.rightBarButtonItem = groupChatViewBarButton;
    
}
-(void)pushAddGroupList{
    PHAddDetailFindNewGroupTableViewController * phadddetailVC = [[PHAddDetailFindNewGroupTableViewController alloc]init];
    [self.navigationController pushViewController:phadddetailVC animated:YES];
}
#pragma mark - 
#pragma mark - 数据类
#pragma mark -
#pragma mark - createHost
-(void)createHost{
    host =  [[PHAppStartManager defaultManager] userHost];
}
#pragma mark -  每次启动到这里 查询自己加入的群 更新群信息（不包括群成员）
-(void)selectMyGroupWithServerHelperIndex{
    [PHGroupHttpRequest requestSelfGroupLsitDone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSLog(@"%@",responseObject);
        //重置聊天界面群列表
        [PHChatDatabaseHelper saveMyGroupListToDb:responseObject];
        [self.tableView reloadData];
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}
#pragma mark - 群消息
-(void)updateGroupMessageModel:(id)object{
    NSLog(@"聊天主界面接受到 socket分发类 群消息 通知,进行界面更新");
    NSLog(@"updateGroupMessageModel is %@",object);
    
    GroupMessage *gMeseeage = (GroupMessage *)((NSNotification *)object).object;
    //从此处转发到groupChatVC
    //1.找到指定的group 从_chatFriendList
    Group *tmpGroup = [self findGroupFromGrouoArray:gMeseeage.belongGroupId];
    if (tmpGroup.groupChatVC != nil) {//如果在当前界面已点开该群 else表示未进入过群
        if ([tmpGroup.groupChatVC g_isCurrentPresentView]) { //如果是该群就是现在在聊天的群
#warning 消息读取状态到 groupCHatVC 修改
            //
            if (gMeseeage.contentType!=MessageContentVoice) {
                gMeseeage.readState=MessageRead;
            }
        }else{
            [CommonUtil playMessageComeNotify];
            tmpGroup.messageNotReadCount++;
            host.messageNotReadCount++;
        }
        [tmpGroup.groupChatVC addMessageFromXGPDistributor:gMeseeage isSave:NO];
    }else{
        tmpGroup.isSession = 1;
        tmpGroup.messageNotReadCount ++ ;
        host.messageNotReadCount ++;
        tmpGroup.sessionDate = gMeseeage.time;
        
        
        [tmpGroup.groupMessage addObject:gMeseeage];
        
        
        
        
    }
    [self performSelectorOnMainThread:@selector(gtableViewReloadData) withObject:nil waitUntilDone:NO];
}
//查询当前数组 数据
-(Group *)findGroupFromGrouoArray:(int)gid{
    Group *group=nil;
    for (id g in self.PHGroupsAttentionTableViewDataSourceMainArray) {
        if ([g isKindOfClass:[Group class]]) {
            Group *current=(Group *)g;
            if (gid==current.groupId) {
                group=current;
                break;
            }
        }
    }
    return group;
}
#pragma mark - createPHGroupsAttentionTableViewDataSourceMainArray
-(void)createPHGroupsAttentionTableViewDataSourceMainArray{
    if (!self.PHGroupsAttentionTableViewDataSourceMainArray) {
        self.PHGroupsAttentionTableViewDataSourceMainArray = [[NSMutableArray alloc]init];
    }
    [self.PHGroupsAttentionTableViewDataSourceMainArray removeAllObjects];
    SGroupDB * sgroupDB = [[SGroupDB alloc]init];
    [self.PHGroupsAttentionTableViewDataSourceMainArray addObjectsFromArray:[sgroupDB selectAllGroupWithBelongId:host.memberId]];
    //排序添加
//    [self.tableView reloadData];
    [self gtableViewReloadData];
}

#pragma mark
#pragma mark - 界面类
#pragma mark -
#pragma mark - tableview刷新
-(void)gtableViewReloadData
{
    [self sortChatFriendList];
    [self.tableView reloadData];
}

-(void)sortChatFriendList
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sessionDate" ascending:NO];
    [self.PHGroupsAttentionTableViewDataSourceMainArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}
#pragma mark - 创建tableview委托以及数据塞入
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.PHGroupsAttentionTableViewDataSourceMainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupIndexTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierGroupHelperIndexCell];
    if (cell == nil) {
        cell = [[GroupIndexTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierGroupHelperIndexCell];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            id inCellMember = [self.PHGroupsAttentionTableViewDataSourceMainArray objectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                if ([inCellMember isKindOfClass:[Group class]]) {
                    [cell setUpCellWithGroup:inCellMember];
                }
                
//                if ([inCellMember isKindOfClass:[HospitalAggregation class]]) {
//                    [cell setUpCellWithHospitalsAggregation:inCellMember];
//                }
//                
//                if ([inCellMember isKindOfClass:[GroupHelpAggregation class]]) {
//                    [cell setUpCellWithGroupsAggregation:inCellMember];
//                }
            });
        }
    });
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Group * inCellmember = [self.PHGroupsAttentionTableViewDataSourceMainArray objectAtIndex:indexPath.row];
    if (inCellmember != nil) {
        GroupChatViewController *groupChatVC = [[GroupChatViewController alloc]initWithGroup:inCellmember WithHostMember:host];
        inCellmember.groupChatVC = groupChatVC;
        [self.navigationController pushViewController:groupChatVC animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 65;
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
