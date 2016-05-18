//
//  PHPhysicalExamTestManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPhysicalExamTestManager.h"
static PHPhysicalExamTestManager *phPhysicalExamTestManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHPhysicalExamTestManager
+(id)defaultManager
{
    if (phPhysicalExamTestManager == nil) {
        phPhysicalExamTestManager = [[PHPhysicalExamTestManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phPhysicalExamTestManager;
}

-(NSURLRequest *)physicalExamTestURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_PhysicalExamTest_API,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}

-(void)requestPhysicalExamTestCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamTest_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:                               AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
