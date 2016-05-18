//
//  PHBackView.m
//  VideoDemo
//
//  Created by macmini on 15-3-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHBackView.h"
#import "PHVideoModelManager.h"
#import "PHAppStartManager.h"
#define BottomToolBarHeight 193.0f
#define TopToolBarHeight 92.0f

@implementation PHBackView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

-(void)countTime
{
    seconds++;
    if (topToolBar) {
        [topToolBar setTimeLabel:seconds];
    }
}

-(void)createAVModuleWithServerIP:(NSString *)serverIp WithPort:(int)port WithRoomId:(int)roomId WithUserId:(int)userId WithAnchorUserId:(int)anchorUserId WithFrameSize:(CGSize)size
{
    currentUserId = userId;
    currentAnchorUserid = anchorUserId;
    [[PHVideoModelManager defaultManager] createAVModuleWithServerIP:serverIp WithPort:port WithRoomId:roomId WithUserId:userId WithAnchorUserId:anchorUserId WithFrameSize:size InView:self];
    UIView *videoPreview = [[PHVideoModelManager defaultManager] returnVideoPreview];
    if (bottomToolBar == nil) {
        bottomToolBar = [[PHBackViewBottomToolBar alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, BottomToolBarHeight)];
        bottomToolBar.myDelegate = self;
        [self insertSubview:bottomToolBar belowSubview:videoPreview];
    }
    [bottomToolBar show];
    
    if (topToolBar == nil) {
        topToolBar = [[PHBackViewTopToolBar alloc] initWithFrame:CGRectMake(0, -TopToolBarHeight, self.frame.size.width, TopToolBarHeight)];
        topToolBar.myDelegate = self;
        [self insertSubview:topToolBar belowSubview:videoPreview];
    }
    [topToolBar show];
    
    [self bringSubviewToFront:videoPreview];
    seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    [timer fire];
}

-(void)shutDownCall
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
        if ([_delegate respondsToSelector:@selector(passChatSeconds:)]) {
            [_delegate passChatSeconds:seconds];
        }
    }
    
    if ([[PHVideoModelManager defaultManager] isChatting]) {
        [[PHVideoModelManager defaultManager] deleteVideoOutPutWithAnchorUserId:currentAnchorUserid];
//        [toolBar hidden];
//        [toolBar removeFromSuperview];
//        toolBar = nil;
        if (bottomToolBar) {
            [bottomToolBar setUserInteractionEnabled:NO];
        }
        if ([_delegate respondsToSelector:@selector(alertCommentsViewWithTime:)]) {
            [_delegate alertCommentsViewWithTime:seconds];
        }
//        Member *host = [[PHAppStartManager defaultManager] userHost];
//        if (host.userType != MemberUserTypeDoctor) {
//            if (bottomToolBar) {
//                [bottomToolBar setUserInteractionEnabled:NO];
//            }
//            if ([_delegate respondsToSelector:@selector(alertCommentsViewWithTime:)]) {
//                [_delegate alertCommentsViewWithTime:seconds];
//            }
//        }else{
//            if ([_delegate respondsToSelector:@selector(dismissViewWithChatState:)]) {
//                [_delegate dismissViewWithChatState:YES];
//            }
//        }
        
    }else{
        if ([_delegate respondsToSelector:@selector(dismissViewWithChatState:)]) {
            [_delegate dismissViewWithChatState:NO];
        }
    }
}

-(void)releaseAllModel
{
    if (bottomToolBar) {
//        [bottomToolBar hidden];
        [bottomToolBar removeFromSuperview];
        bottomToolBar = nil;
    }
    
    if (topToolBar) {
//        [topToolBar hidden];
        [topToolBar removeFromSuperview];
        topToolBar = nil;
    }
}

-(void)hiddenOrShowTopAndBottomTool
{
    if ([bottomToolBar isShow]) {
        [bottomToolBar hidden];
    }else{
        [bottomToolBar show];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self hiddenOrShowTopAndBottomTool];
    if ([_delegate respondsToSelector:@selector(dismissComment)]) {
        [_delegate dismissComment];
    }
}

#pragma -mark PHBackViewBottomToolBarDelegate 主动挂断
-(void)shutUpCall
{
//    [[PHVideoModelManager defaultManager] deleteVideoOutPutWithAnchorUserId:currentAnchorUserid];
////    [toolBar hidden];
//    [toolBar removeFromSuperview];
//    toolBar = nil;
    if ([_delegate respondsToSelector:@selector(shutUpVideoCall)]) {
        [_delegate shutUpVideoCall];
    }
}

#pragma -mark PHBackViewTopToolBarDelegate
-(void)switchCamera
{
    if ([[PHVideoModelManager defaultManager] isChatting]) {
        [[PHVideoModelManager defaultManager] swapFrontAndBackCameras];
    }
}
@end
