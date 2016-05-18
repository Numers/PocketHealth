//
//  PHPhysicalExamBookManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHPhysicalExamBookManager : NSObject
+(id)defaultManager;
-(NSURLRequest *)physicalExamBookRecoderURLRequest;
-(NSURLRequest *)myPhysicalExamBookRecoderURLRequest;
-(void)requestPhysicalExamBookCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
