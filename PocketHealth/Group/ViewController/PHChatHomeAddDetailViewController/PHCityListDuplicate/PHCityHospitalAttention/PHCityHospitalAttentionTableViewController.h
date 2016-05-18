//
//  PHCityHospitalAttentionTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//
//可以通过这些方法构造界面
//1.通过传入一个城市的方式，页面会根据城市的id去获取这个城市中的医院信息
//2.通过传入一个包含医院信息的数组,根据数组展现界面

#import <UIKit/UIKit.h>

typedef enum {
    createTypeCity = 1,
    createTypeLocation = 2
}createType;
@class City;
@interface PHCityHospitalAttentionTableViewController : UITableViewController
{
    

}
-(id)initWithCity:(City *)city;

-(id)initWithNearLocationWithLatitude:(double)lat longitude:(double)lot;


@end
