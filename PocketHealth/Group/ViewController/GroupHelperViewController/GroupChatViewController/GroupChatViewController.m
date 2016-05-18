//
//  GroupChatViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupChatViewController.h"

//数据
#import "ClientHelper.h"
#import "SGroupDB.h"
#import "SGroupMemberDB.h"
#import "SGroupMessageDB.h"
#import "ChatCacheFileUtil.h"
#import "CalculateViewFrame.h"
//界面

#import "GroupMessage.h"
#import "GroupMember.h"
#import "ZBMessageManagerFaceView.h"
#import "VoiceConverter.h"
#import "ChatRecorderView.h"
#import "UIView+Animation.h"

#define maxRecordTime 60.0f

@interface GroupChatViewController ()<AVAudioRecorderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    double g_animationDuration;
    CGRect g_keyboardRect;
    
    UIButton *joinGroupBtn;
    
    GroupMember * groupMemberMyself;
    
    //    __block  groupState groupstate;
    int retNormal;
}
@end

@implementation GroupChatViewController

#pragma mark -  界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    //获取groupMemberMyself
    for (GroupMember *m in self.chatToGroup.groupMember) {
        if (m.memberId==self.hostMember.memberId) {
            groupMemberMyself=m;
            break;
        }
    }
    //初始化下方输入框
    [self initilzer];
    
//    [self performSelectorInBackground:@selector(requestGroupListInBackGround) withObject:nil];

//    SGroupDB *sgroupDB=[[SGroupDB alloc]init];
//    if (![sgroupDB isExistGroupWithGid: self.chatToGroup.groupId WithBelongUid:self.hostMember.memberId]) {
//        
//        [self performSelectorOnMainThread:@selector(loadMainTimeRetStop:) withObject:nil waitUntilDone:YES];
////        [MMProgressHUD showWithTitle:@"获取消息中.." status:nil];
//        
//        //        //获取短连接
//        //        groupState groupstatus=[self serachMyGroupRecordWithUid:self.hostMember.memberId Gid:self.chatToGroup.groupId];
//        //        //添加一个view 挡住toolview 哈哈哈哈
//        //        [self createJoinGroupBtnWithStatus:groupstatus];
//        
//        [self requestJoinGroupStatus:^(groupState gState) {
//            NSLog(@"%u",gState);
//            [self createJoinGroupBtnWithStatus:gState];
//        }];
//        
//        self.isFromGroupChatView=isFromGroupChatViewAdd;
//        
//        [self performSelectorInBackground:@selector(requestSimpleData) withObject:nil];
//        
//    }else{
//        //后台更新群列表用户
//        [self performSelectorInBackground:@selector(requestGroupListInBackGround) withObject:nil];
////        [self showGroupInfoBtn];
//    }
    
    g_animationDuration = 0.25;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupScrollDragging:) name:@"GROUPSCROLLDRAGGING" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardChange:)
                                                name:UIKeyboardDidChangeFrameNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    //刷新用户列表 可修改
    [self performSelectorInBackground:@selector(requestGroupListInBackGround) withObject:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//输入框初始化
- (void)initilzer{
    [self shareMessageToolView];
    [self shareFaceView];
    [self shareShareMeun];
}
-(NSString *)messageInputViewTextByDelete:(NSString *)text
{
    NSString *name = nil;
    if ((text != nil) && (text.length > 0)) {
        NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
        NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
        
        NSString *o_text = [CustomMethod transformString:text emojiDic:expressionDic];
        o_text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",o_text];
        
        MarkUpParser *wk_markupParser = [[MarkUpParser alloc] init];
        NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkUp:o_text];
        NSString *aString = [attString string];
        NSString *temp = [aString substringFromIndex:aString.length-2];
        if ([temp isEqualToString:@"－ "]){
            NSRange range = [text rangeOfString:@"[" options:NSBackwardsSearch];
            if (range.length > 0) {
                name = [text substringToIndex:range.location];
            }
            
        }else{
            name = [text substringToIndex:text.length-1];
        }
        
    }
    return name;
}
-(void)shareMessageToolView
{
    if (!self.g_messageToolView) {
        CGFloat inputViewHeight;
        
        if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
            inputViewHeight = 45.0f;
        }
        else{
            inputViewHeight = 40.0f;
        }
        
        NSLog(@"%lf",self.view.frame.size.height);
        self.g_messageToolView = [[ZBMessageInputView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                     self.view.frame.size.height - inputViewHeight,self.view.frame.size.width,inputViewHeight)];
        self.g_messageToolView.delegate = self;
        [self.view addSubview:self.g_messageToolView];
        self.g_previousTextViewContentHeight=35.5f;
    }
}
- (void)shareFaceView{
    
    if (!self.g_faceView)
    {
        NSLog(@"%lf",CGRectGetHeight(self.view.frame));
        self.g_faceView = [[ZBMessageManagerFaceView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                    CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196)];
        self.g_faceView.delegate = self;
        [self.view addSubview:self.g_faceView];
        
    }
}

