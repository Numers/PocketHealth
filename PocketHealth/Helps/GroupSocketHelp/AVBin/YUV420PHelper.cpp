
#include "YUV420Phelper.h"

#include <stdlib.h>
#include <string.h>
#include <math.h>

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "native-activity", __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "native-activity", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "native-activity", __VA_ARGS__))
#endif

////////////////////////////////////////////////
//本类支持对YUV420P格式的图像进行选择，镜像和缩放功能
//
//YUV420P包含一下两种格式
//Yv12格式  YYYYYYYY VV UU
//I420格式  YYYYYYYY UU VV
//旋转对于这两种格式来说，没有区别
//只支持90，180，270三种旋转，0度只是原始数据复制
//flip_horizontal和flip_vertical是镜像反转
//
//xugp 2015.1.7
//qhsoft@gmail.com
//此代码消耗了海量脑细胞，请保持敬畏之心使用。
//
////////////////////////////////////////////////

YUV420PHelper::YUV420PHelper(void)
{
}

YUV420PHelper::~YUV420PHelper(void)
{
}

void YUV420PHelper::swapUV(BYTE *data,int width,int height){
	int ysize=width*height;
	int usize=ysize/4;
	BYTE * tmp=(BYTE*)malloc(usize);
	memcpy(tmp,data+ysize,usize);
	memcpy(data+ysize,data+ysize+usize,usize);
	memcpy(data+ysize+usize,tmp,usize);
	free(tmp);
}

void YUV420PHelper::uvuv2uuvv(BYTE *data,int width,int height){
	int ysize=width*height;
	int usize=ysize/4;
	BYTE * tmpu=(BYTE*)malloc(usize);
	BYTE * tmpv=(BYTE*)malloc(usize);

	for(int i=0;i<usize;i++){
		tmpu[i]=data[ysize+i*2];
		tmpv[i]=data[ysize+i*2+1];
	}

	memcpy(data+ysize,tmpu,usize);
	memcpy(data+ysize+usize,tmpv,usize);
	free(tmpu);
	free(tmpv);
}

void YUV420PHelper::rotate(BYTE *des,BYTE *src,int width,int height,int rotation){
	switch(rotation){
	case 90: return YUV420PHelper::rotate_90(des,src,width,height);
	case 180: return YUV420PHelper::rotate_180(des,src,width,height);
	case 270: return YUV420PHelper::rotate_270(des,src,width,height);
	default: return YUV420PHelper::rotate_0(des,src,width,height);
	}
}

void YUV420PHelper::rotate_0(BYTE *des,BYTE *src,int width,int height){
	int n=width*height + width*height/2;
	for(int i=0;i<n;i++){
		des[i]=src[i];
	}
}

void YUV420PHelper::rotate_90(BYTE *des,BYTE *src,int width,int height)
{
    int n = 0;
    int hw = width / 2;
    int hh = height / 2;
    //rotate y
    for(int j = 0; j < width;j++)
    {
        for(int i = height - 1; i >= 0; i--)
        {
            des[n++] = src[width * i + j];
        }
    }

    //rotate u
    BYTE *ptemp = src + width * height;
    for(int j = 0;j < hw;j++)
    {
        for(int i = hh - 1;i >= 0;i--)
        {
            des[n++] = ptemp[ hw*i + j ];
        }
    }

    //rotate v
    ptemp += width * height / 4;
    for(int j = 0; j < hw; j++)
    {
        for(int i = hh - 1;i >= 0;i--)
        {
            des[n++] = ptemp[hw*i + j];
        }
    }
}

void YUV420PHelper::rotate_180(BYTE *des,BYTE *src,int width,int height)
{
    int n = 0;
    int hw = width / 2;
    int hh = height / 2;
    //rotate y
    for(int j = height - 1; j >= 0; j--)
    {
        for(int i = width; i > 0; i--)
        {
            des[n++] = src[width*j + i];
        }
    }

    //rotate u
    BYTE *ptemp = src + width * height;
    for(int j = hh - 1;j >= 0; j--)
    {
        for(int i = hw; i > 0; i--)
        {
            des[n++] = ptemp[hw * j + i];
        }
    }

    //rotate v
    ptemp += width * height / 4;
    for(int j = hh - 1;j >= 0; j--)
    {
        for(int i = hw; i > 0; i--)
        {
            des[n++] = ptemp[hw * j + i];
        }
    }
}

