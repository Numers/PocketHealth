//
//  NotificationMessage.m
//  AJKGroupChatDemo
//
//  Created by YangFan on 14/12/12.
//  Copyright (c) 2014年 YangFan. All rights reserved.
//

#import "NotificationMessage.h"

@implementation NotificationMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"content":          @"txt",
             @"createTime":          @"time",
             @"memberId": @"touid" ,
             
             @"recordId" : @"recordid",
            //所属属性
             @"belongGroupId": @"gid",
             @"messageCode" : @"msgtype" ,
             @"joinType" : @"JoinType"
             };
}
@end
