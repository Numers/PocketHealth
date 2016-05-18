//
//  PHActivityInsideViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHActivityInsideViewController.h"
#import "PHCircleWithLabel.h"
#import "PHAppStartManager.h"

@interface PHActivityInsideViewController ()
{
    
    IBOutlet PHCircleWithLabel *phActivityCircleView;
    IBOutlet UILabel *lblLeftCalory;
    IBOutlet UIButton *btnCalory;
    IBOutlet UIButton *btnMetabolism;
}
@end

@implementation PHActivityInsideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [btnCalory.layer setCornerRadius:15.f];
    [btnCalory.layer setMasksToBounds:YES];
    [btnMetabolism.layer setCornerRadius:15.f];
    [btnMetabolism.layer setMasksToBounds:YES];
    [phActivityCircleView inilizedView];
    [phActivityCircleView setBackgroundColor:[UIColor clearColor]];
    [phActivityCircleView setStrokeColor:[UIColor colorWithRed:16/255.0f green:255/255.0f blue:203.0f alpha:1.0f]];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)settingPNIBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(btnSettingPNIClick)]) {
        [self.delegate btnSettingPNIClick];
    }
}
- (IBAction)settingMetabolismBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(btnSettingMetabolismClick)]) {
        [self.delegate btnSettingMetabolismClick];
    }
}
-(void)resettingCalorie:(NSInteger )calorie{
    NSString * topStr = @"还剩余";
    NSString * kululi = [NSString stringWithFormat:@"%ld 大卡",(long)calorie];
    NSAttributedString *cr = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    NSAttributedString *kaluliStr = [[NSMutableAttributedString alloc] initWithString:kululi];
    NSMutableAttributedString * showStr = [[NSMutableAttributedString alloc]initWithString:topStr];
    [showStr appendAttributedString:cr];
    [showStr appendAttributedString:kaluliStr];
    [phActivityCircleView setLabelCentre:showStr];
    Member *host = [[PHAppStartManager defaultManager] userHost];
    
    if (host.calorie == 0) {
        lblLeftCalory.text = @"摄入量未设置";
        [phActivityCircleView setProgress:0.f WithAnimate:NO];
    }else if (host.metabolism == 0)
    {
        lblLeftCalory.text = @"代谢量未设置";
        float percent = calorie/host.calorie;
        if (percent > 1.f) {
            percent = 1.f;
        }
        [phActivityCircleView setProgress:percent * 100 WithAnimate:NO];
    }else{
        long baseLeftCalorie = host.calorie - [[NSNumber numberWithFloat:nearbyintf(host.metabolism)]intValue];
        if (baseLeftCalorie > 0) {
            lblLeftCalory.text = [NSString stringWithFormat:@"日热量结余%ld大卡",baseLeftCalorie];
            float percent = 1.0f*calorie/baseLeftCalorie;
            if (percent > 1.f) {
                percent = 1.f;
            }
            [phActivityCircleView setProgress:percent * 100 WithAnimate:NO];
        }else{
            lblLeftCalory.text = @"日热量结余0大卡";
            [phActivityCircleView setProgress:0 WithAnimate:NO];
        }
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
