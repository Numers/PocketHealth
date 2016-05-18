//
//  GroupHelpAggregation.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneForOneMessage.h"

@class GroupMessage;
@interface GroupHelpAggregation : NSObject

@property (nonatomic , copy) NSString *logoImage ;
@property (nonatomic , copy) NSString * content ;
@property (nonatomic) NSTimeInterval sessionDate;
@property (nonatomic , copy) NSString * groupHelperName ;
@property (nonatomic) BOOL isHasNewMessage;

@property (nonatomic) NSInteger notReadCount;
@property (nonatomic) MessageContentType contentType;
-(id)initWithLastGroupMessage:(GroupMessage *)groupMessage;
-(id)initWithNotReadCount:(NSInteger)notReadCount;
@end