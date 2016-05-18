//
//  PHDetailsOtherInfoViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Organization;
@protocol PHDetailsOtherInfoDelegate<NSObject>
-(void)selectIntroductionCellWithOrganization:(Organization *)org;
-(void)selectQRCodeCellWithOrganization:(Organization *)org;
-(void)selectAcceptMessageSwitchViewWithOrganization:(Organization *)org;
-(void)selectJoinValidateCellWithOrganization:(Organization *)org;
-(void)clickGoChatViewWithOrganization:(Organization *)org result:(void (^)(BOOL))resultFlag;

//取消关注
-(void)dontAttentionOrganization:(Organization *)org result:(void (^)(BOOL))resultFlag;
@end

@interface PHDetailsOtherInfoViewController : UIViewController
@property(nonatomic, assign) id<PHDetailsOtherInfoDelegate> delegate;
-(id)initWithOrganizaiton:(Organization *)org;
@end
