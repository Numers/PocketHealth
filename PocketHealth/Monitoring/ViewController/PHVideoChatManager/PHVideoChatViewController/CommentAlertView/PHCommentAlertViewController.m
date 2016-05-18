//
//  PHCommentAlertViewController.m
//  PocketHealth
//
//  Created by macmini on 15-3-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHCommentAlertViewController.h"
#import "CalculateIndex.h"
#define DefaultScore 0

@interface PHCommentAlertViewController ()<UIAlertViewDelegate>
{
    NSTimeInterval callTime;
    NSInteger score;
}
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnFirstStar;
@property (strong, nonatomic) IBOutlet UIButton *btnSecondStar;
@property (strong, nonatomic) IBOutlet UIButton *btnThirdStar;
@property (strong, nonatomic) IBOutlet UIButton *btnFourthStar;
@property (strong, nonatomic) IBOutlet UIButton *btnFifthStar;
@end

@implementation PHCommentAlertViewController
-(id)initWithCallTime:(NSTimeInterval)timeInterval
{
    self = [super init];
    if (self) {
        callTime = timeInterval;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view.layer setCornerRadius:5.0f];
    [self.view.layer setMasksToBounds:YES];
    score = DefaultScore;
    [self setImageStateWithScore:score];
    [self doWithCallTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doWithCallTime
{
    long allTime = [[NSNumber numberWithDouble:callTime] longValue];
    NSInteger minites = allTime / 60;
    NSInteger seconds = allTime % 60;
//    double cost = [CalculateIndex calculateCost:allTime];
    NSString *description = [NSString stringWithFormat:@"本次通话累计%ld分%ld秒，感谢您的使用！",(long)minites,(long)seconds];
    _lblDescription.text = description;
}

-(void)showInView:(UIView *)view
{
    self.view.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
    [view addSubview:self.view];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:popAnimation forKey:nil];
}

-(void)hidden
{
    CAKeyframeAnimation *hideAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    hideAnimation.duration = 0.4;
    hideAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.00f, 0.00f, 0.00f)]];
    hideAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f];
    hideAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    hideAnimation.delegate = self;
    [self.view.layer addAnimation:hideAnimation forKey:nil];
}

-(void)setImageStateWithScore:(NSInteger)commentScore
{
    switch (commentScore) {
        case 0:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
        }
            break;
        case 4:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentEmptyStarImage"] forState:UIControlStateNormal];
        }
            break;
        case 5:
        {
            [_btnFirstStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnSecondStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnThirdStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnFourthStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
            [_btnFifthStar setBackgroundImage:[UIImage imageNamed:@"CommentFullStarImage"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (IBAction)clickFirstStarBtn:(id)sender {
    score = 1;
    [self setImageStateWithScore:score];
}

- (IBAction)clickSecondStarBtn:(id)sender {
    score = 2;
    [self setImageStateWithScore:score];
}

- (IBAction)clickThirdStarBtn:(id)sender {
    score = 3;
    [self setImageStateWithScore:score];
}

- (IBAction)clickFourthStarBtn:(id)sender {
    score = 4;
    [self setImageStateWithScore:score];
}

- (IBAction)clickFifthStarBtn:(id)sender {
    score = 5;
    [self setImageStateWithScore:score];
}

-(IBAction)clickSubmitBtn:(id)sender
{
    if (score == 0) {
        [self alertNotCommentNotify];
    }else{
        [self submitScore];
    }
}

-(void)submitScore
{
    [self hidden];
    if ([_delegate respondsToSelector:@selector(commentWithScore:)]) {
        [_delegate commentWithScore:score];
    }
}

-(void)alertNotCommentNotify
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您还未评分," delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.view removeFromSuperview];
}
@end
