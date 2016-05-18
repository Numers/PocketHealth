//
//  GroupMessage.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupMessage.h"
#import "EmojiConvert.h"
@implementation GroupMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"belongGroupId":          @"gid",
             @"code":          @"msgtype",
             @"contentType" : @"ct",
             @"content" : @"txt" ,
             @"time" : @"time" ,
             @"memberId" : @"uid"
             
             };
}
-(id)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    //先判断有没有emoji表情 [E][/E]
    NSString * tmpEmojiStr = [EmojiConvert convertReceviceStringMaybeHasContainEmoji:self.content];
    if (tmpEmojiStr!=nil && ![tmpEmojiStr isEqualToString:@""]) {
        self.content = tmpEmojiStr;
    }
    return self;
}
@end
