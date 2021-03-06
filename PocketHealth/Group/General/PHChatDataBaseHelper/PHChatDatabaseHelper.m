//
//  PHChatDatabaseHelper.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHChatDatabaseHelper.h"
#import "Member.h"
#import "SFirendDB.h"
#import "PHAppStartManager.h"
#import "SGroupDB.h"
#import "Group.h"
#import "SNotificationMessage.h"


@implementation PHChatDatabaseHelper

+(void)saveMyAllFriendListToDb:(id)responseObject{
    //1.获取字典
    NSDictionary *dic = (NSDictionary *)responseObject;
    int code = [[dic objectForKey:@"Code"]intValue];
    if ( code  == 1) {
        NSArray * resultArray = [dic objectForKey:@"Result"];
        SFirendDB * sfirend = [[SFirendDB alloc]init];
        
        for (NSDictionary *memberDic  in resultArray) {
            //字典模型转换
            NSError * error ;
            Member * member = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:memberDic error:&error];
            if (!error) {
                long long hostid =[[PHAppStartManager defaultManager] userHost].memberId;
                //判断是否存在好友
                if (![sfirend isExistMemberWithUid:member.memberId WithBelongUid:hostid]) {
                    [sfirend saveUser:member WithBelongUid:hostid];
                    NSLog(@"用户好友 数据库中插入一条数据");
                }else{
                    //此处不更新session 字段 ——————————————
                    Member *tmpMember = [sfirend selectUserWithUid:member.memberId WithBelongUid:hostid];
                    member.isSession = tmpMember.isSession;
                    //-----------------------------------
                    [sfirend mergeWithUser:member WithBelongUid:hostid];
                    NSLog(@"用户好友 数据库中更新一条数据");
                }
            }else{
                NSLog(@"数据错误，返回");
            }
        }
    }else{
        NSLog(@"请求好友列表错误");
    }
    
}
+(void)saveMyGroupListToDb:(id)responseObject{
    //1.获取字典
    NSDictionary *dic = (NSDictionary *)responseObject;
    int code = [[dic objectForKey:@"Code"]intValue];
    if ( code  == 1) {
        NSArray * resultArray = [dic objectForKey:@"Result"];
        SGroupDB * sgroupdb = [[SGroupDB alloc]init];
        
        NSMutableArray * serviceArray = [[NSMutableArray alloc]init];
        for (NSDictionary *groupdic  in resultArray) {
            //字典模型转换
            NSError * error ;
            Group * group = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:groupdic error:&error];
            [serviceArray addObject:group];
            if (!error) {
                long long hostid =[[PHAppStartManager defaultManager] userHost].memberId;
                //判断是否存在群
                if (![sgroupdb isExistGroupWithGid:group.groupId WithBelongUid:hostid]) {
                    [sgroupdb saveGroup:group];
//                        Group * g =[sgroupdb selectGroupWithGid:group.groupId WithBelongUid:hostid];
                    NSLog(@"群组 数据库中插入一条数据");
                }else{
                    [sgroupdb mergeGroup:group];
                    NSLog(@"群组 数据库中更新一条数据");
                }
            }else{
                NSLog(@"数据错误，返回");
            }
        }
        long long hostid =[[PHAppStartManager defaultManager] userHost].memberId;
        //处理错误量
        NSArray * allGroup = [sgroupdb selectAllGroupWithBelongId:hostid];
        NSMutableArray * groupIdArray = [NSMutableArray array];
        for (Group * tmpGroup in serviceArray) {
            [groupIdArray addObject:[NSNumber numberWithInt:tmpGroup.groupId]];
        }
        
        NSPredicate *deleteDuplicate = [NSPredicate predicateWithFormat:@"NOT (SELF.groupId IN  %@)",groupIdArray];
        NSArray * resultFilterArray = [allGroup filteredArrayUsingPredicate:deleteDuplicate];
        if (resultFilterArray!=nil) {
            for (Group * group in resultFilterArray) {
                [sgroupdb deleteGroup:group];
            }
        }
    }else{
        NSLog(@"请求群组数据网络错误");
    }
    
}

+(void)reloadMyGroupListToDb:(id)responseObject{
    //1.获取字典
    NSDictionary *dic = (NSDictionary *)responseObject;
    int code = [[dic objectForKey:@"Code"]intValue];
    if ( code  == 1) {
        NSArray * resultArray = [dic objectForKey:@"Result"];
        SGroupDB * sgroupdb = [[SGroupDB alloc]init];
//        NSMutableArray * serviceArray = [[NSMutableArray alloc]init];
        long long hostid =[[PHAppStartManager defaultManager] userHost].memberId;
        
        
        NSMutableArray * serverArray = [[NSMutableArray alloc]init];
        //处理增量
        for (NSDictionary *groupdic  in resultArray) {
            //字典模型转换
            NSError * error ;
            Group * group = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:groupdic error:&error];
            if (!error) {
                if (![sgroupdb isExistGroupWithGid:group.groupId WithBelongUid:hostid]) {
                    [sgroupdb saveGroup:group];
                }else{
                    [sgroupdb mergeGroup:group];
                }
                [serverArray addObject:group];
            }
        }
        //处理错误量
        NSArray * allGroup = [sgroupdb selectAllGroupWithBelongId:hostid];
        NSMutableArray * groupIdArray = [NSMutableArray array];
        for (Group * tmpGroup in serverArray) {
            [groupIdArray addObject:[NSNumber numberWithInt:tmpGroup.groupId]];
        }
        
        NSPredicate *deleteDuplicate = [NSPredicate predicateWithFormat:@"NOT (SELF.groupId IN  %@)",groupIdArray];
        NSArray * resultFilterArray = [allGroup filteredArrayUsingPredicate:deleteDuplicate];
        if (resultFilterArray!=nil) {
            for (Group * group in resultFilterArray) {
                [sgroupdb deleteGroup:group];
            }
        }
        
    }else{
        NSLog(@"请求群组数据网络错误");
    }
    
}

#pragma mark - 删除聊天消息
+(BOOL)deleteFriendNotification{
    SNotificationMessage * snoMsg = [[SNotificationMessage alloc]init];
    long long hostID= [[PHAppStartManager defaultManager]userHost].memberId;
    return [snoMsg deleteFriendNotificaionWithSelectedMember:hostID];
}
+(BOOL)deleteGroupNotification{
    SNotificationMessage * snoMsg = [[SNotificationMessage alloc]init];
    long long hostID= [[PHAppStartManager defaultManager]userHost].memberId;
    return [snoMsg deleteGroupNotificaionWithSelectedMember:hostID];
}
@end
