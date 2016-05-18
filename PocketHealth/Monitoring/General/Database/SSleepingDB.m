//
//  SSleepingDB.m
//  PocketHealth
//
//  Created by YangFan on 15/1/13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//
//  1.0.1 睡眠的入睡以及醒来的时间修改为long
//

#import "SSleepingDB.h"
#import "CommonUtil.h"
#import "GlobalVar.h"
#define kSleepingDB @"SleepingDB"
#import "CommonUtil.h"


@implementation SSleepingDB

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立数据库，如果未建立，则建立数据库=========
        _db = [SDBManager defaultDBManager].dataBase;
    }
    return self;
}
-(void)createDataBase{
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kSleepingDB]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kSleepingDB);
    } else {
        // TODO: 插入新的数据库
//        NSString * sql = @"CREATE TABLE SleepingDB (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, belongMemberId BIGINT,lastSleepTime TIMESTAMP,wakeupSleepTime TIMESTAMP,belongSleepDate VARCHAR(50),sleepDuration INTEGER,isUpload INTEGER)";
        NSString * sql = @"CREATE TABLE SleepingDB (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, belongMemberId BIGINT,lastSleepTime INTEGER,wakeupSleepTime INTEGER,belongSleepDate VARCHAR(50),sleepDuration INTEGER,isUpload INTEGER)";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kSleepingDB);
        } else {
            NSLog(@"%@数据库创建成功",kSleepingDB);
        }
    }
}
-(BOOL)saveSleeping:(Sleeping *)sleeping{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO SleepingDB"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:10];
    
    [keys appendString:@"belongMemberId,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%lld",sleeping.belongMemberId]];
    
    
    
    [keys appendString:@"sleepDuration,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)sleeping.sleepDuration]];
    
    
    
    [keys appendString:@"lastSleepTime,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)sleeping.lastSleepTime]];
    

    [keys appendString:@"wakeupSleepTime,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)sleeping.wakeupSleepTime]];
    
    [keys appendFormat:@"isUpload,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%ld",(long)sleeping.isUpload]];
    
    //belongSleepDate
    [keys appendFormat:@"belongSleepDate,"];
    [values appendString:@"?,"];
    [arguments addObject:sleeping.belongSleepDate];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
    NSLog(@"%@",query);
    
    bool isSaveOk = [_db executeUpdate:query withArgumentsInArray:arguments];
    isSaveOk?NSLog(@"sleeping 插入数据OK"):NSLog(@"sleeping save error");
    return isSaveOk;
}
-(NSString *)selectTodaySleepingMinutes:(long long)memberId{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    //如果是在0点到9点 那么显示昨天的睡眠 如果19点到次日0点 那么显示今天睡眠数据
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger dd = [yyyymmdd integerValue];
    
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<dd && dd<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    NSDate *dateFlag = [formatter dateFromString:belongSleepDate];
    //    NSDate * dateFlag = [formatter dateFromString:dateString];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    NSTimeInterval timeStart = timeZero - 3600 * (24-kTimeStart);
    NSTimeInterval timeEnd = timeZero + 3600 * KTimeEnd ;
    
    
    //    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f' and  belongSleepDate like '%@%%'",memberId,timeStart,timeEnd,timeStart,timeEnd,dateString];
    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f' and belongSleepDate = '%@'",memberId,timeStart,timeEnd,timeStart,timeEnd,belongSleepDate];
    FMResultSet * rs = [_db executeQuery:query];
    //    NSLog(@"%@",query);
    NSString * sleepSum;
    while ([rs next]) {
        sleepSum = [[NSString alloc]init];
        sleepSum = [rs stringForColumn:@"sleepSum"];
    }
    return sleepSum;

//    NSString * dateString = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date]timeIntervalSince1970]];
//    //modify by yangfan 2015-03-04 由于belongSleepDate数据库 样式改变做修改
////    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and belongSleepDate like '%@%%'",memberId,dateString];
//    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and belongSleepDate = '%@'",memberId,dateString];
//    FMResultSet * rs = [_db executeQuery:query];
//    NSString * sleepSum;
//    while ([rs next]) {
//        sleepSum = [[NSString alloc]init];
//        sleepSum = [rs stringForColumn:@"sleepSum"];
//    }
//    return sleepSum;
}
-(NSString *)selectOnedaySleepingMinutesWithYYMMDD:(NSString *)dateString WithMember:(long long)memberId{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
//    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    //如果是在0点到9点 那么显示昨天的睡眠 如果19点到次日0点 那么显示今天睡眠数据
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger dd = [yyyymmdd integerValue];
    
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<dd && dd<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    NSDate *dateFlag = [formatter dateFromString:belongSleepDate];
//    NSDate * dateFlag = [formatter dateFromString:dateString];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    NSTimeInterval timeStart = timeZero - 3600 * (24-kTimeStart);
    NSTimeInterval timeEnd = timeZero + 3600 * KTimeEnd ;
    
    
//    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f' and  belongSleepDate like '%@%%'",memberId,timeStart,timeEnd,timeStart,timeEnd,dateString];
    NSString * query =[NSString stringWithFormat:@"select *  , sum(sleepDuration) as sleepSum from SleepingDB where belongMemberId = '%lld' and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f'",memberId,timeStart,timeEnd,timeStart,timeEnd];
    FMResultSet * rs = [_db executeQuery:query];
//    NSLog(@"%@",query);
    NSString * sleepSum;
    while ([rs next]) {
        sleepSum = [[NSString alloc]init];
        sleepSum = [rs stringForColumn:@"sleepSum"];
    }
    return sleepSum;
}
-(BOOL)mergeSleeping:(Sleeping *)sleeping{
    NSString * query = @"UPDATE SleepingDB SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:100];
    // xxx = xxx;
    
    
    if (sleeping.lastSleepTime) {
        [temp appendFormat:@" lastSleepTime = '%ld',",(long)sleeping.lastSleepTime];
    }
    if (sleeping.sleepDuration) {
        [temp appendFormat:@" sleepDuration = '%ld',",(long)sleeping.sleepDuration];
    }
    if (sleeping.isUpload) {
        [temp appendFormat:@" isUpload = '%ld',",(long)sleeping.isUpload];
    }
    if (sleeping.wakeupSleepTime) {
        [temp appendFormat:@" wakeupSleepTime = '%ld',",(long)sleeping.wakeupSleepTime];
    }
    if (sleeping.belongSleepDate) {
        [temp appendFormat:@" belongSleepDate = '%@',",sleeping.belongSleepDate];
    }
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE belongmemberid = '%lld'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],sleeping.belongMemberId];
    NSLog(@"%@",query);
    BOOL flag = [_db executeUpdate:query];
    flag ?NSLog(@"sleeping 修改一条数据 成功"): NSLog(@"sleeping 修改一条数据 失败");
    return flag;

}
-(BOOL)isExistSleepingData:(NSTimeInterval)startSleepTime WithBelongId:(long long)belongId belongSleepDateHour:(NSString *)belongSleepDateHour{
    NSString * query =[NSString stringWithFormat:@"SELECT * FROM SleepingDB WHERE belongMemberId = '%lld' and lastSleepTime = %ld and belongSleepDate = '%@' ",belongId,(long)startSleepTime,belongSleepDateHour];
    FMResultSet * rs = [_db executeQuery:query];
    BOOL isExist =  rs.next;
    [rs close];
    return isExist;
}
-(BOOL)mergeSleepingWakeupTimeTo:(NSTimeInterval)wakeupSleepTime WithBelongId:(long long)belongId WithStartSleepTime:(NSTimeInterval)startSleepTime{
    NSString * query = [NSString stringWithFormat:@"UPDATE SleepingDB SET wakeupSleepTime = '%ld' WHERE belongMemberId = '%lld' and lastSleepTime = '%ld' ",(long)wakeupSleepTime,belongId,(long)startSleepTime];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"更新了%ld条数据",(long)result);
    return result;
}
-(BOOL)mergeSleepingWakeupTimeTo:(NSTimeInterval)wakeupSleepTime WithLastSleepTime:(NSTimeInterval)lastSleepTime WithBelongId:(long long)belongId WithDuration:(NSInteger)duration{
    NSString * belongdate = [CommonUtil TimeStrYYYYMMDDHHWithInterval:lastSleepTime];
    NSString * query = [NSString stringWithFormat:@"UPDATE SleepingDB SET wakeupSleepTime = %ld , sleepDuration = %ld WHERE belongMemberId = '%lld' and  belongSleepDate = '%@' and lastSleepTime = %ld ",(long)wakeupSleepTime,(long)duration,belongId ,belongdate,(long)lastSleepTime ];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"更新了%ld条数据",(long)result);
    return result;
}

