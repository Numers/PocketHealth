//
//  GroupIndexTableViewCell.m
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupIndexTableViewCell.h"

#import "Member.h"
#import "OneForOneMessage.h"

#import "NotificationMessage.h"
#import "HospitalAggregation.h"
#import "GroupHelpAggregation.h"

#import "Group.h"
#import "GroupMessage.h"

#import "CommonUtil.h"
#import "UIImageView+WebCache.h"
#import "RKNotificationHub.h"

#import "GlobalVar.h"


@implementation GroupIndexTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 4.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpCellWithMember:(Member *)member
{
    if (self.headImageView == nil) {
        self.headImageView = [[UIImageView alloc] init];
    }

    
    if (self.nickNameLabel == nil) {
        self.nickNameLabel = [[UILabel alloc] init];
    }
    if (member.userType == MemberUserTypeAdmin) {
        self.nickNameLabel.text = member.nickName;
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:member.headImage] placeholderImage:[UIImage imageNamed:DefaultOrganizationHeadImage]];
    }else{
        self.nickNameLabel.text = member.nickName;
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:member.headImage] placeholderImage:[UIImage imageNamed:DefaultUserHeadImage]];
    }
    
    if (self.messageLabel == nil) {
        self.messageLabel = [[UILabel alloc] init];
    }
    
    if (self.timeLabel == nil) {
        self.timeLabel = [[UILabel alloc ] init];
    }
    
    if (member.sessionDate == 0) {
        self.timeLabel.text = @"";
    }else{
        self.timeLabel.text = [CommonUtil TimeStrWithInterval:member.sessionDate];
    }
    
    
    if (member.messageArr.count > 0) {
        OneForOneMessage *message = (OneForOneMessage *)[member.messageArr objectAtIndex:member.messageArr.count-1];
        self.messageLabel.text = [self contentStringHandle:message.contentType WithMainStr:message.content];
//        MessageContentType contentType = [message messageContentType];
//        if (contentType == MessageContentText) {
//            self.messageLabel.text = message.content;
//        }else if (contentType == MessageContentVoice)
//        {
//            self.messageLabel.text = @"[语音]";
//        }else if (contentType == MessageContentImage)
//        {
//            self.messageLabel.text = @"[图片]";
//        }
        
    }else{
        self.messageLabel.text = nil;
    }
    if (self.countHub == nil) {
        self.countHub = [[RKNotificationHub alloc]initWithView:self];
        CGRect frame = [self getCircleFrameWithHeadView:self.headImageView.frame];
        [self.countHub setCircleAtFrame:frame];
    }
    if (member.messageNotReadCount > 0) {
        if (member.messageNotReadCount<100) {
            [self.countHub setCount:(int)member.messageNotReadCount];
        }
        else{
            [self.countHub setCount:99];
        }
    }else{
        [self.countHub setCount:0];
    }
    [self.countHub pop];
}
-(void)setUpCellWithGroup:(Group *)group
{
    if (self.headImageView == nil) {
        self.headImageView = [[UIImageView alloc] init];
    }
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:group.groupHeadImage] placeholderImage:[UIImage imageNamed:@"defult_groups_icons"]];
    if (self.nickNameLabel == nil) {
        self.nickNameLabel = [[UILabel alloc] init];
    }
    self.nickNameLabel.text = group.groupName;
    if (self.messageLabel == nil) {
        self.messageLabel = [[UILabel alloc] init];
    }
    
    if (self.timeLabel == nil) {
        self.timeLabel = [[UILabel alloc ] init];
    }
    if (group.sessionDate == 0) {
        self.timeLabel.text = @"";
    }else{
        self.timeLabel.text = [CommonUtil TimeStrWithInterval:group.sessionDate];
    }
    
    
    if (group.groupMessage.count > 0) {
        GroupMessage *message = (GroupMessage *)[group.groupMessage objectAtIndex:group.groupMessage.count-1];
//        MessageContentType contentType = [message messageContentType];
        self.messageLabel.text = [self contentStringHandle:message.contentType WithMainStr:message.content];
//        if (contentType == MessageContentText) {
//            self.messageLabel.text = message.content;
//        }else if (contentType == MessageContentVoice)
//        {
//            self.messageLabel.text = @"[语音]";
//        }else if (contentType == MessageContentImage)
//        {
//            self.messageLabel.text = @"[图片]";
//        }else if (contentType == MessageContentRedPacket){
//            
//            self.messageLabel.text=@"[链接]抢红包啦！";
//        }
    }else{
        self.messageLabel.text = nil;
    }
    
    if (self.countHub == nil) {
        self.countHub = [[RKNotificationHub alloc]initWithView:self];
        CGRect frame = [self getCircleFrameWithHeadView:self.headImageView.frame];
        [self.countHub setCircleAtFrame:frame];
    }
    if (group.messageNotReadCount > 0) {
        if (group.messageNotReadCount<100) {
            [self.countHub setCount:(int)group.messageNotReadCount];
        }
        else{
            [self.countHub setCount:99];
        }
    }else{
        [self.countHub setCount:0];
    }
    [self.countHub pop];
}

