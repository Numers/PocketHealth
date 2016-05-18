//
//  PHAddDetailMemberFkViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/30.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"
#import "PHProtocol.h"
@interface PHAddDetailMemberFkViewController : UIViewController

-(id)initWithMember:(Member *)member;
@property(nonatomic, assign) id<PHPushChatViewDelegate> delegate;
@end
