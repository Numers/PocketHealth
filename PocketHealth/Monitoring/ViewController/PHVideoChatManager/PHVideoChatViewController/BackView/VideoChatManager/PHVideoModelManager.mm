//
//  PHVideoModelManager.m
//  VideoDemo
//
//  Created by macmini on 15-3-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHVideoModelManager.h"
#import "IAVModuleIOS.h"
#include "YUV420Phelper.h"

#define bufferTime 1000

#define inputWidth 640
#define inputHeight 480
#define scaleCount 0.8

static PHVideoModelManager *phVideoModelManager;
IAVModuleIOS    *g_pAVModule = NULL;
@implementation PHVideoModelManager
+(id)defaultManager
{
    if (phVideoModelManager == nil) {
        phVideoModelManager = [[PHVideoModelManager alloc] init];
        [phVideoModelManager setIsChatting:NO];
        
    }
    return phVideoModelManager;
}

-(void)setIsChatting:(BOOL)chat
{
    isChatting = chat;
}

-(BOOL)isChatting
{
    return isChatting;
}

-(UIView *)returnVideoPreview
{
    return phAVCaptureVideoPreView;
}

-(void)convertAVModelAndAVPreviewFrame
{
    if (phAVModelView.frame.size.width < phAVCaptureVideoPreView.frame.size.width) {
        [parentView sendSubviewToBack:phAVModelView];
        [parentView bringSubviewToFront:phAVCaptureVideoPreView];
    }else{
        [parentView bringSubviewToFront:phAVModelView];
        [parentView sendSubviewToBack:phAVCaptureVideoPreView];
    }
    CGRect frame;
    frame = phAVCaptureVideoPreView.frame;
    [phAVCaptureVideoPreView changeFrame:phAVModelView.frame];
    [phAVModelView changeFrame:frame];
    g_pAVModule->SetOutputPosition(currentAnchorUserid, 0, 0, frame.size.width, frame.size.height);
}

-(void)createAVModuleWithServerIP:(NSString *)serverIp WithPort:(int)port WithRoomId:(int)roomId WithUserId:(int)userId WithAnchorUserId:(int)anchorUserId WithFrameSize:(CGSize)size InView:(UIView *)view
{
    frameSize = size;
    parentView = view;
    isCanInsertData = YES;
    currentAnchorUserid = anchorUserId;
    phAVModelView = [[PHAVModelView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    if (g_pAVModule == NULL) {
        g_pAVModule = CreateAVModuleIOSObject();
        if (!g_pAVModule) {
            NSLog(@"CreateAVModuleIOSObject Failed!");
            return;
        }
    }
    
    if (!g_pAVModule ->InitAVModule((char *)[serverIp UTF8String], port, roomId, userId, bufferTime, 0, size.width, size.height, 10, 20, TRUE, 7, 16000, 1, 32000, 16, 1)) {
        g_pAVModule->Release();
        g_pAVModule = NULL;
        NSLog(@"InitAVModule Failed!");
        return;
    }
    NSLog(@"InitAVModule Success! ");
    
    g_pAVModule->InsertOutput(anchorUserId, (__bridge void *)phAVModelView, 0, 0, phAVModelView.frame.size.width, phAVModelView.frame.size.height);
    g_pAVModule->SetAudioStatus(1, YES);
    g_pAVModule->SetVideoStatus(1, YES);
    g_pAVModule->InsertInput(0);
    [parentView insertSubview:phAVModelView atIndex:0];
    [self setupCaptureSession];
    [phVideoModelManager setIsChatting:YES];
}

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    
    NSError *error = nil;
    
    // Create the session
    session = [[AVCaptureSession alloc] init] ;
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPreset640x480;
    
    // Find a suitable AVCaptureDevice
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];//这里默认是使用后置摄像头，你可以改成前置摄像头
//    [self swapFrontAndBackCameras];
    //默认前置摄像头
    AVCaptureDevice *device = [self frontCamera];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    
    
    // Configure your output.
    videoQueue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:phVideoModelManager queue:videoQueue];
    
    // Specify the pixel format
//    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
//                            [NSNumber numberWithInt: 240], (id)kCVPixelBufferWidthKey,
//                            [NSNumber numberWithInt: 320], (id)kCVPixelBufferHeightKey,
//                            nil];
    
    
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], (NSString *) kCVPixelBufferPixelFormatTypeKey,
                            nil];
    [session addOutput:output];

    phAVCaptureVideoPreView = [[PHAVCaptureVideoPreView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 78, 20, 78, 142) WithSession:session];
    [parentView addSubview:phAVCaptureVideoPreView];
    [parentView bringSubviewToFront:phAVCaptureVideoPreView];
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
//    output.minFrameDuration = CMTimeMake(1, 15);
    
    // Start the session running to start the flow of data
    [session startRunning];
    
    // Assign session to an ivar.
    //[self setSession:session];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{

    NSData *mData = imageToBuffer(sampleBuffer);
    BYTE * orgBuff =(BYTE *) [mData bytes];
    
    YUV420PHelper::uvuv2uuvv(orgBuff, inputWidth, inputHeight);
    
    BYTE * newbuff = (BYTE*)malloc(mData.length);
    YUV420PHelper::rotate_90(newbuff, orgBuff, inputWidth, inputHeight);
    
