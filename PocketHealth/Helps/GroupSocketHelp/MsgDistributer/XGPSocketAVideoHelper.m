//
//  XGPSocketAVideoHelper.m
//  PocketHealth
//
//  Created by YangFan on 15/3/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "XGPSocketAVideoHelper.h"
#import "ClientHelper.h"
#import "PHAppStartManager.h"
#import "PHVideoChatManager.h"

@implementation XGPSocketAVideoHelper

static XGPSocketAVideoHelper *globalSocketAVDistrbuter;
+(id)defaultManager
{
    if (globalSocketAVDistrbuter == nil) {
        globalSocketAVDistrbuter = [[XGPSocketAVideoHelper alloc] init];
        
        //视频模块3个通知
        [[NSNotificationCenter defaultCenter]addObserver:globalSocketAVDistrbuter selector:@selector(AVSucceedRegNotificaion:) name:@"succeedRegisterAVRoom" object:nil];
        //acceptSessionAV
        [[NSNotificationCenter defaultCenter]addObserver:globalSocketAVDistrbuter selector:@selector(AVAcceptNotificaion:) name:@"acceptSessionAV" object:nil];
        //finishSessionAV
        [[NSNotificationCenter defaultCenter]addObserver:globalSocketAVDistrbuter selector:@selector(AVFinishNotificaion:) name:@"finishSessionAV" object:nil];
        //checkSession
        [[NSNotificationCenter defaultCenter]addObserver:globalSocketAVDistrbuter selector:@selector(AVCheckNotificaion:) name:@"checkSessionAV" object:nil];
        
    }
    return globalSocketAVDistrbuter;
}


-(void)saveCurrentChatRoomInfo:(NSDictionary *)dic
{
    currentChatRoomDic = [NSMutableDictionary dictionaryWithDictionary:roomInfoDic];
}

#pragma mark - 视频相关socket处理
-(void)registerRoomWithDic:(NSDictionary *)dic{
    roomInfoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    long long memberId = [[PHAppStartManager defaultManager]userHost].memberId;
    
    
    NSString * roomIP = [roomInfoDic objectForKey:@"roomip"];
    NSInteger roomid = [[roomInfoDic objectForKey:@"roomid"]integerValue];
    NSInteger port = [[roomInfoDic objectForKey:@"port"]integerValue];
    [ClientHelper regiseterSessionWithMyid:memberId Token:[CommonUtil MyToken]];
}
-(void)finishAVWithDic:(NSDictionary *)dic WithType:(finishAVType)ftype{
    ffftype = ftype;
    long long sessionId = [[dic objectForKey:@"SessionID"]longLongValue];
    long long memberId = [[PHAppStartManager defaultManager]userHost].memberId;
    [ClientHelper finishSessionWithMyid:memberId Token:[CommonUtil MyToken] SessionId:sessionId];
}

#pragma mark -  通知
-(void)AVSucceedRegNotificaion:(NSNotification *)notifi{
    id object =notifi.object;
    long long sesscionId = [object longLongValue];
   
    [roomInfoDic setObject:[NSNumber numberWithLongLong:sesscionId] forKey:@"SessionID"];
    //发送普通消息给 对方用户
    [ClientHelper sendAcceptAVSessionMessageWithInfoDic:roomInfoDic];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"sendToVCSuccueedRegister" object:roomInfoDic];
}
-(void)AVAcceptNotificaion:(NSNotification *)notifi{
    //接收到对方接受了我的视频请求 向界面发出通知
    [[PHVideoChatManager defaultManager]didConnected];
//    id object =notifi.object;
//    long long sesscionId = [object longLongValue];
//    long long memberId = [[PHAppStartManager defaultManager]userHost].memberId;
//    [ClientHelper acceptSessionWithMyid:memberId Token:[CommonUtil MyToken] SessionId:sesscionId];
}

-(void)AVFinishNotificaion:(NSNotification *)notifi{
//    id object =notifi.object;
//    long long sesscionId = [object longLongValue];
    

    
    [ClientHelper sendFinishAVMessageWithInfoDic:currentChatRoomDic withFinishType:ffftype];
    //发送通知给界面 告知挂断
//    [[PHVideoChatManager defaultManager]didDisConnected];
}
-(void)AVCheckNotificaion:(NSNotification *)notifi{
    //说明成功获取通知 那么启动视频界面
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PHVideoChatManager defaultManager]createVideoChatWithDicInfo:roomInfoDic
                                                         WithCallState:YES];
    });
    
}
-(void)releaseSelf{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 给界面使用的方法
-(void)acceptSessionWithSessionId:(long long)sessionId withMyid:(long long)memberId{
    [ClientHelper acceptSessionWithMyid:memberId Token:[CommonUtil MyToken] SessionId:sessionId];
}

-(void)getOneAVRequestWithInfoDic:(NSDictionary *)dic{
    //得到视频请求 验证视频请求的有效性
    //暂存视频字典
    NSDictionary * createRoomInfoDic = [dic objectForKey:@"Data"];
    roomInfoDic = [NSMutableDictionary dictionaryWithDictionary:createRoomInfoDic];
    long long sessionid = [[roomInfoDic objectForKey:@"SessionID"]longLongValue];
    long long myid = [[PHAppStartManager defaultManager]userHost].memberId;
    
    //验证视频有效性
    [ClientHelper checkSessionWithMyid:myid Token:[CommonUtil MyToken] SessionId:sessionid];
    
}
-(void)getOneAVRequestFinish:(NSDictionary *)dic{
    NSString * alertMsg = [dic objectForKey:@"txt"];
    //发送通知给界面 告知挂断
    [[PHVideoChatManager defaultManager]didDisConnectedWithDescription:alertMsg];
}


@end
