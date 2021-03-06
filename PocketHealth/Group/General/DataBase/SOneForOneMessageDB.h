//
//  SOneForOneMessageDB.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneForOneMessage.h"
#import "SDBManager.h"


#import "Member.h"


@interface SOneForOneMessageDB : NSObject
{
    FMDatabase * _db;
}

- (void) createDataBase;

- (BOOL)saveMessage:(OneForOneMessage *) message WithUid:(long long)uid WithContactUid:(long long)otherUid;

-(void)deleteMessageWithUid:(long long)uid WithContactUid:(long long)otherUid;

- (void) mergeMessage:(OneForOneMessage *)message WithUid:(long long)uid WithContactUid:(long long)otherUid;

-(void)mergeNotReadMessageToReadMessageWithUid:(long long)uid WithContactUid:(long long)otherUid;

-(NSMutableArray *)selectMessageWithUid:(long long)uid WithContactUid:(long long)otherUid;

-(NSInteger)selectNotReadMessageCountWithUid:(long long)uid WithContactUid:(long long)otherUid;

-(NSInteger)selectNotReadMessageCountWithContactUid:(long long)uid;

//掌上健康新增
/**
 *  获取最后一条医院消息数据
 *
 *  @param hostId
 *
 *  @return 返回最后一条消息的详情
 */
-(OneForOneMessage *)selectLastMessageAboutMemberType:(MemberUserType)memberType WithSelectId:(long long)memberId WithContantUid:(long long)hostId;
//分页查询
-(NSMutableArray *)selectPrivateMessageWithMemberID:(long long)memberId WithContactUid:(long long)otherUid offsetIndex:(unsigned)offsetIndex;
//-(OneForOneMessage *)selectLastMessageAboutTheUid:(long long)uid WithContantUid:(long long)hostId;
-(NSInteger)selectNotReadMessageAboutHospitalCountWithContactUid:(long long)uid;
@end
