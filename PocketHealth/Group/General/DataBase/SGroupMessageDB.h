//
//  SGroupMessageDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "GroupMessage.h"

@interface SGroupMessageDB : NSObject
{
    FMDatabase * _db;
    FMDatabaseQueue *queue;

}

/**
 * @brief 创建数据库
 */
- (void) createDataBase;
/**
 * @brief 保存一条用户记录
 *
 * @param Message 需要保存的用户数据
 * @param otherUid 消息的从属otherUid
 */
- (void)saveGroupMessage:(GroupMessage *) message WithContactUid:(long long)otherUid;

-(void)deleteGroupMessageWithGid:(unsigned)gid WithContactUid:(long long)otherUid;

- (void) mergeGroupMessage:(GroupMessage *)message WithContactUid:(long long)otherUid;

-(void)mergeNotReadMessageToReadMessageWithGid:(unsigned)gid WithContactUid:(long long)otherUid;
-(void)mergeMessageStateIsSendingToFaildWithGid:(unsigned)gid WithContactUid:(long long)otherUid;


-(NSMutableArray *)selectGroupMessageWithGid:(unsigned)gid WithContactUid:(long long)otherUid;
-(NSMutableArray *)selectGroupMessageWithGid:(unsigned)gid WithContactUid:(long long)otherUid offsetIndex:(unsigned)offsetIndex;


-(NSInteger)selectNotReadMessageCountWithGid:(unsigned)gid WithContactUid:(long long)otherUid;
-(NSInteger)selectNotReadMessageCountWithContactUid:(long long)uid;

-(NSMutableArray *)selectGroupMessageNotificationTpyeWithGid:(unsigned)gid WithContactUid:(long long)otherUid WithMessageCode:(MessageCode)code;

-(NSInteger)selectNotReadJoinGroupMessageCountWithContactGid:(unsigned)gid Uid:(long long)otherUid;


//取出所有的未读的加群消息
//-(NSMutableArray *)selectGroupJoinMessageNotReadWithGid:(unsigned)gid Uid:(long long)uid;

-(void)selectGroupJoinMessageNotReadWithGid:(unsigned)gid Uid:(long long)otherUid;

//掌上健康新增功能
//获取最后一条群消息
-(GroupMessage *)selectLastGroupMessageInAllGroupWithHostId:(long long)hostId;

//-(void) inDateBase :(void(^)(FMDatabase *db))queueBlock;
@end
