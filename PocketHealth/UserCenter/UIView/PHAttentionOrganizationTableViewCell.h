//
//  PHAttentionOrganizationTableViewCell.h
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Organization;
@interface PHAttentionOrganizationTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgHeadImage;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganizationName;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganizationTel;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganizationAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganizationLevel;

-(void)setupWithOrganization:(Organization *)organization;
@end