-(NSArray *)selectAllUnUploadDate:(long long)hostId{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    //如果是在0点到9点 那么显示昨天的睡眠 如果19点到次日0点 那么显示今天睡眠数据
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger dd = [yyyymmdd integerValue];
    
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<dd && dd<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    NSDate *dateFlag = [formatter dateFromString:belongSleepDate];
    //    NSDate * dateFlag = [formatter dateFromString:dateString];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    NSTimeInterval timeStart = timeZero - 3600 * (24-kTimeStart);
    NSTimeInterval timeEnd = timeZero + 3600 * KTimeEnd ;
    
    
    
    //and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f'
    
//    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SleepingDB WHERE belongMemberId = '%lld' and isUpload = 0 ORDER BY id DESC ",hostId];
    
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM SleepingDB WHERE belongMemberId = '%lld' and isUpload = 0  and lastSleepTime between '%f' and  '%f'  or  wakeupSleepTime between  '%f' and '%f' ORDER BY id DESC",hostId,timeStart,timeEnd,timeStart,timeEnd];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    while ([rs next]) {
        Sleeping *sleeping = [[Sleeping alloc]init];
        
        sleeping.belongMemberId = hostId;
//        sleeping.lastSleepTime = [rs doubleForColumn:@"lastSleepTime"];
//        sleeping.wakeupSleepTime = [rs doubleForColumn:@"wakeupSleepTime"];
        sleeping.lastSleepTime = [rs intForColumn:@"lastSleepTime"];
        sleeping.wakeupSleepTime = [rs intForColumn:@"wakeupSleepTime"];
        sleeping.sleepDuration = [rs intForColumn:@"sleepDuration"];
        sleeping.belongSleepDate = [rs stringForColumn:@"belongSleepDate"];
        
        
        [array addObject:sleeping];
        //        }
    }
    [rs close];
    return array;

}
-(BOOL)mergeUnUploadSleepingToUploaded:(long long)hostId{
    NSString * query = [NSString stringWithFormat:@"UPDATE SleepingDB SET isUpload = 1 WHERE belongMemberId = '%lld' and isUpload = 0",hostId];
    NSInteger result = [_db executeUpdate:query];
    NSLog(@"更新了 sleepDb %ld条数据",(long)result);
    return result;
}
-(NSString *)selectTodaySleepingStartTimeWithMemberId:(long long)memberId{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    //如果是在0点到9点 那么显示昨天的睡眠 如果19点到次日0点 那么显示今天睡眠数据
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger dd = [yyyymmdd integerValue];
    
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<dd && dd<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    
//    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSDate * dateFlag = [formatter dateFromString:belongSleepDate];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    NSTimeInterval timeStart = timeZero - 3600 * (24-kTimeStart);
    NSTimeInterval timeEnd = timeZero + 3600 * KTimeEnd ;
    
    NSString * startTime;
    NSString * query = [NSString stringWithFormat:@"select lastSleepTime from  SleepingDb  where lastSleepTime between '%ld' and  '%ld'  or  wakeupSleepTime between  '%ld' and '%ld' and belongMemberId  = '%lld'  order by id ASC limit 1",(long)timeStart,(long)timeEnd,(long)timeStart,(long)timeEnd,memberId];
   FMResultSet * rs = [_db executeQuery:query];
    if ([rs next]) {
        NSTimeInterval lastSleepTime = [rs doubleForColumn:@"lastSleepTime"];
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:lastSleepTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        startTime=[formatter stringFromDate:date];
    }
    return startTime;
    
}
-(NSMutableArray *)selectSleepDetailArrayWithMemberId:(long long)memberId WithBelongSleepDate:(NSString *)belongSleepDateNOTUSE{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //如果是在0点到9点 那么显示昨天的睡眠 如果19点到次日0点 那么显示今天睡眠数据
    //获取小时数字
    NSString * yyyymmdd = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSRange range = [yyyymmdd rangeOfString:@" "];
    yyyymmdd = [yyyymmdd substringFromIndex:range.location+1];
    NSInteger dd = [yyyymmdd integerValue];
    
    NSString * belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    if (19<dd && dd<=23) {
        belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]+86400];
    }
    
    NSDate * dateFlag = [formatter dateFromString:belongSleepDate];
    
    NSTimeInterval timeZero = [dateFlag timeIntervalSince1970];
    NSTimeInterval timeStart = timeZero - 3600 * (24-kTimeStart);
    NSTimeInterval timeEnd = timeZero + 3600 * KTimeEnd ;
    
    NSLog(@"timeStart : %@ timeEnd :%@",[CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:timeStart] , [CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:timeEnd]);
    NSString * query = [NSString stringWithFormat:@"select * from SleepingDB  where lastSleepTime between '%ld' and  '%ld'  or  wakeupSleepTime between  '%ld' and '%ld' and belongMemberId = '%lld' ",(long)timeStart,(long)timeEnd,(long)timeStart,(long)timeEnd,memberId];
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    while ([rs next]) {
        Sleeping *sleeping = [[Sleeping alloc]init];
        
        sleeping.belongMemberId = memberId;
//        sleeping.lastSleepTime = [rs doubleForColumn:@"lastSleepTime"];
//        sleeping.wakeupSleepTime = [rs doubleForColumn:@"wakeupSleepTime"];
        sleeping.lastSleepTime = [rs intForColumn:@"lastSleepTime"];
        sleeping.wakeupSleepTime = [rs intForColumn:@"wakeupSleepTime"];
        
        sleeping.sleepDuration = [rs intForColumn:@"sleepDuration"];
        sleeping.belongSleepDate = [rs stringForColumn:@"belongSleepDate"];
        
        
        [array addObject:sleeping];
        //        }
    }
    [rs close];
    return array;
}
@end