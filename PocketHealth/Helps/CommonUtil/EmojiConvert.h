//
//  EmojiConvert.h
//  PocketHealth
//
//  Created by YangFan on 15/1/19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmojiConvert : NSObject

//编码
+(NSString *)emojiConvertToSendString:(NSString *)baseStr;

//解码
//+(NSMutableString *)convertOrgUnicodeToPrintUnicode:(NSString *)orgUnicode;
+(NSString *)convertReceviceStringMaybeHasContainEmoji:(NSString *)receiveString;
@end
