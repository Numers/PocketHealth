//
//  Group.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "Group.h"
#import "PHAppStartManager.h"
#import "GroupChatViewController.h"
#import "SGroupDB.h"
#import "GlobalVar.h"

@implementation Group

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"groupId" : @"Hbid",
             @"groupName" : @"Hbname",
             @"groupOwner" : @"Hbownerid",
             @"groupTag" : @"Hbtag" ,
             @"groupBriefIntroduction" : @"Hbremark",
             @"groupHeadImage" : @"Hblogourl" ,
             @"groupCreateTime": @"Hbcreatetime",
             @"groupState" : @"Hbstate",
             @"groupMemberCount":@"UserCount",
             @"groupStructure":@"Organ_name",
             @"joinStrategy":@"Hbjoingroup"
             };
}

+(NSValueTransformer *)groupHeadImageJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSString stringWithFormat:@"%@%@",ServerBaseURL,str];
    }
                                                         reverseBlock:^(NSString *num) {
                                                             return num;
                                                         }];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) {
        return nil;
    }
    self.belongMemberId = [[PHAppStartManager defaultManager] userHost].memberId;
    return self;
}
#pragma mark -  从数据库中查找指定群
+(Group *)findGroupFromDataBaseByGid:(unsigned)gid UserId:(long long)belongUid{
    SGroupDB *sGroupDB = [[SGroupDB alloc]init];
    Group *tmpGroup =  [sGroupDB selectGroupWithGid:gid WithBelongUid:belongUid];
    return tmpGroup;
}
@end
