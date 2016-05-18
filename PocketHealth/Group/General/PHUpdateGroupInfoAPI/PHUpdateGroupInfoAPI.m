//
//  PHUpdateGroupInfoAPI.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUpdateGroupInfoAPI.h"
static PHUpdateGroupInfoAPI *phUpdateGroupInfoAPI;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHUpdateGroupInfoAPI
+(id)defaultManager
{
    if (phUpdateGroupInfoAPI == nil) {
        phUpdateGroupInfoAPI = [[PHUpdateGroupInfoAPI alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phUpdateGroupInfoAPI;
}

-(void)updateGroupInfoWithParameter:(NSString *)parameter WithProperty:(NSString *)property WithGroupId:(NSString *)groupId CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
{
    NSString *url = [PH_UpdateGroupInfo_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:parameter,property,groupId,@"Hbid",AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end