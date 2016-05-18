//
//  PHNotificationUserInfoViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/2/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationMessage.h"

@protocol PHNotificationUserInfoViewControllerDelegate <NSObject>

-(void)agreeBtnClickReback:(NotificationMessage *)notificationMessage;

@end

@interface PHNotificationUserInfoViewController : UIViewController

@property (nonatomic ,strong) IBOutlet UITableView * tableView;
@property (nonatomic ,strong) NotificationMessage * notifiMessage;
@property (nonatomic , weak) id<PHNotificationUserInfoViewControllerDelegate> delegate;
@end
