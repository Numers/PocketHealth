//
//  GroupChatTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupChatTableViewController.h"

//界面
#import "EGORefreshTableHeaderView.h"
#import "VoicePlayDevice.h"
#import "UIImageView+WebCache.h"
#import "GroupMessageCell.h"

//数据
#import "CalculateViewFrame.h"
#import "SGroupDB.h"
#import "SGroupMemberDB.h"
#import "SGroupMessageDB.h"
#import "ChatCacheFileUtil.h"
#import "VoiceConverter.h"


#define CONNECT_TIMEOUT 15.0
#define WRITE_TIMEOUT 10.0
#define SHOWMSGBETWEENTIME 120.0

@interface GroupChatTableViewController ()<UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    //下拉刷新 add by yangfan
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    int offsetIndex;
    
    
    //++++
    int refreshCount;
}
@end

@implementation GroupChatTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithGroup:(Group *)group WithHostMember:(Member *)host
{
    self = [super init];
    if (self) {
        _chatToGroup = group;
        _hostMember = host;
        _g_isCurrentPresentView = NO;
    }
    return self;
}

#pragma mark - 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    //[self.navigationController.navigationBar setTranslucent:YES];
    CGFloat inputViewHeight;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    
    self.g_tableView = [[UITableView alloc] init];
    self.g_tableView.delegate = self;
    self.g_tableView.dataSource = self;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    self.g_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, frame.size.height-inputViewHeight);
    
    //    NSLog(@"%f %f",self.g_tableView.frame.origin.y,self.g_tableView.frame.size.height);
    self.g_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.g_tableView.allowsSelection = NO;
    [self.view addSubview:self.g_tableView];
    
    //下拉加载 如果是加群之前的60条消息 是没有下啦刷新的
    SGroupDB *sgroupDB=[[SGroupDB alloc]init];
    if ([sgroupDB isExistGroupWithGid: self.chatToGroup.groupId WithBelongUid:self.hostMember.memberId]) {
        if (self.isFromGroupChatView!=isFromGroupChatViewAdd) {
            if(_refreshHeaderView == nil)
            {
                EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.g_tableView.bounds.size.height, self.view.frame.size.width, self.g_tableView.bounds.size.height)];
                
                view.delegate = self;
                [self.g_tableView addSubview:view];
                _refreshHeaderView = view;
            }
            [_refreshHeaderView refreshLastUpdatedDate];
        }
    }

    _allGroupMessagesFrame = [[NSMutableArray alloc]init];