- (void)shareShareMeun
{
    if (!self.g_shareMenuView)
    {
        NSLog(@"%lf,%lf",CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame));
        self.g_shareMenuView = [[ZBMessageShareMenuView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                       CGRectGetHeight(self.view.frame),
                                                                                       CGRectGetWidth(self.view.frame), 196)];
        [self.view addSubview:self.g_shareMenuView];
        self.g_shareMenuView.delegate = self;
        
        //判断发红包权限
//        SGroupMemberDB *sgroupMdb=[[SGroupMemberDB alloc]init];
//        GroupMember *tempGM= [sgroupMdb selectGroupMemberWithUid:self.hostMember.memberId WithGid:self.chatToGroup.groupId];
//        if (tempGM!=nil) {
//            if (tempGM.groupMemberType==groupOwner||tempGM.groupMemberType==groupAdmin) {
//                self.g_shareMenuView.showRedPacket=YES;
//            }else{
//                self.g_shareMenuView.showRedPacket=NO;
//            }
//        }else{
//            self.g_shareMenuView.showRedPacket=NO;
//        }
        
        
        [self.g_shareMenuView ImageSetting];
        [self.g_shareMenuView reloadData];
    }
}
-(void)recordStart
{
    if(g_recording)
        return;
    
    [g_audioPlayer pause];
    g_recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDate *now = [NSDate date];
    
    
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy_MM_dd"];
    NSString *temp = [NSString stringWithFormat:@"%lld%lld",self.hostMember.memberId,(long long int)[now timeIntervalSince1970]];
    NSString *fileName = [temp stringByAppendingString:@".wav"];
    g_amrFileName = [temp stringByAppendingString:@".amr"];
    NSString *fullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    g_pathURL = url;
    
    NSError *error;
    g_audioRecorder = [[AVAudioRecorder alloc] initWithURL:g_pathURL settings:settings error:&error];
    g_audioRecorder.delegate = self;
    
    [g_audioRecorder prepareToRecord];
    [g_audioRecorder setMeteringEnabled:YES];
    [g_audioRecorder peakPowerForChannel:0];
    [g_audioRecorder record];
    
    [self initRecordView];
    [UIView showView:g_recorderView
         animateType:AnimateTypeOfPopping
           finalRect:kRecorderViewRect
          completion:^(BOOL finish){
              if (finish){
                  [self startRecorderViewTimer];
              }
          }];
    //设置遮罩背景不可触摸
    [UIView setTopMaskViewCanTouch:NO];
}

-(void)recordStop
{
    if(!g_recording)
        return;
    
    g_timeLen = g_audioRecorder.currentTime;
    [UIView hideViewByCompletion:^(BOOL finish){
        [self stopRecorderViewTimer];
        g_recording = NO;
        [g_audioRecorder stop];
        
    }];
    if ([g_audioRecorder isRecording]) {
        [g_audioRecorder stop];
        g_recording = NO;
    }
    if (g_timeLen < 1) {
//        [MMProgressHUD showWithStatus:nil];
//        [MMProgressHUD dismissWithError:@"录音过短" afterDelay:2.0f];
        [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:g_pathURL.path];
        return;
    }
    
    
    
    NSString *amrPath = [VoiceConverter wavToAmr:g_pathURL.path];
    GroupMessage *message = [[GroupMessage alloc] init];
    message.belongGroupId = self.chatToGroup.groupId;
    message.memberId = self.hostMember.memberId;
    message.icon = self.hostMember.headImage;
    message.code = MessageCodeGroupText;
    message.type = MessageTypeMe;
    message.nickName=self.hostMember.nickName;
    message.content = [NSString stringWithFormat:@"%@|%d",g_amrFileName,[[NSNumber numberWithDouble:g_timeLen] intValue]];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *now = [NSDate date];
    message.time = [[NSDate date]timeIntervalSince1970];
    message.state = MessageIsSend;
    
    //表示身份
    if (groupMemberMyself.groupMemberType==groupOwner) {
        message.messageIdentity=MessageIdentityOwner;
    }
    else if (groupMemberMyself.groupMemberType==groupAdmin){
        message.messageIdentity=MessageIdentityAdmin;
    }
    else{
        message.messageIdentity=MessageIdentityUser;
    }
    
    message.readState = MessageRead;
    message.contentType=MessageContentVoice;
    self.chatToGroup.sessionDate = [now timeIntervalSince1970];
    [self addMessage:message];
    
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:g_pathURL.path];
    //[[ChatCacheFileUtil sharedInstance] deleteWithContentPath:amrPath];
    
    NSLog(@"音频文件路径:%@\n%@",g_pathURL.path,amrPath);
    //    if (_timeLen<1) {
    //        [g_App showAlert:@"录的时间过短"];
    //        return;
    //    }
    //[self sendVoice:recordData];
    
    [self uploadVoiceFile:message WithFileName:g_amrFileName];
}

