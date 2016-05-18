/*
 * GSSimpleClientSocket.h
 *
 *  Created on: 2014年7月30日
 *      Author: xugp
 *
 *      本类用于临时短连接阻塞方式通信，主要用在未加入群之前临时获取群最近聊天记录
 */

#ifndef GSSIMPLECLIENTSOCKET_H_
#define GSSIMPLECLIENTSOCKET_H_

#define OP_NEWGROUPMESSAGE 0x000E //获取最新群消息
#define OP_NEWGROUPMESSAGE_RES 0x000F //获取最新群消息

typedef struct __head_t{
	DWORD opid;
	DWORD datalen;
}head_t;

typedef struct __newgroupmessage_t{
	DWORD ownerid;
	DWORD gid;
	DWORD count;
}newgroupmessage_t;

typedef struct __sync_res_t{
	char newsynckey[14];
	short zipflag; //0表示未压缩，1表示gzip压缩
	int length;
	//后续变长数据
}sync_res_t;


class GSSimpleClientSocket {
public:
	GSSimpleClientSocket();
	virtual ~GSSimpleClientSocket();

private:
	int m_sock;
	int SendAndRecv(DWORD opid,char * data,int datalen,char ** res,int * reslen);
public:
	int Connect(char * addr,int port);
	int GetNewGroupMessage(DWORD gid, DWORD ownerid, int count,char * buffer,int bufferlen);
	void Close();
};

#endif /* GSSIMPLECLIENTSOCKET_H_ */
