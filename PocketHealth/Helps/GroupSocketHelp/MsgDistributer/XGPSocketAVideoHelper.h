//
//  XGPSocketAVideoHelper.h
//  PocketHealth
//
//  Created by YangFan on 15/3/10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define avOutputWidth   480
#define avOutputHeight  640

typedef enum {
    finishAVTypeNormal = 0,
    finishAVTypeBusy = 1
}finishAVType;

@interface XGPSocketAVideoHelper : NSObject
{
    NSMutableDictionary * roomInfoDic;
    NSMutableDictionary *currentChatRoomDic;
    finishAVType ffftype; //本地保存一下挂断原因
}
+(id)defaultManager;

-(void)releaseSelf;

-(void)registerRoomWithDic:(NSDictionary *)dic;
-(void)finishAVWithDic:(NSDictionary *)dic WithType:(finishAVType)ftype;
-(void)acceptSessionWithSessionId:(long long)sessionId withMyid:(long long)memberId;
-(void)getOneAVRequestWithInfoDic:(NSDictionary *)dic;
-(void)getOneAVRequestFinish:(NSDictionary *)dic;

-(void)saveCurrentChatRoomInfo:(NSDictionary *)dic;
@end
