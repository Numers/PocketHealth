//
//  Member.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@class OneForOneMessage,PrivateChatViewViewController,Organization,GroupMember;

@interface mDoctor : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSString  *dpname;
@property (nonatomic, strong) NSString  *organName;
@property (nonatomic, strong) NSString  *dijobtitle;
@property (nonatomic, strong) NSString  *diremark;
@property (nonatomic)   NSInteger ddid;
@property (nonatomic) NSInteger dpid;
@property (nonatomic) NSInteger oiid;

@end

@interface Member : MTLModel<MTLJSONSerializing>
//typedef enum {
//    
//    MemberFriendTypeUser = 1, //普通用户
//    MemberFriendTypeHospital = 2, //医院号
//    MemberFriendTypeAll = 0 //无类型标记
//} MemberFriendType;

typedef enum{
    MemberUserTypeUser = 0, //普通用户
    MemberUserTypeAdmin = 2, //机构用户
    MemberUserTypeDoctor = 1, //医生
    MemberUserTypeNil = 999
}MemberUserType;


typedef enum {
    sexWoman=2,
    sexMan=1
}sexCode;

typedef enum{
    userStateNormal = 0,
    userStateDelete = 1
}userStateType;

//聊天相关枚举

@property(nonatomic) long long memberId;
@property(copy, nonatomic) NSString *loginName;
@property(copy, nonatomic) NSString *realName;
@property(copy, nonatomic) NSString *passWord;
@property(copy, nonatomic) NSString *nickName;
@property(retain, nonatomic) NSString *headImage;
@property(copy, nonatomic) NSString *location;

@property(nonatomic) NSInteger userHeight;
@property(nonatomic) NSInteger userWeight;
@property(nonatomic) sexCode userSex; //1 男 2女 0未知
@property(nonatomic) userStateType userState;
@property(nonatomic) NSTimeInterval userRegister;
@property(nonatomic) NSTimeInterval birthDate;

@property (nonatomic) NSInteger utuid; //跟我是否为好友
//用户所属机构属性
@property(nonatomic) NSInteger oiId;
@property(nonatomic, copy) NSString *organizationName;
@property(nonatomic, copy) NSString *organizationHeadImage;
@property(nonatomic, copy) NSString *organizationLevel;
@property(nonatomic, copy) NSString *organizationAddress;
@property(nonatomic, copy) NSString *organizationTel;

//健康数据信息
@property(nonatomic) NSInteger calorie;
@property(nonatomic) float metabolism;
//关注的好友、医生、机构数
@property(nonatomic) NSInteger friendCount;
@property(nonatomic) NSInteger doctorCount;
@property(nonatomic) NSInteger organizaitonCount;

//医生信息
@property(nonatomic) NSInteger diId;
@property(nonatomic, copy) NSString *diJobTitle;
@property(nonatomic, copy) NSString *diDepartment;
@property (nonatomic , copy) NSString * dimark;
@property (nonatomic,strong) mDoctor * doctor;
//@property (nonatomic) float token;
//聊天特殊参数
@property(nonatomic) NSInteger isSession;
@property(nonatomic) NSTimeInterval sessionDate;
@property (nonatomic , copy) OneForOneMessage * lastestOneMessage;
@property (nonatomic) NSInteger messageNotReadCount;
@property(retain, nonatomic) NSMutableArray *messageArr;

@property (nonatomic, strong) PrivateChatViewViewController *chatVC;

@property (nonatomic) MemberUserType userType ; //
//@property (nonatomic) MemberFriendType friendType ; //1用户 2医院号

-(Member *)initlizedWithDictionary:(NSDictionary *)dic;
-(NSString *)getHttpKey;
-(NSDictionary *)dictionaryInfo;

+(Member *)initWithOrganization:(Organization *)inputOrga;

+(Member *)initWithGroupMember:(GroupMember *)groupMember;
//从远程服务器获取用户信息 依靠id
+(void)getMemberInfoFromServer:(long long)memberId done:(void(^)(NSDictionary *))done error:(void(^)(void))getError;

@end




