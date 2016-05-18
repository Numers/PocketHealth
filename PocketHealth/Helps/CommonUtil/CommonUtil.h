//
//  CommonUtil.h
//  ylmm
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonUtil : NSObject
+(void)HUDShowText:(NSString *)text InView:(UIView *)view;
+(UIImage *)imageWithColor:(UIColor *)color;
+(id)localUserDefaultsForKey:(NSString *)key;
+(void)localUserDefaultsValue:(id)value forKey:(NSString *)key;
+(id)MyToken;
//*******时间转换
+(NSString *)TimeStrMMDDHHmmWithInterval:(NSTimeInterval)interval;
+(NSString *)TimeStrWithInterval:(NSTimeInterval)interval;
+(NSString *)TimeStrYYYYMMDDWithInterval:(NSTimeInterval)interval;
+(NSString *)TimeStrYYYYMMDDHHWithInterval:(NSTimeInterval)interval;
+(NSString *)TimeStrYYYYMMDDHHMMSSWithInterval:(NSTimeInterval)interval;
+(NSTimeInterval )TimeIntervalZeroWithInterval:(NSTimeInterval)interval;
+(NSString * )TimeStrZeroWithTimerStr:(NSString *)timelongStr;
+(NSString *)LocalTimeStr;
+(NSTimeInterval)TimeStrTransformInterval:(NSString *)timeStr;
+(NSInteger)HHTimeStrNow;
+(NSString *)sleepTimeBelongDateWithHH:(NSInteger )HH;
//--------------
+(BOOL)isShowTimeLabelWithFirstTime:(NSTimeInterval)fTime SecondTime:(NSTimeInterval)sTime;
+(NSString *) jsonStringWithArray:(NSArray *)array;
//+(NSString *)md5WithLoginName:(NSString *)loginName WithPassword:(NSString *)password;
//+(NSString *)md5WithUid:(unsigned)uid;

+(NSString *)md5:(NSString *)str;
+(UIImage *)croppedImage:(UIImage *)image;
+(BOOL) isValidateMobilePhone:(NSString *)mobilePhone;
+(BOOL) isValidatePassWord:(NSString *)psd;
+(BOOL)isValidateName:(NSString *)text;

+(void)playMessageComeNotify;

+(NSTimeInterval )IntervalWithTimeStr:(NSString *)time;


//计算与服务器通讯的key值
+(NSString *)createSendKeyWithUserName:(NSString *)userName Userid:(NSString *)userid;

//验证服务器返回的code是否为1 1为正确
+(BOOL)isValidateHttpResponseObject:(id)responseObject;


+(NSAttributedString *)transformAddFaceExpressionWithOrgstr:(NSString *)orgStr attributesWithDic:(NSDictionary *)attributesDictionary;

@end
