//
//  PHPhysicalExamBookManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPhysicalExamBookManager.h"
static PHPhysicalExamBookManager *phPhysicalExamBookManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHPhysicalExamBookManager
+(id)defaultManager
{
    if (phPhysicalExamBookManager == nil) {
        phPhysicalExamBookManager = [[PHPhysicalExamBookManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phPhysicalExamBookManager;
}

-(NSURLRequest *)physicalExamBookRecoderURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_PhysicalExamBook_API,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}

-(NSURLRequest *)myPhysicalExamBookRecoderURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_MyPhysicalExamBook_API,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}

-(void)requestPhysicalExamBookCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamBook_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:                               AFNetWorkKey,@"key",nil];
    [requestManager GET:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
