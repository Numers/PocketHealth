//
//  PHVideoChatManager.h
//  PocketHealth
//
//  Created by macmini on 15-3-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHVideoChatViewController;
@interface PHVideoChatManager : NSObject
{
    PHVideoChatViewController *phVideoChatVC;
}
+(id)defaultManager;
-(void)createVideoChatWithDicInfo:(NSDictionary *)dic WithCallState:(BOOL)isComingCall;
-(void)didConnected;
-(void)didDisConnectedWithDescription:(NSString *)desc;
-(void)releaseVideoChatVC;
@end
