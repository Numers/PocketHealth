//
//  SFirendDB.m
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "SFirendDB.h"
#import "SOneForOneMessageDB.h"

#define kFriendTableName @"SFriend"

@implementation SFirendDB

#pragma mark - 初始化
- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
    }
    return self;
}
- (void) createDataBase {
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kFriendTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kFriendTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql = @"CREATE TABLE SFriend (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, memberid BIGINT,belongmemberid BIGINT,nickname VARCHAR(50),loginname VARCHAR(50), headimage VARCHAR(100), isSession INTEGER,sessiondate TIMESTAMP,userheight INTEGER,userweight INTEGER,usersex INTEGER,userstate INTEGER,userregister TIMESTAMP ,usertype INTEGER )";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kFriendTableName);
        } else {
            NSLog(@"%@数据库创建成功",kFriendTableName);
        }
    }
}
#pragma mark -  保存用户
- (void) saveUser:(Member *) user WithBelongUid:(long long)belongUid{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO SFriend"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:14];
    
    [keys appendString:@"belongmemberid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",belongUid]];
    
    [keys appendString:@"userstate,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.userState]];
    
    
    if (user.isSession) {
        [keys appendString:@"isSession,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.isSession]];
    }
    
    
    if (user.sessionDate) {
        [keys appendString:@"sessiondate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",user.sessionDate]];
    }
    //userregister
    if (user.userRegister) {
        [keys appendString:@"userregister,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",user.userRegister]];
    }
    
    if (user.memberId) {
        [keys appendString:@"memberid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lld",user.memberId]];
    }
    
    if (user.nickName) {
        [keys appendString:@"nickname,"];
        [values appendString:@"?,"];
        [arguments addObject:user.nickName];
    }
    
    if (user.loginName) {
        [keys appendString:@"loginname,"];
        [values appendString:@"?,"];
        [arguments addObject:user.loginName];
    }
    
    
    if (user.headImage) {
        [keys appendString:@"headimage,"];
        [values appendString:@"?,"];
        [arguments addObject:user.headImage];
    }
    //userheight INTEGER,
//    userweight INTEGER,
//    usersex INTEGER,
//    userstate INTEGER,

    if (user.userHeight) {
        [keys appendString:@"userheight,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.userHeight]];
    }
    if (user.userWeight) {
        [keys appendString:@"userweight,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.userWeight]];
    }
    if (user.userSex) {
        [keys appendString:@"usersex,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.userSex]];
    }

    

    //usertype
    if (user.userType) {
        [keys appendString:@"usertype,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.userType]];
    }
    
    

//    if (user.friendType) {
//        [keys appendString:@"friendtype,"];
//        [values appendString:@"?,"];
//        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)user.friendType]];
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
-(BOOL)isExistMemberWithUid:(long long)uid WithBelongUid:(long long)belongUid{
    NSString * query =[NSString stringWithFormat:@"SELECT * FROM SFriend WHERE memberid = '%lld' and belongmemberid = '%lld' ",uid,belongUid];
    FMResultSet * rs = [_db executeQuery:query];
    BOOL isExist =  rs.next;
    [rs close];
    return isExist;
}
/**
 * @brief 修改用户的信息
 *
 * @param user 需要修改的用户信息
 */
- (void) mergeWithUser:(Member *) user WithBelongUid:(long long)belongUid{
    if (!user.memberId) {
        return;
    }
    NSString * query = @"UPDATE SFriend SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:100];
    // xxx = xxx;
    if (user.headImage) {
        [temp appendFormat:@" headimage = '%@',",user.headImage];
    }
//    if (user.userType) {
        [temp appendFormat:@" usertype = '%u',",user.userType];
//    }
//    if (user.friendType) {
//        [temp appendFormat:@" sessiondate = '%u',",user.friendType];
//    }
    //不修改昵称
    //    if (user.nickName) {
    //        user.nickName=[user.nickName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    //        [temp appendFormat:@" nickname = '%@',",user.nickName];
    //    }
    
    if (user.loginName) {
        [temp appendFormat:@" loginname = '%@',",user.loginName];
    }
    
    [temp appendFormat:@" userstate = '%u',",user.userState];
    
    if (user.sessionDate) {
        [temp appendFormat:@" sessiondate = '%lf',",user.sessionDate];
    }
    
    [temp appendFormat:@" isSession = '%@',",[NSString stringWithFormat:@"%ld",(long)user.isSession]];
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE memberid = '%lld' and belongmemberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],user.memberId,belongUid];
    NSLog(@"%@",query);
    NSInteger resultCount=[_db executeUpdate:query];
    NSLog(@"修改 %ld 条数据 ",(long)resultCount);
    
}
-(void)mergeWithUserWithoutSession:(Member *)user WithBelongUid:(long long)belongUid{
    if (!user.memberId) {
        return;
    }
    NSString * query = @"UPDATE SFriend SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:100];
    // xxx = xxx;
    if (user.headImage) {
        [temp appendFormat:@" headimage = '%@',",user.headImage];
    }
    [temp appendFormat:@" usertype = '%u',",user.userType];
    
    if (user.loginName) {
        [temp appendFormat:@" loginname = '%@',",user.loginName];
    }
    if (user.nickName) {
        [temp appendFormat:@" nickname = '%@',",user.nickName];
    }
    [temp appendFormat:@" userstate = '%u',",user.userState];
    
    if (user.sessionDate) {
        [temp appendFormat:@" sessiondate = '%lf',",user.sessionDate];
    }
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE memberid = '%lld' and belongmemberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],user.memberId,belongUid];
    NSLog(@"%@",query);
    NSInteger resultCount=[_db executeUpdate:query];
    NSLog(@"修改 %ld 条数据 ",(long)resultCount);
}
-(NSArray *)selectWithoutSessionUserWithHospitalWithBelongUid:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE belongmemberid = '%lld' and  usertype = %u  ORDER BY sessiondate DESC",belongUid,MemberUserTypeAdmin];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Member *member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        
        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        member.lastestOneMessage = [msgdb selectLastMessageAboutMemberType:MemberUserTypeAdmin WithSelectId:member.memberId WithContantUid:belongUid];
        
        member.messageArr = [msgdb selectMessageWithUid:member.memberId WithContactUid:belongUid];
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];
        [array addObject:member];
    }
    [rs close];
    return array;
}

