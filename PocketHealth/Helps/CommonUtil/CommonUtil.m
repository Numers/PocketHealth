//
//  CommonUtil.m
//  ylmm
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 YiLiao. All rights reserved.
//

#import "CommonUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "WQPlaySound.h"

#import "NSString+Additions.h"
#import "DesWithIV.h"
#import "MBProgressHUD+Add.h"
//#import "PGlobal.h"

#define SHOWMSGBETWEENTIME 60.0

@implementation CommonUtil
+(void)HUDShowText:(NSString *)text InView:(UIView *)view{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];
}

+(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(id)localUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:key];
    return token;
}
+(void)localUserDefaultsValue:(id)value forKey:(NSString *)key
{
    if ((value == nil) || ([value isKindOfClass:[NSNull class]])) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+(id)MyToken
{
    return [CommonUtil localUserDefaultsForKey:KMY_TOKEN];
//    return @"qweqwe";
    //暂时未使用,随意填写
}

+(NSString *)TimeStrMMDDHHmmWithInterval:(NSTimeInterval)interval{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日 HH:mm"];
    
    NSString *time=[formatter stringFromDate:date];
    return time;
}

+(NSString *)TimeStrYYYYMMDDWithInterval:(NSTimeInterval)interval{
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
    
            NSString *time=[formatter stringFromDate:date];
            return time;
}
+(NSString *)TimeStrYYYYMMDDHHWithInterval:(NSTimeInterval)interval{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH"];
    
    NSString *time=[formatter stringFromDate:date];
    return time;
}
+(NSString *)TimeStrYYYYMMDDHHMMSSWithInterval:(NSTimeInterval)interval{
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *time=[formatter stringFromDate:date];
    return time;
}
+(NSTimeInterval )TimeIntervalZeroWithInterval:(NSTimeInterval)interval{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate * dateFlag = [formatter dateFromString:[CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]]];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    return timeZero;
}
+(NSTimeInterval)TimeStrTransformInterval:(NSString *)timeStr{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate * dateFlag = [formatter dateFromString:timeStr];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    return timeZero;
}
+(NSString * )TimeStrZeroWithTimerStr:(NSString *)timelongStr{
    NSString * zeroTimeStr;
    NSRange range = [timelongStr rangeOfString:@" "];
    if (range.length>0) {
        zeroTimeStr = [timelongStr substringToIndex:range.location];
    }
    return zeroTimeStr;
}
+(NSString *)TimeStrWithInterval:(NSTimeInterval)interval
{
    
    //关闭判断分钟日期模式
    if (/* DISABLES CODE */ (NO)) {
        //
        NSTimeInterval now = [[NSDate dateWithTimeIntervalSinceNow:0]timeIntervalSince1970];
        NSTimeInterval cha = now - interval;
        NSString *timeDetailStr = [self TimeDetailStrCalculate:cha WithInterval:interval];
        return timeDetailStr;
    }else{
        //---------
        NSString *timeRet;
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *time=[formatter stringFromDate:date];
        
        
        NSDate *dateToday = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *time2=[formatter stringFromDate:dateToday];
        if ([time isEqualToString:time2]) {
            //如果是今天 那么返回时间 HH:mm
            [formatter setDateFormat:@"HH:mm"];
            timeRet = [formatter stringFromDate:date];

        }else{
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            timeRet = [formatter stringFromDate:date];
        }
        return timeRet;
    }
   
}
+(NSTimeInterval )IntervalWithTimeStr:(NSString *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSince1970];
}
+(NSString *)TimeDetailStrCalculate:(NSTimeInterval)cha WithInterval:(NSTimeInterval)interval{
    NSString * timeString = nil;
    if (cha/3600 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
//        int num= [timeString intValue];
        
//        if (num <= 1) {
//            
//            timeString = [NSString stringWithFormat:@"刚刚..."];
//            
//        }else{
//            
//            timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
//            
//        }
        timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    
    if (cha/3600 > 1 && cha/86400 < 1) {
        
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        timeString = [NSString stringWithFormat:@"%@小时前", timeString];
        
    }

    if (cha/86400 > 1)
        
    {
        
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        
        timeString = [timeString substringToIndex:timeString.length-7];
        
        int num = [timeString intValue];
        
        if (num < 2) {
            
            timeString = [NSString stringWithFormat:@"昨天"];
            
        }else if(num >= 2 && num <3){
            
            timeString = [NSString stringWithFormat:@"前天"];
        }else if (num >=3 && num < 7){
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE"];
            timeString=[formatter stringFromDate:date];
        }
        else{
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            timeString=[formatter stringFromDate:date];
        }
        
    }
    return timeString;
}
+(NSString *)LocalTimeStr
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}
//返回现在的小时HH
+(NSInteger)HHTimeStrNow{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger HH = [yyyymmdd integerValue];
    return HH;
}
+(NSString *)sleepTimeBelongDateWithHH:(NSInteger )HH{
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<HH && HH<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    return belongSleepDate;
}
#pragma mark - 计算是否要显示聊天时间
+(BOOL)isShowTimeLabelWithFirstTime:(NSTimeInterval)fTime SecondTime:(NSTimeInterval)sTime{
    NSTimeInterval i = fTime - sTime;
    return i>SHOWMSGBETWEENTIME||i==0?true:false;
}
//+(NSString *)md5WithUid:(unsigned)uid
//{
//    NSString *temp = [NSString stringWithFormat:@"%u%@",uid,KEY];
//    NSString *ret = [self md5:[NSString stringWithFormat:@"%@%@",[self md5:temp],KEY]];
//    return ret;
//}
//
//+(NSString *)md5WithLoginName:(NSString *)loginName WithPassword:(NSString *)password
//{
//    NSString *temp = [NSString stringWithFormat:@"%@%@",loginName,KEY];
//    NSString *md5Str = [self md5:temp];
//    NSString *temp2 = [NSString stringWithFormat:@"%@%@%@",md5Str,password,KEY];
//    return [self md5:temp2];
//}

