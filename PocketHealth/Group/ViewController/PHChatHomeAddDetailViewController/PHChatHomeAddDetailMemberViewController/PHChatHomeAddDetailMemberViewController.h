//
//  PHChatHomeAddDetailMemberViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/3/5.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
// 这个界面用来作为 医院医生的搜索

#import <UIKit/UIKit.h>
#import "Member.h"
#import "Group.h"

@protocol PHChatHomeAddDetailResultViewControllerDelegate <NSObject>

-(void)pushSearchResultMemberViewController:(Member *)member;
-(void)pushSearchResultGroupViewController:(Group *)group;
@end
@interface PHChatHomeAddDetailMemberViewController : UIViewController<UISearchResultsUpdating>

@property (nonatomic , strong) NSMutableArray *resultArray;

@property (nonatomic,weak) id<PHChatHomeAddDetailResultViewControllerDelegate>delegate;
@property (nonatomic) float tableViewY;

-(void)reloadResultTableViewWithArray:(NSArray *)sendResultArray WithMemberType:(MemberUserType)memberUserType;
-(void)removeAllUserInResultArray;
@end
