//
//  YFQRCodeReaderViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol YFQRCodeReaderViewControllerDelegate <NSObject>

-(void)pushAddViewByDelegateNavi:(id)object;
-(void)pushWebViewByDelegateNavi:(NSURL *)urlStr;
@end


@interface YFQRCodeReaderViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewPreview;

@property (nonatomic, retain) UIImageView * line;
@property (nonatomic) CGRect lineFrame;
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic ,weak) id <YFQRCodeReaderViewControllerDelegate> delegate;
@end
