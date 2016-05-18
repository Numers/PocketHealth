//
//  PHLoginManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHLoginManager.h"
#import "NSString+Additions.h"
static PHLoginManager *loginManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHLoginManager
+(id)defaultManager
{
    if (loginManager == nil) {
        loginManager = [[PHLoginManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return loginManager;
}

-(void)loginWithLoginName:(NSString *)loginName WithPassword:(NSString *)password WithUdid:(NSString *)udid WithChanneid:(NSString *)channeid WithBuserid:(NSString *)buserid WithDeviceType:(DeviceType)deviceType needMd5:(BOOL)need CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_Login_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:loginName,@"loginname",
                                udid,@"udId",
                                channeid,@"channeid",
                                buserid,@"buserid",
                                [NSString stringWithFormat:@"%d",deviceType],@"devicetype",nil];
    if (need) {
        [parameters setObject:[NSString md5:[NSString stringWithFormat:@"%@%@",key_password,password]] forKey:@"password"];
    }else{
        [parameters setObject:password forKey:@"password"];
    }
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
