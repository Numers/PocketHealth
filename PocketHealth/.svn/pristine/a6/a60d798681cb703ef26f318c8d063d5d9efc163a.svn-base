//
//  PHWeightViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHHeightViewController.h"
#import "PHAppStartManager.h"
#define ToolBarHeight 40.0f
#define Duration 0.3f
#define MinHeight 90
#define MaxHeight 280

@interface PHHeightViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSInteger hostHeight;
    NSMutableArray *dataSourceArray;
    NSInteger selectHeight;
    UIView *parentView;
    BOOL isShow;
}
@property(nonatomic, strong) UIPickerView *pickView;
@property(nonatomic, strong) UIToolbar *toolBar;
@end

@implementation PHHeightViewController
-(id)initWithHeight:(NSInteger)h
{
    self = [super init];
    if (self) {
        if ((h>MaxHeight) || (h<MinHeight)) {
            hostHeight = 150;
        }else{
            hostHeight = h;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self inilizedDataSource];
    [self setUpPickView];
    
    float viewHeight = _toolBar.frame.size.height + _pickView.frame.size.height;
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, viewHeight);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)inilizedDataSource
{
    dataSourceArray = [[NSMutableArray alloc] init];
    for (int i = MinHeight; i<=MaxHeight; i++) {
        NSString *dataStr = [NSString stringWithFormat:@"%dcm",i];
        [dataSourceArray addObject:dataStr];
    }
}

-(void)setUpPickView
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ToolBarHeight)];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancelBtn)];
    [leftBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickComfirmBtn)];
    [rightBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    _toolBar.items=@[leftBarItem,centerSpace,rightBarItem];
    [self.view addSubview:_toolBar];
    
    _pickView = [[UIPickerView alloc] init];
    [_pickView setFrame:CGRectMake(0, ToolBarHeight, [UIScreen mainScreen].bounds.size.width, _pickView.frame.size.height)];
    _pickView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    _pickView.delegate = self;
    _pickView.dataSource = self;
    [_pickView setShowsSelectionIndicator:YES];
    [self.view addSubview:_pickView];
    [_pickView selectRow:hostHeight - MinHeight inComponent:0 animated:NO];
    selectHeight = hostHeight;
}

-(void)showInView:(UIView *)view
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
    [view setUserInteractionEnabled:NO];
    parentView = view;
    isShow = YES;
}

-(void)hidden
{
    [parentView setUserInteractionEnabled:YES];
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeView) withObject:nil afterDelay:Duration];
}

-(void)removeView
{
    [_toolBar removeFromSuperview];
    _toolBar = nil;
    
    [_pickView removeFromSuperview];
    _pickView = nil;
    
    [self.view removeFromSuperview];
}

-(BOOL)isShow
{
    return isShow;
}

-(void)clickCancelBtn
{
    [self hidden];
}

-(void)clickComfirmBtn
{
    if ([_delegate respondsToSelector:@selector(pickHeight:)]) {
        [_delegate pickHeight:selectHeight];
    }
    [self hidden];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark pickViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = [dataSourceArray objectAtIndex:row];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectHeight = row + MinHeight;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return dataSourceArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
@end
