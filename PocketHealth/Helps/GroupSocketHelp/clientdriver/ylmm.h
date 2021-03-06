//
//  ylmm.h
//  ylmm
//
//  Created by macmini on 14-5-26.
//  Copyright (c) 2014骞�YiLiao. All rights reserved.
//

#ifndef ylmm_ylmm_h
#define ylmm_ylmm_h

#include "proto.h"

typedef void FOnNotify(char * data);
typedef void FOnSyncRes(char * msg);
typedef void FOnMessageRes(int retcode,int msgtype,int msgsn,char * data);
typedef void FOnConnect();
typedef void FOnClose();
typedef void FOnConnectTimeout();

typedef void FOnRegisterSessionRes(long long sessionid,int code);
typedef void FOnAcceptSessionRes(long long sessionid,int code,UID uid);//,int roomid,char *roomserverip,int roomport
typedef void FOnFinishSessionRes(long long sessionid,int code,UID uid,UID peerid,long long createtime,long long accepttime,long long finishtime);
typedef void FOnCheckSessionRes(long long sessionid,int status);

void _init(FOnNotify * lpOnNotify, FOnSyncRes *lpOnSyncRes, FOnMessageRes *lpOnMessageRes, FOnConnect *lpOnConnect, FOnClose *lpOnClose, FOnConnectTimeout *lpOnConnectTimeOut);
void _setVideoSessionFun(FOnRegisterSessionRes * lpOnRegisterSessionRes,FOnAcceptSessionRes * lpOnAcceptSessionRes,FOnFinishSessionRes * lpOnFinishSessionRes,FOnCheckSessionRes * lpOnCheckSessionRes);
int sendMessage(UID uid,char * token,UID touid,char * msg,int msgsn);
int sendOneMessage(UID uid,char * token,UID touid,char * msg,int msgsn);
int test();
int _connect(char * ip,int port);
int _sync(UID uid,char * token,char * synckey);
int _registerSession(UID uid,char * token);//,char * roomip,int roomid,int roomport
int _acceptSession(UID uid,char * token,long long sessionid);
int _finishSession(UID uid,char * token,long long sessionid);
int _checkSession(UID uid,char * token,long long sessionid);
void _close();
bool _isConnected();

int addFriend(UID uid,char * token,UID touid,char * userinfo,int msgsn);
int acceptFriend(UID uid,char * token,UID touid,int msgsn);
int removeFriend(UID uid,char * token,UID touid,int msgsn);

int sendGroupMessage(UID uid,char * token,UID gid,char * msg,int msgsn);

#endif
