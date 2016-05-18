//
//  PHUploadPushInfo.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUploadPushInfo.h"
static PHUploadPushInfo *phUploadPushInfo;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHUploadPushInfo
+(id)defaultManager
{
    if (phUploadPushInfo == nil) {
        phUploadPushInfo = [[PHUploadPushInfo alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phUploadPushInfo;
}

-(void)uploadPushInfoWithDictionary:(NSDictionary *)dic WithAFNetWorkKey:(NSString *)key CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_SendPushInfo_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:dic];
    [parameters setObject:key forKey:@"key"];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
