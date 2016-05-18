//
//  PHChatHomeAddDetailResultViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"
#import "Group.h"

@protocol PHChatHomeAddDetailResultViewControllerDelegate <NSObject>

-(void)pushSearchResultMemberViewController:(Member *)member;
-(void)pushSearchResultGroupViewController:(Group *)group;
@end
@interface PHChatHomeAddDetailResultViewController : UIViewController<UISearchResultsUpdating>

@property (nonatomic , strong) NSMutableArray *resultArray;

@property (nonatomic,weak) id<PHChatHomeAddDetailResultViewControllerDelegate>delegate;
@property (nonatomic) float tableViewY;

-(void)reloadResultTableViewWithArray:(NSArray *)sendResultArray WithMemberType:(MemberUserType)memberUserType;
-(void)removeAllUserInResultArray;
@end
