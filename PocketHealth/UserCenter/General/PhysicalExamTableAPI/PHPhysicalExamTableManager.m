//
//  PHPhysicalExamTableManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPhysicalExamTableManager.h"
static PHPhysicalExamTableManager *phPhysicalExamTableManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHPhysicalExamTableManager
+(id)defaultManager
{
    if (phPhysicalExamTableManager == nil) {
        phPhysicalExamTableManager = [[PHPhysicalExamTableManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phPhysicalExamTableManager;
}

-(void)requestPhysicalExamTableListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamTable_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:                               AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(void)addNewPhysicalExamTable:(NSString *)orderId WithPassword:(NSString *)password WithorganizationOiid:(NSInteger)oiid CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamAdd_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:orderId,@"id",password,@"pwd",[NSString stringWithFormat:@"%ld",oiid],@"oiid",AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(NSURLRequest *)physicalExamTableURLRequestWithEbid:(NSInteger)ebid
{
    NSString *url = [NSString stringWithFormat:@"%@?ebid=%@&key=%@",PH_PhysicalExamReport_API,[NSString stringWithFormat:@"%ld",ebid],AFNetWorkKey];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}

-(void)requestPhysicalExamReportWithEbid:(NSInteger)ebid CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_PhysicalExamReport_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",ebid],@"ebid",AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