-(void)setUpCellWithNotificaion:(NotificationMessage *)notificaionMsg{
    if (self.headImageView == nil) {
        self.headImageView = [[UIImageView alloc] init];
    }
     [self.headImageView setImage:[UIImage imageNamed:@"groupHomeNotificaionCellIcon"]];
    if (self.nickNameLabel == nil) {
        self.nickNameLabel = [[UILabel alloc] init];
    }
    self.nickNameLabel.text = @"通知";
    self.messageLabel.text = notificaionMsg.content;
    self.timeLabel.text = [CommonUtil TimeStrWithInterval:notificaionMsg.sessionDate];
    
    if (self.countHub == nil) {
        self.countHub = [[RKNotificationHub alloc]initWithView:self];
        CGRect frame = [self getCircleFrameWithHeadView:self.headImageView.frame];
        [self.countHub setCircleAtFrame:frame];
    }
    if (notificaionMsg.noHandleCount > 0) {
        if (notificaionMsg.noHandleCount<100) {
            [self.countHub setCount:(int)notificaionMsg.noHandleCount];
        }
        else{
            [self.countHub setCount:99];
        }
    }else{
        [self.countHub setCount:0];
    }
    [self.countHub pop];
}
-(void)setUpCellWithHospitalsAggregation:(HospitalAggregation *)hospitalAggregation{
    if (self.headImageView == nil) {
        self.headImageView = [[UIImageView alloc] init];
    }
    [self.headImageView setImage:[UIImage imageNamed:@"groupHomeHospitailCellIcon"]];
    if (self.nickNameLabel == nil) {
        self.nickNameLabel = [[UILabel alloc] init];
    }
    self.nickNameLabel.text = @"医院号";
//    self.messageLabel.text = hospitalAggregation.content;
    
    MessageContentType contentType = hospitalAggregation.contentType;
    self.messageLabel.text = [self contentStringHandle:contentType WithMainStr:hospitalAggregation.content];
//    if (contentType == MessageContentText) {
//        self.messageLabel.text = hospitalAggregation.content;
//    }else if (contentType == MessageContentVoice)
//    {
//        self.messageLabel.text = @"[语音]";
//    }else if (contentType == MessageContentImage)
//    {
//        self.messageLabel.text = @"[图片]";
//    }else if (contentType == MessageContentRedPacket){
//        
//        self.messageLabel.text=@"[链接]抢红包啦！";
//    }

    
    if (hospitalAggregation.sessionDate == 0) {
        self.timeLabel.text = @"";
    }else{
        self.timeLabel.text = [CommonUtil TimeStrWithInterval:hospitalAggregation.sessionDate];
    }
    
    
    if (self.countHub == nil) {
        self.countHub = [[RKNotificationHub alloc]initWithView:self];
        CGRect frame = [self getCircleFrameWithHeadView:self.headImageView.frame];
        [self.countHub setCircleAtFrame:frame];
    }
    if (hospitalAggregation.noReadCount > 0) {
        if (hospitalAggregation.noReadCount<100) {
            [self.countHub setCount:(int)hospitalAggregation.noReadCount];
        }
        else{
            [self.countHub setCount:99];
        }
    }else{
        [self.countHub setCount:0];
    }
    [self.countHub pop];
    
}
-(void)setUpCellWithGroupsAggregation:(GroupHelpAggregation *)groupHelpAggregation{
    if (self.headImageView == nil) {
        self.headImageView = [[UIImageView alloc] init];
    }
    [self.headImageView setImage:[UIImage imageNamed:@"groupHomeGroupAttentionCellIcon"]];
    if (self.nickNameLabel == nil) {
        self.nickNameLabel = [[UILabel alloc] init];
    }
    if ( groupHelpAggregation.isHasNewMessage) {
        self.messageLabel.tintColor = [UIColor colorWithRed:253 green:131 blue:8 alpha:1];
    }
   
    self.nickNameLabel.text = @"群助手";
    
    
//    MessageContentType contentType = [OneForOneMessage messageContentType:groupHelpAggregation.content];
    
    self.messageLabel.text = [self contentStringHandle:groupHelpAggregation.contentType WithMainStr:groupHelpAggregation.content];
//    if (contentType == MessageContentText) {
    
    if (self.countHub == nil) {
        self.countHub = [[RKNotificationHub alloc]initWithView:self];
        CGRect frame = [self getCircleFrameWithHeadView:self.headImageView.frame];
        [self.countHub setCircleAtFrame:frame];
    }
    if (groupHelpAggregation.notReadCount > 0) {
        if (groupHelpAggregation.notReadCount<100) {
            [self.countHub setCount:(int)groupHelpAggregation.notReadCount];
        }
        else{
            [self.countHub setCount:99];
        }
    }else{
        [self.countHub setCount:0];
    }
    [self.countHub pop];
    
    if (groupHelpAggregation.sessionDate == 0) {
        self.timeLabel.text = @"";
    }else{
        self.timeLabel.text = [CommonUtil TimeStrWithInterval:groupHelpAggregation.sessionDate];
    }
}

#pragma mark - 绘制红点位置
-(CGRect )getCircleFrameWithHeadView:(CGRect )headImageFrame{
    CGRect frame = headImageFrame;
    frame.origin.x += frame.size.width - 10;
    frame.origin.y -= 8;
    frame.size.width = 20;
    frame.size.height = 20;
    return frame;
}
#pragma mark -  返回的现实字符串
-(NSString *)contentStringHandle:(MessageContentType)ct WithMainStr:(NSString *)str{

    if (ct == MessageContentText) {
        
    }else if (ct == MessageContentVoice)
    {
        str = @"[语音]";
    }else if (ct == MessageContentImage)
    {
        str= @"[图片]";
    }
    return str;
}

@end
