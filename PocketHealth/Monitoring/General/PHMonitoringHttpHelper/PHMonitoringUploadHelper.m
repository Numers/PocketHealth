//
//  PHMonitoringUploadHelper.m
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMonitoringUploadHelper.h"
#import "PHMonitoringHttpRequest.h"
#import "JSONKit.h"
#import "SSleepingDB.h"
#import "SMonitorExerciseDB.h"
#import "CommonUtil.h"


#import "PHAppStartManager.h"

@implementation PHMonitoringUploadHelper


+(BOOL)uploadSleepDetail:(long long )hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    //从数据库取出所有未上传的睡眠数据
    SSleepingDB *ssleepingDB = [[SSleepingDB alloc]init];
    NSArray * unuploadArray =  [ssleepingDB selectAllUnUploadDate:hostId];
    NSMutableArray * sleepingAllArray = [[NSMutableArray alloc]init];
    for (Sleeping * sleeping in unuploadArray) {
        NSMutableDictionary * sleepingDic = [NSMutableDictionary dictionary];
        [sleepingDic setObject:[NSString stringWithFormat:@"%lld",sleeping.belongMemberId] forKey:@"userId"];
        
        NSString * sendSDsleepTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:sleeping.lastSleepTime];
        [sleepingDic setObject:sendSDsleepTime forKey:@"sdsleepTime"];
        NSString * sendUpSleepTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:sleeping.wakeupSleepTime];
        [sleepingDic setObject:sendUpSleepTime forKey:@"sdwakeupTime"];
        
        
        [sleepingDic setObject:[NSString stringWithFormat:@"%ld",(long)sleeping.sleepDuration] forKey:@"sdsleepDuration"];
        [sleepingDic setObject:sleeping.belongSleepDate forKey:@"sdBelongTime"];
        [sleepingAllArray addObject:[sleepingDic JSONString]];
    }
    
    if (sleepingAllArray.count != 0 ) {
        NSString * sendStr =  [CommonUtil jsonStringWithArray:sleepingAllArray];
        [PHMonitoringHttpRequest uploadSleepDetail:sendStr done:doneCallback error:errorCallback];
        return YES;
    }else{
        return NO;
    }
   
}
+(BOOL)uploadExerciseDetail:(long long)hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    //从数据库取出所有未上传的运动数据
    SMonitorExerciseDB *smExerciseDB = [[SMonitorExerciseDB alloc]init];
    NSArray * unuploadArray =[smExerciseDB selectUnUploadExerciseWithBelongId:hostId];
    NSMutableArray * exerciseAllArray = [[NSMutableArray alloc]init];
    for (Exercise * exercise in unuploadArray) {
        NSMutableDictionary * exerciseDic = [NSMutableDictionary dictionary];
        [exerciseDic setObject:[NSString stringWithFormat:@"%lld",exercise.belongMemberId] forKey:@"userId"];
        
        NSString * sendECreateTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:exercise.createTime];
        [exerciseDic setObject:sendECreateTime forKey:@"edcreateTime"];
        NSString * sendEDate = exercise.belongDateTime;
        [exerciseDic setObject:sendEDate forKey:@"edBelongDate"];
        
        
        [exerciseDic setObject:[NSString stringWithFormat:@"%ld",(long)exercise.steps] forKey:@"edSteps"];

        Member * host = [[PHAppStartManager defaultManager] userHost];
        [exerciseDic setObject:[NSString stringWithFormat:@"%ld",(long)host.calorie] forKey:@"edCaloricIntake"];
        [exerciseAllArray addObject:[exerciseDic JSONString]];
    }
    
    if (exerciseAllArray.count != 0 ) {
        NSString * sendStr =  [CommonUtil jsonStringWithArray:exerciseAllArray];
        [PHMonitoringHttpRequest uploadExerciseDetail:sendStr done:doneCallback error:errorCallback];
        return YES;
    }else{
        return NO;
    }
}
+(BOOL)uploadExercise_Mood_SleepingListWithMemberId:(long long)hostId  cancal:(void (^)(BOOL flag))cancal done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
//    NSString * sendStrExer;
    //从数据库取出所有未上传的运动数据
    SMonitorExerciseDB *smExerciseDB = [[SMonitorExerciseDB alloc]init];
    NSArray * unuploadArrayExer =[smExerciseDB selectUnUploadExerciseWithBelongId:hostId];
    NSMutableArray * exerciseAllArray = [[NSMutableArray alloc]init];
    for (Exercise * exercise in unuploadArrayExer) {
        NSMutableDictionary * exerciseDic = [NSMutableDictionary dictionary];
        [exerciseDic setObject:[NSString stringWithFormat:@"%lld",exercise.belongMemberId] forKey:@"userId"];
        
        NSString * sendECreateTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:exercise.createTime];
        [exerciseDic setObject:sendECreateTime forKey:@"edcreateTime"];
        
        
        
        NSString * sendEDate = exercise.belongDateTime;
        NSRange range = [sendEDate rangeOfString:@" "];
        if (range.length==0) {
            NSLog(@"非法数据 continue");
            continue;
        }
        sendEDate = [sendEDate substringToIndex:range.location];
        [exerciseDic setObject:sendEDate forKey:@"edBelongDate"];
        [exerciseDic setObject:[NSString stringWithFormat:@"%ld",(long)exercise.steps] forKey:@"edSteps"];
        Member * host = [[PHAppStartManager defaultManager] userHost];
        [exerciseDic setObject:[NSString stringWithFormat:@"%ld",(long)host.calorie] forKey:@"edCaloricIntake"];
        [exerciseAllArray addObject:exerciseDic ];
    }
