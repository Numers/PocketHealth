//
//  PHMonitoringHttpRequest.h
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"

@interface PHMonitoringHttpRequest : NSObject

+(void)uploadSleepDetail:(NSString *)jsonData done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

+(void)uploadExerciseDetail:(NSString *)jsonData done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
+(void)uploadExercise:(NSArray *)exerciseStr MoodList:(NSArray *)moodStr Sleeping:(NSArray *)sleepingStr done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//从服务器获取我的3项目得分
+(void)requestMySocreDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

+(void)requestCalorieListFromServerDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
@end