-(void)recordCancel
{
    if(!g_recording)
        return;
    [g_audioRecorder stop];
    g_recording = NO;
    
    [UIView hideViewByCompletion:^(BOOL finish){
        [self stopRecorderViewTimer];
    }];
    [g_recorderView prepareToDelete:YES];
    
}
#pragma mark - 启动定时器
- (void)startRecorderViewTimer{
    g_recorderViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

#pragma mark - 停止定时器
- (void)stopRecorderViewTimer{
    if (g_recorderViewTimer && g_recorderViewTimer.isValid){
        [g_recorderViewTimer invalidate];
        g_recorderViewTimer = nil;
    }
    //[recorderView prepareToDelete:YES];
}
#pragma mark - 更新音频峰值
- (void)updateMeters{
    if (g_audioRecorder.isRecording){
        //更新峰值
        [g_audioRecorder updateMeters];
        [g_recorderView updateMetersByAvgPower:[g_audioRecorder averagePowerForChannel:0]];
        
        g_timeLen = g_audioRecorder.currentTime;
        if(g_timeLen>=maxRecordTime)
            [self recordStop];
    }
}
-(void)uploadVoiceFile:(GroupMessage *)message WithFileName:(NSString *)name
{
    //上传shengying
//    NSString *amrFullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:g_amrFileName];
//    NSData *recordData = [NSData dataWithContentsOfFile:amrFullPath];
//    
//    //    [self performSelectorOnMainThread:@selector(loadMainTimeRetStopNormal:) withObject:message waitUntilDone:NO];
//    
//    if (recordData != nil) {
//        NSString *urlStr = [NSString stringWithFormat:@"%@",HTTP_UPSOUND_URL_NEW];
//        __weak ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
//        [request setData:recordData withFileName:name andContentType:@"amr" forKey:@"file"];
//        [request setTimeOutSeconds:10];
//        
//        [request setCompletionBlock:^{
//            NSLog(@"%@",request.responseString);
//            NSDictionary *rootDic=[request.responseString objectFromJSONString];
//            int code = [[rootDic objectForKey:@"Code"] intValue];
//            if (code == 1) {
//                NSLog(@"上传成功");
//                @try {
//                    NSString *voiceAbsolutePath = [[[rootDic objectForKey:@"Data"]objectForKey:@"Result"]objectForKey:@"FileName"];
//                    if (voiceAbsolutePath != nil) {
//                        NSRange range = [voiceAbsolutePath rangeOfString:@"/UpLoadFile/"];
//                        if (range.length > 0) {
//                            NSString *path = [voiceAbsolutePath substringFromIndex:range.location+range.length];
//                            NSString *serverPath = [path stringByAppendingString:[NSString stringWithFormat:@"|%d",[[NSNumber numberWithDouble:g_timeLen] intValue]]];
//                            NSString *sendContent = [NSString stringWithFormat:@"{\"txt\":\"%@\",\"ct\":%u}",serverPath,MessageContentVoice];
//                            
//                            //msgsn 做修改 by yangfan 2014-10-17 10:36:42
//                            //self.chatToGroup.groupMessage.count-1 修改为self.allGroupMessagesFrame.count-1
//                            retNormal=[ClientHelper sendGroupMessage:self.hostMember.memberId Token:[CommonUtil MyToken] Gid:self.chatToGroup.groupId Message:sendContent Msgsn:self.allGroupMessagesFrame.count-1];
//                            [self updateMessageStateWithRet:message ret:retNormal];
//                            //                        if (retNormal<0) {
//                            //                            message.state = MessageFailed;
//                            //                            [self updateGMessageStateWithMessage:message];
//                            //                            [self performSelectorInBackground:@selector(reConnectChatHost) withObject:nil];
//                            ////                            [ClientHelper connectToHost];
//                            //                        }
//                            //                        else{
//                            //                            message.state = MessageSuccess;
//                            //                            [self updateGMessageStateWithMessage:message];
//                            //                        }
//                            //                        NSLog(@"message.state %u",message.state);
//                        }
//                    }
//                    
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"数据错误");
//                }
//                
//            }else
//            {
//                NSLog(@"上传失败");
//                [self updateFaildMessageState:message];
//            }
//            
//        }];
//        [request setFailedBlock:^{
//            NSLog(@"voice updata 网络错误");
//            [self updateFaildMessageState:message];
//        }];
//        [request startAsynchronous];
//        
//    }
}

