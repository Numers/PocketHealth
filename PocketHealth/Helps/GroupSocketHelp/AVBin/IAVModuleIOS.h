//
//  IAVMoudle.h
//  AVModule
//
//  Created by cress on 13-3-17.
//
//

#ifndef AVModule_IAVMoudle_h
#define AVModule_IAVMoudle_h

#define ADelayBufferCount 5

class IAVCallback
{
public:
    virtual void OnAudioOtherData(unsigned char *pOtherData, int nLength) = 0;
};

class IAVModuleIOS
{
public:
    virtual int GetWaveOutPlayCount(int nUserID) = 0;
    virtual void SetAVCallback(IAVCallback *pCall) = 0;
    
    virtual void SetDefaultBitmap(char *buffer, int length) = 0;
    /*
     jstring serverip, jint port, jint roomid, jint userid, jint bufferTime,
     //video info
     jint videoCodec, jint width, jint height, jint frame, jint quality, jint openVideo,
     //audio info
     jint audioCodec, jint sampleRate, jint channels, jint bitRate, jint bitSample, jint openAudio
     */
	virtual bool InitAVModule(char *serverip, int port, int roomid, int userid, int bufferTime,
                      //video info
                      int videoCodec, int width, int height, int frame, int quality, int openVideo,
                      //audio info
                      int audioCodec, int sampleRate, int channels, int bitRate, int bitSample, int openAudio) = 0;
	virtual void Release() = 0;
	virtual void InsertOutput(int nUserID, void *pWindow, int x, int y, int width, int height) = 0;
	virtual void DeleteOutput(int nUserID) = 0;
	virtual void SetAudioStatus(int nUserID, bool bAudio) = 0;
	virtual void SetVideoStatus(int nUserID, bool bVideo) = 0;
    
	virtual void StopAVOutput(int nUserID) = 0;
	virtual void DeleteAVOutput(int nUserID) = 0;
    virtual int GetNetRate() = 0;
    
    virtual void InsertInput(bool bWaveIn) = 0;
	virtual void DeleteInput() = 0;
	virtual void AddInputAudioData(char *pData, int nDataLength) = 0;
	virtual void AddInputAudioDataEx(char *pData, int nDataLength, char *pOtherData, int nOtherDataLength) = 0;
    virtual int GetAudioEncodeFrameSize() = 0;
    virtual void SetInputAudioStatus(bool bAudio) = 0;
    virtual void SetBaseInfo(char *serverip, int port, int roomid, int userid, int bufferTime) = 0;
    virtual void SetOutputStereoEffect(bool bOpen, int nDelay, float fBalance) = 0;
    virtual void SetOutputPosition(int nUserID, int x, int y, int width, int height) = 0;
    virtual bool  AddVideoData(unsigned char *pBuffer, int nLength, bool bEncode = true, bool bIFrame = false) = 0;
    
};


#ifdef __cplusplus
extern "C" {
#endif

    
    IAVModuleIOS * CreateAVModuleIOSObject(void);
    

#ifdef __cplusplus
}

#endif 

#endif
