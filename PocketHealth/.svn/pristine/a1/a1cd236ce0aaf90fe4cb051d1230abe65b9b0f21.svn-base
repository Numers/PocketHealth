#pragma once

typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned char BYTE;
//#define NULL 0

class GSBuffer
{
private:
	void * m_pBuffer;
	unsigned int m_nBufferSize;
public:
	GSBuffer(void);
	~GSBuffer(void);

	void Write(void * buffer,unsigned int len);
	void WriteBuffer(GSBuffer * pGSBuffer);

	int Read(void * buffer,unsigned int len);
	int ReadCopyOut(void * buffer,unsigned int len);

	unsigned int GetSize(){return m_nBufferSize;};

	void Clear();

	void RemoveFront(unsigned int n);
};

