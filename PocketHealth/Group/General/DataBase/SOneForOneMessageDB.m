//
//  SOneForOneMessageDB.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "SOneForOneMessageDB.h"
#import "SFirendDB.h"

#define kOneForOneMessageTableName @"SOneForOneMessage"

@implementation SOneForOneMessageDB
- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
        
    }
    return self;
}
- (void) createDataBase
{
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kOneForOneMessageTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kOneForOneMessageTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql = @"CREATE TABLE SOneForOneMessage (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, memberid BIGINT,contactmemberid BIGINT, icon VARCHAR(50),time TIMESTAMP, content VARCHAR(500),nickname VARCHAR(50), type INTEGER, code INTEGER, contentType INTEGER,state INTEGER, readstate INTEGER , msgsn INTEGER)";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kOneForOneMessageTableName);
        } else {
            NSLog(@"%@数据库创建成功",kOneForOneMessageTableName);
        }
    }
    
}
- (BOOL) saveMessage:(OneForOneMessage *) message WithUid:(long long)uid WithContactUid:(long long)otherUid
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO SOneForOneMessage"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:20];
    
    [keys appendString:@"memberid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",uid]];
    
    [keys appendString:@"contactmemberid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",otherUid]];
    
    if (message.icon) {
        [keys appendString:@"icon,"];
        [values appendString:@"?,"];
        [arguments addObject:message.icon];
    }
    if (message.MsgSN) {
        [keys appendString:@"msgsn,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)message.MsgSN]];
    }

    if (message.time) {
        [keys appendString:@"time,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",message.time]];
    }
    
    if (message.content) {
        [keys appendString:@"content,"];
        [values appendString:@"?,"];
        [arguments addObject:message.content];
    }
    
    if (message.nickName) {
        [keys appendString:@"nickname,"];
        [values appendString:@"?,"];
        [arguments addObject:message.nickName];
    }
    
    [keys appendString:@"type,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",message.type]];
    
    //contentType
    
    [keys appendString:@"contentType,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",message.contentType]];
    
    [keys appendString:@"code,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",message.code]];
    
    [keys appendString:@"state,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",message.state]];
    
    [keys appendString:@"readstate,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",message.readState]];
    
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    
    BOOL flag = [_db executeUpdate:query withArgumentsInArray:arguments];
    flag?NSLog(@"插入一条 Message 数据 成功" ):NSLog(@"插入一条 Message 数据 失败");
    return flag;
}

-(void)deleteMessageWithUid:(long long)uid WithContactUid:(long long)otherUid
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SOneForOneMessage WHERE memberid = '%lld' and contactmemberid = '%lld'",uid,otherUid];
    NSLog(@"删除一条数据");
    [_db executeUpdate:query];
}

- (void) mergeMessage:(OneForOneMessage *)message WithUid:(long long)uid WithContactUid:(long long)otherUid
{
    NSString * query = @"UPDATE SOneForOneMessage SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:100];
    // xxx = xxx;
    if (message.icon) {
        [temp appendFormat:@" icon = '%@',",message.icon];
    }
    if (message.time) {
        [temp appendFormat:@" time = '%f',",message.time];
    }
    
    if (message.content) {
        [temp appendFormat:@" content = '%@',",message.content];
    }
    
    if (message.nickName) {
        [temp appendFormat:@" nickname = '%@',",message.nickName];
    }
    
    [temp appendFormat:@" type = '%d',",message.type];
    [temp appendFormat:@" code = '%d',",message.code];
    [temp appendFormat:@" state = '%d',",message.state];
    [temp appendFormat:@" readstate = '%d',",message.readState];
    [temp appendFormat:@" contentType = '%d',",message.contentType];
    
    [temp appendFormat:@" msgsn = '%ld',",(long)message.MsgSN];
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE memberid = '%lld' and contactmemberid = '%lld' and time = '%f'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],uid,otherUid,message.time];
    NSLog(@"%@",query);
    NSLog(@"修改一条数据");
    [_db executeUpdate:query];
    
}

