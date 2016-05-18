//
//  PHMonitoringHttpRequest.m
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMonitoringHttpRequest.h"
#import "PHAppStartManager.h"
#import "JSONKit.h"


@implementation PHMonitoringHttpRequest

+(void)uploadSleepDetail:(NSString *)jsonData done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    NSString *urlStr=[NSString stringWithFormat:PH_Monitoring_UploadSleepDetail];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *httpKey = [[[PHAppStartManager defaultManager] userHost]getHttpKey];
    NSDictionary *parameters =[[NSDictionary alloc]initWithObjectsAndKeys:httpKey,@"key",jsonData,@"data", nil];
    [manager POST:urlStr  parameters:parameters success: doneCallback failure:errorCallback];

}
+(void)uploadExerciseDetail:(NSString *)jsonData done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    NSString *urlStr=[NSString stringWithFormat:PH_Monitoring_UploadExerciseDetails];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *httpKey = [[[PHAppStartManager defaultManager] userHost]getHttpKey];
    NSDictionary *parameters =[[NSDictionary alloc]initWithObjectsAndKeys:httpKey,@"key",jsonData,@"data", nil];
    [manager POST:urlStr  parameters:parameters success: doneCallback failure:errorCallback];
}
+(void)uploadExercise:(NSArray *)exerciseStr MoodList:(NSArray *)moodStr Sleeping:(NSArray *)sleepingStr done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    
    if (exerciseStr==nil) {
        exerciseStr = [NSArray array];
    }
    if (moodStr==nil) {
        moodStr =[NSArray array];
    }
    if (sleepingStr==nil) {
        sleepingStr=[NSArray array];
    }

    NSDictionary * dataDic = [NSDictionary dictionaryWithObjectsAndKeys:exerciseStr,@"ExerciseList", moodStr,@"MoodList",sleepingStr,@"SleepingList",nil];
    
    NSString *urlStr=[NSString stringWithFormat:PH_Monitroing_AllDataUpdata];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:TimeOut];
    NSString *httpKey = [[[PHAppStartManager defaultManager] userHost]getHttpKey];
    NSDictionary *parameters =[[NSDictionary alloc]initWithObjectsAndKeys:httpKey,@"key",[dataDic JSONString],@"datastr", nil];
    

    
    [manager POST:urlStr  parameters:parameters success: doneCallback failure:errorCallback];
    
}
// 返回我的所有得分
+(void)requestMySocreDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    NSString *urlStr=[NSString stringWithFormat:PH_Get_MyHealthData];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:TimeOut];
    NSString *httpKey = [[[PHAppStartManager defaultManager] userHost]getHttpKey];
    NSDictionary *parameters =[[NSDictionary alloc]initWithObjectsAndKeys:httpKey,@"key", nil];
    [manager POST:urlStr  parameters:parameters success: doneCallback failure:errorCallback];
}

+(void)requestCalorieListFromServerDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
    //PH_GetFoodList
    NSString *urlStr=[NSString stringWithFormat:PH_GetFoodList];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:TimeOut];
//    NSString *httpKey = [[[PHAppStartManager defaultManager] userHost]getHttpKey];
//    NSDictionary *parameters =[[NSDictionary alloc]initWithObjectsAndKeys:httpKey,@"key", nil];
    [manager POST:urlStr  parameters:nil success: doneCallback failure:errorCallback];
}
@end
