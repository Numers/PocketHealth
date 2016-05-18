//
//  PHGetMemberInfoManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
#import "Member.h"

@interface PHGetMemberInfoManager : NSObject
+(id)defaultManager;
//请求单个群用户的用户详情
-(void)requestMemberInfo:(long long)hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
-(void)requestFriendListWithMemberType:(MemberUserType)userType CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)requestGroupByUserId:(long long)userId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
@end
