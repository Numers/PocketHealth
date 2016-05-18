//
//  City.m
//  PocketHealth
//
//  Created by macmini on 15-1-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "City.h"
#import "Organization.h"

@implementation City
-(id)init
{
    self = [super init];
    if (self) {
        _organizationList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        if (dic) {
//            NSLog(@"_organizationList is %@", dic );
            _organizationList = [[NSMutableArray alloc] init];
            _cityId = [[dic objectForKey:@"Id"] integerValue];
            _pId = [[dic objectForKey:@"Pid"] integerValue];
            _initials = [dic objectForKey:@"Initials"];
            _cityName = [dic objectForKey:@"Areaname"];
            NSArray *organizationList = [dic objectForKey:@"OrganList"];
            if ((organizationList != nil) && (![organizationList isKindOfClass:[NSNull class]]) && (organizationList.count > 0)) {
                for (NSDictionary *organizationDic in organizationList) {
                    NSError *error = nil;
                    Organization *organization = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:organizationDic error:&error];
                    if (!error) {
                        [_organizationList addObject:organization];
                    }
                }
            }
        }
    }
    return self;
}
@end
