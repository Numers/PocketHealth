//
//  SGroupDB.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "SGroupDB.h"
#import "SGroupMessageDB.h"
#import "SGroupMemberDB.h"

#define kGroupTableName @"SGroup"

@implementation SGroupDB
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
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kGroupTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kGroupTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql = @"CREATE TABLE SGroup (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, groupid INTEGER,belongmemberid BIGINT, groupname VARCHAR(50),groupheadimage VARCHAR(50),isSession INTEGER,sessiondate TIMESTAMP, groupowner INTEGER,groupbriefintroduction VARCHAR(50) ,messageNotReadCount INTEGER , grouptag VARCHAR(50),joinStrategy INTEGER, groupstate INTEGER,groupcreatetime TIMESTAMP,groupstructure VARCHAR(50))";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kGroupTableName);
        } else {
            NSLog(@"%@数据库创建成功",kGroupTableName);
        }
    }
}
-(BOOL)isExistGroupWithGid:(unsigned)gid WithBelongUid:(long long)belongUid{
    NSString * query =[NSString stringWithFormat:@"SELECT * FROM SGroup WHERE groupid = '%u' and belongmemberid = '%lld'",gid,belongUid];
    FMResultSet * rs = [_db executeQuery:query];
    BOOL isExist =  rs.next;
    [rs close];
    return isExist;
}
- (void) saveGroup:(Group *) group
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO SGroup"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:10];
    
    if (group.groupId) {
        [keys appendString:@"groupid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%u",group.groupId]];
    }
    
    if (group.belongMemberId) {
        [keys appendString:@"belongmemberid,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lld",group.belongMemberId]];
    }
    
    if (group.groupName) {
        [keys appendString:@"groupname,"];
        [values appendString:@"?,"];
        [arguments addObject:group.groupName];
    }
    
    if (group.groupBriefIntroduction) {
        [keys appendString:@"groupbriefintroduction,"];
        [values appendString:@"?,"];
        [arguments addObject:group.groupBriefIntroduction];
    }
    
    if (group.sessionDate) {
        [keys appendString:@"sessiondate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",group.sessionDate]];
    }
    
    if(group.groupTag){
        [keys appendString:@"grouptag,"];
        [values appendString:@"?,"];
        [arguments addObject:group.groupTag];
    }
    
    if (group.groupHeadImage) {
        [keys appendString:@"groupheadimage,"];
        [values appendString:@"?,"];
        [arguments addObject:group.groupHeadImage];
    }
    
    if (group.groupOwner) {
        [keys appendString:@"groupowner,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lld",group.groupOwner]];
    }
    
  
    if (group.groupState) {
        [keys appendString:@"groupstate,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%ld",(long)group.groupState]];
    }
    if (group.groupCreateTime) {
        [keys appendString:@"groupcreatetime,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%lf",group.groupCreateTime]];
    }
    
    if (group.groupStructure) {
        [keys appendString:@"groupstructure,"];
        [values appendString:@"?,"];
        [arguments addObject:group.groupStructure];
    }
    
    //0---------------
    [keys appendString:@"isSession,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)group.isSession]];
    
    [keys appendString:@"joinStrategy,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)group.joinStrategy]];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    
    bool isSaveOk = [_db executeUpdate:query withArgumentsInArray:arguments];
    isSaveOk?NSLog(@"groupdb 插入数据OK"):NSLog(@"groupdb save error");
    
    if (group.groupMember.count > 0) {
        SGroupMemberDB *groupMemberdb = [[SGroupMemberDB alloc] init];
        for(GroupMember *gm in group.groupMember){
            if(![groupMemberdb isExistGroupMemberWithUid:gm.memberId WithGid:gm.groupId]){
                [groupMemberdb saveGroupMember:gm];
            }
        }
    }
    
//    if (group.groupMessage.count > 0) {
//        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
//        for(GroupMessage *gmsg in group.groupMessage){
//            [groupMessagedb saveGroupMessage:gmsg WithContactUid:group.belongMemberId];
//        }
//    }
}
- (void) mergeGroup:(Group *)group
{
    NSString * query = @"UPDATE SGroup SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:100];
    // xxx = xxx;
    if (group.groupName) {
        [temp appendFormat:@" groupname = '%@',",group.groupName];
    }
    
    if (group.sessionDate) {
        [temp appendFormat:@" sessiondate = '%lf',",group.sessionDate];
    }
    
    if (group.groupHeadImage) {
        [temp appendFormat:@" groupheadimage = '%@',",group.groupHeadImage];
    }
    
    if(group.groupTag){
        [temp appendFormat:@" grouptag = '%@',",group.groupTag];
    }
    if (group.groupOwner) {
        [temp appendFormat:@" groupowner = '%lld',",group.groupOwner];
    }
    
    if (group.groupBriefIntroduction) {
        [temp appendFormat:@" groupbriefintroduction = '%@',",group.groupBriefIntroduction];
    }
    if (group.groupState) {
        [temp appendFormat:@" groupstate = '%ld',",(long)group.groupState];
    }
    //createtime不需要修改 到此为止
    //=========-=-==-=-=-=-=-=-=-=--=-=-=-==-=-==-
    
    
    [temp appendFormat:@" isSession = '%@',",[NSString stringWithFormat:@"%ld",(long)group.isSession]];
    
    [temp appendFormat:@" joinStrategy = '%@',",[NSString stringWithFormat:@"%ld",(long)group.joinStrategy]];
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE groupid = '%u' and belongmemberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],group.groupId,group.belongMemberId];
//    NSLog(@"%@",query);
    BOOL flag = [_db executeUpdate:query];
    flag ?NSLog(@"group修改一条数据 成功"): NSLog(@"group 修改一条数据 失败");
}
-(Group *)selectGroupWithGid:(unsigned)gid WithBelongUid:(long long)belongUid{
    Group *group = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SGroup WHERE groupid = '%u' and belongmemberid = '%lld'",gid,belongUid];
    FMResultSet * rs = [_db executeQuery:query];
    if ([rs next]) {
        group = [[Group alloc] init];
        group.groupId = [rs intForColumn:@"groupid"];
        group.belongMemberId = [rs longLongIntForColumn:@"belongmemberid"];
        group.groupName = [rs stringForColumn:@"groupname"];
        group.isSession = [rs intForColumn:@"isSession"];
        group.sessionDate = [rs doubleForColumn:@"sessiondate"];
        group.groupHeadImage = [rs stringForColumn:@"groupheadimage"];
        group.groupOwner = [rs longLongIntForColumn:@"groupowner"];
        group.groupTag = [rs stringForColumn:@"grouptag"];
        group.joinStrategy = [rs intForColumn:@"joinStrategy"];
        group.groupBriefIntroduction=[rs stringForColumn:@"groupbriefintroduction"];
        group.groupStructure = [rs stringForColumn:@"groupstructure"];
        //91唱新增属性

        group.groupState = [rs intForColumn:@"groupstate"];
        group.groupCreateTime = [rs doubleForColumn:@"groupcreatetime"];
        //----0-0-=-=-==-=-=-=-=-=-==-=-=
        
        SGroupMemberDB *groupMemberdb = [[SGroupMemberDB alloc] init];
        group.groupMember = [groupMemberdb selectAllGroupMemberWithGid:group.groupId];
        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
        group.groupMessage = [groupMessagedb selectGroupMessageWithGid:group.groupId WithContactUid:belongUid];
//        group.messageNotReadCount = [groupMessagedb selectNotReadMessageCountWithGid:group.groupId WithContactUid:belongUid];
        
    }
    [rs close];
    return group;

}
//查询所有的群
-(NSMutableArray *)selectAllGroupWithBelongId:(long long)belongUid{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SGroup WHERE belongmemberid = '%lld' ORDER BY id DESC",belongUid];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Group *group = [[Group alloc] init];
        group.groupId = [rs intForColumn:@"groupid"];
        group.belongMemberId = [rs longLongIntForColumn:@"belongmemberid"];
        group.groupName = [rs stringForColumn:@"groupname"];
        group.isSession = [rs intForColumn:@"isSession"];
        group.sessionDate = [rs doubleForColumn:@"sessiondate"];
        group.groupHeadImage = [rs stringForColumn:@"groupheadimage"];
        group.groupTag = [rs stringForColumn:@"grouptag"];
        group.joinStrategy = [rs intForColumn:@"joinStrategy"];
        group.groupOwner = [rs longLongIntForColumn:@"groupowner"];
        group.groupBriefIntroduction=[rs stringForColumn:@"groupbriefintroduction"];
        group.groupStructure = [rs stringForColumn:@"groupstructure"];
        
        //新增属性
        group.groupState = [rs intForColumn:@"groupstate"];
        group.groupCreateTime = [rs doubleForColumn:@"groupcreatetime"];
        //----0-0-=-=-==-=-=-=-=-=-==-=-=
        
        SGroupMemberDB *groupMemberdb = [[SGroupMemberDB alloc] init];
        group.groupMember = [groupMemberdb selectAllGroupMemberWithGid:group.groupId];
        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
        group.groupMessage = [groupMessagedb selectGroupMessageWithGid:group.groupId WithContactUid:belongUid];
        if (group.sessionDate==0) {
            OneForOneMessage * message = group.groupMessage.lastObject;
            if (message!=nil) {
                group.sessionDate = message.time;
            }
            
        }
        NSPredicate *predicateUser=[NSPredicate predicateWithFormat:@"SELF.readState == %u",MessageNotRead];
        NSArray *tmpNotReadMessageArray=[NSArray arrayWithArray:[group.groupMessage filteredArrayUsingPredicate:predicateUser]];
        
        //        group.messageNotReadCount = [groupMessagedb selectNotReadMessageCountWithGid:group.groupId WithContactUid:belongUid];
        group.messageNotReadCount=tmpNotReadMessageArray.count;
//        if ([group isValidate]) {
            [array addObject:group];
//        }
    }
    [rs close];
    return array;
}
- (void) deleteGroup:(Group *)group{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM SGroup WHERE groupid = '%u' and belongmemberid = '%lld'",group.groupId,group.belongMemberId];
    NSLog(@"删除一条数据");
    [_db executeUpdate:query];
    
    if (group.groupMember.count > 2) {
        SGroupMemberDB *groupMemberdb = [[SGroupMemberDB alloc] init];
        for(GroupMember *gm in group.groupMember){
            [groupMemberdb deleteGroupMember:gm];
        }
    }
    
    if (group.groupMessage.count > 0) {
        SGroupMessageDB *groupMessagedb = [[SGroupMessageDB alloc] init];
        [groupMessagedb deleteGroupMessageWithGid:group.groupId WithContactUid:group.belongMemberId];
    }
}

@end
