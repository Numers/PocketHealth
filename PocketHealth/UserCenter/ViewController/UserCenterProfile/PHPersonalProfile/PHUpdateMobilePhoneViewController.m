//
//  PHUpdateRealNameViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-12.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUpdateMobilePhoneViewController.h"
#import "MBProgressHUD+Add.h"
#import "PHUpdateUserInfoManager.h"
#import "PHAppStartManager.h"
#import "Member.h"

@interface PHUpdateMobilePhoneViewController ()<UITextFieldDelegate>
{
    Member *host;
}
@property (strong, nonatomic) IBOutlet UITextField *txtMobilePhone;

@end

@implementation PHUpdateMobilePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    host = [[PHAppStartManager defaultManager] userHost];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateMobilePhone
{
    if ((_txtMobilePhone.text == nil) || (_txtMobilePhone.text.length == 0)) {
        [MBProgressHUD showError:@"手机号不能为空!" toView:self.view];
        return;
    }
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:_txtMobilePhone.text WithProperty:@"Usertruename" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
//            host.realName = _txtMobilePhone.text;
            [[PHAppStartManager defaultManager] setHostMember:host];
            [MBProgressHUD showSuccess:@"更新成功" toView:self.view];
        }else{
            [MBProgressHUD showError:@"更新失败!" toView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"网络错误!" toView:self.view];
    }];
}

- (IBAction)clickComfirmBtn:(id)sender {
    [self updateMobilePhone];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtMobilePhone becomeFirstResponder]) {
        [_txtMobilePhone resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
@end
