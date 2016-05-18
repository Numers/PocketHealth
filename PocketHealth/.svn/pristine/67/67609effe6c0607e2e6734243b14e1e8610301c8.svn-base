//
//  PHMonitoringUploadHelper.h
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHMonitoringUploadHelper : NSObject

+(BOOL)uploadSleepDetail:(long long )hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

+(BOOL)uploadExerciseDetail:(long long)hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

+(BOOL)uploadExercise_Mood_SleepingListWithMemberId:(long long)hostId cancal:(void (^)(BOOL flag))cancal done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
@end
