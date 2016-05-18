//
//  Doctor.m
//  PocketHealth
//
//  Created by macmini on 15-3-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "Doctor.h"
#import "GlobalVar.h"

@implementation Doctor
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"realName":@"Usertruename",
             @"nickName":@"Nickname",
             @"memberId" : @"Userid",
             @"headImage" : @"Headimg" ,
             @"location": @"Userlocation",
             @"birthDate": @"Userborn",
             @"dpName":@"Dpname",
             @"score":@"Score",
             
             @"oiId":@"Oiid",
             @"dpId":@"Dpid",
             @"diId":@"Diid",
             @"diJobTitle":@"Dijobtitle",
             @"remark":@"Diremark",
             
             @"userSex" : @"Usersex",
             @"userType" : @"Usertype" ,
             
             @"diCancall":@"Dicancall",
             @"diCalling":@"Dicalling"
             };
}


-(void)setNilValueForKey:(NSString *)key{
    [self setValue:@0 forKey:key];
}
+(NSValueTransformer *)headImageJSONTransformer{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(NSString *str) {
                
                return [NSString stringWithFormat:@"%@%@",ServerBaseURL,str];
            }
            reverseBlock:^(NSString *num) {
                return num;
            }];
}

+(NSValueTransformer *)birthDateJSONTransformer{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(id str) {
                return [NSNumber numberWithDouble:[str doubleValue]/1000.f];
            }
            reverseBlock:^(id num) {
                return num;
            }];
}

@end
