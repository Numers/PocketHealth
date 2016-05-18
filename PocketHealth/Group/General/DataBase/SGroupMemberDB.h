//
//  SGroupMemberDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupMember.h"
#import "SDBManager.h"


@interface SGroupMemberDB : NSObject
{
    FMDatabase * _db;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase;
/**
 * @brief 保存一条群组成员数据记录
 *
 * @param groupMember 需要保存的群组数据
 */
- (void) saveGroupMember:(GroupMember *) groupMember;

/**
 * @brief 删除一条群组成员数据
 *
 * @param groupMember 需要删除的群组成员
 */
- (void) deleteGroupMember:(GroupMember *)groupMember;

/**
 * @brief 修改群组成员的信息
 *
 * @param groupMember 需要修改的群组成员信息
 */
- (void) mergeGroupMember:(GroupMember *)groupMember;

- (void) mergeGroupMemberWithOutChatTime:(GroupMember *)groupMember;


-(NSMutableArray *)selectAllGroupMemberWithGid:(unsigned)gid;

-(GroupMember *)selectGroupMemberWithUid:(long long )uid WithGid:(unsigned)gid;

-(GroupMember *)selectGroupMemberInfo:(long long)uid;


-(BOOL)isExistGroupMemberWithUid:(long long )uid WithGid:(unsigned)gid;

@end