-(void)uploadImageFile:(UIImage *)image WithSendMessage:(GroupMessage *)message WithFileName:(NSString *)name
{
    //上传图片
//    NSData *imageData = UIImageJPEGRepresentation(image,0.01);
//    NSString *urlStr = [NSString stringWithFormat:@"%@",HTTP_UPSOUND_URL_NEW];
//    __weak ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    //    [self performSelectorOnMainThread:@selector(loadMainTimeRetStopNormal:) withObject:message waitUntilDone:NO];
//    
//    [request setData:imageData withFileName:name andContentType:@"jpeg" forKey:@"file"];
//    [request setTimeOutSeconds:10];
//    
//    [request setCompletionBlock:^{
//        NSLog(@"%@",request.responseString);
//        NSDictionary *rootDic=[request.responseString objectFromJSONString];
//        int code = [[rootDic objectForKey:@"Code"] intValue];
//        if (code == 1) {
//            @try {
//                NSLog(@"上传成功");
//                NSString *voiceAbsolutePath = [[[rootDic objectForKey:@"Data"]objectForKey:@"Result"]objectForKey:@"FileName"];
//                if (voiceAbsolutePath != nil) {
//                    NSRange range = [voiceAbsolutePath rangeOfString:@"/UpLoadFile/"];
//                    if (range.length > 0) {
//                        NSString *path = [voiceAbsolutePath substringFromIndex:range.location+range.length];
//                        NSString *serverPath = [path stringByAppendingString:@"|IMAGE"];
//                        message.content = serverPath;
//                        
//                        //表示身份
//                        if (groupMemberMyself.type==groupOwner) {
//                            message.messageIdentity=MessageIdentityOwner;
//                        }
//                        else if (groupMemberMyself.type==groupAdmin){
//                            message.messageIdentity=MessageIdentityAdmin;
//                        }
//                        else{
//                            message.messageIdentity=MessageIdentityUser;
//                        }
//                        
//                        message.contentType=MessageContentImage;
//                        [self addMessage:message];
//                        NSString *sendContent = [NSString stringWithFormat:@"{\"txt\":\"%@\",\"ct\":%u}",serverPath,MessageContentImage];
//                        
//                        
//                        retNormal =[ClientHelper sendGroupMessage:self.hostMember.memberId Token:[CommonUtil MyToken] Gid:self.chatToGroup.groupId Message:sendContent Msgsn:self.allGroupMessagesFrame.count-1];
//                        [self updateMessageStateWithRet:message ret:retNormal];
//                        //                    if (retNormal<0) {
//                        //                        message.state = MessageFailed;
//                        //                        [self updateGMessageStateWithMessage:message];
//                        //                        [self performSelectorInBackground:@selector(reConnectChatHost) withObject:nil];
//                        ////                        [ClientHelper connectToHost];
//                        //                    }
//                        //                    else{
//                        //                        message.state = MessageSuccess;
//                        //                        [self updateGMessageStateWithMessage:message];
//                        //                    }
//                    }
//                }
//            }
//            @catch (NSException *exception) {
//                NSLog(@"网络错误 ");
//            }
//            
//            
//        }else
//        {
//            
//            NSLog(@"上传失败");
//            [self updateFaildMessageState:message];
//            //            message.state = MessageFailed;
//            //            [self updateGMessageStateWithMessage:message];
//            //            [ClientHelper connectToHost];
//            //            NSLog(@"message.state %u",message.state);
//        }
//        
//    }];
//    [request setFailedBlock:^{
//        NSLog(@"img updata 网络错误");
//        [self updateFaildMessageState:message];
//        //        message.state = MessageFailed;
//        //        [self updateGMessageStateWithMessage:message];
//        //        [ClientHelper connectToHost];
//        //        NSLog(@"message.state %u",message.state);
//    }];
//    [request startAsynchronous];
    
}

#pragma mark - 数据类
-(void)requestGroupListInBackGround{
    //更新一下群成员
    //  后台执行：
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //1.更新成员变量
//    NSMutableArray *tmpMemberList= [XJDChangeUserInfoHelp requestGroupMemberListWithGid:self.chatToGroup.groupId];
//    self.chatToGroup.groupMember=tmpMemberList;
    
    //        NSLog(@"self.chatToGroup.groupMember: %@",self.chatToGroup.groupMember);
    //2.更新数据库
    SGroupMemberDB *groupMemberdb = [[SGroupMemberDB alloc] init];
    for(GroupMember *gm in self.chatToGroup.groupMember){
        if(![groupMemberdb isExistGroupMemberWithUid:gm.memberId WithGid:gm.groupId]){
            [groupMemberdb saveGroupMember:gm];
        }else{
            [groupMemberdb mergeGroupMember:gm];
        }
    }
    //    });
}

