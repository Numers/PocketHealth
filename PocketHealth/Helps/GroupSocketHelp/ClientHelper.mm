//
//  ClientHelper.m
//  ylmm
//
//  Created by macmini on 14-5-26.
//  Copyright (c) 2014年 YiLiao. All rights reserved.
//

#import "ClientHelper.h"
#import "ylmm.h"
#import "JSONKit.h"
//#include "GSSimpleClientSocket.h"

#import "EmojiConvert.h"
#import "OneForOneMessage.h"
#import "PHAppStartManager.h"
#import "SocketGlobalVar.h"
#import "AppDelegate.h"





//GSSimpleClientSocket *gs_SimpleClient=NULL;

void OnNotify(char *data){
    if (data == NULL ||  data[0]==0) {
        NSLog(@"*********************************");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ONNOTIFY" object:nil];
    }else{
        NSLog(@"error error error ! has a big OnNotify!!!!!!");
        NSString * str=[NSString stringWithUTF8String:data];
        NSDictionary *dic = [str objectFromJSONString];
        //调用主动关闭socket聊天链接
        AppDelegate * delegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.isInitiativeExitChatConnect = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ONKICKNOTIFY" object:dic];
    }
    
}

void OnSyncRes(char * msg){
    NSString * str=[NSString stringWithUTF8String:msg];
    NSDictionary *dic = [str objectFromJSONString];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ONSYNCRES" object:dic];
}

void OnMessageRes(int retcode,int msgtype,int msgsn,char * data){
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:retcode],@"retcode",[NSNumber numberWithInt:msgsn],@"msgsn", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ONMESSAGERES" object:dic];
}

void _OnConnect(){
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ONCONNECT" object:nil];
}

void _OnClose(){
//    NSLog(@"in close");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ONCLOSE" object:nil];
}

void _OnConnectTimeout(){
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ONCONNECTTIMEOUT" object:nil];
}
#pragma mark - 视频部分初始化
void OnRegisterSessionRes(long long sessionid, int code){
    
    if (code == 0) {
        //向界面发送 呼出通知 以及界面更新
        [[NSNotificationCenter defaultCenter]postNotificationName:@"succeedRegisterAVRoom" object:[NSNumber numberWithLongLong:sessionid]];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"sendToVCFailedRegister" object:[NSNumber numberWithLongLong:sessionid]];
    }
}
void OnAcceptSessionRes(long long sessionid,int code,UID uid){
    if (code == 0) {
        //接受 向界面发送 成功建立连接通知 界面进行图像上行下载
        [[NSNotificationCenter defaultCenter]postNotificationName:@"acceptSessionAV" object:nil];
    }
    
}
void OnFinishSessionRes(long long sessionid,int code,UID uid,UID peerid,long long createtime,long long accepttime,long long finishtime){
    //挂断 截断通知
//    if (code == 0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"finishSessionAV" object:nil];
//    }
}
void OnCheckSessionRes(long long sessionid,int status){
    if (status == 0) {
        //0表示成功 那么就通知呼出通讯界面
        //checkSessionAV
        [[NSNotificationCenter defaultCenter]postNotificationName:@"checkSessionAV" object:nil];
    }
}
@implementation ClientHelper
+(void)initClient{
    FOnNotify *fOnNotify                          = OnNotify;
    FOnSyncRes *fOnSyncRes                        = OnSyncRes;
    FOnMessageRes *fOnMessageRes                  = OnMessageRes;
    FOnConnect *fOnConnect                        = _OnConnect;
    FOnClose *fOnClose                            = _OnClose;
    FOnConnectTimeout *fOnConnectTimeOut          = _OnConnectTimeout;
    _init(fOnNotify,fOnSyncRes,fOnMessageRes,fOnConnect,fOnClose,fOnConnectTimeOut);
    //视频模块初始化
    FOnRegisterSessionRes * fOnRegisterSessionRes = OnRegisterSessionRes;
    FOnAcceptSessionRes * fOnAcceptSessionRes     = OnAcceptSessionRes;
    FOnFinishSessionRes * fOnFinishSessionRes     = OnFinishSessionRes;
    FOnCheckSessionRes * fOnCheckSessionRes = OnCheckSessionRes;
    _setVideoSessionFun(fOnRegisterSessionRes, fOnAcceptSessionRes, fOnFinishSessionRes,fOnCheckSessionRes);
    
}

