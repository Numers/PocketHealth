
#include <assert.h>
#include <string.h>

#include "GSClientSocket.h"


#include <pthread.h>

#include "proto.h"
#include <stdio.h>

#define MT_ONEMSG 0
#define MT_P2P 1
#define MT_GROUP 2

#define MT_ADDFRIEND 10
#define MT_ACCEPTFRIEND 11
#define MT_REMOVEFRIEND 12


#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "native-activity", __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "native-activity", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "native-activity", __VA_ARGS__))

JavaVM *g_jvm = NULL;
jobject g_obj = NULL;
#else
#include "ylmm.h"

static FOnNotify * g_lpOnNotify=NULL;
static FOnSyncRes *g_lpOnSyncRes=NULL;
static FOnMessageRes *g_lpOnMessageRes=NULL;
static FOnConnect *g_lpOnConnect=NULL;
static FOnClose *g_lpOnClose=NULL;
static FOnConnectTimeout *g_lpOnConnectTimeout=NULL;
static FOnRegisterSessionRes * g_lpOnRegisterSessionRes=NULL;
static FOnAcceptSessionRes * g_lpOnAcceptSessionRes=NULL;
static FOnFinishSessionRes * g_lpOnFinishSessionRes=NULL;
static FOnCheckSessionRes * g_lpOnCheckSessionRes=NULL;

#endif


GSClientSocket * g_ClientSocket=NULL;


static void OnSyncRes(char * msg);
static void OnNotify(char * data);
static void OnMessageRes(int retcode,int msgtype,int msgsn,char * data);
static void _OnConnect();
static void _OnConnectTimeout();
static void _OnClose();

static void OnRegisterSessionRes(long long sessionid,int code);
static void OnAcceptSessionRes(long long sessionid,int code,UID uid);//,int roomid,char *roomserverip,int roomport
static void OnFinishSessionRes(long long sessionid,int code,UID uid,UID peerid,long long createtime,long long accepttime,long long finishtime);
static void OnCheckSessionRes(long long sessionid,int status);

class MyClientSocketSink :public GSClientSocketSink {
public:
	~MyClientSocketSink(){};
public:
	void OnConnect(){_OnConnect();};
	void OnClose(){_OnClose();};
	void OnConnectTimeout(){_OnConnectTimeout();};
public:
	int OnRecvPacket( void * data,int len ){
		head_t * head=(head_t*)data;
		switch(head->opid){
		case OP_NOTIFY:{
			char * res=NULL;
			if(head->datalen>0){
				res=(char *)malloc(head->datalen+1);
				memset(res,0,head->datalen+1);
				memcpy(res,head+1,head->datalen);
			}

			OnNotify(res);

			if(res!=NULL){
				free(res);
			}
			break;
		}

		case OP_SYNC_RES:{
			//LOGE("1");
			sync_res_t *res=(sync_res_t *)(head+1);
			if(res->zipflag==1){
				//��Ҫ��ѹ
			}
			int len=res->length+16+100;//data+synckey+elsechar
			char * alljsondata=(char *)malloc(len);
			//LOGE("2");
			char * jsondata=(char *)malloc(res->length+1);
			memset(jsondata,0,res->length+1);
			memcpy(jsondata,res+1,res->length);
			//LOGE("3");
			sprintf(alljsondata,"{\"newsynckey\":\"%s\",\"data\":%s}",res->newsynckey,jsondata);
			//LOGE("4");
			OnSyncRes(alljsondata);
			//LOGE("5");
			free(jsondata);
			free(alljsondata);
			break;
		}


		case OP_MESSAGE_RES:{
			//LOGE("OP_MESSAGE_RES");
			sendmsg_res_t * res=(sendmsg_res_t *)(head+1);
			char * data=NULL;
			if(res->length>0){
				data=(char *)malloc(res->length);
				memcpy(data,res+1,res->length);
			}
			//LOGE("OP_MESSAGE_RES:%d",res->retcode);
			OnMessageRes(res->retcode,res->msgtype,res->msgsn,data);
			free(data);
			//LOGE("3");
			break;
		}


		case OP_REGISTERSESSION:{
			register_session_res_t * res=(register_session_res_t*)(head+1);
			OnRegisterSessionRes(res->sessionid,res->code);
			break;
		}

		case OP_ACCEPTSESSION:{
			accept_session_res_t * res=(accept_session_res_t*)(head+1);
			OnAcceptSessionRes(res->sessionid,res->code,res->uid);//,res->roomid,res->roomserverip,res->roomport
			break;
		}

		case OP_FINISHSESSION:{
			finish_session_res_t * res=(finish_session_res_t*)(head+1);
			OnFinishSessionRes(res->sessionid, res->code,res->uid,res->peerid,res->createtime,res->accepttime,res->finishtime);
			break;
		}

		case OP_CHECKSESSION:{
			check_session_res_t * res=(check_session_res_t*)(head+1);
			OnCheckSessionRes(res->sessionid,res->status);
		}

		}
		return 0;

	};
};
MyClientSocketSink * g_ss=NULL;

