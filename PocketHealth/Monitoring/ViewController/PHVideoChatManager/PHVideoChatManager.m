//
//  PHVideoChatManager.m
//  PocketHealth
//
//  Created by macmini on 15-3-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHVideoChatManager.h"
#import "PHVideoChatViewController.h"
#import "CommonUtil.h"
#import "ClientHelper.h"
#import "XGPSocketAVideoHelper.h"

static PHVideoChatManager *phVideoChatManager;
@implementation PHVideoChatManager
+(id)defaultManager
{
    if (phVideoChatManager == nil) {
        phVideoChatManager = [[PHVideoChatManager alloc] init];
    }
    return phVideoChatManager;
}

-(void)createVideoChatWithDicInfo:(NSDictionary *)dic WithCallState:(BOOL)isComingCall
{
    if (phVideoChatVC) {
        //用户正在通话中
        [ClientHelper sendFinishAVMessageWithInfoDic:dic withFinishType:finishAVTypeBusy];
        return;
    }
    phVideoChatVC = [[PHVideoChatViewController alloc] initWithDictionary:dic CallState:isComingCall];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:phVideoChatVC animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [UIApplication sharedApplication].idleTimerDisabled = YES;//不自动锁屏
        [[XGPSocketAVideoHelper defaultManager] saveCurrentChatRoomInfo:dic];
    }];
}

-(void)didConnected
{
    if (phVideoChatVC) {
        [phVideoChatVC didConnected];
    }
}

-(void)didDisConnectedWithDescription:(NSString *)desc
{
    if (phVideoChatVC) {
        [CommonUtil HUDShowText:desc InView:[[UIApplication sharedApplication] keyWindow]];
        [phVideoChatVC didDisConnected];
    }
}

-(void)releaseVideoChatVC
{
    if (phVideoChatVC) {
        [phVideoChatVC.view removeFromSuperview];
        phVideoChatVC = nil;
    }
}
@end
