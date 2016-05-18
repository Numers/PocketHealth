//
//  PHMonitoringDateBaseHelper.m
//  PocketHealth
//
//  Created by YangFan on 15/1/15.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMonitoringDateBaseHelper.h"
#import "SSleepingDB.h"
#import "SMonitorExerciseDB.h"

@implementation PHMonitoringDateBaseHelper

+(NSString *)selectOneDayWithDateTIme:(NSString *)date WithMemberId:(long long)memberId{
    SSleepingDB * sleepDb = [[SSleepingDB alloc]init];
    NSString * oneDaySleep = [sleepDb selectOnedaySleepingMinutesWithYYMMDD:date WithMember:memberId];
    return oneDaySleep;
}
+(NSString *)selectTodaySleepingMinutes:(long long)memberId{
    SSleepingDB * sleepDb = [[SSleepingDB alloc]init];
    NSString * todaySleep = [sleepDb selectTodaySleepingMinutes:memberId];
    return todaySleep;
}
+(BOOL)mergeUnUploadSleepingToUploaded:(long long)memberId{
    SSleepingDB *sleepDb = [[SSleepingDB alloc]init];
    return [sleepDb mergeUnUploadSleepingToUploaded:memberId];
}
+(BOOL)mergeUnUploadExerciseToUploaded:(long long)memberId{
    SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
    return [smExerciseDB mergeUnUploadExerciseToUploaded:memberId];
}
@end
