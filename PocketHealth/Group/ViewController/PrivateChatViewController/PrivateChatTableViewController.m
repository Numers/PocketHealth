//
//  PrivateChatTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PrivateChatTableViewController.h"
#import "MessageCell.h"
#import "MessageFrame.h"

#import "SOneForOneMessageDB.h"
#import "SFirendDB.h"
#import "VoiceConverter.h"
#import "ChatCacheFileUtil.h"
#import "VoicePlayDevice.h"
#import "Organization.h"

//界面
#import "EGORefreshTableHeaderView.h"
#import "CalculateViewFrame.h"
#import "GlobalVar.h"
//子界面
#import "HospitalDetailInGroupTableViewController.h"
#import "PHAddDetailMemberFkViewController.h"

#import "PHOrganizationDetailsViewController.h"
#import "CommonUtil.h"

#import "UINavigationController+PHNavigationController.h"
#import "SJAvatarBrowser.h"



#define CONNECT_TIMEOUT 15.0
#define WRITE_TIMEOUT 10.0


@interface PrivateChatTableViewController ()<UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray  *_allMessagesFrame;
    
    //下拉刷新 add by yangfan
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    int offsetIndex;
    
    BOOL isPriLoadingChatImage;
}
@end

@implementation PrivateChatTableViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithMember:(Member *)member WithHostMember:(Member *)host;
{
    self = [super init];
    if (self) {
        _chatToMember = member;
        _hostMember = host;
        _isCurrentPresentView = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //右上角按钮 创建
    [self createChatRightBtn];

    // Do any additional setup after loading the view.
   
    //[self.navigationController.navigationBar setTranslucent:YES];
    CGFloat inputViewHeight;
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, frame.size.height-inputViewHeight);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];

    
    _allMessagesFrame = [[NSMutableArray alloc]init];
    if (_chatToMember.messageArr.count > 0) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        NSDate *previousTime = [NSDate dateWithTimeIntervalSince1970:0];
        int i = 0;
        for (OneForOneMessage *oneMessage in self.chatToMember.messageArr) {
            
            
            MessageFrame *messageFrame = [[MessageFrame alloc] init];
            int k = (i-1)>0?i-1:0;
            OneForOneMessage * beforeMsg =  self.chatToMember.messageArr[k] ;
            messageFrame.showTime = [CommonUtil isShowTimeLabelWithFirstTime:oneMessage.time SecondTime:beforeMsg.time];


            messageFrame.message = oneMessage;
            messageFrame.hostMemberId = _hostMember.memberId;
            //            previousTime = m.time;
            [_allMessagesFrame addObject:messageFrame];
            
            i++;
        }
        
    }


    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setOtherViewNavigation];
    
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_default.jpg"]];
    
    //设置标题 顺便更新
    [self updateChatMemberInfo];
    
    
    
    [self notificationSetting];
//    if (self.chatToMember.messageArr.count > 0) {
//        [self TableViewReloadData];
//    }

    _isCurrentPresentView = YES;