void YUV420PHelper::rotate_270(BYTE *des,BYTE *src,int width,int height)
{
    int n = 0;
    int hw = width / 2;
    int hh = height / 2;
    //rotate y
    for(int j = width; j > 0; j--)
    {
        for(int i = 0; i < height;i++)
        {
            des[n++] = src[width*i + j];
        }
    }

    //rotate u
    BYTE *ptemp = src + width * height;
    for(int j = hw; j > 0;j--)
    {
        for(int i = 0; i < hh;i++)
        {
            des[n++] = ptemp[hw * i + j];
        }
    }

    //rotate v
    ptemp += width * height / 4;
    for(int j = hw; j > 0;j--)
    {
        for(int i = 0; i < hh;i++)
        {
            des[n++] = ptemp[hw * i + j];
        }
    }
}

void YUV420PHelper::flip_horizontal(BYTE *des,BYTE *src,int width,int height)
{
    int n = 0;
    int hw = width / 2;
    int hh = height / 2;
    //rotate y
    for(int j = 0; j < height; j++)
    {
        for(int i = width - 1;i >= 0;i--)
        {
            des[n++] = src[width * j + i];
        }
    }

    //rotate u
    BYTE *ptemp = src + width * height;
    for(int j = 0; j < hh; j++)
    {
        for(int i = hw - 1;i >= 0;i--)
        {
            des[n++] = ptemp[hw * j + i];
        }
    }

    //rotate v
    ptemp += width * height / 4;
    for(int j = 0; j < hh; j++)
    {
        for(int i = hw - 1;i >= 0;i--)
        {
            des[n++] = ptemp[hw * j + i];
        }
    }
}

void YUV420PHelper::flip_vertical(BYTE *des,BYTE *src,int width,int height)
{
    int n = 0;
    int hw = width / 2;
    int hh = height / 2;
    //rotate y
    for(int j = 0; j < width;j++)
    {
        for(int i = height - 1; i >= 0;i--)
        {
            des[n++] = src[width * i + j];
        }
    }

    //rotate u
    BYTE *ptemp = src + width * height;
    for(int j = 0; j < hw; j++)
    {
        for(int i = hh - 1; i >= 0;i--)
        {
            des[n++] = ptemp[ hw * i + j];
        }
    }

    //rotate v
    ptemp += width * height / 4;
    for(int j = 0; j < hw; j++)
    {
        for(int i = hh - 1; i >= 0; i--)
        {
            des[n++] = ptemp[ hw * i + j];
        }
    }
}


