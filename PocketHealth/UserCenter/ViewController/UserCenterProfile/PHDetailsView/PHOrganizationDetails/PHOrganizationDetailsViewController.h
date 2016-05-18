//
//  PHOrganizationDetailsViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHProtocol.h"
typedef enum
{
    OrganizationCreateTypeByDetailOne = 1,
    OrganizationCreateTypeByCityList = 2
}OrganizationCreateType;
@class Organization;
@interface PHOrganizationDetailsViewController : UIViewController
-(id)initWithOrganization:(Organization *)org;
@property (nonatomic ) OrganizationCreateType createFromType;

@property(nonatomic, assign) id<PHPushChatViewDelegate> delegate;
@end
