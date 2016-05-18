//
//  GroupHelpAggregation.m
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupHelpAggregation.h"
#import "GroupMessage.h"

@implementation GroupHelpAggregation

-(id)initWithLastGroupMessage:(GroupMessage *)groupMessage{
    self = [super init];
    if (self) {
        //
        self.content = groupMessage.content;
        self.isHasNewMessage = NO;
        self.sessionDate = groupMessage.time;
        self.contentType = groupMessage.contentType;
    }
    return self;
}
-(id)initWithNotReadCount:(NSInteger)notReadCount{
    self = [super init];
    if (self) {
        //
        self.notReadCount = notReadCount;
        self.content = [NSString stringWithFormat:@"%ld条未读消息",(long)notReadCount];
        self.isHasNewMessage =  YES;
    }
    return self;
}
@end
