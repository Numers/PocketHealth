//
//  PHAttentionDoctorTableViewCell.h
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Member;
@interface PHAttentionDoctorTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgHeadImage;
@property (strong, nonatomic) IBOutlet UILabel *lblNameAndTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDepartment;
@property (strong, nonatomic) IBOutlet UILabel *lblOrganizationName;
-(void)setupWithMember:(Member *)member;
@end
