//
//  PHRegisterViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHRegisterViewController.h"

@interface PHRegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txtIdentifyCode;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNickName;
@property (strong, nonatomic) IBOutlet UIButton *btnIdentifyCode;

@end

@implementation PHRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
- (IBAction)clickIdentifyCodeBtn:(id)sender {
}
- (IBAction)clickSubmitBtn:(id)sender {
}

@end
