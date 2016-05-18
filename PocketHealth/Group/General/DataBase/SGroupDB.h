//
//  SGroupDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "Group.h"

@interface SGroupDB : NSObject
{
    FMDatabase * _db;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase;
/**
 * @brief 保存一条群组记录
 *
 * @param group 需要保存的群组数据
 */
- (void) saveGroup:(Group *) group;

/**
 * @brief 删除一条群组数据
 *
 * @param group 需要删除的群组
 */
- (void) deleteGroup:(Group *)group;
//
///**
// *  删除所有该用户数据
// *
// *  @param belongUid 用户id
// */
//-(void)deleteAllGroupWithBelongId:(long long)belongUid;
/**
 * @brief 修改群组的信息
 *
 * @param group 需要修改的群组信息
 */
- (void) mergeGroup:(Group *)group;

-(NSMutableArray *)selectSessionGroupWithBelongUid:(long long)belongUid;

-(NSMutableArray *)selectAllGroupWithBelongId:(long long)belongUid;

-(Group *)selectGroupWithGid:(unsigned)gid WithBelongUid:(long long)belongUid;

-(BOOL)isExistGroupWithGid:(unsigned)gid WithBelongUid:(long long)belongUid;
@end