//    if (_chatToMember.messageArr.count > 0) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        NSDate *previousTime = [NSDate dateWithTimeIntervalSince1970:0];
//        for (OneForOneMessage *m in self.chatToMember.messageArr) {
//            MessageFrame *messageFrame = [[MessageFrame alloc] init];
//            //            NSDate *messageDate = [formatter dateFromString:m.time];
//            //            NSTimeInterval i = [messageDate timeIntervalSinceDate:previousTime];
//            NSTimeInterval i = m.time - previousTime.timeIntervalSinceNow;
//            messageFrame.showTime = i>SHOWMSGBETWEENTIME?true:false;
//            messageFrame.message = m;
//            messageFrame.hostMemberId = _hostMember.memberId;
//            //            previousTime = m.time;
//            [_allMessagesFrame addObject:messageFrame];
//        }
//        
//    }
//    if ([self.navigationController isMovingFromParentViewController]) {
    if (YES){
         SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        _hostMember.messageArr = [msgdb selectMessageWithUid:_chatToMember.memberId WithContactUid:_hostMember.memberId];
        

        offsetIndex=0;
//        if (self.isFromGroupChatView!=isFromGroupChatViewAdd) {
            //
            [_allMessagesFrame removeAllObjects];
            if (_hostMember.messageArr.count > 0) {
//                _chatToMember.messageArr

                
//                NSArray *smallArray = [largeArray subarrayWithRange:NSMakeRange(0, 10)];
                NSMutableArray *tmpPriviateMessageArray=[NSMutableArray arrayWithArray:_chatToMember.messageArr];
                _allMessagesFrame=[self createAllPrivateMessagesFrameWithOneMessage:tmpPriviateMessageArray];
            }
//            NSLog(@"%@",_allMessagesFrame);
            MessageFrame *allMsgFrame  = _allMessagesFrame.lastObject;
            self.messageSN = allMsgFrame.message.MsgSN++;
            
            NSLog(@"self.messageSN is : %ld",(long)self.messageSN);
            [self performSelectorOnMainThread:@selector(privateChatTableViewReloadData) withObject:nil waitUntilDone:NO];
//        }
        
        
        [self TableViewReloadData];
        
        
        
        
        
            [msgdb mergeNotReadMessageToReadMessageWithUid:_chatToMember.memberId WithContactUid:_hostMember.memberId];
#warning add mergeMessageStateIsSendingToFaildWithGid
//        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
//        [groupMessagedb mergeMessageStateIsSendingToFaildWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
//        [groupMessagedb mergeNotReadMessageToReadMessageWithGid:_chatToGroup.groupId WithContactUid:_hostMember.memberId];
        
        
        
        _hostMember.messageNotReadCount = _hostMember.messageNotReadCount-_chatToMember.messageNotReadCount;
        _chatToMember.messageNotReadCount = 0;
        
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    _isCurrentPresentView = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (!IOS_VERSION_8_OR_ABOVE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLLDRAGGING" object:nil];
    }
    // Checking if we are disappearing because of the back button
    
//    if ([self.navigationController isMovingToParentViewController])
//    {
//        // In case that back button is pressed, insert your code here
//        NSLog(@"aa");
//    }
//    if ([self isMovingToParentViewController])
//    {
//        // In case that back button is pressed, insert your code here
//        NSLog(@"bb");
//    }
//    if ([self isMovingFromParentViewController])
//    {
//        // In case that back button is pressed, insert your code here
//        NSLog(@"bb");
//    }
//    if ([self.navigationController isMovingFromParentViewController])
//    {
//        // In case that back button is pressed, insert your code here
//        NSLog(@"bb");
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)notificationSetting
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSendMessageToTableView:) name:@"TABLEVIEWRELOAD" object:nil];
}
#pragma mark - 更新用户信息
-(void)updateChatMemberInfo{
    SFirendDB * sfriendDb = [[SFirendDB alloc]init];
    Member * tmpMember =  [sfriendDb selectUserWithUid:_chatToMember.memberId WithBelongUid:_hostMember.memberId];
    _chatToMember.nickName = tmpMember.nickName;
    _chatToMember.headImage = tmpMember.headImage;
    self.navigationItem.title = _chatToMember.nickName;
}
-(void)initAudio{
    //    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
}

