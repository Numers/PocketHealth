//
//  PHTagEditViewController.h
//  PocketHealth
//
//  Created by macmini on 15-2-8.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Group;
@interface PHTagEditViewController : UIViewController
{
    Group *group;
}
-(id)initWithGroup:(Group *)g;
@end
