//
//  PhysicalExamTable.h
//  PocketHealth
//
//  Created by macmini on 15-1-21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface PhysicalExamTable : MTLModel<MTLJSONSerializing>
@property(nonatomic) NSInteger ebId;
@property(nonatomic, copy) NSString *ebNumber;
@property(nonatomic, copy) NSString *ebPassword;
@property(nonatomic) long long userId;
@property(nonatomic, copy) NSString *belongOrganizationName;
@property(nonatomic) long long organizationId;
@property(nonatomic, copy) NSString *loginName;
@property(nonatomic) NSTimeInterval ebFirstLogin;
@property(nonatomic) NSTimeInterval ebLastLogin;
@property(nonatomic) NSTimeInterval examinTime;
@end
