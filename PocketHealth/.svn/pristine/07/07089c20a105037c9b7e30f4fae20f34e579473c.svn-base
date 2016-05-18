//
//  PHWeathManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHWeathManager.h"
static PHWeathManager *phWeathManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHWeathManager
+(id)defaultManager
{
    if (phWeathManager == nil) {
        phWeathManager = [[PHWeathManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phWeathManager;
}

-(void)requestWeathInfo:(NSString *)latAndLng CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_Monitroing_WeathInfo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:latAndLng,@"name",                               AFNetWorkKey,@"key",nil];
    [requestManager GET:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
