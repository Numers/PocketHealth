//
//  PHGroupChatHomeViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Member;

typedef enum{
    isDisConnect = 0,
    isConnected = 1,
    isTimeOut = 2,
    isSync = 3
} ConnectState;

@interface PHGroupChatHomeViewController : UIViewController
{
    
}

@property(nonatomic, strong) NSMutableArray *PHGroupChatTableViewDataSourceMainArray;

@property (nonatomic , strong) NSMutableDictionary * PHChatViewMutableDic;//存储聊天的chatvc'地址
@property(nonatomic, strong) UITableView *tableView;


-(Member *)searchMemberInFriendDBByMemberId:(long long)memberId;
-(Member *)searchMemberInChatFriendListByMemberId:(long long)memberId;
@end
