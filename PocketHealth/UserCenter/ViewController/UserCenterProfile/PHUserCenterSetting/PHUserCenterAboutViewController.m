//
//  PHUserCenterAboutViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-2.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHUserCenterAboutViewController.h"
#import "OHAttributedLabel.h"
#import "PHProtocolViewController.h"
#import "GlobalVar.h"

@interface PHUserCenterAboutViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imgAppIcon;
@property (strong, nonatomic) OHAttributedLabel *lblDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblCopyRight;

@end

@implementation PHUserCenterAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:ViewBackGroundColor];
    [_imgAppIcon.layer setCornerRadius:10.f];
    [_imgAppIcon.layer setMasksToBounds:YES];
    // Do any additional setup after loading the view from its nib.
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_lblVersion setText:[NSString stringWithFormat:@"掌上健康V%@",appVersion]];
    NSString *text = @"访问官网: http://health.cn\n官方微博: 掌上健康\n官方微信: 掌上健康";
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text];
    //设置缩进、行距
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;//行距
    [attributedStr addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[UIFont systemFontOfSize:15.f],NSFontAttributeName,[UIColor colorWithRed:148/255.f green:148/255.f blue:148/255.f alpha:1.f],NSForegroundColorAttributeName, nil] range:NSMakeRange(0, text.length)];
    CGSize size = attributedStr.size;
    _lblDetails = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height + 10)];
    [_lblDetails setNumberOfLines:0];
    [_lblDetails setUnderlineLinks:YES];
    [_lblDetails setTextAlignment:NSTextAlignmentLeft];
    [_lblDetails setLinkColor:[UIColor colorWithRed:47/255.f green:161/255.f blue:218/255.f alpha:1.f]];
    [_lblDetails setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width / 2, _lblVersion.frame.origin.y + _lblVersion.frame.size.height + size.height/2 + 76)];
    [_lblDetails setAttributedText:attributedStr];
    [self.view addSubview:_lblDetails];
    
    [self copyRightLabelSetting];
}

-(void)copyRightLabelSetting
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _lblCopyRight.text = [NSString stringWithFormat:@"Copyright © 2006-%ld 9158.com",dateComponent.year];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"关于"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickProtocolBtn:(id)sender {
    PHProtocolViewController *phProtocolVC = [[PHProtocolViewController alloc] init];
    [self.navigationController pushViewController:phProtocolVC animated:YES];
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
