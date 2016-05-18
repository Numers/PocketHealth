//
//  PHGroupHttpRequest.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
#import "Member.h"
#import "CommonUtil.h"
#import "Group.h"

@interface PHGroupHttpRequest : NSObject

//请求自己的群列表
+(void)requestSelfGroupLsitDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//请求自己的好友列表 包括医院
+(void)requestUserFirendListWithType:(NSInteger)selectType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//搜索好友
+(void)searchAllUserOnHttpServerWith:(NSString *)searchString done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//加谁为好友
+(void)requestAddAnFriend:(long long)toid WithMemberType:(MemberUserType)userType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//请求单个群用户的用户详情
+(void)requestMemberInfo:(long long)hostId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//申请加群
+(void)requestAddGroup:(unsigned)gid WithMemberId:(long long)memberId WithTag:(NSString *)tag done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//发起退群 PH_Delete_GroupUser
+(void)requestDeleteUserWith:(unsigned)gid WithDeletedId:(long long)memberId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//搜索医院
+(void)searchAllHospitalOnHttpServerWith:(NSString *)searchString done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//请求附近医院
+(void)requestNearByHospitalWithLat:(double)lat lon:(double)lon done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//添加城市列表
+(void)searchAllCityListDone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//上传图片
+(void)uploadMessageFileWithFileName:(NSString *)name WithUIImage:(UIImage *)image WithSendMessage:(OneForOneMessage *)message completeHandle:(ApiCompletionHandler)completBlock;
//上传语音
+(void)uploadMessageVoiceWithFileName:(NSString *)name completeHandle:(ApiCompletionHandler)completBlock;

//查询指定群所有用户
+(void)requestAllGroupUsersWithGid:(unsigned)gid done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//删除群中指定用户
+(void)deleteUserFromBarWithDeleteUid:(long long)memberId WithGid:(unsigned)gid done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//管理员允许谁加入群了
+(void)adminAcptGroupUserWithRecordid:(unsigned)rid toDo:(joinToDoType)joinat done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//查找热门类型
+(void)searchHopTypeGroupWithdone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//感兴趣的群
+(void)searchInterestBarWithdone:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//根据cityid获取医院列表
+(void)requestCityHospitalWithCityId:(NSInteger )cityId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
/// 根据群分类查询群列表
+(void)requestBarListByTypeId:(unsigned)typeId done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;

//删除好友
+(void)deleteUserWithMemberId:(long long)memberId  done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;
//设置为管理员
+(void)settingGroupAdminOperateId:(long long)memberId WithGroupId:(unsigned)gid OperateType:(unsigned)oType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback;


#pragma mark - 对获取的数据进行处理
+(void)mergeGroupAndGroupMemberDBWithDic:(NSDictionary *)dic WithBeforeGroup:(Group *)beforeGroup WithMemberID:(long long)memberID;

@end
