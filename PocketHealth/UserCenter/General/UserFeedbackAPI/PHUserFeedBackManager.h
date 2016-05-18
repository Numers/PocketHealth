//
//  PHUserFeedBackManager.h
//  PocketHealth
//
//  Created by macmini on 15-2-3.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHUserFeedBackManager : NSObject
+(id)defaultManager;
-(void)uploadFeedBack:(NSString *)remark WithContactNumber:(NSString *)number CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
