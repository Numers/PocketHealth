//
//  HospitalAggregation.m
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "HospitalAggregation.h"
#import "OneForOneMessage.h"

@implementation HospitalAggregation

-(id)initWithLastMessage:(OneForOneMessage *)message{
    self = [super init];
    if (self) {
        //
        self.content = message.content ;
        self.sessionDate = message.time;
        self.contentType = message.contentType;
    }
    return self;
}
@end
