//
//  PHSexSelectView.h
//  PocketHealth
//
//  Created by macmini on 15-1-26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"
@protocol PHSexSelectViewDelegate <NSObject>
-(void)changeSexNotify:(sexCode)code;
@end
@interface PHSexSelectView : UIView
{
    UIButton *sexManRadioBtn;
    UIButton *sexWomanRadioBtn;
    UILabel *lblSexMan;
    UILabel *lblSexWoman;
    sexCode selectSexCode;
}
@property(nonatomic, assign) id<PHSexSelectViewDelegate> delegate;
-(void)selectSex:(sexCode)code;
@end
