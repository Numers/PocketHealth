//
//  PHFindDoctorsManager.m
//  PocketHealth
//
//  Created by macmini on 15-3-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHFindDoctorsManager.h"
static PHFindDoctorsManager *phFindDoctorsManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHFindDoctorsManager
+(id)defaultManager
{
    if (phFindDoctorsManager == nil) {
        phFindDoctorsManager = [[PHFindDoctorsManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phFindDoctorsManager;
}

-(void)requestDoctorListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_SearchDoctors_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:AFNetWorkKey,@"key",nil];
    [requestManager GET:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(void)setDoctorOnCallState:(long)doctorId SessionId:(long long)sessionId CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_SetDoctorOnCallState_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",doctorId],@"doctorid",[NSString stringWithFormat:@"%lld",sessionId],@"sessionid",AFNetWorkKey,@"key",nil];
    [requestManager GET:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(void)finishCallWithIid:(NSInteger)iid fromUserId:(long long)fromUserId ToUserId:(long long)toUserId WithSessionId:(long long)sessionId WithSeconds:(NSInteger)seconds WithCommentScore:(NSInteger)score CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_FinishCall_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",toUserId],@"called",[NSString stringWithFormat:@"%lld",fromUserId],@"caller",[NSString stringWithFormat:@"%ld",(long)iid],@"iid",[NSString stringWithFormat:@"%lld",sessionId],@"sessionid",[NSString stringWithFormat:@"%ld",(long)score],@"score",[NSString stringWithFormat:@"%ld",(long)seconds],@"seconds",AFNetWorkKey,@"key",nil];
    [requestManager GET:url parameters:parameters success:calldoneBack failure:callErrorBack];

}
@end
