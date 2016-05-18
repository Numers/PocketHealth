//
//  PHPhysicalExamTestManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHPhysicalExamTestManager : NSObject
+(id)defaultManager;
-(NSURLRequest *)physicalExamTestURLRequest;
-(void)requestPhysicalExamTestCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end