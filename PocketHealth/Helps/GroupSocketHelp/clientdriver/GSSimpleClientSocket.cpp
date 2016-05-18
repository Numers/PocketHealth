/*
 * GSSimpleClientSocket.cpp
 *
 *  Created on: 2014Äê7ÔÂ30ÈÕ
 *      Author: xugp
 */
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <sys/select.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>

#include "GSSimpleClientSocket.h"

GSSimpleClientSocket::GSSimpleClientSocket() {
	// TODO Auto-generated constructor stub
	m_sock=0;
}

GSSimpleClientSocket::~GSSimpleClientSocket() {
	// TODO Auto-generated destructor stub
}

int GSSimpleClientSocket::Connect(char* addr, int port) {
	m_sock=socket(AF_INET,SOCK_STREAM,0);
	if(m_sock<0) return -2;

	char * sip=NULL;
	struct hostent * ent=gethostbyname(addr);
	if(ent){
		if(ent->h_length>0){
			sip=ent->h_addr_list[0];
		}
	}

	if(sip==NULL){
		return -3;
	}
	struct sockaddr_in s_add;
	memset(&s_add,0,sizeof(struct sockaddr_in));
	s_add.sin_family=AF_INET;
	s_add.sin_addr=*(struct in_addr *)sip;
	s_add.sin_port=htons(port);
	int ret=connect(m_sock,(struct sockaddr *)&s_add,sizeof(s_add));

	return ret;
}

int GSSimpleClientSocket::SendAndRecv(DWORD opid, char* data, int datalen,
		char** res, int* reslen) {

	int rlen=sizeof(head_t) + datalen;
	head_t * req=(head_t *)malloc(rlen);
	req->opid=opid;
	req->datalen=datalen;
	memcpy(req+1,data,datalen);
	int ret=send(m_sock,req,rlen,0);
	if(ret>=0){

		head_t reshead={0};
		int m=0;
		while(m<sizeof(head_t)){
			int n=recv(m_sock,((char *)&reshead)+m,sizeof(head_t)-m,0);
			if(n<=0) return -4;
			m+=n;
		}

		if(m==sizeof(head_t)){
			*res=malloc(sizeof(head_t)+reshead.datalen);
			memcpy(*res,&reshead,sizeof(head_t));

			while(m<sizeof(head_t)+reshead.datalen){
				int n=recv(m_sock,(*res) + m,reshead.datalen-m-sizeof(head_t),0);
				if(n<=0) return -5;
				m+=n;
			}

			*reslen=m;

			return m;
		}else{
			return -1;
		}


	}else{
		return ret;
	}
}

int GSSimpleClientSocket::GetNewGroupMessage(DWORD gid, DWORD ownerid,
		int count, char* buffer, int bufferlen) {



	char * data=NULL;
	int datalen;

	newgroupmessage_t * req=(newgroupmessage_t *)malloc(sizeof(newgroupmessage_t));
	req->gid=gid;
	req->ownerid=ownerid;
	req->count=count;

	int ret=SendAndRecv(OP_NEWGROUPMESSAGE,(char *)req,sizeof(newgroupmessage_t),&data,&datalen);

	if(ret>0){
		head_t *h=(head_t*)data;

		if(h->opid==OP_NEWGROUPMESSAGE_RES){
			sync_res_t * sync_res=(sync_res_t*)(h+1);
			int n=datalen-sizeof(head_t)-sizeof(newgroupmessage_t);
			memcpy(buffer,sync_res+1,n>bufferlen?bufferlen:n);
		}else{
			ret=-5;
		}

	}

	if(data!=NULL) free(data);
	return ret;
}

void GSSimpleClientSocket::Close() {
	close(m_sock);
}
