//
//  PHMonitoringDateBaseHelper.h
//  PocketHealth
//
//  Created by YangFan on 15/1/15.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHMonitoringDateBaseHelper : NSObject


//-(NSString *)selectTodaySteps;
+(NSString *)selectTodaySleepingMinutes:(long long)memberId;
+(NSString *)selectOneDayWithDateTIme:(NSString *)date WithMemberId:(long long)memberId;

+(BOOL)mergeUnUploadSleepingToUploaded:(long long)memberId;
+(BOOL)mergeUnUploadExerciseToUploaded:(long long)memberId;
@end
