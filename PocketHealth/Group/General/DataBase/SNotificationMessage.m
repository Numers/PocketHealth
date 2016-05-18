//
//  SNotificationMessage.m
//  AJKGroupChatDemo
//
//  Created by YangFan on 14/12/12.
//  Copyright (c) 2014年 YangFan. All rights reserved.
//

#import "SNotificationMessage.h"
#import "SFirendDB.h"

#define kNotificationMessageTableName @"SNotificationMessage"
#define kShowTimeTimeInterval 86400;

@implementation SNotificationMessage
- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
        
    }
    return self;
}

- (void)createDataBase
{
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kNotificationMessageTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kNotificationMessageTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql = @"CREATE TABLE SNotificationMessage (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, belongGroupId INTEGER, memberid BIGINT,contactmemberid BIGINT, createtime TIMESTAMP,sessiondate TIMESTAMP,messagecode INTEGER,recordid INTEGER, jointype VARCHAR(50),content VARCHAR(500) ,state INTEGER,headImg VARCHAR(50),nickname VARCHAR(50))";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kNotificationMessageTableName);
        } else {
            NSLog(@"%@数据库创建成功",kNotificationMessageTableName);
        }
    }
}

-(BOOL)saveNoticationMessage:(NotificationMessage *)notificationMsg HostId:(long long)hostId{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@",kNotificationMessageTableName];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:14];

    
    
    [keys appendString:@"contactmemberid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",hostId]];
    
    
    if (notificationMsg.memberId) {
        [keys appendString:@"memberid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lld",notificationMsg.memberId]];
    }
    if (notificationMsg.content) {
        [keys appendString:@"content,"];
        [values appendString:@"?,"];
        [arguments addObject:notificationMsg.content];
    }
    if (notificationMsg.belongGroupId) {
        [keys appendString:@"belongGroupId,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%u",notificationMsg.belongGroupId]];
    }
    if (notificationMsg.messageCode) {
        [keys appendString:@"messagecode,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%u",notificationMsg.messageCode]];
    }
    if (notificationMsg.createTime) {
        [keys appendString:@"createtime,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%f",notificationMsg.createTime]];
    }
    if (notificationMsg.sessionDate) {
        [keys appendString:@"sessiondate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%f",notificationMsg.sessionDate]];
    }
    if (notificationMsg.recordId) {
        [keys appendString:@"recordid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%u",notificationMsg.recordId]];
    }
    if (notificationMsg.joinType) {
        [keys appendString:@"jointype,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",notificationMsg.joinType]];
    }
    if (notificationMsg.headImg) {
        //headImg
        [keys appendString:@"headImg,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",notificationMsg.headImg]];
    }
    if (notificationMsg.nickName) {
        //nickname
        [keys appendString:@"nickname,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",notificationMsg.nickName]];
    }
    
    [keys appendString:@"state,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%u",notificationMsg.state]];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"notificationMsg query: %@",query);
    
    BOOL result = [_db executeUpdate:query withArgumentsInArray:arguments];
    result?NSLog(@"notificationMsg 插入一条数据"):NSLog(@"notificationMsg 插入错误");
    return result;
}
-(BOOL)mergeNotificaionState:(NotificationMessage *)notificaionMsg HostId:(long long)hostId{
    NSString * query = [NSString stringWithFormat:@"UPDATE SNotificationMessage SET state = '%d' WHERE memberid = '%lld' and contactmemberid = '%lld' and createtime = '%f' ",notificaionMsg.state,notificaionMsg.memberId,hostId,notificaionMsg.createTime];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"改变消息状态变成已读 更新了%ld条数据",(long)result);
    return result;
}
-(BOOL)mergeNotificaionStateHadSeeWithHostId:(long long)hostId{
    NSString * query = [NSString stringWithFormat:@"UPDATE SNotificationMessage SET state = '%d' WHERE contactmemberid = '%lld'  ",NotificationMessageStateHadSee,hostId];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"改变消息状态变成已读 更新了%ld条数据",(long)result);
    return result;
}
//查询数据库在一段时间内是否重复
-(BOOL)isTheNotificationMessageDuplicate:(NotificationMessage *)notificationMsg HostId:(long long )hostId{
    BOOL isShow = YES;
   NSString * query =[NSString stringWithFormat: @"SELECT * FROM SNotificationMessage WHERE contactmemberid = '%lld' and memberid = '%lld' ",notificationMsg.memberId,hostId];
    FMResultSet * rs = [_db executeQuery:query];
    NotificationMessage *resultMessage ;
    if ([rs next]) {
        resultMessage.content     = [rs stringForColumn:@"content"];
        resultMessage.createTime  = [rs doubleForColumn:@"createtime"];
        resultMessage.memberId    = [rs longLongIntForColumn:@"memberid"];
        resultMessage.messageCode = [rs intForColumn:@"messagecode"];
        resultMessage.sessionDate = [rs doubleForColumn:@"sessiondate"];
        resultMessage.recordId    = [rs intForColumn:@"recordid"];
        resultMessage.joinType    = [rs stringForColumn:@"jointype"];
        resultMessage.headImg    = [rs stringForColumn:@"headImg"];
        resultMessage.nickName    = [rs stringForColumn:@"nickname"];
        //
    }
    [rs close];
    if (resultMessage!=nil) {
        NSTimeInterval i  = notificationMsg.sessionDate - resultMessage.sessionDate;
        isShow = i < 86400 ? YES:NO;
    }
    
    return isShow;
}
-(NSArray *)selectAllNoticationMessageWithHostId:(long long)hostId MessageCode:(MessageCode)messageCode ResultCount:(int)count
{
    NSString *query = [NSString string];
    if (messageCode == 0) {
        //查询所有消息
        query =[NSString stringWithFormat: @"SELECT * FROM SNotificationMessage WHERE contactmemberid = '%lld' ORDER BY id DESC limit %u ",hostId,count];
    }else{
        query =[NSString stringWithFormat: @"SELECT * FROM SNotificationMessage WHERE contactmemberid = '%lld' and messagecode = '%u' ORDER BY id DESC limit %u ",hostId,messageCode,count];
    }
    
    
    
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        NotificationMessage *notificationMsg = [[NotificationMessage alloc]init];
        notificationMsg.belongGroupId = [rs intForColumn:@"belongGroupId"];
        
        //如果是群通知那么增加一些属性
        if (notificationMsg.belongGroupId) {
            

        }
        notificationMsg.content     = [rs stringForColumn:@"content"];
        notificationMsg.createTime  = [rs doubleForColumn:@"createtime"];
        notificationMsg.memberId    = [rs longLongIntForColumn:@"memberid"];
        notificationMsg.messageCode = [rs intForColumn:@"messagecode"];
        notificationMsg.sessionDate = [rs doubleForColumn:@"sessiondate"];
        notificationMsg.recordId    = [rs intForColumn:@"recordid"];
        notificationMsg.joinType    = [rs stringForColumn:@"jointype"];
        notificationMsg.state       = [rs intForColumn:@"state"];
        notificationMsg.headImg    = [rs stringForColumn:@"headImg"];
        notificationMsg.nickName    = [rs stringForColumn:@"nickname"];
        //
        //查询member数据库 取出member数据
        
        SFirendDB * sfriendDB = [[SFirendDB alloc]init];
        notificationMsg.member = [sfriendDB selectUserWithUid:notificationMsg.memberId WithBelongUid:hostId];
        [array addObject:notificationMsg];
    }
    [rs close];
    return array;
}
-(NSInteger)selectNotifcationNoHandleWithHostId:(long long)hostId{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SNotificationMessage WHERE contactmemberid = '%lld' and  state = '%d'",hostId,NotificationMessageStateUnHandle];
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    NSInteger result = 0;
    while ([rs next]) {
        result++;
    }
    NSLog(@"查到%ld条数据",(long)result);
    return result;
}
-(NotificationMessage *)selectLastNotificaionMessageWithHostId:(long long)hostId{
    //搜索数据库 消息的最后一条 无论群消息还是好友
    NSString * query =[NSString stringWithFormat: @"SELECT * FROM SNotificationMessage WHERE contactmemberid = '%lld' ORDER BY id DESC limit 1",hostId];
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    
    NotificationMessage *notificationMsg ;
     while ([rs next]) {
         notificationMsg = [[NotificationMessage alloc]init];
         notificationMsg.belongGroupId = [rs intForColumn:@"belongGroupId"];
         
         //如果是群通知那么增加一些属性
         if (notificationMsg.belongGroupId) {
             
             
         }
         notificationMsg.content     = [rs stringForColumn:@"content"];
         notificationMsg.createTime  = [rs doubleForColumn:@"createtime"];
         notificationMsg.memberId    = [rs longLongIntForColumn:@"memberid"];
         notificationMsg.messageCode = [rs intForColumn:@"messagecode"];
         notificationMsg.sessionDate = [rs doubleForColumn:@"sessiondate"];
         notificationMsg.recordId    = [rs intForColumn:@"recordid"];
         notificationMsg.joinType    = [rs stringForColumn:@"jointype"];
         notificationMsg.state       = [rs intForColumn:@"state"];
         notificationMsg.headImg    = [rs stringForColumn:@"headImg"];
         notificationMsg.nickName    = [rs stringForColumn:@"nickname"];
         //再从数据库中取出之前存入的member对象
         SFirendDB * sfriend = [[SFirendDB alloc]init];
         Member * notifiMember = [sfriend selectUserWithUid:notificationMsg.memberId WithBelongUid:hostId];
         notificationMsg.member = notifiMember;
     }
    [rs close];
    return notificationMsg;
}

-(BOOL)deleteFriendNotificaionWithSelectedMember:(long long)memberId{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SNotificationMessage WHERE contactmemberid = '%lld' and  belongGroupId is null",memberId];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@" 删除了%ld条数据",(long)result);
    return result;
}
-(BOOL)deleteGroupNotificaionWithSelectedMember:(long long)memberId{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SNotificationMessage WHERE contactmemberid = '%lld' and  belongGroupId is not null",memberId];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@" 删除了%ld条数据",(long)result);
    return result;
}
@end