//
//  GroupIndexTableViewCell.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Member,NotificationMessage,HospitalAggregation,GroupHelpAggregation,RKNotificationHub,Group;
@interface GroupIndexTableViewCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *headImageView;
@property(strong, nonatomic) IBOutlet UILabel *nickNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *messageLabel;
@property(strong, nonatomic) IBOutlet UILabel *timeLabel;
@property(strong, nonatomic) RKNotificationHub * countHub;

-(void)setUpCellWithMember:(Member *)member;
-(void)setUpCellWithGroup:(Group *)group;
-(void)setUpCellWithNotificaion:(NotificationMessage *)notificaionMsg;
-(void)setUpCellWithHospitalsAggregation:(HospitalAggregation *)hospitalAggregation;
-(void)setUpCellWithGroupsAggregation:(GroupHelpAggregation *)groupHelpAggregation;
@end