-(void)mergeNotReadMessageToReadMessageWithUid:(long long)uid WithContactUid:(long long)otherUid
{
    //语音不进行修改
//    NSString * query = [NSString stringWithFormat:@"UPDATE SOneForOneMessage SET readstate = '%d' WHERE memberid = '%lld' and contactmemberid = '%lld' and readstate = '%d' and contentType <> 1",MessageRead,uid,otherUid,MessageNotRead];
    NSString * query = [NSString stringWithFormat:@"UPDATE SOneForOneMessage SET readstate = '%d' WHERE memberid = '%lld' and contactmemberid = '%lld' and readstate = '%d'",MessageNotClickButSee,uid,otherUid,MessageNotRead];
    
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"更新了%ld条数据",(long)result);
}

-(NSMutableArray *)selectMessageWithUid:(long long)uid WithContactUid:(long long)otherUid
{
    NSString * query =[NSString stringWithFormat: @"SELECT * FROM (SELECT * FROM SOneForOneMessage WHERE memberid = '%lld' and contactmemberid = '%lld' ORDER BY id DESC limit 10) AS temp ORDER BY id ASC",uid,otherUid];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        OneForOneMessage *message = [[OneForOneMessage alloc] init];
        message.contentType=[rs intForColumn:@"contentType"];
        message.code = [rs intForColumn:@"code"];
        
        if ((message.code==MessageCodeJoinGroup)||(message.contentType==MessageContentAddGroupMember)||(message.contentType==MessageContentRemoveGroupMember)) {
            continue;
        }
        message.type = [rs intForColumn:@"type"];
        message.memberId = [rs longForColumn:@"memberid"];
        message.icon = [rs stringForColumn:@"icon"];
        message.time = [rs doubleForColumn:@"time"];
        message.content = [rs stringForColumn:@"content"];
        message.state = [rs intForColumn:@"state"];
        message.readState = [rs intForColumn:@"readstate"];
        message.nickName=[rs stringForColumn:@"nickname"];
        message.MsgSN = [rs intForColumn:@"msgsn"];
        [array addObject:message];
    }
    [rs close];
    return array;
}

-(NSInteger)selectNotReadMessageCountWithUid:(long long)uid WithContactUid:(long long)otherUid
{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SOneForOneMessage WHERE memberid = '%lld' and contactmemberid = '%lld' and readstate = '%d'",uid,otherUid,MessageNotRead];
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    NSInteger result = 0;
    while ([rs next]) {
        result++;
    }
    [rs close];
    NSLog(@"查到%ld条数据",(long)result);
    return result;
    
}
-(NSInteger)selectNotReadMessageCountWithContactUid:(long long)uid
{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SOneForOneMessage WHERE contactmemberid = '%lld' and  readstate = '%d'",uid,MessageNotRead];
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    NSInteger result = 0;
    while ([rs next]) {
        result++;
    }
    NSLog(@"查到%ld条数据",(long)result);
    return result;
}

