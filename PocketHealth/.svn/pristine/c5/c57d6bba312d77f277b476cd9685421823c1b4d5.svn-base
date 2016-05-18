//
//  GroupMessage.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OneForOneMessage.h"

typedef enum {
    MessageIdentityAdmin=2,
    MessageIdentityOwner=1,
    MessageIdentityUser=0
}MessageIdentity;

@interface GroupMessage : OneForOneMessage

@property(nonatomic) unsigned belongGroupId; //所属的群组
@property (nonatomic)unsigned messageIdentity;//消息来自什么身份 管理员 群主 用户



@end