-(void)unInitAudio{
    //    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
#pragma mark - 创建右上角的按钮
-(void)createChatRightBtn{
    UIButton * privateChatViewRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    privateChatViewRightBtn.frame = CGRectMake(0, 0, 40, 40);
    privateChatViewRightBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"group_hos_info"]];
    [privateChatViewRightBtn addTarget:self action:@selector(privateChatViewRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * groupChatViewBarButton = [[UIBarButtonItem alloc]initWithCustomView:privateChatViewRightBtn];
    self.navigationItem.rightBarButtonItem = groupChatViewBarButton;
}
-(void)privateChatViewRightBtnClick{
    //推入
    [self pushChatToMember:_chatToMember];
    
    
}
-(void)pushChatToMember:(Member *)selectMember{
    if (selectMember.userType == MemberUserTypeAdmin) {
        NSLog(@"推入医院信息界面");
        Organization * org = [Organization allocWithMember:selectMember];
        PHOrganizationDetailsViewController * phOraganVC = [[PHOrganizationDetailsViewController alloc]initWithOrganization:org];
        phOraganVC.createFromType = OrganizationCreateTypeByDetailOne;
        [self.navigationController pushViewController:phOraganVC animated:YES];
        //        HospitalDetailInGroupTableViewController * hospitalDetailVC = [[HospitalDetailInGroupTableViewController alloc]init];
        //        hospitalDetailVC.member = _chatToMember;
        //        [self.navigationController pushViewController:hospitalDetailVC animated:YES];
    }else{
        NSLog(@"推入用户信息界面");
        PHAddDetailMemberFkViewController * phgpInfoVC  = [[PHAddDetailMemberFkViewController alloc]initWithMember:selectMember];
        [self.navigationController pushViewController:phgpInfoVC animated:YES];
    }
}
#pragma mark 给数据源增加内容
- (void)addMessage:(OneForOneMessage *)msg isSave:(BOOL)saveFlag{
    
    
    
    MessageFrame *mf = [[MessageFrame alloc] init];
    if (_chatToMember.messageArr.count > 0) {

        
        OneForOneMessage *previousMsg = [self.chatToMember.messageArr objectAtIndex:self.chatToMember.messageArr.count-1];

        mf.showTime = [CommonUtil isShowTimeLabelWithFirstTime:msg.time SecondTime:previousMsg.time];
    }else
    {
        mf.showTime = true;
    }
    mf.message = msg;
    mf.hostMemberId = _hostMember.memberId;
    
    
    [_chatToMember.messageArr addObject:msg];
    [_allMessagesFrame addObject:mf];
    
    SOneForOneMessageDB *msgdb       = [[SOneForOneMessageDB alloc] init];
//    if ([msg isValidate]) {
    if (saveFlag) {
            [msgdb saveMessage:msg WithUid:_chatToMember.memberId WithContactUid:self.hostMember.memberId];
    }else{
        [msgdb mergeMessage:msg WithUid:_chatToMember.memberId WithContactUid:self.hostMember.memberId];
    }
//    [msgdb mergeMessage:msg WithUid:_chatToMember.memberId WithContactUid:self.hostMember.memberId];
//    [msgdb saveMessage:msg WithUid:_chatToMember.memberId WithContactUid:self.hostMember.memberId];
        _chatToMember.isSession = 1;
        SFirendDB *frienddb     = [[SFirendDB alloc] init];
        [frienddb mergeWithUser:_chatToMember WithBelongUid:self.hostMember.memberId];
//    }
    //    [msgdb close];
    
    
    [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
    
    
    //当发送消息之后 刷新主聊天界面
    [[NSNotificationCenter defaultCenter]postNotificationName:@"REFRESHHOMECHATVIEWWITHCHATMEMBER" object:_chatToMember];
}
#pragma mark -  构造10条消息的数据源内容函数
-(NSMutableArray *)createAllPrivateMessagesFrameWithOneMessage:(NSMutableArray *)privateMessageArray{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableArray *tmpGroupMessageFrame=[[NSMutableArray alloc]init];
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSDate *previousTime = [NSDate date];
    int i = 0;
    for (OneForOneMessage *oneMessage in privateMessageArray) {
        //如果code是加群消息，就过滤 不在聊天消息中显示
        //        if (m.code==MessageCodeJoinGroup) {
        //            continue;
        //        }
        
        MessageFrame *messageFrame = [[MessageFrame alloc] init];
        int k = (i-1)>0?i-1:0;
        OneForOneMessage * beforeMsg =  privateMessageArray[k] ;
        messageFrame.showTime = [CommonUtil isShowTimeLabelWithFirstTime:oneMessage.time SecondTime:beforeMsg.time];

//        if (i<privateMessageArray.count) {
//            int k = (i-1)>0?i-1:0;
//            OneForOneMessage * beforeMsg =  privateMessageArray[k] ;
//            messageFrame.showTime = [CommonUtil isShowTimeLabelWithFirstTime:oneMessage.time SecondTime:beforeMsg.time];
//        }else{
//            messageFrame.showTime = false;
//        }
        
        //        NSDate *messageDate = [formatter dateFromString:m.time];
        //        NSTimeInterval i = [messageDate timeIntervalSinceDate:previousTime];
        
        messageFrame.message = oneMessage;
        //        previousTime = messageDate;
        [tmpGroupMessageFrame addObject:messageFrame];
        i++;
    }
    return tmpGroupMessageFrame;
}
-(void)addSendMessageToTableView:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    NSInteger retcode = [[dic valueForKey:@"retcode"] integerValue];
    NSInteger msgsn = [[dic valueForKey:@"msgsn"] integerValue];
    
    if (msgsn < self.chatToMember.messageArr.count) {
        OneForOneMessage *message = [self.chatToMember.messageArr objectAtIndex:msgsn];
        if (YES) {
            if (retcode == 0) {
                message.state = MessageSuccess;
            }else{
                message.state = MessageFailed;
            }
            
            SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
//            if ([message isValidate]) {
                [msgdb mergeMessage:message WithUid:self.chatToMember.memberId WithContactUid:self.hostMember.memberId];
//            }
            NSLog(@"%ld, %ld",(long)retcode,(long)msgsn);
            [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)TableViewReloadData
{
    [self.tableView reloadData];
    [self tableViewscrollToBottom];
}
-(void)TableViewReloadDataWithoutScrollToBottom{
    [self.tableView reloadData];
}
-(void)tableViewscrollToBottom{
    //滚动至当前行
    if (_allMessagesFrame.count>0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_allMessagesFrame.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}
#pragma mark - tableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MessageCell * cell = [[MessageCell alloc]init];
    
//    if (cell == nil) {
//        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // 设置数据
//        cell.messageFrame = _allMessagesFrame[indexPath.row];
//        
//        OneForOneMessage *message = [_chatToMember.messageArr objectAtIndex:indexPath.row];
//        if (message.code == MessageCodeText) {
//            if ([message messageContentType] == MessageContentVoice) {
//                cell.delegate = self;
//                cell.didTouch = @selector(onSelect:);
//                cell.index = indexPath.row;
//            }
//        }
//    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.messageFrame = _allMessagesFrame[indexPath.row];
                OneForOneMessage * message = cell.messageFrame.message;
//                OneForOneMessage *message = [_chatToMember.messageArr objectAtIndex:indexPath.row];
//                OneForOneMessage *message = [_allMessagesFrame objectAtIndex:indexPath.row];
                cell.delegate = self;
                cell.didTouchIcon=@selector(onSelectIconPrivate:);
                cell.index=indexPath.row;
                if (message.code == MessageCodeText) {
                    if ([message messageContentType] == MessageContentVoice||[message messageContentType] == MessageContentImage) {
                        cell.delegate = self;
                        cell.didTouch = @selector(onSelect:);
                        cell.index = indexPath.row;
                    }
                }

                                [cell setNeedsDisplay];
                //
                
            });
        }
    });
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [_allMessagesFrame[indexPath.row] cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - 代理方法

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLLDRAGGING" object:nil];
}

