//
//  PHGettingMonitorValueManager.h
//  PocketHealth
//
//  Created by YangFan on 15/1/23.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHGettingMonitorValueManager : NSObject

+(id)defaultManager;

-(void)gettingScoreWithMoodActivitySleep:(long long)memberId result:(void(^)(NSDictionary * result))rebackValue;
@end
