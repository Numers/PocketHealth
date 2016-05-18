/*
 * YUV420PHelper.h
 *
 *  Created on: 2015��1��6��
 *      Author: xugp
 */

#ifndef YUV420PHELPER_H_
#define YUV420PHELPER_H_


typedef unsigned char BYTE;

class YUV420PHelper{

public:
	YUV420PHelper(void);
	~YUV420PHelper(void);

public:
	static void rotate_0(BYTE *des,BYTE *src,int width,int height); //����
	static void rotate_90(BYTE *des,BYTE *src,int width,int height);
	static void rotate_180(BYTE *des,BYTE *src,int width,int height);
	static void rotate_270(BYTE *des,BYTE *src,int width,int height);

	static void flip_horizontal(BYTE *des,BYTE *src,int width,int height);
	static void flip_vertical(BYTE *des,BYTE *src,int width,int height);

	static void rotate(BYTE *des,BYTE *src,int width,int height,int rotation);
	static int resize(BYTE *des,int desWidth,int desHeight,BYTE *src,int srcWidth,int srcHeight);

	static int resizeclip(BYTE *des,int desWidth,int desHeight,BYTE *src,int srcWidth,int srcHeight);

	//�Ե�UV���ݣ�Yv12��I420���ݻ�ת
	static void swapUV(BYTE *data,int width,int height);
	static void uvuv2uuvv(BYTE *data,int width,int height);

};



#endif /* YUV420PHELPER_H_ */