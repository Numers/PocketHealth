//
//  SMonitorExerciseDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "Exercise.h"


@interface SMonitorExerciseDB : NSObject
{
    FMDatabase * _db;
}
/**
 *  创建数据库
 */
- (void) createDataBase;
/**
 * @brief 保存一条锻炼记录
 *
 * @param exercies 需要锻炼数据
 */
- (BOOL) saveMonitorExercise:(Exercise *) exercise;

-(BOOL)mergeMonitorExercise : (Exercise *)exercise;
    /**
 * @brief 查询一条锻炼记录
 *
 * @param belongid 查询锻炼数据
 */
-(NSArray *) selectMointorExerciseWithBelongId:(long long)hostId;

-(NSArray *) selectUnUploadExerciseWithBelongId:(long long)hostId;

-(BOOL)mergeUnUploadExerciseToUploaded:(long long)hostId;

-(BOOL)isExistTheSameBelongDate:(NSString *)belongDateTime WithMemberId:(long long)hostId;

-(BOOL)mergeLastStepsRecordWithBelongId:(long long )hostId WithSteps:(NSInteger )steps WithBelongDateTime:(NSString *)belongDateTime;
/**
 *  取出指定人指定天的步数
 *
 *  @param hostId         memberid
 *  @param belongDataTime "YYYY-MM-DD"
 *
 *  @return 返回今天步数
 */
-(NSInteger )selectTodayStepsWithMemberId:(long long)hostId WithDataTime:(NSString *)belongDateTime;

///**
// *  保存每小时的步伐数据
// *
// *  @param steps      步伐 累加型
// *  @param createTime 开启时间
// *  @param memberId   用户id
// *
// *  @return 返回是否保存成功
// */
//-(BOOL)saveEveryHourSteps:(NSString *)steps WithCreateTime:(NSTimeInterval)createTime WithMemberId:(long long)memberId;

@end
