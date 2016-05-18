//
//  PHPhysicalExamQuestionManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPhysicalExamQuestionManager.h"
static PHPhysicalExamQuestionManager *phPhysicExamQuestionManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHPhysicalExamQuestionManager
+(id)defaultManager
{
    if (phPhysicExamQuestionManager == nil) {
        phPhysicExamQuestionManager = [[PHPhysicalExamQuestionManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phPhysicExamQuestionManager;
}

-(NSURLRequest *)physicalExamQuestionURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",PH_PhysicalExamQuestion_API,AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}

-(void)requestPhysicalExamQuestionCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamQuestion_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:                               AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