-(void)groupScrollDragging:(NSNotification *)notification
{
    [self.view endEditing:YES];
    //    [self messageViewAnimationWithMessageRect:CGRectZero
    //                     withMessageInputViewRect:self.g_messageToolView.frame
    //                                  andDuration:g_animationDuration
    //                                     andState:ZBMessageViewStateShowNone];
    
    [self messageViewAnimationWithMessageRect_scrollerDrag:CGRectZero                    withMessageInputViewRect:self.g_messageToolView.frame
                                               andDuration:g_animationDuration
                                                  andState:ZBMessageViewStateShowNone];
}
#pragma mark -keyboard
- (void)keyboardWillHide:(NSNotification *)notification{
    
    g_keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    g_animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
}

- (void)keyboardWillShow:(NSNotification *)notification{
    g_keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    g_animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)keyboardChange:(NSNotification *)notification{
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [self messageViewAnimationWithMessageRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

#pragma mark - messageView animation
- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    
    [UIView animateWithDuration:duration animations:^{
        self.g_messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(self.view.frame),CGRectGetHeight(inputViewRect));
        
        CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
        
        self.g_tableView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.g_tableView.frame), CGRectGetHeight(frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect));
        
        [self g_tableViewSrollToBotton];
        
        switch (state) {
            case ZBMessageViewStateShowFace:
            {
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowNone:
            {
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_faceView.frame));
                
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowShare:
            {
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_faceView.frame));
            }
                break;
                
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}
- (void)messageViewAnimationWithMessageRect_scrollerDrag:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    
    [UIView animateWithDuration:duration animations:^{
        self.g_messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(self.view.frame),CGRectGetHeight(inputViewRect));
        
        CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
        self.g_tableView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.g_tableView.frame), CGRectGetHeight(frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect));
        
        switch (state) {
            case ZBMessageViewStateShowFace:
            {
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowNone:
            {
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_faceView.frame));
                
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_shareMenuView.frame));
            }
                break;
            case ZBMessageViewStateShowShare:
            {
                self.g_shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
                self.g_faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.g_faceView.frame));
            }
                break;
                
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}
#pragma end





-(void)imageUploadInitWithImage:(UIImage *)image
{
    NSDate *now = [NSDate date];
    NSString *temp = [NSString stringWithFormat:@"%lld%lld",self.hostMember.memberId,(long long)[now timeIntervalSince1970]];
    NSString *fileName = [temp stringByAppendingString:@".jpeg"];
    
    GroupMessage *message = [[GroupMessage alloc] init];
    message.belongGroupId = self.chatToGroup.groupId;
    message.memberId = self.hostMember.memberId;
    message.icon = self.hostMember.headImage;
    message.code = MessageCodeGroupText;
    message.type = MessageTypeMe;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    message.time = [[NSDate date]timeIntervalSince1970];
    message.state = MessageIsSend;
    message.readState = MessageRead;
    //    UIImage *uploadImage = [CommonUtil croppedImage:image]; //tagyf0925
    UIImage *uploadImage=image;
    self.chatToGroup.sessionDate = [now timeIntervalSince1970];
    [self uploadImageFile:uploadImage WithSendMessage:message WithFileName:fileName];
}

#pragma mark - 初始化录音界面
- (void)initRecordView{
    if (g_recorderView == nil)
        g_recorderView = (ChatRecorderView*)[[[NSBundle mainBundle]loadNibNamed:@"ChatRecorderView" owner:self options:nil] lastObject];
    //还原界面显示
    [g_recorderView restoreDisplay];
}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音停止");
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"录音开始");
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    NSLog(@"录音中断");
}

