//
//  HospitalAggregation.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HospitalAggregation : NSObject

@property (nonatomic , copy) NSString * logoImage ;
@property (nonatomic , copy) NSString * content ;
@property (nonatomic) NSTimeInterval sessionDate;
@property (nonatomic , copy) NSString * hospitalGroupName ;

@end
