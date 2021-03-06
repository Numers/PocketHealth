//
//  GroupMember.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupMember.h"

@implementation GroupMember

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // properties defined in header < : > key in JSON Dictionary
    return @{
             @"loginName":@"Loginname",
             @"realName":@"Usertruename",
             @"nickName":@"Nickname",
             @"passWord":@"Password",
             @"memberId" : @"Userid",
             @"headImage" : @"Headimg" ,
             
             @"userHeight" : @"Userheight",
             @"userWeight" : @"Userweight",
             @"userSex" : @"Usersex",
             @"userState" : @"Userstate" ,
             
             @"friendType" : @"FriendType" ,
             @"userType" : @"Usertype" ,
             @"userRegister" :@"Userregister",
             @"groupMemberType" :@"Btutype"
             };
}

//+(GroupMember *)allocWithMember:(Member *)tmpMember{
//    GroupMember * gmember = [[GroupMember alloc]init];
//    
//    for (<#type *object#> in <#collection#>) {
//        <#statements#>
//    }
//    return gmember;
//}
@end
