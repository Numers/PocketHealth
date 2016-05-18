//
//  PHUserCenterFeedBackViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-2.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUserCenterFeedBackViewController.h"
#import "CommonUtil.h"
#import "PHUserFeedBackManager.h"
#import "PHTextView.h"

static NSString *callNumber = @"12345";
@interface PHUserCenterFeedBackViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) PHTextView *suggestionTextView;
@property (strong, nonatomic) IBOutlet UITextField *contactText;
@property (strong, nonatomic) IBOutlet UILabel *lblCall;


@end

@implementation PHUserCenterFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:ViewBackGroundColor];
    [_lblCall.layer setCornerRadius:10.f];
    [_lblCall.layer setMasksToBounds:YES];
    _suggestionTextView = [[PHTextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 135)];
    [_suggestionTextView setPlaceHolder:@"描述问题、吐槽或对产品的建议..."];
    [self.view addSubview:_suggestionTextView];
    
    _contactText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _contactText.frame.size.height)];
    _contactText.leftViewMode = UITextFieldViewModeAlways;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f],NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"手机或QQ" attributes:dic];
    [_contactText setAttributedPlaceholder:attr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"用户反馈"];
}

-(BOOL)validateData
{
    UIAlertView *alert = nil;
    if (([_suggestionTextView text] == nil) || ([_suggestionTextView text].length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"意见反馈" message:@"请描述问题、吐槽或对产品的建议" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if ((_contactText.text == nil) || (_contactText.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"意见反馈" message:@"请留下您的联系方式,以方便我们联系您!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

-(void)uploadSuggestion
{
    [[PHUserFeedBackManager defaultManager] uploadFeedBack:[_suggestionTextView text] WithContactNumber:_contactText.text CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            [CommonUtil HUDShowText:@"提交成功" InView:self.view];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络连接失败" InView:self.view];
    }];
}

- (IBAction)clickSubmitBtn:(id)sender {
    if([self validateData])
    {
        [self uploadSuggestion];
    }
}

- (IBAction)clickCallBtn:(id)sender {
    UIWebView *callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",callNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
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
