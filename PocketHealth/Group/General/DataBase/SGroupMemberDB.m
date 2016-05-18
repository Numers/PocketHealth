//
//  SGroupMemberDB.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "SGroupMemberDB.h"
#define kGroupMemberTableName @"SGroupMember"

@implementation SGroupMemberDB
- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
        
    }
    return self;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase
{
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kGroupMemberTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kGroupMemberTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql =@"CREATE TABLE SGroupMember (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, memberid BIGINT,nickname VARCHAR(50),loginname VARCHAR(50), headimage VARCHAR(100), isSession INTEGER,sessiondate TIMESTAMP,userheight INTEGER,userweight INTEGER,usersex INTEGER,userstate INTEGER,userregister TIMESTAMP ,usertype INTEGER,groupid INTERGER,groupmembertype INTERGER,lastchattime VARCHAR(50))";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kGroupMemberTableName);
        } else {
            NSLog(@"%@数据库创建成功",kGroupMemberTableName);
        }
    }
}
/**
 * @brief 保存一条群组成员数据记录
 *
 * @param groupMember 需要保存的群组数据
 */
- (void) saveGroupMember:(GroupMember *) groupMember{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO SGroupMember"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:7];
    
    //群特有属性
    if (groupMember.groupMemberType) {
        [keys appendString:@"groupmembertype,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.groupMemberType]];
    }
    if (groupMember.groupId) {
        [keys appendString:@"groupid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%u",groupMember.groupId]];
    }
    
    
    [keys appendString:@"memberid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",groupMember.memberId]];
    
    [keys appendString:@"isSession,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.isSession]];
    
    if (groupMember.sessionDate) {
        [keys appendString:@"sessiondate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",groupMember.sessionDate]];
    }
    //userregister
    if (groupMember.userRegister) {
        [keys appendString:@"userregister,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",groupMember.userRegister]];
    }
    
    if (groupMember.memberId) {
        [keys appendString:@"memberid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lld",groupMember.memberId]];
    }
    
    if (groupMember.nickName) {
        [keys appendString:@"nickname,"];
        [values appendString:@"?,"];
        [arguments addObject:groupMember.nickName];
    }
    
    if (groupMember.loginName) {
        [keys appendString:@"loginname,"];
        [values appendString:@"?,"];
        [arguments addObject:groupMember.loginName];
    }
    
    
    if (groupMember.headImage) {
        [keys appendString:@"headimage,"];
        [values appendString:@"?,"];
        [arguments addObject:groupMember.headImage];
    }
    //userheight INTEGER,
    //    userweight INTEGER,
    //    usersex INTEGER,
    //    userstate INTEGER,
    
    if (groupMember.userHeight) {
        [keys appendString:@"userheight,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.userHeight]];
    }
    if (groupMember.userWeight) {
        [keys appendString:@"userweight,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.userWeight]];
    }
    if (groupMember.userSex) {
        [keys appendString:@"usersex,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.userSex]];
    }
    if (groupMember.userState) {
        [keys appendString:@"userstate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.userState]];
    }
    
    if (groupMember.userType) {
        //usertype
        [keys appendString:@"usertype,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.userType]];
    }
    if (groupMember.lastChatTime) {
        [keys appendString:@"lastchattime,"];
        [values appendString:@"?,"];
        [arguments addObject:groupMember.lastChatTime];
    }
//    if (groupMember.friendType) {
//        [keys appendString:@"friendtype,"];
//        [values appendString:@"?,"];
//        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)groupMember.friendType]];
//    }
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    
    BOOL flag = [_db executeUpdate:query withArgumentsInArray:arguments];
    flag?NSLog(@" SFriendDB 插入一条数据 成功"):NSLog(@"SFriendDB 插入一条数据 失败");
}
- (void) mergeGroupMember:(GroupMember *)groupMember{
    NSString * query = @"UPDATE SGroupMember SET";
    NSMutableString * temp = [NSMutableString string];
    // xxx = xxx;
    if (groupMember.nickName) {
        [temp appendFormat:@" nickname = '%@',",groupMember.nickName];
    }
    
    if (groupMember.headImage) {
        [temp appendFormat:@" headimage = '%@',",groupMember.headImage];
    }
    if (groupMember.lastChatTime) {
        [temp appendFormat:@" lastchattime = '%@',",groupMember.lastChatTime];
    }
//    [temp appendFormat:@" type = '%u',",groupMember.type];
    
    [temp appendFormat:@" usersex = '%u',",groupMember.userSex];
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE groupid = '%u' and memberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],groupMember.groupId,groupMember.memberId];
//    NSLog(@"%@",query);
   
    BOOL flag = [_db executeUpdate:query];
    flag?NSLog(@"修改群用户 成功"): NSLog(@"修改群用户 一条数据  失败");
}
- (void) mergeGroupMemberWithOutChatTime:(GroupMember *)groupMember{
    NSString * query = @"UPDATE SGroupMember SET";
    NSMutableString * temp = [NSMutableString string];
    // xxx = xxx;
    if (groupMember.nickName) {
        [temp appendFormat:@" nickname = '%@',",groupMember.nickName];
    }
    
    if (groupMember.headImage) {
        [temp appendFormat:@" headimage = '%@',",groupMember.headImage];
    }

    //    [temp appendFormat:@" type = '%u',",groupMember.type];
    
    [temp appendFormat:@" usersex = '%u',",groupMember.userSex];
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE groupid = '%u' and memberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],groupMember.groupId,groupMember.memberId];
    //    NSLog(@"%@",query);
    
    BOOL flag = [_db executeUpdate:query];
    flag?NSLog(@"修改群用户 成功"): NSLog(@"修改群用户 一条数据  失败");
}
-(NSMutableArray *)selectAllGroupMemberWithGid:(unsigned)gid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SGroupMember WHERE groupid = '%u' ORDER BY usertype ASC",gid];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [[NSMutableArray alloc]init];
    while ([rs next]) {
        GroupMember *groupMember = [[GroupMember alloc] init];
        groupMember.groupId = [rs intForColumn:@"groupid"];
        groupMember.memberId = [rs longLongIntForColumn:@"memberid"];
        groupMember.loginName = [rs stringForColumn:@"loginname"];
        groupMember.nickName = [rs stringForColumn:@"nickname"];
        groupMember.headImage = [rs stringForColumn:@"headimage"];
        groupMember.groupMemberType=[rs intForColumn:@"groupmembertype"];
        groupMember.userSex=[rs intForColumn:@"usersex"];
        
        groupMember.lastChatTime = [rs stringForColumn:@"lastchattime"];
//        groupMember.orgName = [rs stringForColumn:@"orgname"];
//        groupMember.typeName = [rs stringForColumn:@"typename"];
//        groupMember.userIntroduce = [rs stringForColumn:@"userintroduce"];
//        groupMember.userRecord = [rs stringForColumn:@"userrecord"];
        groupMember.userType=[rs intForColumn:@"usertype"];
        
//        groupMember.userPro=[rs stringForColumn:@"userpro"];
//        groupMember.userCity=[rs stringForColumn:@"usercity"];
//        if ([groupMember isValidate]) {
        [array addObject:groupMember];
//        }
    }
    [rs close];
    return array;
}
-(BOOL)isExistGroupMemberWithUid:(long long )uid WithGid:(unsigned)gid{
    NSString * query =[NSString stringWithFormat:@"SELECT * FROM SGroupMember WHERE groupid = '%u' and memberid = '%lld'",gid,uid];
    FMResultSet * rs = [_db executeQuery:query];
    BOOL isExist =  rs.next;
    [rs close];
    return isExist;
}
-(GroupMember *)selectGroupMemberWithUid:(long long)uid WithGid:(unsigned)gid
{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SGroupMember WHERE groupid = '%u' and memberid = '%lld'",gid,uid];
    FMResultSet * rs = [_db executeQuery:query];
    GroupMember *groupMember = nil;
    if ([rs next]) {
        groupMember = [[GroupMember alloc] init];
        groupMember.groupId = [rs intForColumn:@"groupid"];
        groupMember.memberId = [rs longLongIntForColumn:@"memberid"];
        groupMember.loginName = [rs stringForColumn:@"loginname"];
        groupMember.nickName = [rs stringForColumn:@"nickname"];
        groupMember.headImage = [rs stringForColumn:@"headimage"];
//        groupMember.friendType=[rs intForColumn:@"friendtype"];
        groupMember.userSex=[rs intForColumn:@"usersex"];
        groupMember.userType = [rs intForColumn:@"usertype"];
        
        groupMember.lastChatTime = [rs stringForColumn:@"lastchattime"];
        


        
    }
    [rs close];
    return groupMember;
}
-(GroupMember *)selectGroupMemberInfo:(long long)uid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SGroupMember WHERE memberid = '%lld' limit 1",uid];
    FMResultSet * rs = [_db executeQuery:query];
    GroupMember *groupMember = nil;
    if ([rs next]) {
        groupMember = [[GroupMember alloc] init];
        groupMember.groupId = [rs intForColumn:@"groupid"];
        groupMember.memberId = [rs longLongIntForColumn:@"memberid"];
        groupMember.loginName = [rs stringForColumn:@"loginname"];
        groupMember.nickName = [rs stringForColumn:@"nickname"];
        groupMember.headImage = [rs stringForColumn:@"headimage"];
        //        groupMember.friendType=[rs intForColumn:@"friendtype"];
        groupMember.userSex=[rs intForColumn:@"usersex"];
        groupMember.userType = [rs intForColumn:@"usertype"];
        
        groupMember.lastChatTime = [rs stringForColumn:@"lastchattime"];
        
        
        
        
    }
    [rs close];
    return groupMember;
}
- (void) deleteGroupMember:(GroupMember *)groupMember{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SGroupMember WHERE groupid = '%u' and memberid = '%lld'",groupMember.groupId,groupMember.memberId];
    NSLog(@"删除一条数据");
    [_db executeUpdate:query];
}
@end