//    NSLog(@" vmData.length %u",mData.length);
    BYTE * newbuff2 = (BYTE *)malloc(frameSize.width*frameSize.height*1.5*scaleCount);
    
    YUV420PHelper::resizeclip(newbuff2, frameSize.width, frameSize.height*scaleCount, newbuff, inputHeight, inputWidth);
//
    BYTE * newbuff3 = (BYTE *)malloc(frameSize.width*frameSize.height*1.5);
    YUV420PHelper::resizeclip(newbuff3, frameSize.width, frameSize.height, newbuff2, frameSize.width, frameSize.height*scaleCount);
//    YUV420PHelper::resizeclip(newbuff2, frameSize.width, frameSize.height, newbuff3, frameSize.width, frameSize.height*0.9);
    if (g_pAVModule != NULL && isCanInsertData) {
        g_pAVModule->AddVideoData(newbuff3, frameSize.width*frameSize.height*1.5);
    }
    
    free(newbuff);
    free(newbuff2);
    free(newbuff3);
}

NSData* imageToBuffer( CMSampleBufferRef source) {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(source);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    OSType type = CVPixelBufferGetPixelFormatType(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);
     NSLog(@" width is :%zu -------  height is :%zu   bytesPerRow is :%zu type is %u",width,height , bytesPerRow,(unsigned int)type);
    NSData *data = [NSData dataWithBytes:src_buff length:bytesPerRow * height];
    //    NSData *data = [NSData dataWithBytes:src_buff length:width * height *1.5];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//    NSLog(@" data length %i",[data length]);
    return data;
}

-(void)deleteVideoOutPutWithAnchorUserId:(int)anchorUserid
{
    [session stopRunning];
//    dispatch_async(videoQueue, ^{
//        //
        isCanInsertData = NO;
//    });
    
        if (g_pAVModule) {
            @try {
                sleep(3);

                g_pAVModule->DeleteInput();
                g_pAVModule->DeleteOutput(anchorUserid);
//                g_pAVModule->DeleteAVOutput(anchorUserid);
                
                g_pAVModule->Release();
                g_pAVModule = NULL;
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                if (phAVCaptureVideoPreView) {
                    [phAVCaptureVideoPreView removeFromSuperview];
                    phAVCaptureVideoPreView = nil;
                }
                
                if (phAVModelView) {
                    [phAVModelView removeFromSuperview];
                    phAVModelView = nil;
                }
                [phVideoModelManager setIsChatting:NO];
                session = nil;
            }
        }

   

}

//设置为前置摄像头
- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}
/**
 *  切换前置后置摄像头方法
 */
- ( void ) swapFrontAndBackCameras {
    
    NSArray * inputs = session.inputs;
    for ( AVCaptureDeviceInput * INPUT in inputs ) {
        AVCaptureDevice * Device = INPUT. device ;
        if ( [ Device hasMediaType : AVMediaTypeVideo ] ) {
            AVCaptureDevicePosition position = Device . position ;
            AVCaptureDevice * newCamera = nil ;
            AVCaptureDeviceInput * newInput = nil ;
            
            if ( position == AVCaptureDevicePositionFront )
                newCamera = [ self cameraWithPosition : AVCaptureDevicePositionBack ] ;
            else
                newCamera = [ self cameraWithPosition : AVCaptureDevicePositionFront ] ;
            newInput = [ AVCaptureDeviceInput deviceInputWithDevice:newCamera error: nil ];
            
            
            
            [session beginConfiguration ] ;
            
            [session removeInput : INPUT ] ;
            [session addInput : newInput ] ;
            
            [session commitConfiguration ] ;
            break ;
        }
    } 
}
/**
 *  设置摄像头位置
 *
 *  @param position 位置AVCaptureDevicePosition
 *
 *  @return AVCaptureDevice
 */
- ( AVCaptureDevice * ) cameraWithPosition : ( AVCaptureDevicePosition ) position
{
    NSArray * Devices = [ AVCaptureDevice devicesWithMediaType : AVMediaTypeVideo ] ;
    for ( AVCaptureDevice * Device in Devices )
        if ( Device . position == position )
            return Device ;
    return nil ;
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
//    // Free up the context and color space
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
//    // Release the Quartz image
//    CGImageRelease(quartzImage);
    
    return (image);
}
@end
