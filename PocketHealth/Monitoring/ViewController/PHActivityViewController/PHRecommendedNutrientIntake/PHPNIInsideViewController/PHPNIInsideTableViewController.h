//
//  PHPNIInsideTableViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PNIFoodCategory;

@protocol PHPNIInsideTableViewControllerDelegate <NSObject>

-(void)changeCategroyInArray:(PNIFoodCategory *)category;

@end
@interface PHPNIInsideTableViewController : UITableViewController


-(id)initWithPNIFoodCategory:(PNIFoodCategory *)pniCategory;

@property (nonatomic , weak) id<PHPNIInsideTableViewControllerDelegate> delegate;
@end
