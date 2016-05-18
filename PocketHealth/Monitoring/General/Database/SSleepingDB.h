//
//  SSleepingDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "Sleeping.h"

@interface SSleepingDB : NSObject
{
    FMDatabase *_db;
}

-(void)createDataBase;


-(BOOL)saveSleeping:(Sleeping *)sleeping;
-(NSString *)selectTodaySleepingMinutes:(long long)memberId;
-(NSString *)selectOnedaySleepingMinutesWithYYMMDD:(NSString *)dateString WithMember:(long long)memberId;
-(BOOL)mergeSleeping : (Sleeping *)sleeping;

-(BOOL)isExistSleepingData:(NSTimeInterval)startSleepTime WithBelongId:(long long)belongId belongSleepDateHour:(NSString *)belongSleepDateHour;

-(BOOL)mergeSleepingWakeupTimeTo:(NSTimeInterval)wakeupSleepTime WithBelongId:(long long)belongId WithStartSleepTime:(NSTimeInterval)startSleepTime;

-(NSArray *)selectAllUnUploadDate:(long long)hostId;

-(BOOL)mergeUnUploadSleepingToUploaded:(long long)hostId;

/**
 *  查询昨天入睡的的开始时间
 *
 *  @param memberId 用户id
 *
 *  @return 返回开始的 时间 MM : SS
 */
-(NSString *)selectTodaySleepingStartTimeWithMemberId:(long long)memberId;

/**
 *  查询睡眠记录
 *
 *  @param memberId 用户id
 *
 *  @return 返回sleeping数组
 */
-(NSMutableArray *)selectSleepDetailArrayWithMemberId:(long long)memberId WithBelongSleepDate:(NSString *)belongSleepDate;

-(BOOL)mergeSleepingWakeupTimeTo:(NSTimeInterval)wakeupSleepTime WithLastSleepTime:(NSTimeInterval)lastSleepTime WithBelongId:(long long)belongId WithDuration:(NSInteger)duration;
@end
