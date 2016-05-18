//
//  PHUserCenterHeadView.h
//  PocketHealth
//
//  Created by macmini on 15-1-31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHUserCenterHeadViewDelegate <NSObject>
-(void)friendListBtnClick;
-(void)doctorListBtnClick;
-(void)organizationListBtnClick;
@end
@class Member;
@interface PHUserCenterHeadView : UITableViewHeaderFooterView
{
    UIButton *btnFriendList;
    UIButton *btnDoctorList;
    UIButton *btnOrganizationList;
    
    UILabel *lblFriend;
    UILabel *lblDoctor;
    UILabel *lblOrganization;
    
    UILabel *lblFriendCount;
    UILabel *lblDoctorCount;
    UILabel *lblOrganizationCount;
}

@property(nonatomic, weak) id<PHUserCenterHeadViewDelegate> delegate;
-(void)updateUIViewContentWithMember:(Member *)member;
@end
