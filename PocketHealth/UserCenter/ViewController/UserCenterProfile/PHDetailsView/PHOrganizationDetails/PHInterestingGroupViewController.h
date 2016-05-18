//
//  PHInterestingGroupViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@protocol PHInterestingGroupDelegate <NSObject>
-(void)selectGroupCellWithGroup:(Group *)g;
@end

@interface PHInterestingGroupViewController : UIViewController
@property(nonatomic, assign) id<PHInterestingGroupDelegate> delegate;
-(id)initWithGroups:(NSMutableArray *)groupList;
@end
