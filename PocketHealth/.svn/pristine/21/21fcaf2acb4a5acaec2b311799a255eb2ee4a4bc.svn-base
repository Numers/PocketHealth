//
//  PHUserCenterHeadView.m
//  PocketHealth
//
//  Created by macmini on 15-1-31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUserCenterHeadView.h"
#import "PHAppStartManager.h"
#import "PHGetMemberInfoManager.h"
#import "GlobalVar.h"
#import "CommonUtil.h"
#define LabelIndexFontSize 12.f
#define LabelIndexValueFontSize 14.f

@implementation PHUserCenterHeadView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        btnFriendList = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [btnFriendList setCenter:CGPointMake(frame.size.width/6, frame.size.height/2)];
        [btnFriendList addTarget:self action:@selector(friendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnFriendList];
        
        UIView *lineLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 20)];
        [lineLabel setBackgroundColor:[UIColor colorWithRed:199/255.f green:200/255.f blue:204/255.f alpha:1.f]];
        [lineLabel setCenter:CGPointMake(frame.size.width/3, frame.size.height / 2)];
        [self addSubview:lineLabel];
        
        btnDoctorList = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [btnDoctorList setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [btnDoctorList addTarget:self action:@selector(doctorBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnDoctorList];
        
        UIView *lineLabel1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 20)];
        [lineLabel1 setBackgroundColor:[UIColor colorWithRed:199/255.f green:200/255.f blue:204/255.f alpha:1.f]];
        [lineLabel1 setCenter:CGPointMake(frame.size.width * 2 /3, frame.size.height / 2)];
        [self addSubview:lineLabel1];
        
        btnOrganizationList = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [btnOrganizationList setCenter:CGPointMake(self.frame.size.width * 5 / 6, frame.size.height / 2)];
        [btnOrganizationList addTarget:self action:@selector(organizationBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnOrganizationList];
        
        lblFriend = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblFriend setTextAlignment:NSTextAlignmentCenter];
        [lblFriend setTextColor:[UIColor colorWithRed:143/255.f green:143/255.f blue:143/255.f alpha:1.f]];
        [lblFriend setFont:[UIFont systemFontOfSize:LabelIndexFontSize]];
        [lblFriend setCenter:CGPointMake(frame.size.width / 6, frame.size.height - 16)];
        [lblFriend setText:@"好友"];
        [self addSubview:lblFriend];
        
        lblFriendCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblFriendCount setTextAlignment:NSTextAlignmentCenter];
        [lblFriendCount setTextColor:[UIColor colorWithRed:34/255.f green:34/255.f blue:34/255.f alpha:1.f]];
        [lblFriendCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:LabelIndexValueFontSize]];
        [lblFriendCount setCenter:CGPointMake(frame.size.width / 6, 16)];
        [self addSubview:lblFriendCount];
        
        lblDoctor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblDoctor setTextAlignment:NSTextAlignmentCenter];
        [lblDoctor setTextColor:[UIColor colorWithRed:143/255.f green:143/255.f blue:143/255.f alpha:1.f]];
        [lblDoctor setFont:[UIFont systemFontOfSize:LabelIndexFontSize]];
        [lblDoctor setCenter:CGPointMake(frame.size.width / 2, frame.size.height - 16)];
        [lblDoctor setText:@"医生"];
        [self addSubview:lblDoctor];
        
        lblDoctorCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblDoctorCount setTextAlignment:NSTextAlignmentCenter];
        [lblDoctorCount setTextColor:[UIColor colorWithRed:34/255.f green:34/255.f blue:34/255.f alpha:1.f]];
        [lblDoctorCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:LabelIndexValueFontSize]];
        [lblDoctorCount setCenter:CGPointMake(frame.size.width / 2, 16)];
        [self addSubview:lblDoctorCount];
        
        lblOrganization = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblOrganization setTextAlignment:NSTextAlignmentCenter];
        [lblOrganization setTextColor:[UIColor colorWithRed:143/255.f green:143/255.f blue:143/255.f alpha:1.f]];
        [lblOrganization setFont:[UIFont systemFontOfSize:LabelIndexFontSize]];
        [lblOrganization setCenter:CGPointMake(frame.size.width * 5 / 6, frame.size.height - 16)];
        [lblOrganization setText:@"医院"];
        [self addSubview:lblOrganization];
        
        lblOrganizationCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, 12)];
        [lblOrganizationCount setTextAlignment:NSTextAlignmentCenter];
        [lblOrganizationCount setTextColor:[UIColor colorWithRed:34/255.f green:34/255.f blue:34/255.f alpha:1.f]];
        [lblOrganizationCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:LabelIndexValueFontSize]];
        [lblOrganizationCount setCenter:CGPointMake(frame.size.width * 5 / 6, 16)];
        [self addSubview:lblOrganizationCount];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        [lineView setBackgroundColor:[UIColor colorWithRed:199/255.f green:200/255.f blue:204/255.f alpha:1.f]];
        [lineView setCenter:CGPointMake(frame.size.width/2, frame.size.height)];
        [self addSubview:lineView];
    }
    return self;
}

-(void)updateUIViewContentWithMember:(Member *)member
{
    [self getUserInfoWithMember:member];
}

-(void)getUserInfoWithMember:(Member *)member
{
    [[PHGetMemberInfoManager defaultManager] requestMemberInfo:member.memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            Member *hostMember = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:hostMember];
                [self setUIValueWithHost:hostMember];
            }
        }else{
            [self setUIValueWithHost:member];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setUIValueWithHost:member];
    }];
}

-(void)setUIValueWithHost:(Member *)hostMember
{
    lblFriendCount.text = [NSString stringWithFormat:@"%ld",(long)hostMember.friendCount];
    lblDoctorCount.text = [NSString stringWithFormat:@"%ld",(long)hostMember.doctorCount];
    lblOrganizationCount.text = [NSString stringWithFormat:@"%ld",(long)hostMember.organizaitonCount];
}

-(void)friendBtnClick
{
    if ([self.delegate respondsToSelector:@selector(friendListBtnClick)]) {
        [self.delegate friendListBtnClick];
    }
}

-(void)doctorBtnClick
{
    if ([self.delegate respondsToSelector:@selector(doctorListBtnClick)]) {
        [self.delegate doctorListBtnClick];
    }
}

-(void)organizationBtnClick
{
    if ([self.delegate respondsToSelector:@selector(organizationListBtnClick)]) {
        [self.delegate organizationListBtnClick];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
