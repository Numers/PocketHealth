//
//  PHChatDatabaseHelper.h
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHChatDatabaseHelper : NSObject

+(void)saveMyAllFriendListToDb:(id)responseObject;

+(void)saveMyGroupListToDb:(id)responseObject;

+(void)reloadMyGroupListToDb:(id)responseObject;

+(BOOL)deleteFriendNotification;
+(BOOL)deleteGroupNotification;
@end
