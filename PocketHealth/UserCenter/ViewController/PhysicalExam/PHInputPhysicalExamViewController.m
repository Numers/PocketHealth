//
//  PHInputPhysicalExamViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHInputPhysicalExamViewController.h"
#import "PHAppStartManager.h"
#import "PHLocationOrganizationHelper.h"
#import "GlobalVar.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Organization.h"
#import "PHCityViewController.h"
#import "PHPhysicalExamTableManager.h"
#import "CommonUtil.h"
#import "UINavigationController+PHNavigationController.h"

@interface PHInputPhysicalExamViewController ()<CLLocationManagerDelegate,UITextFieldDelegate,MKMapViewDelegate,InputPhysicalExamDelegate,PHLocationOrganizationDelegate>
{
    Organization *organization; //gps定位的最近机构
    NSString *gpsCityName; //gps定位的城市
    Organization *selectOrganization; //选择的机构
    PHLocationOrganizationHelper *locationHelper;
}
@property (strong, nonatomic) IBOutlet UIButton *btnOrganization;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) IBOutlet UITextField *txtPhysicalCode;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhysicalCode;
@property (strong, nonatomic) IBOutlet UIImageView *imgPassword;

@end

@implementation PHInputPhysicalExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    if ([CLLocationManager locationServicesEnabled]) {
        [_indicatorView startAnimating];
        locationHelper = [[PHLocationOrganizationHelper alloc] init];
        locationHelper.delegate = self;
        [locationHelper startLocationOrganization];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle:@"获取体检报告"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setTitle:@""];
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController setOtherViewNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectOrganizaiton:(Organization *)org
{
    if (org == nil) {
        [_btnOrganization setTitleColor:[UIColor colorWithRed:204.f/255 green:204.f/255 blue:204.f/255 alpha:1.f] forState:UIControlStateNormal];
        [_btnOrganization setTitle:@"请手动选取体检医院" forState:UIControlStateNormal];
        selectOrganization = nil;
    }else{
        [_btnOrganization setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnOrganization setTitle:org.organizationName forState:UIControlStateNormal];
        selectOrganization = org;
    }
}

-(BOOL)addNewPhysicalExamTableValidate
{
    UIAlertView *alert = nil;
    if ((_txtPhysicalCode.text == nil) || (_txtPhysicalCode.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"导入体检单" message:@"体检单号不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if ((_txtPassword.text == nil) || (_txtPassword.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"导入体检单" message:@"体检单密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if(selectOrganization == nil){
        alert = [[UIAlertView alloc] initWithTitle:@"导入体检单" message:@"请选择您体检所在的机构" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (IBAction)clickConfirmBtn:(id)sender {
    if ([self addNewPhysicalExamTableValidate]) {
        [[PHPhysicalExamTableManager defaultManager] addNewPhysicalExamTable:_txtPhysicalCode.text WithPassword:_txtPassword.text WithorganizationOiid:selectOrganization.oiId CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger code = [[dic objectForKey:@"Code"] integerValue];
            if (code == 1) {
                [[PHAppStartManager defaultManager] pushHomeViewWithSelectIndex:2];
            }else{
                [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.navigationController.view];
            }
        } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
            [CommonUtil HUDShowText:[error description] InView:self.navigationController.view];
        }];
    }
}

- (IBAction)clickJumpBtn:(id)sender {
    [[PHAppStartManager defaultManager] pushHomeViewWithSelectIndex:1];
}

- (IBAction)clickHospitalBtn:(id)sender {
    PHCityViewController *phCityVC = [[PHCityViewController alloc] initWithGpsOrganization:organization WithGpsCityName:gpsCityName];
    phCityVC.delegate = self;
    [self.navigationController pushViewController:phCityVC animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtPhysicalCode isFirstResponder]) {
        [_txtPhysicalCode resignFirstResponder];
    }
    
    if ([_txtPassword isFirstResponder]) {
        [_txtPassword resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(void)myTextFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = [notification object];
    if([textField isEqual:_txtPhysicalCode]){
        [self physicalCodeImageViewChange];
    }
    
    if ([textField isEqual:_txtPassword]) {
        [self passwordImageViewChange];
    }
    
}

-(void)physicalCodeImageViewChange
{
    if ((_txtPhysicalCode.text == nil) || (_txtPhysicalCode.text.length == 0)) {
        [_imgPhysicalCode setImage:[UIImage imageNamed:@"phone-number2"]];
    }else{
        [_imgPhysicalCode setImage:[UIImage imageNamed:@"phone-number"]];
    }
}

-(void)passwordImageViewChange
{
    if ((_txtPassword.text == nil) || (_txtPassword.text.length == 0)) {
        [_imgPassword setImage:[UIImage imageNamed:@"password-icon2"]];
    }else{
        [_imgPassword setImage:[UIImage imageNamed:@"password-icon"]];
    }
}

#pragma -mark InputPhysicalExamDelegate
-(void)popViewWithOrganization:(Organization *)org
{
    if (org != nil) {
        [self selectOrganizaiton:org];
    }
}

#pragma -mark PHLocationOrganizationDelegate
-(void)returnNearestOrganization:(Organization *)org
{
    [_indicatorView stopAnimating];
    [self selectOrganizaiton:org];
}

-(void)returnCityName:(NSString *)cityName
{
    gpsCityName = cityName;
}
@end
