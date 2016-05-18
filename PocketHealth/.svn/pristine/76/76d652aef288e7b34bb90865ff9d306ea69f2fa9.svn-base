//
//  PHUserFeedBackManager.m
//  PocketHealth
//
//  Created by macmini on 15-2-3.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUserFeedBackManager.h"
static PHUserFeedBackManager *phUserFeedBackManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHUserFeedBackManager
+(id)defaultManager
{
    if (phUserFeedBackManager == nil) {
        phUserFeedBackManager = [[PHUserFeedBackManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phUserFeedBackManager;
}

-(void)uploadFeedBack:(NSString *)remark WithContactNumber:(NSString *)number CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *urlStr=[NSString stringWithFormat:PH_UserFeedBack_API];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters =[[NSMutableDictionary alloc]initWithObjectsAndKeys:remark,@"remark",number,@"number",AFNetWorkKey,@"key", nil];
    [manager POST:urlStr  parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
