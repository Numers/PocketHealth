//
//  PHRegisterManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHRegisterManager.h"
static PHRegisterManager *registerManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHRegisterManager
+(id)defaultManager
{
    if (registerManager == nil) {
        registerManager = [[PHRegisterManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return registerManager;
}

-(void)sendIdentifyCodeWithPhoneNumber:(NSString *)phone CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
{
    NSString *url = [PH_IdentifyCode_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:phone,@"tel",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(void)registerUserWithUdid:(NSString *)udid WithChanneid:(NSString *)channeid WithBuserid:(NSString *)buserid WithDeviceType:(DeviceType)deviceType CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_RegisterUser_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid,@"udId",channeid,@"channeid",buserid,@"buserid",[NSString stringWithFormat:@"%d",deviceType],@"devicetype",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
