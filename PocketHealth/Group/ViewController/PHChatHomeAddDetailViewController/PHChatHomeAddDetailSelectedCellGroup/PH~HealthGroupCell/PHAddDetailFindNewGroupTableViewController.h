//
//  PHAddDetailFindNewGroupTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
//pop委托
#import "PHProtocol.h"

@interface PHAddDetailFindNewGroupTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong , nonatomic) UISearchController * searchController;
@property (strong , nonatomic)  UISearchBar * searchBarIOS7;
@property (nonatomic , weak) id<PHPushChatViewDelegate> delegate;
@property (nonatomic , strong) UITableView * tableView;
@end
