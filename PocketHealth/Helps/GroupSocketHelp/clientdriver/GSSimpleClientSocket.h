/*
 * GSSimpleClientSocket.h
 *
 *  Created on: 2014��7��30��
 *      Author: xugp
 *
 *      ����������ʱ������������ʽͨ�ţ���Ҫ����δ����Ⱥ֮ǰ��ʱ��ȡȺ��������¼
 */

#ifndef GSSIMPLECLIENTSOCKET_H_
#define GSSIMPLECLIENTSOCKET_H_

#define OP_NEWGROUPMESSAGE 0x000E //��ȡ����Ⱥ��Ϣ
#define OP_NEWGROUPMESSAGE_RES 0x000F //��ȡ����Ⱥ��Ϣ

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
	short zipflag; //0��ʾδѹ����1��ʾgzipѹ��
	int length;
	//�����䳤����
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
