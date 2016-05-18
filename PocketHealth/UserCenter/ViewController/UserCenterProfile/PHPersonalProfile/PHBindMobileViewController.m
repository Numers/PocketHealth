//
//  PHBingMobileViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-14.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHBindMobileViewController.h"
#import "PHUpdateUserInfoManager.h"
#import "CommonUtil.h"
#import "PHAppStartManager.h"
#import "PHPasswordSettingViewController.h"

@interface PHBindMobileViewController ()<UITextFieldDelegate,PHPasswordSettingViewDelegate>
{
    NSTimer *timer;
    NSInteger seconds;
}
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtValidateCode;
@property (strong, nonatomic) IBOutlet UIButton *btnValidateCode;

@end

@implementation PHBindMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    [_btnValidateCode setAdjustsImageWhenHighlighted:NO];
    [_btnValidateCode setEnabled:NO];
    _txtValidateCode.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, _txtValidateCode.frame.size.height)];
    _txtValidateCode.leftViewMode = UITextFieldViewModeAlways;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Member *host = [[PHAppStartManager defaultManager] userHost];
    if ((host.loginName == nil) || (host.loginName.length == 0))
    {
        [self.navigationItem setTitle:@"绑定手机号"];
    }else{
        [self.navigationItem setTitle:@"修改手机号"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeValidateCodeBtnTextColor:(NSString *)text
{
    if ((text == nil) || (text.length < 11)) {
        [_btnValidateCode setEnabled:NO];
        [_btnValidateCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnValidateCode setBackgroundImage:[UIImage imageNamed:@"usercenter-verifyCodeImage_unable"] forState:UIControlStateNormal];
    }else{
        [_btnValidateCode setEnabled:YES];
        [_btnValidateCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnValidateCode setTitleColor:[UIColor colorWithRed:239/255.0f green:155/255.0f blue:173/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [_btnValidateCode setBackgroundImage:[UIImage imageNamed:@"usercenter-verifyCodeImage_enable_normal"] forState:UIControlStateNormal];
        [_btnValidateCode setBackgroundImage:[UIImage imageNamed:@"usercenter-verifyCodeImage_enable_upsideDown"] forState:UIControlStateHighlighted];
    }
}

-(void)myTextFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = [notification object];
    if([textField isEqual:_txtMobile]){
        [self changeValidateCodeBtnTextColor:_txtMobile.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtMobile isFirstResponder]) {
        [_txtMobile resignFirstResponder];
    }
    
    if ([_txtValidateCode isFirstResponder]) {
        [_txtValidateCode resignFirstResponder];
    }
}

- (IBAction)clickLoginBtn:(id)sender {
    [[PHAppStartManager defaultManager] loginOut];
}

- (IBAction)clickValidateCodeBtn:(id)sender {
    if ([CommonUtil isValidateMobilePhone:_txtMobile.text]) {
        [self sendPhoneCodeWithTel:_txtMobile.text];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"手机号不合法" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)sendPhoneCodeWithTel:(NSString *)tel
{
    Member *host = [[PHAppStartManager defaultManager] userHost];
    OperationCode operationCode;
    if ((host.loginName == nil) || (host.loginName.length == 0))
    {
        operationCode = BindMobile;
    }else{
        operationCode = ModifyMobile;
    }
    [[PHUpdateUserInfoManager defaultManager] sendPhoneCodeWithTel:tel WithType:operationCode CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            seconds = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(validateBtnSetting) userInfo:nil repeats:YES];
            [timer fire];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误!" InView:self.view];
    }];
}

-(void)verificatePhone:(NSString *)phone WithVerificateCode:(NSString *)code
{
    Member *host = [[PHAppStartManager defaultManager] userHost];
    [[PHUpdateUserInfoManager defaultManager] verificateUserWithPhone:phone WithVerificateCode:code WithUserId:host.memberId  CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            Member *host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                 AFNetWorkKey = [CommonUtil createSendKeyWithUserName:host.loginName Userid:[NSString stringWithFormat:@"%lld",host.memberId]];
                PHPasswordSettingViewController *phPasswordSettingVC = [[PHPasswordSettingViewController alloc] init];
                phPasswordSettingVC.delegate = self;
                [self.navigationController pushViewController:phPasswordSettingVC animated:YES];
            }
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误!" InView:self.view];
    }];
}

-(void)validateBtnSetting
{
    --seconds;
    if (seconds>0) {
        [_btnValidateCode setTitle:[NSString stringWithFormat:@"还剩(%ld)秒",seconds] forState:UIControlStateNormal];
        [_btnValidateCode setEnabled:NO];
    }else{
        [timer invalidate];
        timer = nil;
        [_btnValidateCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_btnValidateCode setEnabled:YES];
    }
}

- (IBAction)clickSetPasswordBtn:(id)sender {
    UIAlertView *alert = nil;
    if ((_txtMobile.text == nil) || (_txtMobile.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"手机号不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ((_txtValidateCode.text == nil) || (_txtValidateCode.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"验证码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [self verificatePhone:_txtMobile.text WithVerificateCode:_txtValidateCode.text];
}

-(void)popView{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