-(void)onSelect:(UIView*)sender{
    NSInteger n = sender.tag;
    OneForOneMessage *msg=[self.chatToMember.messageArr objectAtIndex:n];
    
    switch ([msg messageContentType]) {
        case MessageContentVoice:{
            [self recordPlay:msg];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:n inSection:0];
             [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case MessageContentImage:{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLLDRAGGING" object:nil];
            if (!isPriLoadingChatImage) {
                isPriLoadingChatImage = YES;
                [self showImage:[msg fullServerImagePath]];
            }
            
        }
            break;

        default:
            break;
    }
    msg = nil;
}
-(void)onSelectIconPrivate:(UIView *)sender{
    int n = sender.tag;
    OneForOneMessage *msg=[_chatToMember.messageArr objectAtIndex:n];
    
    Member *selectMember =msg.type!=MessageTypeMe?_chatToMember:_hostMember;
    
    
    [self pushChatToMember:selectMember];

}
-(void)showImage:(NSString *)imageUrl;
{
    
    //    NSString *fullImagePath = [_messageFrame.message fullServerImagePath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                UIImageView *imageView = nil;
                if (imageData != nil) {
                    imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
                    
                }else
                {
                    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DefaultChatImageNotLoading]];
                }
                if (imageView.image) {
                    [SJAvatarBrowser showImage:imageView completion:^(BOOL imgFinishFlag) {
                    }];
                }
                isPriLoadingChatImage = NO;
            });
        }
    });
}
#pragma mark -  点击的代理方法
-(void)onSelectIcon:(UIView *)sender{
    int n = sender.tag;
    MessageFrame *messageFrame = _allMessagesFrame[n];
    OneForOneMessage * message = messageFrame.message;
    if (message.type == MessageTypeMe) {

    }
}