+(NSInteger)connect
{
    NSString *ip = SocketChatHostUrl;//@"192.168.100.3";
//    NSString *ip = @"192.168.2.120";//61.164.160.49
//     NSString *ip = @"192.168.2.102";
    return  _connect((char *)[ip UTF8String], Port);
}
+(NSInteger)connectToHost
{
    NSInteger connecteState = 0;
    if (![self isConnect]) {
        [self close];
        connecteState = [self connect];
    NSLog(@"reconnect");
    }
    return connecteState;
}

+(BOOL)isConnect{
    return _isConnected();
}
+(NSInteger)sendMessage:(long long )uid Token:(NSString *)token ToUid:(long long )touid Message:(NSString *)msg Msgsn:(NSInteger )msgsn
{
    NSString * sendStr = [EmojiConvert emojiConvertToSendString:msg];
    int ret= sendMessage(uid, (char *)[token UTF8String], touid, (char *)[sendStr UTF8String],[[NSNumber numberWithInteger:msgsn] intValue]);
    if (ret<0) {
        [self connect];
        //重连机制 1
    }
    return ret;
}

+(NSInteger)sendGroupMessage:(long long )uid Token:(NSString *)token Gid:(unsigned)gid Message:(NSString *)msg Msgsn:(NSInteger )msgsn
{
//    NSDate *dateBefore=[NSDate date];
//    NSTimeInterval timeBeforeSend=[dateBefore timeIntervalSince1970];
//    NSLog(@"%f",timeBeforeSend);
    
    NSString * sendStr = [EmojiConvert emojiConvertToSendString:msg];
    int ret=sendGroupMessage(uid, (char *)[token UTF8String], gid, (char *)[sendStr UTF8String],[[NSNumber numberWithInteger:msgsn] intValue]);
    return ret;
}
+(void)reConnectChatHost{
    [self connect];
}
+(NSInteger)sync:(long long )uid Token:(NSString *)token Synckey:(NSString *)synckey
{
    
    return _sync(uid, (char *)[token UTF8String], (char *)[synckey UTF8String]);
}

+(void)close
{
    _close();
}
+(void)closeBySelf{

    _close();
}
//UserInfo  为键值对的json 字符串
+(NSInteger)addFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid UserInfo:(NSString *)userinfo Msgsn:(NSInteger)msgsn
{
    return addFriend(uid, (char*)[token UTF8String], touid, (char *)[userinfo UTF8String], [[NSNumber numberWithInteger:msgsn] intValue]);
}
+(NSInteger)acceptFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid Msgsn:(NSInteger)msgsn
{
    return acceptFriend(uid, (char *)[token UTF8String], touid, [[NSNumber numberWithInteger:msgsn] intValue]);
}
+(NSInteger)removeFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid Msgsn:(NSInteger)msgsn
{
    return removeFriend(uid, (char *)[token UTF8String], touid, [[NSNumber numberWithInteger:msgsn] intValue]);
}

