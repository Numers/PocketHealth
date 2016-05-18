//
//  NotificationMessage.h
//  AJKGroupChatDemo
//
//  Created by YangFan on 14/12/12.
//  Copyright (c) 2014年 YangFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
//#import "Message.h"


@interface NotificationMessage : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *content;//主体内容
@property (nonatomic) long long memberId; //所属成员
@property (nonatomic) NSTimeInterval createTime; //创建时间
@property (nonatomic) NSTimeInterval sessionDate; //本地接受到的时间
@property (nonatomic) unsigned belongGroupId; //所属群组
@property (nonatomic) unsigned messageCode; //消息类型 同message类

@property (nonatomic) unsigned recordId; //消息编号

@property (nonatomic) NSString * joinType; //加群类型 Invite or Join


@end