#ifdef ANDROID
//jstring to char*
char* jstringTostring(JNIEnv* env, jstring jstr)
{
	char* rtn = NULL;
	jclass clsstring = env->FindClass("java/lang/String");
	jstring strencode = env->NewStringUTF("utf-8");
	jmethodID mid = env->GetMethodID(clsstring, "getBytes", "(Ljava/lang/String;)[B");
	jbyteArray barr= (jbyteArray)env->CallObjectMethod(jstr, mid, strencode);
	jsize alen = env->GetArrayLength(barr);
	jbyte* ba = env->GetByteArrayElements(barr, JNI_FALSE);
	if (alen > 0)
	{
		rtn = (char*)malloc(alen + 1);
		memcpy(rtn, ba, alen);
		rtn[alen] = 0;
	}
	env->ReleaseByteArrayElements(barr, ba, 0);
	env->DeleteLocalRef(strencode);
	return rtn;
}

//char* to jstring
jstring stringTojstring(JNIEnv* env, const char* pat)
{
	if(pat!=NULL){
		return env->NewStringUTF(pat);
	}else{
		return env->NewStringUTF("");
	}
}

extern "C" JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM * vm,void * reserved){
  JNIEnv * env=NULL;
  jint result=-1;
  if(vm->GetEnv((void**)&env,JNI_VERSION_1_4)!=JNI_OK){
	  LOGE("GetEnv failed!");
	  return result;
  }

  g_jvm=vm;

  return JNI_VERSION_1_4;
}

