//
//  PHPasswordSettingViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-14.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPasswordSettingViewController.h"
#import "CommonUtil.h"
#import "PHUpdateUserInfoManager.h"
#import "NSString+Additions.h"
#import "PHAppStartManager.h"

@interface PHPasswordSettingViewController ()<UITextFieldDelegate>
{
    BOOL isAgree;
}
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtValidatePassword;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;

@end

@implementation PHPasswordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    [self changeAgreeState:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"设置密码"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtPassword isFirstResponder]) {
        [_txtPassword resignFirstResponder];
    }
    
    if ([_txtValidatePassword isFirstResponder]) {
        [_txtValidatePassword resignFirstResponder];
    }
}

-(void)changeAgreeState:(BOOL)state
{
    isAgree = state;
    if (state) {
        [_btnAgree setBackgroundImage:[UIImage imageNamed:@"AgreementSelect"] forState:UIControlStateNormal];
    }else{
        [_btnAgree setBackgroundImage:[UIImage imageNamed:@"AgreementNotSelect"] forState:UIControlStateNormal];
    }
}

-(void)updateUserPassword:(NSString *)password
{
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:[NSString md5:[NSString stringWithFormat:@"%@%@",key_password,password]] WithProperty:@"Password" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            Member *host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                [CommonUtil HUDShowText:@"更新成功" InView:self.view];
                [self.navigationController popViewControllerAnimated:NO];
                if ([_delegate respondsToSelector:@selector(popView)]) {
                    [_delegate popView];
                }
            }
        }else{
            [CommonUtil HUDShowText:@"更新失败" InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误" InView:self.view];
    }];
}

- (IBAction)clickTermsBtn:(id)sender {
}

- (IBAction)clickComfirmBtn:(id)sender {
    UIAlertView *alert = nil;
    if ((_txtPassword.text == nil) || (_txtPassword.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([_txtPassword.text containsString:@" "]) {
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码不能包含空格!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ((_txtValidatePassword.text == nil) || (_txtValidatePassword.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"验证密码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(![_txtPassword.text isEqualToString:_txtValidatePassword.text]){
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码不相同!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(!isAgree){
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请阅读服务条款并同意!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([CommonUtil isValidatePassWord:_txtPassword.text]) {
        [self updateUserPassword:_txtPassword.text];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"密码设置不合法!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}
- (IBAction)clickAgreeBtn:(id)sender {
    if (isAgree) {
        [self changeAgreeState:NO];
    }else{
        [self changeAgreeState:YES];
    }
}
@end
