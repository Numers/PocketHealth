//
//  NotificationMessage.m
//  AJKGroupChatDemo
//
//  Created by YangFan on 14/12/12.
//  Copyright (c) 2014年 YangFan. All rights reserved.
//

#import "NotificationMessage.h"
#import "GlobalVar.h"

@implementation NotificationMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"content":          @"txt",
             @"createTime":          @"time",
             @"memberId": @"uid" ,
             @"headImg":@"Headimg",
             @"recordId" : @"recordid",
             @"nickName":@"Nickname",
            //所属属性
             @"belongGroupId": @"gid",
             @"messageCode" : @"msgtype" ,
             @"joinType" : @"JoinType"
             };
}
+(NSValueTransformer *)headImgJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSString stringWithFormat:@"%@%@",ServerBaseURL,str];
    }
                                                         reverseBlock:^(NSString *num) {
                                                             return num;
                                                         }];
}
@end
