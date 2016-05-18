//
//  PHPhysicalExamTableManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-11.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"

@interface PHPhysicalExamTableManager : NSObject
+(id)defaultManager;
-(void)requestPhysicalExamTableListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(void)addNewPhysicalExamTable:(NSString *)orderId WithPassword:(NSString *)password WithorganizationOiid:(NSInteger)oiid CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
-(NSURLRequest *)physicalExamTableURLRequestWithEbid:(NSInteger)ebid;
-(void)requestPhysicalExamReportWithEbid:(NSInteger)ebid CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack;
@end