#pragma mark -心跳包
+(NSInteger)test{
    return test();
}
//短lianjie
//+(void)initSimpleConnect{
//    gs_SimpleClient=new GSSimpleClientSocket();
//}
//+(NSInteger)simpleConnect{
//    NSString *ip = @"ylmm-server.xugp.com";//@"192.168.100.3";
//    return gs_SimpleClient->Connect((char *)[ip UTF8String], 10000);
//}
//+(NSInteger)getNewSimpleGroupMessageWithGid:(unsigned int)gid Ownerid:(unsigned int)ownerid Count:(int)count buffer:(NSMutableString **)buffer bufferlen:(int)bufferlen{
//    
//    char * tempbuff=(char *)malloc(bufferlen);
//    memset(tempbuff, 0, bufferlen);
//    NSInteger ret=gs_SimpleClient->GetNewGroupMessage(gid, ownerid, count, tempbuff,bufferlen);
//    
//    
//    
////    *buffer =[NSMutableString stringWithUTF8String:tempbuff];
//    NSString *result=[NSString  stringWithUTF8String:tempbuff];
//    
//    *buffer=(NSMutableString *)result;
//    //    NSString *result=[[NSString alloc]initWithCString:tempbuff encoding:NSUTF8StringEncoding];
//    //通知传值r
////    NSDictionary * jsonStr=[[NSString stringWithFormat:@"%s",tempbuff] objectFromJSONString];
//    
////    JSONDecoder *jsdc=[[JSONDecoder alloc]init];
////    NSDictionary * aa=[jsdc mutableObjectWithUTF8String:(unsigned char *)tempbuff length:sizeof(tempbuff)];
//    
//    
//    NSLog(@"%@",result);
//    
//    free(tempbuff);
//    return ret;
//    
//}
//+(void)closeSimpleConnect{
//    return gs_SimpleClient->Close();
////    gs_SimpleClient=nil;
//}
#pragma mark - 视频部分调用
+(NSInteger)regiseterSessionWithMyid:(long long)uid Token:(NSString *)token{
    
    return  _registerSession(uid, (char *)[token UTF8String]);
}
+(NSInteger)acceptSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid{
    return _acceptSession(uid, (char *)[token UTF8String], sessionid);
}
+(NSInteger)finishSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid{
    return _finishSession(uid, (char *)[token UTF8String], sessionid);
}
+(NSInteger)checkSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid {
    return _checkSession(uid, (char *)[token UTF8String], sessionid);
}

//发送成功连接
+(NSInteger)sendAcceptAVSessionMessageWithInfoDic:(NSDictionary *)roomInfoDic{
    
    
    long long fromId = [[roomInfoDic objectForKey:@"fromId"]longLongValue];
    long long touid = [[roomInfoDic objectForKey:@"touid"]longLongValue];
    
    NSDictionary * message = [NSDictionary dictionaryWithObjectsAndKeys:@"视频通话",@"txt",[NSString stringWithFormat:@"%d",MessageContentAVStart],@"ct",roomInfoDic,@"Data",nil];
    NSString *msg = [message JSONString];

    return [ClientHelper sendMessage:fromId Token:[CommonUtil MyToken] ToUid:touid Message:msg Msgsn:4444];
}
+(NSInteger)sendFinishAVMessageWithInfoDic:(NSDictionary *)roomInfoDic withFinishType:(finishAVType)ftype{
    long long fromId = [[roomInfoDic objectForKey:@"fromId"]longLongValue];
    long long touid = [[roomInfoDic objectForKey:@"touid"]longLongValue];
    
    long long myid = [[PHAppStartManager defaultManager]userHost].memberId;
    if (fromId != myid) {
        long long tmp;
        tmp = fromId;
        fromId = touid;
        touid = tmp;
    }
    
    NSString * alertMsg ;
    MessageContentType ct;
    switch (ftype) {
        case finishAVTypeNormal:
        {
            alertMsg = @"视频通话结束";
            ct = MessageContentAVClose;
            
        }
            break;
        case finishAVTypeBusy:{
            alertMsg = @"对方正忙";
            ct = MessageContentAVBusyClose;
        }
            break;
        default:
            break;
    }
    NSDictionary * message = [NSDictionary dictionaryWithObjectsAndKeys:alertMsg,@"txt",[NSString stringWithFormat:@"%d",ct],@"ct",roomInfoDic,@"Data",nil];
    return [ClientHelper sendMessage:fromId Token:[CommonUtil MyToken] ToUid:touid Message:[message JSONString] Msgsn:8888];
}

@end
