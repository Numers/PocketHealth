//
//  PHOrganizationSelectViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City,Organization;
@protocol CityDelegate <NSObject>
@required
-(void)popViewWithOrganization:(Organization *)org;

@end
@interface PHOrganizationSelectViewController : UIViewController
@property(nonatomic, assign) id<CityDelegate> delegate;
-(id)initWithCity:(City *)city;
@end
