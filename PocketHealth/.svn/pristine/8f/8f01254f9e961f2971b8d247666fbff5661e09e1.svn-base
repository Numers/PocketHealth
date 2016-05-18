#pragma once
#include "GSBuffer.h"
#include <pthread.h>

class GSClientSocketSink{
public:
	GSClientSocketSink(void);
	virtual ~GSClientSocketSink(void);
	virtual int OnRecvPacket(void * data,int len);
	virtual void OnConnect(){};
	virtual void OnConnectTimeout(){};
	virtual void OnClose(){};
public:
	static int decode(GSBuffer * pBuffer);  //�����Ƿ��Ϲ��򣬷��ط�Ϲ���İ�ȡ�0��ʾû�а�-1��ʾ������
	
};

typedef struct __head_t{
	DWORD opid;
	DWORD datalen;
}head_t;

class GSClientSocket
{
private:
	int m_sock;
	bool m_bConnected;
	bool m_bThread;

	GSBuffer * m_pGSBuffer;

	GSClientSocketSink * m_pGSClientSocketSink;
#ifdef WIN32
	DWORD dwThreadId;
#else
	pthread_t thread;
#endif

public:
	GSClientSocket(void);
	virtual ~GSClientSocket(void);

public:
	void OnConnect();
	void OnConnectTimeout();
	void OnClose();
	void SetThread(bool val){m_bThread=val;};
	void SetSocketSink(GSClientSocketSink * pGSClientSocketSink);
	bool IsConnected(){return m_bConnected;};
	void SetConected(bool val){m_bConnected=val;};
	int GetSocket(){return m_sock;};
	GSBuffer * GetBuffer();
	int Connect(char * ip,int port);
	void Close();
	GSClientSocketSink * GetClientSocketSink(){
		return m_pGSClientSocketSink;};
	int WriteCmd(DWORD opid,void * data,int datalen);
};

