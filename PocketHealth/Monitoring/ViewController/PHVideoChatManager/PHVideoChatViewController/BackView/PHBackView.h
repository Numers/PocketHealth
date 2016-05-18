//
//  PHBackView.h
//  VideoDemo
//
//  Created by macmini on 15-3-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHBackViewBottomToolBar.h"
#import "PHBackViewTopToolBar.h"
@protocol PHBackViewDelegate <NSObject>
-(void)shutUpVideoCall;
-(void)alertCommentsViewWithTime:(NSTimeInterval)time;
-(void)dismissViewWithChatState:(BOOL)isChatting;
-(void)passChatSeconds:(NSInteger)sec;
-(void)dismissComment;
@end
@interface PHBackView : UIView<PHBackViewBottomToolBarDelegate,PHBackViewTopToolBarDelegate>
{
    PHBackViewBottomToolBar *bottomToolBar;
    PHBackViewTopToolBar *topToolBar;
    int currentUserId;
    int currentAnchorUserid;
    
    NSTimer *timer;
    NSInteger seconds;
}
@property(nonatomic, assign) id<PHBackViewDelegate> delegate;
-(void)createAVModuleWithServerIP:(NSString *)serverIp WithPort:(int)port WithRoomId:(int)roomId WithUserId:(int)userId WithAnchorUserId:(int)anchorUserId WithFrameSize:(CGSize)size;
-(void)shutDownCall;//被动挂断
-(void)releaseAllModel;
-(void)hiddenOrShowTopAndBottomTool;
@end
