//
//  Room.m
//  PocketHealth
//
//  Created by macmini on 15-3-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "Room.h"

@implementation Room
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"iid":@"Iid",
             @"roomId":@"Roomid",
             @"maxOnline":@"Maxonline",
             @"currentOnline":@"Curonline",
             @"roomHost" : @"Roomhost",
             @"roomIp" : @"Roomip" ,
             @"cncRoomIp": @"Cncroomip",
             @"roomPort": @"Roomport",
             
             @"mcGroupId":@"Mcgroupid",
             @"rdGroupId":@"Rdgroupid",
             @"promsvrid":@"Promsvrid",
             @"isDel":@"Isdel",
             @"tmtVideoIp":@"Tmtvideoip",
             @"cncVideoIp":@"Cncvideoip",
             
             @"videoPort":@"Videoport",
             @"tmtWhiteboardIp":@"Tmtwhiteboardip",
             @"cncWhiteboardIp":@"Cncwhiteboardip",
             
             @"whiteboardPort":@"Whiteboardport",
             @"rtmp":@"Rtmp",
             @"cncRtmp":@"Cncrtmp",
             
             @"isUsed" : @"Isused"
             };
}


-(void)setNilValueForKey:(NSString *)key{
    [self setValue:@0 forKey:key];
}
@end
