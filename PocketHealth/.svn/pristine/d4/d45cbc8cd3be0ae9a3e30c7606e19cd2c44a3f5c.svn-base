//
//  ClientHelper.h
//  ylmm
//
//  Created by macmini on 14-5-26.
//  Copyright (c) 2014年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonUtil.h"
#import "XGPSocketAVideoHelper.h"


@interface ClientHelper : NSObject


#pragma mark - 群功能模块
/**
 *  initClint 初始化连接 在连接之前使用
 */
+(void)initClient;


/**
 *  connect 建立链接
 *
 *  在已连接的状况下不要再次调用
 *  @return -1 表示连接失败 // 但是有时候感觉不是很稳定？
 */
+(NSInteger)connect;

/**
 *  判断是否链接的标识
 *
 *  @return true 表示已连接
 */
//+(BOOL)isConnect;

/**
 *  connectToHost 一种安全的链接方式的封装
 *
 *  @return -1 表示链接失败
 */
+(NSInteger)connectToHost;

/**
 *  sendMessage 发送私聊消息方法
 *
 *  @param uid   发送消息的用户id
 *  @param token 发送消息的令牌 调用[CommonUtil MyToken] 即可。下同
 *  @param touid 接受消息的用户id
 *  @param msg   消息内容
 *  @param msgsn 消息序列号？
 *
 *  @return -1 表示失败
 */
+(NSInteger)sendMessage:(long long )uid Token:(NSString *)token ToUid:(long long )touid Message:(NSString *)msg Msgsn:(NSInteger )msgsn;

+(BOOL)isConnect;
/**
 *  sync 执行同步指令
 *
 *  @param uid     用户id
 *  @param token   令牌
 *  @param synckey 同步指令key
 *
 *  @return -1 为失败
 */
+(NSInteger)sync:(long long )uid Token:(NSString *)token Synckey:(NSString *)synckey;
/**
 *  断开连接，一般在切换到后台时使用，使得可以接收到消息推送
 */
+(void) close;

/**
 *  主动断开连接
 */
+(void)closeBySelf;
/**
 *  sendGroupMessage 发送群聊消息
 *
 *  @param uid   发送消息的用户ID
 *  @param token 令牌
 *  @param gid   发送消息的组ID
 *  @param msg   消息内容
 *  @param msgsn 消息序列号
 *
 *  @return -1 表示发送失败
 */
+(NSInteger)sendGroupMessage:(long long )uid Token:(NSString *)token Gid:(unsigned)gid Message:(NSString *)msg Msgsn:(NSInteger )msgsn;

/**
 *
 *  addFriend
 *  acceptFriend
 *  removeFriend
 *  @param uid      发送好友请求的用户id
 *  @param token    令牌
 *  @param touid    添加的用户id
 *  @param userinfo 发起好友请求的内容
 *  @param msgsn    消息序列号？
 *
 *  @return -1代表失败
 */
+(NSInteger)addFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid UserInfo:(NSString *)userinfo Msgsn:(NSInteger)msgsn;
+(NSInteger)acceptFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid Msgsn:(NSInteger)msgsn;
+(NSInteger)removeFriend:(long long )uid Token:(NSString *)token ToUid:(long long )touid Msgsn:(NSInteger)msgsn;

#pragma mark - 心跳连接
+(NSInteger)test;
#pragma mark - 视频部分调用
+(NSInteger)regiseterSessionWithMyid:(long long)uid Token:(NSString *)token;
+(NSInteger)acceptSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid;
+(NSInteger)finishSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid;
+(NSInteger)checkSessionWithMyid:(long long)uid Token:(NSString *)token SessionId:(long long)sessionid ;

//发送普通消息给对方 提醒他
+(NSInteger)sendAcceptAVSessionMessageWithInfoDic:(NSDictionary *)roomInfoDic;
+(NSInteger)sendFinishAVMessageWithInfoDic:(NSDictionary *)roomInfoDic withFinishType:(finishAVType)ftype;

#pragma mark - 短链接获取群组最近的少量聊天记录
+(void)initSimpleConnect;
+(NSInteger)simpleConnect;
+(NSInteger)getNewSimpleGroupMessageWithGid:(unsigned int)gid Ownerid:(unsigned int)ownerid Count:(int)count buffer:(NSMutableString **)buffer bufferlen:(int)bufferlen;
+(void)closeSimpleConnect;


@end
