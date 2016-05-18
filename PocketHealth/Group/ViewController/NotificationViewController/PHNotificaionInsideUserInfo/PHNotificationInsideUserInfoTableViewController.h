//
//  PHNotificationInsideUserInfoTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/20.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationMessage.h"

@protocol PHNotificationInsideUserInfoTableViewControllerDelegate <NSObject>

-(void)agreeBtnClickReback:(NotificationMessage *)notificationMessage;

@end


@interface PHNotificationInsideUserInfoTableViewController : UITableViewController

@property (nonatomic ,strong) NotificationMessage * notifiMessage;

@property (nonatomic , weak) id<PHNotificationInsideUserInfoTableViewControllerDelegate> delegate;
@end
