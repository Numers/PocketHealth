//
//  PHAccountBalanceManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-30.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAFHttpHelper.h"
@interface PHAccountBalanceManager : NSObject
+(id)defaultManager;
-(NSURLRequest *)accountBalanceURLRequest;
@end
