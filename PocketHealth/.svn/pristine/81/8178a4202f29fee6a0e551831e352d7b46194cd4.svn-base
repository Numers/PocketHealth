//
//  GroupChatTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageInputView.h"
#import <AVFoundation/AVFoundation.h>
#import "Group.h"
#import "Member.h"
#import "GroupMessage.h"
#import "GroupMessageFrame.h"

typedef enum {
    isFromGroupChatViewAdd=1,
    isFromGroupChatViewNormal=0
}isFromGroupChatView;

@interface GroupChatTableViewController : UIViewController<AVAudioPlayerDelegate>{
    AVAudioPlayer *g_audioPlayer;
}

@property (strong, nonatomic) Group *chatToGroup;
@property (strong, nonatomic) Member *hostMember;

@property (strong, nonatomic)  UITableView *g_tableView;
@property (nonatomic) BOOL g_isCurrentPresentView;

@property (nonatomic,assign) CGFloat g_previousTextViewContentHeight;

- (void)addMessage:(GroupMessage *)msg;
-(id)initWithGroup:(Group *)group WithHostMember:(Member *)host;
-(void)TableViewReloadData;

-(void)g_tableViewSrollToBotton;

@property (nonatomic) int retSimpleResult;
@property (nonatomic) isFromGroupChatView isFromGroupChatView;

@property (strong, nonatomic) NSMutableArray  *allGroupMessagesFrame;

@property (nonatomic) BOOL selectRedPacketPushViewFlag;
@property (nonatomic)  NSInteger messageSN; //消息序列号 2014-12-16 14:10:19 yangfan

/**
 *  向界面添加消息 新方法 2014-12-19 10:38:18 更抽象
 *
 *  @param gMessage 群消息对象
 */
-(void)addMessageFromXGPDistributor:(GroupMessage *)gMessage;

@end
