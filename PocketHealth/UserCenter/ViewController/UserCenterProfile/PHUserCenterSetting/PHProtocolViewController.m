//
//  PHProtocolViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-3.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHProtocolViewController.h"
#import "CalculateViewFrame.h"
#import "CommonUtil.h"
#import "PHProtocolManager.h"
@interface PHProtocolViewController ()<UIWebViewDelegate>
{
    UIActivityIndicatorView *activityView;
}

@property(nonatomic, strong) UIWebView *webView;
@end

@implementation PHProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setOpaque:NO];
    [activityView setCenter:_webView.center];
    [_webView addSubview:activityView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_webView loadRequest:[[PHProtocolManager defaultManager] protocolURLRequest]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"软件许可及服务协议"];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBarItemImage"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer,leftItem]];
}

-(void)back
{
    if(_webView != nil){
        if ([_webView canGoBack]) {
            [_webView goBack];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark  WebViewDelegate
//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSHTTPURLResponse *response = nil;
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//    if (response.statusCode == 404) {
//        // code for 404
//        return NO;
//    } else if (response.statusCode == 403) {
//        // code for 403
//        return NO;
//    }
//    return YES;
//}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityView setOpaque:YES];
    [activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ((title != nil) && (title.length > 0)) {
        [self.navigationItem setTitle:title];
    }
    [activityView setOpaque:NO];
    [activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityView setOpaque:NO];
    [activityView stopAnimating];
    [CommonUtil HUDShowText:@"加载失败" InView:self.view];
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