//按比例缩放，比例不对时，黑边处理
int YUV420PHelper::resize(BYTE *des,int desWidth,int desHeight,BYTE *src,int srcWidth,int srcHeight){

	register int i,j;
	float scale=(float)desWidth/desHeight;
	float srcScale=(float)srcWidth/srcHeight;

	int desStartX=0,desStartY=0;
	int desRealWidth=desWidth,desRealHeight=desHeight;
	float resizeScale=1.0;
	if(srcScale>scale){
		//上下留黑
		resizeScale=(float)srcWidth/desWidth;
		desRealHeight=srcHeight/resizeScale;
		desStartY=(desHeight-desRealHeight)/2;

	}else{
		//左右留黑
		resizeScale=(float)srcHeight/desHeight;
		desRealWidth=srcWidth/resizeScale;
		desStartX=(desWidth-desRealWidth)/2;
	}

	//置全黑
	int desYSize=desWidth*desHeight;
	int desUSize=desYSize/4;
	int desVSize=desUSize;

	//Y全部置0
	for(i=0;i<desYSize;i++){
		des[i]=0;
	}
	//UV全部置128
	for(i=0;i<desUSize+desVSize;i++){
		des[desYSize+i]=128;
	}
	//LOGW("333333");

	//置黑完成

	unsigned int idxDes=0,idxSrc=0;

	/////////////////////////////////////////////////
	//灰度缩放
	/////////////////////////////////////////////////
	//未优化代码
	/*
	for(i=0;i<desRealHeight;i++){
		for(j=0;j<desRealWidth;j++){
			idxDes= desWidth*(i+desStartY) + j + desStartX;
			idxSrc=srcWidth*i*resizeScale +j*resizeScale;
			des[idxDes]=src[idxSrc];
		}
	}
	//*/

	//优化
	///*
	float desWidthxdesStartY=desWidth*desStartY;
	float srcWidthxresizeScale=srcWidth*resizeScale;
	float desWidthxi=0;
	float srcWidthxresizeScalexi=0;
	for(i=0;i<desRealHeight;i++){
		float jxresizeScale=0;
		for(j=0;j<desRealWidth;j++){
			idxDes= desWidthxi+desWidthxdesStartY + j + desStartX;
			idxSrc=srcWidthxresizeScalexi +jxresizeScale;
			des[idxDes]=src[idxSrc];
			jxresizeScale+=resizeScale;
		}
		desWidthxi+=desWidth;
		srcWidthxresizeScalexi+=srcWidthxresizeScale;
	}
	//*/


	/////////////////////////////////////////////////

	int hw=desRealWidth/2;
	int hh=desRealHeight/2;
	int hdw=desWidth/2;
	int hsw=srcWidth/2;
	int seekSrc=srcWidth*srcHeight;
	int seekDes=desWidth*desHeight;


	////////////////////////////////////////////////////
	//未优化的可读版代码，变换U或者V部分
	////////////////////////////////////////////////////
	/*
	for(i=0;i<hh;i++){
		for(j=0;j<hw;j++){
			idxDes=hdw*(i+desStartY/2)+j+desStartX/2;
			idxSrc=hsw*i*resizeScale+j*resizeScale;

			des[idxDes+seekDes]=src[idxSrc+seekSrc];
		}
	}
	//*/


	////////////////////////////////////////////////////
	//已经优化版本
	////////////////////////////////////////////////////
	float hX=desStartX/2;
	float hY=desStartY/2;
	float hdwxhY=hdw*hY;
	float hswxresizeScale=hsw*resizeScale;

	float hdwxi,hswxresizeScalexi;

	hdwxi=0;
	hswxresizeScalexi=0;
	for(i=0;i<hh;i++){
		float jxresizeScale=0;
		for(j=0;j<hw;j++){
			idxDes=hdwxi+hdwxhY+j+hX;
			idxSrc=hswxresizeScalexi+jxresizeScale;
			des[idxDes+seekDes]=src[idxSrc+seekSrc];
			jxresizeScale+=resizeScale;
		}
		hdwxi+=hdw;
		hswxresizeScalexi+=hswxresizeScale;
	}

	seekSrc+=seekSrc/4; //seekSrc+=srcWidth*srcHeight/4;//简单优化，减少一次乘法
	seekDes+=seekDes/4; //seekDes+=desWidth*desHeight/4;//简单优化，减少一次乘法

	hdwxi=0;
	hswxresizeScalexi=0;
	for(i=0;i<hh;i++){
		float jxresizeScale=0;
		for(j=0;j<hw;j++){
			idxDes=hdwxi+hdwxhY+j+hX;
			idxSrc=hswxresizeScalexi+jxresizeScale;
			des[idxDes+seekDes]=src[idxSrc+seekSrc];
			jxresizeScale+=resizeScale;
		}
		hdwxi+=hdw;
		hswxresizeScalexi+=hswxresizeScale;
	}
	return 0;
}

int YUV420PHelper::resizeclip(BYTE *des,int desWidth,int desHeight,BYTE *src,int srcWidth,int srcHeight){
	float desScale=(float)desWidth/desHeight;
	float srcScale=(float)srcWidth/srcHeight;
	float scale=1;
	int startX=0,startY=0;
	if(srcScale<desScale){
		scale=(float)srcWidth/desWidth;
		startY=(srcHeight-desHeight*scale)/2;
	}else{
		scale=(float)srcHeight/desHeight;
		startX=(srcWidth-desWidth*scale)/2;
	}

	//LOGE("scale:%f,startX:%d,startY:%d\n",scale,startX,startY);

	int i,j;
	for(i=0;i<desHeight;i++){
		for(j=0;j<desWidth;j++){
			int desIdx=desWidth*i+j;
			int srcIdx=(floor(i*scale)+startY)*srcWidth+floor(j*scale)+startX;
			//LOGE("desIdx:%d,srcIdx:%d",desIdx,srcIdx);
			des[desIdx]=src[srcIdx];
		}
	}




	int desYSize=desHeight*desWidth;
	int srcYSize=srcWidth*srcHeight;
	int srcUSize=srcYSize/4;
	int desUSize=desYSize/4;
	int desVSize=desUSize;

	int hw=desWidth/2;
	int hh=desHeight/2;
	int hsw=srcWidth/2;
	int hsh=srcWidth/2;
	int hstartX=startX/2;
	int hstartY=startY/2;
	for(i=0;i<hh;i++){
		for(j=0;j<hw;j++){
			int desIdx=hw*i+j;
			int srcIdx=hsw*(floor(i*scale)+hstartY)+floor(j*scale)+hstartX;
			des[desYSize+desIdx]=src[srcYSize+srcIdx];
			des[desYSize+desUSize+desIdx]=src[srcYSize+srcUSize+srcIdx];
		}
	}

	return 0;
}


