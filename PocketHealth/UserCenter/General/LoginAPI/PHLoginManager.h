//
//  PHLoginManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
static NSString *key_password = @"T@Q%G";//密码加密前5位字符串;
@interface PHLoginManager : NSObject
+(id)defaultManager;

-(void)loginWithLoginName:(NSString *)loginName WithPassword:(NSString *)password WithUdid:(NSString *)udid WithChanneid:(NSString *)channeid WithBuserid:(NSString *)buserid WithDeviceType:(DeviceType)deviceType needMd5:(BOOL)need CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