+(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

+(UIImage *)croppedImage:(UIImage *)image

{
    if (image)
    {
        float min = MIN(image.size.width,image.size.height);
        CGRect rectMAX = CGRectMake((image.size.width-min)/2, (image.size.height-min)/2, min, min);
        
        CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rectMAX);
        
        UIGraphicsBeginImageContext(rectMAX.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, min, min), subImageRef);
        UIImage *viewImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
        return viewImage;
    }
    
    return nil;
}

+(BOOL)isValidateName:(NSString *)text
{
    NSString *nameRegex = @"^[a-zA-Z\\u4e00-\\u9fa5]{1}[0-9a-zA-Z_\\u4e00-\\u9fa5]{0,7}$";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:text];
}

+(BOOL) isValidateMobilePhone:(NSString *)mobilePhone
{
    NSString *phoneRegex = @"^1\\d{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:mobilePhone];
}

+(void)playMessageComeNotify
{
    WQPlaySound *sound = [[WQPlaySound alloc] initForPlayingSoundWith:1007];
    [sound play];
}

+(BOOL) isValidatePassWord:(NSString *)psd
{
    NSString *psdRegex = @"^.{6,16}$";
    NSPredicate *psdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", psdRegex];
    return [psdTest evaluateWithObject:psd];
}

