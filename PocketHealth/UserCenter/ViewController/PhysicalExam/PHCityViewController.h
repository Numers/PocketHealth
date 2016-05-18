//
//  PHCityViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Organization;
@protocol InputPhysicalExamDelegate <NSObject>
@required
-(void)popViewWithOrganization:(Organization *)organizaiton;

@end
@interface PHCityViewController : UIViewController
@property(nonatomic, assign) id<InputPhysicalExamDelegate> delegate;
-(id)initWithGpsOrganization:(Organization *)gOrganization WithGpsCityName:(NSString *)cityName;
@end