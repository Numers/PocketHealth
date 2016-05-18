//
//  PHGroupPersonalInfoViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/15.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMember.h"

//界面推送
#import "PHProtocol.h"

@protocol PHGroupPersonalInfoViewControllerDelegate <NSObject>

@optional
-(void)deleteSelectedMember:(GroupMember *)selectMember;

@end

@interface PHGroupPersonalInfoViewController : UIViewController

-(id)initWithGroupMember:(GroupMember *)member WithMyGroupHost:(GroupMember *)ghost;

@property (nonatomic ,weak) id <PHGroupPersonalInfoViewControllerDelegate> delegate;

@property (nonatomic,assign) id<PHPushChatViewDelegate> delegatePush;
@end
