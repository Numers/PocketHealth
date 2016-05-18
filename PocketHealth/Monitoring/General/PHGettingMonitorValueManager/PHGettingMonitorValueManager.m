//
//  PHGettingMonitorValueManager.m
//  PocketHealth
//
//  Created by YangFan on 15/1/23.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGettingMonitorValueManager.h"
#import "PHMonitoringHttpRequest.h"

//数据类
#import "CommonUtil.h"

static PHGettingMonitorValueManager * phGettingMoniValueManager;
@implementation PHGettingMonitorValueManager

+(id)defaultManager
{
    if (phGettingMoniValueManager == nil) {
        phGettingMoniValueManager = [[PHGettingMonitorValueManager alloc] init];
        
    }
    return phGettingMoniValueManager;
}
-(void)gettingScoreWithMoodActivitySleep:(long long)memberId result:(void(^)(NSDictionary* result))rebackValue{
    //请求http 请求 返回 3个值
    if (memberId!=0) {
        //暂时没写
    }
    [PHMonitoringHttpRequest requestMySocreDone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        //这边暂时获取3个分值的数据 添加到数组
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            NSDictionary * dic = (NSDictionary *)responseObject;
            NSDictionary * resultDic = [dic objectForKey:@"Result"];
            if (([resultDic isKindOfClass:[NSNull class]]) || (resultDic == nil)) {
                rebackValue(nil);
                return ;
            }
    
            //block回调用
            rebackValue(resultDic);
        }else{
            rebackValue(nil);
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        rebackValue(nil);
    }];
}
@end