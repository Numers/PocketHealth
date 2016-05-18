//
//  PHGroupIntroductionEditViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGroupIntroductionEditViewController.h"
#import "Group.h"
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "PHUpdateGroupInfoAPI.h"
#import "PHTextView.h"
#import "SGroupDB.h"

@interface PHGroupIntroductionEditViewController ()
{
    PHTextView *textView;
}
@end

@implementation PHGroupIntroductionEditViewController
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
    textView = [[PHTextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 135)];
    if ((group.groupBriefIntroduction == nil) || (group.groupBriefIntroduction.length == 0)) {
        [textView setPlaceHolder:@"请输入群简介"];
    }else{
        [textView setPlaceHolder:group.groupBriefIntroduction];
    }
    [self.view addSubview:textView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"群简介编辑"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(clickSaveBtn)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

-(void)clickSaveBtn
{
    if ((textView.text == nil) || (textView.text.length == 0)) {
        [CommonUtil HUDShowText:@"群简介不能为空!" InView:self.navigationController.view];
        return;
    }
    
    [[PHUpdateGroupInfoAPI defaultManager] updateGroupInfoWithParameter:[textView text] WithProperty:@"Hbremark" WithGroupId:[NSString stringWithFormat:@"%u",group.groupId] CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            group.groupBriefIntroduction = [textView text];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end