#pragma mark - ZBMessageInputView Delegate
- (void)didSelectedMultipleMediaAction:(BOOL)changed{
    
    if (changed)
    {
        [self messageViewAnimationWithMessageRect:self.g_shareMenuView.frame
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowShare];
    }
    else{
        [self messageViewAnimationWithMessageRect:g_keyboardRect
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
    
}


- (void)didSendFaceAction:(BOOL)sendFace{
    if (sendFace) {
        [self messageViewAnimationWithMessageRect:self.g_faceView.frame
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowFace];
    }
    else{
        [self messageViewAnimationWithMessageRect:g_keyboardRect
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

- (void)didChangeSendVoiceAction:(BOOL)changed{
    if (changed){
        [self messageViewAnimationWithMessageRect:g_keyboardRect
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

/*
 * 点击输入框代理方法
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView{
    
}

- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    [self messageViewAnimationWithMessageRect:g_keyboardRect
                     withMessageInputViewRect:self.g_messageToolView.frame
                                  andDuration:g_animationDuration
                                     andState:ZBMessageViewStateShowNone];
    
    if (!self.g_previousTextViewContentHeight)
    {
        self.g_previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}

- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [ZBMessageInputView maxHeight];
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < self.g_previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.g_previousTextViewContentHeight;
    
    if(!isShrinking && self.g_previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.g_previousTextViewContentHeight);
    }
    
    if(changeInHeight != 0.0f) {
        
        [UIView animateWithDuration:0.01f
                         animations:^{
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.g_messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.g_messageToolView.frame;
                             self.g_messageToolView.frame = CGRectMake(0.0f,
                                                                       inputViewFrame.origin.y - changeInHeight,
                                                                       inputViewFrame.size.width,
                                                                       inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [self.g_messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             [self gtableViewFrameChangeWithMessageInputViewRect:self.g_messageToolView.frame andDuration:0.01f];
                         }];
        
        self.g_previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}
/*
 * 发送信息
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView{
    NSString *content = messageInputTextView.text;
    if ([content isEqualToString:@""]) {
        return;
    }
    messageInputTextView.text = @"";
    [self inputTextViewDidChange:messageInputTextView];
    
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    NSDate *date = [NSDate date];
//    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss"; // @"yyyy-MM-dd HH:mm:ss"
//    NSString *time = [fmt stringFromDate:date];
    GroupMessage *message = [[GroupMessage alloc] init];
    message.belongGroupId = self.chatToGroup.groupId;
    message.memberId=self.hostMember.memberId;
    message.nickName=self.hostMember.nickName;
    message.content = content;
    message.time = [[NSDate date] timeIntervalSince1970];
    message.icon = self.hostMember.headImage;
    message.type = MessageTypeMe;
    message.state = MessageIsSend;
    message.code = MessageCodeGroupText;
    message.readState = MessageRead;
    message.contentType=MessageContentText;
    
    message.MsgSN = ++self.messageSN;
    
    
    //表示身份
    if (groupMemberMyself.groupMemberType==groupOwner) {
        message.messageIdentity=MessageIdentityOwner;
    }
    else if (groupMemberMyself.groupMemberType==groupAdmin){
        message.messageIdentity=MessageIdentityAdmin;
    }
    else{
        message.messageIdentity=MessageIdentityUser;
    }
    
    
    self.chatToGroup.sessionDate = [[NSDate date] timeIntervalSince1970];
    [self addMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MOVEMEMBERTOTOP" object:self.chatToGroup];
    
    NSString *msg = [NSString stringWithFormat:@"{\"txt\":\"%@\",\"ct\":%u}",content,MessageContentText];
    
    
    
    
    //    [self performSelectorOnMainThread:@selector(loadMainTimeRetStopNormal:) withObject:message waitUntilDone:NO];
    
    NSLog(@"msgsn:%u    _allGroupMessagesFrame.count : %u ",self.chatToGroup.groupMessage.count-1,self.allGroupMessagesFrame.count);
    retNormal=[ClientHelper sendGroupMessage:self.hostMember.memberId Token:[CommonUtil MyToken] Gid:self.chatToGroup.groupId Message:msg Msgsn:message.MsgSN];
    [self updateMessageStateWithRet:message ret:retNormal];
        if (retNormal<0) {
            message.state = MessageFailed;
            //修改数据库中message
            [self updateGMessageStateWithMessage:message];
            //修改界面中message
            [self performSelectorInBackground:@selector(reConnectChatHost) withObject:nil];
        }
        else{
            message.state = MessageSuccess;
            NSLog(@"message.state %u",message.state);
            [self updateGMessageStateWithMessage:message];
        }
    
    
    NSLog(@"send");
    
}


-(void)loadMainTimeRetStopNormal:(GroupMessage *)message{
    //    NSLog(@"%@",message);
    NSTimer *timerStop=[NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(stopSendNewMessage:) userInfo:message repeats:NO];
    NSRunLoop *runloop=[NSRunLoop currentRunLoop];
    [runloop addTimer:timerStop forMode:NSDefaultRunLoopMode];
}
-(void)stopSendNewMessage:(id)sender{
    NSTimer *tmpTimer=(NSTimer *)sender;
    GroupMessage *logMsg=(GroupMessage *)tmpTimer.userInfo;
    NSLog(@"logMsg is %@",logMsg);
    
    NSLog(@"self.chatToGroup.groupMessage is %@",self.chatToGroup.groupMessage);
    for (GroupMessageFrame *tmpMessageFrame in self.allGroupMessagesFrame) {
        //        tmpMessage.MsgSN =
        
        NSLog(@"tmpMessage.MsgSN %u is equel ? self.messageSN %u ",tmpMessageFrame.message.MsgSN , logMsg.MsgSN);
        
        if (tmpMessageFrame.message.MsgSN == logMsg.MsgSN) {
            //
            if (tmpMessageFrame.message.state==MessageIsSend) {
                tmpMessageFrame.message.state=MessageFailed;
                [self updateGMessageStateWithMessage:tmpMessageFrame.message];
                //        [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
                
            }
            break;
        }
    }
    
    
    
    
    
    
    
}
-(void)stopSendGroupMessageRightNow{
    
}
#pragma mark - 更新消息状态]
-(void)updateFaildMessageState:(GroupMessage *)message{
    message.state = MessageFailed;
    [self updateGMessageStateWithMessage:message];
    //            [ClientHelper connectToHost];
    [self performSelectorInBackground:@selector(reConnectChatHost) withObject:nil];
    NSLog(@"message.state %u",message.state);
}
-(void)updateMessageStateWithRet:(GroupMessage *)message ret:(int)ret{
    if (retNormal<0) {
        message.state = MessageFailed;
        [self updateGMessageStateWithMessage:message];
        [self performSelectorInBackground:@selector(reConnectChatHost) withObject:nil];
        //                            [ClientHelper connectToHost];
    }
    else{
        [self performSelectorOnMainThread:@selector(loadMainTimeRetStopNormal:) withObject:message waitUntilDone:NO];
        
    }
    //    else{
    //        message.state = MessageSuccess;
    //        [self updateGMessageStateWithMessage:message];
    //    }
    NSLog(@"message.state %u",message.state);
}
-(void)reConnectChatHost{
    [ClientHelper connectToHost];
}
-(void)updateGMessageStateWithMessage:(GroupMessage *)msg
{
    SGroupMessageDB *msgdb = [[SGroupMessageDB alloc] init];
//    if ([msg isValidate]) {
#warning 补上方法
//        [msgdb mergeGroupMessage:msg WithContactUid:self.hostMember.memberId];
    
        for (GroupMessageFrame *gMF in self.allGroupMessagesFrame) {
            NSLog(@"%f %f",gMF.message.time,msg.time);
//            if ([gMF.message.time isEqualToString: msg.time]&&gMF.message.memberId==msg.memberId) {
            if (gMF.message.time == msg.time&&gMF.message.memberId==msg.memberId) {
                gMF.message.state=msg.state ;
                break;
            }
        }
//    }
    
    [self performSelectorOnMainThread:@selector(TableViewReloadData) withObject:nil waitUntilDone:NO];
}
/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction
{
    NSLog(@"开始录制...");
    [self recordStart];
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction
{
    NSLog(@"取消录制...");
    [self recordCancel];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction
{
    NSLog(@"结束录制...");
    [self recordStop];
}
#pragma end
#pragma mark - 按下Home键
- (void)applicationWillResignActive:(NSNotification *)notification
{
    NSLog(@"按理说是触发home按下");
    if ([g_audioRecorder isRecording]) {
        [self recordStop];
    }
}
#pragma mark - ZBMessageFaceViewDelegate
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    if (dele) {
        self.g_messageToolView.messageInputTextView.text = [self messageInputViewTextByDelete:self.g_messageToolView.messageInputTextView.text];
    }else{
        self.g_messageToolView.messageInputTextView.text = [self.g_messageToolView.messageInputTextView.text stringByAppendingString:faceStr];
    }
    [self inputTextViewDidChange:self.g_messageToolView.messageInputTextView];
}
-(void)sendStr{
    [self didSendTextAction:_g_messageToolView.messageInputTextView];
}
#pragma end

#pragma mark - ZBMessageShareMenuView Delegate
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {
            NSLog(@"点击第一个按钮。");
            UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imgPicker setDelegate:self];
            [imgPicker setAllowsEditing:YES];
            [self presentViewController:imgPicker animated:YES completion:^{
            }];
        }
            
            break;
        case 1:
        {
            NSLog(@"点击第二个按钮。");
            UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imgPicker setDelegate:self];
            [imgPicker setAllowsEditing:YES];
            [self.navigationController presentViewController:imgPicker animated:YES completion:^{
            }];
        }
            break;
        case 2:
            NSLog(@"点击第三个按钮。");
            break;
        case 3:
            NSLog(@"点击第四个按钮。");
            break;
        case 4:{
            NSLog(@"点击了红包按钮");
            //tag
//            GroupRedPacketSendViewController *redVC=[[GroupRedPacketSendViewController alloc]initWithChatGroup:self.chatToGroup];
//            [self.navigationController pushViewController:redVC animated:NO];
        }
            break;
        default:
            break;
    }
}

#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * userImage= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.g_messageToolView.frame
                                      andDuration:g_animationDuration
                                         andState:ZBMessageViewStateShowNone];
        [self imageUploadInitWithImage:userImage];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma end



#pragma mark - 文本框代理方法
#pragma mark 点击textField键盘的回车按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"delete characters");
    return YES;
}
#pragma mark - 发送红包的方法
-(void)handleRedPacketData:(NSString *)redCode{
    
    NSLog(@"redcode is : %@",redCode);
    
    GroupMessage *message = [[GroupMessage alloc] init];
    message.belongGroupId = self.chatToGroup.groupId;
    message.memberId = self.hostMember.memberId;
    
    message.icon = self.hostMember.headImage;
    message.code = MessageCodeGroupText;
    message.type = MessageTypeMe;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *now=[NSDate date];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    message.time = [[NSDate date]timeIntervalSince1970];
    message.state = MessageSuccess;
    message.readState = MessageRead;
    self.chatToGroup.sessionDate = [now timeIntervalSince1970];
    
    
    //表示身份
    if (groupMemberMyself.groupMemberType==groupOwner) {
        message.messageIdentity=MessageIdentityOwner;
    }
    else if (groupMemberMyself.groupMemberType==groupAdmin){
        message.messageIdentity=MessageIdentityAdmin;
    }
    else{
        message.messageIdentity=MessageIdentityUser;
    }
    
    //sendMessageContent 是发送给服务器的
    //    NSString *sendMessageContent=[NSString stringWithFormat:@"%@发了一个红包犒劳大家|red",self.hostMember.nickName];
    //message.content 是存在数据库中的 存放了redcode
    message.content =[NSString stringWithFormat:@"%@发了一个红包犒劳大家|red|rcode:%@",self.hostMember.nickName,redCode];
    message.contentType=MessageContentRedPacket;
    [self addMessage:message];
    //    NSString *sendContent = [NSString stringWithFormat:@"{\"txt\":\"%@\",\"rpstring\":\"%@\",\"ct\":%u}",sendMessageContent,redCode,MessageContentRedPacket];
    //    [ClientHelper sendGroupMessage:self.hostMember.memberId Token:[CommonUtil MyToken] Gid:self.chatToGroup.groupId Message:sendContent Msgsn:self.chatToGroup.groupMessage.count-1];
}
-(void)gtableViewFrameChangeWithMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
        self.g_tableView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.g_tableView.frame), CGRectGetHeight(frame)-CGRectGetHeight(self.view.frame)+self.g_messageToolView.frame.origin.y);
        [self g_tableViewSrollToBotton];
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark - 查询自己的加群状态
//-(groupState)serachMyGroupRecordWithUid:(int)uid Gid:(int)gid{
//    groupState groupstate=groupStateUnKnowState;
//    NSString *urlStr=[NSString stringWithFormat:@"%@?gid=%u",XJD_HOME_THEGROUP_RECORD,gid];
//    //    NSString *urlStr=[NSString stringWithFormat:@"%@?uid=%u&gid=%u",XJD_HOME_THEGROUP_RECORD,uid,gid];
//    __weak ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    XJDChangeUserInfoHelp *xjdhelpme=[XJDChangeUserInfoHelp getXJDGlobalInfo];
//    [request setPostValue:xjdhelpme.xjdKey forKey:@"key"];
//    NSError *error=[request error];
//    request.timeOutSeconds=5;
//    [request startSynchronous];
//    
//    //    [request setCompletionBlock:^{
//    if (!error) {
//        NSString *result=[request responseString];
//        NSDictionary *tmpdic=[result objectFromJSONString];
//        int code=[[tmpdic objectForKey:@"Code"]intValue];;
//        if (code==1) {
//            //
//            NSDictionary *resultDic=[[tmpdic objectForKey:@"Data"]objectForKey:@"Result"];
//            if ([resultDic isKindOfClass:[NSNull class]]) {
//                groupstate=100;
//            }
//            else{
//                groupstate=[[[[tmpdic objectForKey:@"Data"]objectForKey:@"Result"]objectForKey:@"Barstate"]intValue];
//                
//            }
//        }
//    }
//    //    }];
//    
//    //    [request setFailedBlock:^{
//    //        groupstate=100;
//    //    }];
//    
//    return groupstate;
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