//
//  PHFindDoctorsManager.h
//  PocketHealth
//
//  Created by macmini on 15-3-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHFindDoctorsManager : NSObject
+(id)defaultManager;
-(void)requestDoctorListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)setDoctorOnCallState:(long)doctorId SessionId:(long long)sessionId CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)finishCallWithIid:(NSInteger)iid fromUserId:(long long)fromUserId ToUserId:(long long)toUserId WithSessionId:(long long)sessionId WithSeconds:(NSInteger)seconds WithCommentScore:(NSInteger)score CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
