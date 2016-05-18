//
//  PHReportIndexManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-29.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHReportIndexManager.h"
static PHReportIndexManager *phReportIndexManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHReportIndexManager
+(id)defaultManager
{
    if (phReportIndexManager == nil) {
        phReportIndexManager = [[PHReportIndexManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phReportIndexManager;
}

-(NSURLRequest *)reportIndexURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_Monitoring_GetReportIndex,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}
@end
