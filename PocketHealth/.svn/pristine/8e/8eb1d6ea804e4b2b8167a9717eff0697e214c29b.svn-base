//
//  PrivateChatTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageInputView.h"
#import <AVFoundation/AVFoundation.h>
#import "OneForOneMessage.h"
#import "Member.h"

#define kRecorderViewRect       CGRectMake([UIScreen mainScreen].bounds.size.width/2-80, [UIScreen mainScreen].bounds.size.height/2-120, 160, 160)

@interface PrivateChatTableViewController : UIViewController<AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
}
@property (strong, nonatomic) Member *chatToMember;
@property (strong, nonatomic) Member *hostMember;

@property (strong, nonatomic)  UITableView *tableView;
//@property (strong, nonatomic) FacePanelViewController *facePanelVC;
@property (nonatomic) BOOL isCurrentPresentView;

- (void)addMessage:(OneForOneMessage *)msg isSave:(BOOL)flag;
-(id)initWithMember:(Member *)member WithHostMember:(Member *)host;

@property (nonatomic)  NSInteger messageSN; //消息序列号 2014-12-16 14:10:19 yangfan

-(void)TableViewReloadData;
-(void)TableViewReloadDataWithoutScrollToBottom;
-(void)tableViewscrollToBottom;

@end
