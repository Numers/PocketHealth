//
//  PHUpdateRealNameViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-12.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUpdateRealNameViewController.h"
#import "CommonUtil.h"
#import "PHUpdateUserInfoManager.h"
#import "PHAppStartManager.h"
#import "Member.h"

@interface PHUpdateRealNameViewController ()<UITextFieldDelegate>
{
    Member *host;
}
@property (strong, nonatomic) IBOutlet UITextField *txtRealName;

@end

@implementation PHUpdateRealNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    host = [[PHAppStartManager defaultManager] userHost];
    _txtRealName.placeholder = host.realName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"修改姓名"];
}

-(void)updateRealName
{
    UIAlertView *alert = nil;
    if ((_txtRealName.text == nil) || (_txtRealName.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"名字不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (_txtRealName.text.length > 8) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"长度不能超过8个字符!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(![CommonUtil isValidateName:_txtRealName.text])
    {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不能以数字、下划线开头，只能包含简体中文、大小写字母、数字和下划线。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:_txtRealName.text WithProperty:@"Usertruename" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            [CommonUtil HUDShowText:@"更新失败!" InView:self.navigationController.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误!" InView:self.navigationController.view];
    }];
}

- (IBAction)clickComfirmBtn:(id)sender {
    [self updateRealName];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtRealName isFirstResponder]) {
        [_txtRealName resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
@end