//    if (exerciseAllArray.count!=0) {
//        sendStrExer =  [CommonUtil jsonStringWithArray:exerciseAllArray];
//    }
    
    
    
    //从数据库取出所有未上传的睡眠数据
//    NSString * sendStrSleeping;
    SSleepingDB *ssleepingDB = [[SSleepingDB alloc]init];
    NSArray * unuploadArraySleeping =  [ssleepingDB selectAllUnUploadDate:hostId];
    NSMutableArray * sleepingAllArray = [[NSMutableArray alloc]init];
    for (Sleeping * sleeping in unuploadArraySleeping) {
        NSMutableDictionary * sleepingDic = [NSMutableDictionary dictionary];
        [sleepingDic setObject:[NSString stringWithFormat:@"%lld",sleeping.belongMemberId] forKey:@"userId"];
        
        NSString * sendSDsleepTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:sleeping.lastSleepTime];
        [sleepingDic setObject:sendSDsleepTime forKey:@"sdsleepTime"];
        NSString * sendUpSleepTime = [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:sleeping.wakeupSleepTime];
        [sleepingDic setObject:sendUpSleepTime forKey:@"sdwakeupTime"];
        
        
        [sleepingDic setObject:[NSString stringWithFormat:@"%ld",(long)sleeping.sleepDuration] forKey:@"sdsleepDuration"];

        //进行修改 belongsleepdate 从 sleeptime进行转换 
//        [sleepingDic setObject:[CommonUtil TimeStrZeroWithTimerStr:sleeping.belongSleepDate] forKey:@"sdBelongTime"];
//        [sleepingDic setObject:[CommonUtil TimeStrZeroWithTimerStr:[CommonUtil TimeStrYYYYMMDDHHWithInterval:sleeping.lastSleepTime]] forKey:@"sdBelongTime"];
        [sleepingDic setObject:sleeping.belongSleepDate forKey:@"sdBelongTime"];
        [sleepingAllArray addObject:sleepingDic];
    }
//    if (sleepingAllArray.count != 0 ) {
//        sendStrSleeping =  [CommonUtil jsonStringWithArray:sleepingAllArray];
//    }
    
    //暂时没心情
    if (sleepingAllArray.count==0 && exerciseAllArray.count==0 ) {
        //block
        cancal(NO);
        return NO;
    }
    [PHMonitoringHttpRequest uploadExercise:exerciseAllArray MoodList:nil Sleeping:sleepingAllArray done:doneCallback error:errorCallback];

    
    return YES;

}
//+(void)uploadExercise:(NSString *)exerciseStr MoodList:(NSString *)moodStr Sleeping:(NSString *)sleepingStr done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
@end