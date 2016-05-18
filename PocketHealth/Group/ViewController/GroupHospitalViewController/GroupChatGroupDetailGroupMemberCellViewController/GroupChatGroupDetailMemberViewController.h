//
//  GroupChatGroupDetailMemberViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatGroupDetailMemberViewController : UIViewController
@property (strong, nonatomic) IBOutlet UICollectionView *memberListCollectView;
@property (strong, nonatomic) IBOutlet UILabel *groupMemberCount;

@property (strong, nonatomic) NSMutableArray * groupMemberList;
-(id)initWithFrame:(CGRect)frame;
@end
