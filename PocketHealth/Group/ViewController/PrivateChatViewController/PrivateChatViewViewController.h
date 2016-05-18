//
//  PrivateChatViewViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateChatTableViewController.h"
#import "ZBMessageInputView.h"
#import "ZBMessageShareMenuView.h"
#import "ZBMessageManagerFaceView.h"
#import <AVFoundation/AVFoundation.h>

@class ChatRecorderView;
@interface PrivateChatViewViewController : PrivateChatTableViewController<UITextFieldDelegate,ZBMessageInputViewDelegate,ZBMessageShareMenuViewDelegate,ZBMessageManagerFaceViewDelegate>
{
    BOOL recording;
    AVAudioRecorder *audioRecorder;
    NSURL *pathURL;
    NSString *amrFileName;
    
    NSTimeInterval _timeLen;
    
    ChatRecorderView *recorderView;
    NSTimer *recorderViewTimer;
    CGPoint curTouchPoint;      //触摸点
    BOOL canNotSend;
    CGFloat curCount;           //当前计数,初始为0
}

@property (nonatomic,strong) ZBMessageInputView *messageToolView;

@property (nonatomic,strong) ZBMessageManagerFaceView *faceView;

@property (nonatomic,strong) ZBMessageShareMenuView *shareMenuView;
@property (nonatomic,assign) CGFloat previousTextViewContentHeight;

@end
