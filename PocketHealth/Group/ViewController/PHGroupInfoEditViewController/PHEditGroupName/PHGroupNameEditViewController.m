//
//  PHGroupNameEditViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGroupNameEditViewController.h"
#import "Group.h"
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "PHUpdateGroupInfoAPI.h"
#import "SGroupDB.h"

@interface PHGroupNameEditViewController ()<UITextFieldDelegate>
@property(nonatomic, strong) IBOutlet UITextField *txtGroupName;
@end

@implementation PHGroupNameEditViewController
-(id)initWithGroup:(Group *)g
{
    self = [super init];
    if (self) {
        group = g;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    _txtGroupName.placeholder = group.groupName;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"群名称编辑"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(clickSaveBtn)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

-(void)clickSaveBtn
{
    if ((_txtGroupName.text == nil) || (_txtGroupName.text.length == 0)) {
        [CommonUtil HUDShowText:@"名字不能为空!" InView:self.navigationController.view];
        return;
    }
    
    [[PHUpdateGroupInfoAPI defaultManager] updateGroupInfoWithParameter:_txtGroupName.text WithProperty:@"Hbname" WithGroupId:[NSString stringWithFormat:@"%u",group.groupId] CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            group.groupName = _txtGroupName.text;
            SGroupDB *groupdb = [[SGroupDB alloc] init];
            [groupdb mergeGroup:group];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.navigationController.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络连接失败!" InView:self.navigationController.view];
    }];
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
    if ([_txtGroupName isFirstResponder]) {
        [_txtGroupName resignFirstResponder];
    }
}
@end
