//
//  PHFindDoctorListTableViewCell.h
//  PocketHealth
//
//  Created by macmini on 15-3-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHFindDoctorTableViewCellDelegate <NSObject>
-(void)pushToVideoChatWithTag:(NSInteger)tag;
@end
@class Room,Doctor;
@interface PHFindDoctorListTableViewCell : UITableViewCell
{
    Room *room;
    Doctor *doctor;
}
@property(nonatomic, strong) IBOutlet UIImageView *imgHeadImageView;
@property(nonatomic, strong) IBOutlet UIImageView *imgHeadImageBackColorView;
@property(nonatomic, strong) IBOutlet UIImageView *imgStarLevel;
@property(nonatomic, strong) IBOutlet UILabel *lblName;
@property(nonatomic, strong) IBOutlet UILabel *lblDepartment;
@property(nonatomic, strong) IBOutlet UILabel *lblJob;
@property(nonatomic, strong) IBOutlet UIButton *btnVideo;

@property(nonatomic) NSInteger indexTag;
@property(nonatomic, assign) id<PHFindDoctorTableViewCellDelegate> delegate;

-(void)setUpCellWithDictionary:(NSDictionary *)dic;
@end