-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

-(void)recordPlay:(OneForOneMessage *)msg{
    NSArray *array = [msg.content componentsSeparatedByString:@"|"];
    if ((array != nil) && (array.count == 2)) {
        NSString *amrFullPath = [[NSString alloc]init];
        if (msg.type == MessageTypeMe) {
            amrFullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[array objectAtIndex:0]]];
        }
        else if(msg.type == MessageTypeOther){
//            NSRange range = [[array objectAtIndex:0] rangeOfString:@"/"];
//            NSString *fileName = [[array objectAtIndex:0] substringFromIndex:range.location+range.length];
//            amrFullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:fileName];
            NSString *myStr = [array objectAtIndex:0];
            NSRange range = [myStr rangeOfString:@"/"];
            while (range.length == 1) {
                myStr = [myStr substringFromIndex:range.location+range.length];
                range = [myStr rangeOfString:@"/"];
            }
           
//            NSString *fileName = [[array objectAtIndex:0] substringFromIndex:range.location+range.length];
            amrFullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:myStr];
            
            NSFileManager *fileManager=[NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:amrFullPath]) {
                
                NSString *fileUrl = [NSString stringWithFormat:@"%@%@",ServerBaseURL,[array objectAtIndex:0]];
                NSData *amrData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]];
                [amrData writeToFile:amrFullPath atomically:YES];
                
                SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
                msg.readState = MessageRead;
                [msgdb mergeMessage:msg WithUid:self.chatToMember.memberId WithContactUid:self.hostMember.memberId];

            }
        }
        //[msg.fileData writeToFile:fullPath atomically:YES];
        NSString *wavPath = [VoiceConverter amrToWav:amrFullPath];
        //        NSError *error=nil;
        //        [audioPlayer stop];
        audioPlayer = [VoicePlayDevice shareInstanceWithFilePath:wavPath];
        
//                [self initPlayer];
//                audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:wavPath] error:&error];
        
        [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:wavPath];
        //        if (error) {
        //            error=nil;
        //        }
        [audioPlayer setVolume:1];
        [audioPlayer prepareToPlay];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
        
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
}
-(void)privateChatTableViewReloadData
{
    [self.tableView reloadData];
    [self tableViewscrollToBottom];
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
    SOneForOneMessageDB *sPmessagedb=[[SOneForOneMessageDB alloc]init];
    NSMutableArray *tmpPrivateMessageArray = [sPmessagedb selectPrivateMessageWithMemberID:_chatToMember.memberId WithContactUid:_hostMember.memberId offsetIndex:offsetIndex];
    if (tmpPrivateMessageArray.count==0) {
        offsetIndex-=10;
    }
    
    NSLog(@"tmpPrivateMessageArray is %@",tmpPrivateMessageArray);
    for (MessageFrame *tmpmFrame in [self createAllPrivateMessagesFrameWithOneMessage:tmpPrivateMessageArray]) {
        
        [_allMessagesFrame  insertObject:tmpmFrame atIndex:0];
    }
    
//    NSLog(@"%@",_allMessagesFrame);
    
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [self reloadTableViewDataSource];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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
