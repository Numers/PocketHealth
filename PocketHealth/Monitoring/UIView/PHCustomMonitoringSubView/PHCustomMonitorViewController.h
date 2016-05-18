//
//  PHCustomMonitorViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    PHHealthTypeMood = 1,
    PHHealthTypeActivity = 2,
    PHHealthTypeSleep = 3
}PHHealthType;

@protocol PHCustomMonitorViewControllerDelegate <NSObject>

@optional
-(void)activityVCBtnSettingPNIBtnClick;
-(void)activityVCBtnSettingMetabolismBtnClick;

@end

@interface PHCustomMonitorViewController : UIViewController
{
    IBOutlet UIView *backView;
}
@property (strong, nonatomic) IBOutlet UILabel *labelTopTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelScore;
@property (strong, nonatomic) IBOutlet UILabel *labelDetailLabel;

//包含在view中的细节label
@property (strong, nonatomic) IBOutlet UILabel *labelProper1;
@property (strong, nonatomic) IBOutlet UILabel *labelProper2;
@property (strong, nonatomic) IBOutlet UILabel *labelProper3;
@property (strong, nonatomic) IBOutlet UILabel *labelValue1;
@property (strong, nonatomic) IBOutlet UILabel *labelValue2;
@property (strong, nonatomic) IBOutlet UILabel *labelValue3;

@property (strong, nonatomic) IBOutlet UIView *containView;

-(id)initWithHealthType:(PHHealthType)healthType;

-(void)setDynamicLabelWithDic:(NSDictionary *)dic;
-(void)settingScore:(NSInteger )score;

//委托
@property (nonatomic, weak) id<PHCustomMonitorViewControllerDelegate> delegate;
@end
