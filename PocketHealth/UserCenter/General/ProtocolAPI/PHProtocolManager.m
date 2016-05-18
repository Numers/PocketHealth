//
//  PHProtocolManager.m
//  PocketHealth
//
//  Created by macmini on 15-2-3.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHProtocolManager.h"
static PHProtocolManager *phProtocolManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHProtocolManager
+(id)defaultManager
{
    if (phProtocolManager == nil) {
        phProtocolManager = [[PHProtocolManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phProtocolManager;
}
-(NSURLRequest *)protocolURLRequest
{
    NSString *url = [NSString stringWithFormat:@"%@",PH_UserProtocol_API];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut];
    return request;
}
@end
