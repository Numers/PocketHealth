//
//  PHUpdateUserInfoManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-12.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
typedef enum{
    BindMobile = 1,
    ModifyMobile = 2,
    FindPassword = 3
}OperationCode;
static NSString *key_password = @"T@Q%G";//密码加密前5位字符串;
@interface PHUpdateUserInfoManager : NSObject
+(id)defaultManager;
-(void)updateUserInfoWithParameter:(NSString *)parameter WithProperty:(NSString *)property CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)updateUserInfoWithDictionary:(NSDictionary *)dic CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)updateUserHeadWithImageData:(NSData *)fileData Completion:(ApiCompletionHandler)completion;
-(void)sendPhoneCodeWithTel:(NSString *)tel WithType:(OperationCode)type CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)verificateUserWithPhone:(NSString *)phone WithVerificateCode:(NSString *)verificateCode WithUserId:(long long)userId CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