extern "C" JNIEXPORT void Java_com_gitsoft_ylmm_ClientHelper_init(JNIEnv* env,
        jobject thiz){
	//env->GetJavaVM(&g_jvm);
	g_obj=env->NewGlobalRef(thiz);

	g_ss=new MyClientSocketSink();
	g_ClientSocket=new GSClientSocket();
	g_ClientSocket->SetSocketSink(g_ss);

	//pthread_cond_init(&g_cond,NULL);
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_connect(JNIEnv* env,
        jobject thiz,jstring ip,jint port){

	//LOGE("11111");
	if(g_ClientSocket==NULL) return -1;

	char * sip=jstringTostring(env,ip);
	//LOGE("sip:%s",sip);
	int ret=g_ClientSocket->Connect(sip,port);

	free(sip);
	//LOGE("ret:%d",ret);
	return ret;
}

extern "C" JNIEXPORT void Java_com_gitsoft_ylmm_ClientHelper_close(JNIEnv* env,
        jobject thiz){

	//LOGE("11111");
	if(g_ClientSocket==NULL) return;

	g_ClientSocket->Close();
}


extern "C" JNIEXPORT int Java_com_gitsoft_ylmm_ClientHelper_test(JNIEnv* env,
	jobject thiz){
	if(g_ClientSocket==NULL) return -1;
	int ret=g_ClientSocket->WriteCmd(OP_TEST,NULL,0);
	return ret;
}

int jni_sendMessageBase(UID uid,char * tokenstr,UID touid,int msgtype,char * msgstr,int msgsn){
	if(g_ClientSocket==NULL) return -1;

	int len=sizeof(sendmsg_t) + strlen(msgstr)+1;

	sendmsg_t * data=(sendmsg_t *)malloc(len);
	memset(data,0,len);
	data->msgtype=msgtype;
	data->uid=uid;
	data->touid=touid;
	data->msgsn=msgsn;
	data->msglength=strlen(msgstr);
	//LOGE("a:%s",tokenstr);
	memcpy(data->token,tokenstr,sizeof(data->token));
	//LOGE("d");
	memcpy(data+1,msgstr,strlen(msgstr));

	//LOGE("b");
	int ret=g_ClientSocket->WriteCmd(OP_MESSAGE,data,len);

	//LOGE("c");
	free(data);
	return ret;

}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_sendOneMessage(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong touid,jstring msg,jint msgsn){
	char * msgstr=jstringTostring(env,msg);
	char * tokenstr=jstringTostring(env,token);

	int ret=jni_sendMessageBase(uid,tokenstr,touid,MT_ONEMSG,msgstr,msgsn);

	free(msgstr);
	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_sendMessage(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong touid,jstring msg,jint msgsn){
	char * msgstr=jstringTostring(env,msg);
	char * tokenstr=jstringTostring(env,token);

	int ret=jni_sendMessageBase(uid,tokenstr,touid,MT_P2P,msgstr,msgsn);

	free(msgstr);
	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_sendGroupMessage(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong gid,jstring msg,jint msgsn){
	char * msgstr=jstringTostring(env,msg);
	char * tokenstr=jstringTostring(env,token);

	int ret=jni_sendMessageBase(uid,tokenstr,gid,MT_GROUP,msgstr,msgsn);

	free(msgstr);
	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_addFriend(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong touid,jstring userinfo,jint msgsn){
	char * msgstr=jstringTostring(env,userinfo);
	char * tokenstr=jstringTostring(env,token);

	int ret=jni_sendMessageBase(uid,tokenstr,touid,MT_ADDFRIEND,msgstr,msgsn);

	free(msgstr);
	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_acceptFriend(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong touid,jint msgsn){
	char * tokenstr=jstringTostring(env,token);
	int ret=jni_sendMessageBase(uid,tokenstr,touid,MT_ACCEPTFRIEND,"{}",msgsn);

	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_removeFriend(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jlong touid,jint msgsn){
	char * tokenstr=jstringTostring(env,token);
	int ret=jni_sendMessageBase(uid,tokenstr,touid,MT_REMOVEFRIEND,"{}",msgsn);

	free(tokenstr);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_sync(JNIEnv* env,
        jobject thiz,jlong uid,jstring token,jstring synckey){

	if(g_ClientSocket==NULL) return -1;

	char * tokenstr=jstringTostring(env,token);
	char * synckeystr=jstringTostring(env,synckey);

	sync_t * sync=(sync_t *)malloc(sizeof(sync_t));
	memset(sync,0,sizeof(sync_t));
	sync->uid=uid;
	memcpy(sync->token,tokenstr,sizeof(sync->token));
	memcpy(sync->synckey,synckeystr,sizeof(sync->synckey));

	int ret=g_ClientSocket->WriteCmd(OP_SYNC,sync,sizeof(sync_t));

	free(tokenstr);
	free(synckeystr);

	free(sync);

	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_registerSession(JNIEnv* env,
		jobject thiz,jlong uid,jstring token){//,jstring roomip,jint roomid,jint roomport
	int ret=0;

	if(g_ClientSocket==NULL) return -1;
	char * tokenstr=jstringTostring(env,token);
	//char * roomipstr=jstringTostring(env,roomip);

	register_session_t * register_session=(register_session_t *)malloc(sizeof(register_session_t));
	memset(register_session,0,sizeof(register_session_t));
	register_session->uid=uid;
	//register_session->roomid=roomid;
	//register_session->roomport=roomport;
	//memcpy(register_session->roomserverip,roomipstr,sizeof(register_session->roomserverip));

	ret=g_ClientSocket->WriteCmd(OP_REGISTERSESSION,register_session,sizeof(register_session_t));

	free(tokenstr);
	//free(roomipstr);

	free(register_session);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_acceptSession(JNIEnv* env,
		jobject thiz,jlong uid,jstring token,jlong sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;
	char * tokenstr=jstringTostring(env,token);

	accept_session_t * accept_session=(accept_session_t *)malloc(sizeof(accept_session_t));
	memset(accept_session,0,sizeof(accept_session_t));
	accept_session->uid=uid;
	accept_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_ACCEPTSESSION,accept_session,sizeof(accept_session_t));

	free(tokenstr);

	free(accept_session);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_checkSession(JNIEnv* env,
		jobject thiz,jlong uid,jstring token,jlong sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;
	char * tokenstr=jstringTostring(env,token);

	check_session_t * check_session=(check_session_t *)malloc(sizeof(check_session_t));
	memset(check_session,0,sizeof(check_session_t));
	//accept_session->uid=uid;
	check_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_CHECKSESSION,check_session,sizeof(check_session_t));

	free(tokenstr);

	free(check_session);
	return ret;
}

extern "C" JNIEXPORT jint Java_com_gitsoft_ylmm_ClientHelper_finishSession(JNIEnv* env,
		jobject thiz,jlong uid,jstring token,jlong sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;
	char * tokenstr=jstringTostring(env,token);

	finish_session_t * finish_session=(finish_session_t *)malloc(sizeof(finish_session_t));
	memset(finish_session,0,sizeof(finish_session_t));
	finish_session->uid=uid;
	finish_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_FINISHSESSION,finish_session,sizeof(finish_session_t));

	free(tokenstr);

	free(finish_session);
	return ret;
}


static void OnSyncRes(char * msg){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	jstring msgstr;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}


	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	//LOGE("1");
	methodid=env->GetMethodID(cls,"OnSyncRes","(Ljava/lang/String;)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}
	//LOGE("2");
	//LOGE(msg);
	msgstr=stringTojstring(env,msg);
	//LOGE("3");
	env->CallVoidMethod(g_obj,methodid,msgstr);

	env->DeleteLocalRef(msgstr);
	//LOGE("4");

error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnNotify(char * data){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	jstring sdata;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnNotify","(Ljava/lang/String;)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	sdata=stringTojstring(env,data);
	env->CallVoidMethod(g_obj,methodid,sdata);
	env->DeleteLocalRef(sdata);
error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnMessageRes(int retcode,int msgtype,int msgsn,char * data){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	jstring sdata;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);

	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnMessageRes","(IIILjava/lang/String;)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	//LOGE("4");
	sdata=stringTojstring(env,data);
	//LOGE(sdata);
	env->CallVoidMethod(g_obj,methodid,retcode,msgtype,msgsn,sdata);
	env->DeleteLocalRef(sdata);
	//LOGE("5");

error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}


static void _OnConnect(){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnConnect","()V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	env->CallVoidMethod(g_obj,methodid);

error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void _OnClose(){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnClose","()V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	env->CallVoidMethod(g_obj,methodid);

error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void _OnConnectTimeout(){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnConnectTimeout","()V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	env->CallVoidMethod(g_obj,methodid);

error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnRegisterSessionRes(long long sessionid,int code){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	//jstring sdata;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnRegisterSessionRes","(JI)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	//sdata=stringTojstring(env,data);
	env->CallVoidMethod(g_obj,methodid,sessionid,code);
	//env->DeleteLocalRef(sdata);
error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnAcceptSessionRes(long long sessionid,int code,UID uid){//,int roomid,char *roomserverip,int roomport
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	//jstring sroomserverip;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnAcceptSessionRes","(JIJ)V");//IILjava/lang/String;
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	//sroomserverip=stringTojstring(env,roomserverip);
	env->CallVoidMethod(g_obj,methodid,sessionid,code,uid);  //roomid,sroomserverip,roomport,
	//env->DeleteLocalRef(sroomserverip);
error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnFinishSessionRes(long long sessionid,int code,UID uid,UID peerid,long long createtime,long long accepttime,long long finishtime){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	//jstring sdata;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnFinishSessionRes","(JIJJJJJ)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	//sdata=stringTojstring(env,data);
	env->CallVoidMethod(g_obj,methodid,sessionid,code,uid,peerid,createtime,accepttime,finishtime);
	//env->DeleteLocalRef(sdata);
error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

static void OnCheckSessionRes(long long sessionid,int status){
	JNIEnv * env;
	jclass cls;
	jmethodID methodid;

	//jstring sdata;

	if(g_jvm->AttachCurrentThread(&env,NULL)!=JNI_OK){
		LOGE("%s:AttachCurrentThread() failed",__FUNCTION__);
		return;
	}

	cls=env->GetObjectClass(g_obj);
	if(cls==NULL){
		LOGE("FindClass() Error");
		goto error;
	}

	methodid=env->GetMethodID(cls,"OnCheckSessionRes","(JI)V");
	if(methodid==NULL){
		LOGE("GetMethodID() Error");
		goto error;
	}

	//sdata=stringTojstring(env,data);
	env->CallVoidMethod(g_obj,methodid,sessionid,status);
	//env->DeleteLocalRef(sdata);
error:
    if(g_jvm->DetachCurrentThread()!=JNI_OK){
    	LOGE("%s: DetachCurrentThread() failed", __FUNCTION__);
    }
}

#else

void _init(FOnNotify * lpOnNotify, FOnSyncRes *lpOnSyncRes, FOnMessageRes *lpOnMessageRes, FOnConnect *lpOnConnect, FOnClose *lpOnClose, FOnConnectTimeout *lpOnConnectTimeOut){
    g_lpOnNotify=lpOnNotify;
    g_lpOnSyncRes = lpOnSyncRes;
    g_lpOnMessageRes = lpOnMessageRes;
    g_lpOnConnect = lpOnConnect;
    g_lpOnClose = lpOnClose;
    g_lpOnConnectTimeout = lpOnConnectTimeOut;
	g_ss=new MyClientSocketSink();
	g_ClientSocket=new GSClientSocket();
	g_ClientSocket->SetSocketSink(g_ss);

}

void _setVideoSessionFun(FOnRegisterSessionRes * lpOnRegisterSessionRes,FOnAcceptSessionRes * lpOnAcceptSessionRes,FOnFinishSessionRes * lpOnFinishSessionRes,FOnCheckSessionRes * lpOnCheckSessionRes){
	g_lpOnRegisterSessionRes=lpOnRegisterSessionRes;
	g_lpOnAcceptSessionRes=lpOnAcceptSessionRes;

	g_lpOnFinishSessionRes=lpOnFinishSessionRes;
	g_lpOnCheckSessionRes=lpOnCheckSessionRes;
}

int _connect(char * ip,int port){

	//LOGE("11111");
	//char * sip=jstringTostring(env,ip);
	//LOGE("sip:%s",sip);
	int ret=g_ClientSocket->Connect(ip,port);
	//g_uid=uid;
	//LOGE("ret:%d",ret);
	return ret;
}

int test(){
	if(g_ClientSocket==NULL) return -1;
	int ret=g_ClientSocket->WriteCmd(OP_TEST,NULL,0);
	return ret;
}

int sendMessageBase(UID uid,char * token,UID touid,int msgtype,char * msg,int msgsn){

	if(g_ClientSocket==NULL) return -1;

	char * msgstr=msg;
	char * tokenstr=token;
	int len=sizeof(sendmsg_t) + strlen(msgstr)+1;


	sendmsg_t * data=(sendmsg_t *)malloc(len);
	memset(data,0,len);
	data->msgtype=msgtype;
	data->uid=uid;
	data->touid=touid;
	data->msgsn=msgsn;
	data->msglength=strlen(msgstr);
	//LOGE("a:%s",tokenstr);
	memcpy(data->token,tokenstr,sizeof(data->token));
	//LOGE("d");
	memcpy(data+1,msgstr,strlen(msgstr));

	//LOGE("b");
	int ret=g_ClientSocket->WriteCmd(OP_MESSAGE,data,len);

	//LOGE("c");
	//free(msgstr);
	//free(tokenstr);

	free(data);
	return ret;
}


int sendMessage(UID uid,char * token,UID touid,char * msg,int msgsn){
	return sendMessageBase(uid,token,touid,MT_P2P,msg,msgsn);
}

int sendOneMessage(UID uid,char * token,UID touid,char * msg,int msgsn){
	return sendMessageBase(uid,token,touid,MT_ONEMSG,msg,msgsn);
}

int sendGroupMessage(UID uid,char * token,UID gid,char * msg,int msgsn){
	return sendMessageBase(uid,token,gid,MT_GROUP,msg,msgsn);
}

int addFriend(UID uid,char * token,UID touid,char * userinfo,int msgsn){
	return sendMessageBase(uid,token,touid,MT_ADDFRIEND,userinfo,msgsn);
}

int acceptFriend(UID uid,char * token,UID touid,int msgsn){
	return sendMessageBase(uid,token,touid,MT_ACCEPTFRIEND,"{}",msgsn);
}

int removeFriend(UID uid,char * token,UID touid,int msgsn){
	return sendMessageBase(uid,token,touid,MT_REMOVEFRIEND,"{}",msgsn);
}

bool _isConnected(){
    if (g_ClientSocket==NULL){
        return false;
    }
    return g_ClientSocket->IsConnected();
}


int _sync(UID uid,char * token,char * synckey){

	char * tokenstr=token;
	char * synckeystr=synckey;

	sync_t * sync=(sync_t *)malloc(sizeof(sync_t));
	memset(sync,0,sizeof(sync_t));
	sync->uid=uid;
	memcpy(sync->token,tokenstr,sizeof(sync->token));
	memcpy(sync->synckey,synckeystr,sizeof(sync->synckey));

	int ret=g_ClientSocket->WriteCmd(OP_SYNC,sync,sizeof(sync_t));

	free(sync);

	return ret;
}

int _registerSession(UID uid,char * token){//,char * roomip,int roomid,int roomport
	int ret=0;

	if(g_ClientSocket==NULL) return -1;

	register_session_t * register_session=(register_session_t *)malloc(sizeof(register_session_t));
	memset(register_session,0,sizeof(register_session_t));
	register_session->uid=uid;
	//register_session->roomid=roomid;
	//register_session->roomport=roomport;
	//memcpy(register_session->roomserverip,roomip,sizeof(register_session->roomserverip));

	ret=g_ClientSocket->WriteCmd(OP_REGISTERSESSION,register_session,sizeof(register_session_t));

	free(register_session);
	return ret;
}

int _acceptSession(UID uid,char * token,long long sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;

	accept_session_t * accept_session=(accept_session_t *)malloc(sizeof(accept_session_t));
	memset(accept_session,0,sizeof(accept_session_t));
	accept_session->uid=uid;
	accept_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_ACCEPTSESSION,accept_session,sizeof(accept_session_t));

	free(accept_session);
	return ret;
}

int _finishSession(UID uid,char * token,long long sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;

	finish_session_t * finish_session=(finish_session_t *)malloc(sizeof(finish_session_t));
	memset(finish_session,0,sizeof(finish_session_t));
	finish_session->uid=uid;
	finish_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_FINISHSESSION,finish_session,sizeof(finish_session_t));

	free(finish_session);
	return ret;
}

int _checkSession(UID uid,char * token,long long sessionid){
	int ret=0;

	if(g_ClientSocket==NULL) return -1;

	check_session_t * check_session=(check_session_t *)malloc(sizeof(check_session_t));
	memset(check_session,0,sizeof(check_session_t));
	//finish_session->uid=uid;
    
	check_session->sessionid=sessionid;

	ret=g_ClientSocket->WriteCmd(OP_CHECKSESSION,check_session,sizeof(check_session_t));

	free(check_session);
	return ret;
}

void _close(){
	if(g_ClientSocket==NULL) return;
	g_ClientSocket->Close();
}

static void OnSyncRes(char * msg){
	if(g_lpOnSyncRes){
		(*g_lpOnSyncRes)(msg);
	}
}

static void OnNotify(char *data){
	if(g_lpOnNotify){
		(*g_lpOnNotify)(data);
	}
}

static void OnMessageRes(int retcode,int msgtype,int msgsn,char * data){
	if(g_lpOnMessageRes){
		(*g_lpOnMessageRes)(retcode,msgtype,msgsn,data);
	}
}


static void _OnConnect(){
	if(g_lpOnConnect){
		(*g_lpOnConnect)();
	}
}

static void _OnClose(){
	if(g_lpOnClose){
		(*g_lpOnClose)();
	}
}

static void _OnConnectTimeout(){
	if(g_lpOnConnectTimeout){
		(*g_lpOnConnectTimeout)();
	}
}

static void OnRegisterSessionRes(long long sessionid,int code){
	if(g_lpOnRegisterSessionRes){
		(*g_lpOnRegisterSessionRes)(sessionid,code);
	}
}

static void OnAcceptSessionRes(long long sessionid,int code,UID uid){//,int roomid,char *roomserverip,int roomport
	if(g_lpOnAcceptSessionRes){
		(*g_lpOnAcceptSessionRes)(sessionid,code,uid);//,roomid,roomserverip,roomport
	}
}

static void OnFinishSessionRes(long long sessionid,int code,UID uid,UID peerid,long long createtime,long long accepttime,long long finishtime){
	if(g_lpOnFinishSessionRes){
		(*g_lpOnFinishSessionRes)(sessionid,code,uid,peerid,createtime,accepttime,finishtime);
	}
}

static void OnCheckSessionRes(long long sessionid,int status){
	if(g_lpOnCheckSessionRes){
		(*g_lpOnCheckSessionRes)(sessionid,status);
	}
}


#endif