-(NSArray *)selectSessionUserWithoutHospitalWithBelongUid:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE isSession = 1 and belongmemberid = '%lld' and  usertype <> %u ORDER BY sessiondate DESC",belongUid,MemberUserTypeAdmin];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Member *member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        
        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        member.lastestOneMessage = [msgdb selectLastMessageAboutMemberType:MemberUserTypeUser WithSelectId:member.memberId WithContantUid:belongUid];
        member.userState = [rs intForColumn:@"userstate"];
        member.messageArr = [msgdb selectMessageWithUid:member.memberId WithContactUid:belongUid];
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];
        [array addObject:member];
    }
    [rs close];
    return array;
}
-(NSArray *)selectAllUserWithoutHopspitalWithBelongUid:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE belongmemberid = '%lld' and  usertype = %u and userstate = 0",belongUid,MemberUserTypeUser];
//     NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend"];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Member *member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        
        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
//        member.lastestOneMessage = [msgdb selectLastMessageAboutTheUid:member.memberId WithContantUid:belongUid];
        
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];
        [array addObject:member];
    }
    [rs close];
    return array;
}
-(NSArray *)selectHospitalWithBelongUid:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE belongmemberid = '%lld' and  usertype = '%u' and userstate = 0 ",belongUid,MemberUserTypeDoctor];
    //     NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend"];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Member *member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        
        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        //        member.lastestOneMessage = [msgdb selectLastMessageAboutTheUid:member.memberId WithContantUid:belongUid];
        
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];
        [array addObject:member];
    }
    [rs close];
    return array;
}
-(NSArray *)selectAttantionWithBelongUid:(long long)belongUid WithAttantionType:(MemberUserType)attantionType{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE belongmemberid = '%lld' and  usertype = '%u' and userstate = 0 ",belongUid,attantionType];
    //     NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend"];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Member *member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        
        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];usertype
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        //        member.lastestOneMessage = [msgdb selectLastMessageAboutTheUid:member.memberId WithContantUid:belongUid];
        
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];
        [array addObject:member];
    }
    [rs close];
    return array;
}
//查询用户详情方法
-(Member *)selectUserWithUid:(long long)uid WithBelongUid:(long long)belongUid{
    Member *member = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SFriend WHERE memberid = '%lld' and belongmemberid = '%lld' ",uid,belongUid];
    FMResultSet * rs = [_db executeQuery:query];
    if ([rs next]) {
        member = [[Member alloc] init];
        member.memberId = [rs longLongIntForColumn:@"memberid"];
        member.nickName = [rs stringForColumn:@"nickname"];
        member.loginName = [rs stringForColumn:@"loginname"];
        member.headImage = [rs stringForColumn:@"headimage"];
        member.isSession = [rs intForColumn:@"isSession"];
        member.sessionDate = [rs doubleForColumn:@"sessiondate"];
        

        member.userType=[rs intForColumn:@"usertype"];
        member.userState = [rs intForColumn:@"userstate"];
//        member.friendType = [rs intForColumn:@"friendtype"];
        SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
        member.messageArr = [msgdb selectMessageWithUid:member.memberId WithContactUid:belongUid];
        member.messageNotReadCount = [msgdb selectNotReadMessageCountWithUid:member.memberId WithContactUid:belongUid];

    }
    [rs close];
    return member;
}
//删除好友
- (BOOL) deleteUserWithId:(long long) uid WithBelongUid:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SFriend WHERE memberid = '%lld' and belongmemberid = '%lld'",uid,belongUid];
    NSLog(@"删除一条数据");
    BOOL flag =  [_db executeUpdate:query];
    
    SOneForOneMessageDB *msgdb = [[SOneForOneMessageDB alloc] init];
    [msgdb deleteMessageWithUid:uid WithContactUid:belongUid];

    return flag;
}
@end