#pragma mark -  计算通讯key值
+(NSString *)createSendKeyWithUserName:(NSString *)userName Userid:(NSString *)userid{
    if ((userName == nil) || (userName.length == 0)) {
        userName = @"aaa";
    }
    
    if (userid==nil) {
        userid=@"1000000";
    }
    int randomX= (arc4random() % 90000)+10000;
    NSString *sendshowkey=[NSString stringWithFormat:@"%@_%@_HG*&IT^_%u",userName,userid,randomX];
    NSString *sendkey=[DesWithIV encryptUseDES:sendshowkey key:@"D9)3!|WU"];
    NSString *sendURlEncodedKey=[NSString encodeToPercentEscapeString:sendkey];
    
    
    return sendURlEncodedKey;
}
//#pragma mark - url encode
//-(NSString *)encodeToPercentEscapeString: (NSString *) input
//{
//    // Encode all the reserved characters, per RFC 3986
//    NSString *outputStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                                (CFStringRef)input,
//                                                                                                NULL,
//                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                                                                kCFStringEncodingUTF8));
//    return outputStr;
//}
#pragma mark - 验证服务器返回的code是否为1 1为正确
+(BOOL)isValidateHttpResponseObject:(id)responseObject{
   
    NSDictionary *dic = (NSDictionary *)responseObject;
    if ([dic objectForKey:@"Code"]) {
        NSInteger code = [[dic objectForKey:@"Code"]intValue];
        if (code == 1) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    
}
#pragma mark -  数组转字符串
+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = valueObj;
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}
#pragma mark - 添加了表情的字符串
+(NSAttributedString *)transformAddFaceExpressionWithOrgstr:(NSString *)orgStr attributesWithDic:(NSDictionary *)attributesDictionary{
    
    
    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    //从第一个字符串开始 寻找左方括号
    NSString  * changeStr =orgStr;
    
    //返回getOutAttriStr
    NSMutableAttributedString * getOutAttriStr = [[NSMutableAttributedString alloc]init];

//    NSRange rangeLeftSymbolBefore ;
//    NSRange rangeRightSymbolBefore;
    
    
    NSRange rangeLeftSymbolNow ;
    NSRange rangeRightSymbolNow;
    if ([changeStr rangeOfString:@"["].length==0) {
        [getOutAttriStr appendAttributedString:[[NSAttributedString alloc]initWithString:changeStr attributes:attributesDictionary]];
    }else{
//        [self transExpressionLoop:changeStr];
        while ([changeStr rangeOfString:@"["].length!=0) {
            rangeLeftSymbolNow = [changeStr rangeOfString:@"["];
            rangeRightSymbolNow = [changeStr rangeOfString:@"]"];
            
            NSString * beforeStr = [changeStr substringToIndex:rangeLeftSymbolNow.location];
            //先获取"["之前的字符串
            [getOutAttriStr appendAttributedString:[[NSAttributedString alloc]initWithString:beforeStr attributes:attributesDictionary]];
            
            if (rangeRightSymbolNow.length!=0) {
                
//                NSRange replaceRange = NSMakeRange(rangeLeftSymbolNow.location, rangeLeftSymbolNow.location - rangeRightSymbolNow.location);
                NSRange replaceRange = NSMakeRange(rangeLeftSymbolNow.location,rangeRightSymbolNow.location-rangeLeftSymbolNow.location + rangeRightSymbolNow.length);
                NSString * transStr = [changeStr substringWithRange:replaceRange];
                NSString * expressionStr = [expressionDic objectForKey:transStr];
                
//                NSString * beforeStr = [changeStr substringWithRange:NSMakeRange(rangeLeftSymbolNow.location, rangeRightSymbolBefore.location-rangeLeftSymbolNow.location)];
                //更新changeStr
                changeStr = [changeStr substringFromIndex:rangeRightSymbolNow.location+rangeRightSymbolNow.length];
                
                
                //添加表情
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [UIImage imageNamed:expressionStr];
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                [getOutAttriStr appendAttributedString:attachmentString];
            }
//            //进入下一个循环
//            rangeRightSymbolBefore = rangeRightSymbolNow;
//            rangeLeftSymbolBefore = rangeRightSymbolNow;
        }
        
        
        
//        [myString appendAttributedString:attachmentString];
    }
    
    

    return getOutAttriStr;
}



@end