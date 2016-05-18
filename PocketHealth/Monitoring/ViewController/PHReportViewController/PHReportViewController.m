//
//  PHReportViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-29.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHReportViewController.h"
#import "UINavigationController+PHNavigationController.h"
#import "CalculateViewFrame.h"
#import "CommonUtil.h"
#import "PHReportIndexManager.h"
#import "PHBottomToolBar.h"
#import "PHAppStartManager.h"

#define BottomToolBarHeight 60

@interface PHReportViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate,PHBottomToolBarDelegate>
{
    UIActivityIndicatorView *activityView;
}
@property(nonatomic, strong) UIWebView *webView;
@end

@implementation PHReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setUserInteractionEnabled:YES];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _webView = [[UIWebView alloc] initWithFrame:frame];
    [_webView setUserInteractionEnabled:YES];
    _webView.delegate = self;
    [_webView setMultipleTouchEnabled:YES];
    [self.view addSubview:_webView];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWebView)];
    tapGestureRecognizer.delegate = self;
    [_webView addGestureRecognizer:tapGestureRecognizer];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setOpaque:NO];
    [activityView setCenter:_webView.center];
    [_webView addSubview:activityView];
    
    phBottomToolBar = [[PHBottomToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, BottomToolBarHeight)];
    phBottomToolBar.myDelegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:phBottomToolBar];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_webView loadRequest:[[PHReportIndexManager defaultManager] reportIndexURLRequest]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"健康报告"];
    [self.navigationController setOtherViewNavigation];
    
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
            [self hiddenBottomToolBar];
            [phBottomToolBar removeFromSuperview];
            phBottomToolBar = nil;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapWebView
{
//    if (canPopBottomToolBar) {
//        if ([phBottomToolBar isShow]) {
//            [self hiddenBottomToolBar];
//        }else{
//            [self showBottomToolBar];
//        }
//    }else{
//        if ([phBottomToolBar isShow]) {
//            [self hiddenBottomToolBar];
//        }
//    }
}

-(void)showBottomToolBar
{
    
    if (![phBottomToolBar isShow]) {
        [phBottomToolBar show];
        CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
        [_webView setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - BottomToolBarHeight)];
    }
}

-(void)hiddenBottomToolBar
{
    if ([phBottomToolBar isShow]) {
        [phBottomToolBar hidden];
        CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
        [_webView setFrame:frame];
    }
}

#pragma -mark  WebViewDelegate
#pragma mark - UIWebView Delegate Methods
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
        if (![title isEqualToString:@"健康报告"]) {
            [self showBottomToolBar];
        }else{
            [self hiddenBottomToolBar];
        }
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
#pragma mark UIGestureRecognizerClick
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:tapGestureRecognizer]) {
        return YES;
    }
    return NO;
}

#pragma -mark phBottomToolBarDelegate
-(void)pushToSearchDoctorView
{
    [phBottomToolBar hidden];
    [phBottomToolBar removeFromSuperview];
    phBottomToolBar = nil;
    [[PHAppStartManager defaultManager] popToTabBarControllerWithIndex:0];
    if ([_delegate respondsToSelector:@selector(pushFindDoctorView)]) {
        [_delegate pushFindDoctorView];
    }
}

-(void)pushToChatView
{
    [phBottomToolBar hidden];
    [phBottomToolBar removeFromSuperview];
    phBottomToolBar = nil;
    [[PHAppStartManager defaultManager] popToTabBarControllerWithIndex:1];
}

@end
