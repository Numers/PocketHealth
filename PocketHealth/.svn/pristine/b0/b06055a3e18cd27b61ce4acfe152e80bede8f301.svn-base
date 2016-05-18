#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "GSBuffer.h"


GSBuffer::GSBuffer(void)
{
	m_pBuffer=NULL;
	m_nBufferSize=0;
}


GSBuffer::~GSBuffer(void)
{
	if(m_pBuffer!=NULL){
		free(m_pBuffer);
	}
	m_nBufferSize=0;
}

void GSBuffer::Write( void * buffer,unsigned int len )
{
	void * tmp=malloc(m_nBufferSize + len);

	if(m_pBuffer!=NULL){
		memcpy(tmp,m_pBuffer,m_nBufferSize);
		free(m_pBuffer);
		m_pBuffer=NULL;
	}

	memcpy((char*)tmp+m_nBufferSize,buffer,len);
	m_nBufferSize=m_nBufferSize + len;
	m_pBuffer=tmp;

}

void GSBuffer::WriteBuffer( GSBuffer * pGSBuffer )
{
	unsigned int n=pGSBuffer->GetSize();
	if(n>0){
		void * tmp=malloc(n);
		pGSBuffer->ReadCopyOut(tmp,n);
		Write(tmp,n);
		free(tmp);
	}
}

int GSBuffer::Read( void * buffer,unsigned int len )
{
	unsigned int n=ReadCopyOut(buffer,len);
	RemoveFront(n);


	return n;
}

int GSBuffer::ReadCopyOut( void * buffer,unsigned int len )
{
	unsigned int n=GetSize()>len?len:GetSize();

	memcpy(buffer,m_pBuffer,n);
	return n;
}

void GSBuffer::Clear()
{
	if(m_pBuffer!=NULL){
		free(m_pBuffer);
		m_pBuffer=NULL;
	}

	m_nBufferSize=0;
}

void GSBuffer::RemoveFront( unsigned int n )
{
	unsigned int m=m_nBufferSize-n;
	if (m==0)
	{
		if(m_pBuffer!=NULL){
			free(m_pBuffer);
			m_pBuffer=NULL;
		}
		m_nBufferSize=0;
	}else{
		void * tmp=malloc(m);
		memcpy(tmp,(char*)m_pBuffer+n,m);
		m_nBufferSize=0;
		free(m_pBuffer);
		m_pBuffer=NULL;

		Write(tmp,m);
		free(tmp);
	}
}
