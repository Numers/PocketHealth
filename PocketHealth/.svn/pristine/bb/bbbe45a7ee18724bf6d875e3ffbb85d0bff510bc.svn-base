//
//  PHMoodInsideViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMoodInsideViewController.h"

@interface PHMoodInsideViewController ()
{
    

}
@end

@implementation PHMoodInsideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProgressValue:(NSInteger)progressValue
{
    _progressValue = progressValue;
    [self changeMoodImage];
    float value = progressValue/100.f;
    self.moodSlider.value =value;
}

- (IBAction)sliderChange:(id)sender {

    UISlider * slider = (UISlider *)sender;
    
    float value =slider.value*100;
    
     _progressValue= (int)value;
    [self changeMoodImage];
    
   
    
    //通知一个值出去
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PHMoodValueChange" object:[NSNumber numberWithInteger:_progressValue]];
    
}
-(void)changeMoodImage{
    if (_progressValue <= 33) {
        [self.moodImageView setImage:[UIImage imageNamed:@"moodFaceAngry"]];
    }else if (_progressValue >33&&_progressValue<=66){
        [self.moodImageView setImage:[UIImage imageNamed:@"moodFaceSad"]];
    }else{
        [self.moodImageView setImage:[UIImage imageNamed:@"moodFaceHappy"]];
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