#warning 补上方法
//    SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
//    [groupMessagedb mergeMessageStateIsSendingToFaildWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.g_tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self groupNotificationSetting];
    
    //modify by yangfan 无论groupMessage是否有消息，都从数据库获取10条数据
    //    if (_chatToGroup.groupMessage.count > 0) {
    //        [self TableViewReloadData];
    //    }
    
    
    
    NSLog(@" moving from :%hhd",self.isMovingToParentViewController);
    
    //如果从父页面进来就取10条数据 否则数据不重新加载
    if (self.isMovingToParentViewController) {
        SGroupMessageDB *sgmessagedb=[[SGroupMessageDB alloc]init];
        _chatToGroup.groupMessage = [sgmessagedb selectGroupMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
        
        NSLog(@"%@",_chatToGroup.groupMessage);
        offsetIndex=0;
        if (self.isFromGroupChatView!=isFromGroupChatViewAdd) {
            //
            [_allGroupMessagesFrame removeAllObjects];
            if (_chatToGroup.groupMessage.count > 0) {
                NSMutableArray *tmpGroupMessageArray=[NSMutableArray arrayWithArray:_chatToGroup.groupMessage];
                _allGroupMessagesFrame=[self createAllGroupMessagesFrameWithGroupMessage:tmpGroupMessageArray];
            }
            NSLog(@"%@",_allGroupMessagesFrame);
            GroupMessageFrame *gMsgFrame  = _allGroupMessagesFrame.lastObject;
            self.messageSN = gMsgFrame.message.MsgSN++;
            
            NSLog(@"self.messageSN is : %ld",(long)self.messageSN);
            [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
        }
        
        
        //            [self TableViewReloadData];
        
        
        
        _g_isCurrentPresentView = YES;
        
//        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
//        [groupMessagedb mergeMessageStateIsSendingToFaildWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
//        [groupMessagedb mergeNotReadMessageToReadMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
        
        
        
        _hostMember.messageNotReadCount = _hostMember.messageNotReadCount-_chatToGroup.messageNotReadCount;
        _chatToGroup.messageNotReadCount = 0;
    }

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated

{
    
    [super viewWillDisappear:animated];
    _g_isCurrentPresentView = NO;
    [g_audioPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Checking if we are disappearing because of the back button
    
    if ([self isMovingFromParentViewController])
        
    {
        // In case that back button is pressed, insert your code here
    }
}

#pragma mark -  通知定义
-(void)groupNotificationSetting
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSendGroupMessageToTableView:) name:@"TABLEVIEWRELOAD" object:nil];
}
#pragma mark 给数据源增加内容 1
- (void)addMessage:(GroupMessage *)msg{
    
    GroupMessageFrame *mf = [[GroupMessageFrame alloc] init];
    if (_chatToGroup.groupMessage.count > 0) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        GroupMessage *previousMsg = [_chatToGroup.groupMessage objectAtIndex:_chatToGroup.groupMessage.count-1];
//        NSDate *previousTime = [fmt dateFromString:previousMsg.time];
//        NSDate *messageDate = [fmt dateFromString:msg.time];
        
//        NSTimeInterval i = [messageDate timeIntervalSinceDate:previousTime];
        NSTimeInterval i = msg.time - previousMsg.time;
        mf.showTime = i>SHOWMSGBETWEENTIME?true:false;
    }else
    {
        mf.showTime = true;
    }
    mf.message = msg;
    SGroupMessageDB *msgdb = [[SGroupMessageDB alloc] init];
    
    if (self.isFromGroupChatView!=isFromGroupChatViewAdd) {
        //
        //        SGroupMessageDB *sgmessagedb=[[SGroupMessageDB alloc]init];
//        if ([msg isValidate]) {
            [msgdb saveGroupMessage:msg WithContactUid:_hostMember.memberId];
            _chatToGroup.isSession = 1;
            SGroupDB *groupdb = [[SGroupDB alloc] init];
            [groupdb mergeGroup:_chatToGroup];
//        }
        
        _chatToGroup.groupMessage = [msgdb selectGroupMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
        //        [_allGroupMessagesFrame addObject:mf];
        //        [_allGroupMessagesFrame removeAllObjects];
        //每次都去从数据库获取。
        if (_chatToGroup.groupMessage.count > 0) {
            NSMutableArray *tmpGroupMessageArray=[NSMutableArray arrayWithArray:_chatToGroup.groupMessage];
            _allGroupMessagesFrame=[self createAllGroupMessagesFrameWithGroupMessage:tmpGroupMessageArray];
            
        }
        //        GroupMessageFrame *printGroupFrame=(GroupMessageFrame *)_allGroupMessagesFrame[9];
        //        NSLog(@"%@ %@",printGroupFrame.message.time,printGroupFrame.message.content);
        
        [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
        
    }else{
        [_chatToGroup.groupMessage addObject:msg];
        //        if (_g_isCurrentPresentView) {
        [_allGroupMessagesFrame addObject:mf];
        //        }
        
    }
    
    
    //    [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
    
}
#pragma mark 给数据源增加内容 2 新版
-(void)addMessageFromXGPDistributor:(GroupMessage *)gMessage{
    
    NSLog(@"addMessageFromXGPDistributor Message content is : %@",gMessage.content);
    gMessage.MsgSN = self.messageSN ++ ;
    GroupMessageFrame *mf = [[GroupMessageFrame alloc] init];
    if (_chatToGroup.groupMessage.count > 0) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        GroupMessage *previousMsg = [_chatToGroup.groupMessage objectAtIndex:_chatToGroup.groupMessage.count-1];
//        NSDate *previousTime = [fmt dateFromString:previousMsg.time];
//        NSDate *messageDate = [fmt dateFromString:gMessage.time];
//        NSTimeInterval i = [messageDate timeIntervalSinceDate:previousTime];
        NSTimeInterval i = gMessage.time - previousMsg.time;
        mf.showTime = i>SHOWMSGBETWEENTIME?true:false;
    }else
    {
        mf.showTime = true;
    }
    mf.message = gMessage;
    SGroupMessageDB *msgdb = [[SGroupMessageDB alloc] init];
    if (self.isFromGroupChatView!=isFromGroupChatViewAdd) {
        _chatToGroup.isSession = 1;
        SGroupDB *groupdb = [[SGroupDB alloc] init];
        [groupdb mergeGroup:_chatToGroup];
        
        
        _chatToGroup.groupMessage = [msgdb selectGroupMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
        //每次都去从数据库获取。
        if (_chatToGroup.groupMessage.count > 0) {
            NSMutableArray *tmpGroupMessageArray=[NSMutableArray arrayWithArray:_chatToGroup.groupMessage];
            _allGroupMessagesFrame=[self createAllGroupMessagesFrameWithGroupMessage:tmpGroupMessageArray];
            
        }
        [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
        
    }else{
        [_chatToGroup.groupMessage addObject:gMessage];
        [_allGroupMessagesFrame addObject:mf];
    }
    
}

#pragma mark -  给数据源添加内容
-(NSMutableArray *)createAllGroupMessagesFrameWithGroupMessage:(NSMutableArray *)groupMessageArray{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableArray *tmpGroupMessageFrame=[[NSMutableArray alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *previousTime = [NSDate dateWithTimeIntervalSinceNow:0];
    for (GroupMessage *m in groupMessageArray) {
        //如果code是加群消息，就过滤 不在聊天消息中显示
        //        if (m.code==MessageCodeJoinGroup) {
        //            continue;
        //        }
        GroupMessageFrame *messageFrame = [[GroupMessageFrame alloc] init];
//        NSDate *messageDate = [formatter dateFromString:m.time];
//        NSTimeInterval i = [messageDate timeIntervalSinceDate:previousTime];
        NSTimeInterval i = m.time - previousTime.timeIntervalSinceNow;
        messageFrame.showTime = i>SHOWMSGBETWEENTIME?true:false;
        messageFrame.message = m;
//        previousTime = messageDate;
        [tmpGroupMessageFrame addObject:messageFrame];
        
    }
    return tmpGroupMessageFrame;
    
}

-(void)addSendGroupMessageToTableView:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    NSInteger retcode = [[dic valueForKey:@"retcode"] integerValue];
    NSInteger msgsn = [[dic valueForKey:@"msgsn"] integerValue];
    
    
    
    //    msgsn>_chatToGroup.groupMessage.count?msgsn=msgsn%10:NSLog(@"msgsn : %u",msgsn);
    //当页面加载过更多，发送消息的时候 msgsn一定会大于9 所以如果是大于_chatToGroup.groupMessage.count 那么说明刷新页面已经先一步执行
    
    //那么我们就需要处理下msgsn的值 使其正确的对应  并修改消息状态
    
    //    if (msgsn < _chatToGroup.groupMessage.count) {
    //stopSendNewMessage 状态修改 放在了这个函数中
    //        self.allGroupMessagesFrame 中获取数据
    //    NSLog(@"self.chatToGroup.groupMessage is %@",self.chatToGroup.groupMessage);
    for (GroupMessageFrame *tmpMessageFrame in self.allGroupMessagesFrame) {
        
        NSLog(@"tmpMessage.MsgSN %u is equel self.messageSN %u ",tmpMessageFrame.message.MsgSN , msgsn);
        if (tmpMessageFrame.message.MsgSN == msgsn) {
            if (tmpMessageFrame.message.state == MessageIsSend|| tmpMessageFrame.message.state == MessageFailed) {
                if (retcode == 0) {
                    tmpMessageFrame.message.state = MessageSuccess;
                }else{
                    tmpMessageFrame.message.state = MessageFailed;
                }
                SGroupMessageDB *msgdb = [[SGroupMessageDB alloc] init];
//                if ([tmpMessageFrame.message isValidate]) {
                    [msgdb mergeGroupMessage:tmpMessageFrame.message WithContactUid:_hostMember.memberId];
//                }
                
                NSLog(@"%ld, %ld",(long)retcode,(long)msgsn);
                [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
            }
            break;
        }
        //        }
        //        GroupMessage *message = [_chatToGroup.groupMessage objectAtIndex:msgsn];
        //        if (message.state == MessageIsSend|| message.state == MessageFailed) {
        //            if (retcode == 0) {
        //                message.state = MessageSuccess;
        //            }else{
        //                message.state = MessageFailed;
        //            }
        //            SGroupMessageDB *msgdb = [[SGroupMessageDB alloc] init];
        //            if ([message isValidate]) {
        //                [msgdb mergeGroupMessage:message WithContactUid:_hostMember.memberId];
        //            }
        //
        //            NSLog(@"%ld, %ld",(long)retcode,(long)msgsn);
        //            [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
        //        }
    }
}
#pragma mark -  tableview reload
-(void)TableViewReloadData
{
    
    NSLog(@"%u",refreshCount);
    refreshCount++;
    [self.g_tableView reloadData];
    [self g_tableViewSrollToBotton];
}
-(void)TableViewReloadDataWithoutScrollToBottom{
    [self.g_tableView reloadData];
}
-(void)g_tableViewSrollToBotton{
    //滚动至当前行
    
    //如果是红包那么就不滑动 直接ret
    
    if (_selectRedPacketPushViewFlag) {
        _selectRedPacketPushViewFlag=NO;
        return;
    }
    
    if (_allGroupMessagesFrame.count>0) {
        
        NSLog(@"_allGroupMessagesFrame.count - 1 is %u",_allGroupMessagesFrame.count - 1);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_allGroupMessagesFrame.count - 1 inSection:0];
        [self.g_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - tableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"_allGroupMessagesFrame.count %u",_allGroupMessagesFrame.count);
    return _allGroupMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupMessageCell *cell;
    if (self.retSimpleResult>0) {
        //
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[GroupMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                //Data processing
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update Interface
                    // 设置数据
                    NSLog(@"indexPath.row %ld",(long)indexPath.row);
                    cell.messageFrame = _allGroupMessagesFrame[indexPath.row];
                    
                    
                    //    GroupMessage *message = [_chatToGroup.groupMessage objectAtIndex:indexPath.row];
                    
                    GroupMessage *message =cell.messageFrame.message;
                    //                    [cell.iconView setImageWithURL:[NSURL URLWithString:cell.messageFrame.message.icon] placeholderImage:[UIImage imageNamed:@"defult_head.png"]];
                    cell.delegate = self;
                    cell.didTouchIcon=@selector(onSelectIcon:);
                    cell.index=indexPath.row;
                    //                    NSLog(@"cell.messageFrame.messageLabel.text is:  %@",cell.messageFrame.messageLabel.text);
                    
                    
                    if (message.code == MessageCodeGroupText) {
                        //        MessageContentType mCType= [message messageContentType];
                        MessageContentType mCType= message.contentType;
                        if (mCType == MessageContentVoice) {
                            
                            cell.didTouch = @selector(onSelect:);
                            cell.index = indexPath.row;
                        }
                        else if (mCType==MessageContentRedPacket){
                            
                            cell.didTouch = @selector(onSelect:);
                            cell.index = indexPath.row;
                        }
                    }
                    
                });
            }
        });
    }
    else{
        cell = [[GroupMessageCell alloc]init];
        //Update Interface
        // 设置数据
        cell.messageFrame = _allGroupMessagesFrame[indexPath.row];
        
        //    GroupMessage *message = [_chatToGroup.groupMessage objectAtIndex:indexPath.row];
        
        GroupMessage *message =cell.messageFrame.message;
        NSLog(@" %u %@",indexPath.row,message.content);
        //    [cell.iconView setImageWithURL:[NSURL URLWithString:cell.messageFrame.message.icon] placeholderImage:[UIImage imageNamed:@"defult_head.png"]];
        cell.delegate = self;
        cell.didTouchIcon=@selector(onSelectIcon:);
        cell.index=indexPath.row;
        
        if (message.code == MessageCodeGroupText) {
            //        MessageContentType mCType= [message messageContentType];
            MessageContentType mCType= message.contentType;
            if (mCType == MessageContentVoice) {
                
                cell.didTouch = @selector(onSelect:);
                cell.index = indexPath.row;
            }
            else if (mCType==MessageContentRedPacket){
                
                cell.didTouch = @selector(onSelect:);
                cell.index = indexPath.row;
            }
        }
        
        NSLog(@"%u",indexPath.row);
    }
    
    //    GroupMessageCell *cell = [[GroupMessageCell alloc]init];
    
    // 设置数据
    return cell;
}
-(void)prepareForReuse{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [_allGroupMessagesFrame[indexPath.row] cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    NSLog(@"reload");
    offsetIndex+=10;
    SGroupMessageDB *sgmessagedb=[[SGroupMessageDB alloc]init];
    NSMutableArray *tmpGroupMessageArray = [sgmessagedb selectGroupMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId offsetIndex:offsetIndex];
    if (tmpGroupMessageArray.count==0) {
        offsetIndex-=10;
    }
    
    NSLog(@"tmpGroupMessageArray is %@",tmpGroupMessageArray);
    for (GroupMessageFrame *tmpmFrame in [self createAllGroupMessagesFrameWithGroupMessage:tmpGroupMessageArray]) {
        
        [_allGroupMessagesFrame  insertObject:tmpmFrame atIndex:0];
    }
    
    NSLog(@"%@",_allGroupMessagesFrame);
    
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [self reloadTableViewDataSource];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.g_tableView];
    [self performSelectorOnMainThread:@selector(TableViewReloadDataWithoutScrollToBottom) withObject:nil waitUntilDone:NO];
    //    [self TableViewReloadDataWithoutScrollToBottom];
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}
@end
