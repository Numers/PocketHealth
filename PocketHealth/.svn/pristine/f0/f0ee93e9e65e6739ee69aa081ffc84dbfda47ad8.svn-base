//
//  PhysicalExamTable.m
//  PocketHealth
//
//  Created by macmini on 15-1-21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PhysicalExamTable.h"

@implementation PhysicalExamTable
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"ebId":@"Ebid",
             @"ebNumber":@"Ebnumber",
             @"ebPassword":@"Ebpassword",
             @"belongOrganizationName":@"Organ_name",
             @"organizationId":@"Id",
             @"userId":@"Userid",
             @"loginName":@"Loginname",
             @"ebFirstLogin":@"Ebfirstlogin",
             @"ebLastLogin":@"Eblastlogin",
             @"examinTime":@"Edexamintime"
             };
}

-(void)setNilValueForKey:(NSString *)key
{
    [self setValue:@0 forKey:key];
//    NSMutableDictionary *dic = [[super dictionaryValue] mutableCopy];
//    [dic removeObjectForKey:key];
//    [self setValuesForKeysWithDictionary:dic];
}

+(NSValueTransformer *)examinTimeJSONTransformer{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(id str) {
                return [NSNumber numberWithDouble:[str doubleValue]/1000.f];
            }
            reverseBlock:^(id num) {
                return num;
            }];
}

+(NSValueTransformer *)ebFirstLoginJSONTransformer{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(id str) {
                return [NSNumber numberWithDouble:[str doubleValue]/1000.f];
            }
            reverseBlock:^(id num) {
                return num;
            }];
}

+(NSValueTransformer *)ebLastLoginJSONTransformer{
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(id str) {
                return [NSNumber numberWithDouble:[str doubleValue]/1000.f];
            }
            reverseBlock:^(id num) {
                return num;
            }];
}

@end
