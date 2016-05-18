//
//  PHQRCodeViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-15.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHQRCodeViewController.h"
#import "QRCodeGenerator.h"
#import "PHAppStartManager.h"
#import "GlobalVar.h"

@interface PHQRCodeViewController ()
{
    id member;
    MemberUserType type;
}
@property (strong, nonatomic) IBOutlet UIImageView *imgQRCodeImage;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblRole;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganization;
@property (strong, nonatomic) IBOutlet UIImageView *whiteBackGroundView;

@end

@implementation PHQRCodeViewController
-(id)initWithMember:(id)m WithMemberType:(MemberUserType)memberType
{
    self = [super init];
    if (self) {
        member = m;
        type = memberType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的二维码";
    // Do any additional setup after loading the view from its nib.
    [_whiteBackGroundView.layer setCornerRadius:5.f];
    [self generateQRCodeStrWithMember:member WithMemberType:type];
}

-(NSString *)generateQRCodeStrWithMember:(id)member WithMemberType:(MemberUserType)memberType
{
    NSString *code = nil;
    switch (memberType) {
        case MemberUserTypeUser:
        {
            code = [self dowithUser];
        }
            break;
        case MemberUserTypeAdmin:
        {
            [self dowithOrganizaiton];
        }
            break;
        case MemberUserTypeDoctor:
        {
            [self dowithDoctor];
        }
            break;
            
        default:
            break;
    }
    return code;
}

-(NSString *)dowithUser
{
    NSString *code = nil;
    if ([member isKindOfClass:[Member class]]) {
        Member *m = (Member *)member;
        code = [self createQRcodeByMember:m];
        [self updateUIViewWithMember:m WithCodeStr:code];
    }
    return code;
}

-(NSString *)dowithDoctor
{
    NSString *code = nil;
    if ([member isKindOfClass:[Member class]]) {
        Member *m = (Member *)member;
        code = [self createQRcodeByMember:m];
        [self updateUIViewWithDoctor:m WithCodeStr:code];
    }
    return code;
}

-(NSString *)dowithOrganizaiton
{
    NSString *code = nil;
    if ([member isKindOfClass:[Member class]]) {
        Member *m = (Member *)member;
        code = [self createQRcodeByMember:m];
//        code = [NSString stringWithFormat:@"%lld",m.memberId];
        [self updateUIViewWithOrganization:m WithCodeStr:code];
    }else if([member isKindOfClass:[Organization class]]){
        Organization *org = (Organization *)member;
        code = [self createQRcodeByOrg:org];
//        code = [NSString stringWithFormat:@"%lld",org.userId];
        [self updateUIViewWithOrg:org WithCodeStr:code];
    }
    return code;
}

//code转换 方法
-(NSString *)createQRcodeByMember:(Member *)qrmember{
    NSString * qrCode = [NSString stringWithFormat:@"%@?id=%lld&type=%u",PH_UserDown_API,qrmember.memberId,qrmember.userType];
    return qrCode;
}
-(NSString *)createQRcodeByOrg:(Organization *)org{
    NSString * qrCode = [NSString stringWithFormat:@"%@?id=%lld&type=%u",PH_UserDown_API,org.userId,MemberUserTypeAdmin];
    return qrCode;
}
-(void)updateUIViewWithMember:(Member *)m WithCodeStr:(NSString *)codeStr
{
    [_lblName setHidden:NO];
    [_lblRole setHidden:YES];
    [_lblOrganization setHidden:YES];
    [_imgQRCodeImage setImage:[QRCodeGenerator qrImageForString:codeStr imageSize:_imgQRCodeImage.bounds.size.width]];
    _lblName.text = m.realName;
}

-(void)updateUIViewWithDoctor:(Member *)m WithCodeStr:(NSString *)codeStr
{
    [_lblName setHidden:NO];
    [_lblRole setHidden:NO];
    [_lblOrganization setHidden:NO];
    [_imgQRCodeImage setImage:[QRCodeGenerator qrImageForString:codeStr imageSize:_imgQRCodeImage.bounds.size.width]];
    _lblName.text = m.realName;
    _lblRole.text = m.diJobTitle;
    _lblOrganization.text = m.diDepartment;
}

-(void)updateUIViewWithOrganization:(Member *)m WithCodeStr:(NSString *)codeStr
{
    [_lblName setHidden:NO];
    [_lblRole setHidden:NO];
    [_lblOrganization setHidden:YES];
    [_imgQRCodeImage setImage:[QRCodeGenerator qrImageForString:codeStr imageSize:_imgQRCodeImage.bounds.size.width]];
    _lblName.text = m.organizationName;
    _lblRole.text = m.organizationLevel;
    self.navigationItem.title = @"医院名片";
}

-(void)updateUIViewWithOrg:(Organization *)org WithCodeStr:(NSString *)codeStr
{
    [_lblName setHidden:NO];
    [_lblRole setHidden:NO];
    [_lblOrganization setHidden:YES];
    [_imgQRCodeImage setImage:[QRCodeGenerator qrImageForString:codeStr imageSize:_imgQRCodeImage.bounds.size.width]];
    _lblName.text = org.organizationName;
    _lblRole.text = org.organizationLevel;
    
    self.navigationItem.title = @"医院名片";
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickAddFriendByMobileBtn:(id)sender {
}
@end
