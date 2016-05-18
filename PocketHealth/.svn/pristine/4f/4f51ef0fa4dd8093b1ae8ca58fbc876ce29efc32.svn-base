//
//  PHAccountBalanceManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-30.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAccountBalanceManager.h"
static PHAccountBalanceManager *phAccountBalanceManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHAccountBalanceManager
+(id)defaultManager
{
    if (phAccountBalanceManager == nil) {
        phAccountBalanceManager = [[PHAccountBalanceManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phAccountBalanceManager;
}
-(NSURLRequest *)accountBalanceURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_UserBalance_API,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}
@end
