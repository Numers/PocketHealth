//
//  PHIdentifyingCodeViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHIdentifyingCodeViewController.h"
#import "PHRegisterViewController.h"
#import "CommonUtil.h"
#import "PHRegisterManager.h"

@interface PHIdentifyingCodeViewController ()
{
    BOOL isAgree;
}
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@property (strong, nonatomic) IBOutlet UITextField *txtPhone;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *UINoteLabelWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *UINoteLabelHeightConstraint;

@end

@implementation PHIdentifyingCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self readStateSettingWithValue:YES];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    _UINoteLabelWidthConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds) - 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)readStateSettingWithValue:(BOOL)value
{
    isAgree = value;
    if (value) {
        
    }else{
        
    }
}

- (IBAction)clickIdentifyCodeBtn:(id)sender {
    if (isAgree) {
        if ([CommonUtil isValidateMobilePhone:_txtPhone.text]) {
            [[PHRegisterManager defaultManager] sendIdentifyCodeWithPhoneNumber:_txtPhone.text CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                NSInteger code = [[dic objectForKey:@"Code"] integerValue];
                if (code == 1) {
                    PHRegisterViewController *phRegisterVC = [[PHRegisterViewController alloc] init];
                    [self.navigationController pushViewController:phRegisterVC animated:YES];
                }
            } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }else{
            
        }
    }else{
        
    }
}

- (IBAction)clickProtocolBtn:(id)sender {
}
- (IBAction)clickReadBtn:(id)sender {
    if (isAgree) {
        [self readStateSettingWithValue:NO];
    }else{
        [self readStateSettingWithValue:YES];
    }
}

@end