-(NSInteger)selectNotReadMessageAboutHospitalCountWithContactUid:(long long)uid
{
    NSString * query = [NSString stringWithFormat:@"select * from SOneForOneMessage s left join SFriend sf on s.memberid=sf.memberid where sf.usertype= '%u' and s.contactmemberid= '%lld' and readstate = '%u' ",MemberUserTypeAdmin,uid,MessageNotRead];
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    NSInteger result = 0;
    while ([rs next]) {
        result++;
    }
    NSLog(@"查到%ld条数据",(long)result);
    return result;
}
#pragma mark -  掌上健康获取最后一条membertype数据  (user可以指定特殊用户
-(OneForOneMessage *)selectLastMessageAboutMemberType:(MemberUserType)memberType WithSelectId:(long long)memberId WithContantUid:(long long)hostId{
    //搜索数据库 用户类型是 2 （医院号） 的消息的最后一条
    NSString * query ;
    if (memberType == MemberUserTypeAdmin && memberId==0) {
        
        query =[NSString stringWithFormat: @"select * from SOneForOneMessage s left join SFriend sf on s.memberid=sf.memberid where sf.usertype= %u and s.contactmemberid='%lld' order by time desc limit 1",MemberUserTypeAdmin,hostId];
    }else{
        query =[NSString stringWithFormat: @"SELECT * FROM SOneForOneMessage WHERE type = '%u' and memberid = '%lld' and contactmemberid = '%lld' ORDER BY id DESC limit 1",memberType,memberId,hostId];
    }
    NSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    OneForOneMessage *message;
    while ([rs next]) {
        message = [[OneForOneMessage alloc] init];
        message.contentType=[rs intForColumn:@"contentType"];
        message.code = [rs intForColumn:@"code"];
        
        if ((message.code==MessageCodeJoinGroup)||(message.contentType==MessageContentAddGroupMember)||(message.contentType==MessageContentRemoveGroupMember)) {
            continue;
        }
        message.type = [rs intForColumn:@"type"];
        message.memberId = [rs longForColumn:@"memberid"];
        message.icon = [rs stringForColumn:@"icon"];
        message.time = [rs doubleForColumn:@"time"];
        message.content = [rs stringForColumn:@"content"];
        message.state = [rs intForColumn:@"state"];
        message.readState = [rs intForColumn:@"readstate"];
        message.nickName=[rs stringForColumn:@"nickname"];
        message.MsgSN = [rs intForColumn:@"msgsn"];
        [resultArray addObject:message];
    }
//    NSLog(@"%@",resultArray);
    for (OneForOneMessage *oneMsg in resultArray) {
        NSLog(@"%@",oneMsg);
    }
    [rs close];
    return message;
    
}
-(NSMutableArray *)selectPrivateMessageWithMemberID:(long long)memberId WithContactUid:(long long)hostId offsetIndex:(unsigned)offsetIndex{
    NSString * query =[NSString stringWithFormat: @"SELECT * FROM ( SELECT * FROM SOneForOneMessage WHERE memberid = '%lld' and contactmemberid = '%lld' ORDER BY time DESC limit 10 offset %u) AS bieming ORDER BY time ASC  ",memberId,hostId,offsetIndex];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        OneForOneMessage *message = [[OneForOneMessage alloc] init];
        message.memberId = [rs longLongIntForColumn:@"memberid"];
        
        message.icon = [rs stringForColumn:@"icon"];
        message.time = [rs doubleForColumn:@"time"];
        message.code = [rs intForColumn:@"code"];
        message.content = [rs stringForColumn:@"content"];
        message.nickName = [rs stringForColumn:@"nickname"];
        message.type = [rs intForColumn:@"type"];
        message.state = [rs intForColumn:@"state"];
        message.readState = [rs intForColumn:@"readstate"];
        //        message.barID=[rs intForColumn:@"barid"];
        message.contentType=[rs intForColumn:@"contentType"];
        message.MsgSN = [rs intForColumn:@"msgsn"];
        [array addObject:message];
    }
    [rs close];
    return array;
}
//-(OneForOneMessage *)selectLastMessageAboutTheUid:(long long)uid WithContantUid:(long long)hostId{
//    NSString * query =[NSString stringWithFormat: @"SELECT * FROM SOneForOneMessage WHERE type = 1 and memberid = '%lld' and contactmemberid = '%lld' ORDER BY id DESC limit 1",uid, hostId];
//    NSLog(@"%@",query);
//    FMResultSet * rs = [_db executeQuery:query];
//    
//    OneForOneMessage *message;
//    while ([rs next]) {
//        message = [[OneForOneMessage alloc] init];
//        message.contentType=[rs intForColumn:@"contentType"];
//        message.code = [rs intForColumn:@"code"];
//        
//        if ((message.code==MessageCodeJoinGroup)||(message.contentType==MessageContentAddGroupMember)||(message.contentType==MessageContentRemoveGroupMember)) {
//            continue;
//        }
//        message.type = [rs intForColumn:@"type"];
//        message.memberId = [rs longForColumn:@"memberid"];
//        message.icon = [rs stringForColumn:@"icon"];
//        message.time = [rs stringForColumn:@"time"];
//        message.content = [rs stringForColumn:@"content"];
//        message.state = [rs intForColumn:@"state"];
//        message.readState = [rs intForColumn:@"readstate"];
//        message.nickName=[rs stringForColumn:@"nickname"];
//    }
//    [rs close];
//    return message;
//}
@end
