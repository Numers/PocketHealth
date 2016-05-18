//
//  OneForOneMessage.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "OneForOneMessage.h"
#import "GlobalVar.h"
@implementation OneForOneMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    //父类消除警告用的写这句话
    // properties defined in header < : > key in JSON Dictionary
    return @{
             
             };
}

-(MessageContentType)messageContentType
{
    MessageContentType type;
    NSRange range = [self.content rangeOfString:@".amr|"];
    if(range.length == 0)
    {
        NSRange range1 = [self.content rangeOfString:@"|IMAGE"];
        if ((range1.location > 0) && (range1.length > 0)) {
            type = MessageContentImage;
        }else{
            NSRange range2=[self.content rangeOfString:@"|red"];
            if ((range2.location > 0) && (range2.length > 0)){
                type=MessageContentRedPacket;
            }
            else{
                type = MessageContentText;
            }
            
        }
    }
    //    else if ((range.location > 0) && (range.length > 0) ) {
    //        type =  MessageContentVoice;
    //    }
    else {
        type =  MessageContentVoice;
    }
    return type;
}
+(MessageContentType)messageContentType:(NSString *)content{
    MessageContentType type;
    NSRange range = [content rangeOfString:@".amr|"];
    if(range.length == 0)
    {
        NSRange range1 = [content rangeOfString:@"|IMAGE"];
        if ((range1.location > 0) && (range1.length > 0)) {
            type = MessageContentImage;
        }else{
            NSRange range2=[content rangeOfString:@"|red"];
            if ((range2.location > 0) && (range2.length > 0)){
                type=MessageContentRedPacket;
            }
            else{
                type = MessageContentText;
            }
            
        }
    }
    //    else if ((range.location > 0) && (range.length > 0) ) {
    //        type =  MessageContentVoice;
    //    }
    else {
        type =  MessageContentVoice;
    }
    return type;
}
-(NSString *)fullServerImagePath{
    NSString *imagePath = nil;
    if ([self messageContentType] == MessageContentImage) {
        NSRange range = [self.content rangeOfString:@"|IMAGE"];
        if ((range.length > 0) && (range.location > 0)) {
            NSString *path = [self.content substringToIndex:range.location];
            imagePath = [NSString stringWithFormat:@"%@%@",ServerBaseURL,path];
        }
    }
    return imagePath;
}
-(NSString *)fulltThumbnailsPath{
    NSString *imagePath = nil;
    if ([self messageContentType] == MessageContentImage) {
        NSRange range = [self.content rangeOfString:@"|IMAGE"];
        if ((range.length > 0) && (range.location > 0)) {
            NSString *path = [self.content substringToIndex:range.location];
            NSString * imagePathShort  = [NSString stringWithFormat:@"%@%@",ServerBaseURL,path];
            
            imagePath = [imagePathShort stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_s.jpeg"];
        }
        
        
    }
    return imagePath;
}
@end
