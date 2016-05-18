//
//  PHRegisterManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"

@interface PHRegisterManager : NSObject
+(id)defaultManager;

-(void)sendIdentifyCodeWithPhoneNumber:(NSString *)phone CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;

-(void)registerUserWithUdid:(NSString *)udid WithChanneid:(NSString *)channeid WithBuserid:(NSString *)buserid WithDeviceType:(DeviceType)deviceType CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
